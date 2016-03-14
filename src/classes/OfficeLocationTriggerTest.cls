/* FILE: OfficeLocationTriggerTest.cls
 * AUTHOR: Pavitra Burla
 * DATE: July 24, 2015
 * PURPOSE: Test for OfficeLocationTrigger
 */
@isTest(SeeAlldata=true)
public class OfficeLocationTriggerTest {

    static testmethod void mainSiteTest(){
    	
    	Id  divId;
        Office_Location__c existingOffLoc;
        try{
            existingOffLoc = [SELECT Rootstock_Division__c 
                                FROM Office_Location__c 
                                WHERE Rootstock_Division__c!= null 
                                AND Active__c = true 
                                AND Main_Site__c = true LIMIT 1];

        }catch(QueryException qe){}
        
        if(existingOffLoc == null){
            try{
                existingOffLoc = [SELECT Rootstock_Division__c 
                                FROM Office_Location__c 
                                WHERE Rootstock_Division__c!= null  LIMIT 1];

            }catch(QueryException qe){}
        }
        
        if(existingOffLoc == null){
            divId = [SELECT Id FROM rstk__sydiv__c limit 1].Id;
            existingOffLoc = new Office_Location__c(Name = 'Test Existing location, MD',Rootstock_Division__c = divId,Main_Site__c= true,Street__c = '345 test st', City__c = 'Annapolis Junction', State__c = 'MD', Zip_Code__c = '20701',State_Coverage__c = '', Location__Latitude__s = 39.125951, Location__Longitude__s = -76.794940, Active__c = true);
            insert existingOffLoc;
        }

        divId = existingOffLoc.Rootstock_Division__c;
        existingOffLoc.Active__c = true;
        existingOffLoc.Main_Site__c= true;
        update existingOffLoc;
        
        Office_Location__c testOffice1 = new Office_Location__c(Name = 'Test location1, MD',Rootstock_Division__c = divId,Street__c = '123 test st', City__c = 'Annapolis Junction', State__c = 'MD', Zip_Code__c = '20701',State_Coverage__c = '', Location__Latitude__s = 39.125951, Location__Longitude__s = -76.794940, Active__c = true);
        insert testOffice1;
        testOffice1 = [SELECT Id FROM Office_Location__c WHERE Id=:testOffice1.Id];
        System.assertNotEquals(null,testOffice1.Id);
        
        testOffice1.Main_Site__c=true;
        try{
        	//This will cause a dml exception since we can't have 2 office locations as main site with same div
        	update testOffice1;
        }catch(DmlException de){
            System.debug(loggingLevel.ERROR,'***In exception' + de.getMessage());

        }

        testOffice1 = [SELECT Main_Site__c FROM Office_Location__c WHERE Id=:testOffice1.Id];
        System.assertEquals(false,testOffice1.Main_Site__c);        
        
    }   

}