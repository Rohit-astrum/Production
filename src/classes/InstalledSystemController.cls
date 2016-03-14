/***********************************************
    Class: InstalledSystemController 
    Author:  Astrum Solar
    Usage:   This class is used for calculation for creating
             graphs and display the data of Installed System 
             and Annual Production object in the form of charts.
    Date:    12/26/2011
06/27/2012 TCM - zen-21 add paging and alleviate viewstate problems
07/11/2012 TCM - comment out unused code
***********************************************/

public Class InstalledSystemController {

    /* variable used - start*/
    
    public Integer PAGE_SIZE { get { return 100; } } 
    
    //private String queryCondition; // variable for condition in dynamic query
    
    private String sortExp = 'Account__r.Name'; // default sort expression
    
    private String sortDirection = 'ASC'; // default sort direction
    
    private String nullExp = 'NULLS LAST'; // sorting for null values last
    
    //String sortFullExp; // expression for sorting
    
    //String queryConditionOrder; // for dynamic query
    
    public String queryType { get; set; } // for inner or outer query
    
    public Integer currentPage { get; set; }
    
    Date objDate = Date.today(); // todays date
    
    String stryear = '2012'; // default year
    
    transient List<InstallWrapper> listWrapper; // list of wrapper
    
    private static final Integer thisYear = Date.today().year();
    private static final Integer thisMonth = Date.today().month();
    
    private static final String[] strMonthArray = new String[]{'','January','February','March','April','May','June','July','August','September','October','November','December'};
    
    public InstallWrapper summaryWrapper{get;set;} // for summary row
    public integer totalpanels{get;set;} // for summary row
    String startQuery = 'Select Name, Installation_Date__c, Id, Installation_Year__c,Production_Year_Starting_Month__c,' 
                         + 'State__c, Generation_Start_Date__c, System_Makeup__c, Number_of_Panels__c,' 
                         + 'Lease_Financing_Type__c, Lease_Purchase__c, Account__r.Id, Account__r.Name, Property__r.Name,' 
                         + 'Property__r.Id, Sales_Order__r.Name, Sales_Order__r.Id, Quoted_System_Design__r.Name,' 
                         + 'Quoted_System_Design__r.Id,Quoted_System_Design__r.System_Design__r.Name,'
                         + 'Quoted_System_Design__r.System_Design__r.Id,(Select January_Production_Guarantee_kWh__c, February_Production_Guarantee_kWh__c,' 
                         + 'March_Production_Guarantee_kWh__c, April_Production_Guarantee_kWh__c,' 
                         + 'May_Production_Guarantee_kWh__c, June_Production_Guarantee_kWh__c,' 
                         + 'July_Production_Guarantee_kWh__c, August_Production_Guarantee_kWh__c,'
                         + 'September_Production_Guarantee_kWh__c, October_Production_Guarantee_kWh__c,' 
                         + 'November_Production_Guarantee_kWh__c, December_Production_Guarantee_kWh__c,'
                         + 'January_Actual_Production_kWh__c, February_Actual_Production_kWh__c,' 
                         + 'March_Actual_Production_kWh__c, April_Actual_Production_kWh__c,' 
                         + 'May_Actual_Production_kWh__c, June_Actual_Production_kWh__c, July_Actual_Production_kWh__c,' 
                         + 'August_Actual_Production_kWh__c, September_Actual_Production_kWh__c,' 
                         + 'October_Actual_Production_kWh__c, November_Actual_Production_kWh__c,' 
                         + 'December_Actual_Production_kWh__c,January_Projected_SRECs__c, February_Projected_SRECs__c,' 
                         + 'March_Projected_SRECs__c, April_Projected_SRECs__c, May_Projected_SRECs__c, '
                         + 'June_Projected_SRECs__c, July_Projected_SRECs__c, August_Projected_SRECs__c, '
                         + 'September_Projected_SRECs__c, October_Projected_SRECs__c, November_Projected_SRECs__c,' 
                         + 'December_Projected_SRECs__c,January_SRECs_Generated__c, February_SRECs_Generated__c, '
                         + 'March_SRECs_Generated__c, April_SRECs_Generated__c, May_SRECs_Generated__c,' 
                         + 'June_SRECs_Generated__c, July_SRECs_Generated__c, August_SRECs_Generated__c,' 
                         + 'September_SRECs_Generated__c, October_SRECs_Generated__c, November_SRECs_Generated__c,'
                         + 'December_SRECs_Generated__c,Annual_Production_Guarantee__c,Expected_SRECs_To_Date__c,' 
                         + 'Annual_SRECs_To_Date__c, Projected_vs_Actual_SRECs_To_Date__c, Year__c From Annual_Production__r '
                         + 'WHERE Year__c <> NULL) from Installed_System__c';           
 
    public enum EncodingType { TEXT, SIMPLE, EXTENDED } // variable for encoding type
    
    public EncodingType eType { get; private set; } // variable for encoding for google chart
    
    public String strGrntURL { get; set;}
    public String chartData { get; set;}
    public Boolean displayChart { get; set; }       
    
    public string PiecChartURL{get;set;}
    /* variable used - end*/ 
    
    /* google map exception classes - start */
    public class EncodingException extends Exception {}
    public class UnsupportedEncodingTypeException 
           extends Exception {}
    /* google map exception classes - end */

	private Integer totalRecords = 0;    
   
    /* --setCon as ApexPages.StandardSetController --*/
    public ApexPages.StandardSetController setCon {
        get {
            //List<Installed_System__c> listInstSys = new List<Installed_System__c>();
            if(setCon == null) {
            	
				String sortFullExp = sortExpression  + ' ' + sortDirection + ' ' + nullExp;               
            	String queryConditionOrder = startQuery + ' order by ' + sortFullExp; 
            	System.debug('^^^^^^^^^^^^^query'+ queryConditionOrder);    
            	setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryConditionOrder));
            	setCon.setPageSize(PAGE_SIZE);
				totalRecords = setCon.getResultSize();
				currentPage = setCon.getPageNumber();
               
               /*
               listInstSys = [Select Name, Installation_Date__c, Id,Installation_Year__c,Production_Year_Starting_Month__c, 
                             State__c, Generation_Start_Date__c, System_Makeup__c, Number_of_Panels__c, 
                             Lease_Financing_Type__c, Lease_Purchase__c, Account__r.Id, Account__r.Name, 
                             Property__r.Name, Property__r.Id, Sales_Order__r.Name, Sales_Order__r.Id, 
                             Quoted_System_Design__r.Name, Quoted_System_Design__r.Id,
                             Quoted_System_Design__r.System_Design__r.Name,Quoted_System_Design__r.System_Design__r.Id,
                             (Select January_Production_Guarantee_kWh__c, February_Production_Guarantee_kWh__c, 
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
                             September_SRECs_Generated__c, October_SRECs_Generated__c,  
                             November_SRECs_Generated__c,December_SRECs_Generated__c, Annual_Production_Guarantee__c,                                                           // Annual_Production_Guarantee_To_Date_kWh__c , Annual_Production_To_Date_kWh__c,Annual_Guarantee_vs_Actual_Prod_To_Date__c, 
                             Expected_SRECs_To_Date__c, Annual_SRECs_To_Date__c, 
                             Projected_vs_Actual_SRECs_To_Date__c, Year__c From Annual_Production__r order by Year__c) 
                             from Installed_System__c order by Account__r.Name]; 
               setCon = new ApexPages.StandardSetController(listInstSys);
	            setCon.setPageSize(170);
               */                
            } else {
            	if (currentPage != null) {
					setCon.setPageNumber(currentPage);
            	}
            }
            return setCon;
        }
        private set;
    }
    
    public Integer totalPages {
    	get { 
    		if (totalPages == null && totalRecords != null) {
    			totalPages = Math.ceil(totalRecords * 1.0 / PAGE_SIZE).intValue();
    		}
    		return totalPages;
    	}
    	private set;
    }
    
    public Integer[] pageList {
    	get {
    		if (totalPages == null || totalPages == 0) {
    			return null;
    		}
    		Integer[] result = new Integer[totalPages];
    		for (Integer i = 0; i < totalPages; i++) {
    			result[i] = i+1;
    		}
    		return result;
    	}
    }
    

    
	public InstalledSystemController() { 
        listWrapper = getSystemList();       
        //createPartList();
        createSummary(); 
        
        //TCM commented out
        //CreateSummaryOfInstalledSystemsCertified();
        //CreateSummaryOfInstalledSystemsNotCertified();     
     }
    
    
/* TCM
    //
    // Class needed for Summary of Installed Systems
    //
    public List<SummaryOfInstalledSystems> systemsCertified {get;set;}
    public List<SummaryOfInstalledSystems> systemsNotCertified {get;set;}
    public class SummaryOfInstalledSystems
    {
        public String State {get;set;}
        public integer NumberInstalled {get;set;}
        public double kW {get;set;}
        
        public double ActualToDate {get;set;}
        public string ActualToDateFormatted {set;get;}
        
        public double GuaranteeToDate {get;set;}
        public string GuaranteeToDateFomatted {get;set;}
        
        public double GuaranteeVsActual {get;set;}
        public string GuaranteeVsActualFormatted {get;set;}
    }
    
    private void CreateSummaryOfInstalledSystemsCertified()
    {   
        systemsCertified = new List<SummaryOfInstalledSystems>();   
        AggregateResult[] agr = [SELECT 
                                    COUNT(a.Id)NumInstalled,
                                    a.Installed_System__r.System_State__c,
                                    SUM(a.Installed_System__r.System_Size_kW__c)kW,
                                    SUM(January_Actual_Production_kWh__c)Jan,
                                    SUM(February_Actual_Production_kWh__c)Feb,
                                    SUM(March_Actual_Production_kWh__c)Mar,
                                    SUM(April_Actual_Production_kWh__c)Apr,
                                    SUM(May_Actual_Production_kWh__c)May,
                                    SUM(June_Actual_Production_kWh__c)Jun,
                                    SUM(July_Actual_Production_kWh__c)Jul,
                                    SUM(August_Actual_Production_kWh__c)Aug,
                                    SUM(September_Actual_Production_kWh__c)Sep,
                                    SUM(October_Actual_Production_kWh__c)Oct,
                                    SUM(November_Actual_Production_kWh__c)Nov,
                                    SUM(December_Actual_Production_kWh__c)Dec,
                                
                                    SUM(January_Production_Guarantee_kWh__c)Jan_G,
                                    SUM(February_Production_Guarantee_kWh__c)Feb_G,
                                    SUM(March_Production_Guarantee_kWh__c)Mar_G,
                                    SUM(April_Production_Guarantee_kWh__c)Apr_G,
                                    SUM(May_Production_Guarantee_kWh__c)May_G,
                                    SUM(June_Production_Guarantee_kWh__c)Jun_G,
                                    SUM(July_Production_Guarantee_kWh__c)Jul_G,
                                    SUM(August_Production_Guarantee_kWh__c)Aug_G,
                                    SUM(September_Production_Guarantee_kWh__c)Sep_G,
                                    SUM(October_Production_Guarantee_kWh__c)Oct_G,
                                    SUM(November_Production_Guarantee_kWh__c)Nov_G,
                                    SUM(December_Production_Guarantee_kWh__c)Dec_G
                                    FROM Annual_Production__c a
                                    WHERE a.Installed_System__r.System_Certification__c <> 'Not Yet Certified'
                                    GROUP BY a.Installed_System__r.System_State__c];
        
        for(AggregateResult a : agr)
        {    
            SummaryOfInstalledSystems s = new SummaryOfInstalledSystems();      
            double totalProductionToDate = Double.valueOf(a.get('Jan')) + 
                                            Double.valueOf(a.get('Feb')) +
                                            Double.valueOf(a.get('Mar')) +
                                            Double.valueOf(a.get('Apr')) +
                                            Double.valueOf(a.get('May')) +
                                            Double.valueOf(a.get('Jun')) +
                                            Double.valueOf(a.get('Jul')) +
                                            Double.valueOf(a.get('Aug')) + 
                                            Double.valueOf(a.get('Sep')) +
                                            Double.valueOf(a.get('Oct')) + 
                                            Double.valueOf(a.get('Nov')) +
                                            Double.valueOf(a.get('Dec'));
            
            double totalGuaranteeToDate = 0 + Double.valueOf(a.get('Jan_G')) + 
                                            Double.valueOf(a.get('Feb_G')) +
                                            Double.valueOf(a.get('Mar_G')) +
                                            Double.valueOf(a.get('Apr_G')) +
                                            Double.valueOf(a.get('May_G')) +
                                            Double.valueOf(a.get('Jun_G')) +
                                            Double.valueOf(a.get('Jul_G')) +
                                            Double.valueOf(a.get('Aug_G')) + 
                                            Double.valueOf(a.get('Sep_G')) +
                                            Double.valueOf(a.get('Oct_G')) + 
                                            Double.valueOf(a.get('Nov_G')) +
                                            Double.valueOf(a.get('Dec_G'));
                                                        
            s.NumberInstalled = Integer.valueOf(a.get('NumInstalled'));
            s.State = String.valueOf(a.get('System_State__c'));
            s.kW = Double.valueOf(a.get('kW'));
            s.ActualToDate = totalProductionToDate;
            s.ActualToDateFormatted = totalProductionToDate.round().format();
            s.GuaranteeToDate = totalGuaranteeToDate;
            s.GuaranteeToDateFomatted = totalGuaranteeToDate.round().format();          
            
            if(totalProductionToDate == null)
                totalProductionToDate = 0;
            
            if(totalGuaranteeToDate == null)
                totalGuaranteeToDate = 0;
                
            s.GuaranteeVsActual = (totalProductionToDate / totalGuaranteeToDate) * 100;
            string fmt = s.GuaranteeVsActual.format();
            
            s.GuaranteeVsActualFormatted =  fmt.substring(0, fmt.indexOf('.') + 2) + '%';
            
            systemsCertified.add(s);
        }       
    }
    
    private void CreateSummaryOfInstalledSystemsNotCertified()
    {       
        systemsNotCertified = new List<SummaryOfInstalledSystems>();
        AggregateResult[] agr = [SELECT 
                                    COUNT(a.Id)NumInstalled,
                                    a.Installed_System__r.System_State__c,
                                    SUM(a.Installed_System__r.System_Size_kW__c)kW,
                                    
                                    SUM(January_Actual_Production_kWh__c)Jan,
                                    SUM(February_Actual_Production_kWh__c)Feb,
                                    SUM(March_Actual_Production_kWh__c)Mar,
                                    SUM(April_Actual_Production_kWh__c)Apr,
                                    SUM(May_Actual_Production_kWh__c)May,
                                    SUM(June_Actual_Production_kWh__c)Jun,
                                    SUM(July_Actual_Production_kWh__c)Jul,
                                    SUM(August_Actual_Production_kWh__c)Aug,
                                    SUM(September_Actual_Production_kWh__c)Sep,
                                    SUM(October_Actual_Production_kWh__c)Oct,
                                    SUM(November_Actual_Production_kWh__c)Nov,
                                    SUM(December_Actual_Production_kWh__c)Dec,
                                    
                                    SUM(January_Production_Guarantee_kWh__c)Jan_G,
                                    SUM(February_Production_Guarantee_kWh__c)Feb_G,
                                    SUM(March_Production_Guarantee_kWh__c)Mar_G,
                                    SUM(April_Production_Guarantee_kWh__c)Apr_G,
                                    SUM(May_Production_Guarantee_kWh__c)May_G,
                                    SUM(June_Production_Guarantee_kWh__c)Jun_G,
                                    SUM(July_Production_Guarantee_kWh__c)Jul_G,
                                    SUM(August_Production_Guarantee_kWh__c)Aug_G,
                                    SUM(September_Production_Guarantee_kWh__c)Sep_G,
                                    SUM(October_Production_Guarantee_kWh__c)Oct_G,
                                    SUM(November_Production_Guarantee_kWh__c)Nov_G,
                                    SUM(December_Production_Guarantee_kWh__c)Dec_G                                  
                                    FROM Annual_Production__c a
                                    WHERE a.Installed_System__r.System_Certification__c = 'Not Yet Certified'
                                    GROUP BY a.Installed_System__r.System_State__c];
        
        for(AggregateResult a : agr)
        {    
            SummaryOfInstalledSystems s = new SummaryOfInstalledSystems();  

            double totalProductionToDate = 0 + Double.valueOf(a.get('Jan')) + 
                                            Double.valueOf(a.get('Feb')) +
                                            Double.valueOf(a.get('Mar')) +
                                            Double.valueOf(a.get('Apr')) +
                                            Double.valueOf(a.get('May')) +
                                            Double.valueOf(a.get('Jun')) +
                                            Double.valueOf(a.get('Jul')) +
                                            Double.valueOf(a.get('Aug')) + 
                                            Double.valueOf(a.get('Sep')) +
                                            Double.valueOf(a.get('Oct')) + 
                                            Double.valueOf(a.get('Nov')) +
                                            Double.valueOf(a.get('Dec'));
                        
            double totalGuaranteeToDate = 0 + Double.valueOf(a.get('Jan_G')) + 
                                            Double.valueOf(a.get('Feb_G')) +
                                            Double.valueOf(a.get('Mar_G')) +
                                            Double.valueOf(a.get('Apr_G')) +
                                            Double.valueOf(a.get('May_G')) +
                                            Double.valueOf(a.get('Jun_G')) +
                                            Double.valueOf(a.get('Jul_G')) +
                                            Double.valueOf(a.get('Aug_G')) + 
                                            Double.valueOf(a.get('Sep_G')) +
                                            Double.valueOf(a.get('Oct_G')) + 
                                            Double.valueOf(a.get('Nov_G')) +
                                            Double.valueOf(a.get('Dec_G'));
                                                        
            s.NumberInstalled = Integer.valueOf(a.get('NumInstalled'));
            s.State = String.valueOf(a.get('System_State__c'));
            s.kW = Double.valueOf(a.get('kW'));
            s.ActualToDate = totalProductionToDate;
            s.ActualToDateFormatted = totalProductionToDate.round().format();
            s.GuaranteeToDate = totalGuaranteeToDate;
            s.GuaranteeToDateFomatted = totalGuaranteeToDate.round().format();          
            
            if(totalProductionToDate == null)
                totalProductionToDate = 0;
            
            if(totalGuaranteeToDate == null)
                totalGuaranteeToDate = 0;
                
            s.GuaranteeVsActual = (totalProductionToDate / totalGuaranteeToDate) * 100;
            string fmt = s.GuaranteeVsActual.format();
            
            s.GuaranteeVsActualFormatted =  fmt.substring(0, fmt.indexOf('.') + 2) + '%';
                                
            systemsNotCertified.add(s);
        }       
    }

	//create the partion for pie chart
    private void createPartList() {
        
        String chd = '';    
        String chl = '';
        string chco = '61AF3F,707274,009DDC';
        integer noooverprod =0;
        integer nounderprod = 0;
        integer noprojprod = 0;
        
        if(listWrapper != null && listWrapper.size() > 0) {
            
            for(InstallWrapper item : listWrapper) {
                
                if(item.Grnt_vs_Actl_Prod > 105)
                    noooverprod += 1;
                    
                 else if(item.Grnt_vs_Actl_Prod < 95) 
                    nounderprod += 1;
                    
                 else 
                    noprojprod += 1;     
            }
        }
        
       if(noooverprod > 0) {           
            chd +=  string.ValueOf(noooverprod) + ',';
            chl +=  'Over Producing > 5% [' + noooverprod + ']|';
       }
       
        if(nounderprod > 0) {           
            chd +=  string.ValueOf(nounderprod) + ',';
            chl +=  'Under Producing < 5% [' + nounderprod + ']|';
        }
              
        if(noprojprod > 0) {          
            chd +=  String.ValueOf(noprojprod ) + ',';
            chl +=  'On%20Target%20%2B%2F-%205%20%25 ['+ noprojprod + ']|';
        }
        
        if(chd.length()>0)
            chd = chd.substring(0, chd.length() -1);
        if(chl.length()>0)
            chl = chl.substring(0, chl.length() -1);
       
        String result = '&chd=t:' + chd + '&chl=' + chl + '&chts=000000,12,c' +'&chco=' + chco + '&chma=5,5,50,50';
        PiecChartURL = '&cht=p3&chtt=Production+Overview' + result ;
       
    }
*/    
    public void createSummary() {

		Integer Annl_Prod_Grnt = 0;
		Integer Annl_Prod_Grnt_To_Date = 0; 
		Integer Annl_Prod_To_Date = 0;       
		Double Grnt_vs_Actl_Prod = 0; 
		Integer exp_srec_to_date = 0;
		Integer annl_srec_to_date = 0;
		integer proj_vs_actl_srec = 0;
		
		List<AggregateResult> panelCount = 
			[SELECT SUM(Number_of_Panels__c) totalPanels
			FROM Installed_System__c
			WHERE Installation_Year__c != NULL 
			AND Generation_Start_Date__c != NULL
			AND Number_of_Panels__c != NULL];
			
		if (panelCount.size() > 0) {
			if (panelCount[0].get('totalPanels') != null) {
				totalPanels = ((Double)panelCount[0].get('totalPanels')).intValue();
			}
		} 
    	
		AggregateResult[] annualProduction = 
			[SELECT
				CALENDAR_YEAR(Start_of_Year__c) prodYear,
				CALENDAR_YEAR(Installed_System__r.Generation_Start_Date__c) installYear,
				CALENDAR_MONTH(Installed_System__r.Generation_Start_Date__c) installMonth,
				/* Production guarantees */ 
				SUM(Annual_Production_Guarantee__c) annualTotalGrnt,
				SUM(January_Production_Guarantee_kWh__c) janTotalGrnt,
                SUM(February_Production_Guarantee_kWh__c) febTotalGrnt,
                SUM(March_Production_Guarantee_kWh__c) marTotalGrnt,
                SUM(April_Production_Guarantee_kWh__c) aprTotalGrnt, 
                SUM(May_Production_Guarantee_kWh__c) mayTotalGrnt,
                SUM(June_Production_Guarantee_kWh__c) junTotalGrnt,
                SUM(July_Production_Guarantee_kWh__c) julTotalGrnt, 
                SUM(August_Production_Guarantee_kWh__c) augTotalGrnt, 
                SUM(September_Production_Guarantee_kWh__c) sepTotalGrnt,
                SUM(October_Production_Guarantee_kWh__c) octTotalGrnt, 
                SUM(November_Production_Guarantee_kWh__c) novTotalGrnt, 
                SUM(December_Production_Guarantee_kWh__c) decTotalGrnt, 
				/* Actual Production */ 
                SUM(Annual_Production_To_Date_kWh__c) janTotal, 
                SUM(February_Actual_Production_kWh__c) febTotal, 
                SUM(March_Actual_Production_kWh__c) marTotal, 
                SUM(April_Actual_Production_kWh__c) aprTotal, 
                SUM(May_Actual_Production_kWh__c) mayTotal, 
                SUM(June_Actual_Production_kWh__c) junTotal, 
                SUM(July_Actual_Production_kWh__c) julTotal,
                SUM(August_Actual_Production_kWh__c) augTotal,
                SUM(September_Actual_Production_kWh__c) sepTotal, 
                SUM(October_Actual_Production_kWh__c) octTotal, 
                SUM(November_Actual_Production_kWh__c) novTotal, 
                SUM(December_Actual_Production_kWh__c) decTotal,
				/* Projected SRECs */ 
				SUM(January_Projected_SRECs__c) janprojsrec, 
				SUM(February_Projected_SRECs__c) febprojsrec, 
				SUM(March_Projected_SRECs__c) marprojsrec, 
				SUM(April_Projected_SRECs__c) aprprojsrec, 
				SUM(May_Projected_SRECs__c) mayprojsrec, 
                SUM(June_Projected_SRECs__c) junprojsrec, 
                SUM(July_Projected_SRECs__c) julprojsrec, 
                SUM(August_Projected_SRECs__c) augprojsrec, 
				SUM(September_Projected_SRECs__c) sepprojsrec, 
				SUM(October_Projected_SRECs__c) octprojsrec, 
				SUM(November_Projected_SRECs__c) novprojsrec, 
				SUM(December_Projected_SRECs__c) decprojsrec,
				/* Generated SRECs */ 
				SUM(January_SRECs_Generated__c) jangensrec, 
				SUM(February_SRECs_Generated__c) febgensrec, 
				SUM(March_SRECs_Generated__c) margensrec, 
				SUM(April_SRECs_Generated__c) aprgensrec, 
				SUM(May_SRECs_Generated__c) maygensrec, 
				SUM(June_SRECs_Generated__c) jungensrec, 
				SUM(July_SRECs_Generated__c) julgensrec, 
				SUM(August_SRECs_Generated__c) auggensrec, 
				SUM(September_SRECs_Generated__c) sepgensrec, 
				SUM(October_SRECs_Generated__c) octgensrec, 
				SUM(November_SRECs_Generated__c) novgensrec, 
				SUM(December_SRECs_Generated__c) decgensrec 
                
			FROM Annual_Production__c
			WHERE Installed_System__r.Installation_Year__c != NULL 
			AND Installed_System__r.Generation_Start_Date__c != NULL 

			GROUP BY CALENDAR_YEAR(Start_of_Year__c),
				CALENDAR_YEAR(Installed_System__r.Generation_Start_Date__c),
				CALENDAR_MONTH(Installed_System__r.Generation_Start_Date__c)];

		Integer prodYear, installYear, installMonth;
		Integer[] result;
			
		for (AggregateResult ap : annualProduction) {
		
			prodYear = (Integer)ap.get('prodYear');
			installYear = (Integer)ap.get('installYear');
			installMonth = (Integer)ap.get('installMonth');
			if (prodYear == null || installYear == null || installMonth == null) {
				continue;
			}
		
			if ((prodYear - installYear) > 0  && prodYear == thisYear) {
				result = calcTotals(thisMonth - 1, 1, ap);
			} else if ((prodYear - installYear) > 0) {
				result = calcTotals(12, 1, ap);                             
			} else if ((prodYear - installYear) == 0){
				Integer endMonth = (prodYear == thisYear) ? thisMonth - 1 : 12;     
				result = calcTotals(endmonth, installMonth, ap);                             
			} else {
				result = null;
			}
			
			if (result != null) {
				Annl_Prod_Grnt_To_Date += result[0];
				Annl_Prod_To_Date += result[1];
				exp_srec_to_date += result[2];
				annl_srec_to_date += result[3];     
			}

			if (ap.get('annualTotalGrnt') != null) {   
				 Annl_Prod_Grnt += ((Double)(ap.get('annualTotalGrnt'))).intValue();               
			}

		}

		if (exp_srec_to_date != 0) {
			proj_vs_actl_srec = (annl_srec_to_date - exp_srec_to_date);
		}  

        summaryWrapper = new InstallWrapper(null);
                 
        summaryWrapper.Annl_Prod_Grnt = Annl_Prod_Grnt; 
		summaryWrapper.Annl_Prod_Grnt_To_Date = Annl_Prod_Grnt_To_Date; 
		summaryWrapper.Annl_Prod_To_Date = Annl_Prod_To_Date; 
		summaryWrapper.exp_srec_to_date = exp_srec_to_date;
		summaryWrapper.annl_srec_to_date = annl_srec_to_date;
		summaryWrapper.proj_vs_actl_srec = proj_vs_actl_srec;    
            
		if (summaryWrapper.Annl_Prod_Grnt_To_Date != 0) {
			summaryWrapper.Grnt_vs_Actl_Prod  += ((Double)summaryWrapper.Annl_Prod_To_Date / (Double)summaryWrapper.Annl_Prod_Grnt_To_Date) * 100 ;
		}  
    	
    }
    
    private Integer[] calcTotals (Integer endmonth, Integer startmonth, AggregateResult ap) {
        
        String[] months = new String[] { '', 'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec' };
		Integer[] result = new Integer[4];
		result[0] = result[1] = result[2] = result[3] = 0;

		for (Integer i = endmonth; i >= startmonth ; i--) {
			if (ap.get(months[i] + 'TotalGrnt') != null) {   
				result[0] += ((Double)(ap.get(months[i] +'TotalGrnt'))).intValue();               
			}
			if (ap.get(months[i] + 'Total') != null) {    
				result[1] += ((Double)(ap.get(months[i] + 'Total'))).intValue();
			}
			if (ap.get(months[i] + 'projsrec') != null) {   
				result[2] += ((Double)(ap.get(months[i] +'projsrec'))).intValue();
			}               
			if (ap.get(months[i] + 'gensrec') != null) {    
				result[3] += ((Double)(ap.get(months[i] + 'gensrec'))).intValue();
			}
		}
		return result;
	}

/* TCM    
    public void createSummary_OLD() {
    
        totalpanels = 0;
        InstallWrapper tempwrapper = new InstallWrapper(null);
        integer Annl_Prod_Grnt = 0; 
        
        if(listWrapper != null && listWrapper.size() > 0){
            for(InstallWrapper item : listWrapper){
            
                if(item.objSystem.Number_of_Panels__c != null) {    
                    totalpanels = totalpanels +  integer.valueOf(item.objSystem.Number_of_Panels__c); 
                 } 
                 
                tempwrapper.Annl_Prod_Grnt += item.Annl_Prod_Grnt; 
                tempwrapper.Annl_Prod_Grnt_To_Date += item.Annl_Prod_Grnt_To_Date; 
                tempwrapper.Annl_Prod_To_Date += item.Annl_Prod_To_Date; 
                tempwrapper.exp_srec_to_date += item.exp_srec_to_date;
                tempwrapper.annl_srec_to_date += item.annl_srec_to_date;
                tempwrapper.proj_vs_actl_srec += item.proj_vs_actl_srec;    
            } 
            
           if(tempwrapper.Annl_Prod_Grnt_To_Date != 0) {
           
                tempwrapper.Grnt_vs_Actl_Prod  += ((Double)tempwrapper.Annl_Prod_To_Date /(Double)tempwrapper.Annl_Prod_Grnt_To_Date)*100 ;  
           }  
          
        }
        summaryWrapper = tempwrapper;
    }
*/    
    
    // --returns the sort expression --
    public String sortExpression{
        get{            
            return sortExp;            
        }
        set{
        	// if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';            
            sortExp = value;
        }
    }
     
    // --method to be show sort direction image-- 
    public String getSortDirection() {
        
        // if column is not selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
	//called when changing the query (sorting)
	public PageReference viewData(){
        
        /* build the full sort expression */
        if(queryType == 'outer') {
        	setCon = null; //force rebuild
        	totalRecords = null;
        	totalPages = null;
        	listWrapper = null;
        }
        
        //getSystemList(); 
        return null;
    }
    
    //forces refresh with new page number
    public PageReference changePage() {
    	listWrapper = null;
    	return null;
    }
    
	// method for getting all Install Systems 
	public List<InstallWrapper> getSystemList() {
     
		if (queryType == 'outer' || queryType == null || queryType == '') {
			
			if (listWrapper == null) {
         
				List<Installed_System__c> listSystem = (List<Installed_System__c>) setCon.getRecords();
				listWrapper = new List<InstallWrapper>();
              
				for(Installed_System__c item : listSystem) {
					listWrapper.add(new InstallWrapper(item));      
				}             
			}
       
/* TCM       
		} else if(queryType == 'inner') {
			
           if (listWrapper != null) {
               listWrapper = customSort(listWrapper, sortExpression, sortDirection);
           }   
*/                   
       }
       
       return listWrapper;  
         
   }
   
	// Wrapper class for Install System records */
	public class InstallWrapper {
       
		public Installed_System__c objSystem { get; private set; }
		public Integer Annl_Prod_Grnt { get; private set; }
		public Integer Annl_Prod_Grnt_To_Date { get; private set; } 
		public Integer Annl_Prod_To_Date { get; private set; }       
		public Double Grnt_vs_Actl_Prod { get; private set; } 
		public Integer exp_srec_to_date { get; private set; }
		public Integer annl_srec_to_date { get; private set; }
		public integer proj_vs_actl_srec { get; private set; }        
		public integer count { get; set; }  
       
		public InstallWrapper(Installed_System__c installSys) {
			Grnt_vs_Actl_Prod = Annl_Prod_Grnt = Annl_Prod_Grnt_To_Date = Annl_Prod_To_Date  
				= exp_srec_to_date = annl_srec_to_date = proj_vs_actl_srec = 0;       
			objSystem = installSys;
       		if (objSystem == null || objSystem.Installation_Year__c == null) {
       			return;
       		}
       		
       		Integer[] result;
       		
			for (Annual_Production__c objannl : objSystem.Annual_Production__r ) {
                                     
				if ((objannl.Year__c - objSystem.Installation_Year__c) > 0  && objannl.Year__c == thisYear) {
					result = calcGrntActlProd(thisMonth - 1, 1, objannl);
				} else if ((objannl.Year__c - objSystem.Installation_Year__c) > 0) {
					result = calcGrntActlProd(12, 1, objannl);                             
				} else if ((objannl.Year__c - objSystem.Installation_Year__c) == 0){
					Integer endMonth = (objannl.Year__c == thisYear) ? thisMonth - 1 : 12;     
					Integer startMonth = Integer.valueOf(objSystem.Production_Year_Starting_Month__c);
					result = calcGrntActlProd(endmonth ,startmonth,objannl);                             
				} else {
					result = null;
				}
                             
				if (result != null) {
					Annl_Prod_Grnt_To_Date += result[0];
					Annl_Prod_To_Date += result[1];
					exp_srec_to_date += result[2];
					annl_srec_to_date += result[3];     
				}
                            
	            if (objannl.Year__c == 2011){
					if (objannl.Annual_Production_Guarantee__c != null) {
						Annl_Prod_Grnt = Integer.ValueOf(objannl.Annual_Production_Guarantee__c);
					}
				}
			
			}  

			if (Annl_Prod_Grnt_To_Date != 0) {
				Grnt_vs_Actl_Prod  = ((Double)Annl_Prod_To_Date / (Double)Annl_Prod_Grnt_To_Date) * 100;
			}
			if (exp_srec_to_date != 0) {
				proj_vs_actl_srec = (annl_srec_to_date - exp_srec_to_date);
			}  
		}
       
		public Double getFieldValue(String field) {
			Double fieldvalue;
			if (field.equals('Annual_Production_Guarantee_To_Date_kWh__c')) {
				fieldvalue = Annl_Prod_Grnt_To_Date;
			} else if (field.equals('Annual_Production_Guarantee__c')) {
				fieldvalue = Annl_Prod_Grnt;
			} else if (field.equals('Annual_Production_To_Date_kWh__c')) {
				fieldvalue = Annl_Prod_To_Date ;
			} else if (field.equals('Annual_Guarantee_vs_Actual_Prod_To_Date__c')) {
				fieldvalue = Grnt_vs_Actl_Prod; 
			} else if (field.equals('Expected_SRECs_To_Date__c')) {
				fieldvalue = exp_srec_to_date;    
			} else if(field.equals('Annual_SRECs_To_Date__c')) {
				fieldvalue = annl_srec_to_date;
			} else if(field.equals('Projected_vs_Actual_SRECs_To_Date__c')) {
				fieldvalue = proj_vs_actl_srec;
			}     
			return fieldvalue;   
		}
       
		/* install system table chnages */
		public Integer[] calcGrntActlProd(integer endmonth, integer startmonth, Annual_Production__c objAP) {
        
			Integer[] result = new Integer[4];
			result[0] = result[1] = result[2] = result[3] = 0;

			for (Integer count = endmonth; count >= startmonth ; count--) {
				if (objAP.get(strMonthArray[count] + '_Production_Guarantee_kWh__c') != null) {   
					result[0] += ((Double)(objAP.get(strMonthArray[count] +'_Production_Guarantee_kWh__c'))).intValue();               
				}
				if (objAP.get(strMonthArray[count] + '_Actual_Production_kWh__c') != null) {    
					result[1] += ((Double)(objAP.get(strMonthArray[count] + '_Actual_Production_kWh__c'))).intValue();
				}
				if (objAP.get(strMonthArray[count] + '_Projected_SRECs__c') != null) {   
					result[2] += ((Double)(objAP.get(strMonthArray[count] +'_Projected_SRECs__c'))).intValue();
				}               
				if (objAP.get(strMonthArray[count] + '_SRECs_Generated__c') != null) {    
					result[3] += ((Double)(objAP.get(strMonthArray[count] + '_SRECs_Generated__c'))).intValue();
				}
			}
			return result;
		}
	}
   
/*
    // - method for sorting sObject list -
    public List<InstallWrapper> customSort(List<InstallWrapper> unSortedList, String sortField, String sortOrder) {
        
        List<InstallWrapper> resultList = new List<InstallWrapper>();

        Map<object, List<InstallWrapper>> objectMap = new Map<object, List<InstallWrapper>>();

        for(InstallWrapper objWrp : unSortedList){          
            
            if(objectMap.get(ObjWrp.getFieldValue(sortField)) == null)              
              objectMap.put(ObjWrp.getFieldValue(sortField), new List<InstallWrapper>());
              
            objectMap.get(ObjWrp.getFieldValue(sortField)).add(ObjWrp);
        }       

        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();

        for(object key : keys){
            resultList.addAll(objectMap.get(key));
        }

        List<InstallWrapper> sortedList = unsortedList;
        sortedList.clear();
        
        if(sortOrder.toLowerCase() == 'asc')
        {
           for(InstallWrapper objWrap :resultList)
               sortedList.add(objWrap);
        }
        else if(sortOrder.toLowerCase() == 'desc')
        {
           for(integer i = resultList.size() - 1; i >= 0; i--)
               sortedList.add(resultList[i]);
        }

        return sortedList;
    }  
   
	// - method for getting guaranteed vs actual production graph -
    public string getSysGrntURL() { // new changes ###########
        
       eType = EncodingType.TEXT;
       String GrntData = '';
       String ActlData = '';
       Double maxvalue = 0;
       integer graphmin = 0;
       integer graphmax = 0;
  
       AggregateResult[] aggrResult = [SELECT SUM(January_Production_Guarantee_kWh__c) janTotalGrnt,
                                       SUM(February_Production_Guarantee_kWh__c) febTotalGrnt,
                                       SUM(March_Production_Guarantee_kWh__c) marTotalGrnt,
                                       SUM(April_Production_Guarantee_kWh__c) aprTotalGrnt, 
                                       SUM(May_Production_Guarantee_kWh__c) mayTotalGrnt,
                                       SUM(June_Production_Guarantee_kWh__c) juneTotalGrnt,
                                       SUM(July_Production_Guarantee_kWh__c) julyTotalGrnt, 
                                       SUM(August_Production_Guarantee_kWh__c) augTotalGrnt, 
                                       SUM(September_Production_Guarantee_kWh__c) sepTotalGrnt,
                                       SUM(October_Production_Guarantee_kWh__c) octTotalGrnt, 
                                       SUM(November_Production_Guarantee_kWh__c) novTotalGrnt, 
                                       SUM(December_Production_Guarantee_kWh__c) decTotalGrnt, 
                                       SUM(January_Actual_Production_kWh__c) janTotal, 
                                       SUM(February_Actual_Production_kWh__c) febTotal, 
                                       SUM(March_Actual_Production_kWh__c) marTotal, 
                                       SUM(April_Actual_Production_kWh__c) aprTotal, 
                                       SUM(May_Actual_Production_kWh__c) mayTotal, 
                                       SUM(June_Actual_Production_kWh__c) juneTotal, 
                                       SUM(July_Actual_Production_kWh__c) julyTotal,
                                       SUM(August_Actual_Production_kWh__c) augTotal,
                                       SUM(September_Actual_Production_kWh__c) sepTotal, 
                                       SUM(October_Actual_Production_kWh__c) octTotal, 
                                       SUM(November_Actual_Production_kWh__c) novTotal, 
                                       SUM(December_Actual_Production_kWh__c) decTotal, 
                                       count(Year__c) yr 
                                       from Annual_Production__c 
                                       where Year__c  = 2011];  
         
       if(aggrResult[0].get('janTotalGrnt') != null) {
           GrntData += aggrResult[0].get('janTotalGrnt') + ',';
       if((Double)aggrResult[0].get('janTotalGrnt') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('janTotalGrnt'); 
       } 
       else
           GrntData += 0.0 + ',';
       
       if(aggrResult[0].get('febTotalGrnt') != null){
           GrntData += aggrResult[0].get('febTotalGrnt') + ','; 
           if((Double)aggrResult[0].get('febTotalGrnt') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('febTotalGrnt');    
        }
       else
           GrntData += 0.0 + ',';
       
       if(aggrResult[0].get('marTotalGrnt') != null) {
           GrntData += aggrResult[0].get('marTotalGrnt') + ',';
           if((Double)aggrResult[0].get('marTotalGrnt') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('marTotalGrnt');        
       }
       else
           GrntData += 0.0 + ',';
       
       if(aggrResult[0].get('aprTotalGrnt') != null){
           GrntData += aggrResult[0].get('aprTotalGrnt') + ',';
           if((Double)aggrResult[0].get('aprTotalGrnt') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('aprTotalGrnt');  
       }
       else
           GrntData += 0.0 + ',';    
       
       if(aggrResult[0].get('mayTotalGrnt') != null) {
           GrntData += aggrResult[0].get('mayTotalGrnt') + ',';
           if((Double)aggrResult[0].get('mayTotalGrnt') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('mayTotalGrnt');  
       }
       else
           GrntData += 0.0 + ',';
       
       if(aggrResult[0].get('juneTotalGrnt') != null){
           GrntData += aggrResult[0].get('juneTotalGrnt') + ',';
           if((Double)aggrResult[0].get('juneTotalGrnt') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('juneTotalGrnt');  
       } 
       else
           GrntData += 0.0 + ',';
       
       if(aggrResult[0].get('julyTotalGrnt') != null){
           GrntData += aggrResult[0].get('julyTotalGrnt') + ',';
           if((Double)aggrResult[0].get('julyTotalGrnt') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('julyTotalGrnt');
       } 
       else
           GrntData += 0.0 + ',';
       
       if(aggrResult[0].get('augTotalGrnt') != null) {
           GrntData += aggrResult[0].get('augTotalGrnt') + ',';
           if((Double)aggrResult[0].get('augTotalGrnt') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('augTotalGrnt');
       }
       else
           GrntData += 0.0 + ',';    
       
       if(aggrResult[0].get('sepTotalGrnt') != null){
           GrntData += aggrResult[0].get('sepTotalGrnt') + ',';
           if((Double)aggrResult[0].get('sepTotalGrnt') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('sepTotalGrnt');
       }
       else
           GrntData += 0.0 + ',';
       
       if(aggrResult[0].get('octTotalGrnt') != null){
           GrntData += aggrResult[0].get('octTotalGrnt') + ',';
           if((Double)aggrResult[0].get('octTotalGrnt') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('octTotalGrnt');
       } 
       else
           GrntData += 0.0 + ',';
       
       if(aggrResult[0].get('novTotalGrnt') != null){
           GrntData += aggrResult[0].get('novTotalGrnt') + ',';
           if((Double)aggrResult[0].get('novTotalGrnt') > maxvalue)
              maxvalue = (Double)aggrResult[0].get('novTotalGrnt');
       }
       else
           GrntData += 0.0 + ',';
       
       if(aggrResult[0].get('decTotalGrnt') != null) {
           GrntData += aggrResult[0].get('decTotalGrnt') + ','; 
           if((Double)aggrResult[0].get('decTotalGrnt') > maxvalue)
              maxvalue = (Double)aggrResult[0].get('decTotalGrnt');
       }
       else
           GrntData += 0.0 + ',';   
               
       if(GrntData.length()>0){
           GrntData = GrntData.substring(0,GrntData.length()-1);
       }
  
       if(aggrResult[0].get('janTotal') != null){
           ActlData += aggrResult[0].get('janTotal') + ',';
           if((Double)aggrResult[0].get('janTotal') > maxvalue)
              maxvalue = (Double)aggrResult[0].get('janTotal');
       }           
       else
           ActlData += 0.0 + ',';
       
       if(aggrResult[0].get('febTotal') != null) {
           ActlData += aggrResult[0].get('febTotal') + ','; 
           if((Double)aggrResult[0].get('febTotal') > maxvalue)
              maxvalue = (Double)aggrResult[0].get('febTotal');
       }
       else
           ActlData += 0.0 + ',';
       
       if(aggrResult[0].get('marTotal') != null){
           ActlData += aggrResult[0].get('marTotal') + ',';
           if((Double)aggrResult[0].get('marTotal') > maxvalue)
              maxvalue = (Double)aggrResult[0].get('marTotal');
       }
       else
           ActlData += 0.0 + ',';
       
       if(aggrResult[0].get('aprTotal') != null){
           ActlData += aggrResult[0].get('aprTotal') + ',';           
           if((Double)aggrResult[0].get('aprTotal') > maxvalue)
              maxvalue = (Double)aggrResult[0].get('aprTotal');
       }    
       else
           ActlData += 0.0 + ',';
       
       if(aggrResult[0].get('mayTotal') != null) {
           ActlData += aggrResult[0].get('mayTotal') + ',';
           if((Double)aggrResult[0].get('mayTotal') > maxvalue)
              maxvalue = (Double)aggrResult[0].get('mayTotal');
       }
       else
           ActlData += 0.0 + ',';
       
       if(aggrResult[0].get('juneTotal') != null) {
           ActlData += aggrResult[0].get('juneTotal') + ','; 
           if((Double)aggrResult[0].get('juneTotal') > maxvalue)
              maxvalue = (Double)aggrResult[0].get('juneTotal');
       }
       else
           ActlData += 0.0 + ',';
       
       if(aggrResult[0].get('julyTotal') != null) {
           ActlData += aggrResult[0].get('julyTotal') + ',';
           if((Double)aggrResult[0].get('julyTotal') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('julyTotal');    
       }
       else
           ActlData += 0.0 + ',';
       
       if(aggrResult[0].get('augTotal') != null){
           ActlData += aggrResult[0].get('augTotal') + ',';
           if((Double)aggrResult[0].get('augTotal') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('augTotal'); 
       } 
       else
           ActlData += 0.0 + ',';   
       
       if(aggrResult[0].get('sepTotal') != null) {
           ActlData += aggrResult[0].get('sepTotal') + ',';
           if((Double)aggrResult[0].get('sepTotal') > maxvalue)
               maxvalue = (Double)aggrResult[0].get('sepTotal'); 
       }
       else
           ActlData += 0.0 + ',';
       
       if(aggrResult[0].get('octTotal') != null) {
           ActlData += aggrResult[0].get('octTotal') + ',';
           if((Double)aggrResult[0].get('octTotal') > maxvalue)
              maxvalue =(Double)aggrResult[0].get('octTotal'); 
       }
       else
           ActlData += 0.0 + ','; 
       
       if(aggrResult[0].get('novTotal') != null) {
           ActlData += aggrResult[0].get('novTotal') + ',';
           if((Double)aggrResult[0].get('novTotal') > maxvalue)
              maxvalue =(Double)aggrResult[0].get('novTotal'); 
       }
       else
           ActlData += 0.0 + ',';
       
       if(aggrResult[0].get('decTotal') != null) {
           ActlData += aggrResult[0].get('decTotal') + ','; 
           if((Double)aggrResult[0].get('decTotal') > maxvalue)
             maxvalue = (Double)aggrResult[0].get('decTotal'); 
       }
       else
           ActlData += 0.0 + ',';
       
       if(ActlData.length()>0) {
           ActlData = ActlData.substring(0,ActlData.length()-1);
       } 
       
   
       graphmax = Integer.valueOf(maxvalue);
       if(graphmax == 0)
           graphmax = 100;
       graphmin = Integer.valueOf(maxvalue/10);
        
       String strGrntURL = '';
       String chartURL =  '&amp;chtt=Guaranteed+vs+Actual+Production' 
         + '&chts=000000,12,c'
         + '&amp;chxt=x,y' 
         + '&amp;chxr=0,0,11,1|1,0,'+ graphmax + ',' +  graphmin                 //25000,2500
         + '&amp;cht=lc'
         + '&amp;chxl=0:|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec'     
         + '&chd=t:' + GrntData + '|' + ActlData
         + '&chds=0,' + graphmax                                                 //'&chds=0,25000'
         + '&chco=009DDC,61AF3F'
         + '&chdl=Guaranteed%20Production|Actual%20Production';
         
         // strGrntURL += '&chma=10,10,50,10|80,20';
       
         strGrntURL = chartURL;
         return strGrntURL;
         
    } 
*/    
   
   /* method for getting production summary into pieChart
    public string getPiecChartURL(){    
        integer noOfOverPerf = 0; 
        integer noOfUnderPerf = 0;  
        integer noOfProPerf = 0; 
        String chd = '';    
        String chl = '';
        string chco = '61AF3F,707274,009DDC';
    
        List<Installed_System__c> listSysProd = new List<Installed_System__c>();
        listSysProd = [select (select Annual_Guarantee_vs_Actual_Prod_To_Date__c,Year__c from Annual_Production__r where Year__c = 2011) from Installed_System__c];                
      
        for(Installed_System__c item : listSysProd) {
                Double itemvalue = (item.Annual_Production__r[0].Annual_Guarantee_vs_Actual_Prod_To_Date__c);
               
            if(item.Annual_Production__r != null && item.Annual_Production__r.size()>0 && item.Annual_Production__r[0].Annual_Guarantee_vs_Actual_Prod_To_Date__c != null) {        
               
                if(itemvalue > 5)
                    noOfOverPerf = noOfOverPerf + 1; 
                else if(itemvalue < -5)   
                    noOfUnderPerf = noOfUnderPerf + 1;
                else if((itemvalue >= -5) && (itemvalue <= 5))    
                    noOfProPerf =  noOfProPerf + 1; 
            }             
        }
        
        if(noOfOverPerf > 0) {
           
            chd +=  String.ValueOf(noOfOverPerf) + ',';
            chl +=  'Over Producing >= 5%[' + noOfOverPerf+ ']|';
        }
        if(noOfUnderPerf > 0) {
           
            chd +=  String.ValueOf(noOfUnderPerf) + ',';
            chl +=  'Under Producing >= 5%[' + noOfUnderPerf + ']|';
        }      
        if(noOfProPerf > 0) {
          
            chd +=  String.ValueOf(noOfProPerf ) + ',';
            chl +=  'On%20Target%20%2B%2F-%205%25['+ noOfProPerf + ']|';
        }
        
        if(chd.length()>0)
            chd = chd.substring(0, chd.length() -1);
        if(chl.length()>0)
            chl = chl.substring(0, chl.length() -1);
       
        String result = '&chd=t:' + chd + '&chl=' + chl + '&chts=000000,12,c' +'&chco=' + chco + '&chma=10,10,50,50';        
        String chartPath = '&cht=p3&chtt=Calendar+Year+2011|Production+Overview' + result ;

        return chartPath;
    }*/
    
/* TCM    
    // - method for getting SRECs data - 
    public string getSRECChartURL(){
    
        List<Installed_System__c> listInstSys;       
        String strfirstset = '';
        String strsecondset = '';       
        integer graphmax = 0;
        integer graphmin = 0;
        
       
       
        listInstSys = [Select Id, (Select January_Projected_SRECs__c, February_Projected_SRECs__c, 
                      March_Projected_SRECs__c, April_Projected_SRECs__c, May_Projected_SRECs__c, 
                      June_Projected_SRECs__c, July_Projected_SRECs__c, August_Projected_SRECs__c, 
                      September_Projected_SRECs__c, October_Projected_SRECs__c, 
                      November_Projected_SRECs__c, December_Projected_SRECs__c, 
                      January_SRECs_Generated__c, February_SRECs_Generated__c, 
                      March_SRECs_Generated__c, April_SRECs_Generated__c, 
                      May_SRECs_Generated__c, June_SRECs_Generated__c, 
                      July_SRECs_Generated__c, August_SRECs_Generated__c, 
                      September_SRECs_Generated__c, October_SRECs_Generated__c, 
                      November_SRECs_Generated__c, December_SRECs_Generated__c 
                      From Annual_Production__r where Year__c = 2011 limit 1) 
                      From Installed_System__c ];
                      
        Map<String,Double> totalActlSREC = new Map<String,Double>();
        Map<String,Double> totalExpSREC = new Map<String,Double>();
        // mothly SRECs variables 
        Double janProjSREC = 0.0;
        Double febProjSREC = 0.0;
        Double marProjSREC = 0.0;
        Double aprProjSREC = 0.0;
        Double mayProjSREC = 0.0;
        Double junProjSREC = 0.0;
        Double julProjSREC = 0.0;
        Double augProjSREC = 0.0;
        Double sepProjSREC = 0.0;
        Double octProjSREC = 0.0;
        Double novProjSREC = 0.0;
        Double decProjSREC = 0.0;
        Double janSRECGen = 0.0;
        Double febSRECGen = 0.0;
        Double marSRECGen = 0.0;
        Double aprSRECGen = 0.0;
        Double maySRECGen = 0.0;
        Double junSRECGen = 0.0;
        Double julSRECGen = 0.0;
        Double augSRECGen = 0.0;
        Double sepSRECGen = 0.0;
        Double octSRECGen = 0.0;
        Double novSRECGen = 0.0;
        Double decSRECGen = 0.0;
        Map<String, Double> cumulativeMonthSRECs = new Map<String, Double>();
         Map<String, Double> cumulativeMonthSRECs_Generated = new Map<String, Double>();
        for(Installed_System__c item : listInstSys){   
        
            if(item.Annual_Production__r != null && item.Annual_Production__r.size()>0) {
                
                Double currentSI_JanSREC = 0;
                Double currentSI_FebSREC = 0;
                Double currentSI_MarSREC = 0;
                Double currentSI_AprSREC = 0;
                Double currentSI_MaySREC = 0;
                Double currentSI_JunSREC = 0;
                Double currentSI_JulSREC = 0;
                Double currentSI_AugSREC = 0;
                Double currentSI_SepSREC = 0;
                Double currentSI_OctSREC = 0;
                Double currentSI_NovSREC = 0;
                Double currentSI_DecSREC = 0;
                // get mothly projected srec date

                if(item.Annual_Production__r[0].January_Projected_SRECs__c != null) {
                      Double prevCumulativeJanSRECs = 0;                       
                      currentSI_JanSREC = item.Annual_Production__r[0].January_Projected_SRECs__c;  
                     
                      if(cumulativeMonthSRECs.containsKey('Jan'))
                      {
                          prevCumulativeJanSRECs = cumulativeMonthSRECs.get('Jan'); 
                        
                      }                     
                      
                      prevCumulativeJanSRECs +=currentSI_JanSREC ;  
                      cumulativeMonthSRECs.put('Jan', prevCumulativeJanSRECs );     
                  }
                  
                if(item.Annual_Production__r[0].February_Projected_SRECs__c != null) {

                      Double prevCumulativeFebSRECs = 0;                       
                      currentSI_FebSREC = currentSI_JanSREC + item.Annual_Production__r[0].February_Projected_SRECs__c ;  
                     
                      if(cumulativeMonthSRECs.containsKey('Feb'))
                      {
                          prevCumulativeFebSRECs= cumulativeMonthSRECs.get('Feb'); 
                        
                      }                      
           
                      prevCumulativeFebSRECs+=currentSI_FebSREC ;  
                      cumulativeMonthSRECs.put('Feb', prevCumulativeFebSRECs ); 
                 }

                 if(item.Annual_Production__r[0].March_Projected_SRECs__c != null)  {
               
                      Double prevCumulativeMarSRECs = 0;                       
                      currentSI_MarSREC = currentSI_FebSREC + item.Annual_Production__r[0].March_Projected_SRECs__c;  
                     
                      if(cumulativeMonthSRECs.containsKey('Mar'))
                      {
                          prevCumulativeMarSRECs = cumulativeMonthSRECs.get('Mar'); 
                        
                      }
                      prevCumulativeMarSRECs +=currentSI_MarSREC ;  
                      cumulativeMonthSRECs.put('Mar', prevCumulativeMarSRECs ); 
                 }

                if(item.Annual_Production__r[0].April_Projected_SRECs__c != null)  { 

                      Double prevCumulativeAprSRECs = 0;                       
                      currentSI_AprSREC = currentSI_MarSREC  + item.Annual_Production__r[0].April_Projected_SRECs__c;  
                     
                      if(cumulativeMonthSRECs.containsKey('Apr'))
                      {
                          prevCumulativeAprSRECs = cumulativeMonthSRECs.get('Apr'); 
                        
                      }
                      
               
                      prevCumulativeAprSRECs +=currentSI_AprSREC ;  
                      cumulativeMonthSRECs.put('Apr', prevCumulativeAprSRECs ); 

                }
                
                if(item.Annual_Production__r[0].May_Projected_SRECs__c != null) {
                

                      Double prevCumulativeMaySRECs = 0;                       
                      currentSI_MaySREC = currentSI_AprSREC  + item.Annual_Production__r[0].May_Projected_SRECs__c; 
                      
                      if(cumulativeMonthSRECs.containsKey('May'))
                      {
                          prevCumulativeMaySRECs = cumulativeMonthSRECs.get('May'); 
                        
                      }
                      
                      prevCumulativeMaySRECs +=currentSI_MaySREC ;  
                      cumulativeMonthSRECs.put('May', prevCumulativeMaySRECs ); 
                }

                if(item.Annual_Production__r[0].June_Projected_SRECs__c != null) 
                {

                   Double prevCumulativeJunSRECs = 0;                       
                       currentSI_JunSREC = currentSI_MaySREC  + item.Annual_Production__r[0].June_Projected_SRECs__c;  
                     
                      if(cumulativeMonthSRECs.containsKey('Jun'))
                      {
                          prevCumulativeJunSRECs = cumulativeMonthSRECs.get('Jun'); 
                        
                      }
                      
               
                      prevCumulativeJunSRECs +=currentSI_JunSREC ;  
                      cumulativeMonthSRECs.put('Jun', prevCumulativeJunSRECs ); 
                      //janProjSREC+=janProjSREC;                  
              

                }

                if(item.Annual_Production__r[0].July_Projected_SRECs__c != null) {
                   //julProjSREC += junProjSREC + item.Annual_Production__r[0].July_Projected_SRECs__c; 
                                     
                      Double prevCumulativeJulSRECs = 0;                       
                      currentSI_JulSREC = currentSI_JunSREC + item.Annual_Production__r[0].July_Projected_SRECs__c;  
                     
                      if(cumulativeMonthSRECs.containsKey('Jul'))
                      {
                          prevCumulativeJulSRECs = cumulativeMonthSRECs.get('Jul'); 
                        
                      }
                      
               
                      prevCumulativeJulSRECs +=currentSI_JulSREC ;  
                      cumulativeMonthSRECs.put('Jul', prevCumulativeJulSRECs ); 
                      //janProjSREC+=janProjSREC;                  

                }
                  
                if(item.Annual_Production__r[0].August_Projected_SRECs__c != null)                             
                 {
                     //augProjSREC +=  item.Annual_Production__r[0].August_Projected_SRECs__c; 
                    
                      Double prevCumulativeAugSRECs = 0;                       
                      currentSI_AugSREC = currentSI_JulSREC + item.Annual_Production__r[0].August_Projected_SRECs__c;  
                     
                      if(cumulativeMonthSRECs.containsKey('Aug'))
                      {
                          prevCumulativeAugSRECs = cumulativeMonthSRECs.get('Aug'); 
                        
                      }
                      
               
                      prevCumulativeAugSRECs += currentSI_AugSREC;  
                      cumulativeMonthSRECs.put('Aug', prevCumulativeAugSRECs ); 
                      //janProjSREC+=janProjSREC;                  

                }
                  
                
                if(item.Annual_Production__r[0].September_Projected_SRECs__c != null) 
                {
                   //sepProjSREC += augProjSREC + item.Annual_Production__r[0].September_Projected_SRECs__c;
                   
                    Double prevCumulativeSepSRECs = 0;                       
                      currentSI_SepSREC = currentSI_AugSREC + item.Annual_Production__r[0].September_Projected_SRECs__c;  
                      
                      if(cumulativeMonthSRECs.containsKey('Sep'))
                      {
                          prevCumulativeSepSRECs= cumulativeMonthSRECs.get('Sep'); 
                        
                      }
                      
                      prevCumulativeSepSRECs+= currentSI_SepSREC ;  
                      cumulativeMonthSRECs.put('Sep', prevCumulativeSepSRECs); 
                      //janProjSREC+=janProjSREC;                  
               

                }

                if(item.Annual_Production__r[0].October_Projected_SRECs__c != null) 
                {
                    //octProjSREC += sepProjSREC + item.Annual_Production__r[0].October_Projected_SRECs__c;
                     //System.debug('octProjSREC '+ octProjSREC );
                     
                     Double prevCumulativeOctSRECs = 0;                       
                     currentSI_OctSREC = currentSI_SepSREC  + item.Annual_Production__r[0].October_Projected_SRECs__c;  
                      
                      if(cumulativeMonthSRECs.containsKey('Oct'))
                      {
                          prevCumulativeOctSRECs= cumulativeMonthSRECs.get('Oct'); 
                        
                      }
                      
               
                      prevCumulativeOctSRECs+= currentSI_OctSREC ;  
                      cumulativeMonthSRECs.put('Oct', prevCumulativeOctSRECs); 
                      //janProjSREC+=janProjSREC;                  

                }
                
                if(item.Annual_Production__r[0].November_Projected_SRECs__c != null) 
                {
                   
                     Double prevCumulativeNovSRECs = 0;                       
                     currentSI_NovSREC = currentSI_OctSREC + item.Annual_Production__r[0].November_Projected_SRECs__c;  
                      
                      if(cumulativeMonthSRECs.containsKey('Nov'))
                      {
                          prevCumulativeNovSRECs= cumulativeMonthSRECs.get('Nov'); 
                        
                      }

                      prevCumulativeNovSRECs+= currentSI_NovSREC ;  
                      cumulativeMonthSRECs.put('Nov', prevCumulativeNovSRECs); 
                      //janProjSREC+=janProjSREC;                  
                }

                if(item.Annual_Production__r[0].December_Projected_SRECs__c != null) 
                   {

                      //decProjSREC += item.Annual_Production__r[0].December_Projected_SRECs__c;   
                     Double prevCumulativeDecSRECs = 0;                       
                     currentSI_DecSREC = currentSI_NovSREC + item.Annual_Production__r[0].December_Projected_SRECs__c;  
                      
                      if(cumulativeMonthSRECs.containsKey('Dec'))
                      {
                          prevCumulativeDecSRECs= cumulativeMonthSRECs.get('Dec'); 
                        
                      }
                      
                      prevCumulativeDecSRECs+= currentSI_DecSREC ;  
                      cumulativeMonthSRECs.put('Dec', prevCumulativeDecSRECs); 
                      //janProjSREC+=janProjSREC;                  
                }
                  
//New Code - Starts

                currentSI_JanSREC = 0;
                currentSI_FebSREC = 0;
                currentSI_MarSREC = 0;
                currentSI_AprSREC = 0;
                currentSI_MaySREC = 0;
                currentSI_JunSREC = 0;
                currentSI_JulSREC = 0;
                currentSI_AugSREC = 0;
                currentSI_SepSREC = 0;
                currentSI_OctSREC = 0;
                currentSI_NovSREC = 0;
                currentSI_DecSREC = 0;
                // get mothly projected srec date
                
               //  if(item.Annual_Production__r[0].!= null){
               //   janSRECGen += item.Annual_Production__r[0].January_SRECs_Generated__c;
               //}
                
                if(item.Annual_Production__r[0].January_SRECs_Generated__c != null)   
                {      
                      Double prevCumulativeJanSRECs = 0;                       
                      currentSI_JanSREC = item.Annual_Production__r[0].January_SRECs_Generated__c ;  
                      
                      if(cumulativeMonthSRECs_Generated.containsKey('Jan'))
                      {
                          prevCumulativeJanSRECs = cumulativeMonthSRECs_Generated.get('Jan'); 
                        
                      }
                      
                      prevCumulativeJanSRECs +=currentSI_JanSREC ;  
                      cumulativeMonthSRECs_Generated.put('Jan', prevCumulativeJanSRECs ); 
                      //janProjSREC+=janProjSREC;                  
                      
                  }
*/
                  
                  /*
                    if(item.Annual_Production__r[0].February_SRECs_Generated__c != null){
                  febSRECGen += janSRECGen + item.Annual_Production__r[0].February_SRECs_Generated__c;
                    
                }
              
                if(item.Annual_Production__r[0].February_SRECs_Generated__c != null) 
                {

                      Double prevCumulativeFebSRECs = 0;                       
                      currentSI_FebSREC = currentSI_JanSREC + item.Annual_Production__r[0].February_SRECs_Generated__c ;  
                   
                      if(cumulativeMonthSRECs_Generated.containsKey('Feb'))
                      {
                          prevCumulativeFebSRECs= cumulativeMonthSRECs_Generated.get('Feb'); 
                        
                      }
                      
                      prevCumulativeFebSRECs+=currentSI_FebSREC ;  
                      cumulativeMonthSRECs_Generated.put('Feb', prevCumulativeFebSRECs ); 
                      //janProjSREC+=janProjSREC;                  

                }

                if(item.Annual_Production__r[0].March_SRECs_Generated__c != null) {
                   marSRECGen += febSRECGen + item.Annual_Production__r[0].March_SRECs_Generated__c;
                       
                } 
                */

/* TCM
                if(item.Annual_Production__r[0].March_SRECs_Generated__c != null) 
                {

                      Double prevCumulativeMarSRECs = 0;                       
                       currentSI_MarSREC = currentSI_FebSREC + item.Annual_Production__r[0].March_SRECs_Generated__c ;  
                     
                      if(cumulativeMonthSRECs_Generated.containsKey('Mar'))
                      {
                          prevCumulativeMarSRECs = cumulativeMonthSRECs_Generated.get('Mar'); 
                        
                      }
                      
               
                      prevCumulativeMarSRECs +=currentSI_MarSREC ;  
                      cumulativeMonthSRECs_Generated.put('Mar', prevCumulativeMarSRECs ); 
                      //janProjSREC+=janProjSREC;                  
 
                }

                if(item.Annual_Production__r[0].April_SRECs_Generated__c!= null)
                { 

                   Double prevCumulativeAprSRECs = 0;                       
                       currentSI_AprSREC = currentSI_MarSREC  + item.Annual_Production__r[0].April_SRECs_Generated__c;  
                     
                      if(cumulativeMonthSRECs_Generated.containsKey('Apr'))
                      {
                          prevCumulativeAprSRECs = cumulativeMonthSRECs_Generated.get('Apr'); 
                        
                      }
                      
             
                      prevCumulativeAprSRECs +=currentSI_AprSREC ;  
                      cumulativeMonthSRECs_Generated.put('Apr', prevCumulativeAprSRECs ); 

                }
                
                if(item.Annual_Production__r[0].May_SRECs_Generated__c != null) 
                {

                      Double prevCumulativeMaySRECs = 0;                       
                      currentSI_MaySREC = currentSI_AprSREC  + item.Annual_Production__r[0].May_SRECs_Generated__c;  
                     
                      if(cumulativeMonthSRECs_Generated.containsKey('May'))
                      {
                          prevCumulativeMaySRECs = cumulativeMonthSRECs_Generated.get('May'); 
                        
                      }
                      
                      prevCumulativeMaySRECs +=currentSI_MaySREC;
                      cumulativeMonthSRECs_Generated.put('May', prevCumulativeMaySRECs ); 

                }

                if(item.Annual_Production__r[0].June_SRECs_Generated__c != null) 
                {

                      Double prevCumulativeJunSRECs = 0;                       
                      currentSI_JunSREC = currentSI_MaySREC  + item.Annual_Production__r[0].June_SRECs_Generated__c ;  
                      
                      if(cumulativeMonthSRECs_Generated.containsKey('Jun'))
                      {
                          prevCumulativeJunSRECs = cumulativeMonthSRECs_Generated.get('Jun'); 
                        
                      }
                      
              
                      prevCumulativeJunSRECs +=currentSI_JunSREC ;  
                      cumulativeMonthSRECs_Generated.put('Jun', prevCumulativeJunSRECs ); 

                }

                if(item.Annual_Production__r[0].July_SRECs_Generated__c != null) {
                   //julProjSREC += junProjSREC + item.Annual_Production__r[0].July_Projected_SRECs__c; 
                                     
                      Double prevCumulativeJulSRECs = 0;                       
                      currentSI_JulSREC = currentSI_JunSREC + item.Annual_Production__r[0].July_SRECs_Generated__c;  
                     
                      if(cumulativeMonthSRECs_Generated.containsKey('Jul'))
                      {
                          prevCumulativeJulSRECs = cumulativeMonthSRECs_Generated.get('Jul'); 
                        
                      }

                      prevCumulativeJulSRECs +=currentSI_JulSREC ;  
                      cumulativeMonthSRECs_Generated.put('Jul', prevCumulativeJulSRECs );
                      
                }
                  
                if(item.Annual_Production__r[0].August_SRECs_Generated__c != null)                             
                 {
                     //augProjSREC +=  item.Annual_Production__r[0].August_Projected_SRECs__c; 
                    
                      Double prevCumulativeAugSRECs = 0;                       
                      currentSI_AugSREC = currentSI_JulSREC + item.Annual_Production__r[0].August_SRECs_Generated__c;  
                     
                      if(cumulativeMonthSRECs_Generated.containsKey('Aug'))
                      {
                          prevCumulativeAugSRECs = cumulativeMonthSRECs_Generated.get('Aug'); 
                        
                      }
                      

                      prevCumulativeAugSRECs += currentSI_AugSREC;  
                      cumulativeMonthSRECs_Generated.put('Aug', prevCumulativeAugSRECs ); 
                      //janProjSREC+=janProjSREC;                  

                }
                  
                
                if(item.Annual_Production__r[0].September_SRECs_Generated__c != null) 
                {
                   //sepProjSREC += augProjSREC + item.Annual_Production__r[0].September_Projected_SRECs__c;
                   
                      Double prevCumulativeSepSRECs = 0;                       
                      currentSI_SepSREC = currentSI_AugSREC + item.Annual_Production__r[0].September_SRECs_Generated__c;  
                      
                      if(cumulativeMonthSRECs_Generated.containsKey('Sep'))
                      {
                          prevCumulativeSepSRECs= cumulativeMonthSRECs_Generated.get('Sep'); 
                        
                      }

                      prevCumulativeSepSRECs+= currentSI_SepSREC ;  
                      cumulativeMonthSRECs_Generated.put('Sep', prevCumulativeSepSRECs); 
                      //janProjSREC+=janProjSREC;                  
               }

                if(item.Annual_Production__r[0].October_SRECs_Generated__c != null) 
                {

                     Double prevCumulativeOctSRECs = 0;                       
                     currentSI_OctSREC = currentSI_SepSREC  + item.Annual_Production__r[0].October_SRECs_Generated__c;  
                      
                      if(cumulativeMonthSRECs_Generated.containsKey('Oct'))
                      {
                          prevCumulativeOctSRECs= cumulativeMonthSRECs_Generated.get('Oct'); 
                        
                      }
                      
                  
                      prevCumulativeOctSRECs+= currentSI_OctSREC ;  
                      cumulativeMonthSRECs_Generated.put('Oct', prevCumulativeOctSRECs); 
                      //janProjSREC+=janProjSREC;                  

                }
                
                if(item.Annual_Production__r[0].November_SRECs_Generated__c != null) 
                {
 
                     Double prevCumulativeNovSRECs = 0;                       
                     currentSI_NovSREC = currentSI_OctSREC + item.Annual_Production__r[0].November_SRECs_Generated__c;  

                      if(cumulativeMonthSRECs_Generated.containsKey('Nov'))
                      {
                          prevCumulativeNovSRECs= cumulativeMonthSRECs_Generated.get('Nov'); 
                        
                      }
                      
                 
                      prevCumulativeNovSRECs+= currentSI_NovSREC ;  
                      cumulativeMonthSRECs_Generated.put('Nov', prevCumulativeNovSRECs); 
                      //janProjSREC+=janProjSREC;                  

                }

                if(item.Annual_Production__r[0].December_SRECs_Generated__c != null) 
                  {
                      //decProjSREC += item.Annual_Production__r[0].December_Projected_SRECs__c;   
                     Double prevCumulativeDecSRECs = 0;                       
                     currentSI_DecSREC = currentSI_NovSREC + item.Annual_Production__r[0].December_SRECs_Generated__c;  
                     
                      if(cumulativeMonthSRECs_Generated.containsKey('Dec'))
                      {
                          prevCumulativeDecSRECs= cumulativeMonthSRECs_Generated.get('Dec'); 
                        
                      }
                      
                  
                      prevCumulativeDecSRECs+= currentSI_DecSREC ;  
                      cumulativeMonthSRECs_Generated.put('Dec', prevCumulativeDecSRECs); 
                      //janProjSREC+=janProjSREC;                  
 
                }
                  



//New Code - Ends 
            }  
       } 
       // Generate datapoint maps end 

       strfirstset =   cumulativeMonthSRECs.get('Jan')+ ',' + cumulativeMonthSRECs.get('Feb')  + ',' 
                     + cumulativeMonthSRECs.get('Mar') + ',' + cumulativeMonthSRECs.get('Apr') + ',' 
                     + cumulativeMonthSRECs.get('May') + ',' + cumulativeMonthSRECs.get('Jun') + ',' 
                     + cumulativeMonthSRECs.get('Jul')+ ',' + cumulativeMonthSRECs.get('Aug')+ ',' 
                     + cumulativeMonthSRECs.get('Sep')+ ',' + cumulativeMonthSRECs.get('Oct')
                     + ',' + cumulativeMonthSRECs.get('Nov')+ ',' + cumulativeMonthSRECs.get('Dec'); 
               
*/                     
      
      /* strsecondset = janSRECGen  + ',' + febSRECGen  + ',' + marSRECGen + ',' + aprSRECGen
                     + ',' + maySRECGen + ',' + junSRECGen + ',' + julSRECGen 
                     + ',' + augSRECGen + ',' + sepSRECGen + ',' + octSRECGen
                     + ',' + novSRECGen  + ',' + decSRECGen ;  */

/* TCM                     
                      strsecondset =   cumulativeMonthSRECs_Generated.get('Jan')+ ',' + cumulativeMonthSRECs_Generated.get('Feb')  + ',' 
                     + cumulativeMonthSRECs_Generated.get('Mar') + ',' + cumulativeMonthSRECs_Generated.get('Apr') + ',' 
                     + cumulativeMonthSRECs_Generated.get('May') + ',' + cumulativeMonthSRECs_Generated.get('Jun')  + ',' 
                     + cumulativeMonthSRECs_Generated.get('Jul')+ ',' + cumulativeMonthSRECs_Generated.get('Aug')+ ',' 
                     + cumulativeMonthSRECs_Generated.get('Sep')+ ',' + cumulativeMonthSRECs_Generated.get('Oct')
                     + ',' + cumulativeMonthSRECs_Generated.get('Nov')+ ',' + cumulativeMonthSRECs_Generated.get('Dec'); 
            

        graphmax = calcMax(strfirstset ,strsecondset);      
        if(graphmax == 0)
            graphmax = 10;           
        graphmin = integer.valueOf(graphmax/10);

         // URL creation start       
         String chartURL = '&amp;chtt=Expected+vs+Actual+SRECs'
         + '&amp;chts=000000,12,c' 
         + '&amp;chxt=x,y'
         + '&amp;cht=lc'  
         + '&amp;chxr=0,0,11,1|1,0,'+ graphmax + ','+  graphmin 
         + '&amp;chxl=0:|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec'
         + '&amp;chma=10,10,50,10|80,20';         
         chartURL += '&chd=t:' + strfirstset + '|' + strsecondset ;
         chartURL += '&chds=0,' + graphmax  ;                               // '&chds=0,10000'
         chartURL += '&chco=009DDC,61AF3F';
         chartURL += '&chdl=Expected%20SRECs|Actual%20SRECs';

         return(chartURL);
    } 
    
     public string getStateChartURL(){
    
       List<Installed_System__c> listInstSys;
       Annual_Production__c objAnnProd;
       Integer totalStates = 0;
       listInstSys = [Select State__c, (Select Annual_Production_Guarantee__c, Annl_Production__c From Annual_Production__r where Year__c = 2011 limit 1) From Installed_System__c order by State__c];
       Map<String,Double> totalGrntProd = new Map<String,Double>();
       Map<String,Double> totalAnnlProd = new Map<String,Double>();
       string chxl = '';
       string strgrntdata = '';
       string stractldata = ''; 
       integer graphmax = 0;
       integer graphmin = 0;
       
       // Generate datapoint maps start
       for(Installed_System__c item : listInstSys){

            Double grntVal = 0.0;
            Double annlVal = 0.0;
                
            if(item.Annual_Production__r != null && item.Annual_Production__r.size()>0) {
                   objAnnProd =  item.Annual_Production__r[0]; 
                                   
                       if(objAnnProd.Annual_Production_Guarantee__c!= null){
                           grntVal = objAnnProd.Annual_Production_Guarantee__c;
                       }
                       if(objAnnProd.Annl_Production__c != null){
                           annlVal = objAnnProd.Annl_Production__c ;
                       }
                       
                        
               } 
           
           if(totalGrntProd.containsKey(item.State__c)) {              
               totalGrntProd.put(item.State__c, totalGrntProd.get(item.State__c) + grntVal);            
                
           } else {           
               totalGrntProd.put(item.State__c, grntVal);                                
           }

           if(totalAnnlProd.containsKey(item.State__c)) {              
               totalAnnlProd.put(item.State__c, totalAnnlProd.get(item.State__c)+ annlVal );            
                
           } else {           
               totalAnnlProd.put(item.State__c, annlVal);                                
           }
        } 
       // Generate datapoint maps end 
	   // get total states 
        totalStates =  totalGrntProd.size() - 1;
        
        for(String item : totalGrntProd.keySet())
            strgrntdata += totalGrntProd.get(item) + ',';     
        for(String item : totalAnnlProd.keySet()){
            stractldata +=  totalAnnlProd.get(item) + ',';
            chxl += item + '|';
        }     
     
     
        if(strgrntdata.length() > 0)
            strgrntdata = strgrntdata.substring(0, strgrntdata.length() -1);        
        if(stractldata.length() > 0)
            stractldata = stractldata.substring(0, stractldata.length() -1);                    
        if(chxl.length() > 0)
            chxl = chxl.substring(0, chxl.length() -1);
         
       
       // URL creation Strat 
       
       // calc range for graph 
        graphmax = calcMax(strgrntdata ,stractldata);      
        if(graphmax == 0)
            graphmax = 10;   
        graphmin = integer.valueOf(graphmax/10); 
        // calc range for graph 
        
         String chartURL = '&amp;chtt=Guarantee+vs+Actual+Production+by+State' 
         + '&chts=000000,12,c'
         + '&chbh=a,5,10'
         + '&chxt=x,y'
         + '&cht=bvg'         
         + '&amp;chxr=0,0,' + totalStates  + ',1|1,0,'+ graphmax + ',' + graphmin                            
         //+ '&amp;chma=10,10,50,10|80,20';
         + '&chxl=0:|' + chxl         
         + '&chd=t:' + strgrntdata + '|' + stractldata
         + '&chds=0,'+ graphmax
         + '&chco=009DDC,61AF3F'        
         + '&chdl=Guaranteed%20Production|Actual%20Production';
           
         return(chartURL); 
    }
    
	//This method returns the encoding type parameter value that 
	//matches the specified encoding type. 
    public static String getEncodingDescriptor(EncodingType t) {
        if(t == EncodingType.TEXT) return 't';
        else if(t == EncodingType.SIMPLE) return 's';
        else if(t == EncodingType.EXTENDED) return 'e';
        else return '';
     }
     
     // scaling chnages 
      public Integer calcMax(string strfirstset, string strsecondset) {
        Double maxval = 0;
        
        List<String> listpoints =  strfirstset.split(',');        
        for(string tempstr : listpoints) {
            if(Double.valueOf(tempstr) > maxval)
                maxval = Double.valueOf(tempstr);        
        } 
        
        listpoints = strsecondset.split(',');
        for(string tempstr : listpoints) {
            if(Double.valueOf(tempstr) > maxval)
                maxval = Double.valueOf(tempstr);
        }         
                 
        return(integer.valueOf(maxval)+ 10 );
     }
     //scaling chnages
*/    
     
}