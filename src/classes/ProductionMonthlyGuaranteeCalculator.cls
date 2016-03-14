/* FILE: ProductionMonthlyGuaranteeCalculator .cls
 * AUTHOR: Rohit Jain
 * DATE: May 13, 2013
 * PURPOSE: Calculates astrum estimate and production guarantees based on PVWatts, 
 *          total system size, generation start date, and snow derate 
 * MODIFICATION HISTORY
 *
 */

public class ProductionMonthlyGuaranteeCalculator {
    
    public static final Date PRODUCTION_GUARANTEE_START = Date.newInstance(2011,7,1);
    public static final Double PRODUCTION_GUARANTEE_PCT = 0.95; //95%
    public static final Double GUARANTEE_ANNUAL_DERATE_PCT = .005; //0.5%
    
    //jan-dec and total
    private static String[] fieldNames = new String[] {
        'January__c', 'February__c', 'March__c', 'April__c', 'May__c', 'June__c',
        'July__c', 'August__c', 'September__c', 'October__c', 'November__c', 'December__c'
    };

        //jan-dec and total
    private static String[] productionFactorFields = new String[] {
        'Monthly_Production_Factor_Jan__c', 'Monthly_Production_Factor_Feb__c', 'Monthly_Production_Factor_Mar__c', 'Monthly_Production_Factor_Apr__c', 'Monthly_Production_Factor_May__c', 'Monthly_Production_Factor_Jun__c',
        'Monthly_Production_Factor_Jul__c', 'Monthly_Production_Factor_Aug__c', 'Monthly_Production_Factor_Sep__c', 'Monthly_Production_Factor_Oct__c', 'Monthly_Production_Factor_Nov__c', 'Monthly_Production_Factor_Dec__c'
    };
    
    //snow de-rate normal distribution Dec - Mar (15%, 35%, 35%, 15% = 100%)
    private static Double[] snowRatio = new Double[] { .35, .35, .15, 0, 0, 0, 0, 0, 0, 0, 0, .15 };

    public static List<ProductionGuarantee> getProductionGuarantee(PVWatts_Production_Estimates__c pvw, Installed_System__c sys ,Date generationStart) {
        
        List<ProductionGuarantee> result = new List<ProductionGuarantee>();
        Boolean guranteeFlag = false;
        Date utilityConnectDate;
        Integer guaranteeStartYear;
        System.debug('*generationStart' + generationStart);
        Integer currentMonth = Date.today().month();
        System.debug('*currentMonth ' + currentMonth );
        
        Decimal projectAnnualOutput = sys.Quoted_System_Design__r.System_Design__r.Total_Projected_Annual_Output_kWh_y__c ;
        //System.debug('*projectAnnualOutput ' + projectAnnualOutput );
        
        if(generationStart >= PRODUCTION_GUARANTEE_START)
        {
            guranteeFlag = true;    
        }
        if(guranteeFlag )
        {
            if (sys.PM_Project__c != null)
            {
                utilityConnectDate = sys.PM_Project__r.Approved_Utility_Interconnect_Part_2__c;    
                 System.debug('*pm2 utilityConnectDate ' + utilityConnectDate );
                //System.debug('*pm2-utilityConnectDate ' + utilityConnectDate );
            }
            else if(sys.Project__c != null)
            {    System.debug('*pm1 Project__c ' + sys.Project__c);
                 String prjId = Sys.Project__c;
                 if(prjId.length() >=15)
                 {
                    prjId = prjId.substring(0,15);
                 }
                 System.debug('*pm1 prjId  ' + prjId );
                try{
                    Milestone1_Task__c appTask = [Select Due_Date__c From Milestone1_Task__c Where Name = 'Received Certificate of Completion/Net Meter Rider' and ProjectId__c = :prjId  ];
                    utilityConnectDate = apptask.Due_Date__c;
                     System.debug('*pm1 utilityConnectDate ' + utilityConnectDate );
                    //System.debug('*pm1-utilityConnectDate ' + utilityConnectDate );
                }
                catch(Exception e)
                {
                    System.debug('*Err ' + e);
                    utilityConnectDate = null;  
                }
            }
            else
            {
                utilityConnectDate  =    generationStart; 
                 System.debug('*gs utilityConnectDate ' + utilityConnectDate );
            }
            
            Date guaranteeStartDate = utilityConnectDate  > generationStart ? utilityConnectDate  : generationStart ;
            
            if(guaranteeStartDate != null)
            {
                guaranteeStartYear = guaranteeStartDate.year() + 1;
                if (guaranteeStartDate.month() == 1 && guaranteeStartDate.day() == 1) {
                    guaranteeStartYear = guaranteeStartDate.year();
                }       
            }
            else
            {
                guranteeFlag = false;     
            
            }
            System.debug('*gs guranteeFlag ' + guranteeFlag );
            
        } 
        
        Date startOfMonth;
        if(generationStart.day() != 1)
        {
            startOfMonth = generationStart.toStartOfMonth().addMonths(1);
        }
        else
        {
            startOfMonth = generationStart.toStartOfMonth();
        }       
                
        Date startOfThisMonth = Date.today().toStartOfMonth();         
        Decimal productionFactor = (Decimal)sys.get(productionFactorFields[startOfMonth.month()-1] );
        //System.debug('**productionFactor ' + productionFactor );
        Double monthIndex = 0;  
        Double derateFactor = 1-(.005/12);          
        while (startOfMonth < startOfThisMonth) {
            //Double yearsDiff = Math.max(startOfMonth.year() - guaranteeStartYear, 0);
            //Integer monthIndex = startOfMonth.month() - 1;
            ProductionGuarantee pg = new ProductionGuarantee();
            pg.startOfMonth = startOfMonth;
            //System.debug('**monthIndex  ' + monthIndex  );
            Decimal estimate = (projectAnnualOutput) * (productionFactor/100)  * (Math.pow(derateFactor , monthIndex));
            pg.estimate_kWh = estimate.setScale(2);           
            if (guranteeFlag  && startOfMonth.year() >= guaranteeStartYear) {
                Decimal gurantee = pg.estimate_kWh * PRODUCTION_GUARANTEE_PCT;
                pg.guarantee_kWh = gurantee.setScale(2);                 
            }
            result.add(pg);
            startOfMonth = startOfMonth.addMonths(1);          
            productionFactor = (Decimal)sys.get(productionFactorFields[startOfMonth.month()-1] );
            //System.debug('**productionFactor ' + productionFactor );
            monthIndex = monthIndex + 1;
        }
                
        return result;          
        
    }

    public class ProductionGuarantee {
        public Date startOfMonth;
        public Double guarantee_kWh;
        public Double estimate_kWh;
    }

}