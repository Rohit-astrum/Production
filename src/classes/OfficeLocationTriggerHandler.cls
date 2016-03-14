/* FILE: OfficeLocationTriggerHandler.cls
 * AUTHOR: Pavitra Burla
 * DATE: July 20, 2015
 * PURPOSE: Handler for OfficeLocationTrigger
 * MODIFICATION HISTORY
 *
 */
public class OfficeLocationTriggerHandler extends TriggerHandler{
    public OfficeLocationTriggerHandler() {
        //this.setMaxLoopCount(2);
    }
    
    /* context overrides */
    
    protected override void beforeInsert(){
        if(!validateMainSite()){
            throw new TriggerHandlerException('Only one Office Location for a specific Division can have the “Main Site” box checked ');            
        }
    }
    
    protected override void beforeUpdate(){
        if(!validateMainSite()){
            throw new TriggerHandlerException('Only one Office Location for a specific Division can have the “Main Site” box checked ');            
        }        
    }
    
    /* private methods */
    
    private Boolean validateMainSite(){
        Boolean result = false;
        Set<Id> divSet = new Set<Id>();
        Set<Id> offLocSet = new Set<Id>();
        List<Office_Location__c> mainOffLoc = new List<Office_Location__c>();
        for(Office_Location__c offLoc:(List<Office_Location__c>) Trigger.new){
            if(offLoc.Main_Site__c && offLoc.Rootstock_Division__c != null && offLoc.Active__c == true){
                if(divSet.contains(offLoc.Rootstock_Division__c)){
                    return false;
                }
                else{
                    divSet.add(offLoc.Rootstock_Division__c);
                    offLocSet.add(offLoc.Id);
                }
            }
        }

        if(!divSet.isEmpty()){
            mainOffLoc = [SELECT Name 
                            FROM Office_Location__c 
                            WHERE Main_Site__c = true 
                            AND Active__c = true 
                            AND Rootstock_Division__c IN:divSet 
                            AND Id NOT IN:offLocSet];
            if(!mainOffLoc.isEmpty()){
                return false;
            }             
        }
        result = true;
        return result;
    }

}