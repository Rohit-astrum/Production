/* FILE: CreateAstrumPM2ProjectExtension.cls
 * AUTHOR: Tino Mattheou
 * DATE: May 31, 2012
 * PURPOSE: Creates Astrum PM 2.0 Project from Sales Order
 * MODIFICATION HISTORY
 * 06/25/2012 TCM - retrieve opportunity owner id directly since sharing prevents seeing the opportunity owner in the standard controller zen-9
 * 08/11/2014  LLH - trimmed out code because process was split into two stages, this stage only creates PM Project now.
 * 06/16/2015 PB- FPO Calcualte and update costprojections
 * 01/15/2016 PB- FPO Sprint 6- On Rootstock objects recreation transfer components and budget
 */
public class CreateAstrumPM2ProjectExtension {

    private SCRB_SalesOrder__c salesOrder;
    public Id projectId { get; private set; }

    public CreateAstrumPM2ProjectExtension(ApexPages.StandardController stdController) {
        salesOrder = (SCRB_SalesOrder__c)stdController.getRecord();
    }
    
    public PageReference createProject() {
        
        
        /*
        List<PM_Project__c> projects = [SELECT Id FROM PM_Project__c WHERE Sales_Order__c = :salesOrder.Id];

        //if project already exists, display the project        
        if (projects.size() > 0) {
            projectId = projects[0].Id;
            System.debug('projectId=' + projectId);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A project already exists for this sales order.'));
            return null;
        }
        
        SCRB_SalesOrder__c so = [SELECT Id, OpportunityId__c, OpportunityId__r.OwnerId FROM SCRB_SalesOrder__c WHERE Id = :salesOrder.Id];
        
        //create a new PM 2.0 project
        PM_Project__c newProject = new PM_Project__c(
            Name = salesOrder.AccountId__r.Name,
            Sales_Order__c = salesOrder.Id,
            Salesperson__c = so.OpportunityId__r.OwnerId
        );
         
        Date requestedInstall = salesOrder.RequestedShipmentOn__c;
        if (requestedInstall == null) {
            requestedInstall = Date.today().addDays(90);
        }
        newProject.Install__c = nextWeekday(requestedInstall); 
        //default to noon
        newProject.Kickoff__c = Datetime.newInstance(nextWeekDay(Date.today().addDays(7)), Time.newInstance(12,0,0,0));
        
        insert newProject;
        
        */
        RootstockAutomation amr = new RootstockAutomation();
        
        projectId = amr.processSalesOrder(salesOrder );

        
        if(projectId != null)
        {
            System.debug(loggingLevel.ERROR,'**projectId:' + projectId);
            ////FPO Start
            PM_Project__c project = [SELECT Id, Name, Sales_Order__c, Sales_Order__r.System_Design_Quote__r.System_Design__r.Number_of_Arrays__c
                                    , Sales_Order__r.Property__r.Hours_From_Nearest_Office__c
                                    FROM PM_Project__c 
                                    WHERE Id = :projectId];
            
            //Create Rootstock objects1
            amr.processPMProject1(project, null);// FPO Sprint 6 //amr.processPMProject1(project);

            //Check if Install proj exists. Create one if it doesn't exist
            List<Install_Project__c> instlProjs = new List<Install_Project__c>();
            instlProjs = [SELECT Id FROM Install_Project__c WHERE PM_Project__c =:projectId];

            if(instlProjs.isEmpty()){
                //Create install proj
                Install_Project__c ip = new Install_Project__c();
                ip.Name = project.Name;
                ip.PM_Project__c = project.Id;
                ip.Sales_Order__c = project.Sales_Order__c;
                ip.Number_of_Roofs__c = project.Sales_Order__r.System_Design_Quote__r.System_Design__r.Number_of_Arrays__c;
                ip.Standard_Project__c = true;

                ip.Electrician_Drive_Time_To_Site__c = project.Sales_Order__r.Property__r.Hours_From_Nearest_Office__c;
                ip.Drive_Time_Office_To_Site__c = project.Sales_Order__r.Property__r.Hours_From_Nearest_Office__c;
                insert ip;
            }

            //calculate cost projections
            CostProjectionProcessor.updateRtskCstProjections(project.Sales_Order__c);
            ////FPO End

            return new PageReference('/' + projectId );
        }
        else
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A Rootstock Sales Order already exists for this Sales Order.'));
            return null;
        }    
    }
    
    /*
    //find the first day of week after the requested date
    private Date nextWeekday(Date dt) {
        Date startOfWeek = dt.toStartOfWeek();
        Integer days = startOfWeek.daysBetween(dt);
        if (days == 0) { //Sunday
            return dt.addDays(1);
        } 
        if (days == 6) { //Saturday
            return dt.addDays(2);
        }
        return dt; 
        */

}