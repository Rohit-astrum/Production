/* FILE: CPREReCallExtension.cls
 * AUTHOR: Rohit Jain
 * DATE: July 24, 2013
 * PURPOSE: Clean Power Estimator Web Service Callout for Site Quality. Called from Button on Install Location.
 * MODIFICATION HISTORY 
 */
public class CPREReCallExtension {

    private ApexPages.StandardController controller;
    
    public CPREReCallExtension (ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference reCallCPRE() {

        System_Design_Item__c item = (System_Design_Item__c) controller.getRecord();
        item = [Select Sunnova_Site_Quality__c,Panel_Annual_Solar_Access__c,System_Design_Array__r.System_Design__r.Property__r.Property_ZIP__c, System_Design_Array__r.System_Design__r.Property__r.Property_State__c,CPRE_Azimuth__c,Panel_Pitch__c,Sunnova_Upgrade_factor__c from System_Design_Item__c Where id = :item.Id];       
        
        if (item.System_Design_Array__r.System_Design__r.Property__r.Property_ZIP__c != null &&  item.System_Design_Array__r.System_Design__r.Property__r.Property_State__c != null && item.CPRE_Azimuth__c != null && item.Panel_Pitch__c != null && Item.Panel_Annual_Solar_Access__c != null ) {            
            
            Double siteQuality = CleanPowerEstimator_ServiceClient.getSiteQuality(item.System_Design_Array__r.System_Design__r.Property__r.Property_ZIP__c.subString(0,5), item.System_Design_Array__r.System_Design__r.Property__r.Property_State__c,String.valueOf(item.CPRE_Azimuth__c),String.valueOf(item.Panel_Pitch__c),String.valueOf(item.Panel_Annual_Solar_Access__c));                       
            
            if (siteQuality != null) {
                CPRE_Upgrade_Factor__c cpre = CPRE_Upgrade_Factor__c.getValues('CPRE');
                if(item.Sunnova_Upgrade_factor__c != null && item.Sunnova_Upgrade_factor__c != 0 && item.Sunnova_Upgrade_factor__c == cpre.Upgrade_factor__c)
                {
                    item.Sunnova_Site_Quality__c = siteQuality * item.Sunnova_Upgrade_factor__c  ;    
                }
                else
                {
                    
                    if(cpre.Upgrade_factor__c != null)
                    {
                        item.Sunnova_Site_Quality__c = siteQuality * cpre.Upgrade_factor__c ;    
                        item.Sunnova_Upgrade_factor__c = cpre.Upgrade_factor__c;
                    }
                    else
                    {
                        item.Sunnova_Site_Quality__c = siteQuality ;  
                    }
                         
                }    
                update item;    
            }
            
        }
        else
        { 
            throw new customException ('One or more required fields (Property Zip,Property State,Azimuth,Tilt,Annual Solar Access) are missing to calculate Sunnova Site Quality.');
        }
        
        return controller.cancel();
    } 
    
    public class customException extends Exception {} 

}