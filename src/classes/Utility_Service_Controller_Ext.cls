/*
    12/09/14  DK  Commented out the Utility Rate Code selection
*/
public with sharing class Utility_Service_Controller_Ext {
    private final Utility_Service__c util_svc;
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public Utility_Service_Controller_Ext(ApexPages.StandardController stdController) {
        this.util_svc = (Utility_Service__c)stdController.getRecord();
    }
    
    //public String getRateCode() {
    //    return util_svc.Utility_Company__r.name;
    //}

    //public void setRateCode(String rateCodeId) {
    //    String rcid = rateCodeId;
    //    System.debug('Inside setRateCode()');
    //
    //    Utility_Company__c rc = [select id, name 
    //            from Utility_Company__c c 
    //            where Utility_Company__c.Id = :rcid
    //            limit 1]; 
    //    System.debug('Selected Rate Code ID --> ' + rc.Id);
    //    util_svc.Utility_Company__c = rc.id;
    //} 
    
    //public List<SelectOption> getUtilityRateCodes() {
    //    String PropId = System.currentPageReference().getParameters().get('CF00NC0000004Weeu_lkid');
    //    List<SelectOption> options = new List<SelectOption>();
    //    if( PropId <> null ){
    //        System.debug('Property Id --> ' + PropId );
    //        Property__c prop = [select id, Property_State__c from Property__c where id = :PropId limit 1];
    //        System.debug('PropertyState --> ' + prop.Property_State__c );
    //        List<Utility_Company__c> rateCodes = [select id, name, states_serviced__c 
    //                                              from Utility_Company__c
    //                                              where state_serviced__c = :prop.Property_State__c];
    //        for (Utility_Company__c rc : rateCodes){
    //            options.add(new SelectOption(rc.id, rc.name));
    //            System.debug('Adding ' + rc.id + ' --> ' + rc.name );
    //        }
    //    }
    //    return options;
    //}
    
    public PageReference save() {
        //System.debug('util_svc.Utility_Company__r.Id --> ' + util_svc.Utility_Company__r.Id);
        //System.debug('util_svc.Utility_Company__r.name --> ' + util_svc.Utility_Company__r.name);
        
        upsert util_svc;
        return  (new ApexPages.StandardController(util_svc)).view();
    }
    
}