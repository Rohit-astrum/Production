/* FILE: SalesWorkflowValidationUtility.cls
 * AUTHOR: Rohit Jain and Dan Kelner
 * DATE: Oct 8, 2014
 * PURPOSE: Validation Class for Sales Workflow
 * MODIFICATION HISTORY
 *    07/01/15  PB  cpq-590 Assign System Makeup value to new SDQ  
 *    07/16/15  DK  CPQ-619. Apply min/max loan amount validations to all Term Loans rather of solely Hudson.
 *    12/14/15  DK  In order to implement date-sensitive Pricing Regions on Utility by Zip Code records for CPQ-751, runSystemDesignValidations() was updated with a date parameter.
 */
public without sharing class SalesWorkflowValidationUtility {   
    
    public static String validationFieldsForSDQ = 'System_Design_Stored_State__c, System_Design_Stored_State_Mismatch__c, System_Design_Reconstruction_Record__c, ' + 
                                        'Sys_Design_Reconstruct_Record_Mismatch__c, Current__c, Valid__c, All_Electric_Service__c, Validation_Errors__c, Pricing_Date__c, ' + 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.All_Electric_Service__c, ' +
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__r.All_Electric_Service__c, ' +
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Name, System_Design__r.Overall_TSRF__c, ' + 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__r.Default_Rate_Code__c, ' + 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Has_Service_Territories__c, ' + 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.KW_Eligible__c, ' + 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c, ' + 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Avoided_Utility_Rate__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c, ' + 
                                        'System_Design__r.Default_CB_Panel__r.Name, System_Design__r.System_Inverter__r.Make__c, System_Design__r.Property__r.RecordType.DeveloperName, ' +
                                        'System_Design__r.System_Inverter__r.RecordType.DeveloperName, Disqualifying_Validation_Errors__c, Annual_Electricity_Consumption_kWh__c, ' +
                                        'System_Design__r.Property__c, System_Design__r.Property__r.Property_State__c, System_Size_kW__c, Scenario_1_Down_Payment__c, Scenario_2_Down_Payment__c, ' +
                                        'Scenario_3_Down_Payment__c, Scenario_4_Down_Payment__c, Scenario_1_Financing_Rate_Year_1_kWh__c, Scenario_2_Financing_Rate_Year_1_kWh__c, ' +
                                        'Scenario_3_Financing_Rate_Year_1_kWh__c, Scenario_4_Financing_Rate_Year_1_kWh__c, Scenario_1_Lease_Escalator__c, ' +
                                        'Scenario_2_Lease_Escalator__c, Scenario_3_Lease_Escalator__c, Scenario_4_Lease_Escalator__c, Scenario_1_Total_Projected_Annual_Output__c, ' +
                                        'Scenario_2_Total_Projected_Annual_Output__c, Scenario_3_Total_Projected_Annual_Output__c, Scenario_4_Total_Projected_Annual_Output__c, ' + 
                                        'Scenario_1_Final_EPC_Price__c, Scenario_2_Final_EPC_Price__c, Scenario_3_Final_EPC_Price__c, Scenario_4_Final_EPC_Price__c, ' + 
                                        'Scenario_1_Lease_Fund__r.Eligible_Panels__c, Scenario_2_Lease_Fund__r.Eligible_Panels__c, Scenario_3_Lease_Fund__r.Eligible_Panels__c, Scenario_4_Lease_Fund__r.Eligible_Panels__c, ' + 
                                        'Scenario_1_Lease_Fund__r.Eligible_States__c, Scenario_2_Lease_Fund__r.Eligible_States__c, Scenario_3_Lease_Fund__r.Eligible_States__c, Scenario_4_Lease_Fund__r.Eligible_States__c, ' + 
                                        'Scenario_1_Lease_Fund__r.Name, Scenario_2_Lease_Fund__r.Name, Scenario_3_Lease_Fund__r.Name, Scenario_4_Lease_Fund__r.Name, ' + 
                                        'Scenario_1_Lease_Fund__r.Minimum_TSRF__c, Scenario_2_Lease_Fund__r.Minimum_TSRF__c, Scenario_3_Lease_Fund__r.Minimum_TSRF__c, Scenario_4_Lease_Fund__r.Minimum_TSRF__c, ' + 
                                        'Scenario_1_Term_Loan_Amount__c, Scenario_2_Term_Loan_Amount__c, Scenario_3_Term_Loan_Amount__c, Scenario_4_Term_Loan_Amount__c, Scenario_1_SAC_Loan_Amount__c, Scenario_2_SAC_Loan_Amount__c, ' + 
                                        'Scenario_3_SAC_Loan_Amount__c, Scenario_4_SAC_Loan_Amount__c, Scenario_1_SAC_Loan__r.Maximum_Term_Loan_Amount__c, Scenario_2_SAC_Loan__r.Maximum_Term_Loan_Amount__c, ' + 
                                        'Scenario_3_SAC_Loan__r.Maximum_Term_Loan_Amount__c, Scenario_4_SAC_Loan__r.Maximum_Term_Loan_Amount__c, Scenario_1_SAC_Loan__r.Required_Utility_Savings__c, ' + 
                                        'Scenario_2_SAC_Loan__r.Required_Utility_Savings__c, Scenario_3_SAC_Loan__r.Required_Utility_Savings__c, Scenario_4_SAC_Loan__r.Required_Utility_Savings__c, ' + 
                                        'Scenario_1_SAC_Loan__r.Required_Utility_Savings_Term__c, Scenario_2_SAC_Loan__r.Required_Utility_Savings_Term__c, Scenario_3_SAC_Loan__r.Required_Utility_Savings_Term__c, ' + 
                                        'Scenario_4_SAC_Loan__r.Required_Utility_Savings_Term__c, Scenario_1_SAC_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, ' + 
                                        'Scenario_2_SAC_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, Scenario_3_SAC_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, ' + 
                                        'Scenario_4_SAC_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, Scenario_1_SAC_Loan__r.Overproduction_Allowed__c, Scenario_2_SAC_Loan__r.Overproduction_Allowed__c, ' + 
                                        'Scenario_3_SAC_Loan__r.Overproduction_Allowed__c, Scenario_4_SAC_Loan__r.Overproduction_Allowed__c, Scenario_1_SAC_Loan__r.Minimum_Term_Loan_Amount__c, ' + 
                                        'Scenario_2_SAC_Loan__r.Minimum_Term_Loan_Amount__c, Scenario_3_SAC_Loan__r.Minimum_Term_Loan_Amount__c, Scenario_4_SAC_Loan__r.Minimum_Term_Loan_Amount__c, ' + 
                                        'Scenario_1_SAC_Loan__r.Related_Finance_Record__r.Maximum_Term_Loan_Amount__c, Scenario_2_SAC_Loan__r.Related_Finance_Record__r.Maximum_Term_Loan_Amount__c, ' + 
                                        'Scenario_3_SAC_Loan__r.Related_Finance_Record__r.Maximum_Term_Loan_Amount__c, Scenario_4_SAC_Loan__r.Related_Finance_Record__r.Maximum_Term_Loan_Amount__c, ' + 
                                        'Scenario_1_SAC_Loan__r.RecordTypeDeveloperName__c, Scenario_2_SAC_Loan__r.RecordTypeDeveloperName__c, Scenario_3_SAC_Loan__r.RecordTypeDeveloperName__c, ' + 
                                        'Scenario_4_SAC_Loan__r.RecordTypeDeveloperName__c, Scenario_1_SAC_Loan__r.Min_Finance_Percent_of_Price__c, Scenario_2_SAC_Loan__r.Min_Finance_Percent_of_Price__c, ' + 
                                        'Scenario_3_SAC_Loan__r.Min_Finance_Percent_of_Price__c, Scenario_4_SAC_Loan__r.Min_Finance_Percent_of_Price__c, Scenario_1_SAC_Loan__r.Max_Finance_Percent_of_Price__c, ' + 
                                        'Scenario_2_SAC_Loan__r.Max_Finance_Percent_of_Price__c, Scenario_3_SAC_Loan__r.Max_Finance_Percent_of_Price__c, Scenario_4_SAC_Loan__r.Max_Finance_Percent_of_Price__c, ' +
                                        'Scenario_1_Term_Loan__r.Name, Scenario_2_Term_Loan__r.Name, Scenario_3_Term_Loan__r.Name, Scenario_4_Term_Loan__r.Name, ' + 
                                        'Scenario_1_Term_Loan__r.Maximum_Term_Loan_Amount__c, Scenario_2_Term_Loan__r.Maximum_Term_Loan_Amount__c, Scenario_3_Term_Loan__r.Maximum_Term_Loan_Amount__c, ' + 
                                        'Scenario_4_Term_Loan__r.Maximum_Term_Loan_Amount__c, Scenario_1_Term_Loan__r.Maximum_Project_Cost__c, Scenario_2_Term_Loan__r.Maximum_Project_Cost__c, Scenario_3_Term_Loan__r.Maximum_Project_Cost__c, ' + 
                                        'Scenario_4_Term_Loan__r.Maximum_Project_Cost__c, Scenario_1_Term_Loan__r.Minimum_Project_Cost__c, Scenario_2_Term_Loan__r.Minimum_Project_Cost__c, Scenario_3_Term_Loan__r.Minimum_Project_Cost__c, ' + 
                                        'Scenario_4_Term_Loan__r.Minimum_Project_Cost__c, Scenario_1_Term_Loan__r.Required_Utility_Savings__c, Scenario_2_Term_Loan__r.Required_Utility_Savings__c, ' + 
                                        'Scenario_3_Term_Loan__r.Required_Utility_Savings__c, Scenario_4_Term_Loan__r.Required_Utility_Savings__c, Scenario_1_Term_Loan__r.Required_Utility_Savings_Term__c, ' + 
                                        'Scenario_2_Term_Loan__r.Required_Utility_Savings_Term__c, Scenario_3_Term_Loan__r.Required_Utility_Savings_Term__c, Scenario_4_Term_Loan__r.Required_Utility_Savings_Term__c, ' + 
                                        'Scenario_1_Term_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, Scenario_2_Term_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, ' + 
                                        'Scenario_3_Term_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, Scenario_4_Term_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, ' + 
                                        'Scenario_1_Term_Loan__r.Overproduction_Allowed__c, Scenario_2_Term_Loan__r.Overproduction_Allowed__c, Scenario_3_Term_Loan__r.Overproduction_Allowed__c, ' + 
                                        'Scenario_4_Term_Loan__r.Overproduction_Allowed__c, Scenario_1_Term_Loan__r.Minimum_Term_Loan_Amount__c, Scenario_2_Term_Loan__r.Minimum_Term_Loan_Amount__c, ' + 
                                        'Scenario_3_Term_Loan__r.Minimum_Term_Loan_Amount__c, Scenario_4_Term_Loan__r.Minimum_Term_Loan_Amount__c, Scenario_1_Term_Loan__r.RecordTypeDeveloperName__c, ' + 
                                        'Scenario_2_Term_Loan__r.RecordTypeDeveloperName__c, Scenario_3_Term_Loan__r.RecordTypeDeveloperName__c, Scenario_4_Term_Loan__r.RecordTypeDeveloperName__c, ' + 
                                        'Scenario_1_Term_Loan__r.Eligible_States__c, Scenario_2_Term_Loan__r.Eligible_States__c, Scenario_3_Term_Loan__r.Eligible_States__c, Scenario_4_Term_Loan__r.Eligible_States__c, ' + 
                                        'Scenario_1_Term_Loan__r.Min_Finance_Percent_of_Price__c, Scenario_2_Term_Loan__r.Min_Finance_Percent_of_Price__c, Scenario_3_Term_Loan__r.Min_Finance_Percent_of_Price__c, ' + 
                                        'Scenario_4_Term_Loan__r.Min_Finance_Percent_of_Price__c, Scenario_1_Term_Loan__r.Max_Finance_Percent_of_Price__c, Scenario_2_Term_Loan__r.Max_Finance_Percent_of_Price__c, ' + 
                                        'Scenario_3_Term_Loan__r.Max_Finance_Percent_of_Price__c, Scenario_4_Term_Loan__r.Max_Finance_Percent_of_Price__c, Scenario_1_First_Month_Payment__c, ' + 
                                        'Scenario_2_First_Month_Payment__c, Scenario_3_First_Month_Payment__c, Scenario_4_First_Month_Payment__c ,'+
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Production_kWh__c, '+
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh__c, System_Design__r.Total_Projected_Annual_Output_kWh_y__c, '+ 
                                        'Scenario_1_Lease_Fund__r.Required_Utility_Savings__c, Scenario_2_Lease_Fund__r.Required_Utility_Savings__c, Scenario_3_Lease_Fund__r.Required_Utility_Savings__c, Scenario_4_Lease_Fund__r.Required_Utility_Savings__c, '+
                                        'Scenario_1_Lease_Fund__r.Required_Utility_Savings_Term__c, Scenario_2_Lease_Fund__r.Required_Utility_Savings_Term__c, Scenario_3_Lease_Fund__r.Required_Utility_Savings_Term__c, Scenario_4_Lease_Fund__r.Required_Utility_Savings_Term__c, '+
                                        'Scenario_1_Proposal_Term_Months__c, Scenario_2_Proposal_Term_Months__c, Scenario_3_Proposal_Term_Months__c, Scenario_4_Proposal_Term_Months__c, ' + 
                                        'Scenario_1_FIT_Annual_Earnings_After_Tax__c, Scenario_2_FIT_Annual_Earnings_After_Tax__c, Scenario_3_FIT_Annual_Earnings_After_Tax__c, Scenario_4_FIT_Annual_Earnings_After_Tax__c, ' +
                                        'Scenario_1_Term_Loan__r.Sighten_Product_uuid__c, Scenario_2_Term_Loan__r.Sighten_Product_uuid__c, Scenario_3_Term_Loan__r.Sighten_Product_uuid__c, Scenario_4_Term_Loan__r.Sighten_Product_uuid__c';

    public static System_Design__c runSystemDesignValidations(System_Design__c sysDesign, Date pricingDate)
    {
        
        sysDesign = [Select Property__r.Property_ZIP__c,Property__r.Property_State__c,Property__r.Property_County__c,Property__r.QAS_Property_County__c
                            ,Panel_Count__c,Astrum_SQ_Calculation_Status__c,Trenching_Required__c,Includes_Outbuilding_Installation__c,Trench_Length__c
                            ,Property__r.RecordType.DeveloperName,Total_System_Size_kW__c,Validation_errors__c, Valid__c, Property__r.Community_Program_Offer__c 
                            ,Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c 
                         From System_Design__c where id = :sysDesign.Id];

        System.debug(sysDesign);
        Set<ID> panelSdpIds = new Set<ID>();
        Set<ID> nonPanelSdpIds = new Set<ID>();
        List<System_Design_Item__c> panelItems = new List<System_Design_Item__c>();
        List<System_Design_Item__c> nonPanelItems = new List<System_Design_Item__c>();
        List<System_Design_Item__c> trenchingItems = new List<System_Design_Item__c>();
        decimal systemSizeKW = sysDesign.Total_System_Size_kW__c ;


        Boolean isSoil = false;
        Boolean isNullUtility = false;
        Boolean isUpgradeValid = false;
        String errorLog = '';
        sysDesign.validation_errors__c =  '';
        Id pricingRegion;
        string propState;       
        // System Design should be linked to Property
        if (sysDesign.Property__c == null){          
            errorLog += '\n- Error: Property not linked to System Design';            
        } else {
            
            Date cutoffDate = System_Design_Quote_Settings__c.getOrgDefaults().County_Pricing_Region_Cutoff_Date__c;
            if (cutoffDate != null && pricingDate < cutoffDate){   //Pricing date will either be Date.today() or SDQ.Pricing_Date__c
                system.debug('***Query for County');
                //Need to try to set the pricing region ID
                propState = sysDesign.Property__r.Property_State__c;
                string county = sysDesign.Property__r.Property_County__c;
                string qasCounty = sysDesign.Property__r.QAS_Property_County__c;

                if (propState != null && (propState == 'DC' || county != null || qasCounty != null)){

                    String crit = '(State_Abbreviation__c = \'' + String.escapeSingleQuotes(propState) + '\'';
                    if (propState != 'DC')
                        crit += ' AND Name LIKE \'' + String.escapeSingleQuotes(qasCounty != null ? qasCounty : SalesRegionHelper.removeState(county)) + '%\'';
                    
                    crit += ')';    
                    string query = 'SELECT id, Name, Pricing_Region__c FROM County__c ';
                    query+= ' WHERE ' + crit + ' limit 1';
                    list<County__c> counties = database.query(query);
                    if (counties.isempty()){
                        errorLog += '\n- Error: County record not found for Property.';                    
                    } else {                    
                        if (counties[0].Pricing_Region__c == null){
                            errorLog += '\n- Error: Pricing Region is not set in the County: ' + counties[0].Name + '';                            
                        } else {
                            pricingRegion = counties[0].Pricing_Region__c;
                        }
                    }
                }
                else{
                    errorLog += '\n- Error: Missing State/County information in Property. Cannot lookup the county.';
                    system.debug('24'+errorLog);
                }
            } else if (cutoffDate != null && sysDesign.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c != null){    //CPQ-751
                String zip = sysDesign.Property__r.Property_ZIP__c.substring(0,5);
                ID utilCompanyID = sysDesign.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c;
                Utility_by_Zip_Code__c[] utilByZips = [SELECT Pricing_Region__c FROM Utility_by_Zip_Code__c WHERE Utility_Zip_Code__c = :zip AND Utility_Company_Master__c = :utilCompanyID 
                                                        AND Start_Date__c <= :pricingDate AND (End_Date__c = null OR End_Date__c >= :pricingDate)];
                if (utilByZips.isEmpty()){
                    errorLog += '\n- Error: Could not find any "Utility by Zip Code" records with a zip code of ' + zip + ', utility company matching the System Design\'s, ' + 
                                'and a start/end date range containing ' + pricingDate.format() + '.';
                } else if (utilByZips.size() > 1){
                    errorLog += '\n- Error: Found more than one "Utility by Zip Code" record with a zip code of ' + zip + ', utility company matching the System Design\'s, ' + 
                                'and a start/end date range containing ' + pricingDate.format() + '.';
                } else {
                    pricingRegion = utilByZips[0].Pricing_Region__c;
                }
            } else if (cutoffDate != null){
                errorLog += '\n- Error: Utility Company Master must be set on the Utility Service record in order to obtain Pricing Region.';
            } else {
                errorLog += '\n- Error: County Pricing Region Cutoff Date must be set in the System Design Quote Settings.';
            }
        }

        if(isNullUtility){
            system.debug('Utility Company can not be null at Utility Service.');
            errorLog += '\n- Error: Utility Company can not be null at Utility Service.';
        }

        if(sysDesign.Panel_Count__c == null || sysDesign.Panel_Count__c < 4 || sysDesign.Panel_Count__c > 400 ){
            system.debug('Minimum of 4 panels and Maximum of 400 Panels is allowed on System Design.');
            errorLog += '\n- Error: Minimum of 4 panels and Maximum of 400 Panels is allowed on System Design.';
        }

        if(sysDesign.Astrum_SQ_Calculation_Status__c != 'Valid' ){
            system.debug(loggingLevel.ERROR, 'Overall Site Quality is not valid for this System Design.');
            errorLog += '\n- Error: Overall Site Quality is not valid for this System Design. Please Recall Site Quality and Complete the Design.';
        }

        List<System_Design_Item__c> sditems = new List<System_Design_Item__c>();
        List<System_Design_Item__c> specialParts = new List<System_Design_Item__c>();
        Set<ID> arraysWithPanelCounts = new Set<ID>();
        System_Design_Item__c multipleRoofArraysItm;
        //System_Design_Item__c reinforcingRaftersItm;
        for (System_Design_Item__c sdi : [Select System_Design_Product__r.Description__c, System_Design_Product__r.RecordType.DeveloperName, System_Design_Product__r.Name, 
                                                System_Design_Array__r.System_Design__c, System_Design_Array__c, Rated_Output_kW__c, Quantity__c,  
                                                RecordType.DeveloperName, System_Design_Array__r.Array_Size_kW__c, System_Design_Array__r.Panel_Count__c, 
                                                System_Design_Array__r.Total_Trenching_Length_ft__c, System_Design_Product__r.Wire_Type__c, 
                                                System_Design_Array__r.Physical_Surface__r.Surface_Type__c, System_Design_Array__r.CB_Panel__r.Utility_Service__r.Utility_Company__c, 
                                                System_Design_Array__r.CB_Panel__r.Upgrade_Required__c, System_Design_Array__r.CB_Panel__r.Upgrade_Valid__c
                                            From System_Design_Item__c 
                                            Where System_Design_Array__r.System_Design__c = :sysDesign.id
                                            AND RecordType.DeveloperName IN ('Panel', 'Inverter', 'Mounting', 'Special_Part', 'Trenching', 'Entitlement')]){
            if (sdi.Quantity__c != null && sdi.Quantity__c > 0)
                sditems.add(sdi);
            if (sdi.RecordType.DeveloperName == 'Special_Part'){
                specialParts.add(sdi);
                if (sdi.System_Design_Product__r.Description__c == 'Multiple Roof Arrays'){
                    multipleRoofArraysItm = sdi;
                }/* else if (sdi.System_Design_Product__r.Description__c == 'Reinforcing Rafters'){
                    reinforcingRaftersItm = sdi;
                }*/
            }
            if (sdi.System_Design_Array__r.Panel_Count__c != null && sdi.System_Design_Array__r.Panel_Count__c > 0)
                arraysWithPanelCounts.add(sdi.System_Design_Array__c);
        }
        
        if(sditems.isempty()){ 
            system.debug('no items');
            errorLog += '\n- Error: No System Design Items';
        }else{
            //Split the SDI's into different lists which will be calculated in groups
            for(System_Design_Item__c sdi : sditems){
                // Get the list of Panel and Non-Panel Ids
                if(sdi.RecordType.DeveloperName == 'Panel'){
                    if(sdi.System_Design_Array__r.Physical_Surface__r.Surface_Type__c == 'Soil')
                    {
                        isSoil = true;
                    }
                    if(sdi.System_Design_Array__r.CB_Panel__r.Utility_Service__r.Utility_Company__c == null)
                    {
                        isNullUtility = true;
                    }
                    if(sdi.System_Design_Array__r.CB_Panel__r.Upgrade_Required__c && sdi.System_Design_Array__r.CB_Panel__r.Upgrade_Valid__c)
                    {
                        isUpgradeValid = true;
                    }
                    if(sdi.Quantity__c > 0){
                        panelSdpIds.add(sdi.System_Design_Product__c); 
                        panelItems.add(sdi);                         
                    }
                }
                else{               

                    if(sdi.RecordType.DeveloperName == 'Trenching' && sdi.System_Design_Product__r.RecordType.DeveloperName == 'Trenching'){
                        //Get the Trenching items. Only 1 should exist per array and this will be enforced.
                        trenchingItems.add(sdi);
                    }else{          
                        //Get non-panel items
                        //Trenching Items would be included here if there was a community program offer
                        nonPanelSdpIds.add(sdi.System_Design_Product__c);
                        nonPanelItems.add(sdi);
                    }
                }   
            }
        }

        //** Get the total panel count of ENTIRE SYSTEM, and the price for EACH TYPE OF PANEL at that qty.
        if (sysDesign.Panel_Count__c != null && (sysDesign.Panel_Count__c >= 4 || sysDesign.Panel_Count__c <= 400)){  

            string pricing_soql = 'Select Panel_Type__c, Panel_Type__r.Name, Count_' + sysDesign.Panel_Count__c + '_Root_Price__c, Pricing_Region__c,'
                                      + ' Start_Date__c, End_Date__c FROM System_Pricing_Table__c Where Panel_Type__c IN :panelSdpIds ';
                                    //  + ' AND Pricing_Region__c = :pricingRegion  ' 
                                    //  + ' AND Start_Date__c <= TODAY AND (End_Date__c = null OR End_Date__c >= TODAY) ';
 
            List<System_Pricing_Table__c> pricingTable = Database.query(pricing_soql);  //Will be filtered to narrow down results
            List<System_Pricing_Table__c> filteredPricingTable = new List<System_Pricing_Table__c>();
            
            if (pricingTable == null || pricingTable.size() == 0){
                errorLog += '\n- Error: No System Pricing Tables were found for any Panel Types used in this System Design. Please resolve and re-validate the system.';             
            } else {
                for (System_Pricing_Table__c spt : pricingTable){
                    if (spt.Pricing_Region__c == pricingRegion && spt.Start_Date__c <= pricingDate && (spt.End_Date__c == null || spt.End_Date__c >= pricingDate))
                        filteredPricingTable.add(spt);  //These records actually fit the criteria
                }

                if (!filteredPricingTable.isEmpty()){
                    Map<Id, System_Pricing_Table__c> sdpPricingMap = new Map<Id, System_Pricing_Table__c>();
                    for (System_Pricing_Table__c spt : filteredPricingTable){               
                       sdpPricingMap.put(spt.Panel_Type__c, spt);
                    }

                    for (System_Design_Item__c sdi : panelItems){   //Get the matching price entry from the map             
                        System_Pricing_Table__c systemPriceTable = sdpPricingMap.get(sdi.System_Design_Product__c);
                        if (systemPriceTable == null)
                            errorLog += '\n- Error: Could not find matching System Pricing Table entry for "' + sdi.System_Design_Product__r.Description__c + '" where the pricing region is ' +
                                        'associated with the proper county and the start/end date range includes today`s date.';    
                    }
                }
            }    
        }

        if (nonPanelSdpIds.size() > 0){
            string propRecordTypeName = sysDesign.Property__r.RecordType.DeveloperName;
            string pricing_soql = 'Select System_Design_Product__c, System_Design_Product__r.Name, Minimum_Size_kW__c, Maximum_Size_kW__c,'
                                      + ' Start_Date__c, End_Date__c FROM SDP_Price_Entry__c '
                                      + ' WHERE System_Design_Product__c IN :nonPanelSdpIds '
                                      + ' AND Property_Record_Type__c = :propRecordTypeName ';
                                    //  + ' AND Minimum_Size_kW__c <= :systemSizeKW '
                                    //  + ' AND Maximum_Size_kW__c > :systemSizeKW ' 
                                    //  + ' AND Start_Date__c <= TODAY AND (End_Date__c = null OR End_Date__c >= TODAY) ';

            List<SDP_Price_Entry__c> priceEntryTable = Database.query(pricing_soql);    //Will be filtered to narrow down results
            List<SDP_Price_Entry__c> filteredPriceEntries = new List<SDP_Price_Entry__c>();
            
            if (priceEntryTable == null || priceEntryTable.size() == 0){
                 errorLog += '\n- Error: No Price Entries were found for any Non-Panel Items used in this System Design. (With Property record type: ' + propRecordTypeName + ')';      
            } else {
                for (SDP_Price_Entry__c spe : priceEntryTable){
                    if (spe.Minimum_Size_kW__c <= systemSizeKW && spe.Maximum_Size_kW__c > systemSizeKW && spe.Start_Date__c <= pricingDate && (spe.End_Date__c == null || spe.End_Date__c >= pricingDate))
                        filteredPriceEntries.add(spe);  //These are the price entries that actually fit the criteria
                }

                if (!filteredPriceEntries.isEmpty()){
                    //create map of Price entries key'd on the product ID
                    Map<Id, SDP_Price_Entry__c> sdpPriceEntryMap = new Map<Id, SDP_Price_Entry__c>();                
                    for (SDP_Price_Entry__c spe : filteredPriceEntries){
                        sdpPriceEntryMap.put(spe.System_Design_Product__c, spe);                    
                    }

                    //Calculate and add price to full nonpanel price
                    for (System_Design_Item__c sdi : nonPanelItems){
                        SDP_Price_Entry__c priceEntry = sdpPriceEntryMap.get(sdi.System_Design_Product__c);
                        if (priceEntry == null)
                            errorLog += '\n- Error: Could not find matching pricing record for "' + sdi.System_Design_Product__r.RecordType.DeveloperName + ': ' + 
                                        sdi.System_Design_Product__r.Description__c + '" where the minimum/maximum kW size range includes ' + 
                                        'the total size of the System Design and the start/end date range includes today`s date.'; 
                    }
                }
            }
        }

        for(System_Design_Item__c sdi : trenchingItems){           
            //SOQL here within for loop is the best way.  It's the only way to get around SOQL'ing all 3,000+ table records and looping to find a match which would be slow.
            List<Trenching_Table__c> trenchingTable = [Select id, Adder__c, Adder_W__c
                                                         From Trenching_Table__c 
                                                        where Wire_Type__c =: sdi.System_Design_Product__r.Wire_Type__c                                                          
                                                          AND Minimum_Trench_Length__c <: (sdi.System_Design_Array__r.Total_Trenching_Length_ft__c / sdi.Quantity__c) 
                                                          AND Maximum_Trench_Length__c >=: (sdi.System_Design_Array__r.Total_Trenching_Length_ft__c / sdi.Quantity__c)
                                                          AND Minimum_Size__c <: sdi.System_Design_Array__r.Array_Size_kW__c                                                              
                                                          AND Maximum_Size__c >=: sdi.System_Design_Array__r.Array_Size_kW__c
                                                          AND Start_Date__c <= :pricingDate 
                                                          AND (End_Date__c = null OR End_Date__c >= :pricingDate)
                                                        limit 1];
            
            if(trenchingTable == null || trenchingTable.isEmpty()){
                errorLog += '\n- Error: No Data found for Trenching Items used in this System Design at Trenching table.';
            }
        } 

        if((sysDesign.Trenching_Required__c || sysDesign.Includes_Outbuilding_Installation__c || isSoil)  && (sysDesign.Trench_Length__c == null || sysDesign.Trench_Length__c < 1) ){
            system.debug('When Includes Outbuilding Installation is TRUE, Trenching is Required is TRUE or Surface Type is SOIL, Trenching length must be greater than 1ft. Please edit the System Design.');
            errorLog += '\n- Error: When Includes Outbuilding Installation is TRUE, Trenching is Required is TRUE or Surface Type is SOIL, Trenching length must be greater than 1ft. Please edit the System Design.';
        }      

        if(isUpgradeValid)
        {
            //List<System_Design_Item__c> serviceItems = [Select id
            //                                     From System_Design_Item__c s 
            //                                    Where s.System_Design_Array__r.System_Design__c = :sysDesign.id                                                 
            //                                      AND s.RecordType.DeveloperName = 'Special_Part'
            //                                      AND s.System_Design_Product__r.Description__c like 'Service Upgrade%'];
                                                  
            //if (serviceItems == null || serviceItems.size() == 0){
            //    //saveDetail('', true, scenarioN, 'Error: No results in query.');
            //    errorLog += '\n- Error: Service Upgrade Special Part is required for this System Design.';              
            //}

            Boolean foundServiceItem = false;
            for (System_Design_Item__c sdItem : nonPanelItems){
                if (sdItem.RecordType.DeveloperName == 'Special_Part' && sdItem.System_Design_Product__r.Description__c != null && 
                    sdItem.System_Design_Product__r.Description__c.startsWithIgnoreCase('Service Upgrade')){

                    foundServiceItem = true;
                    break;
                }
            }

            if (!foundServiceItem)
                errorLog += '\n- Error: Service Upgrade Special Part is required for this System Design.';
        }

        //Product Adder Junction check. If this Property has a Community Program, ensure that this System Design uses the required SDP's, if there are any.
        if (sysDesign.Property__r.Community_Program_Offer__c != null){
            Product_Adder_Junction__c[] prodAdders = [SELECT Required_System_Design_Product__r.Description__c FROM Product_Adder_Junction__c
                                                      WHERE Required__c = true AND Required_System_Design_Product__c != null AND 
                                                      Community_Program_Adder__c = :sysDesign.Property__r.Community_Program_Offer__c];
            Set<ID> includedProds = new Set<ID>();
            for (System_Design_Item__c sdi : specialParts){     //This could include SDIs with Quantity field values of zero
                includedProds.add(sdi.System_Design_Product__c);
            }
            String missingProds = '';
            for (Product_Adder_Junction__c paj : prodAdders){
                ID requiredProd = paj.Required_System_Design_Product__c;
                if (!includedProds.contains(requiredProd))
                    missingProds += paj.Required_System_Design_Product__r.Description__c + ', ';
            }
            if (missingProds != ''){   //Required SDPs are missing from this System Design
                missingProds = missingProds.removeEnd(', ');
                errorLog += '\n- Error: The following Adders are required on System Design for this Community Program:' + missingProds;
            }
        }

        if (multipleRoofArraysItm != null){
            if (multipleRoofArraysItm.Quantity__c == null || multipleRoofArraysItm.Quantity__c != arraysWithPanelCounts.size() - 1)
                errorLog += '\n- Error: The quantity of the "Multiple Roof Arrays" special part must be one fewer than the count of arrays with panels (' + (arraysWithPanelCounts.size() - 1) + ').';
        }

        //if (reinforcingRaftersItm != null){
        //    if (reinforcingRaftersItm.Quantity__c == null || reinforcingRaftersItm.Quantity__c == 0)
        //        errorLog += '\n- Error: The quantity of the "Reinforcing Rafters" special part must be greater than 0';
        //}

        if (errorLog != null && errorLog.length() > 0){
            sysDesign.validation_errors__c = errorLog;   
            sysDesign.valid__c = false;            
            return sysDesign;
        }
        else
        {
            sysDesign.valid__c = true;
            return sysDesign;
        }
    }

    public static System_Design_Quote__c systemDesignQuoteWorkflowOnCreate(System_Design__c sysDesign, Boolean insertSDQ){
         return systemDesignQuoteWorkflowOnCreate(sysDesign.Id, insertSDQ);
    }

    
    public static System_Design_Quote__c systemDesignQuoteWorkflowOnCreate(System_Design__c sysDesign){
        return systemDesignQuoteWorkflowOnCreate(sysDesign.Id, true);
    }

    public static System_Design_Quote__c systemDesignQuoteWorkflowOnCreate(Id sysDesign, Boolean insertSDQ){
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sysDesign;        
        
        //Stored state serialization
        serializeStoredStateSDQ(sdq);
        
        //Reconstruction serialization
        serializeReconstructionSDQ(sdq);
        
        //Populate SDQ fields from "System Design Quote Settings"
        try {
            sdq.Scenario_1_Financing_Type__c = System_Design_Quote_Settings__c.getOrgDefaults().Default_Scenario_1_Financing_Type__c;
            sdq.Scenario_2_Financing_Type__c = System_Design_Quote_Settings__c.getOrgDefaults().Default_Scenario_2_Financing_Type__c;
            sdq.Scenario_3_Financing_Type__c = System_Design_Quote_Settings__c.getOrgDefaults().Default_Scenario_3_Financing_Type__c;
            sdq.Scenario_4_Financing_Type__c = System_Design_Quote_Settings__c.getOrgDefaults().Default_Scenario_4_Financing_Type__c;
            sdq.Scenario_1_Lease_Fund__c = System_Design_Quote_Settings__c.getOrgDefaults().Default_Scenario_1_Lease_Fund_ID__c;
            sdq.Scenario_2_Lease_Fund__c = System_Design_Quote_Settings__c.getOrgDefaults().Default_Scenario_2_Lease_Fund_ID__c;
            sdq.Scenario_3_Lease_Fund__c = System_Design_Quote_Settings__c.getOrgDefaults().Default_Scenario_3_Lease_Fund_ID__c;
            sdq.Scenario_4_Lease_Fund__c = System_Design_Quote_Settings__c.getOrgDefaults().Default_Scenario_4_Lease_Fund_ID__c;
            sdq.Scenario_1_Proposal_Term_Months__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_1_Proposal_Term_Months__c;
            sdq.Scenario_2_Proposal_Term_Months__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_2_Proposal_Term_Months__c;
            sdq.Scenario_3_Proposal_Term_Months__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_3_Proposal_Term_Months__c;
            sdq.Scenario_4_Proposal_Term_Months__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_4_Proposal_Term_Months__c;
            sdq.Scenario_1_Down_Payment__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_1_Down_Payment__c;
            sdq.Scenario_2_Down_Payment__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_2_Down_Payment__c;
            sdq.Scenario_3_Down_Payment__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_3_Down_Payment__c;
            sdq.Scenario_4_Down_Payment__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_4_Down_Payment__c;
            sdq.Scenario_1_Lease_Escalator__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_1_Lease_Escalator__c;
            sdq.Scenario_2_Lease_Escalator__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_2_Lease_Escalator__c;
            sdq.Scenario_3_Lease_Escalator__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_3_Lease_Escalator__c;
            sdq.Scenario_4_Lease_Escalator__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_4_Lease_Escalator__c;
            sdq.Scenario_1_Lease_Option__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_1_Lease_Option__c;
            sdq.Scenario_2_Lease_Option__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_2_Lease_Option__c;
            sdq.Scenario_3_Lease_Option__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_3_Lease_Option__c;
            sdq.Scenario_4_Lease_Option__c = System_Design_Quote_Settings__c.getOrgDefaults().Scenario_4_Lease_Option__c;
        } catch (NullPointerException e){
            System.debug('Error in SalesWorkflowValidationUtility on line ' + e.getLineNumber() + ': ' + e.getMessage());
        }
        
        //Update SDQ siblings and their Proposals to "Current__c = false"
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        Map<ID, System_Design_Quote__c> sdqMap = new Map<ID, System_Design_Quote__c>([SELECT Current__c, As_Of_Pricing_Date__c, Pricing_Date__c FROM System_Design_Quote__c 
                                                                                      WHERE System_Design__c = :sysDesign ORDER BY LastModifiedDate DESC]);
        if (sdqMap == null)
            sdqMap = new Map<ID, System_Design_Quote__c>();

        Datetime pricingDate;
        Datetime asOfPricingDate;
        for (System_Design_Quote__c sdquote : sdqMap.values()){
            sdquote.Current__c = false;
            if (pricingDate == null && asOfPricingDate == null){    //Set the pricing date variables for only the first SDQ
                pricingDate = sdquote.Pricing_Date__c;
                asOfPricingDate = sdquote.As_Of_Pricing_Date__c;
            }
        }
        update sdqMap.values();
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        
        Proposal__c[] proposals = [SELECT Current__c FROM Proposal__c WHERE System_Design_Quote__c IN :sdqMap.keySet()];
        for (Proposal__c prop : proposals){
            prop.Current__c = false;
        }
        update proposals;
        
        sdq.Current__c = true;
        //CPQ-737. Retain the previous current SDQ's pricing date.
        sdq.Pricing_Date__c = pricingDate;
        sdq.As_Of_Pricing_Date__c = asOfPricingDate;
        
        if (insertSDQ){
            //CPQ-590
            String sysmake = [SELECT System_Makeup__c FROM  System_Design__c WHERE Id =:sysDesign].System_Makeup__c;
            sdq.System_Makeup__c = sysmake;
            insert sdq;
        }
        return sdq;
    }
    
    public static String systemDesignQuoteWorkflowOnEdit(ID sdqID, Boolean updateSDQ){
        System_Design_Quote__c sdq = [SELECT System_Design_Stored_State__c, System_Design_Stored_State_Mismatch__c, System_Design_Reconstruction_Record__c, 
                                      Sys_Design_Reconstruct_Record_Mismatch__c, Current__c, Valid__c, System_Design__c 
                                      FROM System_Design_Quote__c WHERE ID = :sdqID LIMIT 1];
        return systemDesignQuoteWorkflowOnEdit(sdq, updateSDQ);
    }
    
    public static String systemDesignQuoteWorkflowOnEdit(System_Design_Quote__c sdq){
        return systemDesignQuoteWorkflowOnEdit(sdq, true);
    }
    
    public static String systemDesignQuoteWorkflowOnEdit(System_Design_Quote__c sdq, Boolean updateSDQ){
        //See the "systemDesignQuoteWorkflowOnEdit(ID sdqID, Boolean updateSDQ)" function for a list of fields assumed to be on SDQ
        
        //Deserialize the stored state string
        String storedStateResult = deserializeStoredStateSDQ(sdq);
        
        //Deserialize the reconstruction string (but do not restore the records)
        String[] reconstructionResult = deserializeReconstructionSDQ(sdq, false);
        
        String returnVal = '';  //Return one of the deserialization result strings (the stored state one has precedence over the reconstruction one)
        Proposal__c[] proposalList = [SELECT Current__c, Valid__c FROM Proposal__c WHERE System_Design_Quote__c = :sdq.ID];
        ID[] propIDs = new ID[]{};
        for (Proposal__c prop :proposalList)
            propIDs.add(prop.ID);
        //Astrum_Contract__c[] contractList = [SELECT Current__c FROM Astrum_Contract__c WHERE Proposal__c IN :propIDs];
        
        //Field updates for stored state result
        if (storedStateResult == 'Valid'){
            /* Commented by RJ
            sdq.Current__c = true;
            sdq.Valid__c = true;
            for (Proposal__c pr : proposalList){
                pr.Current__c = true;
                pr.Valid__c = true;
            }
            */
            
            //Field updates for reconstruction result
            if (reconstructionResult[0] == 'Valid'){
                //Flags on SDQ and Proposal were just set
            } else {
                sdq.Current__c = false;
                for (Proposal__c pr : proposalList)
                    pr.Current__c = false;
                //for (Astrum_Contract__c contr : contractList)
                //    contr.Current__c = false;
            }
        } else {
            sdq.Current__c = false;
            sdq.Valid__c = false;
            for (Proposal__c pr : proposalList){
                pr.Current__c = false;
                pr.Valid__c = false;
            }
            //for (Astrum_Contract__c contr : contractList){
            //    contr.Current__c = false;
            //}
        }
        returnVal = storedStateResult == 'Valid' ? reconstructionResult[0] : storedStateResult;
        
        update proposalList;
        //update contractList;  //Proposal trigger will update the Contracts' "current" flag to false
        if (updateSDQ){
            SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
            update sdq;

            //Update SDQ siblings and their Proposals to "Current__c = false"
            Map<ID, System_Design_Quote__c> sdqMap = new Map<ID, System_Design_Quote__c>([SELECT Current__c FROM System_Design_Quote__c WHERE System_Design__c = :sdq.System_Design__c AND ID != :sdq.ID]);
            if (sdqMap == null)
                sdqMap = new Map<ID, System_Design_Quote__c>();
            for (System_Design_Quote__c sdquote : sdqMap.values()){
                sdquote.Current__c = false;
            }
            update sdqMap.values();
            SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
            
            Proposal__c[] unrelatedProposals = [SELECT Current__c FROM Proposal__c WHERE System_Design_Quote__c IN :sdqMap.keySet()];
            for (Proposal__c prop : unrelatedProposals){
                prop.Current__c = false;
            }
            update unrelatedProposals;
        }
        
        return returnVal;
    }

    public static String[] systemDesignQuoteWorkflowOnComplete(System_Design_Quote__c sdq)
    {
        return systemDesignQuoteWorkflowOnComplete(sdq, true, false, false, false, null);
    }

    public static String[] systemDesignQuoteWorkflowOnComplete(String sdqID){
        System_Design_Quote__c sdq = Database.query('SELECT ' + validationFieldsForSDQ + ' FROM System_Design_Quote__c WHERE ID = :sdqID LIMIT 1');
        return systemDesignQuoteWorkflowOnComplete(sdq, true, false, false, false, null);
    }

    public static String[] systemDesignQuoteWorkflowOnComplete(String sdqID, Boolean scenario1 , Boolean scenario2, Boolean scenario3, Boolean scenario4, Integer daysUntilExpiration){
        System_Design_Quote__c sdq = Database.query('SELECT ' + validationFieldsForSDQ + ' FROM System_Design_Quote__c WHERE ID = :sdqID LIMIT 1');
        return systemDesignQuoteWorkflowOnComplete(sdq, scenario1, scenario2, scenario3, scenario4, daysUntilExpiration);
    }
    
    public static String[] systemDesignQuoteWorkflowOnComplete(System_Design_Quote__c sdq, Boolean scenario1, Boolean scenario2, Boolean scenario3, Boolean scenario4, Integer daysUntilExpiration){
        //See the "systemDesignQuoteWorkflowOnComplete(ID sdqID)" function for a list of fields assumed to be on SDQ

        String[] returnArray = new String[]{'', ''};  //Index one will either be "Valid" or an error string. Index two will either be a Proposal ID or blank.

        if(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh__c == null || sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh__c <= 0 )
        {
            returnArray.set(0, 'Please enter Utility Consumption information.');
            return returnArray;
        }

        Opportunity opp = [SELECT ID, (SELECT ID FROM OpportunityContactRoles WHERE Role = 'Contract Signer' AND IsPrimary = true) 
                            FROM Opportunity WHERE Property__c = :sdq.System_Design__r.Property__c ORDER BY CreatedDate DESC LIMIT 1];
        if (opp.OpportunityContactRoles.isEmpty())
        {            
            returnArray.set(0, 'Please assign a Contact to the open Opportunity to be the Primary Contract Signer.');
            return returnArray;            
        }


        String comparisonResult = systemDesignQuoteWorkflowOnEdit(sdq, false);
        if (comparisonResult != 'Valid'){   //Either stored state or reconstruction field comparisons failed. Save the SDQ and quit.
            SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
            update sdq;
            SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
            returnArray.set(0, comparisonResult);
            return returnArray;
        }
        
        Date pricingDate = Date.today();
        if (sdq.Pricing_Date__c != null)
            pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());

        //Validate System Design
        System_Design__c sysDesign = new System_Design__c(ID = sdq.System_Design__c);
        String sdValidated = validateSystemDesign(sysDesign, false, pricingDate);
        if (sdValidated != 'Valid'){
            returnArray.set(0, 'System Design `' + sysDesign.ID + '` failed validation:\n' + sdValidated);
            return returnArray;
        }
        
        //Perform SDQ validation rules
        Map<Integer, Boolean> includedScenarios = new Map<Integer, Boolean>{1 => scenario1, 2 => scenario2, 3 => scenario3, 4 => scenario4};
        String validationRulesResult = systemDesignQuoteValidations(sdq, true, includedScenarios);  //Will run DML updates if validations fail
        if (validationRulesResult != 'Valid'){
            returnArray.set(0, validationRulesResult);
            return returnArray;   //Error messages
        }
        
        //proposalWorkflowOnCreate section: Create a new Proposal and run some workflow rules on it
        sdq.Open_Quote__c = true;
        sdq.Valid__c = true;
        sdq.Validation_Errors__c = validationRulesResult;   //Should be "Valid"

        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        
        sysDesign = [SELECT Open_Quote__c FROM System_Design__c WHERE ID = :sysDesign.ID LIMIT 1];
        sysDesign.Open_Quote__c = true;
        SystemDesignTriggerHandler.skipSystemDesignTrigger = true;
        update sysDesign;
        SystemDesignTriggerHandler.skipSystemDesignTrigger = false;
        
        Proposal__c[] existingProps = [SELECT Current__c FROM Proposal__c WHERE System_Design_Quote__r.System_Design__c = :sysDesign.ID];   //Updated for CPQ-775 to span all SDQ's
        for (Proposal__c pr : existingProps){
            pr.Current__c = false;  //Set all other Proposals within this System Design hierarchy to not current
        }
        update existingProps;
        
        ProposalProcessor pp = new ProposalProcessor();
        String propResult = pp.createProposal(sdq, true, scenario1, scenario2, scenario3, scenario4, daysUntilExpiration);  //Will return the ID of the new Proposal if successful; will return an error string if not

        ID testID = null;
        try {
            testID = propResult;
        } catch (Exception e){}

        if (testID != null){    //createProposal() returned a Proposal ID
            returnArray.set(0, 'Valid');
            returnArray.set(1, propResult);
        } else {    //createProposal() returned an error string
            returnArray.set(0, propResult);
        }
        return returnArray;
    }
    
    public static String systemDesignQuoteWorkflowMakeCurrent(ID sdqID){
        System_Design_Quote__c sdq = Database.query('SELECT ' + validationFieldsForSDQ + ' FROM System_Design_Quote__c WHERE ID = :sdqID LIMIT 1');
        return systemDesignQuoteWorkflowMakeCurrent(sdq);
    }
    
    public static String systemDesignQuoteWorkflowMakeCurrent(System_Design_Quote__c sdq){
        //See the "systemDesignQuoteWorkflowMakeCurrent(ID sdqID)" function for a list of fields assumed to be on SDQ
        
        //Deserialize the stored state string
        String storedStateResult = deserializeStoredStateSDQ(sdq);
        
        //Perform SDQ validation rules
        //String validationResult = systemDesignQuoteValidations(sdq, false);
        
        //Map<ID, Proposal__c> proposalList = new Map<ID, Proposal__c>([SELECT Current__c, Valid__c FROM Proposal__c WHERE System_Design_Quote__c = :sdq.ID]);
        //Astrum_Contract__c[] childContracts = [SELECT Current__c, Valid__c FROM Astrum_Contract__c WHERE Proposal__c IN :proposalList.keySet()];
        
        //if (storedStateResult != 'Valid' || validationResult != 'Valid'){
        //    sdq.Current__c = false;
        //    sdq.Valid__c = false;
        //    for (Proposal__c pr : proposalList.values()){
        //        pr.Current__c = false;
        //        pr.Valid__c = false;
        //    }
        //    for (Astrum_Contract__c contr : childContracts){
        //        contr.Current__c = false;
        //        contr.Valid__c = false;
        //    }
        //    SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        //    update sdq;
        //    SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        //    update proposalList.values();
        //    update childContracts;
        //}
        if (storedStateResult != 'Valid')
            return storedStateResult;
        
        //if (validationResult != 'Valid')
        //    return validationResult;
        
        //If we made it this far, then we know the SDQ passed the "current" and "valid" criteria
        sdq.Current__c = true;
        //sdq.Valid__c = true;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        
        //Both checks have succeeded. The System Design will now be updated to match the state in the reconstruction field.
        String[] reconstructionResult = deserializeReconstructionSDQ(sdq, true);

        //Update SDQ siblings and their Proposals to "Current__c = false"
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        Map<ID, System_Design_Quote__c> sdqMap = new Map<ID, System_Design_Quote__c>([SELECT Current__c FROM System_Design_Quote__c WHERE System_Design__c = :sdq.System_Design__c AND ID != :sdq.ID]);
        if (sdqMap == null)
            sdqMap = new Map<ID, System_Design_Quote__c>();
        for (System_Design_Quote__c sdquote : sdqMap.values()){
            sdquote.Current__c = false;
        }
        update sdqMap.values();
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        
        Proposal__c[] unrelatedProposals = [SELECT Current__c FROM Proposal__c WHERE System_Design_Quote__c IN :sdqMap.keySet()];
        for (Proposal__c prop : unrelatedProposals){
            prop.Current__c = false;
        }
        update unrelatedProposals;

        return reconstructionResult[0];
    }

    public static String proposalWorkflowOnComplete(ID propID){
        Proposal__c prop = [SELECT Valid__c, Current__c, System_Design_Quote__c, SDQ_Reconstruction_Record__c, System_Design_Reconstruction_Record__c, 
                            System_Design_Stored_State__c, Scenario_1_Included__c, Scenario_2_Included__c, Scenario_3_Included__c, Scenario_4_Included__c 
                            FROM Proposal__c WHERE ID =:propID LIMIT 1];
        return proposalWorkflowOnComplete(prop);
    }
    
    public static String proposalWorkflowOnComplete(Proposal__c prop){
        //See the "proposalWorkflowOnComplete(ID propID)" function for a list of fields assumed to be on Proposal
        
        ID relatedSDQ = prop.System_Design_Quote__c;
        System_Design_Quote__c sdq = Database.query('SELECT ' + validationFieldsForSDQ + ' FROM System_Design_Quote__c WHERE ID = :relatedSDQ LIMIT 1');
        
        Date pricingDate = Date.today();
        if (sdq.Pricing_Date__c != null)
            pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());

        //Validate System Design
        System_Design__c sysDesign = new System_Design__c(ID = sdq.System_Design__c);
        String sdValidated = validateSystemDesign(sysDesign, false, pricingDate);
        if (sdValidated != 'Valid')
            return 'System Design `' + sysDesign.ID + '` failed validation:\n' + sdValidated;
        
        //Evaluate the stored state of this Proposal's SDQ
        String storedStateResult = deserializeStoredStateSDQ(sdq);
        if (storedStateResult == 'Valid'){
            prop.Current__c = true;
        } else {
            prop.Current__c = false;    //Child Contracts will be set to Current = false in the Proposal trigger
            update prop;
            return storedStateResult;
        }
        
        //Validate System Design Quote
        Map<Integer, Boolean> includedScenarios = new Map<Integer, Boolean>{1 => prop.Scenario_1_Included__c, 2 => prop.Scenario_2_Included__c, 3 => prop.Scenario_3_Included__c, 4 => prop.Scenario_4_Included__c};
        String sdqValidationResult = systemDesignQuoteValidations(sdq, true, includedScenarios);       //Will run updates if validations fail
        if (sdqValidationResult != 'Valid')
            return sdqValidationResult;

        prop.Valid__c = true;
        sdq.Valid__c = true;
        sdq.Validation_Errors__c = sdqValidationResult;     //Should be "Valid"
        update prop;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;

        //Update SDQ siblings and their Proposals to "Current__c = false"
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        Map<ID, System_Design_Quote__c> sdqMap = new Map<ID, System_Design_Quote__c>([SELECT Current__c FROM System_Design_Quote__c WHERE System_Design__c = :sdq.System_Design__c AND ID != :sdq.ID]);
        if (sdqMap == null)
            sdqMap = new Map<ID, System_Design_Quote__c>();
        for (System_Design_Quote__c sdquote : sdqMap.values()){
            sdquote.Current__c = false;
        }
        update sdqMap.values();
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        
        Proposal__c[] unrelatedProposals = [SELECT Current__c FROM Proposal__c WHERE System_Design_Quote__c IN :sdqMap.keySet()];
        for (Proposal__c prp : unrelatedProposals){
            prp.Current__c = false;
        }
        update unrelatedProposals;

        return 'Valid';
    }
    
    public static String proposalWorkflowMakeCurrent(ID propID){
        Proposal__c prop = [SELECT Valid__c, Current__c, System_Design_Quote__c, SDQ_Reconstruction_Record__c, System_Design_Reconstruction_Record__c, 
                            System_Design_Stored_State__c, Scenario_1_Included__c, Scenario_2_Included__c, Scenario_3_Included__c, Scenario_4_Included__c 
                            FROM Proposal__c WHERE ID =:propID LIMIT 1];
        return proposalWorkflowMakeCurrent(prop);
    }
    
    public static String proposalWorkflowMakeCurrent(Proposal__c prop){
        //See the "proposalWorkflowMakeCurrent(ID propID)" function for a list of fields assumed to be on Proposal
        
        ID sdqID = prop.System_Design_Quote__c;
        system.debug('**SZ: query = SELECT ' + validationFieldsForSDQ + ' FROM System_Design_Quote__c WHERE ID = :sdqID LIMIT 1');
        System_Design_Quote__c sdq = Database.query('SELECT ' + validationFieldsForSDQ + ' FROM System_Design_Quote__c WHERE ID = :sdqID LIMIT 1');
        
        //Evaluate Proposal for possible refresh. Repeat what was done in proposalWorkflowOnComplete().
        
        Date pricingDate = Date.today();
        if (sdq.Pricing_Date__c != null)
            pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());

        //Validate System Design
        System_Design__c sysDesign = new System_Design__c(ID = sdq.System_Design__c);
        String sdValidated = validateSystemDesign(sysDesign, false, pricingDate);
        if (sdValidated != 'Valid')
            return 'System Design `' + sysDesign.ID + '` failed validation:\n' + sdValidated;
        
        //Evaluate the stored state of this Proposal's SDQ
        String storedStateResult = deserializeStoredStateSDQ(sdq);
        if (storedStateResult == 'Valid'){
            prop.Current__c = true;
        } else {
            prop.Current__c = false;    //Child Contracts will be set to Current = false in the Proposal trigger
            update prop;
            return storedStateResult;
        }
        
        //Validate System Design Quote
        Map<Integer, Boolean> includedScenarios = new Map<Integer, Boolean>{1 => prop.Scenario_1_Included__c, 2 => prop.Scenario_2_Included__c, 3 => prop.Scenario_3_Included__c, 4 => prop.Scenario_4_Included__c};
        String sdqValidationResult = systemDesignQuoteValidations(sdq, true, includedScenarios);   //Will update Proposal to Valid = false if validations fail
        if (sdqValidationResult != 'Valid')
            return sdqValidationResult;
        
        Savepoint preSuccessCondition = Database.setSavepoint();

        prop.Valid__c = true;
        sdq.Valid__c = true;
        sdq.Validation_Errors__c = sdqValidationResult;     //Should be "Valid"
        update prop;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        
        //Reconstruct SD
        //sdq = [SELECT Valid__c, System_Design__c, System_Design_Reconstruction_Record__c FROM System_Design_Quote__c WHERE ID = :sdq.ID LIMIT 1];   //Newest definition
        String[] sdReconstructionResult = new String[]{'', ''};
        sdReconstructionResult = deserializeReconstructionSDQ(sdq, true);
        
        if (sdReconstructionResult[1] == 'false')  //The reconstruction failed, and no DML was performed
            return 'This Proposal`s System Design could not be reconstructed. Please create a new System Design Quote to continue.';
        
        //Reconstruct SDQ (We already know Proposal is Valid at this point)
        String[] sdqReconstructionResult = deserializeReconstructionProposal(prop, true);
        if (sdqReconstructionResult[1] == 'false'){     //The reconstruction failed, and no DML was performed
            Database.rollback(preSuccessCondition);  //Undo the SD reconstruction and current/valid flagging
            return 'This Proposal`s System Design Quote could not be reconstructed. Please create a new System Design Quote to continue.';
        }

        //Update SDQ siblings and their Proposals to "Current__c = false"
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        Map<ID, System_Design_Quote__c> sdqMap = new Map<ID, System_Design_Quote__c>([SELECT Current__c FROM System_Design_Quote__c WHERE System_Design__c = :sdq.System_Design__c AND ID != :sdq.ID]);
        if (sdqMap == null)
            sdqMap = new Map<ID, System_Design_Quote__c>();
        for (System_Design_Quote__c sdquote : sdqMap.values()){
            sdquote.Current__c = false;
        }
        update sdqMap.values();
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        
        Proposal__c[] otherProposals = [SELECT Current__c FROM Proposal__c WHERE ID != :prop.ID AND (System_Design_Quote__c IN :sdqMap.keySet() OR System_Design_Quote__c = :prop.System_Design_Quote__c)];
        for (Proposal__c prp : otherProposals){
            prp.Current__c = false;
        }
        update otherProposals;
        
        String bothReconstructionResults;
        if (sdReconstructionResult[0] == 'Valid' && sdqReconstructionResult[0] == 'Valid')
            bothReconstructionResults = 'Valid';
        else
            bothReconstructionResults = (sdReconstructionResult[0] != 'Valid' ? sdReconstructionResult[0] : '') + '\n' + (sdqReconstructionResult[0] != 'Valid' ? sdqReconstructionResult[0] : '');
        
        return bothReconstructionResults;
    }
    
    public static String contractWorkflowOnComplete(ID contractID){
        Astrum_Contract__c contract = [SELECT Open_Quote__c, Proposal__c FROM Astrum_Contract__c WHERE ID =:contractID LIMIT 1];
        return contractWorkflowOnComplete(contract);
    }
    
    public static String contractWorkflowOnComplete(Astrum_Contract__c contract){
        //See the "contractWorkflowOnComplete(ID contractID)" function for a list of fields assumed to be on Contract
        
        String returnStr = 'Valid';
        if (contract.Open_Quote__c == true){
            //TO DO: Email contract to Customer via Docusign or Print Contract as paper option
            Astrum_Contract__c[] siblings = [SELECT Current__c FROM Astrum_Contract__c WHERE Proposal__c = :contract.Proposal__c AND ID != :contract.ID];
            for (Astrum_Contract__c contr : siblings){
                contr.Current__c = false;
            }
            update siblings;
        } else {
            returnStr = 'The Contract cannot be presented because it is not part of an open quote.';
        }
        return returnStr;
    }
    
    public static String contractWorkflowOnAccepted(ID contractID){
        Astrum_Contract__c contract = [SELECT Closed__c, Proposal__c FROM Astrum_Contract__c WHERE ID = :contractID LIMIT 1];
        return contractWorkflowOnAccepted(contract);
    }
    
    public static String contractWorkflowOnAccepted(Astrum_Contract__c contract){
        //See the "contractWorkflowOnAccepted(ID contractID)" function for a list of fields assumed to be on Contract
        
        contract.Closed__c = true;
        AstrumContractTriggerHandler.skipAstrumContractTrigger = true;      //No trigger logic to run. Save SOQL by skipping.
        update contract;
        AstrumContractTriggerHandler.skipAstrumContractTrigger = false;
        
        Proposal__c prop = [SELECT Current__c, Valid__c, System_Design_Quote__c, Closed__c, SDQ_Reconstruction_Record__c, 
                            System_Design_Reconstruction_Record__c, System_Design_Stored_State__c FROM Proposal__c WHERE ID = :contract.Proposal__c LIMIT 1];
        System_Design_Quote__c sdq = [SELECT Current__c, System_Design__c, Closed__c, Valid__c, System_Design_Reconstruction_Record__c FROM System_Design_Quote__c WHERE ID = :prop.System_Design_Quote__c LIMIT 1];
        System_Design__c sysDesign = [SELECT Current_Design__c, Closed__c FROM System_Design__c WHERE ID = :sdq.System_Design__c LIMIT 1];
        
        Savepoint preReconstruct = Database.setSavepoint();
        String[] sdReconstructionResult = new String[]{'Valid', ''};
        String[] sdqReconstructionResult = new String[]{'Valid', ''};
        
        if (!prop.Current__c || !sdq.Current__c){       //|| !sysDesign.Current_Design__c
            if (sdq.Valid__c){
                sdReconstructionResult = deserializeReconstructionSDQ(sdq, true);
            } else {
                return 'This Proposal`s System Design Quote has been marked as Invalid, and therefore cannot restore its related System Design. Please create a new System Design Quote to continue the sales process.';
            }
            
            if (!prop.Valid__c){
                Database.rollback(preReconstruct);  //Undo the SD reconstruction
                return 'This Proposal`s System Design Quote has been marked as Invalid, and therefore cannot restore its related System Design. Please create a new System Design Quote to continue the sales process.';
            }
            
            if (sdReconstructionResult[1] == 'true'){
                sdqReconstructionResult = deserializeReconstructionProposal(prop, true);
            } else {
                Database.rollback(preReconstruct);
                return 'This Proposal`s System Design could not be reconstructed due to changes on the design or its related records. Please create new System Design Quote to continue.';
            }
            if (sdqReconstructionResult[1] == 'false'){
                Database.rollback(preReconstruct);
                return 'This Proposal`s System Design Quote could not be reconstructed due to changes on the design or its related records. Please create a new System Design Quote to continue.';
            }
        }
        
        if (prop.Closed__c != true){
            prop.Closed__c = true;
            update prop;
        }
        if (sdq.Closed__c != true){
            sdq.Closed__c = true;
            Opportunity_Trigger_Utility.skipOpportunityTrigger = true;      //Disable the Opp trigger (which is fired in the SDQ trigger) to save SOQL. It should be unnecessary to run at this time anyway.
            update sdq;
            Opportunity_Trigger_Utility.skipOpportunityTrigger = false;
        }
        if (sysDesign.Closed__c != true){
            sysDesign.Closed__c = true;
            Opportunity_Trigger_Utility.skipOpportunityTrigger = true;      //Disable the Opp trigger to save SOQL. It will eventually run before the user closes the Opp in CloseContract.page, so it's okay to skip for now.
            update sysDesign;
            Opportunity_Trigger_Utility.skipOpportunityTrigger = false;
        }
        
        String bothReconstructionResults;
        if (sdReconstructionResult[0] == 'Valid' && sdqReconstructionResult[0] == 'Valid')
            bothReconstructionResults = 'Valid';
        else
            bothReconstructionResults = (sdReconstructionResult[0] != 'Valid' ? sdReconstructionResult[0] : '') + '\n' + (sdqReconstructionResult[0] != 'Valid' ? sdqReconstructionResult[0] : '');
        
        return bothReconstructionResults;
    }
    
    //public static String contractWorkflowOnClosed(ID contractID, ID oppID){
    //    Astrum_Contract__c contract = [SELECT Contract_Execution_Date__c FROM Astrum_Contract__c WHERE ID = :contractID LIMIT 1];
    //    Opportunity opp = null; //[SELECT StageName, CloseDate, Lease_PPA_Fund__c, Leasing_Option__c FROM Opportunity ];
    //    return contractWorkflowOnClosed(contract, opp);
    //}
    
    //public static String contractWorkflowOnClosed(Astrum_Contract__c contract, Opportunity opp){
        //See the "contractWorkflowOnClosed(ID contractID)" function for a list of fields assumed to be on Contract
        
        //opp.StageName = 'Closed - Won';
        //opp.CloseDate = contract.Contract_Execution_Date__c;

        //~~~~~~~~~~ This logic is implemented in CloseContractCtrl.closeOpportunity() ~~~~~~~~~~

        //return null;
    //}
    
    //Requires the fields listed in the global variable "validationFieldsForSDQ"
    public static String systemDesignQuoteValidations(System_Design_Quote__c sdq, Boolean updateRecordsIfFailed, Map<Integer, Boolean> includedScenarios){
        //updateRecordsIfFailed: Flag whether or not to DML update records with "Valid = false" if the the validation rules fail to pass.

        sdq.Validation_Errors__c = '';
        sdq.Disqualifying_Validation_Errors__c = '';
        Proposal__c[] childProps = new Proposal__c[]{};
        if (updateRecordsIfFailed)     //Only query the Proposals if we need to update them
            childProps = [SELECT Valid__c FROM Proposal__c WHERE System_Design_Quote__c = :sdq.ID];
        
        // TODO RJ Commented - This Validation not required as taken care of in Input Page.
        //If SDQ.All-Electric Service <> Utility Service.Utility Rate Code Before Solar.All-Electric Service
        /* if (sdq.All_Electric_Service__c != (sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.All_Electric_Service__c == 'Yes')){
            sdq.Disqualifying_Validation_Errors__c += 'You must select All-Electric Rate Code for Before Utility Rate Code\n';
            systemDesignQuoteValidationsFailed('You must select All-Electric Rate Code for Before Utility Rate Code', sdq, childProps, childContracts);
        }
        //If SDQ.All-Electric Service <> Utility Service.Utility Rate Code After Solar.All-Electric Service
        if (sdq.All_Electric_Service__c != (sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__r.All_Electric_Service__c == 'Yes')){
            sdq.Disqualifying_Validation_Errors__c += 'You must select All-Electric Rate Code for After Utility Rate Code\n';
            systemDesignQuoteValidationsFailed('You must select All-Electric Rate Code for After Utility Rate Code', sdq, childProps, childContracts);
        }
        */
        //If Utility Company.Has Service Territories = TRUE and Utility Rate Code.Default = TRUE

        /* TODO: This validation should be on SD Validations...and not sure why looking for Default Rate Code ? 
        if (sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Has_Service_Territories__c && sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__r.Default_Rate_Code__c){
            sdq.Disqualifying_Validation_Errors__c = 'You must select Utility Service Territory\n';
            systemDesignQuoteValidationsFailed('You must select Utility Service Territory', sdq, childProps, childContracts);
        }
        */
        
        //Get Physical Surfaces relating to this SDQ's Property
        Integer psCount = 0;
        Set<ID> psSoilIDs = new Set<ID>();
        Boolean foundNotSoil = false;
        for (Physical_Surface__c ps : [SELECT Surface_Type__c FROM Physical_Surface__c WHERE Property__c = :sdq.System_Design__r.Property__c]){
            psCount++;
            if (ps.Surface_Type__c == 'Soil'){
                psSoilIDs.add(ps.ID);
            } else if (ps.Surface_Type__c != null){
                foundNotSoil = true;
            }
            if (psSoilIDs.size() != 0 && foundNotSoil && psCount >= 2)
                break;  //We have what we need
        }
        if (psSoilIDs.size() != 0 && foundNotSoil && psCount >= 2 && sdq.System_Size_kW__c < 7){
            AggregateResult ar = [SELECT SUM(Array_Size_kW__c) FROM System_Design_Array__c WHERE Physical_Surface__c IN :psSoilIDs];
            Double totalArraySize = (Double)ar.get('expr0');    //The sum of SDA.Array Size (kW) for all SDA with Surface Type = 'Soil'
            if (totalArraySize <= (0.5 * sdq.System_Size_kW__c))
                systemDesignQuoteValidationsFailed('The total wattage for all "soil type" Physical Surfaces must be greater than 0.5 * Total System Design Size.', sdq, childProps);
        }

        //Product-specific validations
        Boolean ranOneTimeValidations = false;
        for (Integer i = 1; i <= 4; i++){
            if (includedScenarios.get(i) != true)
                continue;
            sObject leaseFund = sdq.getSObject('Scenario_' + i + '_Lease_Fund__r');
            sObject termLoan = sdq.getSObject('Scenario_' + i + '_Term_Loan__r');
            Decimal termLoanAmount = (Decimal)sdq.get('Scenario_' + i + '_Term_Loan_Amount__c');    //Formula field; will never be null
            Decimal sacLoanAmount = (Decimal)sdq.get('Scenario_' + i + '_SAC_Loan_Amount__c');

            if (termLoan != null){
                //SDQ.Scenario_N_Term_Loan_Amount__c <= TermLoan.Maximum_Term_Loan_Amount
                if (termLoan.get('Maximum_Term_Loan_Amount__c') != null && termLoanAmount > (Decimal)termLoan.get('Maximum_Term_Loan_Amount__c'))
                    systemDesignQuoteValidationsFailed('The Term Loan amount for scenario ' + i + ' must be less than or equal to $' + (Decimal)termLoan.get('Maximum_Term_Loan_Amount__c') + '.', sdq, childProps);
                //SDQ.Scenario_N_Term_Loan_Amount__c >= TermLoan.Minimum_Term_Loan_Amount
                if (termLoan.get('Minimum_Term_Loan_Amount__c') != null && termLoanAmount < (Decimal)termLoan.get('Minimum_Term_Loan_Amount__c'))
                    systemDesignQuoteValidationsFailed('The Term Loan amount for scenario ' + i + ' must be greater than or equal to $' + (Decimal)termLoan.get('Minimum_Term_Loan_Amount__c') + '.', sdq, childProps);
                
                //CPQ-758. As of 12/30/15, this is intended for Sungage Loans
                if (termLoan.get('Maximum_Project_Cost__c') != null && termLoanAmount + sacLoanAmount > (Decimal)termLoan.get('Maximum_Project_Cost__c'))
                    systemDesignQuoteValidationsFailed('The Term Loan + SAC Loan amounts for scenario ' + i + ' must be less than or equal to $' + (Decimal)termLoan.get('Maximum_Project_Cost__c') + '.', sdq, childProps);
                if (termLoan.get('Minimum_Project_Cost__c') != null && termLoanAmount + sacLoanAmount < (Decimal)termLoan.get('Minimum_Project_Cost__c'))
                    systemDesignQuoteValidationsFailed('The Term Loan + SAC Loan amounts for scenario ' + i + ' must be greater than or equal to $' + (Decimal)termLoan.get('Minimum_Project_Cost__c') + '.', sdq, childProps);
            }

            //CPQ-745
            if (leaseFund != null && (Decimal)leaseFund.get('Minimum_TSRF__c') != null && (Decimal)leaseFund.get('Minimum_TSRF__c') > sdq.System_Design__r.Overall_TSRF__c)
                systemDesignQuoteValidationsFailed('Minimum TSRF for scenario ' + i + ' is ' + (Decimal)leaseFund.get('Minimum_TSRF__c') + '%. System Design`s TSRF is ' + sdq.System_Design__r.Overall_TSRF__c + '%.', sdq, childProps);

            //KW Lease – Monthly & Prepaid PPA
            if (leaseFund != null && String.valueOf(leaseFund.get('Name')).containsIgnoreCase('Kilowatt')){
                
                if (!ranOneTimeValidations){  //Only run these validations ONCE
                    if (sdq.System_Size_kW__c < 3 || sdq.System_Size_kW__c > 30)
                        systemDesignQuoteValidationsFailed('SDQ`s system size must be between 3 and 30 kW. Actual size is ' + sdq.System_Size_kW__c + '.', sdq, childProps);
                    
                    System_Design_Item__c[] panel = [SELECT System_Design_Product__r.Make__c FROM System_Design_Item__c WHERE System_Design_Array__r.System_Design__c = :sdq.System_Design__c 
                                                    AND System_Design_Product__r.RecordType.DeveloperName = 'Panel' LIMIT 1];
                    //Set<String> approvedPanels = new Set<String>{'CanadianSolar', 'CertainTeed', 'Kyocera', 'Renesolar', 'Suniva', 'Yingli'};
                    String approvedPanels = leaseFund.get('Eligible_Panels__c') != null ? String.valueOf(leaseFund.get('Eligible_Panels__c')) : '';
                    if (panel.isEmpty() || !approvedPanels.contains(panel[0].System_Design_Product__r.Make__c))
                        systemDesignQuoteValidationsFailed('The System Design`s Panel Item must be one of the following: ' + approvedPanels + '.', sdq, childProps);
                    
                    if (sdq.System_Design__r.System_Inverter__r.RecordType.DeveloperName != 'Inverter' || sdq.System_Design__r.System_Inverter__r.Make__c != 'Enphase')
                        systemDesignQuoteValidationsFailed('The System Design must use Enphase Micro Inverters.', sdq, childProps);
                    
                    if (sdq.System_Design__r.Property__r.RecordType.DeveloperName != 'Residential')
                        systemDesignQuoteValidationsFailed('The Property must be residential (for Kilowatt Lease).', sdq, childProps);

                    if (sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.KW_Eligible__c == false)
                        systemDesignQuoteValidationsFailed('The Utility Company does not support Kilowatt Leasing.', sdq, childProps);

                    String eligibleStates = leaseFund.get('Eligible_States__c') != null ? String.valueOf(leaseFund.get('Eligible_States__c')) : '';
                    if (!eligibleStates.contains(sdq.System_Design__r.Property__r.Property_State__c))
                        systemDesignQuoteValidationsFailed('The Property`s state must be one of the following: ' + leaseFund.get('Eligible_States__c') + '.', sdq, childProps);

                    ranOneTimeValidations = true;
                }

                //SDQ.Scenario N Down Payment >= $0 and <= $5000, $1000 step increments
                Decimal downPayment = nullDecimal(sdq.get('Scenario_' + i + '_Down_Payment__c'));
                if (downPayment < 0 || downPayment > 5000 || Math.mod(downPayment.intValue(), 1000) != 0)
                    systemDesignQuoteValidationsFailed('The down payment for the SDQ`s scenario ' + i + ' must be between $0 and $5000, in $1000 increments.', sdq, childProps);
                
                Decimal financingRateYearOne = nullDecimal(sdq.get('Scenario_' + i + '_Financing_Rate_Year_1_kWh__c'));
                Decimal avoidedUtilityRate = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Avoided_Utility_Rate__c;
                if (avoidedUtilityRate == null){
                    systemDesignQuoteValidationsFailed('`Method 1 Avoided Utility Rate` on Utility Service is null. Check that the baseline consumption data is valid on the related rate code.', sdq, childProps);
                } else {
                    if ((String)sdq.get('Scenario_' + i + '_Lease_Escalator__c') == '0'){
                        //SDQ.Scenario N Financing Rate Year 1 ($/kWh) must be less than or equal to SDQ.Scenario N Avoided Utility rate ($/kWh)
                        if (financingRateYearOne > avoidedUtilityRate)
                            systemDesignQuoteValidationsFailed('The financing rate for scenario ' + i + ' must be less than or equal to the Avoided Utility Rate (' + avoidedUtilityRate + ').', sdq, childProps);
                    }
                    
                    if ((String)sdq.get('Scenario_' + i + '_Lease_Escalator__c') == '2.9'){
                        //SDQ.Scenario N Financing Rate Year 1 ($/kWh) must be less than or equal to .9 * SDQ.Scenario N Avoided Utility rate ($/kWh)
                        if (financingRateYearOne > (0.9 * avoidedUtilityRate))
                            systemDesignQuoteValidationsFailed('The financing rate for scenario ' + i + ' must be less than or equal to 90% of the Avoided Utility Rate (' + avoidedUtilityRate + ').', sdq, childProps);
                    }
                }
                
                //SDQ.Scenario N Total Projected Annual Output cannot exceed SDQ.Annual Electricity Consumption (kWh)
                if ((Double)sdq.get('Scenario_' + i + '_Total_Projected_Annual_Output__c') > sdq.Annual_Electricity_Consumption_kWh__c)
                    systemDesignQuoteValidationsFailed('The SDQ`s projected annual output for scenario ' + i + ' cannot exceed its annual electricity consumption of ' + 
                                                        sdq.Annual_Electricity_Consumption_kWh__c + ' kWh.', sdq, childProps);
            
            }

            // Sunlight products with have a Sighten Product uuid
            else if (termLoan != null && termLoan.get('Sighten_Product_uuid__c') != null){
                //Start with common validations that do not depend on the possible presence of a SAC Loan
                sObject sacLoan = sdq.getSObject('Scenario_' + i + '_SAC_Loan__r');

                if (sdq.System_Design__r.Property__r.RecordType.DeveloperName != 'Residential')
                    systemDesignQuoteValidationsFailed('The Property must be residential (for Sunlight Loan).', sdq, childProps);

                //Installation must be in an eligible state
                if (termLoan.get('Eligible_States__c') == null || !String.valueOf(termLoan.get('Eligible_States__c')).containsIgnoreCase(sdq.System_Design__r.Property__r.Property_State__c))
                    systemDesignQuoteValidationsFailed('The Sunlight 20 Year Term Loan does not support the state of ' + sdq.System_Design__r.Property__r.Property_State__c + '.', sdq, childProps);

                
                // validateSavings()
                System.debug(' Required_Utility_Savings__c '+ termLoan.get('Required_Utility_Savings__c'));
                // temporarily remove sighten aspect of savings validation
                if(termLoan.get('Required_Utility_Savings__c') != null) // && termLoan.get('Sighten_Product_uuid__c') == null)
                {
                    String savingResult = validateSavings(sdq,termLoan,i);
                    if(savingResult != null)
                    {
                        systemDesignQuoteValidationsFailed(savingResult, sdq, childProps);
                    }
                }

                if (sacLoan != null){   //This is a Sunlight 20 Year Term Loan + SAC Loan
                    //SDQ.Scenario N Term Loan Amount + SDQ.Scenario N SAC Loan Amount <= Sum(LeaseFund.MaximumTermLoanAmount) for Term and SAC
                    if (termLoan.get('Maximum_Term_Loan_Amount__c') != null && termLoanAmount + sacLoanAmount > (Decimal)termLoan.get('Maximum_Term_Loan_Amount__c') + nullDecimal(sacLoan.get('Maximum_Term_Loan_Amount__c')))
                        systemDesignQuoteValidationsFailed('The Term Loan + SAC Loan amounts for scenario ' + i + ' must be less than or equal to $' + ((Decimal)termLoan.get('Maximum_Term_Loan_Amount__c') + nullDecimal(sacLoan.get('Maximum_Term_Loan_Amount__c'))) + 
                                                            '. (TermLoan.MaximumTermLoanAmount + SAC_Loan.MaximumTermLoanAmount).', sdq, childProps);

                    //If TermLoan.OverproductionAllowed = False, then production value must not exceed 115% of consumption for Scenario N.
                    if ((Boolean)termLoan.get('Overproduction_Allowed__c') == false && ((Double)sdq.get('Scenario_' + i + '_Total_Projected_Annual_Output__c') > 1.15 * sdq.Annual_Electricity_Consumption_kWh__c))
                        systemDesignQuoteValidationsFailed('The total projected annual output for scenario ' + i + ' (' + sdq.get('Scenario_' + i + '_Total_Projected_Annual_Output__c') + ') must not ' + 
                                                        'exceed 115% of the annual electricity consumption (' + 1.15 * sdq.Annual_Electricity_Consumption_kWh__c + ') when the Sunlight term loan does not permit overproduction.', sdq, childProps);

                    Decimal finalEPC_price = (Decimal)sdq.get('Scenario_' + i + '_Final_EPC_Price__c');
                    //SDQ.Scenario_N_Final/EPC_Price__c * TermLoan.Minimum Finance % of Price <= SDQ.Scenario_N_Term_Loan_Amount__c <= SDQ.Scenario_N_Final/EPC_Price__c * TermLoan.Maximum Finance % of Price
                    if (termLoanAmount < finalEPC_price * getPercent(termLoan.get('Min_Finance_Percent_of_Price__c'), 0.0))
                        systemDesignQuoteValidationsFailed('Term Loan financed amount, $' + termLoanAmount + '), must be at least [SDQ.Scenario ' + i + 
                                                        ' Final/EPC Price * TermLoan.Minimum Finance % of Price].', sdq, childProps);
                    if (termLoanAmount > finalEPC_price * getPercent(termLoan.get('Max_Finance_Percent_of_Price__c'), 1.0))
                        systemDesignQuoteValidationsFailed('Term Loan financed amount, $' + termLoanAmount + '), must not be greater than [SDQ.Scenario ' + i + 
                                                        ' Final/EPC Price * TermLoan.Maximum Finance % of Price].', sdq, childProps);
                    
                    //SDQ.Scenario_N_Final/EPC_Price__c * SAC-Loan.Minimum Finance % of Price <= SDQ.Scenario_N_SAC_Loan_Amount__c <= SDQ.Scenario_N_Final/EPC_Price__c * SAC-Loan.Maximum Finance % of Price
                    if (sacLoanAmount < finalEPC_price * getPercent(sacLoan.get('Min_Finance_Percent_of_Price__c'), 0.0))
                        systemDesignQuoteValidationsFailed('SAC Loan financed amount, $' + sacLoanAmount + '), must be at least [SDQ.Scenario ' + i + 
                                                        ' Final/EPC Price * SAC-Loan.Minimum Finance % of Price].', sdq, childProps);
                    if (sacLoanAmount > finalEPC_price * getPercent(sacLoan.get('Max_Finance_Percent_of_Price__c'), 1.0))
                        systemDesignQuoteValidationsFailed('SAC Loan financed amount, $' + sacLoanAmount + '), must not be greater than [SDQ.Scenario ' + i + 
                                                        ' Final/EPC Price * SAC-Loan.Maximum Finance % of Price].', sdq, childProps);

                } else {    //This is strictly a Sunlight 20 Year Term Loan

                }
            }
        }
        
        if (sdq.Validation_Errors__c == ''){
            sdq.Valid__c = true;
            for (Proposal__c prop : childProps)
                prop.Valid__c = true;
            //if (updateRecords){
            //    SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
            //    update sdq;
            //    SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
            //    update childProps;
            //    update childContracts;
            //}
            return 'Valid';
        } else {
            //"systemDesignQuoteValidationsFailed()" has already set the field values
            if (updateRecordsIfFailed){
                SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
                update sdq;
                SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
                update childProps;
            }
            return sdq.Validation_Errors__c;
        }
    }

    private static void systemDesignQuoteValidationsFailed(String errorText, System_Design_Quote__c sdq, Proposal__c[] childProps){
        sdq.Validation_Errors__c += errorText + '\n';
        sdq.Valid__c = false;
        for (Proposal__c prop : childProps)
            prop.Valid__c = false;
    }

    //Savings on cumulative utility bill for the first 5 years must be >= TermLoan.Required_Utility_Savings__c
    @TestVisible private static String validateSavings(System_Design_Quote__c sdq,sObject termLoan, Integer i){
        //Decimal fiveYearBeforeCost = nullDecimal(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Five_Year_Before_Bill_Cost__c);
        //Decimal fiveYearNetCost = nullDecimal(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Five_Year_Net_Bill_Cost__c);
        
        Double assumedEscalator = 0.0399;
        Integer savingYears = 5;
        Double degradation = 0.005;

        ProposalProcessor pp = new ProposalProcessor();

        if (termLoan.get('Assumed_Utility_Rate_Annual_Escalator__c') != null)
        {
            assumedEscalator = (Double)termLoan.get('Assumed_Utility_Rate_Annual_Escalator__c') != null ? (Double)termLoan.get('Assumed_Utility_Rate_Annual_Escalator__c')/100 :0;                     
            //assumedEscalator = (assumedEscalator/100);
        }
        if (termLoan.get('Required_Utility_Savings_term__c') != null)
        {
            savingYears = Integer.valueOf((Double)termLoan.get('Required_Utility_Savings_term__c'));
        }
        System.debug('savingYears '+savingYears + ' assumedEscalator  '+ assumedEscalator);
        Decimal beforeTotalCost = 0;
        Decimal beforeBillSum = pp.getSumFromSemicolonDelimitedList(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c);
        beforeTotalCost = pp.getTotalOverYears(beforeBillSum, assumedEscalator, savingYears);
        System.debug('beforeTotalCost '+beforeTotalCost);

        Decimal nonSolarCost = 0;

        Double totalNetBill = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c != null ? sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c : 0;
        System.debug('totalNetBill '+totalNetBill);
        //Decimal yearlyProduction = sdq.System_Design__r.Total_Projected_Annual_Output_kWh_y__c;
        //Double leaseEsc = 0;
        //leaseEsc = (Double)sdq.get('Scenario_' + i + '_Lease_Escalator__c') ;
        //if(leaseEsc == null)
            //leaseEsc = 0;

        String leaseEscStr = sdq.get('Scenario_' + i + '_Lease_Escalator__c') != null ? (String)sdq.get('Scenario_' + i + '_Lease_Escalator__c') : '0';
        if (String.isBlank(leaseEscStr) || leaseEscStr == 'null')
            leaseEscStr = '0';
        Double leaseEsc = Double.valueOf(leaseEscStr);


        //Decimal totalForcastedConsumption = nullDecimal(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh__c);

        System.debug(' Degration '+ degradation );
        for (Integer y = 0; y < 5; y++){
            System.debug('totalNetBill '+ totalNetBill* Decimal.valueOf(Math.pow(1 + assumedEscalator, (Double)y)));
            System.debug('Prod '+ Decimal.valueOf(Math.pow(1 + degradation, (Double)y)));
            System.debug('Yearly Net Bill '+ totalNetBill * (Decimal.valueOf(Math.pow(1 + assumedEscalator, (Double)y))) * (Decimal.valueOf(Math.pow(1 + degradation, (Double)y))));
            nonSolarCost += totalNetBill * (Decimal.valueOf(Math.pow(1 + assumedEscalator, (Double)y))) * (Decimal.valueOf(Math.pow(1 + degradation, (Double)y)));
            System.debug('nonSolarCost '+nonSolarCost );
        }

        Decimal totalMonthlyPayment = 0;

        Decimal yearlyTotalMonthlyPayment =  nullDecimal(sdq.get('Scenario_' + i + '_First_Month_Payment__c')) * 12;
        
        for (Integer ii = 0; ii < savingYears; ii++){
            totalMonthlyPayment += yearlyTotalMonthlyPayment * Decimal.valueOf(Math.pow(1 + leaseEsc, (Double)ii));
        }

        System.debug('totalMonthlyPayment '+totalMonthlyPayment );

        Decimal afterTotalCost = nonSolarCost + totalMonthlyPayment;
        if (sdq.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c') != null && (Decimal)sdq.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c') > 0)
            afterTotalCost = beforeTotalCost + totalMonthlyPayment;   //Alternate handling for Feed In Tariff

        System.debug('afterTotalCost '+afterTotalCost );

        //Decimal netSavings = fiveYearBeforeCost - fiveYearNetCost - fiveYearMonthlyPayment;              
        //Decimal fiveYearBeforeCost = nullDecimal(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Five_Year_Before_Bill_Cost__c);
        //Decimal avoidedUtilityRate = nullDecimal(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Avoided_Utility_Rate__c);        
        //Double esc = Double.valueOf(getPercent(termLoan.get('Assumed_Utility_Rate_Annual_Escalator__c'), 0.004));
        //fiveYearSavings = fiveYearSavings.setScale(2);        
        //Decimal fiveYearAfterSolarCost = fiveYearSavings + fiveYearMonthlyPayment;
        
        Proposal__c prp = new Proposal__c();
        prp.put('Scenario_'+i+'_Estimated_Operational_Start_D__c', sdq.Pricing_Date__c != null ? Date.valueOf(sdq.Pricing_Date__c).addDays(90) : System.today());
        Decimal termMonth = (Decimal)sdq.get('Scenario_'+i+'_Proposal_Term_months__c');
        prp.put('Scenario_'+i+'_Proposal_Term_months__c', termMonth);
        
        Decimal[] srecEarnings = pp.getAnnualSrecEarnings(prp, sdq, i, savingYears * 12);
        
        
        Decimal totalSRECEarnings = 0;
        if(srecEarnings !=null && srecEarnings.size() >= savingYears)
        {
            for (Integer j = 0; j < savingYears; j++){
            
                totalSRECEarnings = totalSRECEarnings + srecEarnings[j];    
            }
        }
        System.debug('totalSRECEarnings '+totalSRECEarnings);

        Decimal percentSavings = 0;
        if (beforeTotalCost != 0){
            Decimal feedInTariffIncome = 0;
            if (sdq.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c') != null && (Decimal)sdq.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c') > 0)
                feedInTariffIncome = (Decimal)sdq.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c') * savingYears;
            percentSavings = (beforeTotalCost - (afterTotalCost - totalSRECEarnings - feedInTariffIncome))  / beforeTotalCost;
        }
         
        Decimal assumedSavings = getPercent(termLoan.get('Required_Utility_Savings__c'), 0.05);
        if (percentSavings < assumedSavings)
        {
            percentSavings = (percentSavings*100).setScale(2);        
            return 'Scenario ' + i + ' utility bill savings for the first five years must be greater than or equal to ' + Integer.valueOf(termLoan.get('Required_Utility_Savings__c')) + '%. The current savings percent is ' + percentSavings + '%';            
        }
        else
        {
            return null;
        }
    }
    
    private static String deserializeStoredStateSDQ(System_Design_Quote__c sdq){
        String storedJSON = sdq.System_Design_Stored_State__c != null ? sdq.System_Design_Stored_State__c : '';
        String[] jsonArr = storedJSON.split('<;>');    //Create an array of JSON strings
        Property__c old_prop = new Property__c();
        Map<ID, Physical_Surface__c> old_physicalSurfaces = new Map<ID, Physical_Surface__c>();
        Map<ID, Install_Location__c> old_installLocs = new Map<ID, Install_Location__c>();
        Map<ID, CB_Panel__c> old_cbPanels = new Map<ID, CB_Panel__c>();
        Map<ID, Utility_Service__c> old_utilServices = new Map<ID, Utility_Service__c>();
        Set<ID> phySurfIDs = new Set<ID>();
        Set<ID> instLocIDs = new Set<ID>();
        Set<ID> cbIDs = new Set<ID>();
        Set<ID> usIDs = new Set<ID>();
        for (String str : jsonArr){
            ID recID = ID.valueOf(str.substringBetween('"Id":"', '"'));
            if (recID.getSObjectType() == Schema.Property__c.SObjectType){
                Property__c restoredProp = (Property__c)JSON.deserialize(str, Property__c.class);
                old_prop = restoredProp;
            } else if (recID.getSObjectType() == Schema.Physical_Surface__c.SObjectType){
                Physical_Surface__c restoredPS = (Physical_Surface__c)JSON.deserialize(str, Physical_Surface__c.class);
                old_physicalSurfaces.put(recID, restoredPS);
                phySurfIDs.add(recID);
            } else if (recID.getSObjectType() == Schema.Install_Location__c.SObjectType){
                Install_Location__c restoredIL = (Install_Location__c)JSON.deserialize(str, Install_Location__c.class);
                old_installLocs.put(recID, restoredIL);
                instLocIDs.add(recID);
            } else if (recID.getSObjectType() == Schema.CB_Panel__c.SObjectType){
                CB_Panel__c restoredCB = (CB_Panel__c)JSON.deserialize(str, CB_Panel__c.class);
                old_cbPanels.put(recID, restoredCB);
                cbIDs.add(recID);
            } else if (recID.getSObjectType() == Schema.Utility_Service__c.SObjectType){
                Utility_Service__c restoredUS = (Utility_Service__c)JSON.deserialize(str, Utility_Service__c.class);
                old_utilServices.put(recID, restoredUS);
                usIDs.add(recID);
            }
        }
        
        //Query the current versions of these related records
        System_Design__c sd = [SELECT Property__c, Default_CB_Panel__c FROM System_Design__c WHERE ID = :sdq.System_Design__c LIMIT 1];
        Property__c new_prop = [SELECT RecordTypeID, Sales_Region__c, Latitude__c, Longitude__c, ValidationTimestamp__c, Optimal_Site_Quality_kWh_y_kW__c, DC_to_AC_Derate__c 
                                FROM Property__c WHERE ID = :sd.Property__c LIMIT 1];
        Map<ID, Physical_Surface__c> new_physicalSurfaces = new Map<ID, Physical_Surface__c>([SELECT Surface_Type__c, Number_of_Stories__c, Structural_Members__c, 
                                                                                              Surface_Tilt__c, Surface_Azimuth__c, Mounting_Plane_is_Not_Parallel__c, 
                                                                                              Trenching_Dist_to_Intercon_Pt_ft__c, Default_Mounting__c, Outbuilding__c 
                                                                                              FROM Physical_Surface__c WHERE Property__c = :new_prop.ID]);
        Set<ID> installLocationIDs = new Set<ID>();
        for (System_Design_Item__c sdi : [SELECT Install_Location__c FROM System_Design_Item__c WHERE RecordType.DeveloperName = 'Panel' 
                                          AND Quantity__c != 0 AND System_Design_Array__r.System_Design__c = :sd.ID])
            installLocationIDs.add(sdi.Install_Location__c);
                                          
        Map<ID, Install_Location__c> new_installLocs = new Map<ID, Install_Location__c>([SELECT Pitch__c, Azimuth__c, TSRF__c, Annual_Solar_Access__c, Verified_Single_SunEye_Data__c 
                                                                                         FROM Install_Location__c WHERE ID IN :installLocationIDs]);                           
        Map<ID, CB_Panel__c> new_cbPanels = new Map<ID, CB_Panel__c>([SELECT Utility_Service__c, Main_Breaker_Rating_Amps__c, Bus_Rating_Amps__c, Panel_Location__c, Count_of_Open_Circuits__c 
                                                                      FROM CB_Panel__c WHERE ID = :sd.Default_CB_Panel__c LIMIT 1]);
        ID cbMeterID;
        try {
            cbMeterID = new_cbPanels.values().get(0).Utility_Service__c;    //There should only be one record in the map
        } catch (Exception e){
            System.debug('Error in SalesWorkflowValidationUtility on line ' + e.getLineNumber() + ': ' + e.getMessage());
            throw e;
        }
        Map<ID, Utility_Service__c> new_utilServices = new Map<ID, Utility_Service__c>([SELECT Utility_Company_Master__c, Service_Entry_Type__c FROM Utility_Service__c WHERE ID = :cbMeterID LIMIT 1]);
        
        phySurfIDs.addAll(new_physicalSurfaces.keySet());
        instLocIDs.addAll(new_installLocs.keySet());
        cbIDs.addAll(new_cbPanels.keySet());
        usIDs.addAll(new_utilServices.keySet());
        
        //Get unions of all record IDs
        ID[] allPhysSurfs = new List<ID>(phySurfIDs);
        ID[] allInstLocs = new List<ID>(instLocIDs);
        ID[] allCBs = new List<ID>(cbIDs);
        ID[] allUtilServices = new List<ID>(usIDs);
        
        //--- Now compare the records ---//
        sdq.System_Design_Stored_State_Mismatch__c = '';
        if (old_prop.ID != new_prop.ID){
            sdq.System_Design_Stored_State_Mismatch__c += 'Mismatch on Property. Archived record is `' + old_prop.ID + '` and found record is `' + new_prop.ID + '`.';
        } else {
            if (old_prop.RecordTypeID != new_prop.RecordTypeID)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Record Type of Property `' + old_prop.ID + '` has been altered since SDQ serialization.\n';
            if (old_prop.Sales_Region__c != new_prop.Sales_Region__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Sales_Region__c of Property `' + old_prop.ID + '` has been altered since SDQ serialization.\n';
            if (old_prop.Latitude__c !=new_prop.Latitude__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Latitude__c of Property `' + old_prop.ID + '` has been altered since SDQ serialization.\n';
            if (old_prop.Longitude__c != new_prop.Longitude__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Longitude__c of Property `' + old_prop.ID + '` has been altered since SDQ serialization.\n';
            if (old_prop.ValidationTimestamp__c != new_prop.ValidationTimestamp__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The ValidationTimestamp__c of Property `' + old_prop.ID + '` has been altered since SDQ serialization.\n';
            if (old_prop.Optimal_Site_Quality_kWh_y_kW__c != new_prop.Optimal_Site_Quality_kWh_y_kW__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Optimal_Site_Quality_kWh_y_kW__c of Property `' + old_prop.ID + '` has been altered since SDQ serialization.\n';
            if (old_prop.DC_to_AC_Derate__c != new_prop.DC_to_AC_Derate__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The DC_to_AC_Derate__c of Property `' + old_prop.ID + '` has been altered since SDQ serialization.\n';
        }
        
        for (ID psID : allPhysSurfs){
            if (!old_physicalSurfaces.containsKey(psID)){
                sdq.System_Design_Stored_State_Mismatch__c += 'Physical Surface `' + psID + '` has been inserted since SDQ serialization.\n';
                continue;
            } else if (!new_physicalSurfaces.containsKey(psID)){
                sdq.System_Design_Stored_State_Mismatch__c += 'Physical Surface `' + psID + '` has been deleted since SDQ serialization.\n';
                continue;
            }
            if (old_physicalSurfaces.get(psID).Surface_Type__c != new_physicalSurfaces.get(psID).Surface_Type__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Surface_Type__c of Physical Surface `' + psID + '` has been altered since SDQ serialization.\n';
            if (old_physicalSurfaces.get(psID).Number_of_Stories__c != new_physicalSurfaces.get(psID).Number_of_Stories__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Number_of_Stories__c of Physical Surface `' + psID + '` has been altered since SDQ serialization.\n';
            if (old_physicalSurfaces.get(psID).Structural_Members__c != new_physicalSurfaces.get(psID).Structural_Members__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Structural_Members__c of Physical Surface `' + psID + '` has been altered since SDQ serialization.\n';
            if (old_physicalSurfaces.get(psID).Surface_Tilt__c != new_physicalSurfaces.get(psID).Surface_Tilt__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Surface_Tilt__c of Physical Surface `' + psID + '` has been altered since SDQ serialization.\n';
            if (old_physicalSurfaces.get(psID).Surface_Azimuth__c != new_physicalSurfaces.get(psID).Surface_Azimuth__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Surface_Azimuth__c of Physical Surface `' + psID + '` has been altered since SDQ serialization.\n';
            if (old_physicalSurfaces.get(psID).Mounting_Plane_is_Not_Parallel__c != new_physicalSurfaces.get(psID).Mounting_Plane_is_Not_Parallel__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Mounting_Plane_is_Not_Parallel__c of Physical Surface `' + psID + '` has been altered since SDQ serialization.\n';
            if (old_physicalSurfaces.get(psID).Trenching_Dist_to_Intercon_Pt_ft__c != new_physicalSurfaces.get(psID).Trenching_Dist_to_Intercon_Pt_ft__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Trenching_Dist_to_Intercon_Pt_ft__c of Physical Surface `' + psID + '` has been altered since SDQ serialization.\n';
            if (old_physicalSurfaces.get(psID).Default_Mounting__c != new_physicalSurfaces.get(psID).Default_Mounting__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Default_Mounting__c of Physical Surface `' + psID + '` has been altered since SDQ serialization.\n';
            if (old_physicalSurfaces.get(psID).Outbuilding__c != new_physicalSurfaces.get(psID).Outbuilding__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Outbuilding__c of Physical Surface `' + psID + '` has been altered since SDQ serialization.\n';
        }
        
        for (ID ilID : allInstLocs){
            if (!old_installLocs.containsKey(ilID)){
                sdq.System_Design_Stored_State_Mismatch__c += 'Install Location `' + ilID + '` has been inserted since SDQ serialization.\n';
                continue;
            } else if (!new_installLocs.containsKey(ilID)){
                sdq.System_Design_Stored_State_Mismatch__c += 'Install Location `' + ilID + '` has been deleted since SDQ serialization.\n';
                continue;
            }
            if (old_installLocs.get(ilID).Pitch__c != new_installLocs.get(ilID).Pitch__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Pitch__c of Install Location `' + ilID + '` has been altered since SDQ serialization.\n';
            if (old_installLocs.get(ilID).Azimuth__c != new_installLocs.get(ilID).Azimuth__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Azimuth__c of Install Location `' + ilID + '` has been altered since SDQ serialization.\n';
            if (old_installLocs.get(ilID).TSRF__c != new_installLocs.get(ilID).TSRF__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The TSRF__c of Install Location `' + ilID + '` has been altered since SDQ serialization.\n';
            if (old_installLocs.get(ilID).Annual_Solar_Access__c != new_installLocs.get(ilID).Annual_Solar_Access__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Annual_Solar_Access__c of Install Location `' + ilID + '` has been altered since SDQ serialization.\n';
            if (old_installLocs.get(ilID).Verified_Single_SunEye_Data__c != new_installLocs.get(ilID).Verified_Single_SunEye_Data__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Verified_Single_SunEye_Data__c of Install Location `' + ilID + '` has been altered since SDQ serialization.\n';
        }
        
        for (ID cbID : allCBs){
            if (!old_cbPanels.containsKey(cbID)){
                sdq.System_Design_Stored_State_Mismatch__c += 'CB Panel `' + cbID + '` has been inserted since SDQ serialization.\n';
                continue;
            } else if (!new_cbPanels.containsKey(cbID)){
                sdq.System_Design_Stored_State_Mismatch__c += 'CB Panel `' + cbID + '` has been deleted since SDQ serialization.\n';
                continue;
            }
            if (old_cbPanels.get(cbID).Utility_Service__c != new_cbPanels.get(cbID).Utility_Service__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Utility_Service__c (Meter ID) of CB Panel `' + cbID + '` has been altered since SDQ serialization.\n';
            if (old_cbPanels.get(cbID).Main_Breaker_Rating_Amps__c != new_cbPanels.get(cbID).Main_Breaker_Rating_Amps__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Main_Breaker_Rating_Amps__c of CB Panel `' + cbID + '` has been altered since SDQ serialization.\n';
            if (old_cbPanels.get(cbID).Bus_Rating_Amps__c != new_cbPanels.get(cbID).Bus_Rating_Amps__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Bus_Rating_Amps__c of CB Panel `' + cbID + '` has been altered since SDQ serialization.\n';
            if (old_cbPanels.get(cbID).Panel_Location__c != new_cbPanels.get(cbID).Panel_Location__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Panel_Location__c of CB Panel `' + cbID + '` has been altered since SDQ serialization.\n';
            if (old_cbPanels.get(cbID).Count_of_Open_Circuits__c != new_cbPanels.get(cbID).Count_of_Open_Circuits__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Count_of_Open_Circuits__c of CB Panel `' + cbID + '` has been altered since SDQ serialization.\n';
        }
        
        for (ID usID : allUtilServices){
            if (!old_utilServices.containsKey(usID)){
                sdq.System_Design_Stored_State_Mismatch__c += 'Utility Service `' + usID + '` has been inserted since SDQ serialization.\n';
                continue;
            } else if (!new_utilServices.containsKey(usID)){
                sdq.System_Design_Stored_State_Mismatch__c += 'Utility Service `' + usID + '` has been deleted since SDQ serialization.\n';
                continue;
            }
            if (old_utilServices.get(usID).Utility_Company_Master__c != new_utilServices.get(usID).Utility_Company_Master__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Utility_Company_Master__c (Utility Company) of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
            if (old_utilServices.get(usID).Service_Entry_Type__c != new_utilServices.get(usID).Service_Entry_Type__c)
                sdq.System_Design_Stored_State_Mismatch__c += 'The Service_Entry_Type__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
        }
        
        if (sdq.System_Design_Stored_State_Mismatch__c == '')
            return 'Valid';
        else
            return sdq.System_Design_Stored_State_Mismatch__c;
    }
    
    private static String[] deserializeReconstructionSDQ(System_Design_Quote__c sdq, Boolean makeCurrentMode){
        //If makeCurrentMode = false: Normal deserialization action where mismatches are logged
        //If makeCurrentMode = true: Queried records will be updated with archived field values
        String makeCurrentResult = '';
        
        String storedJSON = sdq.System_Design_Reconstruction_Record__c != null ? sdq.System_Design_Reconstruction_Record__c : '';
        String[] jsonArr = storedJSON.split('<;>');    //Create an array of JSON strings
        System_Design__c old_sysDesign = new System_Design__c();
        Map<ID, System_Design_Array__c> old_sdArrays = new Map<ID, System_Design_Array__c>();
        Map<ID, System_Design_Item__c> old_sdItems = new Map<ID, System_Design_Item__c>();
        Map<ID, Physical_Surface__c> old_physicalSurfaces = new Map<ID, Physical_Surface__c>();
        Map<ID, Utility_Service__c> old_utilServices = new Map<ID, Utility_Service__c>();
        Set<ID> sdArrayIDs = new Set<ID>();
        Set<ID> sdItemIDs = new Set<ID>();
        Set<ID> phySurfIDs = new Set<ID>();
        Set<ID> usIDs = new Set<ID>();
        for (String str : jsonArr){
            ID recID = ID.valueOf(str.substringBetween('"Id":"', '"'));
            if (recID.getSObjectType() == Schema.System_Design__c.SObjectType){
                System_Design__c restoredSD = (System_Design__c)JSON.deserialize(str, System_Design__c.class);
                old_sysDesign = restoredSD;
            } else if (recID.getSObjectType() == Schema.System_Design_Array__c.SObjectType){
                System_Design_Array__c restoredSDA = (System_Design_Array__c)JSON.deserialize(str, System_Design_Array__c.class);
                old_sdArrays.put(recID, restoredSDA);
                sdArrayIDs.add(recID);
            } else if (recID.getSObjectType() == Schema.System_Design_Item__c.SObjectType){
                System_Design_Item__c restoredSDI = (System_Design_Item__c)JSON.deserialize(str, System_Design_Item__c.class);
                old_sdItems.put(recID, restoredSDI);
                sdItemIDs.add(recID);
            } else if (recID.getSObjectType() == Schema.Physical_Surface__c.SObjectType){
                Physical_Surface__c restoredPS = (Physical_Surface__c)JSON.deserialize(str, Physical_Surface__c.class);
                old_physicalSurfaces.put(recID, restoredPS);
                phySurfIDs.add(recID);
            } else if (recID.getSObjectType() == Schema.Utility_Service__c.SObjectType){
                Utility_Service__c restoredUS = (Utility_Service__c)JSON.deserialize(str, Utility_Service__c.class);
                old_utilServices.put(recID, restoredUS);
                usIDs.add(recID);
            }
        }
        
        //Query the current versions of these related records
        System_Design__c new_sysDesign = [SELECT Trenching_Required__c, Vent_Stack_Movement_Required__c, Includes_Outbuilding_Installation__c, Inside_Only_Conduit__c, 
                                          Number_of_Locations_with_Tree_Removal__c, System_Panel__c, System_Inverter__c FROM System_Design__c WHERE ID = :sdq.System_Design__c LIMIT 1];
        
        Map<ID, System_Design_Array__c> new_sdArrays = new Map<ID, System_Design_Array__c>([SELECT System_Design__c, Physical_Surface__c, Survey__c, CB_Panel__c, Mounting_Type__c, CB_Panel__r.Utility_Service__c, 
                                                                                            Original_Surface_Tilt__c, Original_Surface_Azimuth__c, Special_Parts_Required__c, Trench_Type__c, Default_Mounting_Type__c 
                                                                                            FROM System_Design_Array__c WHERE System_Design__c = :new_sysDesign.ID]);
        Map<ID, System_Design_Item__c> new_sdItems = new Map<ID, System_Design_Item__c>([SELECT Name, Install_Location__c, System_Design_Array__c, System_Design_Product__c, Quantity__c, 
                                                                                         TSRF_Adjustment__c, Legacy_Astrum_Site_Quality__c, RecordTypeID, Total_Trenching_Lengthft__c, Tilt__c 
                                                                                         FROM System_Design_Item__c WHERE System_Design_Array__c IN :new_sdArrays.keySet()]);
        Set<ID> physicalSurfaceIDs = new Set<ID>();
        Set<ID> utilServiceIDs = new Set<ID>();
        for (System_Design_Array__c sda : new_sdArrays.values()){
            physicalSurfaceIDs.add(sda.Physical_Surface__c);
            utilServiceIDs.add(sda.CB_Panel__r.Utility_Service__c);
        }
        Map<ID, Physical_Surface__c> new_physicalSurfaces = new Map<ID, Physical_Surface__c>([SELECT Mounting_Plane_Tilt__c, Mounting_Plane_Azimuth__c FROM Physical_Surface__c WHERE ID IN :physicalSurfaceIDs]);
        
        Map<ID, Utility_Service__c> new_utilServices = new Map<ID, Utility_Service__c>([SELECT Utility_Rate_Code_Before_Solar__c, Utility_Rate_Code_After_Solar__c, Forecasted_Add_Consumption_kWh_Jan__c, 
                                                                                        Forecasted_Add_Consumption_kWh_Feb__c, Forecasted_Add_Consumption_kWh_Mar__c, Forecasted_Add_Consumption_kWh_Apr__c,
                                                                                        Forecasted_Add_Consumption_kWh_May__c, Forecasted_Add_Consumption_kWh_Jun__c, Forecasted_Add_Consumption_kWh_Jul__c,
                                                                                        Forecasted_Add_Consumption_kWh_Aug__c, Forecasted_Add_Consumption_kWh_Sep__c, Forecasted_Add_Consumption_kWh_Oct__c,
                                                                                        Forecasted_Add_Consumption_kWh_Nov__c, Forecasted_Add_Consumption_kWh_Dec__c, Consumption_Profile__c, 
                                                                                        Monthly_Electric_Consumption_kWh_Jan__c, Monthly_Electric_Consumption_kWh_Feb__c, Monthly_Electric_Consumption_kWh_Mar__c, 
                                                                                        Monthly_Electric_Consumption_kWh_Apr__c, Monthly_Electric_Consumption_kWh_May__c, Monthly_Electric_Consumption_kWh_Jun__c, 
                                                                                        Monthly_Electric_Consumption_kWh_Jul__c, Monthly_Electric_Consumption_kWh_Aug__c, Monthly_Electric_Consumption_kWh_Sep__c, 
                                                                                        Monthly_Electric_Consumption_kWh_Oct__c, Monthly_Electric_Consumption_kWh_Nov__c, Monthly_Electric_Consumption_kWh_Dec__c 
                                                                                        FROM Utility_Service__c WHERE ID IN :utilServiceIDs]);
        sdArrayIDs.addAll(new_sdArrays.keySet());
        sdItemIDs.addAll(new_sdItems.keySet());
        phySurfIDs.addAll(new_physicalSurfaces.keySet());
        usIDs.addAll(new_utilServices.keySet());
        
        //Get unions of all record IDs
        ID[] allSDArrays = new List<ID>(sdArrayIDs);
        ID[] allSDItems = new List<ID>(sdItemIDs);
        ID[] allPhysSurfs = new List<ID>(phySurfIDs);
        ID[] allUtilServices = new List<ID>(usIDs);
        
        //--- Now compare the records ---//
        sdq.Sys_Design_Reconstruct_Record_Mismatch__c = '';
        if (old_sysDesign.ID != new_sysDesign.ID){
            if (makeCurrentMode)
                makeCurrentResult = 'System Design `' + old_sysDesign.ID + '` is no longer associated with the SDQ `' + sdq.ID + '`. Cannot make SDQ current until resolved.';
            else
                sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'Mismatch on System Design. Archived record is `' + old_sysDesign.ID + '` and found record is `' + new_sysDesign.ID + '`.';
        } else {
            if (makeCurrentMode){
                //Update the fields on this SD to match the archived versions
                if (old_sysDesign.Trenching_Required__c != new_sysDesign.Trenching_Required__c)
                    new_sysDesign.Trenching_Required__c = old_sysDesign.Trenching_Required__c;
                if (old_sysDesign.Vent_Stack_Movement_Required__c != new_sysDesign.Vent_Stack_Movement_Required__c)
                    new_sysDesign.Vent_Stack_Movement_Required__c = old_sysDesign.Vent_Stack_Movement_Required__c;
                if (old_sysDesign.Includes_Outbuilding_Installation__c != new_sysDesign.Includes_Outbuilding_Installation__c)
                    new_sysDesign.Includes_Outbuilding_Installation__c = old_sysDesign.Includes_Outbuilding_Installation__c;
                if (old_sysDesign.Inside_Only_Conduit__c != new_sysDesign.Inside_Only_Conduit__c)
                    new_sysDesign.Inside_Only_Conduit__c = old_sysDesign.Inside_Only_Conduit__c;
                if (old_sysDesign.Number_of_Locations_with_Tree_Removal__c != new_sysDesign.Number_of_Locations_with_Tree_Removal__c)
                    new_sysDesign.Number_of_Locations_with_Tree_Removal__c = old_sysDesign.Number_of_Locations_with_Tree_Removal__c;
                if (old_sysDesign.System_Panel__c != new_sysDesign.System_Panel__c)
                    new_sysDesign.System_Panel__c = old_sysDesign.System_Panel__c;
                if (old_sysDesign.System_Inverter__c != new_sysDesign.System_Inverter__c)
                    new_sysDesign.System_Inverter__c = old_sysDesign.System_Inverter__c; 
            } else {
                if (old_sysDesign.Trenching_Required__c != new_sysDesign.Trenching_Required__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Trenching_Required__c of System Design `' + old_sysDesign.ID + '` has been altered since SDQ serialization.\n';
                if (old_sysDesign.Vent_Stack_Movement_Required__c != new_sysDesign.Vent_Stack_Movement_Required__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Vent_Stack_Movement_Required__c of System Design `' + old_sysDesign.ID + '` has been altered since SDQ serialization.\n';
                if (old_sysDesign.Includes_Outbuilding_Installation__c != new_sysDesign.Includes_Outbuilding_Installation__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Includes_Outbuilding_Installation__c of System Design `' + old_sysDesign.ID + '` has been altered since SDQ serialization.\n';
                if (old_sysDesign.Inside_Only_Conduit__c != new_sysDesign.Inside_Only_Conduit__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Inside_Only_Conduit__c of System Design `' + old_sysDesign.ID + '` has been altered since SDQ serialization.\n';
                if (old_sysDesign.Number_of_Locations_with_Tree_Removal__c != new_sysDesign.Number_of_Locations_with_Tree_Removal__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Number_of_Locations_with_Tree_Removal__c of System Design `' + old_sysDesign.ID + '` has been altered since SDQ serialization.\n';
                if (old_sysDesign.System_Panel__c != new_sysDesign.System_Panel__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The System_Panel__c of System Design `' + old_sysDesign.ID + '` has been altered since SDQ serialization.\n';
                if (old_sysDesign.System_Inverter__c != new_sysDesign.System_Inverter__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The System_Inverter__c of System Design `' + old_sysDesign.ID + '` has been altered since SDQ serialization.\n';
            }
        }
        if (makeCurrentMode && makeCurrentResult != '')
            return new String[]{makeCurrentResult, 'false'};   //Quit the reconstruction if the System Design is not matched by ID
        
        Map<ID, System_Design_Array__c> recreateSDAs = new Map<ID, System_Design_Array__c>();   //Archived ID --> Cloned version to insert
        Map<ID, System_Design_Array__c> deleteSDAs = new Map<ID, System_Design_Array__c>();     //ID --> SDA to delete
        System_Design_Array__c[] updateSDAs = new System_Design_Array__c[]{};
        for (ID sdaID : allSDArrays){
            if (!old_sdArrays.containsKey(sdaID)){
                if (makeCurrentMode){
                    makeCurrentResult += 'System Design Array `' + sdaID + '` has been inserted since SDQ serialization.\n';
                    //Since this SDA is not a part of the archived System Design, we mark it for deletion
                    if (new_sdArrays.containsKey(sdaID))    //Essentially guaranteed
                        deleteSDAs.put(sdaID, new_sdArrays.get(sdaID));
                } else {
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'System Design Array `' + sdaID + '` has been inserted since SDQ serialization.\n';
                }
                continue;
            } else if (!new_sdArrays.containsKey(sdaID)){
                if (makeCurrentMode){
                    makeCurrentResult += 'System Design Array `' + sdaID + '` has been deleted since SDQ serialization.\n';
                    //This archived SDA has been deleted, so we mark it for insertion
                    if (old_sdArrays.containsKey(sdaID))    //Essentially guaranteed
                        recreateSDAs.put(sdaID, old_sdArrays.get(sdaID).clone(false, true, false, false));
                } else {
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'System Design Array `' + sdaID + '` has been deleted since SDQ serialization.\n';
                }
                continue;
            }
            System_Design_Array__c oldSDA = old_sdArrays.get(sdaID);
            System_Design_Array__c newSDA = new_sdArrays.get(sdaID);
            
            if (makeCurrentMode){
                //Update the fields on this SDA to match the archived versions
                if (oldSDA.System_Design__c != newSDA.System_Design__c)
                    newSDA.System_Design__c = oldSDA.System_Design__c;
                if (oldSDA.Physical_Surface__c != newSDA.Physical_Surface__c)
                    newSDA.Physical_Surface__c = oldSDA.Physical_Surface__c;
                if (oldSDA.Survey__c != newSDA.Survey__c)
                    newSDA.Survey__c = oldSDA.Survey__c;
                if (oldSDA.CB_Panel__c != newSDA.CB_Panel__c)
                    newSDA.CB_Panel__c = oldSDA.CB_Panel__c;
                if (oldSDA.Mounting_Type__c != newSDA.Mounting_Type__c)
                    newSDA.Mounting_Type__c = oldSDA.Mounting_Type__c;
                updateSDAs.add(newSDA);
            } else {
                if (oldSDA.System_Design__c != newSDA.System_Design__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The System_Design__c of System Design Array `' + sdaID + '` has been altered since SDQ serialization.\n';
                if (oldSDA.Physical_Surface__c != newSDA.Physical_Surface__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Physical_Surface__c of System Design Array `' + sdaID + '` has been altered since SDQ serialization.\n';
                if (oldSDA.Survey__c != newSDA.Survey__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Survey__c of System Design Array `' + sdaID + '` has been altered since SDQ serialization.\n';
                if (oldSDA.CB_Panel__c != newSDA.CB_Panel__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The CB_Panel__c of System Design Array `' + sdaID + '` has been altered since SDQ serialization.\n';
                if (oldSDA.Mounting_Type__c != newSDA.Mounting_Type__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Mounting_Type__c of System Design Array `' + sdaID + '` has been altered since SDQ serialization.\n';
            }
        }
        
        //Insert the SDAs we wish to restore (In order to generate their new IDs)
        insert recreateSDAs.values();
        
        System_Design_Item__c[] recreateSDIs = new System_Design_Item__c[]{};   //Cloned SDIs to insert
        System_Design_Item__c[] deleteSDIs = new System_Design_Item__c[]{};
        System_Design_Item__c[] updateSDIs = new System_Design_Item__c[]{};
        for (ID sdiID : allSDItems){
            if (!old_sdItems.containsKey(sdiID)){
                if (makeCurrentMode){
                    makeCurrentResult += 'System Design Item `' + sdiID + '` has been inserted since SDQ serialization.\n';
                    //This SDI is not a part of the archived System Design
                    if (new_sdItems.containsKey(sdiID) && !deleteSDAs.containsKey(new_sdItems.get(sdiID).System_Design_Array__c))
                        deleteSDIs.add(new_sdItems.get(sdiID)); //Set for deletion if its parent SDA is not marked for deletion (Otherwise, the SDA deletion will cascade to SDIs)
                } else {
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'System Design Item `' + sdiID + '` has been inserted since SDQ serialization.\n';       
                }
                continue;
            } else if (!new_sdItems.containsKey(sdiID)){
                if (makeCurrentMode){
                    makeCurrentResult += 'System Design Item `' + sdiID + '` has been deleted since SDQ serialization.\n';
                    //This archived SDI has been deleted, so we mark it for insertion
                    if (old_sdItems.containsKey(sdiID)){    //Essentially guaranteed
                        System_Design_Item__c clonedSDI = old_sdItems.get(sdiID).clone(false, true, false, false);
                        //Check if this SDI looks up to a deleted SDA
                        if (recreateSDAs.containsKey(clonedSDI.System_Design_Array__c))
                            clonedSDI.System_Design_Array__c = recreateSDAs.get(clonedSDI.System_Design_Array__c).ID;    //Match the old ID and update it to the new one
                        recreateSDIs.add(clonedSDI);
                    }
                } else {
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'System Design Item `' + sdiID + '` has been deleted since SDQ serialization.\n';
                }
                continue;
            }
            System_Design_Item__c oldSDI = old_sdItems.get(sdiID);
            System_Design_Item__c newSDI = new_sdItems.get(sdiID);
            
            if (makeCurrentMode){
                //Update the fields on this SDI to match the archived versions
                if (oldSDI.Install_Location__c != newSDI.Install_Location__c)
                    newSDI.Install_Location__c = oldSDI.Install_Location__c;
                if (oldSDI.System_Design_Array__c != newSDI.System_Design_Array__c)
                    newSDI.System_Design_Array__c = oldSDI.System_Design_Array__c;
                if (oldSDI.System_Design_Product__c != newSDI.System_Design_Product__c)
                    newSDI.System_Design_Product__c = oldSDI.System_Design_Product__c;
                if (oldSDI.Quantity__c != newSDI.Quantity__c)
                    newSDI.Quantity__c = oldSDI.Quantity__c;
                if (oldSDI.Legacy_Astrum_Site_Quality__c != newSDI.Legacy_Astrum_Site_Quality__c)
                    newSDI.Legacy_Astrum_Site_Quality__c = oldSDI.Legacy_Astrum_Site_Quality__c;
                if (oldSDI.RecordTypeID != newSDI.RecordTypeID)
                    newSDI.RecordTypeID = oldSDI.RecordTypeID;
                if (oldSDI.Total_Trenching_Lengthft__c != newSDI.Total_Trenching_Lengthft__c)
                    newSDI.Total_Trenching_Lengthft__c = oldSDI.Total_Trenching_Lengthft__c;
                updateSDIs.add(newSDI);
            } else {
                if (oldSDI.Install_Location__c != newSDI.Install_Location__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Install_Location__c of System Design Item `' + sdiID + '` has been altered since SDQ serialization.\n';
                if (oldSDI.System_Design_Array__c != newSDI.System_Design_Array__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The System_Design_Array__c of System Design Item `' + sdiID + '` has been altered since SDQ serialization.\n';
                if (oldSDI.System_Design_Product__c != newSDI.System_Design_Product__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The System_Design_Product__c of System Design Item `' + sdiID + '` has been altered since SDQ serialization.\n';
                if (oldSDI.Quantity__c != newSDI.Quantity__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Quantity__c of System Design Item `' + sdiID + '` has been altered since SDQ serialization.\n';
                if (oldSDI.Legacy_Astrum_Site_Quality__c != newSDI.Legacy_Astrum_Site_Quality__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Legacy_Astrum_Site_Quality__c of System Design Item `' + sdiID + '` has been altered since SDQ serialization.\n';
                if (oldSDI.RecordTypeID != newSDI.RecordTypeID)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The RecordTypeID of System Design Item `' + sdiID + '` has been altered since SDQ serialization.\n';
                if (oldSDI.Total_Trenching_Lengthft__c != newSDI.Total_Trenching_Lengthft__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Total_Trenching_Lengthft__c of System Design Item `' + sdiID + '` has been altered since SDQ serialization.\n';
            }
        }
        
        //String emailMessageBody = '';   //Build a string for the error message email that contains information for each problem record
        
        Physical_Surface__c[] updatePhysSurfs = new Physical_Surface__c[]{};
        for (ID psID : allPhysSurfs){
            if (!old_physicalSurfaces.containsKey(psID)){
                if (makeCurrentMode){
                    makeCurrentResult += 'Physical Surface `' + psID + '` has been inserted since SDQ serialization.\n';
                    //emailMessageBody +=  'Physical Surface "' + psID + '" has been inserted since SDQ serialization. It should no longer be valid on the recontructed SDQ.\n';
                } else {
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'Physical Surface `' + psID + '` has been inserted since SDQ serialization.\n';
                }
                continue;
            } else if (!new_physicalSurfaces.containsKey(psID)){
                if (makeCurrentMode){
                    makeCurrentResult += 'Physical Surface `' + psID + '` has been deleted since SDQ serialization.\n';
                    //emailMessageBody +=  'Physical Surface "' + psID + '" has been deleted since SDQ serialization. It needs to be recreated on the recontructed SDQ.\n';
                } else {
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'Physical Surface `' + psID + '` has been deleted since SDQ serialization.\n';
                }
                continue;
            }
            Physical_Surface__c oldPhysSurf = old_physicalSurfaces.get(psID);
            Physical_Surface__c newPhysSurf = new_physicalSurfaces.get(psID);
            
            if (makeCurrentMode){
                //Update the fields on this SDI to match the archived versions
                if (oldPhysSurf.Mounting_Plane_Tilt__c != newPhysSurf.Mounting_Plane_Tilt__c)
                    newPhysSurf.Mounting_Plane_Tilt__c = oldPhysSurf.Mounting_Plane_Tilt__c;
                if (oldPhysSurf.Mounting_Plane_Azimuth__c != newPhysSurf.Mounting_Plane_Azimuth__c)
                    newPhysSurf.Mounting_Plane_Azimuth__c = oldPhysSurf.Mounting_Plane_Azimuth__c;
                updatePhysSurfs.add(newPhysSurf);
            } else {
                if (oldPhysSurf.Mounting_Plane_Tilt__c != newPhysSurf.Mounting_Plane_Tilt__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Mounting_Plane_Tilt__c of Physical Surface `' + psID + '` has been altered since SDQ serialization.\n';
                if (oldPhysSurf.Mounting_Plane_Azimuth__c != newPhysSurf.Mounting_Plane_Azimuth__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Mounting_Plane_Azimuth__c of Physical Surface `' + psID + '` has been altered since SDQ serialization.\n';
            }
        }
        
        Utility_Service__c[] updateUtilServices = new Utility_Service__c[]{};
        for (ID usID : allUtilServices){
            if (!old_utilServices.containsKey(usID)){
                if (makeCurrentMode){
                    makeCurrentResult += 'Utility Service `' + usID + '` has been inserted since SDQ serialization.\n';
                    //emailMessageBody += 'Utility Service "' + usID + '" has been inserted since SDQ serialization. It should no longer be valid on the recontructed SDQ.\n';
                } else {
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'Utility Service `' + usID + '` has been inserted since SDQ serialization.\n';
                }
                continue;
            } else if (!new_utilServices.containsKey(usID)){
                if (makeCurrentMode){
                    makeCurrentResult += 'Utility Service `' + usID + '` has been deleted since SDQ serialization.\n';
                    //emailMessageBody += 'Utility Service "' + usID + '" has been deleted since SDQ serialization. It needs to be recreated on the recontructed SDQ.\n';
                } else {
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'Utility Service `' + usID + '` has been deleted since SDQ serialization.\n';
                }
                continue;
            }
            Utility_Service__c oldUtilService = old_utilServices.get(usID);
            Utility_Service__c newUtilService = new_utilServices.get(usID);
            
            if (makeCurrentMode){
                //Update the fields on this Utility Service to match the archived versions
                if (oldUtilService.Utility_Rate_Code_Before_Solar__c != newUtilService.Utility_Rate_Code_Before_Solar__c)
                    newUtilService.Utility_Rate_Code_Before_Solar__c = oldUtilService.Utility_Rate_Code_Before_Solar__c;
                if (oldUtilService.Utility_Rate_Code_After_Solar__c != newUtilService.Utility_Rate_Code_After_Solar__c)
                    newUtilService.Utility_Rate_Code_After_Solar__c = oldUtilService.Utility_Rate_Code_After_Solar__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Jan__c != newUtilService.Forecasted_Add_Consumption_kWh_Jan__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_Jan__c = oldUtilService.Forecasted_Add_Consumption_kWh_Jan__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Feb__c != newUtilService.Forecasted_Add_Consumption_kWh_Feb__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_Feb__c = oldUtilService.Forecasted_Add_Consumption_kWh_Feb__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Mar__c != newUtilService.Forecasted_Add_Consumption_kWh_Mar__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_Mar__c = oldUtilService.Forecasted_Add_Consumption_kWh_Mar__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Apr__c != newUtilService.Forecasted_Add_Consumption_kWh_Apr__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_Apr__c = oldUtilService.Forecasted_Add_Consumption_kWh_Apr__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_May__c != newUtilService.Forecasted_Add_Consumption_kWh_May__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_May__c = oldUtilService.Forecasted_Add_Consumption_kWh_May__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Jun__c != newUtilService.Forecasted_Add_Consumption_kWh_Jun__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_Jun__c = oldUtilService.Forecasted_Add_Consumption_kWh_Jun__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Jul__c != newUtilService.Forecasted_Add_Consumption_kWh_Jul__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_Jul__c = oldUtilService.Forecasted_Add_Consumption_kWh_Jul__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Aug__c != newUtilService.Forecasted_Add_Consumption_kWh_Aug__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_Aug__c = oldUtilService.Forecasted_Add_Consumption_kWh_Aug__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Sep__c != newUtilService.Forecasted_Add_Consumption_kWh_Sep__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_Sep__c = oldUtilService.Forecasted_Add_Consumption_kWh_Sep__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Oct__c != newUtilService.Forecasted_Add_Consumption_kWh_Oct__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_Oct__c = oldUtilService.Forecasted_Add_Consumption_kWh_Oct__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Nov__c != newUtilService.Forecasted_Add_Consumption_kWh_Nov__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_Nov__c = oldUtilService.Forecasted_Add_Consumption_kWh_Nov__c;
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Dec__c != newUtilService.Forecasted_Add_Consumption_kWh_Dec__c)
                    newUtilService.Forecasted_Add_Consumption_kWh_Dec__c = oldUtilService.Forecasted_Add_Consumption_kWh_Dec__c;
                if (oldUtilService.Consumption_Profile__c != newUtilService.Consumption_Profile__c)
                    newUtilService.Consumption_Profile__c = oldUtilService.Consumption_Profile__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Jan__c != newUtilService.Monthly_Electric_Consumption_kWh_Jan__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_Jan__c = oldUtilService.Monthly_Electric_Consumption_kWh_Jan__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Feb__c != newUtilService.Monthly_Electric_Consumption_kWh_Feb__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_Feb__c = oldUtilService.Monthly_Electric_Consumption_kWh_Feb__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Mar__c != newUtilService.Monthly_Electric_Consumption_kWh_Mar__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_Mar__c = oldUtilService.Monthly_Electric_Consumption_kWh_Mar__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Apr__c != newUtilService.Monthly_Electric_Consumption_kWh_Apr__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_Apr__c = oldUtilService.Monthly_Electric_Consumption_kWh_Apr__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_May__c != newUtilService.Monthly_Electric_Consumption_kWh_May__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_May__c = oldUtilService.Monthly_Electric_Consumption_kWh_May__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Jun__c != newUtilService.Monthly_Electric_Consumption_kWh_Jun__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_Jun__c = oldUtilService.Monthly_Electric_Consumption_kWh_Jun__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Jul__c != newUtilService.Monthly_Electric_Consumption_kWh_Jul__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_Jul__c = oldUtilService.Monthly_Electric_Consumption_kWh_Jul__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Aug__c != newUtilService.Monthly_Electric_Consumption_kWh_Aug__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_Aug__c = oldUtilService.Monthly_Electric_Consumption_kWh_Aug__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Sep__c != newUtilService.Monthly_Electric_Consumption_kWh_Sep__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_Sep__c = oldUtilService.Monthly_Electric_Consumption_kWh_Sep__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Oct__c != newUtilService.Monthly_Electric_Consumption_kWh_Oct__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_Oct__c = oldUtilService.Monthly_Electric_Consumption_kWh_Oct__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Nov__c != newUtilService.Monthly_Electric_Consumption_kWh_Nov__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_Nov__c = oldUtilService.Monthly_Electric_Consumption_kWh_Nov__c;
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Dec__c != newUtilService.Monthly_Electric_Consumption_kWh_Dec__c)
                    newUtilService.Monthly_Electric_Consumption_kWh_Dec__c = oldUtilService.Monthly_Electric_Consumption_kWh_Dec__c;
                updateUtilServices.add(newUtilService);
            } else {
                if (oldUtilService.Utility_Rate_Code_Before_Solar__c != newUtilService.Utility_Rate_Code_Before_Solar__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Utility_Rate_Code_Before_Solar__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Utility_Rate_Code_After_Solar__c != newUtilService.Utility_Rate_Code_After_Solar__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Utility_Rate_Code_After_Solar__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Jan__c != newUtilService.Monthly_Electric_Consumption_kWh_Jan__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_Jan__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Feb__c != newUtilService.Monthly_Electric_Consumption_kWh_Feb__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_Feb__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Mar__c != newUtilService.Monthly_Electric_Consumption_kWh_Mar__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_Mar__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Apr__c != newUtilService.Monthly_Electric_Consumption_kWh_Apr__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_Apr__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_May__c != newUtilService.Monthly_Electric_Consumption_kWh_May__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_May__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Jun__c != newUtilService.Monthly_Electric_Consumption_kWh_Jun__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_Jun__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Jul__c != newUtilService.Monthly_Electric_Consumption_kWh_Jul__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_Jul__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Aug__c != newUtilService.Monthly_Electric_Consumption_kWh_Aug__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_Aug__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Sep__c != newUtilService.Monthly_Electric_Consumption_kWh_Sep__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_Sep__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Oct__c != newUtilService.Monthly_Electric_Consumption_kWh_Oct__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_Oct__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Nov__c != newUtilService.Monthly_Electric_Consumption_kWh_Nov__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_Nov__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Monthly_Electric_Consumption_kWh_Dec__c != newUtilService.Monthly_Electric_Consumption_kWh_Dec__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Monthly_Electric_Consumption_kWh_Dec__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Consumption_Profile__c != newUtilService.Consumption_Profile__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Consumption_Profile__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Jan__c != newUtilService.Forecasted_Add_Consumption_kWh_Jan__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_Jan__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Feb__c != newUtilService.Forecasted_Add_Consumption_kWh_Feb__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_Feb__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Mar__c != newUtilService.Forecasted_Add_Consumption_kWh_Mar__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_Mar__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Apr__c != newUtilService.Forecasted_Add_Consumption_kWh_Apr__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_Apr__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_May__c != newUtilService.Forecasted_Add_Consumption_kWh_May__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_May__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Jun__c != newUtilService.Forecasted_Add_Consumption_kWh_Jun__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_Jun__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Jul__c != newUtilService.Forecasted_Add_Consumption_kWh_Jul__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_Jul__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Aug__c != newUtilService.Forecasted_Add_Consumption_kWh_Aug__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_Aug__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Sep__c != newUtilService.Forecasted_Add_Consumption_kWh_Sep__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_Sep__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Oct__c != newUtilService.Forecasted_Add_Consumption_kWh_Oct__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_Oct__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Nov__c != newUtilService.Forecasted_Add_Consumption_kWh_Nov__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_Nov__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
                if (oldUtilService.Forecasted_Add_Consumption_kWh_Dec__c != newUtilService.Forecasted_Add_Consumption_kWh_Dec__c)
                    sdq.Sys_Design_Reconstruct_Record_Mismatch__c += 'The Forecasted_Add_Consumption_kWh_Dec__c of Utility Service `' + usID + '` has been altered since SDQ serialization.\n';
            }
        }
        
        String success = 'true';
        if (makeCurrentMode){   //Perform the DML for restoring the System Design and its components to the serialized state
            Savepoint sp = Database.setSavepoint();
            try {
                Opportunity_Trigger_Utility.skipOpportunityTrigger = true;  //Limit the trigger execution chain
                update new_sysDesign;
                
                update updateSDAs;
                delete deleteSDAs.values();
                
                insert recreateSDIs;    //At risk of having invalid Install Location IDs if their parent Physical Surfaces have since been deleted
                update updateSDIs;
                delete deleteSDIs;
                
                update updatePhysSurfs;
                
                update updateUtilServices;
                Opportunity_Trigger_Utility.skipOpportunityTrigger = false;
            } catch (Exception e) {
                success = 'false';
                Database.rollback(sp);  //If one DML operation fails, then roll back all of them
                System.debug('Error in reconstructing a System Design in SalesWorkflowValidationUtility:' + e.getStackTraceString());
            }
            
            //if (emailMessageBody != '' && !Test.isRunningTest())    //Physical Surface and/or Utility Service has records to insert or delete
                //EmailUtil.adminEmail('SDQ Workflow and Validation', 'Encountered Issues while Reconstructing System Design', emailMessageBody + '\n\n' + dmlException);
            
            if (makeCurrentResult == '')
                makeCurrentResult = 'Valid';
            return new String[]{makeCurrentResult, success};
        }
        
        if (sdq.Sys_Design_Reconstruct_Record_Mismatch__c == '')
            return new String[]{'Valid', success};
        else 
            return new String[]{sdq.Sys_Design_Reconstruct_Record_Mismatch__c, success};
    }
    
    @TestVisible private static String[] deserializeReconstructionProposal(Proposal__c prop, Boolean makeCurrentMode){
        //If makeCurrentMode = false: Normal deserialization action where mismatches are logged
        //If makeCurrentMode = true: Queried records will be updated with archived field values
        
        String storedJSON = prop.SDQ_Reconstruction_Record__c != null ? prop.SDQ_Reconstruction_Record__c : '';
        String[] jsonArr = storedJSON.split('<;>');    //Create an array of JSON strings
        System_Design_Quote__c old_sdq = new System_Design_Quote__c();
        Map<ID, Available_Incentive_Offer__c> old_incentiveOffers = new Map<ID, Available_Incentive_Offer__c>();
        Map<ID, Price_Adjustment__c> old_priceAdjs = new Map<ID, Price_Adjustment__c>();
        Map<ID, Available_SREC_Contract_Offer__c> old_srecOffers = new Map<ID, Available_SREC_Contract_Offer__c>();
        Set<ID> incentiveOfferIDs = new Set<ID>();
        Set<ID> priceAdjIDs = new Set<ID>();
        Set<ID> srecOfferIDs = new Set<ID>();
        for (String str : jsonArr){
            String recIDStr = str.substringBetween('"Id":"', '"');
            if (String.isBlank(recIDStr))
                continue;
            ID recID = ID.valueOf(recIDStr);
            if (recID.getSObjectType() == Schema.System_Design_Quote__c.SObjectType){
                System_Design_Quote__c restoredSDQ = (System_Design_Quote__c)JSON.deserialize(str, System_Design_Quote__c.class);
                old_sdq = restoredSDQ;
            } else if (recID.getSObjectType() == Schema.Available_Incentive_Offer__c.SObjectType){
                Available_Incentive_Offer__c restoredIncOffer = (Available_Incentive_Offer__c)JSON.deserialize(str, Available_Incentive_Offer__c.class);
                old_incentiveOffers.put(recID, restoredIncOffer);
                incentiveOfferIDs.add(recID);
            } else if (recID.getSObjectType() == Schema.Price_Adjustment__c.SObjectType){
                Price_Adjustment__c restoredPA = (Price_Adjustment__c)JSON.deserialize(str, Price_Adjustment__c.class);
                old_priceAdjs.put(recID, restoredPA);
                priceAdjIDs.add(recID);
            } else if (recID.getSObjectType() == Schema.Available_SREC_Contract_Offer__c.SObjectType){
                Available_SREC_Contract_Offer__c restoredSREC = (Available_SREC_Contract_Offer__c)JSON.deserialize(str, Available_SREC_Contract_Offer__c.class);
                old_srecOffers.put(recID, restoredSREC);
                srecOfferIDs.add(recID);
            }
        }
        
        //Query the current versions of these related records
        System_Design_Quote__c new_sdq = [SELECT Channel_Partner__c, Channel_Partner_Lease_Rate_kWh__c, Primary_Residence__c, Property_in_Revocable_Trust__c, Property_in_Historic_Trust__c, 
                                          Natural_Disaster_Adder_Eligible__c, Moderate_Home_Value_Adder_Eligible__c, Previously_Received_County_Tax_Credit__c, Previously_Received_State_Rebate__c, 
                                          Previously_Received_State_Tax_Credit__c, Previously_Received_Utility_Rebate__c, Moderate_Income_Value_Adder_Eligible__c, Scenario_1_Financing_Type__c, 
                                          Scenario_2_Financing_Type__c, Scenario_3_Financing_Type__c, Scenario_4_Financing_Type__c, Scenario_1_Lease_Fund__c, Scenario_2_Lease_Fund__c, Scenario_3_Lease_Fund__c, 
                                          Scenario_4_Lease_Fund__c, Scenario_1_Term_Loan__c, Scenario_2_Term_Loan__c, Scenario_3_Term_Loan__c, Scenario_4_Term_Loan__c, Scenario_1_SAC_Loan__c, 
                                          Scenario_2_SAC_Loan__c, Scenario_3_SAC_Loan__c, Scenario_4_SAC_Loan__c, Scenario_1_Lease_Escalator__c,  Scenario_2_Lease_Escalator__c, Scenario_3_Lease_Escalator__c, 
                                          Scenario_4_Lease_Escalator__c, Scenario_1_Credit_Tier__c, Scenario_2_Credit_Tier__c, Scenario_3_Credit_Tier__c, Scenario_4_Credit_Tier__c, Scenario_1_Financing_Option__c, 
                                          Scenario_2_Financing_Option__c, Scenario_3_Financing_Option__c, Scenario_4_Financing_Option__c, Scenario_1_Lease_Option__c, Scenario_2_Lease_Option__c, 
                                          Scenario_3_Lease_Option__c, Scenario_4_Lease_Option__c, Scenario_1_Down_Payment__c, Scenario_2_Down_Payment__c, Scenario_3_Down_Payment__c, Scenario_4_Down_Payment__c, 
                                          Scenario_1_Apply_Standard_Adjustment__c, Scenario_2_Apply_Standard_Adjustment__c, Scenario_3_Apply_Standard_Adjustment__c, Scenario_4_Apply_Standard_Adjustment__c, 
                                          Scenario_1_Set_Standard_Adjustment_Type__c, Scenario_2_Set_Standard_Adjustment_Type__c, Scenario_3_Set_Standard_Adjustment_Type__c, Scenario_4_Set_Standard_Adjustment_Type__c, 
                                          Scenario_1_Set_Standard_Adjustment_Amoun__c, Scenario_2_Set_Standard_Adjustment_Amoun__c, Scenario_3_Set_Standard_Adjustment_Amoun__c, Scenario_4_Set_Standard_Adjustment_Amoun__c, 
                                          Scenario_1_VP_Sales_Adjustments__c, Scenario_2_VP_Sales_Adjustments__c, Scenario_3_VP_Sales_Adjustments__c, Scenario_4_VP_Sales_Adjustments__c, 
                                          Scenario_1_Refuse_ACH__c, Scenario_2_Refuse_ACH__c, Scenario_3_Refuse_ACH__c, Scenario_4_Refuse_ACH__c, 
                                          Annual_Property_Tax_Bill__c, Income_Corporate_Tax_Rate__c, Utility_Annual_Increase__c, System_Design_Reconstruction_Record__c, System_Design_Stored_State__c 
                                          FROM System_Design_Quote__c WHERE ID = :prop.System_Design_Quote__c LIMIT 1];
        
        Map<ID, Available_Incentive_Offer__c> new_incentiveOffers = new Map<ID, Available_Incentive_Offer__c>([SELECT Incentive_Applied__c, Opted_Out_Manually__c FROM Available_Incentive_Offer__c WHERE System_Design_Quote__c = :prop.System_Design_Quote__c 
                                                                                                               AND Apply_Effective_Price__c = true AND Applicable_Scenario__c != null]);
        
        Map<ID, Price_Adjustment__c> new_priceAdjs = new Map<ID, Price_Adjustment__c>([SELECT Adjustment_Applied__c, Opt_Out_of_Adjustment__c, Type__c FROM Price_Adjustment__c WHERE System_Design_Quote__c = :prop.System_Design_Quote__c 
                                                                                       AND Applicable_Scenario__c != null]);
        
        Map<ID, Available_SREC_Contract_Offer__c> new_srecOffers = new Map<ID, Available_SREC_Contract_Offer__c>([SELECT Contract_Offer_Applied__c FROM Available_SREC_Contract_Offer__c 
                                                                                                                  WHERE System_Design_Quote__c = :prop.System_Design_Quote__c AND Applicable_Scenario__c != null]);
        incentiveOfferIDs.addAll(new_incentiveOffers.keySet());
        priceAdjIDs.addAll(new_priceAdjs.keySet());
        srecOfferIDs.addAll(new_srecOffers.keySet());
        
        //Get unions of all record IDs
        ID[] allIncOffers = new List<ID>(incentiveOfferIDs);
        ID[] allPriceAdjs = new List<ID>(priceAdjIDs);
        ID[] allSrecOffers = new List<ID>(srecOfferIDs);
        
        //--- Now compare the records ---//
        String resultStr = '';
        if (old_sdq.ID != new_sdq.ID){
            resultStr += 'System Design Quote `' + old_sdq.ID + '` is no longer associated with the Proposal `' + prop.ID + '`. Cannot make Proposal current until resolved.';
            return new String[]{resultStr, 'false'};
        } else {
            if (makeCurrentMode){
                //Update the fields on this SDQ to match the archived versions
                if (old_sdq.Channel_Partner__c != new_sdq.Channel_Partner__c)
                    new_sdq.Channel_Partner__c = old_sdq.Channel_Partner__c;
                if (old_sdq.Channel_Partner_Lease_Rate_kWh__c != new_sdq.Channel_Partner_Lease_Rate_kWh__c)
                    new_sdq.Channel_Partner_Lease_Rate_kWh__c = old_sdq.Channel_Partner_Lease_Rate_kWh__c;
                if (old_sdq.Primary_Residence__c != new_sdq.Primary_Residence__c)
                    new_sdq.Primary_Residence__c = old_sdq.Primary_Residence__c;
                if (old_sdq.Property_in_Revocable_Trust__c != new_sdq.Property_in_Revocable_Trust__c)
                    new_sdq.Property_in_Revocable_Trust__c = old_sdq.Property_in_Revocable_Trust__c;
                if (old_sdq.Natural_Disaster_Adder_Eligible__c != new_sdq.Natural_Disaster_Adder_Eligible__c)
                    new_sdq.Natural_Disaster_Adder_Eligible__c = old_sdq.Natural_Disaster_Adder_Eligible__c;
                if (old_sdq.Moderate_Home_Value_Adder_Eligible__c != new_sdq.Moderate_Home_Value_Adder_Eligible__c)
                    new_sdq.Moderate_Home_Value_Adder_Eligible__c = old_sdq.Moderate_Home_Value_Adder_Eligible__c;
                if (old_sdq.Previously_Received_County_Tax_Credit__c != new_sdq.Previously_Received_County_Tax_Credit__c)
                    new_sdq.Previously_Received_County_Tax_Credit__c = old_sdq.Previously_Received_County_Tax_Credit__c;
                if (old_sdq.Previously_Received_State_Rebate__c != new_sdq.Previously_Received_State_Rebate__c)
                    new_sdq.Previously_Received_State_Rebate__c = old_sdq.Previously_Received_State_Rebate__c;
                if (old_sdq.Previously_Received_State_Tax_Credit__c != new_sdq.Previously_Received_State_Tax_Credit__c)
                    new_sdq.Previously_Received_State_Tax_Credit__c = old_sdq.Previously_Received_State_Tax_Credit__c;
                if (old_sdq.Previously_Received_Utility_Rebate__c != new_sdq.Previously_Received_Utility_Rebate__c)
                    new_sdq.Previously_Received_Utility_Rebate__c = old_sdq.Previously_Received_Utility_Rebate__c;
                if (old_sdq.Moderate_Income_Value_Adder_Eligible__c != new_sdq.Moderate_Income_Value_Adder_Eligible__c)
                    new_sdq.Moderate_Income_Value_Adder_Eligible__c = old_sdq.Moderate_Income_Value_Adder_Eligible__c;
                if (old_sdq.Scenario_1_Financing_Type__c != new_sdq.Scenario_1_Financing_Type__c)
                    new_sdq.Scenario_1_Financing_Type__c = old_sdq.Scenario_1_Financing_Type__c;
                if (old_sdq.Scenario_2_Financing_Type__c != new_sdq.Scenario_2_Financing_Type__c)
                    new_sdq.Scenario_2_Financing_Type__c = old_sdq.Scenario_2_Financing_Type__c;
                if (old_sdq.Scenario_3_Financing_Type__c != new_sdq.Scenario_3_Financing_Type__c)
                    new_sdq.Scenario_3_Financing_Type__c = old_sdq.Scenario_3_Financing_Type__c;
                if (old_sdq.Scenario_4_Financing_Type__c != new_sdq.Scenario_4_Financing_Type__c)
                    new_sdq.Scenario_4_Financing_Type__c = old_sdq.Scenario_4_Financing_Type__c;
                if (old_sdq.Scenario_1_Lease_Fund__c != new_sdq.Scenario_1_Lease_Fund__c)
                    new_sdq.Scenario_1_Lease_Fund__c = old_sdq.Scenario_1_Lease_Fund__c;
                if (old_sdq.Scenario_2_Lease_Fund__c != new_sdq.Scenario_2_Lease_Fund__c)
                    new_sdq.Scenario_2_Lease_Fund__c = old_sdq.Scenario_2_Lease_Fund__c;
                if (old_sdq.Scenario_3_Lease_Fund__c != new_sdq.Scenario_3_Lease_Fund__c)
                    new_sdq.Scenario_3_Lease_Fund__c = old_sdq.Scenario_3_Lease_Fund__c;
                if (old_sdq.Scenario_4_Lease_Fund__c != new_sdq.Scenario_4_Lease_Fund__c)
                    new_sdq.Scenario_4_Lease_Fund__c = old_sdq.Scenario_4_Lease_Fund__c;
                if (old_sdq.Scenario_1_Term_Loan__c != new_sdq.Scenario_1_Term_Loan__c)
                    new_sdq.Scenario_1_Term_Loan__c = old_sdq.Scenario_1_Term_Loan__c;
                if (old_sdq.Scenario_2_Term_Loan__c != new_sdq.Scenario_2_Term_Loan__c)
                    new_sdq.Scenario_2_Term_Loan__c = old_sdq.Scenario_2_Term_Loan__c;
                if (old_sdq.Scenario_3_Term_Loan__c != new_sdq.Scenario_3_Term_Loan__c)
                    new_sdq.Scenario_3_Term_Loan__c = old_sdq.Scenario_3_Term_Loan__c;
                if (old_sdq.Scenario_4_Term_Loan__c != new_sdq.Scenario_4_Term_Loan__c)
                    new_sdq.Scenario_4_Term_Loan__c = old_sdq.Scenario_4_Term_Loan__c;
                if (old_sdq.Scenario_1_SAC_Loan__c != new_sdq.Scenario_1_SAC_Loan__c)
                    new_sdq.Scenario_1_SAC_Loan__c = old_sdq.Scenario_1_SAC_Loan__c;
                if (old_sdq.Scenario_2_SAC_Loan__c != new_sdq.Scenario_2_SAC_Loan__c)
                    new_sdq.Scenario_2_SAC_Loan__c = old_sdq.Scenario_2_SAC_Loan__c;
                if (old_sdq.Scenario_3_SAC_Loan__c != new_sdq.Scenario_3_SAC_Loan__c)
                    new_sdq.Scenario_3_SAC_Loan__c = old_sdq.Scenario_3_SAC_Loan__c;
                if (old_sdq.Scenario_4_SAC_Loan__c != new_sdq.Scenario_4_SAC_Loan__c)
                    new_sdq.Scenario_4_SAC_Loan__c = old_sdq.Scenario_4_SAC_Loan__c;
                if (old_sdq.Scenario_1_Lease_Escalator__c != new_sdq.Scenario_1_Lease_Escalator__c)
                    new_sdq.Scenario_1_Lease_Escalator__c = old_sdq.Scenario_1_Lease_Escalator__c;
                if (old_sdq.Scenario_2_Lease_Escalator__c != new_sdq.Scenario_2_Lease_Escalator__c)
                    new_sdq.Scenario_2_Lease_Escalator__c = old_sdq.Scenario_2_Lease_Escalator__c;
                if (old_sdq.Scenario_3_Lease_Escalator__c != new_sdq.Scenario_3_Lease_Escalator__c)
                    new_sdq.Scenario_3_Lease_Escalator__c = old_sdq.Scenario_3_Lease_Escalator__c;
                if (old_sdq.Scenario_4_Lease_Escalator__c != new_sdq.Scenario_4_Lease_Escalator__c)
                    new_sdq.Scenario_4_Lease_Escalator__c = old_sdq.Scenario_4_Lease_Escalator__c;
                if (old_sdq.Scenario_1_Credit_Tier__c != new_sdq.Scenario_1_Credit_Tier__c)
                    new_sdq.Scenario_1_Credit_Tier__c = old_sdq.Scenario_1_Credit_Tier__c;
                if (old_sdq.Scenario_2_Credit_Tier__c != new_sdq.Scenario_2_Credit_Tier__c)
                    new_sdq.Scenario_2_Credit_Tier__c = old_sdq.Scenario_2_Credit_Tier__c;
                if (old_sdq.Scenario_3_Credit_Tier__c != new_sdq.Scenario_3_Credit_Tier__c)
                    new_sdq.Scenario_3_Credit_Tier__c = old_sdq.Scenario_3_Credit_Tier__c;
                if (old_sdq.Scenario_4_Credit_Tier__c != new_sdq.Scenario_4_Credit_Tier__c)
                    new_sdq.Scenario_4_Credit_Tier__c = old_sdq.Scenario_4_Credit_Tier__c;
                if (old_sdq.Scenario_1_Financing_Option__c != new_sdq.Scenario_1_Financing_Option__c)
                    new_sdq.Scenario_1_Financing_Option__c = old_sdq.Scenario_1_Financing_Option__c;
                if (old_sdq.Scenario_2_Financing_Option__c != new_sdq.Scenario_2_Financing_Option__c)
                    new_sdq.Scenario_2_Financing_Option__c = old_sdq.Scenario_2_Financing_Option__c;
                if (old_sdq.Scenario_3_Financing_Option__c != new_sdq.Scenario_3_Financing_Option__c)
                    new_sdq.Scenario_3_Financing_Option__c = old_sdq.Scenario_3_Financing_Option__c;
                if (old_sdq.Scenario_4_Financing_Option__c != new_sdq.Scenario_4_Financing_Option__c)
                    new_sdq.Scenario_4_Financing_Option__c = old_sdq.Scenario_4_Financing_Option__c;
                if (old_sdq.Scenario_1_Lease_Option__c != new_sdq.Scenario_1_Lease_Option__c)
                    new_sdq.Scenario_1_Lease_Option__c = old_sdq.Scenario_1_Lease_Option__c;
                if (old_sdq.Scenario_2_Lease_Option__c != new_sdq.Scenario_2_Lease_Option__c)
                    new_sdq.Scenario_2_Lease_Option__c = old_sdq.Scenario_2_Lease_Option__c;
                if (old_sdq.Scenario_3_Lease_Option__c != new_sdq.Scenario_3_Lease_Option__c)
                    new_sdq.Scenario_3_Lease_Option__c = old_sdq.Scenario_3_Lease_Option__c;
                if (old_sdq.Scenario_4_Lease_Option__c != new_sdq.Scenario_4_Lease_Option__c)
                    new_sdq.Scenario_4_Lease_Option__c = old_sdq.Scenario_4_Lease_Option__c;
                if (old_sdq.Scenario_1_Down_Payment__c != new_sdq.Scenario_1_Down_Payment__c)
                    new_sdq.Scenario_1_Down_Payment__c = old_sdq.Scenario_1_Down_Payment__c;
                if (old_sdq.Scenario_2_Down_Payment__c != new_sdq.Scenario_2_Down_Payment__c)
                    new_sdq.Scenario_2_Down_Payment__c = old_sdq.Scenario_2_Down_Payment__c;
                if (old_sdq.Scenario_3_Down_Payment__c != new_sdq.Scenario_3_Down_Payment__c)
                    new_sdq.Scenario_3_Down_Payment__c = old_sdq.Scenario_3_Down_Payment__c;
                if (old_sdq.Scenario_4_Down_Payment__c != new_sdq.Scenario_4_Down_Payment__c)
                    new_sdq.Scenario_4_Down_Payment__c = old_sdq.Scenario_4_Down_Payment__c;
                if (old_sdq.Scenario_1_Apply_Standard_Adjustment__c != new_sdq.Scenario_1_Apply_Standard_Adjustment__c)
                    new_sdq.Scenario_1_Apply_Standard_Adjustment__c = old_sdq.Scenario_1_Apply_Standard_Adjustment__c;
                if (old_sdq.Scenario_2_Apply_Standard_Adjustment__c != new_sdq.Scenario_2_Apply_Standard_Adjustment__c)
                    new_sdq.Scenario_2_Apply_Standard_Adjustment__c = old_sdq.Scenario_2_Apply_Standard_Adjustment__c;
                if (old_sdq.Scenario_3_Apply_Standard_Adjustment__c != new_sdq.Scenario_3_Apply_Standard_Adjustment__c)
                    new_sdq.Scenario_3_Apply_Standard_Adjustment__c = old_sdq.Scenario_3_Apply_Standard_Adjustment__c;
                if (old_sdq.Scenario_4_Apply_Standard_Adjustment__c != new_sdq.Scenario_4_Apply_Standard_Adjustment__c)
                    new_sdq.Scenario_4_Apply_Standard_Adjustment__c = old_sdq.Scenario_4_Apply_Standard_Adjustment__c;
                if (old_sdq.Scenario_1_Set_Standard_Adjustment_Type__c != new_sdq.Scenario_1_Set_Standard_Adjustment_Type__c)
                    new_sdq.Scenario_1_Set_Standard_Adjustment_Type__c = old_sdq.Scenario_1_Set_Standard_Adjustment_Type__c;
                if (old_sdq.Scenario_2_Set_Standard_Adjustment_Type__c != new_sdq.Scenario_2_Set_Standard_Adjustment_Type__c)
                    new_sdq.Scenario_2_Set_Standard_Adjustment_Type__c = old_sdq.Scenario_2_Set_Standard_Adjustment_Type__c;
                if (old_sdq.Scenario_3_Set_Standard_Adjustment_Type__c != new_sdq.Scenario_3_Set_Standard_Adjustment_Type__c)
                    new_sdq.Scenario_3_Set_Standard_Adjustment_Type__c = old_sdq.Scenario_3_Set_Standard_Adjustment_Type__c;
                if (old_sdq.Scenario_4_Set_Standard_Adjustment_Type__c != new_sdq.Scenario_4_Set_Standard_Adjustment_Type__c)
                    new_sdq.Scenario_4_Set_Standard_Adjustment_Type__c = old_sdq.Scenario_4_Set_Standard_Adjustment_Type__c;
                if (old_sdq.Scenario_1_Set_Standard_Adjustment_Amoun__c != new_sdq.Scenario_1_Set_Standard_Adjustment_Amoun__c)
                    new_sdq.Scenario_1_Set_Standard_Adjustment_Amoun__c = old_sdq.Scenario_1_Set_Standard_Adjustment_Amoun__c;
                if (old_sdq.Scenario_2_Set_Standard_Adjustment_Amoun__c != new_sdq.Scenario_2_Set_Standard_Adjustment_Amoun__c)
                    new_sdq.Scenario_2_Set_Standard_Adjustment_Amoun__c = old_sdq.Scenario_2_Set_Standard_Adjustment_Amoun__c;
                if (old_sdq.Scenario_3_Set_Standard_Adjustment_Amoun__c != new_sdq.Scenario_3_Set_Standard_Adjustment_Amoun__c)
                    new_sdq.Scenario_3_Set_Standard_Adjustment_Amoun__c = old_sdq.Scenario_3_Set_Standard_Adjustment_Amoun__c;
                if (old_sdq.Scenario_4_Set_Standard_Adjustment_Amoun__c != new_sdq.Scenario_4_Set_Standard_Adjustment_Amoun__c)
                    new_sdq.Scenario_4_Set_Standard_Adjustment_Amoun__c = old_sdq.Scenario_4_Set_Standard_Adjustment_Amoun__c;
                if (old_sdq.Scenario_1_VP_Sales_Adjustments__c != new_sdq.Scenario_1_VP_Sales_Adjustments__c)
                    new_sdq.Scenario_1_VP_Sales_Adjustments__c = old_sdq.Scenario_1_VP_Sales_Adjustments__c;
                if (old_sdq.Scenario_2_VP_Sales_Adjustments__c != new_sdq.Scenario_2_VP_Sales_Adjustments__c)
                    new_sdq.Scenario_2_VP_Sales_Adjustments__c = old_sdq.Scenario_2_VP_Sales_Adjustments__c;
                if (old_sdq.Scenario_3_VP_Sales_Adjustments__c != new_sdq.Scenario_3_VP_Sales_Adjustments__c)
                    new_sdq.Scenario_3_VP_Sales_Adjustments__c = old_sdq.Scenario_3_VP_Sales_Adjustments__c;
                if (old_sdq.Scenario_4_VP_Sales_Adjustments__c != new_sdq.Scenario_4_VP_Sales_Adjustments__c)
                    new_sdq.Scenario_4_VP_Sales_Adjustments__c = old_sdq.Scenario_4_VP_Sales_Adjustments__c;
                if (old_sdq.Scenario_1_Refuse_ACH__c != new_sdq.Scenario_1_Refuse_ACH__c)
                    new_sdq.Scenario_1_Refuse_ACH__c = old_sdq.Scenario_1_Refuse_ACH__c;
                if (old_sdq.Scenario_2_Refuse_ACH__c != new_sdq.Scenario_2_Refuse_ACH__c)
                    new_sdq.Scenario_2_Refuse_ACH__c = old_sdq.Scenario_2_Refuse_ACH__c;
                if (old_sdq.Scenario_3_Refuse_ACH__c != new_sdq.Scenario_3_Refuse_ACH__c)
                    new_sdq.Scenario_3_Refuse_ACH__c = old_sdq.Scenario_3_Refuse_ACH__c;
                if (old_sdq.Scenario_4_Refuse_ACH__c != new_sdq.Scenario_4_Refuse_ACH__c)
                    new_sdq.Scenario_4_Refuse_ACH__c = old_sdq.Scenario_4_Refuse_ACH__c;
                if (old_sdq.Annual_Property_Tax_Bill__c != new_sdq.Annual_Property_Tax_Bill__c)
                    new_sdq.Annual_Property_Tax_Bill__c = old_sdq.Annual_Property_Tax_Bill__c;
                if (old_sdq.Income_Corporate_Tax_Rate__c != new_sdq.Income_Corporate_Tax_Rate__c)
                    new_sdq.Income_Corporate_Tax_Rate__c = old_sdq.Income_Corporate_Tax_Rate__c;
                if (old_sdq.Utility_Annual_Increase__c != new_sdq.Utility_Annual_Increase__c)
                    new_sdq.Utility_Annual_Increase__c = old_sdq.Utility_Annual_Increase__c;
            } else {
                if (old_sdq.Channel_Partner__c != new_sdq.Channel_Partner__c)
                    resultStr += 'The Channel_Partner__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Channel_Partner_Lease_Rate_kWh__c != new_sdq.Channel_Partner_Lease_Rate_kWh__c)
                    resultStr += 'The Channel_Partner_Lease_Rate_kWh__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Primary_Residence__c != new_sdq.Primary_Residence__c)
                    resultStr += 'The Primary_Residence__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Property_in_Revocable_Trust__c != new_sdq.Property_in_Revocable_Trust__c)
                    resultStr += 'The Property_in_Revocable_Trust__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Natural_Disaster_Adder_Eligible__c != new_sdq.Natural_Disaster_Adder_Eligible__c)
                    resultStr += 'The Natural_Disaster_Adder_Eligible__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Moderate_Home_Value_Adder_Eligible__c != new_sdq.Moderate_Home_Value_Adder_Eligible__c)
                    resultStr += 'The Moderate_Home_Value_Adder_Eligible__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Previously_Received_County_Tax_Credit__c != new_sdq.Previously_Received_County_Tax_Credit__c)
                    resultStr += 'The Previously_Received_County_Tax_Credit__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Previously_Received_State_Rebate__c != new_sdq.Previously_Received_State_Rebate__c)
                    resultStr += 'The Previously_Received_State_Rebate__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Previously_Received_State_Tax_Credit__c != new_sdq.Previously_Received_State_Tax_Credit__c)
                    resultStr += 'The Previously_Received_State_Tax_Credit__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Previously_Received_Utility_Rebate__c != new_sdq.Previously_Received_Utility_Rebate__c)
                    resultStr += 'The Previously_Received_Utility_Rebate__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Moderate_Income_Value_Adder_Eligible__c != new_sdq.Moderate_Income_Value_Adder_Eligible__c)
                    resultStr += 'The Moderate_Income_Value_Adder_Eligible__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Financing_Type__c != new_sdq.Scenario_1_Financing_Type__c)
                    resultStr += 'The Scenario_1_Financing_Type__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Financing_Type__c != new_sdq.Scenario_2_Financing_Type__c)
                    resultStr += 'The Scenario_2_Financing_Type__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Financing_Type__c != new_sdq.Scenario_3_Financing_Type__c)
                    resultStr += 'The Scenario_3_Financing_Type__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Financing_Type__c != new_sdq.Scenario_4_Financing_Type__c)
                    resultStr += 'The Scenario_4_Financing_Type__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Lease_Fund__c != new_sdq.Scenario_1_Lease_Fund__c)
                    resultStr += 'The Scenario_1_Lease_Fund__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Lease_Fund__c != new_sdq.Scenario_2_Lease_Fund__c)
                    resultStr += 'The Scenario_2_Lease_Fund__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Lease_Fund__c != new_sdq.Scenario_3_Lease_Fund__c)
                    resultStr += 'The Scenario_3_Lease_Fund__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Lease_Fund__c != new_sdq.Scenario_4_Lease_Fund__c)
                    resultStr += 'The Scenario_4_Lease_Fund__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Term_Loan__c != new_sdq.Scenario_1_Term_Loan__c)
                    resultStr += 'The Scenario_1_Term_Loan__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Term_Loan__c != new_sdq.Scenario_2_Term_Loan__c)
                    resultStr += 'The Scenario_2_Term_Loan__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Term_Loan__c != new_sdq.Scenario_3_Term_Loan__c)
                    resultStr += 'The Scenario_3_Term_Loan__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Term_Loan__c != new_sdq.Scenario_4_Term_Loan__c)
                    resultStr += 'The Scenario_4_Term_Loan__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_SAC_Loan__c != new_sdq.Scenario_1_SAC_Loan__c)
                    resultStr += 'The Scenario_1_SAC_Loan__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_SAC_Loan__c != new_sdq.Scenario_2_SAC_Loan__c)
                    resultStr += 'The Scenario_2_SAC_Loan__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_SAC_Loan__c != new_sdq.Scenario_3_SAC_Loan__c)
                    resultStr += 'The Scenario_3_SAC_Loan__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_SAC_Loan__c != new_sdq.Scenario_4_SAC_Loan__c)
                    resultStr += 'The Scenario_4_SAC_Loan__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Lease_Escalator__c != new_sdq.Scenario_1_Lease_Escalator__c)
                    resultStr += 'The Scenario_1_Lease_Escalator__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Lease_Escalator__c != new_sdq.Scenario_2_Lease_Escalator__c)
                    resultStr += 'The Scenario_2_Lease_Escalator__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Lease_Escalator__c != new_sdq.Scenario_3_Lease_Escalator__c)
                    resultStr += 'The Scenario_3_Lease_Escalator__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Lease_Escalator__c != new_sdq.Scenario_4_Lease_Escalator__c)
                    resultStr += 'The Scenario_4_Lease_Escalator__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Credit_Tier__c != new_sdq.Scenario_1_Credit_Tier__c)
                    resultStr += 'The Scenario_1_Credit_Tier__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Credit_Tier__c != new_sdq.Scenario_2_Credit_Tier__c)
                    resultStr += 'The Scenario_2_Credit_Tier__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Credit_Tier__c != new_sdq.Scenario_3_Credit_Tier__c)
                    resultStr += 'The Scenario_3_Credit_Tier__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Credit_Tier__c != new_sdq.Scenario_4_Credit_Tier__c)
                    resultStr += 'The Scenario_4_Credit_Tier__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Financing_Option__c != new_sdq.Scenario_1_Financing_Option__c)
                    resultStr += 'The Scenario_1_Financing_Option__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Financing_Option__c != new_sdq.Scenario_2_Financing_Option__c)
                    resultStr += 'The Scenario_2_Financing_Option__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Financing_Option__c != new_sdq.Scenario_3_Financing_Option__c)
                    resultStr += 'The Scenario_3_Financing_Option__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Financing_Option__c != new_sdq.Scenario_4_Financing_Option__c)
                    resultStr += 'The Scenario_4_Financing_Option__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Lease_Option__c != new_sdq.Scenario_1_Lease_Option__c)
                    resultStr += 'The Scenario_1_Lease_Option__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Lease_Option__c != new_sdq.Scenario_2_Lease_Option__c)
                    resultStr += 'The Scenario_2_Lease_Option__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Lease_Option__c != new_sdq.Scenario_3_Lease_Option__c)
                    resultStr += 'The Scenario_3_Lease_Option__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Lease_Option__c != new_sdq.Scenario_4_Lease_Option__c)
                    resultStr += 'The Scenario_4_Lease_Option__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Down_Payment__c != new_sdq.Scenario_1_Down_Payment__c)
                    resultStr += 'The Scenario_1_Down_Payment__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Down_Payment__c != new_sdq.Scenario_2_Down_Payment__c)
                    resultStr += 'The Scenario_2_Down_Payment__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Down_Payment__c != new_sdq.Scenario_3_Down_Payment__c)
                    resultStr += 'The Scenario_3_Down_Payment__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Down_Payment__c != new_sdq.Scenario_4_Down_Payment__c)
                    resultStr += 'The Scenario_4_Down_Payment__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Apply_Standard_Adjustment__c != new_sdq.Scenario_1_Apply_Standard_Adjustment__c)
                    resultStr += 'The Scenario_1_Apply_Standard_Adjustment__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Apply_Standard_Adjustment__c != new_sdq.Scenario_2_Apply_Standard_Adjustment__c)
                    resultStr += 'The Scenario_2_Apply_Standard_Adjustment__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Apply_Standard_Adjustment__c != new_sdq.Scenario_3_Apply_Standard_Adjustment__c)
                    resultStr += 'The Scenario_3_Apply_Standard_Adjustment__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Apply_Standard_Adjustment__c != new_sdq.Scenario_4_Apply_Standard_Adjustment__c)
                    resultStr += 'The Scenario_4_Apply_Standard_Adjustment__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Set_Standard_Adjustment_Type__c != new_sdq.Scenario_1_Set_Standard_Adjustment_Type__c)
                    resultStr += 'The Scenario_1_Set_Standard_Adjustment_Type__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Set_Standard_Adjustment_Type__c != new_sdq.Scenario_2_Set_Standard_Adjustment_Type__c)
                    resultStr += 'The Scenario_2_Set_Standard_Adjustment_Type__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Set_Standard_Adjustment_Type__c != new_sdq.Scenario_3_Set_Standard_Adjustment_Type__c)
                    resultStr += 'The Scenario_3_Set_Standard_Adjustment_Type__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Set_Standard_Adjustment_Type__c != new_sdq.Scenario_4_Set_Standard_Adjustment_Type__c)
                    resultStr += 'The Scenario_4_Set_Standard_Adjustment_Type__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Set_Standard_Adjustment_Amoun__c != new_sdq.Scenario_1_Set_Standard_Adjustment_Amoun__c)
                    resultStr += 'The Scenario_1_Set_Standard_Adjustment_Amoun__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Set_Standard_Adjustment_Amoun__c != new_sdq.Scenario_2_Set_Standard_Adjustment_Amoun__c)
                    resultStr += 'The Scenario_2_Set_Standard_Adjustment_Amoun__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Set_Standard_Adjustment_Amoun__c != new_sdq.Scenario_3_Set_Standard_Adjustment_Amoun__c)
                    resultStr += 'The Scenario_3_Set_Standard_Adjustment_Amoun__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Set_Standard_Adjustment_Amoun__c != new_sdq.Scenario_4_Set_Standard_Adjustment_Amoun__c)
                    resultStr += 'The Scenario_4_Set_Standard_Adjustment_Amoun__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_VP_Sales_Adjustments__c != new_sdq.Scenario_1_VP_Sales_Adjustments__c)
                    resultStr += 'The Scenario_1_VP_Sales_Adjustments__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_VP_Sales_Adjustments__c != new_sdq.Scenario_2_VP_Sales_Adjustments__c)
                    resultStr += 'The Scenario_2_VP_Sales_Adjustments__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_VP_Sales_Adjustments__c != new_sdq.Scenario_3_VP_Sales_Adjustments__c)
                    resultStr += 'The Scenario_3_VP_Sales_Adjustments__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_VP_Sales_Adjustments__c != new_sdq.Scenario_4_VP_Sales_Adjustments__c)
                    resultStr += 'The Scenario_4_VP_Sales_Adjustments__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_1_Refuse_ACH__c != new_sdq.Scenario_1_Refuse_ACH__c)
                    resultStr += 'The Scenario_1_Refuse_ACH__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_2_Refuse_ACH__c != new_sdq.Scenario_2_Refuse_ACH__c)
                    resultStr += 'The Scenario_2_Refuse_ACH__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_3_Refuse_ACH__c != new_sdq.Scenario_3_Refuse_ACH__c)
                    resultStr += 'The Scenario_3_Refuse_ACH__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Scenario_4_Refuse_ACH__c != new_sdq.Scenario_4_Refuse_ACH__c)
                    resultStr += 'The Scenario_4_Refuse_ACH__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Annual_Property_Tax_Bill__c != new_sdq.Annual_Property_Tax_Bill__c)
                    resultStr += 'The Annual_Property_Tax_Bill__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Income_Corporate_Tax_Rate__c != new_sdq.Income_Corporate_Tax_Rate__c)
                    resultStr += 'The Income_Corporate_Tax_Rate__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
                if (old_sdq.Utility_Annual_Increase__c != new_sdq.Utility_Annual_Increase__c)
                    resultStr += 'The Utility_Annual_Increase__c of System Design Quote `' + old_sdq.ID + '` has been altered since SDQ serialization.\n';
            }
        }
        
        //Available_Incentive_Offer__c[] recreateIncOffers = new Available_Incentive_Offer__c[]{};    //Cloned Incentive Offers to insert
        //Available_Incentive_Offer__c[] deleteIncOffers = new Available_Incentive_Offer__c[]{};
        Available_Incentive_Offer__c[] updateIncOffers = new Available_Incentive_Offer__c[]{};
        for (ID ioID : allIncOffers){
            if (!old_incentiveOffers.containsKey(ioID)){
                if (makeCurrentMode){
                    if (new_incentiveOffers.containsKey(ioID)){  //Essentially guaranteed
                        new_incentiveOffers.get(ioID).Incentive_Applied__c = false;
                        new_incentiveOffers.get(ioID).Opted_Out_Manually__c = true;
                        updateIncOffers.add(new_incentiveOffers.get(ioID));     //Disable the existing Available Incentive Offer if it could not be found in the archive
                    }
                }
                continue;
            } else if (!new_incentiveOffers.containsKey(ioID)){
                //if (makeCurrentMode){
                //    if (old_incentiveOffers.containsKey(ioID)){    //Essentially guaranteed
                //        Available_Incentive_Offer__c clonedIO = old_incentiveOffers.get(ioID).clone(false, true, false, false);
                //        recreateIncOffers.add(clonedIO);    //This archived Incentive Offer has been deleted, so we mark it for insertion
                //    }
                //}
                //resultStr += 'Available Incentive Offer "' + ioID + '" has been deleted/made non-applicable since SDQ serialization.\n';
                continue;
            }
            Available_Incentive_Offer__c oldIncOffer = old_incentiveOffers.get(ioID);
            Available_Incentive_Offer__c newIncOffer = new_incentiveOffers.get(ioID);
            if (makeCurrentMode){
                if (oldIncOffer.Opted_Out_Manually__c != newIncOffer.Opted_Out_Manually__c)
                    newIncOffer.Opted_Out_Manually__c = oldIncOffer.Opted_Out_Manually__c;
                if (oldIncOffer.Incentive_Applied__c != newIncOffer.Incentive_Applied__c)
                    newIncOffer.Incentive_Applied__c = oldIncOffer.Incentive_Applied__c;
                updateIncOffers.add(newIncOffer);
            } else {
                if (oldIncOffer.Opted_Out_Manually__c != newIncOffer.Opted_Out_Manually__c)
                    resultStr += 'The Opted_Out_Manually__c of Available Incentive Offer `' + ioID + '` has been altered since SDQ serialization.\n';
                if (oldIncOffer.Incentive_Applied__c != newIncOffer.Incentive_Applied__c)
                    resultStr += 'The Incentive_Applied__c of Available Incentive Offer `' + ioID + '` has been altered since SDQ serialization.\n';
            }
        }
        
        //Price_Adjustment__c[] recreatePriceAdjs = new Price_Adjustment__c[]{};  //Cloned Price Adjustments to insert
        //Price_Adjustment__c[] deletePriceAdjs = new Price_Adjustment__c[]{};
        Price_Adjustment__c[] updatePriceAdjs = new Price_Adjustment__c[]{};
        for (ID paID : allPriceAdjs){
            if (!old_priceAdjs.containsKey(paID)){
                if (makeCurrentMode){
                    if (new_priceAdjs.containsKey(paID)){    //Essentially guaranteed
                        if (new_priceAdjs.get(paID).Type__c == 'Line Item')
                            new_priceAdjs.get(paID).Opt_Out_of_Adjustment__c = true;
                        new_priceAdjs.get(paID).Adjustment_Applied__c = false;
                        updatePriceAdjs.add(new_priceAdjs.get(paID));  //Disable the existing Price Adjustment if it could not be found in the archive
                    }
                }
                continue;
            } else if (!new_priceAdjs.containsKey(paID)){
                //if (makeCurrentMode){
                //    if (old_priceAdjs.containsKey(paID)){    //Essentially guaranteed
                //        Price_Adjustment__c clonedPA = old_priceAdjs.get(paID).clone(false, true, false, false);
                //        recreatePriceAdjs.add(clonedPA);    //This archived Price Adjustment has been deleted, so we mark it for insertion
                //    }
                //}
                //resultStr += 'Price Adjustment "' + paID + '" has been deleted/made non-applicable since SDQ serialization.\n';
                continue;
            }
            Price_Adjustment__c oldPriceAdj = old_priceAdjs.get(paID);
            Price_Adjustment__c newPriceAdj = new_priceAdjs.get(paID);
            if (makeCurrentMode){
                //If Price Adjustment is of type "Line Item", then it's controlled by Opt_Out_of_Adjustment__c and Adjustment_Applied__c. Otherwise, it's only Adjustment_Applied__c. (Assume that Type__c won't change).
                if (oldPriceAdj.Type__c == 'Line Item'){
                    if (oldPriceAdj.Opt_Out_of_Adjustment__c != newPriceAdj.Opt_Out_of_Adjustment__c)
                        newPriceAdj.Opt_Out_of_Adjustment__c = oldPriceAdj.Opt_Out_of_Adjustment__c;
                }
                if (oldPriceAdj.Adjustment_Applied__c != newPriceAdj.Adjustment_Applied__c)
                    newPriceAdj.Adjustment_Applied__c = oldPriceAdj.Adjustment_Applied__c;
                updatePriceAdjs.add(newPriceAdj);
            } else {
                if (oldPriceAdj.Type__c == 'Line Item'){
                    if (oldPriceAdj.Opt_Out_of_Adjustment__c != newPriceAdj.Opt_Out_of_Adjustment__c)
                        resultStr += 'The Opt_Out_of_Adjustment__c of Price Adjustment `' + paID + '` has been altered since SDQ serialization.\n';
                }
                if (oldPriceAdj.Adjustment_Applied__c != newPriceAdj.Adjustment_Applied__c)
                    resultStr += 'The Adjustment_Applied__c of Price Adjustment `' + paID + '` has been altered since SDQ serialization.\n';
            }
        }
        
        //Available_SREC_Contract_Offer__c[] recreateScrecOffers = new Available_SREC_Contract_Offer__c[]{};  //Cloned Available SREC Contract Offers to insert
        //Available_SREC_Contract_Offer__c[] deleteScrecOffers = new Available_SREC_Contract_Offer__c[]{};
        Available_SREC_Contract_Offer__c[] updateScrecOffers = new Available_SREC_Contract_Offer__c[]{};
        for (ID soID : allSrecOffers){
            if (!old_srecOffers.containsKey(soID)){
                if (makeCurrentMode){
                    if (new_srecOffers.containsKey(soID)){  //Essentially guaranteed
                        new_srecOffers.get(soID).Contract_Offer_Applied__c = false;
                        updateScrecOffers.add(new_srecOffers.get(soID));    //Disable the existing Available SREC Contract Offer if it could not be found in the archive
                    }
                }
                continue;
            } else if (!new_srecOffers.containsKey(soID)){
                //if (makeCurrentMode){
                //    if (old_srecOffers.containsKey(soID)){    //Essentially guaranteed
                //        Available_SREC_Contract_Offer__c clonedSO = old_srecOffers.get(soID).clone(false, true, false, false);
                //        recreateScrecOffers.add(clonedSO);  //This archived Available SREC Contract Offer has been deleted, so we mark it for insertion
                //    }
                //}
                //resultStr += 'Available SREC Contract Offer "' + soID + '" has been deleted/made non-applicable since SDQ serialization.\n';
                continue;
            }
            Available_SREC_Contract_Offer__c oldScrecOffer = old_srecOffers.get(soID);
            Available_SREC_Contract_Offer__c newScrecOffer = new_srecOffers.get(soID);
            if (makeCurrentMode){
                if (oldScrecOffer.Contract_Offer_Applied__c != newScrecOffer.Contract_Offer_Applied__c)
                    newScrecOffer.Contract_Offer_Applied__c = oldScrecOffer.Contract_Offer_Applied__c;
                updateScrecOffers.add(newScrecOffer);
            } else {
                if (oldScrecOffer.Contract_Offer_Applied__c != newScrecOffer.Contract_Offer_Applied__c)
                    resultStr += 'The Contract_Offer_Applied__c of Available SREC Contract Offer `' + soID + '` has been altered since SDQ serialization.\n';
            }
        }
        
        String success = 'true';
        if (makeCurrentMode){   //Perform the DML for restoring the System Design Quote and its components to the serialized state
            Savepoint sp = Database.setSavepoint();
            try {
                //Update the serialized System Design on the SDQ to that of the Proposal's
                if (String.isNotBlank(prop.System_Design_Reconstruction_Record__c))
                    new_sdq.System_Design_Reconstruction_Record__c = prop.System_Design_Reconstruction_Record__c;
                if (String.isNotBlank(prop.System_Design_Stored_State__c))
                    new_sdq.System_Design_Stored_State__c = prop.System_Design_Stored_State__c;
                update new_sdq;
                
                //insert recreateIncOffers;
                update updateIncOffers;
                //delete deleteIncOffers;
                
                //insert recreatePriceAdjs;
                update updatePriceAdjs;
                //delete deletePriceAdjs;
                
                //insert recreateScrecOffers;
                update updateScrecOffers;
                //delete deleteScrecOffers;
                
            } catch (Exception e) {
                success = 'false';
                Database.rollback(sp);  //If one DML operation fails, then roll back all of them
                System.debug('Error in reconstructing an SDQ in SalesWorkflowValidationUtility on line ' + e.getLineNumber() + ': ' + e.getMessage());
            }
            
        }
        
        if (resultStr == '')
            resultStr = 'Valid';
        
        return new String[]{resultStr, success};
    }

    public static String validateSystemDesign(System_Design__c sysDesign, Boolean insertSDQ, Date pricingDate)
    {
        String validityResult;
        sysDesign = runSystemDesignValidations(sysDesign, pricingDate);

        if(sysDesign.valid__c)
        {
            validityResult = 'Valid';
            if (insertSDQ)
                systemDesignQuoteWorkflowOnCreate(sysDesign);   //Insert SDQ
        }
        else
        {
            validityResult = sysDesign.Validation_Errors__c;
            // Make SDQs Invalid
            List<System_Design_Quote__c> quotesList = [Select valid__c from System_Design_Quote__c Where System_Design__c = :sysDesign.id];

            if(quotesList != null && quotesList.size() > 0)
            {
                for(System_Design_Quote__c sdq : quotesList)
                {
                    sdq.valid__c = false;
                }
                SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
                update quotesList;
                SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;

                // Make Proposals Invalid
                Proposal__c[] proposalList = [Select Valid__c from Proposal__c Where System_Design_Quote__c in :quotesList];
                for (Proposal__c prp : proposalList){
                    prp.Valid__c = false;
                }
                update proposalList;
            }
            
        }
        SystemDesignTriggerHandler.skipSystemDesignTrigger = true;
        update sysDesign;
        SystemDesignTriggerHandler.skipSystemDesignTrigger = false;     //System Design will only have its Valid__c field updated; no need to fire triggers
        return validityResult;
    }
    
    //-- Serialize Methods --//
    
    public static void serializeStoredStateSDQ(System_Design_Quote__c sdq){
        //REQUIRED: The SDQ must have these fields already queried: System_Design__c, System_Design_Stored_State__c
        
        System_Design__c sd = [SELECT Property__c, Default_CB_Panel__c FROM System_Design__c WHERE ID = :sdq.System_Design__c LIMIT 1];
        Property__c prop = [SELECT RecordTypeID, Sales_Region__c, Latitude__c, Longitude__c, ValidationTimestamp__c, Optimal_Site_Quality_kWh_y_kW__c, DC_to_AC_Derate__c 
                            FROM Property__c WHERE ID = :sd.Property__c LIMIT 1];
        Physical_Surface__c[] psArr = [SELECT Surface_Type__c, Number_of_Stories__c, Structural_Members__c, Surface_Tilt__c, 
                                       Surface_Azimuth__c, Mounting_Plane_is_Not_Parallel__c, Trenching_Dist_to_Intercon_Pt_ft__c, 
                                       Default_Mounting__c, Outbuilding__c FROM Physical_Surface__c WHERE Property__c = :prop.ID];
        Set<ID> installLocationIDs = new Set<ID>();
        for (System_Design_Item__c sdi : [SELECT Install_Location__c FROM System_Design_Item__c WHERE RecordType.DeveloperName = 'Panel' 
                                          AND Quantity__c != 0 AND System_Design_Array__r.System_Design__c = :sd.ID]){
            installLocationIDs.add(sdi.Install_Location__c);
        }
        Install_Location__c[] ilArr = [SELECT Pitch__c, Azimuth__c, TSRF__c, Annual_Solar_Access__c, Verified_Single_SunEye_Data__c FROM Install_Location__c WHERE ID IN :installLocationIDs];
        
        CB_Panel__c cbPanel = [SELECT Utility_Service__c, Main_Breaker_Rating_Amps__c, Bus_Rating_Amps__c, Panel_Location__c, Count_of_Open_Circuits__c 
                               FROM CB_Panel__c WHERE ID = :sd.Default_CB_Panel__c LIMIT 1];
        Utility_Service__c utilService = [SELECT Utility_Company_Master__c, Service_Entry_Type__c FROM Utility_Service__c WHERE ID = :cbPanel.Utility_Service__c LIMIT 1];
        
        //Serialize each object into a JSON string
        String allJSONs = JSON.serialize(prop) + '<;> ';    //Start with Property
        for (Physical_Surface__c ps : psArr){
            allJSONs += JSON.serialize(ps) + '<;> ';
        }
        for (Install_Location__c il : ilArr){
            allJSONs += JSON.serialize(il) + '<;> ';
        }
        allJSONs += JSON.serialize(cbPanel) + '<;> ';
        allJSONs += JSON.serialize(utilService) + '<;> ';
        //allJSONs has the format of: {json for obj1}; {json for obj2}; {json for obj3}; ...
        
        sdq.System_Design_Stored_State__c = allJSONs;
    }
    
    public static void serializeReconstructionSDQ(System_Design_Quote__c sdq){
        //REQUIRED: The SDQ must have these fields already queried: System_Design__c, System_Design_Reconstruction_Record__c
        
        System_Design__c sd = [SELECT Trenching_Required__c, Vent_Stack_Movement_Required__c, Includes_Outbuilding_Installation__c, Inside_Only_Conduit__c, 
                               Number_of_Locations_with_Tree_Removal__c, System_Panel__c, System_Inverter__c 
                               FROM System_Design__c WHERE ID = :sdq.System_Design__c LIMIT 1];
        Map<ID, System_Design_Array__c> sdArrays = new Map<ID, System_Design_Array__c>(
                                            [SELECT System_Design__c, Physical_Surface__c, Survey__c, CB_Panel__c, Mounting_Type__c, CB_Panel__r.Utility_Service__c, 
                                             Original_Surface_Tilt__c, Original_Surface_Azimuth__c, Special_Parts_Required__c, Trench_Type__c, Default_Mounting_Type__c 
                                             FROM System_Design_Array__c WHERE System_Design__c = :sd.ID]);
        System_Design_Item__c[] sdItems = [SELECT Name, Install_Location__c, System_Design_Array__c, System_Design_Product__c, Quantity__c, 
                                           TSRF_Adjustment__c, Legacy_Astrum_Site_Quality__c, RecordTypeID, Total_Trenching_Lengthft__c, Tilt__c 
                                           FROM System_Design_Item__c WHERE System_Design_Array__c IN :sdArrays.keySet()];
        Set<ID> physicalSurfaceIDs = new Set<ID>();
        Set<ID> utilServiceIDs = new Set<ID>();
        for (System_Design_Array__c sda : sdArrays.values()){
            physicalSurfaceIDs.add(sda.Physical_Surface__c);
            utilServiceIDs.add(sda.CB_Panel__r.Utility_Service__c);
        }
        Physical_Surface__c[] psArr = [SELECT Mounting_Plane_Tilt__c, Mounting_Plane_Azimuth__c FROM Physical_Surface__c WHERE ID IN :physicalSurfaceIDs];
        Utility_Service__c[] utilServices = [SELECT Utility_Rate_Code_Before_Solar__c, Utility_Rate_Code_After_Solar__c, Forecasted_Add_Consumption_kWh_Jan__c, Forecasted_Add_Consumption_kWh_Feb__c, 
                                             Forecasted_Add_Consumption_kWh_Mar__c, Forecasted_Add_Consumption_kWh_Apr__c, Forecasted_Add_Consumption_kWh_May__c, Forecasted_Add_Consumption_kWh_Jun__c, 
                                             Forecasted_Add_Consumption_kWh_Jul__c, Forecasted_Add_Consumption_kWh_Aug__c, Forecasted_Add_Consumption_kWh_Sep__c, Forecasted_Add_Consumption_kWh_Oct__c, 
                                             Forecasted_Add_Consumption_kWh_Nov__c, Forecasted_Add_Consumption_kWh_Dec__c, Consumption_Profile__c, 
                                             Monthly_Electric_Consumption_kWh_Jan__c, Monthly_Electric_Consumption_kWh_Feb__c, Monthly_Electric_Consumption_kWh_Mar__c, 
                                             Monthly_Electric_Consumption_kWh_Apr__c, Monthly_Electric_Consumption_kWh_May__c, Monthly_Electric_Consumption_kWh_Jun__c, 
                                             Monthly_Electric_Consumption_kWh_Jul__c, Monthly_Electric_Consumption_kWh_Aug__c, Monthly_Electric_Consumption_kWh_Sep__c, 
                                             Monthly_Electric_Consumption_kWh_Oct__c, Monthly_Electric_Consumption_kWh_Nov__c, Monthly_Electric_Consumption_kWh_Dec__c 
                                             FROM Utility_Service__c WHERE ID IN :utilServiceIDs];
        
        //Serialize each object into a JSON string
        String allJSONs = JSON.serialize(sd) + '<;> ';    //Start with System Design
        for (System_Design_Array__c sda : sdArrays.values()){
            //Delete the CB_Panel__r.Utility_Service__c node from the string
            String tempJSON = JSON.serialize(sda);
            String firstPart = tempJSON.substringBefore('"CB_Panel__r":{');
            String lastPart = tempJSON.substringAfterLast('},');
            allJSONs += firstPart + lastPart + '<;> ';
        }
        for (System_Design_Item__c sdi : sdItems){
            allJSONs += JSON.serialize(sdi) + '<;> ';
        }
        for (Physical_Surface__c ps : psArr){
            allJSONs += JSON.serialize(ps) + '<;> ';
        }
        for (Utility_Service__c us : utilServices){
            allJSONs += JSON.serialize(us) + '<;> ';
        }
        //allJSONs has the format of: {json for obj1}; {json for obj2}; {json for obj3}; ...
        
        sdq.System_Design_Reconstruction_Record__c = allJSONs;
    }
    
    public static void serializeReconstructionProposal(Proposal__c prop){
        //REQUIRED: The Proposal must have these fields already queried: System_Design_Quote__c, SDQ_Reconstruction_Record__c, System_Design_Reconstruction_Record__c, System_Design_Stored_State__c
        
        System_Design_Quote__c sdq = [SELECT Channel_Partner__c, Channel_Partner_Lease_Rate_kWh__c, Primary_Residence__c, Property_in_Revocable_Trust__c, Property_in_Historic_Trust__c, 
                                      Natural_Disaster_Adder_Eligible__c, Moderate_Home_Value_Adder_Eligible__c, Previously_Received_County_Tax_Credit__c, Previously_Received_State_Rebate__c, 
                                      Previously_Received_State_Tax_Credit__c, Previously_Received_Utility_Rebate__c, Moderate_Income_Value_Adder_Eligible__c, Scenario_1_Financing_Type__c, 
                                      Scenario_2_Financing_Type__c, Scenario_3_Financing_Type__c, Scenario_4_Financing_Type__c, Scenario_1_Lease_Fund__c, Scenario_2_Lease_Fund__c, Scenario_3_Lease_Fund__c, 
                                      Scenario_4_Lease_Fund__c, Scenario_1_Term_Loan__c, Scenario_2_Term_Loan__c, Scenario_3_Term_Loan__c, Scenario_4_Term_Loan__c, Scenario_1_SAC_Loan__c, 
                                      Scenario_2_SAC_Loan__c, Scenario_3_SAC_Loan__c, Scenario_4_SAC_Loan__c, Scenario_1_Lease_Escalator__c, Scenario_2_Lease_Escalator__c, Scenario_3_Lease_Escalator__c, 
                                      Scenario_4_Lease_Escalator__c, Scenario_1_Credit_Tier__c, Scenario_2_Credit_Tier__c, Scenario_3_Credit_Tier__c, Scenario_4_Credit_Tier__c, Scenario_1_Financing_Option__c, 
                                      Scenario_2_Financing_Option__c, Scenario_3_Financing_Option__c, Scenario_4_Financing_Option__c, Scenario_1_Lease_Option__c, Scenario_2_Lease_Option__c, 
                                      Scenario_3_Lease_Option__c, Scenario_4_Lease_Option__c, Scenario_1_Down_Payment__c, Scenario_2_Down_Payment__c, Scenario_3_Down_Payment__c, Scenario_4_Down_Payment__c, 
                                      Scenario_1_Apply_Standard_Adjustment__c, Scenario_2_Apply_Standard_Adjustment__c, Scenario_3_Apply_Standard_Adjustment__c, Scenario_4_Apply_Standard_Adjustment__c, 
                                      Scenario_1_Set_Standard_Adjustment_Type__c, Scenario_2_Set_Standard_Adjustment_Type__c, Scenario_3_Set_Standard_Adjustment_Type__c, Scenario_4_Set_Standard_Adjustment_Type__c, 
                                      Scenario_1_Set_Standard_Adjustment_Amoun__c, Scenario_2_Set_Standard_Adjustment_Amoun__c, Scenario_3_Set_Standard_Adjustment_Amoun__c, Scenario_4_Set_Standard_Adjustment_Amoun__c, 
                                      Scenario_1_VP_Sales_Adjustments__c, Scenario_2_VP_Sales_Adjustments__c, Scenario_3_VP_Sales_Adjustments__c, Scenario_4_VP_Sales_Adjustments__c, 
                                      Scenario_1_Refuse_ACH__c, Scenario_2_Refuse_ACH__c, Scenario_3_Refuse_ACH__c, Scenario_4_Refuse_ACH__c, 
                                      Annual_Property_Tax_Bill__c, Income_Corporate_Tax_Rate__c, Utility_Annual_Increase__c, System_Design_Reconstruction_Record__c, System_Design_Stored_State__c 
                                      FROM System_Design_Quote__c WHERE ID = :prop.System_Design_Quote__c LIMIT 1];

        System_Design_Quote__c storeSdq1 = new System_Design_Quote__c(ID = sdq.ID);     //Copy everything except the serialization fields
        storeSdq1.Channel_Partner__c = sdq.Channel_Partner__c;
        storeSdq1.Channel_Partner_Lease_Rate_kWh__c = sdq.Channel_Partner_Lease_Rate_kWh__c;
        storeSdq1.Primary_Residence__c = sdq.Primary_Residence__c;
        storeSdq1.Property_in_Revocable_Trust__c =  sdq.Property_in_Revocable_Trust__c;
        storeSdq1.Property_in_Historic_Trust__c = sdq.Property_in_Historic_Trust__c;
        storeSdq1.Natural_Disaster_Adder_Eligible__c = sdq.Natural_Disaster_Adder_Eligible__c;
        storeSdq1.Moderate_Home_Value_Adder_Eligible__c = sdq.Moderate_Home_Value_Adder_Eligible__c;
        storeSdq1.Previously_Received_County_Tax_Credit__c = sdq.Previously_Received_County_Tax_Credit__c;
        storeSdq1.Previously_Received_State_Rebate__c = sdq.Previously_Received_State_Rebate__c;
        storeSdq1.Previously_Received_State_Tax_Credit__c = sdq.Previously_Received_State_Tax_Credit__c;
        storeSdq1.Previously_Received_Utility_Rebate__c = sdq.Previously_Received_Utility_Rebate__c;
        storeSdq1.Moderate_Income_Value_Adder_Eligible__c = sdq.Moderate_Income_Value_Adder_Eligible__c;
        storeSdq1.Annual_Property_Tax_Bill__c = sdq.Annual_Property_Tax_Bill__c;
        storeSdq1.Income_Corporate_Tax_Rate__c = sdq.Income_Corporate_Tax_Rate__c;
        storeSdq1.Utility_Annual_Increase__c = sdq.Utility_Annual_Increase__c;
        for (Integer i = 1; i <= 4; i++){
            storeSdq1.put('Scenario_' + i + '_Financing_Type__c', sdq.get('Scenario_' + i + '_Financing_Type__c'));
            storeSdq1.put('Scenario_' + i + '_Lease_Fund__c', sdq.get('Scenario_' + i + '_Lease_Fund__c'));
            storeSdq1.put('Scenario_' + i + '_Term_Loan__c', sdq.get('Scenario_' + i + '_Term_Loan__c'));
            storeSdq1.put('Scenario_' + i + '_SAC_Loan__c', sdq.get('Scenario_' + i + '_SAC_Loan__c'));
            storeSdq1.put('Scenario_' + i + '_Lease_Escalator__c', sdq.get('Scenario_' + i + '_Lease_Escalator__c'));
            storeSdq1.put('Scenario_' + i + '_Credit_Tier__c', sdq.get('Scenario_' + i + '_Credit_Tier__c'));
            storeSdq1.put('Scenario_' + i + '_Financing_Option__c', sdq.get('Scenario_' + i + '_Financing_Option__c'));
            storeSdq1.put('Scenario_' + i + '_Lease_Option__c', sdq.get('Scenario_' + i + '_Lease_Option__c'));
            storeSdq1.put('Scenario_' + i + '_Down_Payment__c', sdq.get('Scenario_' + i + '_Down_Payment__c'));
            storeSdq1.put('Scenario_' + i + '_Apply_Standard_Adjustment__c', sdq.get('Scenario_' + i + '_Apply_Standard_Adjustment__c'));
            storeSdq1.put('Scenario_' + i + '_Set_Standard_Adjustment_Type__c', sdq.get('Scenario_' + i + '_Set_Standard_Adjustment_Type__c'));
            storeSdq1.put('Scenario_' + i + '_Set_Standard_Adjustment_Amoun__c', sdq.get('Scenario_' + i + '_Set_Standard_Adjustment_Amoun__c'));
            storeSdq1.put('Scenario_' + i + '_VP_Sales_Adjustments__c', sdq.get('Scenario_' + i + '_VP_Sales_Adjustments__c'));
            storeSdq1.put('Scenario_' + i + '_Refuse_ACH__c', sdq.get('Scenario_' + i + '_Refuse_ACH__c'));
        }

        System_Design_Quote__c storeSdq2 = new System_Design_Quote__c(ID = sdq.ID);     //Store the serialized System Design separately
        storeSdq2.System_Design_Reconstruction_Record__c = sdq.System_Design_Reconstruction_Record__c;
        storeSdq2.System_Design_Stored_State__c = sdq.System_Design_Stored_State__c;
        
        Available_Incentive_Offer__c[] incentiveOfferList = [SELECT Incentive_Applied__c, Opted_Out_Manually__c FROM Available_Incentive_Offer__c WHERE System_Design_Quote__c = :sdq.ID 
                                                             AND Apply_Effective_Price__c = true AND Applicable_Scenario__c != null];
        
        Price_Adjustment__c[] paList = [SELECT Adjustment_Applied__c, Opt_Out_of_Adjustment__c, Type__c FROM Price_Adjustment__c WHERE System_Design_Quote__c = :sdq.ID 
                                        AND Adjustment_Applied__c = true AND Applicable_Scenario__c != null];
        
        Available_SREC_Contract_Offer__c[] srecOfferList = [SELECT Contract_Offer_Applied__c FROM Available_SREC_Contract_Offer__c WHERE System_Design_Quote__c = :sdq.ID 
                                                            AND Applicable_Scenario__c != null AND Contract_Offer_Applied__c = true];
        
        //Encode the serialized fields on SDQ so that the serialization "levels" remain distinct and delimiters between JSON strings still work
        /*String reconstructionField = storeSdq2.System_Design_Reconstruction_Record__c != null ? storeSdq2.System_Design_Reconstruction_Record__c : '';
        Blob reconstructionBlob = Blob.valueOf(reconstructionField);
        String reconstruction64 = EncodingUtil.base64Encode(reconstructionBlob);
        storeSdq2.System_Design_Reconstruction_Record__c = reconstruction64;  //Base 64 encode the serialized objects
        
        String storedStateField = storeSdq2.System_Design_Stored_State__c != null ? storeSdq2.System_Design_Stored_State__c : '';
        Blob storedStateBlob = Blob.valueOf(storedStateField);
        String storedState64 = EncodingUtil.base64Encode(storedStateBlob);
        storeSdq2.System_Design_Stored_State__c = storedState64;  //Base 64 encode the serialized objects
        */
        
        //Serialize each object into a JSON string
        String sdqJSONs = JSON.serialize(storeSdq1) + '<;> ';    //Start with System Design Quote
        for (Available_Incentive_Offer__c aio : incentiveOfferList){
            sdqJSONs += JSON.serialize(aio) + '<;> ';
        }
        for (Price_Adjustment__c pa : paList){
            sdqJSONs += JSON.serialize(pa) + '<;> ';
        }
        for (Available_SREC_Contract_Offer__c srec : srecOfferList){
            sdqJSONs += JSON.serialize(srec) + '<;> ';
        }
        
        prop.SDQ_Reconstruction_Record__c = sdqJSONs;
        prop.System_Design_Reconstruction_Record__c = storeSdq2.System_Design_Reconstruction_Record__c;
        prop.System_Design_Stored_State__c = storeSdq2.System_Design_Stored_State__c;
    }

    private static Decimal nullDecimal(Object obj){
        Decimal val = obj != null ? (Decimal)obj : 0;
        return val;
    }

    public static Decimal getPercent(Object obj, Decimal defaultVal){
        Decimal val = (Decimal)obj;
        if (val != null){
            val = val/100;
        } else {
            val = defaultVal;
        }
        return val;
    }
}