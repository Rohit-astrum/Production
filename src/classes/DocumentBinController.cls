/* FILE: DocumentBinController.cls
 * AUTHOR: Tino Mattheou
 * DATE: March 27, 2012
 * PURPOSE: Controller for DocumentBin component
 * 06/28/2012 TCM - zen-10 create image thumbnails when uploading
 * 07/06/2012 TCM - bugfix for wrong JSON page
 * 07/26/2012 TCM - remote action classes need to be global to work in service cloud console
 * 12/07/2012 TCM - inspection verification
 * 08/21/2014 RJ - Sys-42
 */

global class DocumentBinController {
    
    public String binName { 
        get; 
        set {
            if (binName != value && value != null) {
                binName = value;
                if (projectId != null && appName != null) {
                    loadBinStuff();
                }
            }
        } 
    }
    public String projectId { 
        get; 
        set {
            if (projectId != value && value != null) {
                projectId = value;
                if (binName != null && appName != null) {
                    loadBinStuff();
                }
            }
        } 
    }
    public String appName { 
        get; 
        set {
            if (appName != value && value != null) {
                appName = value;
                if (binName != null && projectId != null) {
                    loadBinStuff();
                }
            }
        } 
    }
    public String profileName {
        get {
            return [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        }
    }
    public Date binDate { get; set; }
    public Date verificationDate { get; private set; }
    public List<InterimState> binStates { get; set; }
    public String binState { get; set; }
    public PM_Project__c project { get; set; }
    public List<Astrum_Doc__c> documents { get; private set; }
    public List<Astrum_Template__c> templates { get; set; } 
    public Attachment uploadFile { get; set; }
    public Attachment thumbFile { get; set; }
    
    public List<Category_Configuration__c> categories {
        get {
            if (categories == null && binName != null) {
                categories = DocumentConfigurationHelper.getBinCategories(DocumentConfigurationHelper.APP_ASTRUM_PM_20, binName);
            }
            return categories;
        }
        private set;
    }
    
    private String binDateField;
    
    public DocumentBinController() {
        uploadFile = new Attachment();
        thumbFile = new Attachment();
        binStates = new List<InterimState>();
    }
    
    private void loadBinStuff() {
        loadProject();
        loadDocuments();
        loadTemplates();
    }
    
    private void loadProject() {

        //find the field name for the date when this bin was completed
        for (Bin_Configuration__c bc : DocumentConfigurationHelper.getBins(DocumentConfigurationHelper.APP_ASTRUM_PM_20)) {
            if (bc.Bin__c == binName) {
                binDateField = bc.Field_Name__c;
                break;
            }
        }
        
        binState = 'Completed'; //default bin state
        for (Category_Configuration__c cat : categories) {
            if (cat.Field_Name__c != null && cat.Document_Bin_State__c != null) {
                if (cat.Field_Name__c == binDateField) {
                    binState = cat.Document_Bin_State__c;
                } else {
                    InterimState state = new InterimState();
                    state.categoryName = cat.Category__c;
                    state.fieldName = cat.Field_Name__c;
                    state.binState = cat.Document_Bin_State__c;
                    binStates.add(state); 
                }
            }
        }
        //reverse the states because of float-right
        List<InterimState> holdStates = binStates;
        binStates = new List<InterimState>();  
        for (Integer i = holdStates.size() - 1; i >= 0; i--) {
            binStates.add(holdStates[i]);
        }
        
        String query = 'SELECT Id, Name';
        query += ',Sales_Order__r.Property__r.Property_State__c,Sales_Order__r.Property__r.Property_County__c,Sales_Order__r.Property__r.Property_City__c';
        query += ',Sales_Order__r.Financing_Type__c';
        if (binDateField != null) {
            query += ', ' + binDateField + ' ';
        }
        if (binName == 'Proof of Inspection') {
            query += ', Inspection_Verified__c ';
        }
        for (InterimState state : binStates) {
            query += ',' + state.fieldName;
        }
        query += ' FROM PM_Project__c WHERE Id = :projectId';
        
        List<PM_Project__c> projects = Database.query(query);
        
        if (projects.size() > 0) {
            project = projects[0];
        }
        
        if (binDateField != null) {
            binDate = (Date)project.get(binDateField);
        }
        for (InterimState state : binStates) {
            state.binDate = (Date)project.get(state.fieldName);
        }
        if (binName == 'Proof of Inspection') {
            verificationDate = (Date)project.get('Inspection_Verified__c');
        }
        
    }
    
    private void loadDocuments() {
         documents = 
            [SELECT Id, LastModifiedDate, LastModifiedBy.Name, Category__c, Document_Key_Date__c, Verified__c, CreatedById, 
                (SELECT Bin__c 
                FROM PM_Project_Issues__r
                WHERE (To__c = :appName AND Status__c = 'Open')
                OR (To__c <> :appName AND Status__c = 'Fixed')
                OR (To__c = :appName AND Status__c = 'Fixed' AND Bin__c = 'Electrical Review')
                LIMIT 1),
                (SELECT Id, Name, BodyLength, ContentType, CreatedDate, CreatedBy.Name, Description
                FROM Attachments 
                ORDER BY BodyLength DESC LIMIT 1),
                (SELECT Id, Title, Body, LastModifiedDate, LastModifiedBy.Name
                FROM Notes 
                ORDER BY CreatedDate DESC LIMIT 1) 
            FROM Astrum_Doc__c
            WHERE PM_Project__c = :projectId
            AND Bin__c = :binName
            ORDER BY CreatedDate];
    }
    
    private void loadTemplates() {
         
         if (project != null) {
            
            List<State__c> state = [SELECT Id FROM State__c WHERE State_Abbreviation__c = :project.Sales_Order__r.Property__r.Property_State__c];
            List<County__c> county = [SELECT Id FROM County__c WHERE State__r.State_Abbreviation__c = :project.Sales_Order__r.Property__r.Property_State__c
                AND NAME LIKE :(project.Sales_Order__r.Property__r.Property_County__c + '%')];
            List<Municipality__c> city = [SELECT Id FROM Municipality__c WHERE County__c IN :county
                AND NAME LIKE :(project.Sales_Order__r.Property__r.Property_City__c + '%')];
            
            templates =
                [SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, Category__c, Form_Design__c, 
                    State__c, State__r.Name, 
                    County__c, County__r.Name, 
                    Municipality__c, Municipality__r.Name,
                    (SELECT Id, Name, ContentType
                    FROM Attachments ORDER BY CreatedDate DESC LIMIT 1),
                    (SELECT Id, Title, Body
                    FROM NOTES ORDER BY CreatedDate DESC LIMIT 1)
                FROM Astrum_Template__c
                WHERE Bin__c = :binName
                AND (State__c IN :state
                OR County__c IN :county
                OR Municipality__c IN :city)    
                AND (Financing_Type__c = :project.Sales_Order__r.Financing_Type__c
                OR Financing_Type__c = NULL)];  

         }
    }
    
    //TODO: add JSON error handling
    public PageReference upload() {

        PageReference jsonResponse = Page.DocumentBinJson;
        jsonResponse.getParameters().put('fileName', uploadFile.Name);
        jsonResponse.getParameters().put('fileSize', uploadFile.BodyLength+'');
        
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
            // RJ - SYS-42
            if(binName == 'Proof Of Inspection'  && categoryName == 'Proof Of Inspection')
            {
                doc.Document_Key_Date__c = System.today();    
            }   

            /*
            if(binName == 'Proof Of Inspection' && categoryName == 'Proof Of Inspection' && doc.Document_Key_Date__c  != null  &&  doc.Document_Key_Date__c  != System.today())
            {
                throw new CustomException('You can only choose today date for Proof of Inspection date.');
            }
            */

            insert doc;
    
            uploadFile.ParentId = doc.Id;       
            insert uploadFile;
            
            if (uploadFile.ContentType.startsWith('image/') && thumbFile.Body != null && uploadFile.BodyLength != thumbFile.BodyLength) {
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
            
        } catch (Exception e) {
            
            jsonResponse.getParameters().put('error', e.getMessage());
            
        }
            
        return jsonResponse;
    }

    //check to see if bin is completed  
    public PageReference checkBinComplete() {
        ProjectDocumentsController.checkBinComplete(projectId, binName);
        return null;
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

         // RJ - SYS-42
        if(binName == 'Proof Of Inspection'  && categoryName == 'Proof Of Inspection')
        {
            doc.Document_Key_Date__c = System.today();    
        }            

        insert doc;

        Note newNote = new Note(
            ParentId = doc.Id,
            Title = 'Note',
            Body = noteText
        );
        insert newNote;
        
        //ProjectDocumentsController.checkBinComplete(projectId, binName);
        
        return doc.Id;
            
    }
    
    @RemoteAction
    global static void updateDocument(String id, String keyDate) {
        Astrum_Doc__c doc = [SELECT Id, PM_Project__c, Bin__c, Document_Key_Date__c FROM Astrum_Doc__c WHERE Id = :id];
        if (keyDate == null || keyDate.trim().length() == 0) {
            doc.Document_Key_Date__c = null;
        } else {
            doc.Document_Key_Date__c = Date.parse(keyDate);
        }               
        update doc;
        //if (doc.PM_Project__c != null && doc.Bin__c != null) {
        //  ProjectDocumentsController.checkBinComplete(doc.PM_Project__c, doc.Bin__c);
        //}
    }

    @RemoteAction
    global static void updateCategory(String id, String catName) {
        Astrum_Doc__c doc = [SELECT Id, PM_Project__c, Bin__c, Category__c FROM Astrum_Doc__c WHERE Id = :id];
        doc.Category__c = catName;
        update doc;
        //if (doc.PM_Project__c != null && doc.Bin__c != null) {
        //  ProjectDocumentsController.checkBinComplete(doc.PM_Project__c, doc.Bin__c);
        //}
    }
    
    //returns data associated with form fields on a template
    @RemoteAction   
    global static List<FormField> getData(Id projectId, Id formDesignId) {

        List<FormField> formFields = new List<FormField>();
        
        List<Form_Data_Element__c> elements = 
            [SELECT Id, Name, SalesForce_Field__c, Required__c, FDF_Field__c  
            FROM Form_Data_Element__c
            WHERE Form_Design__c = :formDesignId
            ORDER BY Field_Order__c];

        Boolean doLegislative = false;      
        Set<String> fieldNames = new Set<String>();
        String query = 'SELECT ';
        
        for (Form_Data_Element__c fde : elements) {
            if (fde.SalesForce_Field__c != null && !fieldNames.contains(fde.SalesForce_Field__c.toUpperCase())) {
                query += fde.SalesForce_Field__c + ',';
                fieldNames.add(fde.SalesForce_Field__c.toUpperCase());
            } else if (fde.Name == 'Installation Congressional District' || fde.Name == 'Installation Legislative District') {
                doLegislative = true;
            }
        }
        
        query += 'Id,Name,Latitude__c,Longitude__c';
        query += ',Sales_Order__r.Property__r.Property_State__c,Sales_Order__r.Property__r.Property_County__c,Sales_Order__r.Property__r.Property_City__c';
        query += ',Sales_Order__r.Financing_Type__c';
        query += ' FROM PM_Project__c WHERE Id = :projectId';
        
        PM_Project__c project  = Database.query(query);
        
        String congressionalDistrict;
        String legislativeDistrict;
        if (doLegislative) {
            try {
                String[] result = LegislativeLookup.getLegislativeDistrict(project.Latitude__c, project.Longitude__c).split('/');
                congressionalDistrict = result[0];
                legislativeDistrict = result[1];
            } catch(Exception e) { } //TODO: report this
        }
        
        for (Form_Data_Element__c fde : elements) {
            FormField ff = new FormField();
            ff.fieldName = fde.Name;
            if (fde.SalesForce_Field__c != null) {
                Object value = project.get(fde.SalesForce_Field__c);
                if (value != null) {
                    ff.value = String.valueOf(value);
                }
            } else if (fde.Name == 'Installation Congressional District') {
                ff.value = congressionalDistrict;
            } else if (fde.Name == 'Installation Legislative District') {
                ff.value = legislativeDistrict;
            }
            ff.required = (fde.Required__c == true);
            formFields.add(ff);
        }
        
        return formFields;
        
    }
    
    //load documents required for the template
    @RemoteAction   
    global static List<SubmissionDocument> getDocuments(Id projectId, Id formDesignId) {
        List<SubmissionDocument> result = new List<SubmissionDocument>();
        
        Set<String> bins = new Set<String>();
        Set<String> categories = new Set<String>();
            
        List<Form_Submission_Document__c> subDocs = 
            [SELECT Id, Name, Bin__c, Category__c
            FROM Form_Submission_Document__c
            WHERE Form_Design__c = :formDesignId];
            
        //get bins and categories
        for (Form_Submission_Document__c subDoc : subDocs) {
            if (subDoc.Bin__c != null) {
                bins.add(subDoc.Bin__c);
            }
            if (subDoc.Category__c != null) {
                categories.add(subDoc.Bin__c);
            }
        }
        
        List<Astrum_Doc__c> documents = 
            [SELECT Id, Bin__c, Category__c, Document_Key_Date__c,
                (SELECT Id, Name, BodyLength, ContentType, CreatedDate, CreatedBy.Name, Description
                FROM Attachments 
                ORDER BY BodyLength DESC LIMIT 1),
                (SELECT Id, Title, Body, LastModifiedDate, LastModifiedBy.Name
                FROM Notes 
                ORDER BY CreatedDate DESC LIMIT 1)
            FROM Astrum_Doc__c
            WHERE PM_Project__c = :projectId
            AND (Bin__c IN :bins
            OR Category__c IN :categories)];            
        
        SubmissionDocument sd;
        for (Form_Submission_Document__c subDoc : subDocs) {
            sd = new SubmissionDocument();
            sd.docName = subDoc.Name;
            sd.bin = subDoc.Bin__c;
            sd.category = subDoc.Category__c;
            //see if there are any documents in the project
            if (subDoc.Category__c != null && subDoc.Bin__c != null) {
                Boolean foundDoc = false;
                for (Astrum_Doc__c doc : documents) {
                    if (doc.Bin__c == subDoc.Bin__c && doc.Category__c == subDoc.Category__c) {
                        sd.document = doc;
                        result.add(sd);
                        foundDoc = true;
                        sd = new SubmissionDocument();
                        sd.docName = subDoc.Name;
                        sd.bin = subDoc.Bin__c;
                        sd.category = subDoc.Category__c;
                    }
                }
                if (!foundDoc) {
                    result.add(sd);
                }
            } else {
                result.add(sd);         
            }
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
            OR (To__c = :appName AND Status__c = 'Fixed' AND Bin__c = 'Electrical Review'))
            LIMIT 1];
        return issues.size();
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

    global class FormField {
        public String fieldName { get; set; }
        public String value { get; set; }
        public Boolean required { get; set; }
        public Boolean missing { get { return value == null && required == true; } }
    }
    
    global class SubmissionDocument {
        public String docName;
        public String bin;
        public String category;
        public Astrum_Doc__c document;
    }
    
    global class InterimState {
        public String binName;
        public String categoryName;
        public String fieldName;
        public String binState { get; set; }
        public Date binDate { get; set; }
    }  
    
    public class CustomException extends Exception 
    {

    }

}