/*  FILE: SoldScenarioItemizedPricingController
    AUTHOR: Dan Kelner
    DATE: 08/26/15
    PURPOSE: Controller for SoldScenarioItemizedPricing
    MODIFICATION HISTORY
*/
public class SoldScenarioItemizedPricingController {

    public SCRB_SalesOrder__c salesOrder {get; set;}

    public PricingLineItem[] panel {get; set;}      //Single element array
    public PricingLineItem[] inverter {get; set;}   //Single element array
    public PricingLineItem[] mountings {get; set;}
    public PricingLineItem[] specialParts {get; set;}
    public PricingLineItem[] trenchings {get; set;}
    public PricingLineItem[] entitlements {get; set;}
    public PricingLineItem[] promotions {get; set;}
    public PricingLineItem[] vpOverrides {get; set;}
    public PricingLineItem[] incentives {get; set;}
    public PricingLineItem[] srec {get; set;}   //Single element array

    public SoldScenarioItemizedPricingController(ApexPages.StandardController stdController){
        try {
            panel = new PricingLineItem[]{};
            inverter = new PricingLineItem[]{};
            mountings = new PricingLineItem[]{};
            specialParts = new PricingLineItem[]{};
            trenchings = new PricingLineItem[]{};
            entitlements = new PricingLineItem[]{};
            promotions = new PricingLineItem[]{};
            vpOverrides = new PricingLineItem[]{};
            incentives = new PricingLineItem[]{};
            srec = new PricingLineItem[]{};

            String[] fieldsToQuery = new String[]{'System_Design_Quote__r.System_Design__r.System_Panel__r.Description__c', 'System_Design_Quote__r.System_Design__r.Panel_Count__c',
                                                'System_Design_Quote__r.Scenario_1_Panel_Design_Price__c', 'System_Design_Quote__r.Scenario_2_Panel_Design_Price__c',
                                                'System_Design_Quote__r.Scenario_3_Panel_Design_Price__c', 'System_Design_Quote__r.Scenario_4_Panel_Design_Price__c',
                                                'System_Design_Quote__r.System_Design__r.System_Inverter__c', 'System_Design_Quote__r.Scenario_1_Financing_Type__c',
                                                'System_Design_Quote__r.Scenario_2_Financing_Type__c', 'System_Design_Quote__r.Scenario_3_Financing_Type__c', 
                                                'System_Design_Quote__r.Scenario_4_Financing_Type__c', 'System_Design_Quote__r.Scenario_1_Lease_Fund__c', 
                                                'System_Design_Quote__r.Scenario_2_Lease_Fund__c', 'System_Design_Quote__r.Scenario_3_Lease_Fund__c','System_Design_Quote__r.Scenario_4_Lease_Fund__c',
                                                'System_Design_Quote__r.Community_Program_Offer__c', 'System_Design_Quote__r.Pricing_Date__c', 'System_Design_Quote__r.Closed_Scenario__c',
                                                'System_Design_Quote__r.System_Size_kW__c', 'System_Design_Quote__r.Scenario_1_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__r.Name', 
                                                'System_Design_Quote__r.Scenario_2_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__r.Name', 
                                                'System_Design_Quote__r.Scenario_3_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__r.Name', 
                                                'System_Design_Quote__r.Scenario_4_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__r.Name',
                                                'System_Design_Quote__r.Scenario_1_Available_SREC_Contract_Offer__r.Upfront_Effective_Dollar_Amount__c', 
                                                'System_Design_Quote__r.Scenario_2_Available_SREC_Contract_Offer__r.Upfront_Effective_Dollar_Amount__c', 
                                                'System_Design_Quote__r.Scenario_3_Available_SREC_Contract_Offer__r.Upfront_Effective_Dollar_Amount__c', 
                                                'System_Design_Quote__r.Scenario_4_Available_SREC_Contract_Offer__r.Upfront_Effective_Dollar_Amount__c',
                                                'System_Design_Quote__r.Scenario_1_Trenching_Table_Value_Total__c', 'System_Design_Quote__r.Scenario_2_Trenching_Table_Value_Total__c', 
                                                'System_Design_Quote__r.Scenario_3_Trenching_Table_Value_Total__c', 'System_Design_Quote__r.Scenario_4_Trenching_Table_Value_Total__c', 
                                                'System_Design_Quote__r.System_Design__r.Trench_Length__c'};
            if (!Test.isRunningTest())
                stdController.addFields(fieldsToQuery);
            salesOrder = (SCRB_SalesOrder__c)stdController.getRecord();
            if (Test.isRunningTest()){
                String fields = String.join(fieldsToQuery, ',');
                salesOrder = Database.query('SELECT ' + fields + ' FROM SCRB_SalesOrder__c WHERE ID = \'' + salesOrder.ID + '\' LIMIT 1');
            }

            String closedScenario = salesOrder.System_Design_Quote__r.Closed_Scenario__c;
            if (closedScenario == null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No closed scenario was found.'));
                return;
            }
            String finType = (String)salesOrder.getSObject('System_Design_Quote__r').get('Scenario_' + closedScenario + '_Financing_Type__c');
            String leaseFund = (String)salesOrder.getSObject('System_Design_Quote__r').get('Scenario_' + closedScenario + '_Lease_Fund__c');    //ID as String
            Decimal panelDesignPrice = (Decimal)salesOrder.getSObject('System_Design_Quote__r').get('Scenario_' + closedScenario + '_Panel_Design_Price__c');
            Date pricingDate = Date.newInstance(salesOrder.System_Design_Quote__r.Pricing_Date__c.year(), salesOrder.System_Design_Quote__r.Pricing_Date__c.month(), salesOrder.System_Design_Quote__r.Pricing_Date__c.day());

            panel.add(new PricingLineItem('Panels', salesOrder.System_Design_Quote__r.System_Design__r.System_Panel__r.Description__c, salesOrder.System_Design_Quote__r.System_Design__r.Panel_Count__c, panelDesignPrice));
            
            Decimal trenchingTableValue = salesOrder.getSObject('System_Design_Quote__r').get('Scenario_' + closedScenario + '_Trenching_Table_Value_Total__c') != null ? (Decimal)salesOrder.getSObject('System_Design_Quote__r').get('Scenario_' + closedScenario + '_Trenching_Table_Value_Total__c') : 0;
            if (trenchingTableValue > 0)
                trenchings.add(new PricingLineItem('Trenching', null, salesOrder.System_Design_Quote__r.System_Design__r.Trench_Length__c + ' ft', trenchingTableValue, ''));

            for (System_Design_Product__c sdp : [SELECT Description__c, Wire_Type__c, RecordType.DeveloperName, 
                                                    (SELECT Adder_ea__c, Adder_W__c, Adder_Per_Panel__c, Size_Base__c FROM SDP_Price_Entries__r 
                                                        WHERE Financing_Type__c = :finType AND Lease_Fund__c = :leaseFund
                                                        AND Community_Program_Offer__c = :salesOrder.System_Design_Quote__r.Community_Program_Offer__c
                                                        AND Start_Date__c <= :pricingDate AND (End_Date__c = null OR End_Date__c >= :pricingDate) LIMIT 1), 
                                                    (SELECT Quantity__c, System_Design_Array__r.Array_Size_kW__c, System_Design_Array__r.Panel_Count__c, System_Design_Array__r.Total_Trenching_Length_ft__c 
                                                        FROM System_Design_Items__r WHERE System_Design_Array__r.System_Design__c = :salesOrder.System_Design_Quote__r.System_Design__c) 
                                                FROM System_Design_Product__c WHERE RecordType.DeveloperName IN ('Inverter', 'Mounting', 'Special_Part', 'Trenching')
                                                AND ID IN (SELECT System_Design_Product__c FROM System_Design_Item__c WHERE System_Design_Array__r.System_Design__c = :salesOrder.System_Design_Quote__r.System_Design__c)]){
                System_Design_Item__c[] sdis = sdp.System_Design_Items__r;
                SDP_Price_Entry__c[] pes = sdp.SDP_Price_Entries__r;
                if (pes.isEmpty() || sdis.isEmpty())
                    continue;
                System_Design_Item__c sdi = sdis[0];
                if (pes[0].Adder_ea__c == null) pes[0].Adder_ea__c = 0;
                if (pes[0].Adder_W__c == null) pes[0].Adder_W__c = 0;
                if (pes[0].Adder_per_Panel__c == null) pes[0].Adder_Per_Panel__c = 0;
                Decimal perWatt, perEach, perPanel;
                Decimal itemPrice = 0;

                if (sdp.ID == salesOrder.System_Design_Quote__r.System_Design__r.System_Inverter__c){
                    perWatt = pes[0].Adder_W__c * sdi.System_Design_Array__r.Array_Size_kW__c * 1000;
                    perEach = pes[0].Adder_ea__c * sdi.Quantity__c * (pes[0].Size_Base__c > 0 ? salesOrder.System_Design_Quote__r.System_Size_kW__c / pes[0].Size_Base__c : 1);
                    perPanel = pes[0].Adder_Per_Panel__c * sdi.System_Design_Array__r.Panel_Count__c;
                    itemPrice = perWatt + perEach + perPanel;
                    inverter.add(new PricingLineItem('Inverters', sdp.Description__c, null, itemPrice));

                } else if (sdp.RecordType.DeveloperName == 'Mounting'){
                    perWatt = pes[0].Adder_W__c * sdi.System_Design_Array__r.Array_Size_kW__c * 1000;
                    perEach = pes[0].Adder_ea__c * sdi.Quantity__c * (pes[0].Size_Base__c > 0 ? salesOrder.System_Design_Quote__r.System_Size_kW__c / pes[0].Size_Base__c : 1);
                    perPanel = pes[0].Adder_Per_Panel__c * sdi.System_Design_Array__r.Panel_Count__c;
                    itemPrice = perWatt + perEach + perPanel;
                    mountings.add(new PricingLineItem('Mounting', sdp.Description__c, sdi.Quantity__c, itemPrice));

                } else if (sdp.RecordType.DeveloperName == 'Special_Part'){
                    perWatt = pes[0].Adder_W__c * salesOrder.System_Design_Quote__r.System_Size_kW__c;
                    perEach = pes[0].Adder_ea__c * sdi.Quantity__c * (pes[0].Size_Base__c > 0 ? salesOrder.System_Design_Quote__r.System_Size_kW__c / pes[0].Size_Base__c : 1);
                    perPanel = pes[0].Adder_Per_Panel__c * salesOrder.System_Design_Quote__r.System_Design__r.Panel_Count__c;
                    itemPrice = perWatt + perEach + perPanel;
                    specialParts.add(new PricingLineItem('Special Parts', sdp.Description__c, sdi.Quantity__c, itemPrice));

                } /*else if (sdp.RecordType.DeveloperName == 'Trenching'){
                    //SOQL within for loop is acceptable in this circumstance, for reasons of speed and simplicity
                    Trenching_Table__c[] trenchingTable = [SELECT Adder__c, Adder_W__c, Adder_Ft__c FROM Trenching_Table__c 
                                                            WHERE Community_Program_Offer__c = :salesOrder.System_Design_Quote__r.Community_Program_Offer__c
                                                              AND Wire_Type__c = :sdi.System_Design_Product__r.Wire_Type__c                                                          
                                                              AND Minimum_Trench_Length__c < :(sdi.System_Design_Array__r.Total_Trenching_Length_ft__c / sdi.Quantity__c) 
                                                              AND Maximum_Trench_Length__c >= :(sdi.System_Design_Array__r.Total_Trenching_Length_ft__c / sdi.Quantity__c)
                                                              AND Minimum_Size__c < :sdi.System_Design_Array__r.Array_Size_kW__c                                                              
                                                              AND Maximum_Size__c >= :sdi.System_Design_Array__r.Array_Size_kW__c
                                                              AND Start_Date__c <= :pricingDate 
                                                              AND (End_Date__c = null OR End_Date__c >= :pricingDate) LIMIT 1];
                    if (!trenchingTable.isEmpty()){
                        if (salesOrder.System_Design_Quote__r.Community_Program_Offer__c == null){
                            itemPrice = trenchingTable[0].Adder__c;
                        } else {
                            if (trenchingTable[0].Adder_W__c != null)
                                itemPrice = trenchingTable[0].Adder_W__c * sdi.System_Design_Array__r.Array_Size_kW__c;
                            else if (trenchingTable[0].Adder__c != null)
                                itemPrice = trenchingTable[0].Adder__c;
                            else if (trenchingTable[0].Adder_Ft__c != null)
                                itemPrice = trenchingTable[0].Adder_Ft__c * sdi.System_Design_Array__r.Total_Trenching_Length_ft__c;
                        }
                        trenchings.add(new PricingLineItem('Trenching', sdp.Description__c, sdi.Quantity__c, itemPrice));
                    }
                }*/
            }

            for (Price_Adjustment__c pa : [SELECT Effective_Dollar_Amount__c, Type__c, Entitlement_Offer__r.Name, Promotion__r.Name FROM Price_Adjustment__c
                                            WHERE Applicable_Scenario__c = :closedScenario AND Adjustment_Applied__c = true
                                            AND Type__c IN ('Line Item', 'Program', 'Standard', 'VP Override') AND System_Design_Quote__c = :salesorder.System_Design_Quote__c]){

                if (pa.Type__c == 'Line Item' && pa.Entitlement_Offer__c != null){
                    entitlements.add(new PricingLineItem('Entitlement', pa.Entitlement_Offer__r.Name, null, pa.Effective_Dollar_Amount__c));
                } else if ((pa.Type__c == 'Program' || pa.Type__c == 'Standard') && pa.Promotion__c != null){
                    promotions.add(new PricingLineItem('Promotion', pa.Promotion__r.Name, null, pa.Effective_Dollar_Amount__c));
                } else if (pa.Type__c == 'VP Override'){
                    vpOverrides.add(new PricingLineItem('VP Override', null, null, pa.Effective_Dollar_Amount__c));
                }
            }

            for (Available_Incentive_Offer__c aio : [SELECT Incentive_Offer__r.Name, Effective_Dollar_Amount__c FROM Available_Incentive_Offer__c
                                                        WHERE Applicable_Scenario__c = :closedScenario AND Apply_Effective_Price__c = true 
                                                        AND System_Design_Quote__c = :salesorder.System_Design_Quote__c]){

                incentives.add(new PricingLineItem('Incentive', aio.Incentive_Offer__r.Name, null, aio.Effective_Dollar_Amount__c));
            }

            String srecName = (String)salesOrder.getSObject('System_Design_Quote__r').getSObject('Scenario_' + closedScenario + '_Available_SREC_Contract_Offer__r').getSObject('SREC_Contract_Offer__r').get('Name');
            Decimal dollarAmount = (Decimal)salesOrder.getSObject('System_Design_Quote__r').getSObject('Scenario_' + closedScenario + '_Available_SREC_Contract_Offer__r').get('Upfront_Effective_Dollar_Amount__c');
            srec.add(new PricingLineItem('SREC', srecName, null, dollarAmount));

        } catch (Exception e){
            System.debug('Error in SoldScenarioItemizedPricingController: ' + e.getStackTraceString());
        }
    }

    class PricingLineItem {

        public String component {get; set;}
        public String description {get; set;}
        public String quantity {get; set;}
        public String price {get; set;}     //String format for currency

        public PricingLineItem(String c, String d, Decimal q, Decimal p){
            component = c != null ? c : '';
            description = d != null ? d : '';
            quantity = q != null ? String.valueOf(q) : '';
            price = displayCash(p);
        }

        public PricingLineItem(String c, String d, String q, Decimal p, String nothing){    //To avoid ambigious method signature
            component = c != null ? c : '';
            description = d != null ? d : '';
            quantity = q;
            price = displayCash(p);
        }

        private String displayCash(Decimal d){
            if (d == null)
                d = 0;
                
            d = d.setScale(2);
            
            String str = (d + 0.001).format();
            str = '$' + str.substring(0,str.length()-1);
            
            if (d < 0){
                d = Math.abs(d);     //Strip the minus sign
                str = (d + 0.001).format();
                str = '($' + str.substring(0,str.length()-1) + ')';
            }
            return str;
        }
    }
}