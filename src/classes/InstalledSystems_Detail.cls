/***********************************************
    Apex: InstalledSystems_ProductionDetail
    Author:  Astrum Solar
    Usage:   This class is used to show Overview, Detail,
             etc detail for Installed Systems
    Date:    01/07/2012
07/07/2012 TCM - zen-34 prevent errors when information missing on installed system
09/13/2012 TCM - enphase production data
10/26/2012 TCM - removed old code
***********************************************/
public class InstalledSystems_Detail {

    /* set for Production data */
    public Installed_System__c objInstSys {get; set;}
    /* set for installed system instance */
    public Installed_System__c insSysInstance{get; set;}
    /* set installed system id */
    public Id instSysId {get; set;}
    public String sysDesignImgPath {get; set;}
    public String insSysImgPath {get; set;}
    /* List for graph */
    List<Installed_System__c> listInstSys;
    List<ProdWrapper> objProdWrap = new List<ProdWrapper>();
    public ProdWrapper prodSummary{get;set;} // variable for summary row;
   /* all year changes */
   string[] strMonthArray = new String[]{'','January','February','March','April','May','June','July','August','September','October','November','December'};
   string[] strShortMonth = new String[]{'','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
   public Date objDate ;
   /* all year changes */
    
    public InstalledSystems_Detail(ApexPages.StandardController contoller){
        prodSummary = new ProdWrapper();
        instSysId = (Id)contoller.getId();
        
        if( !Test.isRunningTest() ){
            objDate = Date.today();
        }else{
            objDate  = Date.newInstance(2011,12,12);
        }
        
        objInstSys = [ Select System_Certification__c, January_Solar_Access__c, February_Solar_Access__c, March_Solar_Access__c, April_Solar_Access__c, May_Solar_Access__c, 
                       June_Solar_Access__c, July_Solar_Access__c, August_Solar_Access__c, September_Solar_Access__c, 
                       October_Solar_Access__c, November_Solar_Access__c, December_Solar_Access__c, 
                       
                       January_Daily_Peak_Sun_Hours__c,February_Daily_Peak_Sun_Hours__c, March_Daily_Peak_Sun_Hours__c, April_Daily_Peak_Sun_Hours__c,                         
                       May_Daily_Peak_Sun_Hours__c, June_Daily_Peak_Sun_Hours__c, July_Daily_Peak_Sun_Hours__c, 
                       August_Daily_Peak_Sun_Hours__c, September_Daily_Peak_Sun_Hours__c, October_Daily_Peak_Sun_Hours__c, 
                       November_Daily_Peak_Sun_Hours__c, December_Daily_Peak_Sun_Hours__c, 
                       
                       January_Monthly_Peak_Sun_Hours__c, February_Monthly_Peak_Sun_Hours__c, 
                       March_Monthly_Peak_Sun_Hours__c, April_Monthly_Peak_Sun_Hours__c, 
                       May_Monthly_Peak_Sun_Hours__c, June_Monthly_Peak_Sun_Hours__c, July_Monthly_Peak_Sun_Hours__c, 
                       August_Monthly_Peak_Sun_Hours__c, September_Monthly_Peak_Sun_Hours__c, October_Monthly_Peak_Sun_Hours__c,
                       November_Monthly_Peak_Sun_Hours__c, December_Monthly_Peak_Sun_Hours__c,                        
                       
                       January_Percent_Yearly_Sun_Hours__c, February_Percent_Yearly_Sun_Hours__c, March_Percent_Yearly_Sun_Hours__c, 
                       April_Percent_Yearly_Sun_Hours__c, May_Percent_Yearly_Sun_Hours__c, 
                       June_Percent_Yearly_Sun_Hours__c, July_Percent_Yearly_Sun_Hours__c, August_Percent_Yearly_Sun_Hours__c, 
                       September_Percent_Yearly_Sun_Hours__c, October_Percent_Yearly_Sun_Hours__c, November_Percent_Yearly_Sun_Hours__c, 
                       December_Percent_Yearly_Sun_Hours__c, 
                       
                       Projected_January_Production_kWh__c, Projected_February_Production_kWh__c, Projected_March_Production_kWh__c, 
                       Projected_April_Production_kWh__c, Projected_May_Production_kWh__c, Projected_June_Production_kWh__c, 
                       Projected_July_Production_kWh__c, Projected_August_Production_kWh__c, Projected_September_Production_kWh__c, 
                       Projected_October_Production_kWh__c, Projected_November_Production_kWh__c, Projected_December_Production_kWh__c,
                       
                       X10_Payment_Documents_Submitted__c,X10_Payment_Invoice_Authorized__c,X60_Payment_Documents_Submitted__c,X60_Payment_Invoice_Authorized__c,
                       X30_Payment_Documents_Submitted__c,X30_Payment_Invoice_Authorized__c
                                                   
                       from Installed_System__c where id = :instSysId];
                       
           listInstSys = [Select Installation_Year__c,Production_Year_Starting_Month__c,January_Solar_Access__c, February_Solar_Access__c, March_Solar_Access__c, 
                       April_Solar_Access__c, May_Solar_Access__c, June_Solar_Access__c, 
                       July_Solar_Access__c, August_Solar_Access__c, September_Solar_Access__c, 
                       October_Solar_Access__c, November_Solar_Access__c, December_Solar_Access__c, 
                       January_Daily_Peak_Sun_Hours__c, February_Daily_Peak_Sun_Hours__c, 
                       March_Daily_Peak_Sun_Hours__c, April_Daily_Peak_Sun_Hours__c, 
                       May_Daily_Peak_Sun_Hours__c, June_Daily_Peak_Sun_Hours__c, 
                       July_Daily_Peak_Sun_Hours__c, August_Daily_Peak_Sun_Hours__c, 
                       September_Daily_Peak_Sun_Hours__c, October_Daily_Peak_Sun_Hours__c, 
                       November_Daily_Peak_Sun_Hours__c, December_Daily_Peak_Sun_Hours__c, 
                       January_Monthly_Peak_Sun_Hours__c, February_Monthly_Peak_Sun_Hours__c, 
                       March_Monthly_Peak_Sun_Hours__c, April_Monthly_Peak_Sun_Hours__c, 
                       May_Monthly_Peak_Sun_Hours__c, June_Monthly_Peak_Sun_Hours__c, 
                       July_Monthly_Peak_Sun_Hours__c, August_Monthly_Peak_Sun_Hours__c, 
                       September_Monthly_Peak_Sun_Hours__c, October_Monthly_Peak_Sun_Hours__c,
                       November_Monthly_Peak_Sun_Hours__c, December_Monthly_Peak_Sun_Hours__c, 
                       January_Percent_Yearly_Sun_Hours__c, February_Percent_Yearly_Sun_Hours__c, 
                       March_Percent_Yearly_Sun_Hours__c, April_Percent_Yearly_Sun_Hours__c, 
                       May_Percent_Yearly_Sun_Hours__c, June_Percent_Yearly_Sun_Hours__c, 
                       July_Percent_Yearly_Sun_Hours__c, August_Percent_Yearly_Sun_Hours__c, 
                       September_Percent_Yearly_Sun_Hours__c, October_Percent_Yearly_Sun_Hours__c, 
                       November_Percent_Yearly_Sun_Hours__c, December_Percent_Yearly_Sun_Hours__c, 
                       Projected_January_Production_kWh__c, Projected_February_Production_kWh__c, 
                       Projected_March_Production_kWh__c, Projected_April_Production_kWh__c, 
                       Projected_May_Production_kWh__c, Projected_June_Production_kWh__c, 
                       Projected_July_Production_kWh__c, Projected_August_Production_kWh__c, 
                       Projected_September_Production_kWh__c, Projected_October_Production_kWh__c, 
                       Projected_November_Production_kWh__c, Projected_December_Production_kWh__c,
                       (Select Name,January_Production_Guarantee_kWh__c, February_Production_Guarantee_kWh__c, 
                       March_Production_Guarantee_kWh__c, April_Production_Guarantee_kWh__c, 
                       May_Production_Guarantee_kWh__c, June_Production_Guarantee_kWh__c, 
                       July_Production_Guarantee_kWh__c, August_Production_Guarantee_kWh__c, 
                       September_Production_Guarantee_kWh__c, October_Production_Guarantee_kWh__c, 
                       November_Production_Guarantee_kWh__c, December_Production_Guarantee_kWh__c,
                       January_Actual_Production_kWh__c, February_Actual_Production_kWh__c, 
                       March_Actual_Production_kWh__c, April_Actual_Production_kWh__c, 
                       May_Actual_Production_kWh__c, June_Actual_Production_kWh__c, July_Actual_Production_kWh__c, 
                       August_Actual_Production_kWh__c, September_Actual_Production_kWh__c, 
                       October_Actual_Production_kWh__c, November_Actual_Production_kWh__c, 
                       December_Actual_Production_kWh__c,January_Projected_SRECs__c, February_Projected_SRECs__c, 
                       March_Projected_SRECs__c, April_Projected_SRECs__c, May_Projected_SRECs__c, 
                       June_Projected_SRECs__c, July_Projected_SRECs__c, August_Projected_SRECs__c, 
                       September_Projected_SRECs__c, October_Projected_SRECs__c, November_Projected_SRECs__c, 
                       December_Projected_SRECs__c,January_SRECs_Generated__c, February_SRECs_Generated__c, 
                       March_SRECs_Generated__c, April_SRECs_Generated__c, May_SRECs_Generated__c, 
                       June_SRECs_Generated__c, July_SRECs_Generated__c, August_SRECs_Generated__c, 
                       September_SRECs_Generated__c, October_SRECs_Generated__c, November_SRECs_Generated__c, 
                       December_SRECs_Generated__c, Annual_Production_Guarantee__c,Year__c from Annual_Production__r order by Year__c Desc),
                       (Select Name, CreatedDate, LastModifiedDate, Installed_System__c, Panel_Manufacturer__c, 
                       Panel_Type__c, Panel_Output_W__c, Panel_Serial_Number__c, Inverter_Type__c, 
                       Inverter_Serial_Number__c From Installed_Panels__r)                               
                       from Installed_System__c where id = :instSysId];
                       
                sysDesignImgPath = '';
                insSysImgPath = '';
                findImagePath(instSysId);
          }
         
         public void findImagePath(Id instSysId){
             List<Attachment> attList = [Select a.ParentId, a.Name, a.Id From Attachment a where a.ParentId =:instSysId];
             
             if(attList.size()> 0){                 
                 for(Attachment a :attList){
                     String img = a.Name ;
                     System.debug('Name:::' + a.Name);
                     if(img.contains('esign'))
                         sysDesignImgPath = a.Id;
                     else if(img.contains('nstal'))
                         insSysImgPath = a.Id;
                 }   
             }
         }
         
         /* return Installed Panels Data */     
         public List<Installed_Panel__c>  getInstalledPanelsData(){
              return [select Name,CreatedById,LastModifiedById,Installed_System__c,Inverter_Serial_Number__c,Inverter_Type__c,
                     Panel_Manufacturer__c,Panel_Output_W__c,Panel_Serial_Number__c,Panel_Type__c from Installed_Panel__c 
                     where Installed_System__c = :instSysId];
         }
                    
    public List<ProdWrapper> getProductionHistory() {
        
        List<ProdWrapper> result = new List<ProdWrapper>();

//TODO: merge with SREC data?
        List<Monthly_Production__c> monthlyProd = 
            [SELECT Id, Enphase_kWh__c, Production_Guarantee__c, Start_of_Month__c
            FROM Monthly_Production__c
            WHERE Installed_System__c = :instSysId 
            ORDER BY Start_of_Month__c DESC];
            
        Time zero = Time.newInstance(0, 0, 0, 0);
        
        for (Monthly_Production__c mp : monthlyProd) {
            ProdWrapper wrapper = new ProdWrapper (
                String.valueOf(mp.Start_of_Month__c.year()),
                DateTime.newInstance(mp.Start_of_Month__c, zero).format('MMMM'),
                null, //Decimal annlprodgrnt,
                mp.Production_Guarantee__c, 
                mp.Enphase_kWh__c,
                mp.Production_Guarantee__c == null ? null : mp.Enphase_kWh__c - mp.Production_Guarantee__c,  
                mp.Production_Guarantee__c == null || mp.Production_Guarantee__c == 0 ? null 
                    : mp.Enphase_kWh__c / mp.Production_Guarantee__c,  
                null, //Decimal strmonthprojsrec, 
                null, // Decimal strmonthactlsrec, 
                null //Decimal strmonthsrecdiff
            );
            result.add(wrapper);
            
            if (mp.Production_Guarantee__c != null) {
                prodSummary.monthgrnt += mp.Production_Guarantee__c;
            }
             
            if (mp.Enphase_kWh__c != null) {
                prodSummary.monthactl += mp.Enphase_kWh__c;
            }
            
            //TODO: srecs and diff
            //prodSummary.monthprojsrec += totalmonthprojsrec;
            //prodSummary.monthactlsrec += totalmonthactlsrec;
            //prodSummary.monthsrecdiff += totalmonthsrecdiff;
            //prodSummary.monthproddiff += totalproddiff;
            
            System.debug(mp);
        }
            
        return result;
        
    }
       
       public List<System_Design_Item__c> getSysDesignItems() {
           Installed_System__c instSys = [select Quoted_System_Design__r.System_Design__c 
                                                    from Installed_System__c where id = :instSysId];
       
           List<System_Design_Item__c> listSysDesignItems = [select Name, Effective_TSRF__c, Install_Location__c,
                   Location_Pitch__c, Location_Stories__c, MasterSD__c, Panel_Pitch__c, Projected_Annual_Output_kWh_y__c,
                   Property__c, Quantity__c, Rated_Output_kW__c, System_Design_Array__c, System_Design_Product__c, 
                   Tilt__c, TSRF_Adjustment__c, LastModifiedById, LastModifiedDate from System_Design_Item__c 
                   where System_Design_Array__r.System_Design__c = :instSys.Quoted_System_Design__r.System_Design__c];
                   
           return listSysDesignItems;
       }   
      
     
   
    public List<Monthly_Production__c> production {
        get {
            if (production == null) {
                production = 
                    [SELECT Start_of_Month__c, Year__c, Month__c, Enphase_kWh__c, Production_Guarantee__c, Astrum_Estimated__c, External_Estimated__c
                    FROM Monthly_Production__c
                    WHERE Installed_System__c = :instSysId
                    ORDER BY Start_of_Month__c DESC];
            }
            return production;
        }
        private set;
    }
    
    public List<Enphase_Alert__c> alerts {
        get {
            if (alerts == null) {
                alerts = 
                    [SELECT Id, Alert_Name__c, Alert_Start__c, Impact__c, Number_of_Devices__c, Alert_Level__c, Acknowledged__c
                    FROM Enphase_Alert__c
                    WHERE Installed_System__c = :instSysId 
                    AND Acknowledged__c <> true 
                    //AND Alert_Start__c = LAST_90_DAYS
                    ORDER BY Alert_Start__c DESC];
            }
            return alerts;
        }
        private set;
    } 
    
       public List<SREC_Certificate__c> srecs { 
           get { 
               if (srecs == null) { 
                   srecs = 
                       [SELECT Id, Quantity__c, Serial_Number__c, Energy_Compliance_Year__c, Calendar_Compliance_Year__c, Location_of_Generator__c, 
                           Date_Customer_Paid__c, Month_of_Generation__c, Price_Paid_to_Customer_SREC__c 
                        FROM SREC_Certificate__c 
                       WHERE Installed_System__c = :instSysId 
                       ORDER BY Energy_Compliance_Year__c];  
               } 
               return srecs; 
           } 
           private set; 
       } 
        
       public class ProdWrapper {
            public String year{get;private set;}
            public string month{get;private set;}
            public Decimal annlgrnt{get;private set;}
            public Decimal monthgrnt{get;private set;}
            public Decimal monthactl{get;private set;}
            public Decimal monthproddiff{get;private set;}
            public Decimal monthprodperf{get;private set;}
            public Decimal monthprojsrec{get;private set;}
            public Decimal monthactlsrec{get;private set;}
            public Decimal monthsrecdiff{get;private set;}
            
            public ProdWrapper(){
                annlgrnt = 0;    
                monthgrnt = 0;
                monthactl = 0;
                monthproddiff = 0 ;
                monthprodperf = 0;
                monthprojsrec = 0;
                monthactlsrec = 0;
                monthsrecdiff = 0;
            }
            public ProdWrapper(String prodyear,string prodmonth,Decimal annlprodgrnt,Decimal strmonthgrnt, Decimal strmonthactl, Decimal strmonthproddiff, Decimal strmonthprodperf, Decimal strmonthprojsrec, Decimal strmonthactlsrec, Decimal strmonthsrecdiff){
               year = prodyear;
               month = prodmonth;
               annlgrnt = annlprodgrnt == null ? null : annlprodgrnt.setscale(1);
               monthgrnt = strmonthgrnt == null ? null : strmonthgrnt.setscale(1);
               monthactl = strmonthactl == null ? null : strmonthactl.setscale(1);
               monthproddiff = strmonthproddiff == null ? null : strmonthproddiff.setscale(1);
               monthprodperf = strmonthprodperf == null ? null : strmonthprodperf.setscale(1);
               monthprojsrec = strmonthprojsrec == null ? null : strmonthprojsrec.setscale(1);
               monthactlsrec = strmonthactlsrec == null ? null : strmonthactlsrec.setscale(1);
               monthsrecdiff = strmonthsrecdiff == null ? null : strmonthsrecdiff.setscale(1);           
            }
        }
 }