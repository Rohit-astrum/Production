/*
    12/30/14  DK  Replaced Math.round() with Math.floor()
*/
public without sharing class ProposalProcessor {
  //The methods in this class require a variety of SD, SDQ, and Proposal fields to be already queried. See the constructor in CPQproposalController for pertinent SOQL.

  public ProposalProcessor(){}

  private static String[] months = new String[] {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};

  //public Map<integer,double> annualCashFlow = new Map<integer,double>();
  //public Map<integer,double> annualFinPayment = new Map<integer,double>();  //DK 1-20-15. New calculation method created as replacement: getAnnualFinancingPayments().
  //public Map<integer,double> monthlyElectricityProduction = new Map<integer,double>();   //DK 1-19-15. New calculation method created as a replacement.
  //public Map<integer,double> annualAvoidedValue = new Map<integer,double>();    //DK 1-20-15. New calculation method created as a replacement.
 
  //public double cummulativecashFlow = 0;  //DK 1-14-15. New calculation method created as a replacement.

  public String createProposal(ID sdqID){  //DK
    System_Design_Quote__c sdq = new System_Design_Quote__c(ID = sdqID);
    return createProposal(sdq, false);
  }

  public String createProposal(System_Design_Quote__c sdq, Boolean makeCurrent)
  {
    return createProposal(sdq,makeCurrent,true,false,false,false, null);  
  }

  //If makeCurrent is true, then we set this new Proposal to Current__c = true and serialize its parent SDQ into a text field. See SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnComplete().
  public String createProposal(System_Design_Quote__c sdq, Boolean makeCurrent, Boolean scenario1 , Boolean scenario2, Boolean scenario3, Boolean scenario4, Integer daysUntilExpiration){
    Proposal__c prp = new Proposal__c();
    prp.System_Design_Quote__c = sdq.ID;
    prp.Scenario_1_Included__c = scenario1;
    prp.Scenario_2_Included__c = scenario2;
    prp.Scenario_3_Included__c = scenario3;
    prp.Scenario_4_Included__c = scenario4;

    sdq = [SELECT Utility_Annual_Increase__c,Annual_Electricity_Consumption_kWh__c, Forecasted_Add_Ann_Consumption_kW__c,System_Design__c,Property_State__c,Pricing_Date__c,System_Size_kW__c
          ,Scenario_1_Avoided_Utility_Rate__c,Scenario_2_Avoided_Utility_Rate__c,Scenario_3_Avoided_Utility_Rate__c,Scenario_4_Avoided_Utility_Rate__c
          ,Scenario_1_Total_Projected_Annual_Output__c,Scenario_2_Total_Projected_Annual_Output__c,Scenario_3_Total_Projected_Annual_Output__c,Scenario_4_Total_Projected_Annual_Output__c
          ,Scenario_1_Lease_Escalator__c,Scenario_2_Lease_Escalator__c,Scenario_3_Lease_Escalator__c,Scenario_4_Lease_Escalator__c
          ,Scenario_1_First_Month_Payment__c,Scenario_2_First_Month_Payment__c,Scenario_3_First_Month_Payment__c,Scenario_4_First_Month_Payment__c
          ,Scenario_1_Net_Initial_Outlay__c,Scenario_2_Net_Initial_Outlay__c,Scenario_3_Net_Initial_Outlay__c,Scenario_4_Net_Initial_Outlay__c
          ,Scenario_1_Final_EPC_Price_NUM__c,Scenario_2_Final_EPC_Price_NUM__c,Scenario_3_Final_EPC_Price_NUM__c,Scenario_4_Final_EPC_Price_NUM__c
          ,Scenario_1_Proposal_Term_Months__c,Scenario_2_Proposal_Term_Months__c,Scenario_3_Proposal_Term_Months__c,Scenario_4_Proposal_Term_Months__c
          ,Scenario_1_Included_in_Proposal__c,Scenario_2_Included_in_Proposal__c,Scenario_3_Included_in_Proposal__c,Scenario_4_Included_in_Proposal__c
          ,Scenario_1_Financing_Type__c,Scenario_2_Financing_Type__c,Scenario_3_Financing_Type__c,Scenario_4_Financing_Type__c
          ,Scenario_1_Term_Loan__r.Financing_Term_Months__c,Scenario_2_Term_Loan__r.Financing_Term_Months__c,Scenario_3_Term_Loan__r.Financing_Term_Months__c,Scenario_4_Term_Loan__r.Financing_Term_Months__c
          ,Scenario_1_Lease_Option__c,Scenario_2_Lease_Option__c,Scenario_3_Lease_Option__c,Scenario_4_Lease_Option__c
          ,Scenario_1_Installer_Paid_Incentive_Amt__c,Scenario_2_Installer_Paid_Incentive_Amt__c,Scenario_3_Installer_Paid_Incentive_Amt__c,Scenario_4_Installer_Paid_Incentive_Amt__c
          ,Scenario_1_Financing_Rate_Year_1_kWh__c, Scenario_2_Financing_Rate_Year_1_kWh__c, Scenario_3_Financing_Rate_Year_1_kWh__c, Scenario_4_Financing_Rate_Year_1_kWh__c
          ,Scenario_1_Down_Payment__c,Scenario_2_Down_Payment__c,Scenario_3_Down_Payment__c,Scenario_4_Down_Payment__c
          ,Scenario_1_FIT_Annual_Earnings_After_Tax__c,Scenario_2_FIT_Annual_Earnings_After_Tax__c,Scenario_3_FIT_Annual_Earnings_After_Tax__c,Scenario_4_FIT_Annual_Earnings_After_Tax__c 
          ,Scenario_1_FIT_Term_Length_Months__c,Scenario_2_FIT_Term_Length_Months__c,Scenario_3_FIT_Term_Length_Months__c,Scenario_4_FIT_Term_Length_Months__c 
          ,Scenario_1_SREC_Cash_Back__c,Scenario_2_SREC_Cash_Back__c,Scenario_3_SREC_Cash_Back__c,Scenario_4_SREC_Cash_Back__c 
          ,Scenario_1_Total_Net_Adjustment__c,Scenario_2_Total_Net_Adjustment__c,Scenario_3_Total_Net_Adjustment__c,Scenario_4_Total_Net_Adjustment__c 
           FROM System_Design_Quote__c 
          WHERE ID = :sdq.ID];
    
    if (sdq.System_Design__c == null)
      return 'The SDQ does not have a related System Design';
    
    System_Design__c sd = [Select Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c, Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c, Method_1_Jan_Peak_kWh__c,Method_1_Feb_Peak_kWh__c
                   ,Method_1_Mar_Peak_kWh__c,Method_1_Apr_Peak_kWh__c,Method_1_May_Peak_kWh__c,Method_1_Jun_Peak_kWh__c,Method_1_Jul_Peak_kWh__c,Method_1_Aug_Peak_kWh__c,Method_1_Sep_Peak_kWh__c
                   ,Method_1_Oct_Peak_kWh__c,Method_1_Nov_Peak_kWh__c,Method_1_Dec_Peak_kWh__c,Method_1_Jan_Part_Peak_kWh__c,Method_1_Feb_Part_Peak_kWh__c,Method_1_Mar_Part_Peak_kWh__c
                   ,Method_1_Apr_Part_Peak_kWh__c,Method_1_May_Part_Peak_kWh__c,Method_1_Jun_Part_Peak_kWh__c,Method_1_Jul_Part_Peak_kWh__c,Method_1_Aug_Part_Peak_kWh__c,Method_1_Sep_Part_Peak_kWh__c
                   ,Method_1_Oct_Part_Peak_kWh__c,Method_1_Nov_Part_Peak_kWh__c,Method_1_Dec_Part_Peak_kWh__c,Method_1_Jan_Off_Peak_kWh__c,Method_1_Feb_Off_Peak_kWh__c,Method_1_Mar_Off_Peak_kWh__c
                   ,Method_1_Apr_Off_Peak_kWh__c,Method_1_May_Off_Peak_kWh__c,Method_1_Jun_Off_Peak_kWh__c,Method_1_Jul_Off_Peak_kWh__c,Method_1_Aug_Off_Peak_kWh__c,Method_1_Sep_Off_Peak_kWh__c
                   ,Method_1_Oct_Off_Peak_kWh__c,Method_1_Nov_Off_Peak_kWh__c,Method_1_Dec_Off_Peak_kWh__c,Method_1_Jan_Flat_kWh__c,Method_1_Feb_Flat_kWh__c,Method_1_Mar_Flat_kWh__c,Method_1_Apr_Flat_kWh__c
                   ,Method_1_May_Flat_kWh__c,Method_1_Jun_Flat_kWh__c,Method_1_Jul_Flat_kWh__c,Method_1_Aug_Flat_kWh__c,Method_1_Sep_Flat_kWh__c,Method_1_Oct_Flat_kWh__c,Method_1_Nov_Flat_kWh__c,Method_1_Dec_Flat_kWh__c
                   ,Default_CB_Panel__r.Utility_Service__r.Method_1_Avoided_Utility_Rate__c,Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh__c,Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c
                   ,Total_Projected_Annual_Output_kWh_y__c,Default_CB_Panel__r.Utility_Service__r.First_Year_Remaining_Rate__c, Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Savings__c 
                   from System_Design__c 
                   where id = :sdq.System_Design__c];

    Map<String, Price_Adjustment__c> paMap = new Map<String, Price_Adjustment__c>();
    for (Price_Adjustment__c pa : [Select Guaranteed_Rate__c,Production_Guarantee__c,Applicable_Scenario__c From Price_Adjustment__c 
                                   Where System_Design_Quote__c = :sdq.id AND Production_Guarantee__c = true AND Applicable_Scenario__c != null
                                   AND adjustment_applied__c = true and Guaranteed_Rate__c != null order by Guaranteed_Rate__c desc]){
      if(paMap.get(String.valueOf(pa.Applicable_Scenario__c)) == null)
      {
        paMap.put(String.valueOf(pa.Applicable_Scenario__c), pa);
      }
    }

    Map<Integer, Integer> termMonths = new Map<Integer, Integer>();
    termMonths.put(1, (Integer)sdq.Scenario_1_Proposal_Term_Months__c);
    termMonths.put(2, (Integer)sdq.Scenario_2_Proposal_Term_Months__c);
    termMonths.put(3, (Integer)sdq.Scenario_3_Proposal_Term_Months__c);
    termMonths.put(4, (Integer)sdq.Scenario_4_Proposal_Term_Months__c);

    String beforeTotalBill = sd.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c;
    Decimal afterTotalBill = sd.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c != null ? sd.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c : 0;
    Decimal avoidedUtilityRate = nullDecimal(sd.Default_CB_Panel__r.Utility_Service__r.Method_1_Avoided_Utility_Rate__c, 0);

    prp.Annual_Power_Price_Escalator__c = sdq.Utility_Annual_Increase__c != null ? sdq.Utility_Annual_Increase__c : 4.0;
    prp.Proposal_Discount_Rate__c = 2;  //2%
    if (daysUntilExpiration != null)
      prp.Proposal_Expiration_Date__c = Date.today().addDays(daysUntilExpiration);  //DK CPQ-416
    prp.Days_Proposal_Valid__c = daysUntilExpiration;

    for(integer n=1; n<=4; n++)   //Criteria for writing fields: proposal term months has a non-zero value, Scenario N Financing Type is not null, and scenario is included for proposal
    {      
      if (termMonths.get(n) != null && termMonths.get(n) != 0 && sdq.get('Scenario_' + n + '_Financing_Type__c') != null && (Boolean)prp.get('Scenario_' + n + '_Included__c') == true){
        Decimal beforeBill = 0;
        try {
          beforeBill = (avoidedUtilityRate * (sdq.Annual_Electricity_Consumption_kWh__c + sdq.Forecasted_Add_Ann_Consumption_kW__c))  / 12;
        } catch (Exception e){}
        
        Decimal afterBill = 0;
        try {
          afterBill = (avoidedUtilityRate * (sdq.Annual_Electricity_Consumption_kWh__c + sdq.Forecasted_Add_Ann_Consumption_kW__c - (double)sdq.get('Scenario_'+n+'_Total_Projected_Annual_Output__c') )) / 12;
        } catch (Exception e){}
        
        prp.put('Scenario_'+n+'_Year_1_Monthly_Solar_Payment__c', (Decimal)sdq.get('Scenario_'+n+'_First_Month_Payment__c'));
        prp.put('Scenario_'+n+'_Financing_Plan__c', getScenarioFinancingPlan(sdq, n));
        prp.put('Scenario_'+n+'_FIT_Annual_Earnings_After_Tax__c', (Decimal)sdq.get('Scenario_'+n+'_FIT_Annual_Earnings_After_Tax__c'));
        prp.put('Scenario_'+n+'_FIT_Term_Length_Months__c', (Decimal)sdq.get('Scenario_'+n+'_FIT_Term_Length_Months__c'));

        prp.put('Scenario_'+n+'_Year1_Mthly_Uty_Bill_Before__c',beforeBill) ;
        prp.put('Scenario_'+n+'_Year1_Mthly_Uty_Bill_After__c',afterBill) ;
        prp.put('Scenario_'+n+'_Year1_Mthly_Uty_Bill_Savings__c',beforeBill - afterBill);

        prp.put('Scenario_'+n+'_Year1_Annual_Uty_Bill_Before__c',beforeBill*12) ;
        prp.put('Scenario_'+n+'_Year1_Annual_Uty_Bill_After__c',afterBill*12) ;
        prp.put('Scenario_'+n+'_Year1_Annual_Uty_Bill_Savings__c',(beforeBill - afterBill)*12);

        prp.put('Scenario_'+n+'_Estimated_Operational_Start_D__c', sdq.Pricing_Date__c != null ? Date.valueOf(sdq.Pricing_Date__c).addDays(90) : System.today());
        prp.put('Scenario_'+n+'_Proposal_Term_months__c', termMonths.get(n));
        prp.put('Scenario_'+n+'_Annual_Degradation_Factor__c', 0.5);  //0.5%

        if (paMap.containsKey(String.valueOf(n))){
          prp.put('Scenario_'+n+'_Production_Guarantee__c', paMap.get(String.valueOf(n)).Guaranteed_Rate__c);
        } else {
          prp.put('Scenario_'+n+'_Production_Guarantee__c', 90);  //90%  
        }
        
        prp.put('Scenario_' + n + '_Leveled_Cost_of_Guartd_Energy__c', calcLevelizedCostOfGuaranteedEnergy(prp, sdq, sd, n, termMonths.get(n)));
        prp.put('Scenario_' + n + '_Year1_Mthly_Uty_Bill_Savings__c', calcYearOneMonthlyUtilityBillSavings(prp, n));
        prp.put('Scenario_' + n + '_Year1_Avg_Mthly_SREC_Earnings__c', calcYearOneAvgMonthlySrecEarnings(prp, sdq, n));
        prp.put('Scenario_' + n + '_Cumulative_Cash_Benefit__c', calcCumulativeCashBenefit(prp, sdq, sd, n, termMonths.get(n)));
        prp.put('Scenario_' + n + '_Rate_of_Return__c', getRateOfReturn(n, prp, sd, sdq, termMonths.get(n)));
        prp.put('Scenario_' + n + '_Cash_Payback__c', getCashPaybackYear(beforeTotalBill, afterTotalBill, n, prp, sdq, termMonths.get(n)));
        prp.put('Scenario_' + n + '_EOT_Annual_Uty_Bill_Before__c', calcEndOfTermAnnualUtilityBill(getSumFromSemicolonDelimitedList(beforeTotalBill), prp, n, termMonths.get(n)));
        prp.put('Scenario_' + n + '_EOT_Annual_Uty_Bill_After__c', calcEndOfTermAnnualUtilityBill(afterTotalBill, prp, n, termMonths.get(n)));
        prp.put('Scenario_' + n + '_EOT_Annual_Uty_Bill_Savings__c', calcEndOfTermAnnualUtilityBillSavings(beforeTotalBill, afterTotalBill, prp, n, termMonths.get(n)));
        prp.put('Scenario_' + n + '_Cumulative_Uty_Bill_Before__c', calcCumulativeUtilityBillBefore(prp, n, termMonths.get(n)));
        prp.put('Scenario_' + n + '_Cumulative_Uty_Bill_After__c', calcCumulativeUtilityBillAfter(prp, n, termMonths.get(n)));
        prp.put('Scenario_' + n + '_Cumulative_Uty_Bill_Savings__c', calcCumulativeUtilityBillSavings(prp, n, termMonths.get(n)));
        prp.put('Scenario_' + n + '_Payment_Due_Signing__c', calcPaymentDueSigning(sdq, sdq.Property_State__c, n));
        prp.put('Scenario_' + n + '_Payment_Due_Installation__c', calcPaymentDueInstallation(sdq, sdq.Property_State__c, n));
        prp.put('Scenario_' + n + '_Payment_Due_Final_Inspection__c', calcPaymentDueFinalInspection(sdq, sdq.Property_State__c, n));
        prp.put('Scenario_' + n + '_Solar_Electric_Rate__c', calcSolarElectricRate(prp, sdq, sd, n, termMonths.get(n)));

        Decimal presentValueOfFinancingPayments = getPresentValueOfFinancingPayments(prp, sdq, n, termMonths.get(n));
        prp.put('Scenario_'+n+'_Present_Value_Financing_Pmt__c', presentValueOfFinancingPayments);
        Double cumulativeProduction = getCumulativeElectricityProduction(prp, sd, n, termMonths.get(n));
        prp.put('Scenario_'+n+'_Cumulative_Guaranteed_Prod__c', cumulativeProduction);
      }
    }

    if (makeCurrent){
      prp.Current__c = true;
      SalesWorkflowValidationUtility.serializeReconstructionProposal(prp);  //Serialize the parent SDQ on the Proposal
    }

    insert prp;
    
    return prp.ID;
  }

   
  //public Integer getProposalComplianceYear(Proposal__c prop, Integer scenario, Available_SREC_Contract_Offer__c availOffer){
  //  try {
  //      Date startDate = (Date)prop.get('Scenario_' + scenario + '_Estimated_Operational_Start_D__c');
  //      Integer termMonths = Integer.valueOf((Decimal)prop.get('Scenario_' + scenario + '_Proposal_Term_months__c'));

  //      Integer firstMonthComplianceYear = Integer.valueOf(availOffer.SREC_Contract_Offer__r.SREC_Market__r.First_Month_of_Compliance_Year__c);
  //      Integer lastMonthComplianceYear = Integer.valueOf(availOffer.SREC_Contract_Offer__r.SREC_Market__r.Last_Month_of_Compliance_Year__c);

  //      //Step through each month in the Proposal's term until it falls within range of the SREC Market's Compliance Year
  //      Integer n = 1;
  //      Integer complianceYear = null;
  //      Date stepDate;
  //      while (n <= termMonths && complianceYear == null){
  //        stepDate = startDate.addMonths(n);
  //        //If Month of Proposal Month >= SREC Market.First Month of Compliance Year and <= SREC Market.Last Month of Compliance Year: Year of Proposal Month
  //        //If Month of Proposal Month >= SREC Market.First Month of Compliance Year: Year of Proposal Month + 1
  //        //If Month of Proposal Month <= SREC Market.Last Month of Compliance Year: Year of Proposal Month
  //        if (stepDate.month() >= firstMonthComplianceYear && stepDate.month() <= lastMonthComplianceYear){
  //          complianceYear = stepDate.year();
  //        } else if (stepDate.month() >= firstMonthComplianceYear){
  //          complianceYear = stepDate.year() + 1;
  //        } else if (stepDate.month() <= lastMonthComplianceYear){
  //          complianceYear = stepDate.year();
  //        }
  //        n++;
  //      }

  //      return complianceYear;
  //  } catch (Exception e){
  //      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
  //      return -1;
  //  }
  //}

  Public Map<Integer,Integer> getProposalComplainceYearMap(Proposal__c prop, Integer scenario, Available_SREC_Contract_Offer__c availOffer)
  {
    Map<Integer,Integer> proposalComplianceYearMap = new Map<Integer,Integer>();
    try {
        Date startDate = (Date)prop.get('Scenario_' + scenario + '_Estimated_Operational_Start_D__c');
        Integer termMonths = Integer.valueOf((Decimal)prop.get('Scenario_' + scenario + '_Proposal_Term_months__c'));

        Integer firstMonthComplianceYear = Integer.valueOf(availOffer.SREC_Contract_Offer__r.SREC_Market__r.First_Month_of_Compliance_Year__c);
        Integer lastMonthComplianceYear = Integer.valueOf(availOffer.SREC_Contract_Offer__r.SREC_Market__r.Last_Month_of_Compliance_Year__c);

        //Step through each month in the Proposal's term until it falls within range of the SREC Market's Compliance Year
        Integer n = 1;
        Integer complianceYear = null;

        Integer currentMonth = startDate.month();    
        Integer currentYear = startDate.year(); 

        //Date stepDate;
        for (Integer i = 1; i <= termMonths; i++){ 
          
          //If Month of Proposal Month >= SREC Market.First Month of Compliance Year and <= SREC Market.Last Month of Compliance Year: Year of Proposal Month
          //If Month of Proposal Month >= SREC Market.First Month of Compliance Year: Year of Proposal Month + 1
          //If Month of Proposal Month <= SREC Market.Last Month of Compliance Year: Year of Proposal Month
          if (currentMonth >= firstMonthComplianceYear && currentMonth <= lastMonthComplianceYear){
            complianceYear = currentYear;
          } else if (currentMonth >= firstMonthComplianceYear){
            complianceYear = currentYear + 1;
          } else if (currentMonth <= lastMonthComplianceYear){
            complianceYear = currentYear;
          }
          proposalComplianceYearMap.put(i, complianceYear);

          startDate = startDate.addMonths(n);
          currentMonth = startDate.month();   
          currentYear = startDate.year(); 

        }

        return proposalComplianceYearMap;
    } catch (Exception e){
        System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
        return proposalComplianceYearMap;
    }
  }
  
  
  public Decimal getPresentValueOfFinancingPayments(Proposal__c prp, System_Design_Quote__c sdq, Integer n, Integer termMonths){
    try {
      Map<Integer, Decimal> monthlyFinancingPayments = getMonthlyFinancingPayments(prp, sdq, n, termMonths);
      Decimal presentValue = 0;
      Double discRate = getPercent(prp.get('Proposal_Discount_Rate__c'), Double.valueof(0.02));
      Integer currentMonth = prp.get('Scenario_'+n+'_Estimated_Operational_Start_D__c') != null ? ((Date)prp.get('Scenario_'+n+'_Estimated_Operational_Start_D__c')).month() : 1;
      for (Integer i = 0; i < termMonths; i++){
        presentValue += monthlyFinancingPayments.get(currentMonth) * Decimal.valueOf(Math.pow(1 - discRate, Math.floor(currentMonth/12)));
        currentMonth++;
      }
      return presentValue;
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return -1;
    }
  }
  

  //public Map<Integer, Double> getAnnualAvoidedElecValue(Proposal__c prp, System_Design_Quote__c sdq, System_Design__c sd, Integer n, Integer termMonths){
  //  try {
  //    Map<Integer, Double> monthlyElectricityProduction = getMonthlyElectricityProduction(prp, sd, n, termMonths);
  //    Map<Integer, Double> monthlyAvoidedRate = getMonthlyAvoidedUtilityRate(prp, sdq, n, termMonths);
  //    Map<Integer, Double> annualAvoidedElectricityValue = new Map<Integer, Double>();
      
  //    Double yearlySum = 0;
  //    Integer currentYear = 1;
  //    for (Integer month : monthlyElectricityProduction.keySet()){
  //      if (!monthlyAvoidedRate.containsKey(month))
  //        continue;
  //      Integer year = Integer.valueOf(Math.ceil((Decimal)month/12.0));  //e.g. if month = 25, then year = 3
  //      if (year == currentYear){
  //        yearlySum += monthlyElectricityProduction.get(month) * monthlyAvoidedRate.get(month);
  //      } else {
  //        annualAvoidedElectricityValue.put(currentYear, yearlySum);  //Add the total payments for this calendar year
  //        currentYear = year;
  //        yearlySum = monthlyElectricityProduction.get(month) * monthlyAvoidedRate.get(month);  //Start the count anew
  //      }
  //    }
  //    annualAvoidedElectricityValue.put(currentYear, yearlySum);  //Final step
  //    return annualAvoidedElectricityValue;
  //  } catch (Exception e){
  //    System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
  //    return new Map<Integer, Double>();
  //  }  
  //}

  public Map<Integer, Decimal> getMonthlyElectricityProduction(Proposal__c prp, System_Design__c sd, Integer n, Integer termMonths){
    try {
      Map<Integer, Decimal> monthlyElectricityProduction = new Map<Integer, Decimal>();
      Double degradeFactor = getPercent(prp.get('Scenario_'+n+'_Annual_Degradation_Factor__c'), Double.valueOf(0.005));
      Integer month = prp.get('Scenario_'+n+'_Estimated_Operational_Start_D__c') != null ? ((Date)prp.get('Scenario_'+n+'_Estimated_Operational_Start_D__c')).month() : 1;
       Decimal totalDegrade = 1;
         Decimal degrade = (Decimal)degradeFactor/12;
        degrade = degrade.setScale(6);   
        System.debug('degrade '+degrade );
        String deg = '';
        for (Integer i = 0; i < termMonths; i++){
        Integer calendarMonth = Math.mod(month, 12);
        if (calendarMonth == 0)
          calendarMonth = 12;
        Decimal peakProd = nullDecimal(sd.get('Method_1_'+months[calendarMonth-1]+'_Peak_kWh__c'), 0);
        Decimal partPeakProd = nullDecimal(sd.get('Method_1_'+months[calendarMonth-1]+'_Part_Peak_kWh__c'), 0);
        Decimal offPeakProd = nullDecimal(sd.get('Method_1_'+months[calendarMonth-1]+'_Off_Peak_kWh__c'), 0);
        Decimal flatProd = nullDecimal(sd.get('Method_1_'+months[calendarMonth-1]+'_Flat_kWh__c'), 0);

        Decimal monthProd = peakProd + partPeakProd + offPeakProd + flatProd;
        monthProd = monthProd.setScale(0);            
        
        totalDegrade = totalDegrade * (1- degrade);
        
        
          //Decimal degrade = Math.pow((1 + degradeFactor), i/12) - 1 ; 
       // totalDegrade = 1- degrade;
        totalDegrade = totalDegrade.setScale(4);
        //System.debug('2 totalDegrade '+totalDegrade);
        //
        deg += String.valueOf(totalDegrade)+ ';';
        Decimal production = 0;
         if(i > 11)
        {
          production = monthProd * totalDegrade;    
        }
        else
        {
          production = monthProd;  
        }
        
        monthlyElectricityProduction.put(i, production.setScale(3));
          
        //System.debug(i+' totalDegrade '+totalDegrade + ' production '+monthlyElectricityProduction.get(i));
        month++;
      }
        String output = '';
      for (Decimal d : monthlyElectricityProduction.values()){
       output += String.valueOf(d)+ ';';
      }
      //System.debug('*****monthlyElectricityProduction '+output);
      //System.debug('*****degrade '+deg);
      return monthlyElectricityProduction;
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return new Map<Integer, Decimal>();
    }      
  }

  public Decimal getCumulativeElectricityProduction(Proposal__c prp, System_Design__c sd, Integer n, Integer termMonths){
    Map<Integer, Decimal> monthlyProd = getMonthlyElectricityProduction(prp, sd, n, termMonths);
    Decimal cumulativeProduction = 0;
    for (Decimal d : monthlyProd.values()){
      cumulativeProduction += d;
    }
    return cumulativeProduction;
  }

  /* Commented by RJ
  public Map<Integer, Decimal> getMonthlyGuaranteedProduction(Proposal__c prop, System_Design__c sd, Integer n, Integer termMonths){
    Decimal prodGuarantee = getPercent(prop.get('Scenario_' + n + '_Production_Guarantee__c'), Double.valueOf(0.9));
    Map<Integer, Decimal> monthlyProd = getMonthlyElectricityProduction(prop, sd, n, termMonths);
    Map<Integer, Decimal> monthlyGuaranteed = new Map<Integer, Decimal>();
    for (Integer month = 0; month < termMonths; month++){
      monthlyGuaranteed.put(month, monthlyProd.get(month) * prodGuarantee);
    }
    System.debug('monthlyGuaranteed '+monthlyGuaranteed);
    return monthlyGuaranteed;
  }
  */

  public Decimal[] getAnnualGuaranteedProduction(Proposal__c prp, System_Design_Quote__c sdq,System_Design__c sd, Integer n, Integer termMonths){
    /*Map<Integer, Decimal> monthlyProd = getMonthlyGuaranteedProduction(prop, sd, n, termMonths);
    Decimal[] annualGuaranteed = new Decimal[]{};   //Each year from 1 to termMonths is an index
    
    Decimal yearlySum = 0;
    Integer counter = 0;
    for (Integer month = 0; month < termMonths; month++){
      counter++;
      yearlySum += monthlyProd.get(month);
      if (counter == 12){
        annualGuaranteed.add(yearlySum);  //Add the total for the past 12 months
        //System.debug('annualGuaranteed  counter - '+yearlySum);
        yearlySum = 0;
        counter = 0;  //Start the count anew
      }
    }
    if (yearlySum > 0)
      annualGuaranteed.add(yearlySum);  //In case if the Proposal Term isn't divisible by 12
    */
    // Edited by RJ to have Annual degradation
    Decimal projAnnualOutput = nullDecimal(sdq.get('Scenario_'+n+'_Total_Projected_Annual_Output__c'), 0);
    Double degradeFactor = getPercent(prp.get('Scenario_'+n+'_Annual_Degradation_Factor__c'), Double.valueOf(0.005));
    Decimal prodGuarantee = getPercent(prp.get('Scenario_' + n + '_Production_Guarantee__c'), Double.valueOf(0.9));
    Decimal yearGuranteedProd = projAnnualOutput*prodGuarantee;
    Decimal[] annualGuaranteed = new Decimal[]{}; 
    Integer termYears = Integer.ValueOf(termMonths/12);
    for (Integer year = 0; year < termYears; year ++){
      annualGuaranteed.add(yearGuranteedProd);  
      yearGuranteedProd = yearGuranteedProd * (1-degradeFactor);
      
    }


    return annualGuaranteed;
  }

  public Decimal[] getCumulativeGuaranteedProduction(Proposal__c prop,System_Design_Quote__c sdq,System_Design__c sd, Integer n, Integer termMonths){
    Decimal[] annualProd = getAnnualGuaranteedProduction(prop, sdq, sd, n, termMonths);
    Decimal[] cumulativeGuaranteedProd = new Decimal[]{};
    Decimal totalProd = 0;
    for (Decimal d : annualProd){
      totalProd += d;
      cumulativeGuaranteedProd.add(totalProd);
    }
    return cumulativeGuaranteedProd;
  }


  public Decimal getAverageFromSemicolonDelimitedList(String dataList){
    //Will return the mean value of a list such as "958.83;963.88;958.83;960.66;964.71;966.36;964.71;172.00;966.36;964.71;960.66;958.83;"
    try {
      String[] arr = dataList.split(';', 0);  //Discard trailing empty strings
      Decimal sum = 0;
      Decimal val;
      Integer trueSize = 0;
      for (String str : arr){
        if (str == null)
          continue;
        trueSize++;
        val = Decimal.valueOf(str);
        sum += val;
      }
      return sum / (Decimal)trueSize; //Return average
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return -1;
    }
  }

  public Decimal getSumFromSemicolonDelimitedList(String dataList){
    //Will return the sum of a list such as "958.83;963.88;958.83;960.66;964.71;966.36;964.71;172.00;966.36;964.71;960.66;958.83;"
    try {
      String[] arr = dataList.split(';', 0);  //Discard trailing empty strings
      Decimal sum = 0;
      Decimal val;
      for (String str : arr){
        if (str == null)
          continue;
        val = Decimal.valueOf(str);
        sum += val;
      }
      return sum;
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return -1;
    }
  }

  public Decimal getNthYearCost(Decimal totalBill, Double escalator, Integer years){
    //escalator = prop.Annual_Power_Price_Escalator__c
    escalator = getPercent(escalator, Double.valueOf(0.04));
    if (totalBill == null || totalBill == -1)
      return -1;
    Decimal result = totalBill * Decimal.valueOf(Math.pow(1 + escalator, (Double)years - 1));
    return result.setScale(2);
  }

  public Decimal getTotalOverYears(Decimal totalBill, Double escalator, Integer years){
    //escalator = prop.Annual_Power_Price_Escalator__c
    //escalator = getPercent((Object)escalator, Double.valueOf(0.02));
    //System.debug('** Before Total - totalBill '+totalBill + ' escalator '+escalator + ' years '+ years );
    if (totalBill == null || totalBill == -1)
      return -1;
    Decimal sum = 0;
    for (Integer i = 0; i < years; i++){
      Decimal yearSum = totalBill * Decimal.valueOf(Math.pow(1 + escalator, (Double)i));
      sum += yearSum;
    }
    return sum.setScale(2);
  }

  public Decimal getNetSystemPrice(System_Design_Quote__c sdq, Integer scenario){
    //Decimal finalEPC = nullDecimal(sdq.get('Scenario_' + scenario + '_Final_EPC_Price__c'), 0);
    //Decimal stateRebate = nullDecimal(sdq.get('Scenario_' + scenario + '_State_Rebate_Amount__c'), 0);
    //Decimal utilityRebate = nullDecimal(sdq.get('Scenario_' + scenario + '_Utility_Rebate_Amount__c'), 0);
    //Decimal federalTaxCred = nullDecimal(sdq.get('Scenario_' + scenario + '_Federal_Tax_Credit_Amount__c'), 0);
    //Decimal stateTaxCred = nullDecimal(sdq.get('Scenario_' + scenario + '_State_Tax_Credit_Amount__c'), 0);
    //Decimal localTaxCred = nullDecimal(sdq.get('Scenario_' + scenario + '_Local_Tax_Credit_Amount__c'), 0);
    //try {
    //  Decimal result = finalEPC + stateRebate + utilityRebate + federalTaxCred + stateTaxCred + localTaxCred;
    //  return result.setScale(2);
    //} catch (Exception e){
    //  System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
    //  return -1;
    //}
    return nullDecimal(sdq.get('Scenario_' + scenario + '_Net_Initial_Outlay__c'), 0);
  }


  public Decimal getRateOfReturn(Integer n, Proposal__c prop, System_Design__c sd, System_Design_Quote__c sdq, Integer termMonths){
    try {
      Integer termYears = (Integer)Math.floor(termMonths/12.0);
      Decimal downPayment = nullDecimal(sdq.get('Scenario_' + n + '_Down_Payment__c'), 0);

      //First, check the financing type
      String financingType = sdq.get('Scenario_' + n + '_Financing_Type__c') != null ? (String)sdq.get('Scenario_' + n + '_Financing_Type__c') : '';
      ID termLoan = (ID)sdq.get('Scenario_' + n + '_Term_Loan__c');
      if (financingType != 'Purchase' || termLoan != null){
        if (downPayment == 0)
          return -1;  //For any financing type that isn't strictly a purchse (with no loan), then require a non-zero down payment
      }

      Decimal cashOutlay = nullDecimal(sdq.get('Scenario_' + n + '_Net_Initial_Outlay__c'), 0);
      cashOutlay = -1 * Math.abs(cashOutlay);
      Double method1NetSavings = sd.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Savings__c;
      Double utilityRateEsc = getPercent(prop.Annual_Power_Price_Escalator__c, Double.valueOf(0.04));
      Double degradeRate = getPercent(prop.get('Scenario_' + n + '_Annual_Degradation_Factor__c'), Double.valueOf(0.005));
      Decimal[] netSavings = getNetSavings(method1NetSavings, utilityRateEsc, degradeRate, termYears);
      
      Decimal[] yearlyCashFlows = getYearlyCashFlows(netSavings, termYears, prop, sdq, n);

      Integer startYear = prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c') != null ? ((Date)prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c')).year() : Date.today().year();
      Double costOfCapital = System_Design_Quote_Settings__c.getOrgDefaults().Cost_of_Capital__c != null ? System_Design_Quote_Settings__c.getOrgDefaults().Cost_of_Capital__c : 0.0599;
      costOfCapital = costOfCapital + 1;

      Decimal[] adjustedCashFlows = new Decimal[]{};
      for (Integer i = 1; i <= termYears; i++){
        adjustedCashFlows.add(yearlyCashFlows[i-1] * Math.pow(costOfCapital, Double.valueOf(termYears - i)));
      }

      Double fv = 0;
      for (Decimal d : adjustedCashFlows){
          fv += (Double)d;
      }

      Double pv = (Double)-cashOutlay / Math.pow(costOfCapital, 0);
      Double mirr = (Math.pow(Double.valueOf(fv / pv), Double.valueOf(1.0 / termYears)) - 1) * 100;
      return Decimal.valueOf(mirr).setScale(1);

      //RateOfReturnUtility myIRR = new RateOfReturnUtility();
      //myIRR.addCashflow(Date.newInstance(startYear, 1, 1), cashOutlay);
      //for (Integer i = 1; i <= yearlyCashFlows.size(); i++){
      //  myIRR.addCashflow(Date.newInstance(startYear + i, 1, 1), yearlyCashFlows[i-1]);
      //}
      //Decimal ror = myIRR.calculate() * 100;
      //return ror.setScale(1);
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return -1;
    }
  }

  //private Double computeIRR(Decimal[] cf){
  //  Integer i = 0, j = 0;
  //  Double m = 0.0;
  //  Double old_n = 0.00;
  //  Double new_n = 0.00;
  //  Double oldguessRate = 0.01;
  //  Double newguessRate = 0.01;
  //  Double guessRate = 0.01;
  //  Double lowGuessRate = 0.01;
  //  Double highGuessRate = 0.5;
  //  Double npv = 0.0;
  //  Double denom = 0.0;
    
  //  for (i = 0; i < 1000; i++){
  //    npv = 0.00;
  //    for (j = 0; j < cf.size(); j++){
  //      denom = Math.pow((1 + guessRate), Double.valueOf(j));
  //      npv = npv + (cf[j] / denom);
  //    }
      
  //    //Stop checking once the required precision is achieved
  //    if ((npv > 0) && (npv < 0.00000001))
  //      break;
  //    if (old_n == 0)
  //      old_n = npv;
  //    else
  //      old_n = new_n;
  //    new_n = npv;
  //    if (i > 0){
  //      if (old_n < new_n){
  //        if (old_n < 0 && new_n < 0)
  //          highGuessRate = newguessRate;
  //        else
  //          lowGuessRate = newguessRate;
  //      } else {
  //        if (old_n > 0 && new_n > 0)
  //          lowGuessRate = newguessRate;
  //        else
  //          highGuessRate = newguessRate;
  //      }
  //    }
  //    oldguessRate = guessRate;
  //    guessRate = (lowGuessRate + highGuessRate) / 2;
  //    newguessRate = guessRate;
  //  }
  //  return guessRate;
  //}

  public Integer getCashPaybackYear(String beforeBill, Decimal afterBill, Integer n, Proposal__c prop, System_Design_Quote__c sdq, Integer termMonths){
    //The number of years it will take for the customer to recover the cost of their initial outflow
    try {
      Decimal cashOutlay = nullDecimal(sdq.get('Scenario_' + n + '_Net_Initial_Outlay__c'), 0);
      Integer startMonth = prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c') != null ? ((Date)prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c')).month() : 1;
      Decimal beforeAvg = getAverageFromSemicolonDelimitedList(beforeBill).setScale(2);
      Decimal elecSavings = beforeAvg - afterBill;
      //Map<Integer, Decimal> srecPayments = getMonthlySRECPaymentsMap(prop, sdq, n, termMonths);
      Map<Integer, Decimal> financingPayments = getMonthlyFinancingPayments(prop, sdq, n, termMonths);

      cashOutlay = -1 * Math.abs(cashOutlay);
      Integer currentMonth = startMonth;
      for (Integer i = 0; i < termMonths; i ++){
        //Decimal monthlySrec = srecPayments.containsKey(currentMonth) ? srecPayments.get(currentMonth) : 0;
        Decimal monthlyFinancing = financingPayments.containsKey(currentMonth) ? financingPayments.get(currentMonth) : 0;
        //if (cashOutlay + monthlySrec + elecSavings + monthlyFinancing >= 0)
         if (cashOutlay + elecSavings + monthlyFinancing >= 0)
          break;  //Exit the loop for the first iteration where the sum breaks zero
        currentMonth++;
      }
      return Integer.valueOf(Math.floor(currentMonth/12));
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return -1;
    }
  }

  /*public Integer getCashPaybackYear(Decimal[] cumulativeCashFlows){   //New implementation
    try {
      Integer year = 0;
      for (Decimal cashFlow : cumulativeCashFlows){
        if (cashFlow >= 0)
          break;
        year++;
      }
      return year;
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return -1;
    }
  }*/

  //public Decimal[] getNetSavings(Double totalConsumption, Double avgPrice,Double annualProduction, Double remainingRate, Proposal__c prop, Integer years, Integer n){
  //  if (years < 1){
  //    System.debug('Error in getNetSavings() in ProposalProcessor: The value of the "years" param is ' + years + '. It must be greater than or equal to 1.');
  //    return new Decimal[]{};
  //  }
  //  //Decimal beforeSum = getSumFromSemicolonDelimitedList(beforeBill);
  //  //Decimal afterSum = getSumFromSemicolonDelimitedList(afterBill);
  //  Decimal[] savingsArray = new Decimal[]{};
  //  try {
  //    Double esc = getPercent(prop.get('Annual_Power_Price_Escalator__c'), Double.valueOf(0.04));
  //    Double degradeFactor = getPercent(prop.get('Scenario_'+n+'_Annual_Degradation_Factor__c'), Double.valueOf(0.005));

  //    for (Integer i = 0; i < years; i++){
  //      Decimal beforeTotal = totalConsumption * (avgPrice * (Math.pow(1 + esc, (Double)i)));
  //      //System.debug('beforeTotal '+i+' '+beforeTotal);
        
  //      Decimal afterNonSolar = (totalConsumption - (annualProduction * (Math.pow(1 - degradeFactor, (Double)i))))* (remainingRate *(Math.pow(1 + esc, (Double)i)) );

  //     // Decimal afterSolar = (12*firstMonthPayment )*(Math.pow(1 + leaseEsc, (Double)i));

  //      Decimal totalSavings = beforeTotal - afterNonSolar ;
  //      totalSavings = totalSavings.setScale(2);
  //      savingsArray.add(totalSavings);
  //    }
  //  } catch (Exception e){
  //    System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
  //  }
  //  return savingsArray;
  //}

  //New Implementation in accordance with CPQ-573
  public Decimal[] getNetSavings(Double methodNetSavings, Double rateEsc, Double degradeRate, Integer years){
      //methodNetSavings: UtilityService.Method_1_Net_Savings__c
      //rateEsc: Proposal.Annual_Power_Price_Escalator__c (Derived from SDQ.Utility_Annual_Increase__c)
      //degradeRate: Proposal.Scenario_N_Annual_Degradation_Factor__c
      if (years < 1){
          System.debug('Error in getNetSavings() in ProposalProcessor: The value of the "years" param is ' + years + '. It must be greater than or equal to 1.');
          return new Decimal[]{};
      }
      Decimal[] savingsArray = new Decimal[]{};
      try {
          for (Integer i = 0; i < years; i++){
              Double negativeDegradeRate = -1 * Math.abs(degradeRate);
              savingsArray.add(methodNetSavings * Math.pow(1 + rateEsc + negativeDegradeRate, (Double)i));
          }
      } catch (Exception e){
          System.debug('Error in ProposalProcessor:' + e.getStackTraceString());
      }
      return savingsArray;
  }
  
  public Decimal getYearlyCashFlowYearOne(Decimal[] netSavings, Proposal__c prop, System_Design_Quote__c sdq, Integer scenario){
    //(-Scenario N Net Initial Outlay + Annual Avoided Electricity Value + Annual SREC Earnings - Annual Financing Payments)
    return getYearlyCashFlows(netSavings, 1, prop, sdq, scenario).get(0);
  }
  
  public Decimal[] getYearlyCashFlows(  Decimal[] netSavings,Integer years, Proposal__c prop, System_Design_Quote__c sdq, Integer scenario){
    //(Annual Avoided Electricity Value + Annual SREC Earnings - Annual Financing Payments) for each calendar year
    if (years < 1){
      System.debug('Error in getYearlyCashFlows() in ProposalProcessor: The value of the "years" param is ' + years + '. It must be greater than or equal to 1.');
      return new Decimal[]{};
    }
    try {
      Decimal[] arr = new Decimal[]{};
      //Double esc = getPercent(prop.get('Annual_Power_Price_Escalator__c'), Double.valueOf(0.02));
      Decimal cashOutlay = nullDecimal(sdq.get('Scenario_' + scenario + '_Net_Initial_Outlay__c'), 0);
      //Integer startMonth = prop.get('Scenario_' + scenario + '_Estimated_Operational_Start_D__c') != null ? ((Date)prop.get('Scenario_' + scenario + '_Estimated_Operational_Start_D__c')).month() : 1;
      Integer termMonths = years * 12;

      
      //Decimal[] financingPayments = getAnnualFinancingPayments(prop, sdq, scenario, termMonths);
      //Decimal annualFinancingPayment = 0;
      //if (financingPayments.size() >= years)
        //annualFinancingPayment = financingPayments[years - 1];

      Decimal[] srecEarnings = getAnnualSrecEarnings(prop, sdq, scenario, termMonths);

      Integer loanTerm = termMonths;   //Default to be overwritten
      try {
        loanTerm = Integer.valueOf(sdq.getSObject('Scenario_' + scenario + '_Term_Loan__r').get('Financing_Term_Months__c'));
      } catch (Exception e){}
                        
      Decimal[] annualPayments = getAnnualFinancingPayments(prop, sdq, scenario, loanTerm);
      while (annualPayments.size() < termMonths){
        annualPayments.add(0);  //Pad the array to match the standard Proposal term
      }
      
      //Decimal yearEarning = 0;
      //if (srecEarnings.size() >= years)
        //yearEarning = srecEarnings[years - 1];

      //Decimal beforeSum = getSumFromSemicolonDelimitedList(beforeBill);
      //Decimal afterSum = getSumFromSemicolonDelimitedList(afterBill);
      Decimal savings = 0;
      Decimal earnings = 0;
      Decimal annualPayment = 0;
      for (Integer i = 0; i < years; i++){
        //Decimal flow = (beforeSum * Math.pow(1 + esc, (Double)i)) - (afterSum * Math.pow(1 + esc, (Double)i)) + yearEarning - annualFinancingPayment;
        if (netSavings.size() >= i+1)
          savings = netSavings[i];
        if (srecEarnings.size() >= i+1)
          earnings = srecEarnings[i];
        if (annualPayments.size() >= i+1)
          annualPayment = annualPayments[i];
        Decimal flow = savings + earnings + annualPayment ; // Annual Payment is already Negative
        arr.add(flow.setScale(2));
      }
      return arr;
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return new Decimal[]{};
    }
  }

  public Decimal[] getYearlyFeedInTariffEarnings(Proposal__c prop, Integer n, Integer propTermYears){
      Decimal[] earnings = new Decimal[]{};
      Integer fitTermYears = Integer.valueOf(Math.ceil((Decimal)prop.get('Scenario_' + n + '_FIT_Term_Length_Months__c')/12.0));
      for (Integer i = 1; i <= propTermYears; i++){
          if (i <= fitTermYears){
              earnings.add((Decimal)prop.get('Scenario_' + n + '_FIT_Annual_Earnings_After_Tax__c'));
          } else {
              earnings.add(0);
          }
      }
      return earnings;
  }

  public Decimal[] getFeedInTariffUtilitySavings(Proposal__c prop, Integer n, Decimal[] netSavings){    //CPQ-731
      Integer fitTermYears = Integer.valueOf(Math.ceil((Decimal)prop.get('Scenario_' + n + '_FIT_Term_Length_Months__c')/12.0));
      for (Integer i = 0; i < netSavings.size(); i++){
          if (i + 1 <= fitTermYears)
              netSavings[i] = 0;
      }
      return netSavings;
  }

  public Decimal[] getCumulativeCashFlows(Decimal[] netSavings, Integer years, Proposal__c prop, System_Design_Quote__c sdq, Integer scenario, Decimal cashBack){   //Legacy signature
    return getCumulativeCashFlows(netSavings, years, prop, sdq, scenario, cashBack, false);
  }

  public Decimal[] getCumulativeCashFlows(Decimal[] netSavings, Integer years, Proposal__c prop, System_Design_Quote__c sdq, Integer scenario, Decimal cashBack, Boolean includeFIT){
    //"cashBack" variable is indended for use with SDQ.Scenario_N__SREC_Cash_Back__c
    Decimal[] incrementalCashFlows = new Decimal[]{};
    Decimal[] annualCashFlows = new Decimal[]{};
    if (includeFIT){
        Decimal[] savings = getYearlyCashFlows(getFeedInTariffUtilitySavings(prop, scenario, netSavings), years, prop, sdq, scenario);
        Decimal[] earnings = getYearlyFeedInTariffEarnings(prop, scenario, years);
        for (Integer i = 0; i < savings.size(); i++){
            annualCashFlows.add(savings[i] + earnings[i]);
        }
    } else {
        annualCashFlows = getYearlyCashFlows(netSavings, years, prop, sdq, scenario);
    }
    Decimal cashOutlay = nullDecimal(sdq.get('Scenario_' + scenario + '_Net_Initial_Outlay__c'), 0);
    cashOutlay = -1 * Math.abs(cashOutlay);
    Decimal totalCashFlow = cashOutlay + cashBack; //Starting value
    for (Decimal d : annualCashFlows){
      totalCashFlow += d;
      incrementalCashFlows.add(totalCashFlow);
    }
    return incrementalCashFlows;
  }

  public Decimal getSolarPortionOfElectricity(Decimal projectedAnnualOutput, Decimal annualConsumption){
    //projectedAnnualOutput = sysDesign.Total_Projected_Annual_Output_kWh_y__c
    //annualConsumption = sysDesign.Default_CB_Panel__r.Utility_Service__r.Annual_Electricity_Consumption_kWh_frm__c
    try {
      Decimal result = (projectedAnnualOutput / annualConsumption) * 100;
      return result.setScale(2);
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return -1;
    } 
  }

  
  public Map<Integer, Decimal> getMonthlyFinancingPayments(Proposal__c prop, System_Design_Quote__c sdq, Integer n, Integer termMonths){
    try {
      //Decimal financingPayment = nullDecimal(sdq.get('Scenario_' + n + '_Financing_Monthly_Pmt_Year_1__c'), 0);
      Decimal financingPayment = nullDecimal(sdq.get('Scenario_' + n + '_First_Month_Payment__c'), 0);
      String leaseEscStr = sdq.get('Scenario_' + n + '_Lease_Escalator__c') != null ? (String)sdq.get('Scenario_' + n + '_Lease_Escalator__c') : '0';
      if (String.isBlank(leaseEscStr) || leaseEscStr == 'null')
        leaseEscStr = '0';
      Double leaseEsc = Double.valueOf(leaseEscStr) / 100;
      Integer startMonth = prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c') != null ? ((Date)prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c')).month() : 1;

      Map<Integer, Decimal> paymentMap = new Map<Integer, Decimal>();
      Integer currentMonth = startMonth;
      for (Integer i = 0; i < termMonths; i++){
        Decimal monthlyFinancingPayment = financingPayment * Decimal.valueOf(Math.pow(1 + leaseEsc, Math.floor(currentMonth/12)));
        paymentMap.put(currentMonth, monthlyFinancingPayment);
        currentMonth++;
      }
      return paymentMap;
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return new Map<Integer, Decimal>();
    }
  }
  

  public Decimal[] getAnnualFinancingPayments(Proposal__c prop, System_Design_Quote__c sdq, Integer n, Integer termMonths){
    try {
      
      Decimal financingPayment = nullDecimal(sdq.get('Scenario_' + n + '_First_Month_Payment__c'), 0);
      String leaseEscStr = sdq.get('Scenario_' + n + '_Lease_Escalator__c') != null ? (String)sdq.get('Scenario_' + n + '_Lease_Escalator__c') : '0';
      if (String.isBlank(leaseEscStr) || leaseEscStr == 'null')
        leaseEscStr = '0';
      Double leaseEsc = Double.valueOf(leaseEscStr) / 100;
      
      Integer termYears = (Integer)Math.floor(termMonths/12.0);
      Decimal[] annualFinancingPayments = new Decimal[]{};

      for (Integer i = 0; i < termYears; i++){        
        Decimal annualPayment = (12*financingPayment)*(Math.pow(1 + leaseEsc, (Double)i));
        if(annualPayment != null)
        {
          annualFinancingPayments.add(annualPayment * -1 ); 
        }
      }
      /*
      Map<Integer, Decimal> financingPayments = getMonthlyFinancingPayments(prop, sdq, n, termMonths);
      
      Decimal yearlySum = 0;
      Integer counter = 0;
      for (Integer month : financingPayments.keySet()){
        counter++;
        yearlySum += financingPayments.get(month);
        if (counter == 12){
          annualFinancingPayments.add(yearlySum);  //Add the total payments for the past 12 months
          yearlySum = 0;
          counter = 0;  //Start the count anew
        }
      }
      if (yearlySum > 0)
        annualFinancingPayments.add(yearlySum);
      */
      return annualFinancingPayments;
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return new Decimal[]{};
    }
  }

  public Integer[] getMonthlySRECProduction(Proposal__c prop, ID sysDesignID, Integer n, Integer termMonths){
    try {
      System_Design__c sd = [Select id ,Method_1_Jan_Peak_kWh__c,Method_1_Feb_Peak_kWh__c,Method_1_Mar_Peak_kWh__c,Method_1_Apr_Peak_kWh__c,Method_1_May_Peak_kWh__c,Method_1_Jun_Peak_kWh__c
                         ,Method_1_Jul_Peak_kWh__c,Method_1_Aug_Peak_kWh__c,Method_1_Sep_Peak_kWh__c,Method_1_Oct_Peak_kWh__c,Method_1_Nov_Peak_kWh__c,Method_1_Dec_Peak_kWh__c
                         ,Method_1_Jan_Part_Peak_kWh__c,Method_1_Feb_Part_Peak_kWh__c,Method_1_Mar_Part_Peak_kWh__c,Method_1_Apr_Part_Peak_kWh__c,Method_1_May_Part_Peak_kWh__c,Method_1_Jun_Part_Peak_kWh__c
                     ,Method_1_Jul_Part_Peak_kWh__c,Method_1_Aug_Part_Peak_kWh__c,Method_1_Sep_Part_Peak_kWh__c,Method_1_Oct_Part_Peak_kWh__c,Method_1_Nov_Part_Peak_kWh__c,Method_1_Dec_Part_Peak_kWh__c
                     ,Method_1_Jan_Off_Peak_kWh__c,Method_1_Feb_Off_Peak_kWh__c,Method_1_Mar_Off_Peak_kWh__c,Method_1_Apr_Off_Peak_kWh__c,Method_1_May_Off_Peak_kWh__c,Method_1_Jun_Off_Peak_kWh__c
                     ,Method_1_Jul_Off_Peak_kWh__c,Method_1_Aug_Off_Peak_kWh__c,Method_1_Sep_Off_Peak_kWh__c,Method_1_Oct_Off_Peak_kWh__c,Method_1_Nov_Off_Peak_kWh__c,Method_1_Dec_Off_Peak_kWh__c
                     ,Method_1_Jan_Flat_kWh__c,Method_1_Feb_Flat_kWh__c,Method_1_Mar_Flat_kWh__c,Method_1_Apr_Flat_kWh__c,Method_1_May_Flat_kWh__c,Method_1_Jun_Flat_kWh__c
                     ,Method_1_Jul_Flat_kWh__c,Method_1_Aug_Flat_kWh__c,Method_1_Sep_Flat_kWh__c,Method_1_Oct_Flat_kWh__c,Method_1_Nov_Flat_kWh__c,Method_1_Dec_Flat_kWh__c
                         from System_Design__c 
                        where id = :sysDesignID];
      Map<Integer, Double> monthlyElectricityProduction = getMonthlyElectricityProduction(prop, sd, n, termMonths);

      Integer[] monthlySRECs = new Integer[]{};
      Double cumulativeProduction = 0;
      Integer cumulativeSRECs = 0;
      for (Integer i = 1; i <= termMonths; i++){
        if (monthlyElectricityProduction.containsKey(i)){
          //System.debug(i + ' monthly prod: ' + monthlyElectricityProduction.get(i));
          cumulativeProduction += monthlyElectricityProduction.get(i);  //Add the electricity produced for this month
          Integer srecProd = Integer.valueOf(Math.floor(cumulativeProduction/1000) - cumulativeSRECs);
          //System.debug('~ Cumulative prod: ' + cumulativeProduction + ', monthly SREC prod: ' + srecProd);
          monthlySRECs.add(srecProd);
          cumulativeSRECs += srecProd;
          //For example:  Month 4 = Math.floor(((m1 + m2 + m3 + m4)/1000) - (SREC month 1 + SREC month 2 + SREC month 3))
        } else {
          monthlySRECs.add(0);
        }
      }
      System.debug('monthlySRECs SRECs: ' + monthlySRECs); 
      return monthlySRECs;
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return new Integer[]{};
    }
  }

  //public Decimal getMonthlySRECValue(Proposal__c prop, System_Design_Quote__c sdq, Integer n, Integer month){
  //  try {
  //    String scenario = String.valueOf(n);
  //    Available_SREC_Contract_Offer__c srecOffer = [SELECT RecordTypeDeveloperName__c, Contract_Length_months__c, Yearly_Amount_SREC__c, Yearly_Amount_of_ACP__c, 
  //                                                  SREC_Contract_Offer__r.SREC_Market__r.First_Month_of_Compliance_Year__c, SREC_Contract_Offer__r.SREC_Market__r.Last_Month_of_Compliance_Year__c 
  //                                                  FROM Available_SREC_Contract_Offer__c WHERE Contract_Offer_Applied__c = true AND Applicable_Scenario__c = :scenario AND 
  //                                                  Current_Matching_SREC_Offer__c = true AND System_Design_Quote__c = :sdq.ID LIMIT 1];
  //    ID marketID = srecOffer.SREC_Contract_Offer__r.SREC_Market__c;
  //    String complianceYear = String.valueOf(getProposalComplianceYear(prop, n, srecOffer));
  //    //System.debug('Compliance Year: ' + complianceYear);
  //    SREC_Price__c srecPrice = [SELECT Start_Date__c, End_Date__c, Compliance_Year__c, Price__c FROM SREC_Price__c WHERE SREC_Market__c = :marketID AND Compliance_Year__c = :complianceYear LIMIT 1];
  //    SREC_ACP__c srecACP = [SELECT Start_Date__c, End_Date__c, Compliance_Year__c, Value__c FROM SREC_ACP__c WHERE SREC_Market__c = :marketID AND Compliance_Year__c = :complianceYear LIMIT 1];
  //    return getMonthlySRECValue(sdq, month, srecOffer, srecPrice, srecACP);
  //  } catch (Exception e){
  //    System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
  //    return 0;
  //  }
  //}

  public Decimal getMonthlySRECValue(System_Design_Quote__c sdq, Integer month, Available_SREC_Contract_Offer__c srecOffer, SREC_Price__c srecPrice, SREC_ACP__c srecACP){
    try {
      Decimal returnValue = 0;
      if (srecOffer.RecordTypeDeveloperName__c == 'Yearly'){
        if (month <= srecOffer.Contract_Length_months__c){
          if (srecOffer.SREC_Contract_Offer__r.SREC_Earnings_Based_on_KW__c){
            returnValue = sdq.System_Size_kW__c * srecOffer.Yearly_Amount_SREC__c;  //CPQ-629
            System.debug('Yearly SREC Offer, month is <= contract length, SREC Earnings based on KW: ' + returnValue);
          } else {
            returnValue = srecOffer.Yearly_Amount_SREC__c + (getPercent(srecOffer.Yearly_Amount_of_ACP__c, 0) * srecACP.Value__c);
          }

        } else {
          returnValue = srecPrice.Price__c;
        }

      } else if (srecOffer.RecordTypeDeveloperName__c == 'Upfront'){
        if (month <= srecOffer.Contract_Length_months__c){
          returnValue = 0;
          //System.debug('Upfront SREC Offer, month is <= contract length: ' + returnValue);
        } else {
          returnValue = srecPrice.Price__c;
        }

      } else if (srecOffer.RecordTypeDeveloperName__c == 'Brokerage' || String.isBlank(srecOffer.RecordTypeDeveloperName__c)){
        returnValue = srecPrice.Price__c;

      } else if (srecOffer.RecordTypeDeveloperName__c == 'Monthly' && srecOffer.SREC_Contract_Offer__r.SREC_Earnings_Based_on_KW__c){  //CPQ-629
          if (month <= srecOffer.Contract_Length_months__c){
            if (srecOffer.SREC_Contract_Offer__r.Monthly_Amount__c != null){
              returnValue = sdq.System_Size_kW__c * srecOffer.SREC_Contract_Offer__r.Monthly_Amount__c;
              System.debug('Monthly SREC Offer, month is <= contract length: ' + returnValue);
            }
          } else {
              returnValue = srecPrice.Price__c;
              System.debug('Monthly SREC Offer, month is > contract length: ' + returnValue);
          }
      }
      return nullDecimal(returnValue, 0);
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return 0;
    }
  }

  //public Decimal[] getMonthlySRECEarnings(Proposal__c prop, System_Design_Quote__c sdq, Integer n, Integer termMonths){
  //  try {
  //    String scenario = String.valueOf(n);
  //    Available_SREC_Contract_Offer__c srecOffer = [SELECT RecordTypeDeveloperName__c, Contract_Length_months__c, SREC_Contract_Offer__r.SREC_Market__c, 
  //                                                  Yearly_Amount_SREC__c, Yearly_Amount_of_ACP__c 
  //                                                  FROM Available_SREC_Contract_Offer__c WHERE Contract_Offer_Applied__c = true AND Applicable_Scenario__c = :scenario AND 
  //                                                  System_Design_Quote__c = :sdq.ID LIMIT 1];
  //    ID marketID = srecOffer.SREC_Contract_Offer__r.SREC_Market__c;
  //    String complianceYear = String.valueOf(getProposalComplianceYear(prop, n));
  //    SREC_Price__c srecPrice = [SELECT Start_Date__c, End_Date__c, Compliance_Year__c, Price__c FROM SREC_Price__c WHERE SREC_Market__c = :marketID AND Compliance_Year__c = :complianceYear LIMIT 1];
  //    SREC_ACP__c srecACP = [SELECT Start_Date__c, End_Date__c, Compliance_Year__c, Value__c FROM SREC_ACP__c WHERE SREC_Market__c = :marketID AND Compliance_Year__c = :complianceYear LIMIT 1];

  //    Decimal[] srecValues = new Decimal[]{}; //Build an array of SREC values for the entire term
  //    for (Integer i = 1; i <= termMonths; i++){
  //      srecValues.add(getMonthlySRECValue(sdq, i, srecOffer, srecPrice, srecACP));
  //    }

  //    ID sdID = sdq.System_Design__c;
  //    Integer[] srecProduction = getMonthlySRECProduction(prop, sdID, n, termMonths);
  //    Decimal[] monthlyEarnings = new Decimal[]{};

  //    for (Integer i = 0; i < termMonths; i++){
  //      monthlyEarnings.add(srecProduction.get(i) * srecValues.get(i));
  //    }
  //    return monthlyEarnings;
  //  } catch (Exception e){
  //    System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
  //    return new Decimal[]{};
  //  }
  //}

  public Map<Integer, Decimal> getMonthlySRECPaymentsMap(Proposal__c prop, System_Design_Quote__c sdq, Integer n, Integer termMonths , Available_SREC_Contract_Offer__c srecOffer, Map<String,SREC_Price__c> srecPriceYearMap, Map<String,SREC_ACP__c> srecACPYearMap, Integer[] srecProduction){
    try {
      Integer startMonth = prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c') != null ? ((Date)prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c')).month() : 1;
      Decimal[] srecPayments = getMonthlySRECPayments(prop, sdq, n, termMonths,srecOffer, srecPriceYearMap, srecACPYearMap,srecProduction);
      Map<Integer, Decimal> paymentMap = new Map<Integer, Decimal>();   //Integer keys are "startMonth" through "termMonth"
      Integer currentMonth = startMonth;
      for (Decimal d : srecPayments){
        paymentMap.put(currentMonth, d);
        currentMonth++;
      }
      return paymentMap;
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return new Map<Integer, Decimal>();
    }
  }

  public Decimal[] getMonthlySRECPayments(Proposal__c prop, System_Design_Quote__c sdq, Integer n, Integer termMonths, Available_SREC_Contract_Offer__c srecOffer,Map<String,SREC_Price__c> srecPriceYearMap, Map<String,SREC_ACP__c> srecACPYearMap ,Integer[] srecProduction){
    try {
      //First, calculate the monthly SREC Earnings
      String scenario = String.valueOf(n);
     

      Map<Integer,Integer>  complianceYearMap = getProposalComplainceYearMap(prop, n, srecOffer);
      //String complianceYear = String.valueOf(getProposalComplianceYear(prop, n, srecOffer));
      
      Decimal[] srecValues = new Decimal[]{}; //Build an array of SREC values for the entire term
      for (Integer i = 1; i <= termMonths; i++){        
        SREC_Price__c srecPrice = srecPriceYearMap.get(String.valueOf(complianceYearMap.get(i)));
        SREC_ACP__c srecACP = srecACPYearMap.get(String.valueOf(complianceYearMap.get(i)));
        srecValues.add(getMonthlySRECValue(sdq, i, srecOffer, srecPrice, srecACP));
      }

      
      Decimal[] monthlyEarnings = new Decimal[]{};

      for (Integer i = 0; i < termMonths; i++){
        if (srecOffer.RecordTypeDeveloperName__c == 'Monthly' && i+1 <= srecOffer.Contract_Length_months__c){
          monthlyEarnings.add(srecValues.get(i));
        } else {
          monthlyEarnings.add(srecProduction.get(i) * srecValues.get(i));
        }
        //System.debug('Production: ' + srecProduction.get(i) + ', Value: ' + srecValues.get(i));
      }

      //Now apply to the calendar
      Integer paymentMonth = Integer.valueOf(srecOffer.SREC_Contract_Offer__r.SREC_Market__r.Payment_Month__c);
      Integer startMonth = prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c') != null ? ((Date)prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c')).month() : 1;

      Decimal[] srecPayments = new Decimal[]{};
      Decimal earningSum = 0;
      Decimal paymentSum = 0;
      Integer currentMonth = startMonth;
      for (Integer i = 0; i < termMonths; i++){
        Integer calendarMonth = Math.mod(currentMonth, 12);
        if (calendarMonth == 0)
          calendarMonth = 12;   //Correct for December
        //System.debug('Calendar Month: ' + calendarMonth + ', monthly earnings: ' + monthlyEarnings.get(i));
        earningSum += monthlyEarnings.get(i);

        if (srecOffer.RecordTypeDeveloperName__c == 'Monthly' || calendarMonth == paymentMonth){  //RecordType check added on 8/24/15
          srecPayments.add(earningSum - paymentSum);
        } else {
          srecPayments.add(0);
        }
         
        paymentSum += srecPayments.get(i);
        currentMonth++;
      }
      return srecPayments;

    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return new Decimal[]{};
    }
  }

  public Decimal[] getAnnualSrecEarnings(Proposal__c prop, System_Design_Quote__c sdq, Integer n, Integer proposalTermMonths){
    try {
       String scenario = String.valueOf(n);
       Decimal[] annualEarnings = new Decimal[]{};
       List<Available_SREC_Contract_Offer__c> srecOfferList = [SELECT RecordTypeDeveloperName__c, Contract_Length_months__c, SREC_Contract_Offer__r.SREC_Market__r.Payment_Month__c, 
                                                    Yearly_Amount_SREC__c, Yearly_Amount_of_ACP__c, SREC_Contract_Offer__r.SREC_Market__r.First_Month_of_Compliance_Year__c, 
                                                    SREC_Contract_Offer__r.SREC_Market__r.Last_Month_of_Compliance_Year__c, SREC_Contract_Offer__r.SREC_Market__r.Eligible_Term_months__c,
                                                    SREC_Contract_Offer__r.SREC_Earnings_Based_on_KW__c, SREC_Contract_Offer__r.Monthly_Amount__c 
                                                    FROM Available_SREC_Contract_Offer__c 
                                                    WHERE Contract_Offer_Applied__c = true AND Applicable_Scenario__c = :scenario AND 
                                                    Current_Matching_SREC_Offer__c = true AND System_Design_Quote__c = :sdq.ID  LIMIT 1];
      
      if(srecOfferList != null && !srecOfferList.isEmpty())
      {
        Available_SREC_Contract_Offer__c srecOffer= srecOfferList[0];
        ID marketID = srecOffer.SREC_Contract_Offer__r.SREC_Market__c;

        Date pricingDate = Date.today();
        if (sdq.Pricing_Date__c != null)
            pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());   //CPQ-779

        Map<String,SREC_Price__c> srecPriceYearMap = new Map<String,SREC_Price__c>();
        for (SREC_Price__c scp : [SELECT Start_Date__c, End_Date__c, Compliance_Year__c, Price__c FROM SREC_Price__c WHERE SREC_Market__c = :marketID AND 
                                  Start_Date__c <= :pricingDate AND (End_Date__c = null OR End_Date__c >= :pricingDate)]){
          srecPriceYearMap.put(scp.Compliance_Year__c, scp); 
        }

        Map<String,SREC_ACP__c> srecACPYearMap = new Map<String,SREC_ACP__c>();
        for (SREC_ACP__c scp: [SELECT Start_Date__c, End_Date__c, Compliance_Year__c, Value__c FROM SREC_ACP__c WHERE SREC_Market__c = :marketID AND
                                Start_Date__c <= :pricingDate AND (End_Date__c = null OR End_Date__c >= :pricingDate)]){
          srecACPYearMap.put(scp.Compliance_Year__c, scp); 
        }

        Integer srecTermMonths = Integer.valueOf(nullDecimal(srecOffer.SREC_Contract_Offer__r.SREC_Market__r.Eligible_Term_months__c, 240.0));
        if (srecTermMonths > proposalTermMonths)
          srecTermMonths = proposalTermMonths;  //Truncate the term if it's longer than that of the Proposal

        ID sdID = sdq.System_Design__c;
        Integer[] srecProduction = getMonthlySRECProduction(prop, sdID, n, srecTermMonths);

        Map<Integer, Decimal> srecPayments = getMonthlySRECPaymentsMap(prop, sdq, n, srecTermMonths, srecOffer, srecPriceYearMap, srecACPYearMap, srecProduction);
        
        Decimal yearlySum = 0;
        Integer counter = 0;
        Integer[] monthList = new List<Integer>(srecPayments.keySet());
        monthList.sort();
        for (Integer month : monthList){
          //System.debug('Month ' + month + ' SREC Payment: ' + srecPayments.get(month));
          counter++;
          yearlySum += srecPayments.get(month);
          if (counter == 12) {
            annualEarnings.add(yearlySum);  //Add the total earnings for the past 12 months
            yearlySum = 0;
            counter = 0;  //Start the count anew
          }
        }
        if (yearlySum > 0)
          annualEarnings.add(yearlySum);  //In case of remainder

        while (annualEarnings.size() < (Integer)Math.floor(proposalTermMonths/12.0))
          annualEarnings.add(0);  //Pad the array with zeros in order to match the length of the Proposal term
      }
      return annualEarnings;
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return new Decimal[]{};
    }
  }

  public Decimal getPresentValueOfSrecEarnings(Proposal__c prop, System_Design_Quote__c sdq, Integer n, Integer termMonths){
    try {
      Decimal totalValue = 0;
      Integer startMonth = prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c') != null ? ((Date)prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c')).month() : 1;
      Decimal[] annualEarnings = getAnnualSrecEarnings(prop, sdq, n, termMonths);
      Double discRate = getPercent(prop.get('Proposal_Discount_Rate__c'), Double.valueOf(0.02));
      for (Integer i = 0; i < annualEarnings.size(); i++){
        totalValue += annualEarnings.get(i) * Math.pow(1 - discRate, (Double)i);
      }
      return totalValue;
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return 0;
    }
  }

  public Map<Integer, Double> getMonthlyAvoidedUtilityRate(Proposal__c prop, System_Design_Quote__c sdq, Integer n, Integer termMonths){
    //(Scenario N Avoided Utility Rate * Math.pow(1 + Annual Power Price Escalator, floor(m/12))
    Map<Integer, Double> avoidedRates = new Map<Integer, Double>();
    Double avoidedUtilityRate = (Double)sdq.get('Scenario_' + n + '_Avoided_Utility_Rate__c');
    Integer startMonth = prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c') != null ? ((Date)prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c')).month() : 1;
    Double esc = getPercent(prop.get('Annual_Power_Price_Escalator__c'), Double.valueOf(0.04));
    Integer currentMonth = startMonth;
    for (Integer i = 0; i < termMonths; i++){
      avoidedRates.put(currentMonth, avoidedUtilityRate * Math.pow(Double.valueOf(1 + esc), Math.floor(currentMonth/12)));
      currentMonth++;
    }
    return avoidedRates;
  }

  //private static Double internalRateOfReturn(Decimal[] values, Double guess){
  //  Integer maxIterationCount = 20;
  //  Double absoluteAccuracy = 0.0000001;

  //  Decimal x0 = (Decimal)guess;
  //  Decimal x1;

  //  Integer i = 0;
  //  while (i < maxIterationCount){ // the value of the function (NPV) and its derivate can be calculated in the same loop
  //    Decimal fValue = 0;
  //    Decimal fDerivative = 0;
  //    for (Integer k = 0; k < values.size(); k++) {
  //      fValue += values[k] / Math.pow(Double.valueOf(1.0 + x0), (Double)k);
  //      fDerivative += -k * values[k] / Math.pow(Double.valueOf(1.0 + x0), Double.valueOf(k + 1));
  //    }

  //    x1 = x0 - (fValue/fDerivative); // the essence of the Newton-Raphson Method

  //    if (Math.abs(x1 - x0) <= absoluteAccuracy) {
  //      return x1;
  //    }
  //    x0 = x1;
  //    ++i;
  //  }
  //  // maximum number of iterations is exceeded
  //  return null;
  //}

  //--- Field Calculations ---//

  //Proposal__c field: Scenario_N_Leveled_Cost_of_Guartd_Energy__c
  public Decimal calcLevelizedCostOfGuaranteedEnergy(Proposal__c prop, System_Design_Quote__c sdq, System_Design__c sd, Integer n, Integer termMonths){
    //(Scenario N Net Initial Outlay + Present Value of SREC Earnings – Present Value of Financing Payments) / Cumulative Guaranteed Production
    try {
      Decimal cashOutlay = nullDecimal(sdq.get('Scenario_' + n + '_Net_Initial_Outlay__c'), 0);
      cashOutlay = -1 * Math.abs(cashOutlay);
      Decimal presentValueOfSrecEarnings = getPresentValueOfSrecEarnings(prop, sdq, n, termMonths);
      Decimal presentValueOfFinancingPayments = getPresentValueOfFinancingPayments(prop, sdq, n, termMonths);
      Integer termYears = (Integer)Math.floor(termMonths/12.0);
      Decimal cumulativeGuaranteedProduction = getCumulativeGuaranteedProduction(prop, sdq,sd, n, termMonths).get(termYears - 1);
      Decimal result = (cashOutlay + presentValueOfSrecEarnings - presentValueOfFinancingPayments) / cumulativeGuaranteedProduction;
      return result.setScale(2);
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return -1;
    }
  }

  //Proposal__c field: Scenario_N_Year1_Mthly_Uty_Bill_Savings__c
  public Decimal calcYearOneMonthlyUtilityBillSavings(Proposal__c prop, Integer n){
    Decimal monthlyBefore = (Decimal)prop.get('Scenario_' + n + '_Year1_Mthly_Uty_Bill_Before__c');
    Decimal monthlyAfter = (Decimal)prop.get('Scenario_' + n + '_Year1_Mthly_Uty_Bill_After__c');
    return monthlyBefore - monthlyAfter;
  }

  //Proposal__c field: Scenario_N_Year1_Avg_Mthly_SREC_Earnings__c
  public Decimal calcYearOneAvgMonthlySrecEarnings(Proposal__c prop, System_Design_Quote__c sdq, Integer n){
    Decimal[] annualSrecEarnings = getAnnualSrecEarnings(prop, sdq, n, 12);
    Decimal yearOneSrecEarnings = annualSrecEarnings.isEmpty() ? 0 : annualSrecEarnings[0];
    return (Decimal)(yearOneSrecEarnings/12.0);
  }

  //Proposal__c field: Scenario_N_Cumulative_Cash_Benefit__c
  public Decimal calcCumulativeCashBenefit(Proposal__c prop, System_Design_Quote__c sdq, System_Design__c sd, Integer n, Integer termMonths){ 
    try {
      //Integer startMonth = prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c') != null ? ((Date)prop.get('Scenario_' + n + '_Estimated_Operational_Start_D__c')).month() : 1;
      //Decimal beforeAvg = getAverageFromSemicolonDelimitedList(beforeBill).setScale(2);
      //Decimal elecSavings = beforeAvg - afterBill;
      //Map<Integer, Decimal> financingPayments = getMonthlyFinancingPayments(prop, sdq, n, termMonths);

      //Decimal sum = 0;
      //Integer currentMonth = startMonth;
      //for (Integer i = 0; i < termMonths; i ++){
      //  Decimal monthlyFinancing = financingPayments.containsKey(currentMonth) ? financingPayments.get(currentMonth) : 0;
      //  sum += elecSavings - monthlyFinancing;
      //  currentMonth++;
      //}
      //return sum;

      //New implementation for CPQ-747
      Integer termYears = (Integer)Math.floor(termMonths/12.0);
      Decimal customerCheck = 0;
      if ((String)prop.get('Scenario_' + n + '_Financing_Plan__c') == 'Solar Finance Plan'){
        customerCheck = sdq.get('Scenario_' + n + '_SREC_Cash_Back__c') != null ? (Decimal)sdq.get('Scenario_' + n + '_SREC_Cash_Back__c') : 0;   //CPQ-675
      } else if ((String)prop.get('Scenario_' + n + '_Financing_Plan__c') == 'Monthly Savings Plan'){
        customerCheck = Math.abs(nullDecimal(sdq.get('Scenario_' + n + '_Total_Net_Adjustment__c'), 0));  //CPQ-543
      }

      Double method1NetSavings = sd.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Savings__c != null ? sd.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Savings__c : 0;
      Double utilityRateEsc = getPercent(prop.Annual_Power_Price_Escalator__c, Double.valueOf(0.04));
      Double degradeRate = getPercent(prop.get('Scenario_' + n + '_Annual_Degradation_Factor__c'), Double.valueOf(0.005));
      Decimal[] netSavings = getNetSavings(method1NetSavings, utilityRateEsc, degradeRate, termYears);

      Decimal[] cumulativeCashFlows = getCumulativeCashFlows(netSavings, termYears, prop, sdq, n, customerCheck);
      return cumulativeCashFlows.get(cumulativeCashFlows.size() - 1);

    } catch (Exception e){
      System.debug('Error in ProposalProcessor: ' + e.getStackTraceString());
      return -1;
    }
  }
  

  //Proposal__c fields: Scenario_N_EOT_Annual_Uty_Bill_Before__c and Scenario_N_EOT_Annual_Uty_Bill_After__c
  public Decimal calcEndOfTermAnnualUtilityBill(Decimal totalBill, Proposal__c prop, Integer n, Integer termMonths){
    //Sum(Utility_Service.[Before or After] Total Bill) * (1 + Annual Power Price Escalator) ^ (months/12)
    Double esc = getPercent(prop.get('Annual_Power_Price_Escalator__c'), Double.valueOf(0.04));
    Decimal result = totalBill * Math.pow(1 + esc, Math.floor(termMonths/12));
    return result.setScale(2);
  }

  //Proposal__c field: Scenario_N_EOT_Annual_Uty_Bill_Savings__c
  public Decimal calcEndOfTermAnnualUtilityBillSavings(String totalBeforeBill, Decimal totalAfterBill, Proposal__c prop, Integer n, Integer termMonths){
    Decimal EOT_before = calcEndOfTermAnnualUtilityBill(getSumFromSemicolonDelimitedList(totalBeforeBill), prop, n, termMonths);
    Decimal EOT_after = calcEndOfTermAnnualUtilityBill(totalAfterBill, prop, n, termMonths);
    return EOT_before - EOT_after;
  }

  //Proposal__c field: Scenario_N_Cumulative_Uty_Bill_Before__c
  public Decimal calcCumulativeUtilityBillBefore(Proposal__c prop, Integer n, Integer termMonths){
    Decimal cumulative = 0;
    Decimal monthlyBillBefore = nullDecimal(prop.get('Scenario_' + n + '_Year1_Mthly_Uty_Bill_Before__c'), 0);
    Double esc = getPercent(prop.get('Annual_Power_Price_Escalator__c'), Double.valueOf(0.04));
    for (Integer i = 1; i <= termMonths; i++){
      cumulative +=  monthlyBillBefore * Math.pow(Double.valueOf(1 + esc), Math.floor(i/12));
    }
    return cumulative;
  }

  //Proposal__c field: Scenario_N_Cumulative_Uty_Bill_After__c
  public Decimal calcCumulativeUtilityBillAfter(Proposal__c prop, Integer n, Integer termMonths){
    Decimal cumulative = 0;
    Decimal monthlyBillAfter = nullDecimal(prop.get('Scenario_' + n + '_Year1_Mthly_Uty_Bill_After__c'), 0);
    Double esc = getPercent(prop.get('Annual_Power_Price_Escalator__c'), Double.valueOf(0.04));
    for (Integer i = 1; i <= termMonths; i++){
      cumulative +=  monthlyBillAfter * Math.pow(Double.valueOf(1 + esc), Math.floor(i/12));
    }
    return cumulative;
  }

  //Proposal__c field: Scenario_N_Cumulative_Uty_Bill_Savings__c
  public Decimal calcCumulativeUtilityBillSavings(Proposal__c prop, Integer n, Integer termMonths){
    Decimal cumulativeBefore = calcCumulativeUtilityBillBefore(prop, n, termMonths);
    Decimal cumulativeAfter = calcCumulativeUtilityBillAfter(prop, n, termMonths);
    return cumulativeBefore - cumulativeAfter;
  }

  //Proposal__c field: Scenario_N_Payment_Due_Signing__c
  public Decimal calcPaymentDueSigning(System_Design_Quote__c sdq, String stateAbbrev, Integer n){
    try {
      Decimal payment = 0;
      if (stateAbbrev == 'CA'){
        payment = 1000;
      } else {
        payment = (nullDecimal(sdq.get('Scenario_' + n + '_Final_EPC_Price_NUM__c'), 0) - nullDecimal(sdq.get('Scenario_' + n + '_Installer_Paid_Incentive_Amt__c'), 0)) * 0.10;
      }
      return payment.setScale(2);
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return -1;
    }
  }

  //Proposal__c field: Scenario_N_Payment_Due_Installation__c
  public Decimal calcPaymentDueInstallation(System_Design_Quote__c sdq, String stateAbbrev, Integer n){
    try {
      Decimal payment = 0;
      if (stateAbbrev == 'CA'){
        payment = (nullDecimal(sdq.get('Scenario_' + n + '_Final_EPC_Price_NUM__c'), 0) - nullDecimal(sdq.get('Scenario_' + n + '_Installer_Paid_Incentive_Amt__c'), 0) - 1000) * 0.70;
      } else {
        payment = (nullDecimal(sdq.get('Scenario_' + n + '_Final_EPC_Price_NUM__c'), 0) - nullDecimal(sdq.get('Scenario_' + n + '_Installer_Paid_Incentive_Amt__c'), 0)) * 0.60;
      }
      return payment.setScale(2);
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return -1;
    }
  }

  //Proposal__c field: Scenario_N_Payment_Due_Final_Installation__c
  public Decimal calcPaymentDueFinalInspection(System_Design_Quote__c sdq, String stateAbbrev, Integer n){
    try {
      Decimal payment = 0;
      if (stateAbbrev == 'CA'){
        payment = (nullDecimal(sdq.get('Scenario_' + n + '_Final_EPC_Price_NUM__c'), 0) - nullDecimal(sdq.get('Scenario_' + n + '_Installer_Paid_Incentive_Amt__c'), 0) - 1000) * 0.30;
      } else {
        payment = (nullDecimal(sdq.get('Scenario_' + n + '_Final_EPC_Price_NUM__c'), 0) - nullDecimal(sdq.get('Scenario_' + n + '_Installer_Paid_Incentive_Amt__c'), 0)) * 0.30;
      }
      return payment.setScale(2);
    } catch (Exception e){
      System.debug('Error in ProposalProcessor on line ' + e.getLineNumber() + ': ' + e);
      return -1;
    }
  }

  public Decimal calcSolarElectricRate(Proposal__c prop, System_Design_Quote__c sdq, System_Design__c sd, Integer n, Integer termMonths){
    String financingType = sdq.get('Scenario_' + n + '_Financing_Type__c') != null ? (String)sdq.get('Scenario_' + n + '_Financing_Type__c') : '';
    ID termLoan = (ID)sdq.get('Scenario_' + n + '_Term_Loan__c');
    Decimal result = 0;
    if (financingType == 'Purchase' && termLoan == null){
      Decimal cashOutlay = nullDecimal(sdq.get('Scenario_' + n + '_Net_Initial_Outlay__c'), 0);
      //cashOutlay = -1 * Math.abs(cashOutlay);
      Decimal presentValueOfSrecEarnings = getPresentValueOfSrecEarnings(prop, sdq, n, termMonths);
      Decimal cumulativeProduction = getCumulativeElectricityProduction(prop, sd, n, termMonths);
      if (cumulativeProduction != 0)
        result = (cashOutlay - presentValueOfSrecEarnings) / cumulativeProduction;
    } else if (financingType == 'Purchase' && termLoan != null){
      Decimal firstMonthPayment = nullDecimal(sdq.get('Scenario_' + n + '_First_Month_Payment__c'), 0);
      Decimal[] yearOneSrecEarningsArr = getAnnualSrecEarnings(prop, sdq, n, 12);
      System.debug('yearOneSrecEarningsArr '+yearOneSrecEarningsArr);
      Decimal yearOneSrecEarnings = yearOneSrecEarningsArr.isEmpty() ? 0 : yearOneSrecEarningsArr[0];
      Double discRate = getPercent(prop.get('Proposal_Discount_Rate__c'), Double.valueOf(0.02));
      Decimal projAnnualOutput = nullDecimal(sdq.get('Scenario_'+n+'_Total_Projected_Annual_Output__c'), 0);
      if (projAnnualOutput != 0)
        result = ((12.0 * firstMonthPayment) - (yearOneSrecEarnings * (1 - discRate))) / projAnnualOutput;
    } else {
      result = nullDecimal(sdq.get('Scenario_' + n + '_Financing_Rate_Year_1_kWh__c'), 0);
    }
    return result;
  }

  private String getScenarioFinancingPlan(System_Design_Quote__c sdq, Integer n){
    String financingType = sdq.get('Scenario_' + n + '_Financing_Type__c') != null ? (String)sdq.get('Scenario_' + n + '_Financing_Type__c') : '';
    ID termLoan = (ID)sdq.get('Scenario_' + n + '_Term_Loan__c');
    String leaseOption = sdq.get('Scenario_' + n + '_Lease_Option__c') != null ? (String)sdq.get('Scenario_' + n + '_Lease_Option__c') : '';
    String returnStr = '';

    if (financingType == 'Purchase' && termLoan == null){
      returnStr = 'Solar Purchase Plan';
    } else if ((financingType == 'Lease' || financingType == 'PPA') && (leaseOption == 'Low-Upfront - Monthly' || leaseOption == 'Low-Upfront - Massachusetts' || leaseOption == 'Low-Upfront - Monthly - Keep SRCs' || leaseOption == 'Fixed-Rate PPA' || leaseOption == 'Portfolio PPA')){
      returnStr = 'Monthly Savings Plan';
    } else if (financingType == 'Purchase' && termLoan != null){
      returnStr = 'Solar Finance Plan';
    } else if ((financingType == 'Lease' || financingType == 'PPA') && (leaseOption == 'One-Pay' || leaseOption == 'One-Pay - Keep SRECs' || leaseOption == 'One-Pay - Massachusetts')){
      returnStr = 'One Pay Plan';
    }
    return returnStr;
  }

  private static Decimal nullDecimal(Object obj, Decimal defaultVal){
    Decimal val = obj != null ? (Decimal)obj : defaultVal;
    return val;
  }
  
  private static Double getPercent(Object obj, Double defaultVal){
    Double val = (Double)obj;
    if (val != null){
      val = val/100;
    } else {
      val = defaultVal;
    }
    return val;
  }
}