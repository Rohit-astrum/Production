/* FILE: AstrumDailyReportTests.cls
 * AUTHOR: Rohit Jain
 * DATE: August 21, 2014
 * PURPOSE: Class to get the daily/monthly/yearly count for daily Report
 * MOD: 6/3/2015 - Change last three methods to a future call so to avoid governor limits
 */
global  class AstrumDailyReportProcessor  implements Schedulable{

    global void execute(SchedulableContext SC) {
      processReport(); 
    }

    public AstrumDailyReportProcessor() {
        
    }

    Public void processReport()
    {   
        
        Integer startDay = 16;
        Integer startMonth;
        Integer startYear;
        Integer monthStartYear;
        Integer endDay = 15;
        Integer endMonth;
        Integer endMYear;
        Integer monthEndYear;

        Date today = System.today();
        Datetime backlogDate = Datetime.newInstance(2014, 7 , 29);
        Date yearStart = Date.newInstance(2014, 1 , 1);

        Integer currDay = today.day()-1;
        Integer currMMonth = today.month();
        Integer currYear = today.year();

        if(currDay > 15)
        {
            startMonth = currMMonth;   
           
            if(currMMonth == 12)
            {
                startYear = currYear; 
                monthStartYear = currYear;
                monthEndYear = currYear + 1;
                endMYear = currYear + 1;  
                endMonth   = 1;   
            }              
            else
            {
                startYear = currYear-1;                  
                endMYear = currYear;   
                endMonth   = currMMonth + 1;   
                monthStartYear = currYear;
                monthEndYear = currYear;
            }
        }
        else
        {
            
            endMonth   = currMMonth;  

            if(currMMonth == 1)
            {
               startMonth = 12;   
                monthStartYear = currYear-1;
                monthEndYear = currYear ;
            }              
            else
            {               
                startMonth   = currMMonth - 1;   
                monthStartYear = currYear;
                monthEndYear = currYear ;
            }


            startYear = currYear - 1 ; 
            endMYear = currYear; 
        }

        
        Datetime monthEndDate = Datetime.newInstance(monthEndYear, endMonth, endDay);

        
        Datetime yearStartDate ;
        Datetime monthStartDate;
        if(today < Datetime.newInstance(2014, 12, 16))
        {
            yearStartDate = backlogDate;    
        }
        else
        {
            yearStartDate = Datetime.newInstance(startYear, 12 , startDay);   
        }    
        if(today < Datetime.newInstance(2014, 09, 16))
        {
            monthStartDate = backlogDate;    
        }
        else
        {
            monthStartDate = Datetime.newInstance(monthStartYear, startMonth, startDay);
        }    
        Datetime yearEndDate = Datetime.newInstance(endMYear, 12, endDay);
        System.debug(monthStartDate);
        System.debug(monthEndDate);
        System.debug(yearStartDate);
        System.debug(yearEndDate);

        
        Astrum_Daily_Report__c adrgoals = [Select id,daily_Goal_Leads_Num__c,monthly_Goal_Leads_Num__c,yearly_Goal_Leads_Num__c
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
                    ,daily_Stretch_Goal_Avg_Time_to_Sales__c,month_Stretch_Goal_Avg_Time_to_Sales__c,Year_Stretch_Goal_Avg_Time_to_Sales__c
                    ,daily_Stretch_Goal_Avg_Time_to_Ins__c,month_Stretch_Goal_Avg_Time_to_Ins__c,year_Stretch_Goal_Avg_Time_to_Ins__c
                 From Astrum_Daily_Report__c 
                Where RecordType.DeveloperName = 'Goal' limit 1];

        Astrum_Daily_Report__c adr = new Astrum_Daily_Report__c();
        adr.RecordTypeid = [select id from RecordType where sObjectType = 'Astrum_Daily_Report__c' and DeveloperName = 'Actual'].id;

        adr.month_start_date__c = monthStartDate.date();
        adr.month_end_Date__c = monthEndDate.date();
        adr.year_start_date__c = yearStartDate.date();
        adr.year_end_date__c = yearEndDate.date();
        
        adr.daily_Goal_Leads_Num__c = adrgoals.daily_Goal_Leads_Num__c;
        adr.monthly_Goal_Leads_Num__c = adrgoals.monthly_Goal_Leads_Num__c;
        adr.yearly_Goal_Leads_Num__c = adrgoals.yearly_Goal_Leads_Num__c;

        adr.daily_Goal_Oppty_Num__c = adrgoals.daily_Goal_oppty_Num__c;
        adr.monthly_Goal_Oppty_Num__c = adrgoals.monthly_Goal_Oppty_Num__c;
        adr.yearly_Goal_Oppty_Num__c = adrgoals.yearly_Goal_Oppty_Num__c;
        
        adr.daily_Goal_Sales_Num__c = adrgoals.daily_Goal_Sales_Num__c;
        adr.monthly_Goal_Sales_Num__c = adrgoals.monthly_Goal_Sales_Num__c;
        adr.yearly_Goal_Sales_Num__c = adrgoals.yearly_Goal_Sales_Num__c;
        
        adr.daily_Goal_cancel_Num__c = adrgoals.daily_Goal_cancel_Num__c;
        adr.monthly_Goal_cancel_Num__c = adrgoals.monthly_Goal_cancel_Num__c;
        adr.yearly_Goal_cancel_Num__c = adrgoals.yearly_Goal_cancel_Num__c;

        adr.daily_Goal_inspection_Num__c = adrgoals.daily_Goal_inspection_Num__c;
        adr.monthly_Goal_inspection_Num__c = adrgoals.monthly_Goal_inspection_Num__c;
        adr.yearly_Goal_inspection_Num__c = adrgoals.yearly_Goal_inspection_Num__c;

        adr.daily_Goal_Sales_kw_Num__c = adrgoals.daily_Goal_Sales_kw_Num__c;
        adr.monthly_Goal_Sales_kw_Num__c = adrgoals.monthly_Goal_Sales_kw_Num__c;
        adr.yearly_Goal_Sales_kw_Num__c = adrgoals.yearly_Goal_Sales_kw_Num__c;
        
        adr.daily_Goal_cancel_kw_Num__c = adrgoals.daily_Goal_cancel_kw_Num__c;
        adr.monthly_Goal_cancel_kw_Num__c = adrgoals.monthly_Goal_cancel_kw_Num__c;
        adr.yearly_Goal_cancel_kw_Num__c = adrgoals.yearly_Goal_cancel_kw_Num__c;

        adr.daily_Goal_inspection_kw_Num__c = adrgoals.daily_Goal_inspection_kw_Num__c;
        adr.monthly_Goal_inspection_kw_Num__c = adrgoals.monthly_Goal_inspection_kw_Num__c;
        adr.yearly_Goal_inspection_kw_Num__c = adrgoals.yearly_Goal_inspection_kw_Num__c;

        adr.daily_Goal_Avg_Time_Opty_to_Sales_Visit__c = adrgoals.daily_Goal_Avg_Time_Opty_to_Sales_Visit__c;
        adr.month_Goal_Avg_Time_Opty_to_Sales_Visit__c = adrgoals.month_Goal_Avg_Time_Opty_to_Sales_Visit__c;
        adr.yearly_Goal_Avg_Time_Opty_to_Sales_Visit__c = adrgoals.yearly_Goal_Avg_Time_Opty_to_Sales_Visit__c;

        adr.daily_Goal_Avg_Time_Sales_to_Inspection__c = adrgoals.daily_Goal_Avg_Time_Sales_to_Inspection__c;
        adr.month_Goal_Avg_Time_Sales_to_Inspection__c = adrgoals.month_Goal_Avg_Time_Sales_to_Inspection__c;
        adr.yearly_Goal_Avg_Time_Sales_to_Inspection__c = adrgoals.yearly_Goal_Avg_Time_Sales_to_Inspection__c;

        //Stretch Goals
        adr.daily_Stretch_Goal_Leads_Num__c = adrgoals.daily_Stretch_Goal_Leads_Num__c;
        adr.monthly_Stretch_Goal_Leads_Num__c = adrgoals.monthly_Stretch_Goal_Leads_Num__c;
        adr.yearly_Stretch_Goal_Leads_Num__c = adrgoals.yearly_Stretch_Goal_Leads_Num__c;
        adr.daily_Stretch_Goal_Oppty_Num__c = adrgoals.daily_Stretch_Goal_Oppty_Num__c;
        adr.monthly_Stretch_Goal_Oppty_Num__c = adrgoals.monthly_Stretch_Goal_Oppty_Num__c;
        adr.yearly_Stretch_Goal_Oppty_Num__c = adrgoals.yearly_Stretch_Goal_Oppty_Num__c;
        adr.daily_Stretch_Goal_Sales_Num__c = adrgoals.daily_Stretch_Goal_Sales_Num__c;
        adr.monthly_Stretch_Goal_Sales_Num__c = adrgoals.monthly_Stretch_Goal_Sales_Num__c;
        adr.yearly_Stretch_Goal_Sales_Num__c = adrgoals.yearly_Stretch_Goal_Sales_Num__c;
        adr.daily_Stretch_Goal_cancel_Num__c = adrgoals.daily_Stretch_Goal_cancel_Num__c;
        adr.monthly_Stretch_Goal_cancel_Num__c = adrgoals.monthly_Stretch_Goal_cancel_Num__c;
        adr.yearly_Stretch_Goal_cancel_Num__c = adrgoals.yearly_Stretch_Goal_cancel_Num__c; 
        adr.daily_Stretch_Goal_inspection_Num__c = adrgoals.daily_Stretch_Goal_inspection_Num__c;
        adr.monthly_Stretch_Goal_inspection_Num__c = adrgoals.monthly_Stretch_Goal_inspection_Num__c;
        adr.yearly_Stretch_Goal_inspection_Num__c = adrgoals.yearly_Stretch_Goal_inspection_Num__c;
        adr.daily_Stretch_Goal_Sales_kw_Num__c = adrgoals.daily_Stretch_Goal_Sales_kw_Num__c;
        adr.monthly_Stretch_Goal_Sales_kw_Num__c = adrgoals.monthly_Stretch_Goal_Sales_kw_Num__c;
        adr.yearly_Stretch_Goal_Sales_kw_Num__c = adrgoals.yearly_Stretch_Goal_Sales_kw_Num__c; 
        adr.daily_Stretch_Goal_cancel_kw_Num__c = adrgoals.daily_Stretch_Goal_cancel_kw_Num__c;
        adr.monthly_Stretch_Goal_cancel_kw_Num__c = adrgoals.monthly_Stretch_Goal_cancel_kw_Num__c;
        adr.yearly_Stretch_Goal_cancel_kw_Num__c = adrgoals.yearly_Stretch_Goal_cancel_kw_Num__c; 
        adr.daily_Stretch_Goal_inspection_kw_Num__c = adrgoals.daily_Stretch_Goal_inspection_kw_Num__c;
        adr.monthly_Stretch_Goal_inspection_kw_Num__c = adrgoals.monthly_Stretch_Goal_inspection_kw_Num__c;
        adr.yearly_Stretch_Goal_inspection_kw_Num__c = adrgoals.yearly_Stretch_Goal_inspection_kw_Num__c;
        adr.daily_Stretch_Goal_Avg_Time_to_Sales__c = adrgoals.daily_Stretch_Goal_Avg_Time_to_Sales__c;
        adr.month_Stretch_Goal_Avg_Time_to_Sales__c = adrgoals.month_Stretch_Goal_Avg_Time_to_Sales__c;
        adr.year_Stretch_Goal_Avg_Time_to_Sales__c = adrgoals.year_Stretch_Goal_Avg_Time_to_Sales__c;
        adr.daily_Stretch_Goal_Avg_Time_to_Ins__c = adrgoals.daily_Stretch_Goal_Avg_Time_to_Ins__c;
        adr.month_Stretch_Goal_Avg_Time_to_Ins__c = adrgoals.month_Stretch_Goal_Avg_Time_to_Ins__c;
        adr.year_Stretch_Goal_Avg_Time_to_Ins__c = adrgoals.year_Stretch_Goal_Avg_Time_to_Ins__c;
        
        

        /********************************************************************************/
        // Get Daily Opps Number
        /*
        AggregateResult[] dailyOpps = [SELECT count(id) total
                                        FROM Opportunity
                                        WHERE CreatedDate = YESTERDAY];            
        
        for (AggregateResult ar : dailyOpps)  {             
            adr.daily_actual_oppty_num__c = (Integer)ar.get('total');            
        }

        // Get MOnthly Opps Number
        AggregateResult[] monthlyOpps = [SELECT count(id) total
                                        FROM Opportunity
                                        WHERE CreatedDate >= :monthStartDate  AND CreatedDate < TODAY];            
        
        for (AggregateResult ar : monthlyOpps)  {             
            adr.monthly_actual_oppty_num__c = (Integer)ar.get('total');            
        }

        // Get Yearly Opps Number
        AggregateResult[] yearlyOpps = [SELECT count(id) total
                                        FROM Opportunity
                                        WHERE CreatedDate >= :yearStartDate AND CreatedDate < TODAY];            
        
        for (AggregateResult ar : yearlyOpps)  {             
            adr.yearly_actual_oppty_num__c = (Integer)ar.get('total');            
        }
        */

        /********************************************************************************/
        // Get Daily Sales Number
        AggregateResult[] dailySales = [SELECT count(id) total , sum(System_Size_kW__c) totalsize
                                        FROM SCRB_SalesOrder__c
                                        WHERE Time_Original_Submit_Sales_Rep__c = YESTERDAY];            
        
        for (AggregateResult ar : dailySales)  {             
            adr.daily_actual_sales_num__c = (Integer)ar.get('total');
            adr.daily_actual_sales_kw_num__c = (Decimal)ar.get('totalsize') != null ? ((Decimal)ar.get('totalsize')).round() : 0 ;            
        }

        // Get MOnthly Sales Number
        AggregateResult[] monthlySales = [SELECT count(id) total , sum(System_Size_kW__c) totalsize
                                        FROM SCRB_SalesOrder__c
                                        WHERE Time_Original_Submit_Sales_Rep__c >= :monthStartDate AND Time_Original_Submit_Sales_Rep__c < TODAY];            
        
        for (AggregateResult ar : monthlySales)  {             
            adr.monthly_actual_sales_num__c = (Integer)ar.get('total');
            adr.monthly_actual_sales_kw_num__c = (Decimal)ar.get('totalsize') != null ? ((Decimal)ar.get('totalsize')).round() : 0;             
        }

        // Get Yearly Sales Number
        AggregateResult[] yearlySales = [SELECT count(id) total , sum(System_Size_kW__c) totalsize
                                        FROM SCRB_SalesOrder__c
                                        WHERE Time_Original_Submit_Sales_Rep__c >= :yearStartDate AND Time_Original_Submit_Sales_Rep__c < TODAY];            
        
        for (AggregateResult ar : yearlySales)  {             
            adr.yearly_actual_sales_num__c = (Integer)ar.get('total');  
            adr.yearly_actual_sales_kw_num__c = (Decimal)ar.get('totalsize') != null ? ((Decimal)ar.get('totalsize')).round() : 0;           
        }

        /********************************************************************************/
        // Get Daily cancel Number
        AggregateResult[] dailyCancelSales = [SELECT count(id) total , sum(System_Size_kW__c) totalsize
                                        FROM SCRB_SalesOrder__c
                                        WHERE StatusCode__c = 'Canceled' AND Canceled_Date__c = YESTERDAY ];            
        
        for (AggregateResult ar : dailyCancelSales)  {             
            adr.daily_actual_cancel_num__c = (Integer)ar.get('total');
            adr.daily_actual_cancel_kw_num__c = (Decimal)ar.get('totalsize') != null ? ((Decimal)ar.get('totalsize')).round() : 0;             
        }

        // Get MOnthly cancel Number
        AggregateResult[] monthlyCancelSales = [SELECT count(id) total , sum(System_Size_kW__c) totalsize
                                        FROM SCRB_SalesOrder__c
                                        WHERE StatusCode__c = 'Canceled' AND Canceled_Date__c >= :monthStartDate  AND Canceled_Date__c < TODAY];            
        
        for (AggregateResult ar : monthlyCancelSales)  {             
            adr.monthly_actual_cancel_num__c = (Integer)ar.get('total');  
            adr.monthly_actual_cancel_kw_num__c = (Decimal)ar.get('totalsize') != null ? ((Decimal)ar.get('totalsize')).round() : 0;          
        }

        // Get Yearly cancel Number
        AggregateResult[] yearlyCancelSales = [SELECT count(id) total , sum(System_Size_kW__c) totalsize
                                        FROM SCRB_SalesOrder__c
                                        WHERE StatusCode__c = 'Canceled' AND Canceled_Date__c >= :yearStartDate  AND Canceled_Date__c < TODAY];            
        
        for (AggregateResult ar : yearlyCancelSales)  {             
            adr.yearly_actual_cancel_num__c = (Integer)ar.get('total');   
            adr.yearly_actual_cancel_kw_num__c = (Decimal)ar.get('totalsize') != null ? ((Decimal)ar.get('totalsize')).round() : 0;         
        }

         /********************************************************************************/
        // Get Daily Inspection Number
        AggregateResult[] dailyInsp = [SELECT count(id) total, sum(Total_System_Size_kW_DC__c) totalsize
                                        FROM PM_Project__c
                                        WHERE Proof_Of_Inspection__c = YESTERDAY ];            
        
        for (AggregateResult ar : dailyInsp)  {             
            adr.daily_actual_inspection_num__c = (Integer)ar.get('total');
            adr.daily_actual_inspection_kw_num__c = (Decimal)ar.get('totalsize') != null ? ((Decimal)ar.get('totalsize')).round() : 0;            
        }

        // Get MOnthly Inspection Number
        AggregateResult[] monthlyInsp = [SELECT count(id) total , sum(Total_System_Size_kW_DC__c) totalsize
                                        FROM PM_Project__c
                                        WHERE Proof_Of_Inspection__c >= :monthStartDate.date()  AND Proof_Of_Inspection__c < TODAY];            
        
        for (AggregateResult ar : monthlyInsp)  {             
            adr.monthly_actual_inspection_num__c = (Integer)ar.get('total');   
            adr.monthly_actual_inspection_kw_num__c = (Decimal)ar.get('totalsize') != null ? ((Decimal)ar.get('totalsize')).round() : 0;       
        }

        // Get Yearly Inspection Number
        AggregateResult[] yearlyInsp = [SELECT count(id) total , sum(Total_System_Size_kW_DC__c) totalsize
                                        FROM PM_Project__c 
                                        WHERE Proof_Of_Inspection__c >= :yearStartDate.date()  AND Proof_Of_Inspection__c < TODAY];            
        
        for (AggregateResult ar : yearlyInsp)  {             
            adr.yearly_actual_inspection_num__c = (Integer)ar.get('total');    
            adr.yearly_actual_inspection_kw_num__c = (Decimal)ar.get('totalsize') != null ? ((Decimal)ar.get('totalsize')).round() : 0;       
        }

        /******************************************************/
        /********************************************************************************/
        // Get Average Time: Oppotunity Created to First Sales Visit

        /*
        // Get the Map of Events created Yesterday
        List<Event> yesterdaySalesVisits = [Select WhatId,StartDateTime from Event 
                                             Where Record_Type_Name__c IN ('Sales Visit Onsite', 'Sales Visit Remote') 
                                               AND isChild = false 
                                               AND What.Type = 'Opportunity'
                                               AND StartDateTime = YESTERDAY];
        Set<Id> oppId = new Set<Id>();
        for(Event evt : yesterdaySalesVisits )
        {
            oppId.add(evt.WhatId);
        }


        // Get the Map of Evetns created MOnthly
        List<Event> monthSalesVisits = [Select WhatId,StartDateTime from Event 
                                             Where Record_Type_Name__c IN ('Sales Visit Onsite', 'Sales Visit Remote') 
                                               AND isChild = false 
                                               AND What.Type = 'Opportunity'
                                               AND StartDateTime >= :monthStartDate.date()  AND StartDateTime < TODAY];        
        for(Event evt : monthSalesVisits )
        {
            oppId.add(evt.WhatId);
        }

        // Get the Map of Evetns created YTD
        List<Event> yearSalesVisits = [Select WhatId,StartDateTime from Event 
                                             Where Record_Type_Name__c IN ('Sales Visit Onsite', 'Sales Visit Remote') 
                                               AND isChild = false 
                                               AND What.Type = 'Opportunity'
                                               AND StartDateTime >= :yearStartDate.date()  AND StartDateTime < TODAY];        
        for(Event evt : yearSalesVisits )
        {
            oppId.add(evt.WhatId);
        }

        Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>([Select id,CreatedDate from Opportunity where id in :oppId]);

        List<Decimal> timeDiff = new List<Decimal>();
        for(Event evt : yesterdaySalesVisits )
        {            
            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
                     - (opptyMap.get(evt.WhatId).CreatedDate.getTime()/1000/60/60));
        }        
        adr.Daily_Avg_Time_Opty_to_Sales_Visit__c = getMedianStatic(timeDiff);

        timeDiff = new List<Decimal>();
        for(Event evt : monthSalesVisits )
        {
            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
                     - (opptyMap.get(evt.WhatId).CreatedDate.getTime()/1000/60/60));
        }        
        adr.Monthly_Avg_Time_Opty_to_Sales_Visit__c = getMedianStatic(timeDiff);

        timeDiff = new List<Decimal>();
        for(Event evt : yearSalesVisits )
        {
            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
                     - (opptyMap.get(evt.WhatId).CreatedDate.getTime()/1000/60/60));
        }        
        adr.Yearly_Avg_Time_Opty_to_Sales_Visit__c = getMedianStatic(timeDiff);
        */

        /********************************************************************************/
        // Get Average Time: Sales to Inspection


        List<PM_Project__c> yesterdayInspections = [Select Proof_Of_Inspection__c,Sales_Order__r.Time_Original_Submit_Sales_Rep__c,Sales_Order__r.CreatedDate
                                                     FROM PM_Project__c
                                                    WHERE Proof_Of_Inspection__c = YESTERDAY];
       
        List<Decimal> timeDiff = new List<Decimal>();
        for(PM_Project__c project : yesterdayInspections )
        {            
            if(project.Sales_Order__r.Time_Original_Submit_Sales_Rep__c == null)
            {
                project.Sales_Order__r.Time_Original_Submit_Sales_Rep__c = project.Sales_Order__r.CreatedDate;
            }
            timeDiff.add(((Datetime.newInstance(project.Proof_Of_Inspection__c, Time.newInstance(0,0,0,0))).getTime()/1000/60/60)
                     - (project.Sales_Order__r.Time_Original_Submit_Sales_Rep__c.getTime()/1000/60/60));
        }        
        adr.Daily_Avg_Time_Sales_to_Inspection__c = getMedianStatic(timeDiff);

        List<PM_Project__c> monthInspections = [Select Proof_Of_Inspection__c,Sales_Order__r.Time_Original_Submit_Sales_Rep__c,Sales_Order__r.CreatedDate
                                                     FROM PM_Project__c
                                                    WHERE Proof_Of_Inspection__c >= :monthStartDate.date()  AND Proof_Of_Inspection__c < TODAY];
       
        timeDiff = new List<Decimal>();
        for(PM_Project__c project : monthInspections )
        {            
            if(project.Sales_Order__r.Time_Original_Submit_Sales_Rep__c == null)
            {
                project.Sales_Order__r.Time_Original_Submit_Sales_Rep__c = project.Sales_Order__r.CreatedDate;
            }
            timeDiff.add(((Datetime.newInstance(project.Proof_Of_Inspection__c, Time.newInstance(0,0,0,0))).getTime()/1000/60/60)
                     - (project.Sales_Order__r.Time_Original_Submit_Sales_Rep__c.getTime()/1000/60/60));
        }        
        adr.Monthly_Avg_Time_Sales_to_Inspection__c = getMedianStatic(timeDiff);


        List<PM_Project__c> yearInspections = [Select Proof_Of_Inspection__c,Sales_Order__r.Time_Original_Submit_Sales_Rep__c,Sales_Order__r.CreatedDate
                                                     FROM PM_Project__c
                                                    WHERE Proof_Of_Inspection__c >= :yearStartDate.date()  AND Proof_Of_Inspection__c < TODAY];
       
        timeDiff = new List<Decimal>();
        for(PM_Project__c project : yearInspections )
        {            
            if(project.Sales_Order__r.Time_Original_Submit_Sales_Rep__c == null)
            {
                project.Sales_Order__r.Time_Original_Submit_Sales_Rep__c = project.Sales_Order__r.CreatedDate;
            }
            timeDiff.add(((Datetime.newInstance(project.Proof_Of_Inspection__c, Time.newInstance(0,0,0,0))).getTime()/1000/60/60)
                     - (project.Sales_Order__r.Time_Original_Submit_Sales_Rep__c.getTime()/1000/60/60));
        }        
        adr.Yearly_Avg_Time_Sales_to_Inspection__c = getMedianStatic(timeDiff);

        /********************************************************************************/

        // Get Current Backlog Number from PM Project
        AggregateResult[] currentBackLog = [SELECT sum(Total_System_Size_kW_DC__c) totalsize
                                        FROM PM_Project__c
                                        WHERE  Sales_Order__r.StatusCode__c NOT IN ('Submit Pending','Canceled')
                                          AND Status__c != 'Cancelled' 
                                          And Proof_of_Inspection__c = null];            
        
        for (AggregateResult ar : currentBackLog)  {                         
            adr.current_backlog_kw__c = (Decimal)ar.get('totalsize') != null ? ((Decimal)ar.get('totalsize')).round() : 0;            
        }

        // Get Current Backlog Number from Sales Orders for which there is no PM PRoject
        AggregateResult[] currentSOBackLog = [SELECT SUM(System_Size_kW__c)  totalsize
                                             FROM SCRB_SalesOrder__c 
                                            WHERE  StatusCode__c NOT IN ('Submit Pending', 'Canceled')                                        
                                          AND Id NOT IN (SELECT Sales_Order__c from PM_Project__c)                                          
                                          AND Id NOT IN (SELECT Sales_Order__c from Milestone1_Project__c)
                                          AND Opportunity_Close_Date_Lookup__c >= :yearStart];            
        
        for (AggregateResult ar : currentSOBackLog)  {  
            Decimal sobacklog =       (Decimal)ar.get('totalsize') != null ? ((Decimal)ar.get('totalsize')).round() : 0;                  
            adr.current_backlog_kw__c = adr.current_backlog_kw__c +  sobacklog;          
        }

        insert adr;

        DailyLeadCounts(adr.Id);
        MonthlyLeadCounts(adr.Id, monthStartDate);

        Integer day = Date.today().day();
        Integer month = Date.today().month();
        Integer year = Date.today().year();
        if(month == 12 && day > 15) {
            year++;
        }

        if(month < 6 || (month == 12 && day > 15) || (month == 6 && day < 16)){
            YearlyLeadCounts(adr.Id, yearStartDate, Date.today(), true);
        } else {
            YearlyLeadCounts(adr.Id, yearStartDate, Date.parse('6/16/' + String.valueOf(year)), true);
            YearlyLeadCounts(adr.Id, Date.parse('6/16/' + String.valueOf(year)), Date.today(), false);
        }

        OpportunityCounts(adr.Id, monthStartDate, yearStartDate);
        EventAverageTimes(adr.Id, monthStartDate, yearStartDate);
    }

    @future
    private static void DailyLeadCounts(Id adrId){
        Astrum_Daily_Report__c adr = new Astrum_Daily_Report__c();
        adr.Id = adrId;

        /********************************************************************************/
        // Get Daily Leads Number
        Set<String> leadStatuses = LeadStatusPicklistValues();
        AggregateResult[] dailyLeads = [SELECT count(id) total
                                        FROM Lead
                                        WHERE CreatedDate = YESTERDAY AND Status IN :leadStatuses];
        
        for (AggregateResult ar : dailyLeads) {
            adr.daily_actual_leads_num__c = (Integer)ar.get('total');
        }

        update adr;
    }

    @future
    private static void MonthlyLeadCounts(Id adrId, Datetime monthStartDate){
        Astrum_Daily_Report__c adr = new Astrum_Daily_Report__c();
        adr.Id = adrId;

        /********************************************************************************/
        // Get MOnthly Leads Number
        Set<String> leadStatuses = LeadStatusPicklistValues();
        AggregateResult[] monthlyLeads = [SELECT count(id) total
                                        FROM Lead
                                        WHERE CreatedDate >= :monthStartDate  AND CreatedDate < TODAY AND Status IN :leadStatuses];
        
        for (AggregateResult ar : monthlyLeads) {
            adr.monthly_actual_leads_num__c = (Integer)ar.get('total');
        }

        update adr;
    }

    @future
    private static void YearlyLeadCounts(Id adrId, Datetime yearStartDate, Datetime yearEndDate, Boolean firstHalf){
        Astrum_Daily_Report__c adr = new Astrum_Daily_Report__c();
        adr.Id = adrId;

        /********************************************************************************/
        // Get Yearly Leads Number
        Set<String> leadStatuses = LeadStatusPicklistValues();
        AggregateResult[] yearlyLeads = [SELECT count(id) total
                                        FROM Lead
                                        WHERE CreatedDate >= :yearStartDate AND CreatedDate < :yearEndDate AND Status IN :leadStatuses];

        for (AggregateResult ar : yearlyLeads) {
            if(firstHalf){
                adr.Yearly_Actual_Leads_Num_1H__c = (Integer)ar.get('total');
            } else {
                adr.Yearly_Actual_Leads_Num_2H__c = (Integer)ar.get('total');
            }
        }
        
        update adr;
    }

    @future
    private static void OpportunityCounts(Id adrId, Datetime monthStartDate, Datetime yearStartDate){
        Astrum_Daily_Report__c adr = new Astrum_Daily_Report__c();
        adr.Id = adrId;

        AggregateResult[] dailyOpps = [SELECT count(id) total
                                        FROM Opportunity
                                        WHERE CreatedDate = YESTERDAY];            
        
        for (AggregateResult ar : dailyOpps)  {             
            adr.daily_actual_oppty_num__c = (Integer)ar.get('total');            
        }

        // Get MOnthly Opps Number
        AggregateResult[] monthlyOpps = [SELECT count(id) total
                                        FROM Opportunity
                                        WHERE CreatedDate >= :monthStartDate  AND CreatedDate < TODAY];            
        
        for (AggregateResult ar : monthlyOpps)  {             
            adr.monthly_actual_oppty_num__c = (Integer)ar.get('total');            
        }

        // Get Yearly Opps Number
        AggregateResult[] yearlyOpps = [SELECT count(id) total
                                        FROM Opportunity
                                        WHERE CreatedDate >= :yearStartDate AND CreatedDate < TODAY];            
        
        for (AggregateResult ar : yearlyOpps)  {             
            adr.yearly_actual_oppty_num__c = (Integer)ar.get('total');            
        }
        
        update adr;
    }

    @future
    private static void EventAverageTimes(Id adrId, Datetime monthStartDate, Datetime yearStartDate){
        Astrum_Daily_Report__c adr = new Astrum_Daily_Report__c();
        adr.Id = adrId;

        // Get the Map of Events created Yesterday
        List<Event> yesterdaySalesVisits = [Select WhatId,StartDateTime from Event 
                                             Where Record_Type_Name__c IN ('Sales Visit Onsite', 'Sales Visit Remote') 
                                               AND isChild = false 
                                               AND What.Type = 'Opportunity'
                                               AND StartDateTime = YESTERDAY];
        Set<Id> oppId = new Set<Id>();
        for(Event evt : yesterdaySalesVisits )
        {
            oppId.add(evt.WhatId);
        }


        // Get the Map of Evetns created MOnthly
        List<Event> monthSalesVisits = [Select WhatId,StartDateTime from Event 
                                             Where Record_Type_Name__c IN ('Sales Visit Onsite', 'Sales Visit Remote') 
                                               AND isChild = false 
                                               AND What.Type = 'Opportunity'
                                               AND StartDateTime >= :monthStartDate.date()  AND StartDateTime < TODAY];        
        for(Event evt : monthSalesVisits )
        {
            oppId.add(evt.WhatId);
        }

        // Get the Map of Evetns created YTD
        List<Event> yearSalesVisits = [Select WhatId,StartDateTime from Event 
                                             Where Record_Type_Name__c IN ('Sales Visit Onsite', 'Sales Visit Remote') 
                                               AND isChild = false 
                                               AND What.Type = 'Opportunity'
                                               AND StartDateTime >= :yearStartDate.date()  AND StartDateTime < TODAY];        
        for(Event evt : yearSalesVisits )
        {
            oppId.add(evt.WhatId);
        }

        Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>([Select id,CreatedDate from Opportunity where id in :oppId]);

        List<Decimal> timeDiff = new List<Decimal>();
        for(Event evt : yesterdaySalesVisits )
        {            
            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
                     - (opptyMap.get(evt.WhatId).CreatedDate.getTime()/1000/60/60));
        }        
        adr.Daily_Avg_Time_Opty_to_Sales_Visit__c = getMedianStatic(timeDiff);

        timeDiff = new List<Decimal>();
        for(Event evt : monthSalesVisits )
        {
            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
                     - (opptyMap.get(evt.WhatId).CreatedDate.getTime()/1000/60/60));
        }        
        adr.Monthly_Avg_Time_Opty_to_Sales_Visit__c = getMedianStatic(timeDiff);

        timeDiff = new List<Decimal>();
        for(Event evt : yearSalesVisits )
        {
            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
                     - (opptyMap.get(evt.WhatId).CreatedDate.getTime()/1000/60/60));
        }        
        adr.Yearly_Avg_Time_Opty_to_Sales_Visit__c = getMedianStatic(timeDiff);
        
        update adr;
    }

    private static Set<String> LeadStatusPicklistValues(){
        Set<String> picklistValues = new Set<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            if(!f.getValue().contains('Prospect')){
                picklistValues.add(f.getValue());
            }
        }
        return picklistValues;
    }

    Public Decimal getMedian(List<Decimal> timeDiff)
    {
        Integer sizeOfList = timeDiff.size();
        Decimal median = 0;
        if(sizeOfList == 0)
        {
            return median;
        }
        system.debug('size of list is '+ sizeOfList);
        Integer index = sizeOfList - 1;
        system.debug('the index is '+index);
        

        // sort the list first
        timeDiff.sort();

        //Calculate median
        if (Math.mod(sizeOfList, 2) == 0) {
           median = (timeDiff[(index-1)/2] + timeDiff[(index/2)+1])/2;
        }else{
           median = timeDiff[(index+1)/2];
        }

        if(median > 0)
        {
            median = (median/24).round();
        }

        return median;

         
    }

    public static Decimal getMedianStatic(List<Decimal> timeDiff)
    {
        Integer sizeOfList = timeDiff.size();
        Decimal median = 0;
        if(sizeOfList == 0)
        {
            return median;
        }
        system.debug('size of list is '+ sizeOfList);
        Integer index = sizeOfList - 1;
        system.debug('the index is '+index);
        

        // sort the list first
        timeDiff.sort();

        //Calculate median
        if (Math.mod(sizeOfList, 2) == 0) {
           median = (timeDiff[(index-1)/2] + timeDiff[(index/2)+1])/2;
        }else{
           median = timeDiff[(index+1)/2];
        }

        if(median > 0)
        {
            median = (median/24).round();
        }

        return median;

         
    }
    
    
}