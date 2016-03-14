/* FILE: InstalledSystemsChartsController.cls
 * AUTHOR: Tino Mattheou
 * DATE: July 26, 2012
 * PURPOSE: Controller for InstalledSystemsCharts component 
 *          Retrieves trailing 12 months of annual production data
 *          for installed systems qwith guarantees
 * MODIFICATION HISTORY:
 *
 */

public class InstalledSystemsChartsController {

	public List<GuaranteeData> getguarVsActual() {

		//calculate the relevant dates for TTM
		Integer thisYear = Date.today().year();
		Integer lastYear = thisYear - 1;
		Date endOf12Months = Date.today().toStartOfMonth(); //exclusive
		Date startOf12Months = endOf12Months.addYears(-1);
		
		//initialize the result and month multipliers
		GuaranteeData[] result = new GuaranteeData[12];
		for (Integer i = 1; i <= 12; i++) {
			result[i - 1] = new GuaranteeData(i);
			result[i - 1].iyear = Date.newInstance(lastYear, i, 1) >= startOf12Months ? lastYear : thisYear;   
		}
		
		AggregateResult[] annualProduction = 
			[SELECT 
				CALENDAR_YEAR(Start_of_Year__c) prodYear,
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
                SUM(January_Actual_Production_kWh__c) janTotal, 
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
			AND Annual_Production_Guarantee__c > 0
			AND ( Start_of_Year__c = THIS_YEAR
			OR Start_Of_Year__c = LAST_YEAR )

			GROUP BY CALENDAR_YEAR(Start_of_Year__c)];
	
		Integer prodYear;
		String guarField, actField, projSREC, genSREC;
		String[] month = new String[] {  'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec' };
			
		for (AggregateResult ap : annualProduction) {
		
			prodYear = (Integer)ap.get('prodYear');

			for (Integer i = 0; i < 12; i++) {
				guarField = month[i] + 'TotalGrnt';
				actField = month[i] + 'Total';
				projSREC = month[i] + 'projsrec';
				genSREC = month[i] + 'gensrec';
				if (((prodYear == lastYear && Date.newInstance(lastYear, i + 1, 1) >= startOf12Months)
				|| (prodYear == thisYear && Date.newInstance(thisYear, i + 1, 1) < endOf12Months))
				&& ap.get(guarField) != null && (Decimal)ap.get(guarField) > 0) {
					result[i].guarantee += (Decimal)ap.get(guarField);
					if (ap.get(actField) != null) {
						result[i].actual += (Decimal)ap.get(actField);
					}
                    //ASSUMPTION: if production guarantees are there, projected SRECs are also
					if (ap.get(projSREC) != null) {
						result[i].projSREC += (Decimal)ap.get(projSREC);
					}
					if (ap.get(genSREC) != null) {
						result[i].genSREC += (Decimal)ap.get(genSREC);
					}
				}
			}
			
		}
		
		//move this year to the back (sort)
		while (result[0].iYear == thisYear) {
			GuaranteeData gd = result.remove(0);
			result.add(gd);
		}
        
        //accumulate SRECS
        for (Integer i = 1; i < 12; i++) {
            result[i].projSREC += result[i - 1].projSREC;
            result[i].genSREC += result[i - 1].genSREC;
        }
		
		return result;

	}
    
    public List<StateProduction> getStateProd() {

        List<StateProduction> result = new List<StateProduction>();
        
		//calculate the relevant dates for TTM
		Integer thisYear = Date.today().year();
		Integer lastYear = thisYear - 1;
		Date endOf12Months = Date.today().toStartOfMonth(); //exclusive
		Date startOf12Months = endOf12Months.addYears(-1);
		
		Integer prodYear;
		String guarField, actField, state;
        Map<String, StateProduction> stateMap = new Map<String, StateProduction>();
		String[] month = new String[] {  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' };
			
		for (Annual_Production__c[] annualProduction : [SELECT 
				State__c,
				Year__c,
				/* Production guarantees */ 
				January_Production_Guarantee_kWh__c,
                February_Production_Guarantee_kWh__c,
                March_Production_Guarantee_kWh__c,
                April_Production_Guarantee_kWh__c, 
                May_Production_Guarantee_kWh__c,
                June_Production_Guarantee_kWh__c,
                July_Production_Guarantee_kWh__c, 
                August_Production_Guarantee_kWh__c, 
                September_Production_Guarantee_kWh__c,
                October_Production_Guarantee_kWh__c, 
                November_Production_Guarantee_kWh__c, 
                December_Production_Guarantee_kWh__c, 
				/* Actual Production */ 
                January_Actual_Production_kWh__c, 
                February_Actual_Production_kWh__c, 
                March_Actual_Production_kWh__c, 
                April_Actual_Production_kWh__c, 
                May_Actual_Production_kWh__c, 
                June_Actual_Production_kWh__c, 
                July_Actual_Production_kWh__c,
                August_Actual_Production_kWh__c,
                September_Actual_Production_kWh__c, 
                October_Actual_Production_kWh__c, 
                November_Actual_Production_kWh__c, 
                December_Actual_Production_kWh__c
			FROM Annual_Production__c
			WHERE Installed_System__r.Installation_Year__c != NULL 
			AND Installed_System__r.Generation_Start_Date__c != NULL
			AND Annual_Production_Guarantee__c > 0
			AND ( Start_of_Year__c = THIS_YEAR
			OR Start_Of_Year__c = LAST_YEAR )
            AND State__c <> NULL]) {
        
                for (Annual_Production__c ap : annualProduction) {
                 
                    prodYear = ((Decimal)ap.Year__c).intValue();
                    state = (String)ap.get('State__c');
                    StateProduction sp = stateMap.get(state);
                    if (sp == null) {
                        sp = new StateProduction(state);
                        stateMap.put(state, sp);
                        result.add(sp);
                    }
                        
                    for (Integer i = 0; i < 12; i++) {
                        guarField = month[i] + '_Production_Guarantee_kWh__c';
                        actField = month[i] + '_Actual_Production_kWh__c';
                        if (((prodYear == lastYear && Date.newInstance(lastYear, i + 1, 1) >= startOf12Months)
                        || (prodYear == thisYear && Date.newInstance(thisYear, i + 1, 1) < endOf12Months))
                        && ap.get(guarField) != null && (Decimal)ap.get(guarField) > 0) {
                            sp.guarantee += (Decimal)ap.get(guarField);
                            if (ap.get(actField) != null) {
                                sp.actual += (Decimal)ap.get(actField);
                            }
                        }
                    }
                    
                }
        }
		
		return result;

    }
    
    public SystemOverview getSystemOverview() {

		//calculate the relevant dates for TTM
		Integer thisYear = Date.today().year();
		Integer lastYear = thisYear - 1;
		Date endOf12Months = Date.today().toStartOfMonth(); //exclusive
		Date startOf12Months = endOf12Months.addYears(-1);
		
		Integer prodYear;
		String guarField, actField, sysId;
        Map<Id, StateProduction> systemMap = new Map<Id, StateProduction>();
		String[] month = new String[] {  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' };
			
		for (Annual_Production__c[] annualProduction : [SELECT 
				Installed_System__c,
				Year__c,
				/* Production guarantees */ 
				January_Production_Guarantee_kWh__c,
                February_Production_Guarantee_kWh__c,
                March_Production_Guarantee_kWh__c,
                April_Production_Guarantee_kWh__c, 
                May_Production_Guarantee_kWh__c,
                June_Production_Guarantee_kWh__c,
                July_Production_Guarantee_kWh__c, 
                August_Production_Guarantee_kWh__c, 
                September_Production_Guarantee_kWh__c,
                October_Production_Guarantee_kWh__c, 
                November_Production_Guarantee_kWh__c, 
                December_Production_Guarantee_kWh__c, 
				/* Actual Production */ 
                January_Actual_Production_kWh__c, 
                February_Actual_Production_kWh__c, 
                March_Actual_Production_kWh__c, 
                April_Actual_Production_kWh__c, 
                May_Actual_Production_kWh__c, 
                June_Actual_Production_kWh__c, 
                July_Actual_Production_kWh__c,
                August_Actual_Production_kWh__c,
                September_Actual_Production_kWh__c, 
                October_Actual_Production_kWh__c, 
                November_Actual_Production_kWh__c, 
                December_Actual_Production_kWh__c
			FROM Annual_Production__c
			WHERE Installed_System__r.Installation_Year__c != NULL 
			AND Installed_System__r.Generation_Start_Date__c != NULL
			AND Annual_Production_Guarantee__c > 0
			AND ( Start_of_Year__c = THIS_YEAR
			OR Start_Of_Year__c = LAST_YEAR )
        ]) {
        
                for (Annual_Production__c ap : annualProduction) {
                 
                    prodYear = ((Decimal)ap.Year__c).intValue();
                    sysId = ap.Installed_System__c;
                    StateProduction sp = systemMap.get(sysId);
                    if (sp == null) {
                        sp = new StateProduction(sysId);
                        systemMap.put(sysId, sp);
                    }

					//only counting guarantee if there's an actual                         
                    for (Integer i = 0; i < 12; i++) {
                        guarField = month[i] + '_Production_Guarantee_kWh__c';
                        actField = month[i] + '_Actual_Production_kWh__c';
                        if (((prodYear == lastYear && Date.newInstance(lastYear, i + 1, 1) >= startOf12Months)
                        || (prodYear == thisYear && Date.newInstance(thisYear, i + 1, 1) < endOf12Months))
                        && ap.get(guarField) != null && (Decimal)ap.get(guarField) > 0
                        && ap.get(actField) != null && (Decimal)ap.get(actField) > 0) {
                            sp.guarantee += (Decimal)ap.get(guarField);
							sp.actual += (Decimal)ap.get(actField);
                        }
                    }
                    
                }
        }
                
        SystemOverview result = new SystemOverview();
        for (StateProduction sp : systemMap.values()) {
            //ASSUMPTION guarantee is always more than 0
            Decimal pct = (sp.actual - sp.guarantee) / sp.guarantee;
            if (pct > 0.05) {
                result.overProducing++;
            } else if (pct < -0.05) {
                result.underProducing++;
            } else {
                result.onTarget++;
            }
        }

		return result;

    }
        
    public class SystemOverview {
        public SystemOverview() {
            underProducing = overProducing = onTarget = 0;
        }
        public Integer underProducing { get; set; }
        public Integer overProducing { get; set; }
        public Integer onTarget { get; set; }
    }
        
    public class StateProduction {
        public StateProduction(String state) {
            this.state = state;
            guarantee = actual = 0;
        }
        public String state { get; private set; }
		public Decimal guarantee { get; set; }
		public Decimal actual { get; set; }
    }
	
	public class GuaranteeData {
		public GuaranteeData(Integer month) {
			iMonth = month;
			guarantee = actual = projSREC = genSREC = 0;
		}
		private Integer iMonth;
		public Integer iYear;
		public String month { 
			get {
				//return DateTime.newInstance(iYear, iMonth, 1, 0, 0, 0).format('MMM yyyy');				
				return DateTime.newInstance(iYear, iMonth, 1, 0, 0, 0).format('MMM');				
			}
		}
		public Decimal guarantee { get; set; }
		public Decimal actual { get; set; }
        public Decimal projSREC { get; set; }
        public Decimal genSREC { get; set; }
	}

}