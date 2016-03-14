/* FILE: SalesInvoicePrintExtension.cls
 * AUTHOR: Rohit Jain
 * DATE: Aug 6, 2013
 * PURPOSE: Sunnova Customization on Sales Invoice Print.
 * MODIFICATION HISTORY 
 */
public class SalesInvoicePrintExtension{

    private ApexPages.StandardController controller;
    private c2g__codaInvoice__c inv; 
    public SalesInvoicePrintExtension (ApexPages.StandardController controller) {
        this.controller = controller;
        inv = (c2g__codaInvoice__c)controller.getRecord();
        
        inv = [Select Sales_Order__r.System_Design_Quote__r.System_Design__c from c2g__codaInvoice__c Where id = :inv.Id  ];
        
    }
    
    public String inverterMakeup{
        get { 
            Id lastSystemDesignId = null;
            String systemMakeup = '';
            Boolean firstOne = false;
            if (inverterMakeup == null && inv.Sales_Order__r.System_Design_Quote__r.System_Design__c != null) {
                //User u = [SELECT Id, Alias FROM User WHERE Id = :UserInfo.getUserId()];
                AggregateResult[] results = 
                    [SELECT System_Design_Array__r.System_Design__c sdid, System_Design_Product__r.Micro_Inverter__c inv, SUM(Quantity__c) qty
                       FROM System_Design_Item__c
                      WHERE System_Design_Array__r.System_Design__c = :inv.Sales_Order__r.System_Design_Quote__r.System_Design__c
                        AND System_Design_Product__r.Micro_Inverter__c <> NULL
                   GROUP BY System_Design_Array__r.System_Design__c, System_Design_Product__r.Micro_Inverter__c
                    HAVING SUM(Quantity__c) > 0];
                
                
                for (AggregateResult ar : results) {
                    Id systemDesignId = (Id)ar.get('sdid');
                    if (systemDesignId != lastSystemDesignId) {
                        if (systemMakeup != '') {
                            systemMakeup = '';
                        }
                        lastSystemDesignId = systemDesignId;
                        firstOne = false;
                    }
                    
                    String des = (String)ar.get('inv');
                    if(des == 'M215')
                    {
                        des = 'Enphase M215 Mircoinverters';
                    }
                    else
                    {
                        des = des + ' Mircoinverters';
                    }
                    Decimal qty = (Decimal)ar.get('qty');

                    if (firstOne) {
                        systemMakeup += ', ';
                    }
                    firstOne = true;
                    systemMakeup += '(' + qty.intValue() + ') ' + des;
                }
            }
            return systemMakeup;
        }
        private set; 
    }
    
    
    
    
    

}