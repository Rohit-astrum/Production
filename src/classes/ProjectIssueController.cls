/* FILE: ProjectIssueController.cls
 * AUTHOR: Tino Mattheou
 * DATE: April 16, 2012
 * PURPOSE: Controller for ProjectIssue page  
 * MODIFICATION HISTORY
 * Rohit for Electrical Review
 */ 

global class ProjectIssueController {

    private Id projectId;
    private Id astrumDocId;
    private String bin;
    private String cat;
    private String appName;
    
    public List<Issue> issues { get; set; }
    
    public ProjectIssueController() {

        projectId = ApexPages.currentPage().getParameters().get('projectId');
        astrumDocId = ApexPages.currentPage().getParameters().get('astrumDocId');
        bin = ApexPages.currentPage().getParameters().get('bin');
        cat = ApexPages.currentPage().getParameters().get('category');
        appName = ApexPages.currentPage().getParameters().get('appName');

        loadIssues();
        if (issues.size() == 0 ) {
            addBlank();
        }
        
    }
    
    private void loadIssues() {
        
        issues = new List<Issue>();
        
        List<PM_Project_Issue__c> savedIssues = 
            [SELECT Id, Status__c, Description__c, To__c, CreatedDate, CreatedBy.Name, 
                (SELECT Id, Body, LastModifiedDate, LastModifiedBy.Name
                FROM Notes 
                ORDER BY LastModifiedDate)
            FROM PM_Project_Issue__c
            WHERE Astrum_Doc__c = :astrumDocId];

        for (PM_Project_Issue__c savedIssue : savedIssues) {
            Issue i = new Issue();
            i.issue = savedIssue;
            i.newNote = new Note(Title = 'Note');
            issues.add(i);  
        }
        
    }
    
    private void addBlank() {
        
        Issue i = new Issue();  
        i.issue = new PM_Project_Issue__c(
            PM_Project__c = projectId,
            Astrum_Doc__c = astrumDocId,
            Bin__c = bin,
            Category__c = cat,
            To__c = (appName == 'PL' ? (bin == 'Electrical Review' ? 'PL' : 'GRANTS') : 'PL' ) 
        );
        issues.add(i);
        
    }
    
    public PageReference newNote() {
        //upsert the issues first
        List<PM_Project_Issue__c> issuesToUpdate = new List<PM_Project_Issue__c>();
        for (Issue i : issues) {
            if (i.issue.Id != null) {
                issuesToUpdate.add(i.issue);
            } else if (i.issue.Description__c != null && i.issue.Description__c.trim() != '') {
                issuesToUpdate.add(i.issue);
            }
        }
        if (!issuesToUpdate.isEmpty()) {
            upsert issuesToUpdate;
        }

        //add notes, if any
        List<Note> notesToAdd = new List<Note>();
        for (Issue i : issues) {
            if (i.newNote.Body != null && i.newNote.Body.trim() != '') {
                i.newNote.ParentId = i.issue.Id;
                notesToAdd.add(i.newNote);              
            }
        }
        if (!notesToAdd.isEmpty()) {
            insert notesToAdd;
        }
        
        //reload
        loadIssues();
        
        return null;
    }
    
    public class Issue {
        public PM_Project_Issue__c issue { get; set; }
        public Note newNote { get; set; }
    }

}