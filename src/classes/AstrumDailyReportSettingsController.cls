/* FILE: AstrumDailyReportSettingsController.page
 * AUTHOR: Rohit Jain
 * DATE: Aug 18, 2013
 * PURPOSE: Edit page for Astrum daily Report Goals
 * MODIFICATION HISTORY 
 */
public class AstrumDailyReportSettingsController {    
   public boolean isEdit {get; set;}
   public Astrum_Daily_Report__c adr {get; set;}

   public AstrumDailyReportSettingsController() {
		adr = [Select id,daily_Goal_Leads_Num__c,monthly_Goal_Leads_Num__c,yearly_Goal_Leads_Num__c
					 ,daily_Goal_Oppty_Num__c,monthly_Goal_Oppty_Num__c,yearly_Goal_Oppty_Num__c
					 ,daily_Goal_Sales_Num__c,monthly_Goal_Sales_Num__c,yearly_Goal_Sales_Num__c 
					 ,daily_Goal_cancel_Num__c,monthly_Goal_cancel_Num__c,yearly_Goal_cancel_Num__c 
					 ,daily_Goal_inspection_Num__c,monthly_Goal_inspection_Num__c,yearly_Goal_inspection_Num__c 
					  ,daily_Goal_Sales_kw_Num__c,monthly_Goal_Sales_kw_Num__c,yearly_Goal_Sales_kw_Num__c 
					 ,daily_Goal_cancel_kw_Num__c,monthly_Goal_cancel_kw_Num__c,yearly_Goal_cancel_kw_Num__c 
					 ,daily_Goal_inspection_kw_Num__c,monthly_Goal_inspection_kw_Num__c,yearly_Goal_inspection_kw_Num__c 
                     ,daily_Goal_Avg_Time_Opty_to_Sales_Visit__c,month_Goal_Avg_Time_Opty_to_Sales_Visit__c,yearly_Goal_Avg_Time_Opty_to_Sales_Visit__c 
                     ,daily_Goal_Avg_Time_Sales_to_Inspection__c,month_Goal_Avg_Time_Sales_to_Inspection__c,yearly_Goal_Avg_Time_Sales_to_Inspection__c
                     ,daily_Stretch_Goal_Leads_Num__c,monthly_Stretch_Goal_Leads_Num__c,yearly_Stretch_Goal_Leads_Num__c
                    ,daily_Stretch_Goal_Oppty_Num__c,monthly_Stretch_Goal_Oppty_Num__c,yearly_Stretch_Goal_Oppty_Num__c
                    ,daily_Stretch_Goal_Sales_Num__c,monthly_Stretch_Goal_Sales_Num__c,yearly_Stretch_Goal_Sales_Num__c 
                    ,daily_Stretch_Goal_cancel_Num__c,monthly_Stretch_Goal_cancel_Num__c,yearly_Stretch_Goal_cancel_Num__c 
                    ,daily_Stretch_Goal_inspection_Num__c,monthly_Stretch_Goal_inspection_Num__c,yearly_Stretch_Goal_inspection_Num__c 
                    ,daily_Stretch_Goal_Sales_kw_Num__c,monthly_Stretch_Goal_Sales_kw_Num__c,yearly_Stretch_Goal_Sales_kw_Num__c 
                    ,daily_Stretch_Goal_cancel_kw_Num__c,monthly_Stretch_Goal_cancel_kw_Num__c,yearly_Stretch_Goal_cancel_kw_Num__c 
                    ,daily_Stretch_Goal_inspection_kw_Num__c,monthly_Stretch_Goal_inspection_kw_Num__c,yearly_Stretch_Goal_inspection_kw_Num__c
                    ,daily_Stretch_Goal_Avg_Time_to_Sales__c,month_Stretch_Goal_Avg_Time_to_Sales__c,year_Stretch_Goal_Avg_Time_to_Sales__c
                    ,daily_Stretch_Goal_Avg_Time_to_Ins__c,month_Stretch_Goal_Avg_Time_to_Ins__c,year_Stretch_Goal_Avg_Time_to_Ins__c
		         From Astrum_Daily_Report__c 
		        Where RecordType.DeveloperName = 'Goal' limit 1];

		isEdit = false;
	}
    

    public PageReference save()
    {
        update adr;
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