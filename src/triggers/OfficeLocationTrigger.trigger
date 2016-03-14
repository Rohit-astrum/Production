/* FILE: OfficeLocationTrigger.trigger
 * AUTHOR: Pavitra Burla
 * DATE: July 20, 2015
 * PURPOSE: Trigger on OfficeLocation
 * MODIFICATION HISTORY
 *
 */
trigger OfficeLocationTrigger on Office_Location__c (after insert, after update, before insert, before update) {
	new OfficeLocationTriggerHandler().run();
}