/* FILE: ProjectDocumentsController.cls
 * AUTHOR: Tino Mattheou
 * DATE: April 26, 2012
 * PURPOSE: Supports display and uploading of documents on project detail page  
 * MODIFICATION HISTORY
 * 06/27/2012 TCM - zen-10 create image thumbnails when uploading
 * 09/26/2012 TCM - remote action needs to be global to work in service cloud console
 * 12/07/2012 TCM - zen-51 - fix for thumbnail issue
 * 12/07/2012 TCM - zen-79 - display verified date in bin
 */ 

global class ProjectDocumentsController {

    public static List<Bin_Configuration__c> binConfig { 
        get { 
            if (binConfig == null) {
                binConfig = DocumentConfigurationHelper.getBins(DocumentConfigurationHelper.APP_ASTRUM_PM_20);
            }
            return binConfig;
        }
        private set;
    }
    
    public static List<Category_Configuration__c> categories { 
        get { 
            if (categories == null) {
                categories = DocumentConfigurationHelper.getAllCategories(DocumentConfigurationHelper.APP_ASTRUM_PM_20);
            }
            return categories;
        }
        private set;
    }
    
    public String profileName {
        get {
            return [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        }
    }
    
    public static List<String> binGroups {
        get {
            if (binGroups == null) {
                Set<String> binGroupSet = new Set<String>();
                List<String> binGroupsValue = new List<String>();
                for (Bin_Configuration__c bc : binConfig) {
                    if (!binGroupSet.contains(bc.Bin_Grouping_Name__c)) {
                        binGroupSet.add(bc.Bin_Grouping_Name__c);
                        binGroupsValue.add(bc.Bin_Grouping_Name__c);
                    }
                }
                binGroups = binGroupsValue;
            }
            return binGroups;
        }
        private set;
    }
    
    public String projectId { 
        get; 
        set {
            if (projectId != value && value != null) {
                projectId = value;
                loadDocuments();
            }
        } 
    }
    
    public List<Astrum_Doc__c> documents { get; private set; }
    public Attachment uploadFile { get; set; }
    public Attachment thumbFile { get; set; }
    
    public ProjectDocumentsController() {
        uploadFile = new Attachment();
        thumbFile = new Attachment();
    }

    //TODO: appname     
    public String appName {
        get { 
            return DocumentConfigurationHelper.APP_ASTRUM_PM_20;
        }
    }
    
    private void loadDocuments() {
         documents = 
            [SELECT Id, LastModifiedDate, LastModifiedBy.Name, Bin__c, Category__c, Document_Key_Date__c, Verified__c, CreatedById, 
                (SELECT Bin__c 
                FROM PM_Project_Issues__r
                WHERE (To__c = :appName AND Status__c = 'Open')
                OR (To__c <> :appName AND Status__c = 'Fixed')
                OR (To__c <> :appName AND Status__c = 'Open' AND Bin__c = 'Electrical Review')
                LIMIT 1),
                (SELECT Id, Name, BodyLength, ContentType, CreatedDate, CreatedBy.Name, Description
                FROM Attachments 
                ORDER BY BodyLength DESC LIMIT 1),
                (SELECT Id, Title, Body, LastModifiedDate, LastModifiedBy.Name
                FROM Notes 
                ORDER BY CreatedDate DESC LIMIT 1) 
            FROM Astrum_Doc__c
            WHERE PM_Project__c = :projectId
            ORDER BY CreatedDate];
    }
    
    //TODO: add JSON error handling
    public PageReference upload() {

        PageReference jsonResponse = Page.ProjectDocumentsJson;
        jsonResponse.getParameters().put('fileName', uploadFile.Name);
        jsonResponse.getParameters().put('fileSize', uploadFile.BodyLength+'');
        
        String binName = ApexPages.currentPage().getParameters().get('binName');
        String categoryName = ApexPages.currentPage().getParameters().get('categoryName');
        
        Boolean hasThumb = false;

        Savepoint sp = Database.setSavepoint();

        try {
        
            Astrum_Doc__c doc = new Astrum_Doc__c (
                PM_Project__c = projectId,
                Bin__c = binName,
                Category__c = categoryName
            );
            String keyDate = ApexPages.currentPage().getParameters().get('keyDate');
            if (keyDate != null && keyDate.trim().length() > 0) {
                doc.Document_Key_Date__c = Date.parse(keyDate);     
            } else {
                keyDate = '';
            }

            // RJ
            if(binName == 'Proof Of Inspection'  && categoryName == 'Proof Of Inspection')
            {
                doc.Document_Key_Date__c = System.today();    
            }

            insert doc;
           
    
            uploadFile.ParentId = doc.Id;       
            insert uploadFile;

            if (uploadFile.ContentType.startsWith('image/') && thumbFile.Body != null) {
                hasThumb = true;
                thumbFile.Name = 'thumbnail-' + thumbFile.Name; 
                thumbFile.ParentId = doc.Id;        
                insert thumbFile;
            }
            
            uploadFile = 
                [Select Id, BodyLength, Name, ContentType
                FROM Attachment 
                WHERE Id = :uploadFile.Id];
    
            jsonResponse.getParameters().put('docId', doc.Id);
            jsonResponse.getParameters().put('attId', uploadFile.Id);
            jsonResponse.getParameters().put('keyDate', keyDate);
            jsonResponse.getParameters().put('contentType', uploadFile.ContentType);
            if (hasThumb) {
                jsonResponse.getParameters().put('thumbId', thumbFile.Id);
            }
    
            uploadFile = new Attachment();
            thumbFile = new Attachment();
    
            checkBinComplete(projectId, binName);
        
        } catch (Exception e) {
            
            jsonResponse.getParameters().put('error', e.getMessage());
            
        }

        return jsonResponse;
    }
    
    //adds a note document  
    @RemoteAction
    global static String addNote(String projectId, String binName, String categoryName, String noteText) {

        Astrum_Doc__c doc = new Astrum_Doc__c (
            PM_Project__c = projectId,
            Bin__c = binName,
            Category__c = categoryName,
            IsNote__c = true
        );
        // RJ

        if(binName == 'Proof Of Inspection'  && categoryName == 'Proof Of Inspection')
        {
             doc.Document_Key_Date__c = System.today();    
        }
        System.debug('***doc.Document_Key_Date__c -'+doc.Document_Key_Date__c);
        insert doc;

        Note newNote = new Note(
            ParentId = doc.Id,
            Title = 'Note',
            Body = noteText
        );
        insert newNote;
        
        checkBinComplete(projectId, binName);
        
        return doc.Id;
            
    }
    
    @RemoteAction
    global static List<DocumentBinController.InterimState> getAllBinStates(String projectId) {
        List<DocumentBinController.InterimState> result = new List<DocumentBinController.InterimState>();
        Set<String> binFields = new Set<String>();
        Set<String> dateFields = new Set<String>();
        Map<String,String> binFieldMap = new Map<String,String>();
        Map<String,String> binStateMap = new Map<String,String>();
        
        for (Bin_Configuration__c bc : binConfig) {
            binFields.add(bc.Field_Name__c);
            binFieldMap.put(bc.Bin__c, bc.Field_Name__c);
            binStateMap.put(bc.Bin__c, 'Completed');
        }
        dateFields.addAll(binFields);
        
        for (Category_Configuration__c cat : categories) {
            if (cat.Field_Name__c != null) {
                if (binFields.contains(cat.Field_Name__c) && cat.Document_Bin_State__c != null) {
                    binStateMap.put(cat.Bin__c, cat.Document_Bin_State__c);
                } else {
                    dateFields.add(cat.Field_Name__c);
                    DocumentBinController.InterimState state = new DocumentBinController.InterimState();
                    state.binName = cat.Bin__c;
                    state.categoryName = cat.Category__c;
                    state.fieldName = cat.Field_Name__c;
                    state.binState = cat.Document_Bin_State__c;
                    result.add(state); 
                }
            }
        }
        
        dateFields.add('Inspection_Verified__c');
        
        String query = 'SELECT Id';
        for (String field : dateFields) {
            query += ',' + field;
        }
        query += ' FROM PM_Project__c WHERE Id = :projectId';
        
        PM_Project__c project = Database.query(query);
        
        for (DocumentBinController.InterimState state : result) {
            state.binDate = (Date)project.get(state.fieldName);
        }
        
        for (String bin : binFieldMap.keySet()) {
            DocumentBinController.InterimState state = new DocumentBinController.InterimState();
            state.binName = bin;
            state.fieldName = binFieldMap.get(bin);
            state.binState = binStateMap.get(bin);
            state.binDate = (Date)project.get(state.fieldName);
            result.add(state); 
        }
        
        if (project.get('Inspection_Verified__c') != null) {
            DocumentBinController.InterimState state = new DocumentBinController.InterimState();
            state.binName = 'Proof of Inspection';
            state.fieldName = 'Inspection_Verified__c';
            state.binState = 'Verified';
            state.binDate = (Date)project.get('Inspection_Verified__c');
            result.add(state); 
        } 
        
        return result;
    }
    
    @RemoteAction
    global static Integer getDocIssueCount(String appName, String documentId) {
        List<PM_Project_Issue__c> issues =
            [SELECT Id 
            FROM PM_Project_Issue__c
            WHERE Astrum_Doc__c = :documentId
            AND ((To__c = :appName AND Status__c = 'Open')
            OR (To__c <> :appName AND Status__c = 'Fixed')
            OR (To__c <> :appName AND Status__c = 'Open' AND Bin__c = 'Electrical Review'))
            LIMIT 1];
        return issues.size();
    }
    
    @RemoteAction
    global static void updateDocument(String id, String keyDate) {
        Astrum_Doc__c doc = new Astrum_Doc__c(Id = id);
        if (keyDate == null || keyDate.trim().length() == 0) {
            doc.Document_Key_Date__c = null;
        } else {
            doc.Document_Key_Date__c = Date.parse(keyDate);
        }
        update doc;
        
        doc = [SELECT Id, Bin__c, PM_Project__c FROM Astrum_Doc__c WHERE Id = :id];
        
        if (doc.PM_Project__c != null) {
            checkBinComplete(doc.PM_Project__c, doc.Bin__c);
        }
        
    }

    @RemoteAction
    global static void updateCategory(String id, String binName, String catName) {
        
        //make sure the new bin and category are set
        System.assert(binName != null && binName.trim().length() > 0, 'Bin cannot be blank');
        System.assert(catName != null && catName.trim().length() > 0, 'Category cannot be blank');
        
        Astrum_Doc__c doc = new Astrum_Doc__c(Id = id, Bin__c = binName, Category__c = catName);
        update doc;
        
        doc = [SELECT Id, Bin__c, PM_Project__c FROM Astrum_Doc__c WHERE Id = :id];
        
        if (doc.PM_Project__c != null) {
            checkBinComplete(doc.PM_Project__c, doc.Bin__c);
        }
        
    }

    @RemoteAction
    global static Boolean verifyDocument(String documentId) {
        Astrum_Doc__c doc = [SELECT Id, Verified__c FROM Astrum_Doc__c WHERE Id = :documentId];
        if (doc.Verified__c == true) {
            doc.Verified__c = false;
        } else {
            doc.Verified__c = true;
        }
        update doc;
        return doc.Verified__c; 
    }
    
    @RemoteAction
    global static List<AstrumDocument> getDocuments(String appName, String projectId, String binName) {
        
        List<AstrumDocument> result = new List<AstrumDocument>();
        
        Time zero = Time.newInstance(0,0,0,0);

        List<Astrum_Doc__c> documents = 
            [SELECT Id, LastModifiedDate, LastModifiedBy.Name, Bin__c, Category__c, Document_Key_Date__c, Verified__c, CreatedById, 
                (SELECT Bin__c 
                FROM PM_Project_Issues__r
                WHERE (To__c = :appName AND Status__c = 'Open')
                OR (To__c <> :appName AND Status__c = 'Fixed')
                OR (To__c = :appName AND Status__c = 'Fixed' AND Bin__c = 'Electrical Review')
                LIMIT 1),
                (SELECT Id, Name, BodyLength, ContentType, CreatedDate, CreatedBy.Name, Description
                FROM Attachments 
                ORDER BY CreatedDate DESC LIMIT 1),
                (SELECT Id, Title, Body, LastModifiedDate, LastModifiedBy.Name
                FROM Notes 
                ORDER BY CreatedDate DESC LIMIT 1) 
            FROM Astrum_Doc__c
            WHERE PM_Project__c = :projectId
            AND Bin__c = :binName
            ORDER BY CreatedDate];
            
        for (Astrum_Doc__c doc : documents) {
            AstrumDocument d = new AstrumDocument();
            d.docid = doc.Id;
            if (doc.Document_Key_Date__c != null) { 
                d.keyDate = Datetime.newInstance(doc.Document_Key_Date__c, zero).format('M/d/yyyy');
            }
            d.binName = doc.Bin__c;
            d.categoryName = doc.Category__c;
            if (doc.Attachments.size() > 0) {
                Attachment att = doc.Attachments[0]; 
                d.name = att.Name;
                d.contentType = att.ContentType;
                d.url = '/servlet/servlet.FileDownload?file=' + att.Id;
            } else if (doc.Notes.size() > 0) {
                Note n = doc.Notes[0];
                d.notes = n.Body;
                d.author = n.LastModifiedBy.Name;
                d.docDate = n.LastModifiedDate.format('M/d/yyyy');
            }
            d.issue = doc.PM_Project_issues__r.size() > 0;
            d.verified = doc.Verified__c == true;
            d.verifiable = doc.CreatedById != UserInfo.getUserId();
            result.add(d);
        } 
         
        return result;
    }
    
    //check to see if bin is completed
    @RemoteAction
    global static void checkBinComplete(String projectId, String binName) {

        Integer totalRequiredCategories = 0;
        Integer completedRequiredCategories = 0;
        
        //count docs and get dates
        Map<String, AggregateResult> categoryMap = new Map<String, AggregateResult>();
        List<AggregateResult> summary = 
            [SELECT Category__c, COUNT(Id) total, MAX(Document_Key_Date__c) keyDate, MAX(LastModifiedDate) modDate  
            FROM Astrum_Doc__c
            WHERE PM_Project__c = :projectId
            AND Bin__c = :binName
            GROUP BY Category__c];
        for (AggregateResult result: summary) {
            categoryMap.put((String)result.get('Category__c'), result);
        }
        
        //find the field name for the date when bin completed
        String binDateField;
        for (Bin_Configuration__c bc : binConfig) {
            if (bc.Bin__c == binName) {
                binDateField = bc.Field_Name__c;
                break;
            }
        }
        
        //nothing to update
        if (binDateField == null) {
            return;
        }

        //create project object for use for update      
        PM_Project__c project = new PM_Project__c (Id = projectId);
        
        //get the current project dates and reset the project object dates
        String query = 'SELECT Id';
        if (binDateField != null) {
            query += ', ' + binDateField + ' ';
            //clear the bin date
            project.put(binDateField, null);
        }
        for (Category_Configuration__c cat : categories) {
            if (cat.Bin__c == binName && cat.Field_Name__c != null && cat.Field_Name__c != binDateField) { 
                query += ',' + cat.Field_Name__c;
                    //clear category dates
                    project.put(cat.Field_Name__c, null);
            }
        }
        query += ' FROM PM_Project__c WHERE Id = :projectId';
        PM_Project__c existing = Database.query(query);
        
        //determine the interim category dates, if any
        Date categoryBinDate;
        Boolean categoryDateRequired;
        for (Category_Configuration__c cat : categories) {
            if (cat.Bin__c == binName && cat.Minimum_Required__c != null && cat.Minimum_Required__c >= 1) {
                System.debug('1*'+cat.Bin__c);
                totalRequiredCategories++;                
                AggregateResult result = categoryMap.get(cat.Category__c);
                if (result == null) {
                    continue;
                }
                //check if the total number of required is there
                Integer total = (Integer)result.get('total');
                if (total != null && total >= cat.Minimum_Required__c) {
                    completedRequiredCategories++;
                    if (cat.Field_Name__c != null) {
                        //use the lowest key date (assume only 1 doc required with a key date)
                        Date newCategoryDate = (Date)result.get('keyDate');
                        if (cat.Document_Date_Required__c != true) {
                            //if no key date, see if there was a date already, use that
                            if (newCategoryDate == null) {
                                newCategoryDate = ((Datetime)result.get('modDate')).date();
                                //newCategoryDate = (Date)existing.get(cat.Field_Name__c);
                            }
                            //if no date already, use today
                            if (newCategoryDate == null) {
                                newCategoryDate = System.today();
                            }
                        }
                        //if this is for a bin, check if all required categories complete
                        if (cat.Field_Name__c == binDateField) {
                            categoryBinDate = newCategoryDate;
                            categoryDateRequired = cat.Document_Date_Required__c;
                        } else {
                            project.put(cat.Field_Name__c, newCategoryDate);
                            System.debug('1a*'+cat.Field_Name__c);
                        }
                    } else { //category doesn't map
                        Date possibleBinDate = (Date)result.get('keyDate');
                        if (possibleBinDate == null) {
                            possibleBinDate = ((Datetime)result.get('modDate')).date();
                        }
                        if (possibleBinDate != null && (categoryBinDate == null || possibleBinDate > categoryBinDate)) {
                            categoryBinDate = possibleBinDate;
                        }
                    }
                }
            }
            else if(cat.Bin__c == binName && binName == 'Finance Completion Forms' && cat.Category__c == 'Finance Approval to Inspect (NRG only)')
            {
                
                AggregateResult result1 = categoryMap.get(cat.Category__c);
                if (result1 == null) {
                    continue;
                }
                
                Date newCategoryDate1 = (Date)result1.get('keyDate');
               
                //if no key date, see if there was a date already, use that
                if (newCategoryDate1 == null) {
                    newCategoryDate1 = ((Datetime)result1.get('modDate')).date();
                    //newCategoryDate = (Date)existing.get(cat.Field_Name__c);
                }
                //if no date already, use today
                if (newCategoryDate1 == null) {
                    newCategoryDate1 = System.today();
                }
               
                project.put(cat.Field_Name__c, newCategoryDate1);    
            }
            // Added by RJ for SYS-42
            if(cat.Bin__c == binName && binName == 'Proof of Inspection' && cat.Category__c == 'Proof of Inspection')
            {
                
                AggregateResult result1 = categoryMap.get(cat.Category__c);
                if (result1 == null) {
                    continue;
                }
                
                Date newCategoryDate1 = (Date)result1.get('keyDate');
               
                //if no key date, see if there was a date already, use that
                if (newCategoryDate1 == null) {
                    newCategoryDate1 = ((Datetime)result1.get('modDate')).date();
                    //newCategoryDate = (Date)existing.get(cat.Field_Name__c);
                }
                //if no date already, use today
                if (newCategoryDate1 == null) {
                    newCategoryDate1 = System.today();
                }
                Date existingDate = (Date)existing.get(binDateField);
                if(existingDate == null )
                {
                    categoryBinDate =  System.today();    
                }
                else if(existingDate != System.today())
                {
                    categoryBinDate = existingDate;
                }    
                else
                {
                    categoryBinDate =    newCategoryDate1; 
                }
            }
        }

        //bin is complete if the number of completed categories equals the number of required categories and there is at least one document     
        if (totalRequiredCategories == completedRequiredCategories && summary.size() > 0) {
            Date newBinDate = categoryBinDate;
            if (categoryDateRequired != true) {
                if (newBinDate == null) { 
                    //find uncategorized min date
                    AggregateResult result = categoryMap.get('Uncategorized');
                    if (result != null) {
                        newBinDate = (Date)result.get('keyDate');
                        if (newBinDate == null) {
                            newBinDate = ((Datetime)result.get('modDate')).date();
                        }
                    }
                }
                if (newBinDate == null) {
                    newBinDate = (Date)existing.get(binDateField);
                }
                if (newBinDate == null) {
                    newBinDate = Date.today();
                }
            }
            project.put(binDateField, newBinDate);
        }
        
        update project;
    }
    
    global class AstrumDocument {
        public String docid;
        public String name;
        public String url;
        public String keyDate;
        public String contentType;
        public String binName;
        public String categoryName;
        public String notes;
        public String author;
        public String docDate;
        public Boolean issue;
        public Boolean verified;
        public Boolean verifiable;
    }
    
}