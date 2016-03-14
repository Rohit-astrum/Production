/* FILE: NoteCopyToAstrumDoc.trigger
 * AUTHOR: Tino Mattheou
 * DATE: January 17, 2013
 * PURPOSE: Allow interconnect to report on Util Interconnect Part 2 Notes
 * MODIFICATION HISTORY:
 *
 */

trigger NoteCopyToAstrumDoc on Note (after insert, after update) {

    List<Astrum_Doc__c> docsToUpdate = new List<Astrum_Doc__c>();
    Schema.SObjectType docType = Astrum_Doc__c.sObjectType;
    
    for (Note n : Trigger.new) {
        if (n.ParentId.getSObjectType() == docType) {
            docsToUpdate.add(new Astrum_Doc__c(
                Id = n.ParentId,
                Note_Text__c = n.Body
            ));
        }
    }
    
    if (!docsToUpdate.isEmpty()) {
        update docsToUpdate;
    }
    
}