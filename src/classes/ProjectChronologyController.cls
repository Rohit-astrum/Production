/* FILE: ProjectChronologyController.cls
 * AUTHOR: Tino Mattheou
 * DATE: April 18, 2012
 * PURPOSE: Controller for ProjectChronology component
 * MODIFICATION HISTORY
 * 06/25/2012 TCM - zen-4 Date time not showing up if there is no date set
 * 12/07/2012 TCM - zen-79 - Inspection Verification Flow
 * 12/07/2012 TCM - zen-51 - fix for thumbnail issue
 */ 
 
public class ProjectChronologyController {

    public String projectId { 
        get; 
        set {
            if (projectId != value && value != null) {
                projectId = value;
                loadChronology();
            }
        } 
    }
    
    public List<ChronologyItem> items { get; set; }

    private void loadChronology() {
        
        items = loadDocumentHistory();
        items.addAll(loadIssueHistory());
        items.addAll(loadProjectDates());
        
        sortItems();
        
    }
    
    private String[] projectDateFields = new String[] { 'Install__c', 'Customer_Care_Handoff__c', 'Inspection_Verified__c' };
    private String[] projectDateTimeFields = new String[] { 'Kickoff__c', 'Inspection__c' };
    private String[] projectDateDesc = new String[] { 'Install Date', 'Customer Care Handoff Date', 'Inspection Verified Date' };
    private String[] projectDateTimeDesc = new String[] { 'Kickoff Date', 'Inspection Date' };
    private String[] projectDateIcon = new String[] { 'install', 'handoff', 'inspect' };
    private String[] projectDateTimeIcon = new String[] { 'kickoff', 'inspect' };

    //DOCUMENTS AND VERIFICATION
    private List<ChronologyItem> loadDocumentHistory() {
        
        List<ChronologyItem> result = new List<ChronologyItem>();
        
        List<Astrum_Doc__c> documents = 
            [SELECT Id, CreatedDate, CreatedBy.Name, Document_Key_Date__c, Verified__c, Category__c, Bin__c, 
                (SELECT Id, Description__c, CreatedDate, CreatedBy.Name
                FROM PM_Project_Issues__r
                ORDER BY CreatedDate),
                (SELECT Id, Name, BodyLength, ContentType, CreatedDate, CreatedBy.Name, Description
                FROM Attachments 
                ORDER BY BodyLength DESC LIMIT 1),
                (SELECT Id, Title, Body, LastModifiedDate, LastModifiedBy.Name
                FROM Notes 
                ORDER BY CreatedDate DESC LIMIT 1),
                (SELECT CreatedDate, CreatedBy.Name, Field, OldValue, NewValue 
                FROM Histories) 
            FROM Astrum_Doc__c
            WHERE PM_Project__c = :projectId
            ORDER BY CreatedDate DESC];
            
        ChronologyItem event;   
        
        for (Astrum_Doc__c document : documents) {
            event = new ChronologyItem();
            event.eventDate = document.CreatedDate;
            event.eventUser = document.CreatedBy.Name;
            event.eventBin = document.Bin__c;
            if (document.Attachments.size() > 0) {
                event.eventType = document.Category__c + ' Document Added';
                event.linkId = document.Id;
                event.documentName = document.Attachments[0].Name;
                event.attachId = document.Attachments[0].Id;
                event.attachType = document.Attachments[0].ContentType;
                event.icon = 'doc';
            } else if (document.Notes.size() > 0) {
                event.eventType = document.Category__c + ' Note Added';
                event.description = document.Notes[0].Body;
                event.icon = 'note';
            }
            result.add(event);

            for (Astrum_Doc__History h : document.Histories) {
                //verification
                if (h.Field == 'Verified__c') {
                    event = new ChronologyItem();
                    event.eventDate = h.CreatedDate;
                    event.eventUser = h.CreatedBy.Name;
                    event.eventBin = document.Bin__c;
                    event.eventType = document.Category__c + ' Document ' + (h.NewValue == true ? 'Verified' : 'Unverified');
                    if (document != null && document.Attachments.size() > 0) {
                        event.documentName = document.Attachments[0].Name;
                        event.attachId = document.Attachments[0].Id;
                        event.attachType = document.Attachments[0].ContentType;
                    }
                    event.icon = (h.NewValue == true ? 'check' : 'uncheck');
                    result.add(event);
                }
            }
            
        }
        
        return result;  
        
    }
    
    //ISSUES
    private List<ChronologyItem> loadIssueHistory() {

        List<ChronologyItem> result = new List<ChronologyItem>();
        Set<Id> documentIds = new Set<Id>();
        Map<Id, Astrum_Doc__c> documentMap = new Map<Id, Astrum_Doc__c>();

        List<PM_Project_Issue__c> issues =
            [SELECT Id, CreatedDate, CreatedBy.Name, Description__c, Astrum_Doc__c, Category__c, Bin__c, 
                (SELECT Id, CreatedDate, CreatedBy.Name, Body
                FROM Notes 
                ORDER BY CreatedDate DESC) ,
               (Select Id, CreatedDate, CreatedBy.Name,Status_Old_value__c, Status_New_Value__c From PM_Project_Issues_Hisotry__r ORDER BY CreatedDate DESC) 
            FROM PM_Project_Issue__c
            WHERE PM_Project__c = :projectId
            ORDER BY CreatedDate DESC];        
            
        for (PM_Project_Issue__c issue : issues) {
            if (issue.Astrum_Doc__c != null) {
                documentIds.add(issue.Astrum_Doc__c);
            }           
        }
        
        if (!documentIds.isEmpty()) {
            documentMap = new Map<Id, Astrum_Doc__c>(
                [SELECT Id,   
                    (SELECT Id, Name, ContentType
                    FROM Attachments LIMIT 1)
                FROM Astrum_Doc__c
                WHERE Id IN :documentIds]
            );
        }
            
        ChronologyItem event;

        for (PM_Project_Issue__c issue : issues) {
            event = new ChronologyItem();
            event.eventDate = issue.CreatedDate;
            event.eventUser = issue.CreatedBy.Name;
            event.eventType = issue.Category__c + ' Issue Created';
            event.icon = 'alert';
            event.description = issue.Description__c;
            Astrum_Doc__c doc = null;
            if (issue.Astrum_Doc__c != null) {
                doc = documentMap.get(issue.Astrum_Doc__c);
                if (doc != null) {
                    event.linkId = doc.Id;
                    event.eventBin = issue.Bin__c;
                    if (doc.Attachments.size() > 0) {
                        event.documentName = doc.Attachments[0].Name;
                        event.attachId = doc.Attachments[0].Id;
                        event.attachType = doc.Attachments[0].ContentType;
                    } else {
                        event.documentName = 'Note';
                    }
                }
            }
            result.add(event);
            
            for (Note n : issue.Notes) {
                event = new ChronologyItem();
                event.eventDate = n.CreatedDate;
                event.eventUser = n.CreatedBy.Name;
                event.eventType = issue.Category__c + ' Issue Comment';
                event.icon = 'issue';
                event.description = n.Body;
                if (doc != null && doc.Attachments.size() > 0) {
                    event.documentName = doc.Attachments[0].Name;
                    event.attachId = doc.Attachments[0].Id;
                    event.attachType = doc.Attachments[0].ContentType;
                    event.eventBin = issue.Bin__c;
                    event.linkId = doc.Id;
                }
                result.add(event);
            }
            
            for (PM_Project_Issue_History__c n : issue.PM_Project_Issues_Hisotry__r) {
                event = new ChronologyItem();
                event.eventDate = n.CreatedDate;
                event.eventUser = n.CreatedBy.Name;
                event.eventType = issue.Category__c + ' Issue is ' + n.Status_New_Value__c ;
                if(n.Status_New_Value__c == 'Fixed')
                    event.icon = 'fixed';
                else if(n.Status_New_Value__c == 'Open')   
                     event.icon = 'alert'; 
                 else if(n.Status_New_Value__c == 'Closed')   
                     event.icon = '';      
                     
                event.description = issue.Description__c;   
               
                if (issue.Astrum_Doc__c != null) {
                    doc = documentMap.get(issue.Astrum_Doc__c);
                    if (doc != null) {
                        event.linkId = doc.Id;
                        event.eventBin = issue.Bin__c;
                        /*if (doc.Attachments.size() > 0) {
                            event.documentName = doc.Attachments[0].Name;
                            event.attachId = doc.Attachments[0].Id;
                            event.attachType = doc.Attachments[0].ContentType;
                        } else {
                            event.documentName = 'Note';
                        }*/
                    }
                }
                           
                result.add(event);
            }
        }

        return result;  
        
    }
    
    //PROJECT DATES
    private List<ChronologyItem> loadProjectDates() {

        List<ChronologyItem> result = new List<ChronologyItem>();
        
        Set<String> fieldNames = new Set<String>();

        //find the project date fields      
        List<Bin_Configuration__c> pmConfig = DocumentConfigurationHelper.getBins(DocumentConfigurationHelper.APP_ASTRUM_PM_20);
        for (Bin_Configuration__c pm : pmConfig) {
            fieldNames.add(pm.Field_Name__c);
        }
        
        List<DocumentConfigurationHelper.SpecialCategory> specialCategories 
            = DocumentConfigurationHelper.getSpecialCategories(DocumentConfigurationHelper.APP_ASTRUM_PM_20);
        for (DocumentConfigurationHelper.SpecialCategory cat : specialCategories) {
            fieldNames.add(cat.categoryDateFieldName);
        }
        
        String query = 'SELECT Id, Kickoff__c, Install__c, Inspection__c, Customer_Care_Handoff__c, Inspection_Verified__c, CreatedDate, CreatedBy.Name';
        query += ',(SELECT CreatedDate, CreatedBy.Name, Field, OldValue, NewValue FROM Histories WHERE Field IN :projectDateFields OR Field IN :projectDateTimeFields)';
        for (String fieldName : fieldNames) {
            query += ',' + fieldName;
        }
        query += ' FROM PM_Project__c WHERE Id = :projectId';
        
        PM_Project__c project = Database.query(query);

        ChronologyItem event;
        Date dt;
        Datetime dtime;
        Time midnite = Time.newInstance(0, 0, 0, 0);
        
        for (Bin_Configuration__c pm : pmConfig) {
            dt = (Date)project.get(pm.Field_Name__c);
            if (dt != null) {
                event = new ChronologyItem();
                event.eventDate = Datetime.newInstance(dt, midnite);
                //event.eventUser = n.CreatedBy.Name; //TODO: PL name?
                event.eventType = pm.Bin__c + ' Completed'; //TODO: binstate
                event.eventBin = pm.Bin__c;
                event.icon = 'done';
                result.add(event);
            }
        }
        
        //category dates (bin stages)
        for (DocumentConfigurationHelper.SpecialCategory cat : specialCategories) {
            dt = (Date)project.get(cat.categoryDateFieldName);
            if (dt != null) {
                event = new ChronologyItem();
                event.eventDate = Datetime.newInstance(dt, midnite);
                //event.eventUser = n.CreatedBy.Name; //TODO: PL name?
                event.eventType = cat.binName + ' ' + cat.binState;
                event.eventBin = cat.binName;
                event.icon = 'state';
                result.add(event);
            }
        }

        //project creation      
        event = new ChronologyItem();
        event.eventDate = project.CreatedDate;
        event.eventType = 'Project Created';
        event.eventUser = project.CreatedBy.Name;
        event.icon = 'new';
        result.add(event);
        
        for (Integer i = 0; i < projectDateFields.size(); i++) {
            dt = (Date)project.get(projectDateFields[i]);
            if (dt != null) {
                event = new ChronologyItem();
                event.eventDate = Datetime.newInstance(dt, midnite);
                event.eventType = projectDateDesc[i];
                event.icon = projectDateIcon[i];
                event.eventBin = 'Project';
                result.add(event);
            }
        }

        for (Integer i = 0; i < projectDateTimeFields.size(); i++) {
            dtime = (Datetime)project.get(projectDateTimeFields[i]);
            if (dtime != null) {
                event = new ChronologyItem();
                event.eventDate = dTime;
                event.eventType = projectDateTimeDesc[i];
                event.icon = projectDateTimeIcon[i];
                event.eventBin = 'Project';
                result.add(event);
            }
        }
        
        for (PM_Project__History h : project.Histories) {
            for (Integer i = 0; i < projectDateFields.size(); i++) {
                if (h.Field == projectDateFields[i]) {
                    event = new ChronologyItem();
                    event.eventDate = h.CreatedDate;
                    event.eventUser = h.CreatedBy.Name;
                    event.eventBin = 'Project';
                    Time zero = Time.newInstance(0, 0, 0, 0);
                    String oldDate = null;
                    String newDate = null;  
                    if (h.oldValue != null) {
                        oldDate = DateTime.newInstance((Date)h.oldValue,zero).format('M/d/yy');
                    } 
                    if (h.newValue != null) {
                        newDate = DateTime.newInstance((Date)h.newValue,zero).format('M/d/yy');
                    }
                    if (oldDate == null) {
                        event.eventType = projectDateDesc[i] + ' - set to ' + newDate;
                    } else if (newDate == null) {
                        event.eventType = projectDateDesc[i] + ' - ' + oldDate + ' deleted';
                    } else {
                        event.eventType = projectDateDesc[i] + ' - changed from ' + oldDate + ' to ' + newDate;
                    }
                    event.icon = projectDateIcon[i];
                    result.add(event);
                    break;
                }
            }
            for (Integer i = 0; i < projectDateTimeFields.size(); i++) {
                if (h.Field == projectDateTimeFields[i]) {
                    event = new ChronologyItem();
                    event.eventDate = h.CreatedDate;
                    event.eventUser = h.CreatedBy.Name;
                    event.eventBin = 'Project';
                    String oldDate = null;
                    String newDate = null;  
                    if (h.oldValue != null) {
                        oldDate = ((Datetime)h.oldValue).format('M/d/yy h:mma');
                    } 
                    if (h.newValue != null) {
                        newDate = ((Datetime)h.newValue).format('M/d/yy h:mma');
                    }
                    if (oldDate == null) {
                        event.eventType = projectDateTimeDesc[i] + ' - set to ' + newDate;
                    } else if (newDate == null) {
                        event.eventType = projectDateTimeDesc[i] + ' - ' + oldDate + ' deleted';
                    } else {
                        event.eventType = projectDateTimeDesc[i] + ' - changed from ' + oldDate + ' to ' + newDate;
                    }
                    event.icon = projectDateTimeIcon[i];
                    result.add(event);
                    break;
                }
            }
        }

        return result;
        
    }
    
    private void sortItems() {
        
        List<ChronologyItem> result = new List<ChronologyItem>();
        
        Map<DateTime, List<ChronologyItem>> keyMap = new Map<DateTime, List<ChronologyItem>>();
        List<ChronologyItem> mapList;
        
        for (ChronologyItem item : items) {
            mapList = keyMap.get(item.eventDate);
            if (mapList == null) {
                mapList = new List<ChronologyItem>();
                keyMap.put(item.eventDate, mapList);
            }
            mapList.add(item);
        }
        List<DateTime> keys = new List<DateTime>(keyMap.keySet());
        keys.sort();
        
        for (Integer i = keys.size() - 1; i >= 0; i--) {
            mapList = keyMap.get(keys[i]);
            for (ChronologyItem item : mapList) {
                result.add(item);
            }
        }
        
        items = result;
    }
    
    public class ChronologyItem {
        public DateTime eventDate { get; set; }
        public String eventType { get; set; }
        public String eventUser { get; set; }
        public String eventBin { get; set; }
        public String eventCategory { get; set; }
        public String documentName { get; set; }
        public String description { get; set; }
        public Id linkId { get; set; }
        public Id attachId { get; set; }
        public String attachType { get; set; }
        public String dateFormatted { 
            get { return eventDate != null ? eventDate.format('M/d/yy') : ''; }
        }
        public String dateTimeFormatted { 
            get { 
                if (eventDate != null && eventDate.hour() == 0 && eventDate.minute() == 0 && eventDate.second() == 0) {
                    return eventDate.format('M/d/yy');
                }
                return eventDate != null ? eventDate.format('M/d/yy h:mma') : '';           
            }
        }
        public String icon { get; set; }
    }

}