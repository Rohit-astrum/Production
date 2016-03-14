/* FILE: AstrumOfficeCopy.trigger
 * AUTHOR: Rohit Jain
 * DATE: Dec 15, 2012
 * PURPOSE: Copy value to Lookup Field
 * MODIFICATION HISTORY
 *
 */

trigger AstrumOfficeCopy on Property__c (before insert, before update, after insert) {
  Office_Location__c locationId;    

  for (Property__c p : Trigger.new) {
        if ((Trigger.isInsert && Trigger.isBefore && p.Astrum_office__c != null) || (Trigger.isUpdate && p.Astrum_office__c != Trigger.oldMap.get(p.Id).Astrum_office__c ))
        {
           locationId = [SELECT Id from Office_Location__c where Name = :p.Astrum_office__c limit 1];
           p.Astrum_Office_New__c = locationId.Id ;
        }    
  } 
}