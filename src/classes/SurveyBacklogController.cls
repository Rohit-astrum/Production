/* FILE: SurveyBacklogController.page
 * AUTHOR: Rohit Jain
 * DATE: Aug 18, 2013
 * PURPOSE: Edit page for Survey Backlog by Sales Coordinators
 * MODIFICATION HISTORY 
 */
public class SurveyBacklogController {
    // ApexPages.StandardSetController must be instantiated
    // for standard list controllers
   public boolean isEdit {get; set;}

   public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Name, Backlog_in_days__C FROM Astrum_Sales_Region__c]));
            }
            return setCon;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<Astrum_Sales_Region__c> getRegions() {
        return (List<Astrum_Sales_Region__c>) setCon.getRecords();
    }

    public PageReference save()
    {
        update setCon.getRecords();
        isEdit = false;
        return null;
    }

    public PageReference edit()
    {
        isEdit = true;
        return null;
    }

    public PageReference cancel()
    {        
        
        isEdit = false;
        return null;
    }
    
}