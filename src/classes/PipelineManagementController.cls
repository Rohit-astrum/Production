public with sharing class PipelineManagementController {
 /*
    public Boolean showSummary{get; set;}
    public Date startDate{get; set;}
    public Date endDate{get; set;}
    public String startDateT{get; set;}
    public String endDateT{get; set;}
    public Decimal probabilityValue{get; set;}
    public String probabilitySign{get; set;}
    public SummaryInfo  overallSummaryInfo {get; set;}
    
    public List<SummaryInfo>  MAownerSummaryInfo {get; set;}
    public List<SummaryInfo>  CTownerSummaryInfo {get; set;}
    public List<SummaryInfo>  CAownerSummaryInfo {get; set;}
    public List<SummaryInfo>  MDownerSummaryInfo {get; set;}
    public List<SummaryInfo>  NYownerSummaryInfo {get; set;}
    public List<SummaryInfo>  OHownerSummaryInfo {get; set;}
    public List<SummaryInfo>  PAownerSummaryInfo {get; set;}
    public List<SummaryInfo>  WYownerSummaryInfo {get; set;}
    
    public List<SummaryInfo>  ownerSummaryInfo {get; set;}
    
    public SummaryInfo  MASummaryInfo {get; set;}
    public SummaryInfo  CTSummaryInfo {get; set;}
    public SummaryInfo  CASummaryInfo {get; set;}
    public SummaryInfo  MDSummaryInfo {get; set;}
    public SummaryInfo  NYSummaryInfo {get; set;}
    public SummaryInfo  OHSummaryInfo {get; set;}
    public SummaryInfo  PASummaryInfo {get; set;}
    public SummaryInfo  WYSummaryInfo {get; set;}
    
    public List<SelectOption> probabilitySigns{
        get { 
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('', '-Select-'));
            result.add(new SelectOption('>', '>'));
            result.add(new SelectOption('<', '<')); 
            result.add(new SelectOption('>=', '>='));
            result.add(new SelectOption('<=', '<='));  
            result.add(new SelectOption('=', '='));           
            
            return result;         
        }
   }
 
   public PageReference refresh() {
        showSummary = true;
        startDate = Date.parse(startDateT);
        endDate= Date.parse(endDateT);
        System.debug('**Refereshed');
       // populateSummary();
        populateSalesRegionSummary();
        return null;
   }
   
   public PipelineManagementController()
   {
        showSummary = false;
        probabilityValue = 0;
        probabilitySign = '>';
        EndDateT = System.Today().format();
        StartDateT = (System.Today()-7).format();
   } 
   
   public void populateSummary() {
        System.debug('**populateSummary '+StartDate+' End - '+EndDate + ' - '+probabilitySign + ' - '+probabilityValue    );
        overallSummaryInfo = new SummaryInfo();        
       
        MASummaryInfo = new SummaryInfo();
        CTSummaryInfo = new SummaryInfo();
        CASummaryInfo = new SummaryInfo();
        MDSummaryInfo = new SummaryInfo();
        NYSummaryInfo = new SummaryInfo();
        OHSummaryInfo = new SummaryInfo();
        PASummaryInfo = new SummaryInfo();
        WYSummaryInfo = new SummaryInfo();
        
       
       
        //Closed Won
        AggregateResult[] overallClosedWon = 
          [SELECT Sales_Region__c ,COUNT(Id) won
             FROM Opportunity 
            WHERE StageName = 'Closed - Won'
              AND CloseDate >= :startDate
              and CloseDate <= :endDate
              GROUP BY Sales_Region__c];                
       
         
        for(AggregateResult ar : overallClosedWon)   
        {       
            overallSummaryInfo.ClosedWon = overallSummaryInfo.ClosedWon + (Integer)ar.get('won');              
            
            if(ar.get('Sales_Region__c') == 'MA Region')
            {
                MASummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'CT Region')
            {
                CTSummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'CA Region')
            {
                CASummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'MD Region')
            {
                MDSummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'NYC Region')
            {
                NYSummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'OH Region')
            {
                OHSummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'PA Region')
            {
                PASummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'WNY Region')
            {
                WYSummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
        }   
        
        //Closed Lost
        AggregateResult[] overallClosedLost = 
          [SELECT Sales_Region__c ,COUNT(Id) lost
             FROM Opportunity 
            WHERE StageName = 'Closed - Lost'
              AND CloseDate >= :StartDate
              and CloseDate <= :EndDate
              GROUP BY Sales_Region__c ];                
       
        for(AggregateResult ar : overallClosedLost)   
        {       
            overallSummaryInfo.ClosedLost = overallSummaryInfo.ClosedLost + (Integer)ar.get('lost');              
            
            if(ar.get('Sales_Region__c') == 'MA Region')
            {
                MASummaryInfo.ClosedLost  = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'CT Region')
            {
                CTSummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'CA Region')
            {
                CASummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'MD Region')
            {
                MDSummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'NYC Region')
            {
                NYSummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'OH Region')
            {
                OHSummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'PA Region')
            {
                PASummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'WNY Region')
            {
                WYSummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            
            
        }    
                   
        
        //Open Opptys
        
        String openQptyQuery = 'Select Sales_Region__c,o.CreatedDate '
                           +' ,(Select Id From Events Where isChild=false AND RecordType.Name IN (\'Site Survey Onsite\',\'Site Survey Remote\',\'Sales Visit Onsite\',\'Sales Visit Remote\') AND StartDateTime  >= :StartDate AND StartDateTime  <= :EndDate ) '
                           +' ,(Select Id from Tasks Where RecordType.Name = \'Inactivity Notice\' AND ActivityDate  >= :StartDate AND ActivityDate  <= :EndDate)  '
                           +' From Opportunity o '
                           +' WHERE StageName NOT IN ( \'Closed - Lost\', \'Closed - Won\', \'Contract Cancelled\') '
                           +' AND Probability ' + probabilitySign + ' :probabilityValue limit 10000';
                                 
        for(Opportunity opp : Database.query(openQptyQuery ))    
         {
             if((opp.CreatedDate >= StartDate && opp.CreatedDate <= EndDate ) || opp.events.size() > 0 || opp.tasks.size() > 0 )
             {
                    overallSummaryInfo.OpenOppty = overallSummaryInfo.OpenOppty + 1;      
                    if(opp.Sales_Region__c == 'MA Region')
                    {
                        MASummaryInfo.OpenOppty = MASummaryInfo.OpenOppty + 1;     
                    }
                    else if(opp.Sales_Region__c == 'CT Region')
                    {
                        CTSummaryInfo.OpenOppty  = CTSummaryInfo.OpenOppty + 1;      
                    }
                    else if(opp.Sales_Region__c == 'CA Region')
                    {
                        CASummaryInfo.OpenOppty  = CASummaryInfo.OpenOppty + 1;      
                    }
                    else if(opp.Sales_Region__c == 'MD Region')
                    {
                        MDSummaryInfo.OpenOppty  = MDSummaryInfo.OpenOppty + 1;      
                    }
                    else if(opp.Sales_Region__c == 'NYC Region')
                    {
                        NYSummaryInfo.OpenOppty = NYSummaryInfo.OpenOppty + 1;            
                    }
                    else if(opp.Sales_Region__c == 'OH Region')
                    {
                        OHSummaryInfo.OpenOppty = OHSummaryInfo.OpenOppty + 1;            
                    }
                    else if(opp.Sales_Region__c == 'PA Region')
                    {
                        PASummaryInfo.OpenOppty = PASummaryInfo.OpenOppty + 1;             
                    }
                    else if(opp.Sales_Region__c == 'WNY Region')
                    {
                        WYSummaryInfo.OpenOppty = WYSummaryInfo.OpenOppty + 1;           
                    }          
             }   
        } 
        
        // Visits and Site Surveys
        String siteSurveyQuery = 'Select Sales_Region__c,o.CreatedDate , o.Name '
                           +' ,(Select Id,Event_Status__c,RecordType.Name From Events Where isChild=false AND RecordType.Name IN (\'Site Survey Onsite\',\'Site Survey Remote\',\'Sales Visit Onsite\',\'Sales Visit Remote\') '
                           +' AND StartDateTime  >= :StartDate AND StartDateTime  <= :EndDate ) '                          
                           +' From Opportunity o '
                           +' WHERE (Probability '+probabilitySign + ' '+probabilityValue +' OR Category__c = \'Closed\') limit 10000';   
        for(Opportunity opp :Database.query(siteSurveyQuery ))    
         {
             if (opp.events.size() > 0)
             {
                 for(Event evt : opp.events)
                 {
                     if(evt.RecordType.Name == 'Site Survey Onsite' || evt.RecordType.Name == 'Site Survey Remote' )
                     {
                         System.debug('**Site**'+opp.Name);
                         overallSummaryInfo.SiteSurveys = overallSummaryInfo.SiteSurveys + 1; 
                         if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.SiteSurveys = MASummaryInfo.SiteSurveys + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.SiteSurveys = CTSummaryInfo.SiteSurveys + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.SiteSurveys = CASummaryInfo.SiteSurveys + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.SiteSurveys = MDSummaryInfo.SiteSurveys + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.SiteSurveys = NYSummaryInfo.SiteSurveys + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.SiteSurveys = OHSummaryInfo.SiteSurveys + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.SiteSurveys = PASummaryInfo.SiteSurveys + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.SiteSurveys = WYSummaryInfo.SiteSurveys + 1;           
                                }      
                     }   
                     else // Sales Visits
                     {
                         if(evt.Event_Status__c == 'Scheduled')
                         {
                              overallSummaryInfo.VisitsScheduled =  overallSummaryInfo.VisitsScheduled +1;    
                              if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsScheduled = MASummaryInfo.VisitsScheduled + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsScheduled = CTSummaryInfo.VisitsScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsScheduled = CASummaryInfo.VisitsScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsScheduled = MDSummaryInfo.VisitsScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsScheduled = NYSummaryInfo.VisitsScheduled + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsScheduled = OHSummaryInfo.VisitsScheduled + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsScheduled = PASummaryInfo.VisitsScheduled + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsScheduled = WYSummaryInfo.VisitsScheduled + 1;           
                                }          
                         }
                         else if(evt.Event_Status__c == 'Rescheduled')
                         {
                              overallSummaryInfo.VisitsReScheduled =  overallSummaryInfo.VisitsReScheduled +1;  
                              if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsReScheduled = MASummaryInfo.VisitsReScheduled + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsReScheduled  = CTSummaryInfo.VisitsReScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsReScheduled  = CASummaryInfo.VisitsReScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsReScheduled  = MDSummaryInfo.VisitsReScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsReScheduled = NYSummaryInfo.VisitsReScheduled + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsReScheduled  = OHSummaryInfo.VisitsReScheduled  + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsReScheduled = PASummaryInfo.VisitsReScheduled  + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsReScheduled = WYSummaryInfo.VisitsReScheduled  + 1;           
                                }     
                         }
                         else if(evt.Event_Status__c == 'Completed')
                         {
                              overallSummaryInfo.VisitsCompleted =  overallSummaryInfo.VisitsCompleted +1;   
                              
                              if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsCompleted = MASummaryInfo.VisitsCompleted + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsCompleted = CTSummaryInfo.VisitsCompleted + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsCompleted = CASummaryInfo.VisitsCompleted + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsCompleted = MDSummaryInfo.VisitsCompleted + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsCompleted = NYSummaryInfo.VisitsCompleted + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsCompleted = OHSummaryInfo.VisitsCompleted + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsCompleted  = PASummaryInfo.VisitsCompleted + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsCompleted  = WYSummaryInfo.VisitsCompleted   + 1;           
                                }      
                         }
                         else if(evt.Event_Status__c == 'Canceled by Customer')
                         {
                              overallSummaryInfo.VisitsCanceled =  overallSummaryInfo.VisitsCanceled +1;    
                              if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsCanceled = MASummaryInfo.VisitsCanceled + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsCanceled  = CTSummaryInfo.VisitsCanceled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsCanceled  = CASummaryInfo.VisitsCanceled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsCanceled  = MDSummaryInfo.VisitsCanceled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsCanceled = NYSummaryInfo.VisitsCanceled  + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsCanceled = OHSummaryInfo.VisitsCanceled + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsCanceled = PASummaryInfo.VisitsCanceled + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsCanceled   = WYSummaryInfo.VisitsCanceled + 1;           
                                }      
                         }
                         else if(evt.Event_Status__c == 'Disqualified')
                         {
                              overallSummaryInfo.VisitsDisqualified =  overallSummaryInfo.VisitsDisqualified +1;    
                               if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsDisqualified = MASummaryInfo.VisitsDisqualified + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsDisqualified = CTSummaryInfo.VisitsDisqualified + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsDisqualified = CASummaryInfo.VisitsDisqualified + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsDisqualified = MDSummaryInfo.VisitsDisqualified + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsDisqualified = NYSummaryInfo.VisitsDisqualified + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsDisqualified = OHSummaryInfo.VisitsDisqualified + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsDisqualified = PASummaryInfo.VisitsDisqualified + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsDisqualified = WYSummaryInfo.VisitsDisqualified + 1;           
                                }      
                         }
                         else if(evt.Event_Status__c == 'Disqualified-Approved')
                         {
                              overallSummaryInfo.VisitsDisqApproved =  overallSummaryInfo.VisitsDisqApproved +1;  
                              if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsDisqApproved = MASummaryInfo.VisitsDisqApproved + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsDisqApproved = CTSummaryInfo.VisitsDisqApproved + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsDisqApproved = CASummaryInfo.VisitsDisqApproved + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsDisqApproved = MDSummaryInfo.VisitsDisqApproved + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsDisqApproved = NYSummaryInfo.VisitsDisqApproved + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsDisqApproved = OHSummaryInfo.VisitsDisqApproved + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsDisqApproved  = PASummaryInfo.VisitsDisqApproved + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsDisqApproved  = WYSummaryInfo.VisitsDisqApproved  + 1;           
                                }        
                         }  
                         else if(evt.Event_Status__c == 'Missed')
                         {
                              overallSummaryInfo.VisitsMissed =  overallSummaryInfo.VisitsMissed +1;   
                               if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsMissed = MASummaryInfo.VisitsMissed + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsMissed = CTSummaryInfo.VisitsMissed + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsMissed = CASummaryInfo.VisitsMissed + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsMissed = MDSummaryInfo.VisitsMissed + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsMissed = NYSummaryInfo.VisitsMissed + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsMissed = OHSummaryInfo.VisitsMissed + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsMissed = PASummaryInfo.VisitsMissed + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsMissed = WYSummaryInfo.VisitsMissed + 1;           
                                }         
                         }   
                     
                     } 
                 }    
             }  
            
         } 
   }
   
   public void populateSalesRegionSummary() {
   
        overallSummaryInfo = new SummaryInfo();
        MASummaryInfo = new SummaryInfo();
        CTSummaryInfo = new SummaryInfo();
        CASummaryInfo = new SummaryInfo();
        MDSummaryInfo = new SummaryInfo();
        NYSummaryInfo = new SummaryInfo();
        OHSummaryInfo = new SummaryInfo();
        PASummaryInfo = new SummaryInfo();
        WYSummaryInfo = new SummaryInfo();
        
        //Closed Won
        AggregateResult[] overallClosedWon = 
          [SELECT Sales_Region__c ,COUNT(Id) won
             FROM Opportunity 
            WHERE StageName = 'Closed - Won'
              AND CloseDate >= :startDate
              and CloseDate <= :endDate
              GROUP BY Sales_Region__c];                
       
         
        for(AggregateResult ar : overallClosedWon)   
        {       
            overallSummaryInfo.ClosedWon = overallSummaryInfo.ClosedWon + (Integer)ar.get('won');              
            
            if(ar.get('Sales_Region__c') == 'MA Region')
            {
                MASummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'CT Region')
            {
                CTSummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'CA Region')
            {
                CASummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'MD Region')
            {
                MDSummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'NYC Region')
            {
                NYSummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'OH Region')
            {
                OHSummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'PA Region')
            {
                PASummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
            else if(ar.get('Sales_Region__c') == 'WNY Region')
            {
                WYSummaryInfo.ClosedWon = (Integer)ar.get('won');         
            }
        }   
        
        //Closed Lost
        AggregateResult[] overallClosedLost = 
          [SELECT Sales_Region__c ,COUNT(Id) lost
             FROM Opportunity 
            WHERE StageName = 'Closed - Lost'
              AND CloseDate >= :StartDate
              and CloseDate <= :EndDate
              GROUP BY Sales_Region__c ];                
       
        for(AggregateResult ar : overallClosedLost)   
        {       
            overallSummaryInfo.ClosedLost = overallSummaryInfo.ClosedLost + (Integer)ar.get('lost');              
            
            if(ar.get('Sales_Region__c') == 'MA Region')
            {
                MASummaryInfo.ClosedLost  = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'CT Region')
            {
                CTSummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'CA Region')
            {
                CASummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'MD Region')
            {
                MDSummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'NYC Region')
            {
                NYSummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'OH Region')
            {
                OHSummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'PA Region')
            {
                PASummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            else if(ar.get('Sales_Region__c') == 'WNY Region')
            {
                WYSummaryInfo.ClosedLost = (Integer)ar.get('lost');         
            }
            
            
        }    
   
        Map<String,SummaryInfo> ownerSummaryInfoMap = new Map<String,SummaryInfo>(); 
        
        MAownerSummaryInfo = new List<SummaryInfo>(); 
        CTownerSummaryInfo = new List<SummaryInfo>(); 
        CAownerSummaryInfo = new List<SummaryInfo>(); 
        MDownerSummaryInfo = new List<SummaryInfo>(); 
        NYownerSummaryInfo = new List<SummaryInfo>(); 
        OHownerSummaryInfo = new List<SummaryInfo>(); 
        PAownerSummaryInfo = new List<SummaryInfo>(); 
        WYownerSummaryInfo = new List<SummaryInfo>(); 
        
        SummaryInfo ownerSummary;
        String ownerName;
        String region;
        Integer Counter = 0;
       
        //Closed Won
        AggregateResult[] overallOwnerClosedWon = 
          [SELECT Sales_Region__c,Owner.Name,Owner.ID,COUNT(Id) won
             FROM Opportunity 
            WHERE StageName = 'Closed - Won'
              AND CloseDate >= :StartDate
              and CloseDate <= :EndDate 
              GROUP BY Sales_Region__c,Owner.Name,Owner.ID];                
       
        
        
        for(AggregateResult ar : overallOwnerClosedWon)   
        {       
            ownerSummary   = new SummaryInfo ();
            Counter  = Counter  + 1;
            ownerSummary.Counter = Counter ;
            ownerSummary.ClosedWon = ownerSummary.ClosedWon + (Integer)ar.get('won'); 
            ownerSummary.OwnerName = (String)ar.get('Name');
            ownerSummary.SalesRegion = (String)ar.get('Sales_Region__c');
            ownerSummary.OwnerId = (String)ar.get('Id');
            ownerSummaryInfoMap.put(ownerSummary.SalesRegion+'-'+ownerSummary.OwnerId,ownerSummary);
        }   
        
        //Closed Lost
        ownerSummary   = null;
        AggregateResult[] overallOwnerClosedLost = 
          [SELECT Sales_Region__c,Owner.Name,Owner.ID,COUNT(Id) lost
             FROM Opportunity 
            WHERE StageName = 'Closed - Lost'
              AND CloseDate >= :StartDate
              and CloseDate <= :EndDate             
              GROUP BY Sales_Region__c,Owner.Name,Owner.ID ];                
        
        for(AggregateResult ar : overallOwnerClosedLost)   
        {   
            ownerName = (String)ar.get('Id');
            region   = (String)ar.get('Sales_Region__c');
            ownerSummary   = ownerSummaryInfoMap.get(region + '-'+ownerName );
            System.debug('**--'+region + '-'+ownerName);
            if(ownerSummary == null)
            {
                ownerSummary   = new SummaryInfo ();  
                Counter  = Counter  + 1; 
                ownerSummary.Counter = Counter; 
                System.debug('Lost** '+ownerSummary.Counter);
                ownerSummary.OwnerName = (String)ar.get('Name');
                ownerSummary.OwnerId = (String)ar.get('Id');
                ownerSummary.SalesRegion = (String)ar.get('Sales_Region__c');
                System.debug('lost-ownerSummary.OwnerName** '+ownerSummary.OwnerName); 
                ownerSummaryInfoMap.put(ownerSummary.SalesRegion+'-'+ownerSummary.OwnerId,ownerSummary);
            }   
            ownerSummary.ClosedLost = ownerSummary.ClosedLost + (Integer)ar.get('lost');             
        }    
                   
        
        //Open Opptys
        ownerSummary   = null;
        String openQptyQuery = 'Select o.Owner.Name, o.CreatedDate,o.Owner.Id , Sales_Region__c '
                           +' ,(Select Id From Events Where isChild=false AND RecordType.Name In (\'Sales Visit Onsite\', \'Sales Visit Remote\', \'Site Survey Onsite\', \'Site Survey Remote\') and StartDateTime  >= :StartDate AND StartDateTime  <= :EndDate ) '
                           +' ,(Select Id from Tasks Where RecordType.Name = \'Inactivity Notice\' and ActivityDate  >= :StartDate AND ActivityDate  <= :EndDate)  '
                           +' From Opportunity o '
                           +' WHERE StageName NOT IN ( \'Closed - Lost\', \'Closed - Won\', \'Contract Cancelled\')   '
                           +' AND Probability ' + probabilitySign + ' :probabilityValue  limit 10000';
                                 
        for(Opportunity opp : Database.query(openQptyQuery ))    
         {
             ownerSummary   = ownerSummaryInfoMap.get(opp.Sales_Region__c + '-'+opp.ownerId);
             if(ownerSummary == null)
             {
                ownerSummary   = new SummaryInfo (); 
                Counter  = Counter  + 1; 
                ownerSummary.Counter = Counter;   
                System.debug('Open** '+ownerSummary.Counter); 
                ownerSummary.OwnerName = opp.owner.Name;
                ownerSummary.OwnerId = opp.ownerId;
                ownerSummary.SalesRegion = opp.Sales_Region__c;
                System.debug('Open-ownerSummary.OwnerName** '+ownerSummary.OwnerName); 
                
             }   
             if((opp.CreatedDate >= StartDate && opp.CreatedDate <= EndDate) || (opp.events !=null && opp.events.size() > 0) || (opp.tasks !=null && opp.tasks.size() > 0)  )
             {
                 overallSummaryInfo.OpenOppty = overallSummaryInfo.OpenOppty + 1;      
                    if(opp.Sales_Region__c == 'MA Region')
                    {
                        MASummaryInfo.OpenOppty = MASummaryInfo.OpenOppty + 1;     
                    }
                    else if(opp.Sales_Region__c == 'CT Region')
                    {
                        CTSummaryInfo.OpenOppty  = CTSummaryInfo.OpenOppty + 1;      
                    }
                    else if(opp.Sales_Region__c == 'CA Region')
                    {
                        CASummaryInfo.OpenOppty  = CASummaryInfo.OpenOppty + 1;      
                    }
                    else if(opp.Sales_Region__c == 'MD Region')
                    {
                        MDSummaryInfo.OpenOppty  = MDSummaryInfo.OpenOppty + 1;      
                    }
                    else if(opp.Sales_Region__c == 'NYC Region')
                    {
                        NYSummaryInfo.OpenOppty = NYSummaryInfo.OpenOppty + 1;            
                    }
                    else if(opp.Sales_Region__c == 'OH Region')
                    {
                        OHSummaryInfo.OpenOppty = OHSummaryInfo.OpenOppty + 1;            
                    }
                    else if(opp.Sales_Region__c == 'PA Region')
                    {
                        PASummaryInfo.OpenOppty = PASummaryInfo.OpenOppty + 1;             
                    }
                    else if(opp.Sales_Region__c == 'WNY Region')
                    {
                        WYSummaryInfo.OpenOppty = WYSummaryInfo.OpenOppty + 1;           
                    }          
                 //Before
                 ownerSummary.OpenOppty = ownerSummary.OpenOppty + 1;            
                 ownerSummaryInfoMap.put(ownerSummary.SalesRegion+'-'+ownerSummary.OwnerId,ownerSummary);    
             }      
             
        } 
        
        // Visits and Site Surveys
        ownerSummary   = null;
        String siteSurveyQuery = 'Select o.Name,o.Owner.Name, o.CreatedDate ,o.OwnerId , Sales_Region__c '
                           +' ,(Select Id,Event_Status__c,RecordType.Name From Events Where isChild=false AND RecordType.Name IN (\'Site Survey Onsite\',\'Site Survey Remote\',\'Sales Visit Onsite\',\'Sales Visit Remote\') '
                           +' AND StartDateTime  >= :StartDate AND StartDateTime  <= :EndDate ) '                          
                           +' From Opportunity o '
                           +' WHERE (Probability '+probabilitySign + ' '+probabilityValue +' OR Category__c = \'Closed\') limit 10000';   
        for(Opportunity opp :Database.query(siteSurveyQuery ))    
         {
             ownerSummary   = ownerSummaryInfoMap.get(opp.Sales_Region__c + '-'+opp.ownerId );
             if(ownerSummary == null)
             {
                ownerSummary   = new SummaryInfo (); 
                Counter  = Counter  + 1; 
                ownerSummary.Counter = Counter;    
                ownerSummary.OwnerName = opp.owner.Name;
                ownerSummary.OwnerId = opp.ownerId;
                ownerSummary.SalesRegion = opp.Sales_Region__c;
                System.debug('Open-ownerSummary.OwnerName** '+ownerSummary.OwnerName); 
                
                
             }   
             
             if (opp.events.size() > 0)
             {
                 Boolean eventExists = false;
                 for(Event evt : opp.events)
                 {
                     if(evt.RecordType.Name == 'Site Survey Onsite' || evt.RecordType.Name == 'Site Survey Remote' )
                     {
                         
                        if(opp.Sales_Region__c == 'MA Region')
                        {
                            MASummaryInfo.SiteSurveys = MASummaryInfo.SiteSurveys + 1;     
                        }                        
                        else if(opp.Sales_Region__c == 'CT Region')
                        {
                            CTSummaryInfo.SiteSurveys = CTSummaryInfo.SiteSurveys + 1;      
                        }
                        else if(opp.Sales_Region__c == 'CA Region')
                        {
                            CASummaryInfo.SiteSurveys = CASummaryInfo.SiteSurveys + 1;      
                        }
                        else if(opp.Sales_Region__c == 'MD Region')
                        {
                            MDSummaryInfo.SiteSurveys = MDSummaryInfo.SiteSurveys + 1;      
                        }
                        else if(opp.Sales_Region__c == 'NYC Region')
                        {
                            NYSummaryInfo.SiteSurveys = NYSummaryInfo.SiteSurveys + 1;            
                        }
                        else if(opp.Sales_Region__c == 'OH Region')
                        {
                            OHSummaryInfo.SiteSurveys = OHSummaryInfo.SiteSurveys + 1;            
                        }
                        else if(opp.Sales_Region__c == 'PA Region')
                        {
                            PASummaryInfo.SiteSurveys = PASummaryInfo.SiteSurveys + 1;             
                        }
                        else if(opp.Sales_Region__c == 'WNY Region')
                        {
                            WYSummaryInfo.SiteSurveys = WYSummaryInfo.SiteSurveys + 1;           
                        }      
                        ownerSummary.SiteSurveys = ownerSummary.SiteSurveys + 1; 
                        System.debug('**Site**'+opp.Name);
                        eventExists = true;
                         
                     }   
                     else // Sales Visits
                     {
                         if(evt.Event_Status__c == 'Scheduled')
                         {
                                overallSummaryInfo.VisitsScheduled =  overallSummaryInfo.VisitsScheduled +1;    
                                if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsScheduled = MASummaryInfo.VisitsScheduled + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsScheduled = CTSummaryInfo.VisitsScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsScheduled = CASummaryInfo.VisitsScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsScheduled = MDSummaryInfo.VisitsScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsScheduled = NYSummaryInfo.VisitsScheduled + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsScheduled = OHSummaryInfo.VisitsScheduled + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsScheduled = PASummaryInfo.VisitsScheduled + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsScheduled = WYSummaryInfo.VisitsScheduled + 1;           
                                }          
            
                              ownerSummary.VisitsScheduled =  ownerSummary.VisitsScheduled +1;   
                              eventExists = true; 
                         }
                         else if(evt.Event_Status__c == 'Rescheduled')
                         {
                              
                              overallSummaryInfo.VisitsReScheduled =  overallSummaryInfo.VisitsReScheduled +1;  
                                if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsReScheduled = MASummaryInfo.VisitsReScheduled + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsReScheduled  = CTSummaryInfo.VisitsReScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsReScheduled  = CASummaryInfo.VisitsReScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsReScheduled  = MDSummaryInfo.VisitsReScheduled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsReScheduled = NYSummaryInfo.VisitsReScheduled + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsReScheduled  = OHSummaryInfo.VisitsReScheduled  + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsReScheduled = PASummaryInfo.VisitsReScheduled  + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsReScheduled = WYSummaryInfo.VisitsReScheduled  + 1;           
                                }     
                              
                              ownerSummary.VisitsReScheduled =  ownerSummary.VisitsReScheduled +1;  
                              eventExists = true;  
                         }
                         else if(evt.Event_Status__c == 'Completed')
                         {
                              overallSummaryInfo.VisitsCompleted =  overallSummaryInfo.VisitsCompleted +1;   

                                if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsCompleted = MASummaryInfo.VisitsCompleted + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsCompleted = CTSummaryInfo.VisitsCompleted + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsCompleted = CASummaryInfo.VisitsCompleted + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsCompleted = MDSummaryInfo.VisitsCompleted + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsCompleted = NYSummaryInfo.VisitsCompleted + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsCompleted = OHSummaryInfo.VisitsCompleted + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsCompleted  = PASummaryInfo.VisitsCompleted + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsCompleted  = WYSummaryInfo.VisitsCompleted   + 1;           
                                }      
                              
                              ownerSummary.VisitsCompleted =  ownerSummary.VisitsCompleted +1;  
                              eventExists = true;  
                         }
                         else if(evt.Event_Status__c == 'Canceled by Customer')
                         {
                              overallSummaryInfo.VisitsCanceled =  overallSummaryInfo.VisitsCanceled +1;    
                                  if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsCanceled = MASummaryInfo.VisitsCanceled + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsCanceled  = CTSummaryInfo.VisitsCanceled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsCanceled  = CASummaryInfo.VisitsCanceled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsCanceled  = MDSummaryInfo.VisitsCanceled + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsCanceled = NYSummaryInfo.VisitsCanceled  + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsCanceled = OHSummaryInfo.VisitsCanceled + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsCanceled = PASummaryInfo.VisitsCanceled + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsCanceled   = WYSummaryInfo.VisitsCanceled + 1;           
                                }      
                              
                              ownerSummary.VisitsCanceled =  ownerSummary.VisitsCanceled +1;   
                              eventExists = true; 
                         }
                         else if(evt.Event_Status__c == 'Disqualified')
                         {
                              overallSummaryInfo.VisitsDisqualified =  overallSummaryInfo.VisitsDisqualified +1;    
                                if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsDisqualified = MASummaryInfo.VisitsDisqualified + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsDisqualified = CTSummaryInfo.VisitsDisqualified + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsDisqualified = CASummaryInfo.VisitsDisqualified + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsDisqualified = MDSummaryInfo.VisitsDisqualified + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsDisqualified = NYSummaryInfo.VisitsDisqualified + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsDisqualified = OHSummaryInfo.VisitsDisqualified + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsDisqualified = PASummaryInfo.VisitsDisqualified + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsDisqualified = WYSummaryInfo.VisitsDisqualified + 1;           
                                }      
            
                              ownerSummary.VisitsDisqualified =  ownerSummary.VisitsDisqualified +1;  
                              eventExists = true;  
                         }
                         else if(evt.Event_Status__c == 'Disqualified-Approved')
                         {
                                overallSummaryInfo.VisitsDisqApproved =  overallSummaryInfo.VisitsDisqApproved +1;  
                                if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsDisqApproved = MASummaryInfo.VisitsDisqApproved + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsDisqApproved = CTSummaryInfo.VisitsDisqApproved + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsDisqApproved = CASummaryInfo.VisitsDisqApproved + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsDisqApproved = MDSummaryInfo.VisitsDisqApproved + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsDisqApproved = NYSummaryInfo.VisitsDisqApproved + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsDisqApproved = OHSummaryInfo.VisitsDisqApproved + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsDisqApproved  = PASummaryInfo.VisitsDisqApproved + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsDisqApproved  = WYSummaryInfo.VisitsDisqApproved  + 1;           
                                }        
                              
                                ownerSummary.VisitsDisqApproved =  ownerSummary.VisitsDisqApproved +1;   
                                eventExists = true; 
                         }  
                         else if(evt.Event_Status__c == 'Missed')
                         {
                              
                              overallSummaryInfo.VisitsMissed =  overallSummaryInfo.VisitsMissed +1;   
                                if(opp.Sales_Region__c == 'MA Region')
                                {
                                    MASummaryInfo.VisitsMissed = MASummaryInfo.VisitsMissed + 1;     
                                }
                                else if(opp.Sales_Region__c == 'CT Region')
                                {
                                    CTSummaryInfo.VisitsMissed = CTSummaryInfo.VisitsMissed + 1;      
                                }
                                else if(opp.Sales_Region__c == 'CA Region')
                                {
                                    CASummaryInfo.VisitsMissed = CASummaryInfo.VisitsMissed + 1;      
                                }
                                else if(opp.Sales_Region__c == 'MD Region')
                                {
                                    MDSummaryInfo.VisitsMissed = MDSummaryInfo.VisitsMissed + 1;      
                                }
                                else if(opp.Sales_Region__c == 'NYC Region')
                                {
                                    NYSummaryInfo.VisitsMissed = NYSummaryInfo.VisitsMissed + 1;            
                                }
                                else if(opp.Sales_Region__c == 'OH Region')
                                {
                                    OHSummaryInfo.VisitsMissed = OHSummaryInfo.VisitsMissed + 1;            
                                }
                                else if(opp.Sales_Region__c == 'PA Region')
                                {
                                    PASummaryInfo.VisitsMissed = PASummaryInfo.VisitsMissed + 1;             
                                }
                                else if(opp.Sales_Region__c == 'WNY Region')
                                {
                                    WYSummaryInfo.VisitsMissed = WYSummaryInfo.VisitsMissed + 1;           
                                }         
                              
                              ownerSummary.VisitsMissed =  ownerSummary.VisitsMissed +1;    
                              eventExists = true;
                         }   
                     
                     } 
                     
                 } 
                 if(eventExists)
                 {
                     ownerSummaryInfoMap.put(ownerSummary.SalesRegion+'-'+ownerSummary.OwnerId,ownerSummary);
                 
                 }   
             }  
            
         } 
         
         for(SummaryInfo info :ownerSummaryInfoMap.Values() )
         {
         
            if(info.SalesRegion == 'MA Region')
            {
                MAownerSummaryInfo.add(info);     
            }
            else if(info.SalesRegion == 'CT Region')
            {
                CTownerSummaryInfo.add(info);       
            }
            else if(info.SalesRegion == 'CA Region')
            {
                CAownerSummaryInfo.add(info);       
            }
            else if(info.SalesRegion == 'MD Region')
            {
                MDownerSummaryInfo.add(info);       
            }
            else if(info.SalesRegion == 'NYC Region')
            {
                NYownerSummaryInfo.add(info);             
            }
            else if(info.SalesRegion == 'OH Region')
            {
                OHownerSummaryInfo.add(info);            
            }
            else if(info.SalesRegion == 'PA Region')
            {
                PAownerSummaryInfo.add(info);             
            }
            else if(info.SalesRegion == 'WNY Region')
            {
                WYownerSummaryInfo.add(info);          
            }          
         }
   }
   
   
   @RemoteAction
   public static List<Opportunity> getAEOpportunities(String OwnerId,String stDate,String enDate,String probSign,String probValue) {
        
        String[] params = OwnerId.split(':');
        
        System.debug('**'+params[0] );
        System.debug('**'+params[1] );
        System.debug('**'+params[2] );
       
        
        String region = params[0] + ' Region';
        String category = params[1];
        String filterownerId = params[2];
        Date filterStartDate = Date.parse(stDate);
        Date filterEndDate = Date.parse(enDate);
        
        System.debug('**'+filterStartDate  );
        System.debug('filterEndDate **'+filterEndDate );
        
        String queryOpps = 'Select Id,Account.Name,Name,StageName,Category__C,CloseDate , CreatedDate , system_design_quote__c , Amount , Probability '
                                +'    ,(Select StartDateTime,Event_Status__c,RecordType.Name,Completed__C,Ever_Been_Missed__c,Min_Not_Complete_Action_Date__c From Events Where isChild=false AND RecordType.Name In (\'Sales Visit Onsite\', \'Sales Visit Remote\', \'Site Survey Onsite\', \'Site Survey Remote\') AND StartDateTime  >= :filterStartDate AND StartDateTime  <= :filterEndDate ) '                          
                                +'    ,(Select ActivityDate From Tasks Where RecordType.Name = \'Inactivity Notice\' AND ActivityDate  >= :FilterStartDate AND ActivityDate  <= :FilterEndDate )   '       
                                +'   from Opportunity Where Sales_Region__c = :region  and Category__c = :category  and OwnerId= :filterownerId  and (Probability '+probSign+ ' '+probValue+' OR Category__c = \'Closed\')';
        
        System.debug('**'+queryOpps );
        
        List<Opportunity> opps = new List<Opportunity>();
        
        for(Opportunity opp :Database.query(queryOpps))    
        {    
            System.debug('**'+opp.Name+ ' '+opp.Category__c);
            System.debug('**'+opp.CreatedDate);
            System.debug('**'+opp.System_Design_Quote__c);
            System.debug('**'+opp.Amount );
            if(opp.CreatedDate >= filterStartDate  && opp.CreatedDate <= filterEndDate )
             {
                 opps.add(opp);               
             }
             if(opp.Category__c == 'Closed' && opp.CloseDate >= filterStartDate  && opp.CloseDate <= filterEndDate )
             {
                 opps.add(opp);               
             }      
             
             else if (opp.events != null && opp.events.size() > 0)
             {
                 opps.add(opp); 
             }  
             else if(opp.tasks != null && opp.tasks.size() > 0) 
             {
                 opps.add(opp);  
             }                        
            
        }
        System.debug('**'+opps.size());
        return opps;
    
    }
   
   public class SummaryInfo{
        public String SalesRegion{ get; private set; }
        public String OwnerName{ get; private set; }
        public String OwnerId{ get; private set; }
        public Integer counter { get; private set; }
        public Integer ClosedWon { get; private set; }
        public Integer ClosedLost { get; private set; }
        public Integer OpenOppty { get; private set; }
        public Integer SiteSurveys { get; private set; }
        public Integer VisitsScheduled { get; private set; }
        public Integer VisitsCompleted { get; private set; }
        public Integer VisitsReScheduled { get; private set; }
        public Integer VisitsCanceled { get; private set; }
        public Integer VisitsDisqualified { get; private set; }
        public Integer VisitsDisqApproved { get; private set; }
        public Integer VisitsMissed { get; private set; }
        
        public SummaryInfo()
        {
            counter = 0;
            ClosedWon = 0;
            ClosedLost = 0;
            OpenOppty = 0;
            SiteSurveys = 0;
            VisitsScheduled = 0;
            VisitsCompleted = 0;
            VisitsReScheduled  = 0;
            VisitsCanceled = 0;
            VisitsDisqualified = 0;
            VisitsDisqApproved = 0;
            VisitsMissed = 0;    
        
        }
    } 
    */
 
}