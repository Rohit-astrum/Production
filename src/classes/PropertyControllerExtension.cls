public class PropertyControllerExtension {
    private final Property__c prop;
    private final Id propOwner;
    
    public String oppId{
        get;
        // *** setter is NOT being called ***
        set {
            oppId= value;
            System.debug('oppId: '+value);
        }
    }


    public propertyControllerExtension (ApexPages.StandardController stdController) {
        this.prop= (Property__c)stdController.getRecord();
        this.propOwner = [Select id, Property_Owner__c from Property__c p where p.id = :prop.id limit 1].Property_Owner__c;
        System.debug('propOwner --> ' + propOwner );
    }
    
    public PageReference doAssignToOpp(){
        System.debug('oppId --> ' + oppId );
        Opportunity opp = [select id, Name, Property__c, closedate  from Opportunity o where o.Id = :oppId limit 1];
        System.debug('opp --> ' + opp );
        opp.Property__c = prop.Id;
        update opp;
        return null;
    }
    
    public List<Opportunity> getAccountOpportunities(){
        List<Opportunity> opps = [select id, Name, Account.Name from Opportunity o where o.AccountId = :propOwner];
        System.debug('opps --> ' + opps);
        return opps;
    }
}