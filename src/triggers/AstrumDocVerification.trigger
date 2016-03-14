/* FILE: AstrumDocVerification.trigger
 * AUTHOR: Tino Mattheou
 * DATE: December 7, 2012
 * PURPOSE: cross-object updates upon document approval
 * MODIFICATION HISTORY
 * 12/10/2012 TCM - prevent document from being modified if verified
 * 08/21/2012 RJ - SYS-42
 */

trigger AstrumDocVerification on Astrum_Doc__c (before update, after update, after Insert) {

    if(TriggerUtility.skipAstrumDocVerificationTrigger)
    {
        return;
    }
    Set<Id> exceptionProfiles = new Set<Id>();
    for( Profile pf : [Select id from Profile where Name in ('VP of Operations','Controller', 'Accountant')] )
    {
        exceptionProfiles.add(pf.id);    
    }
    //exceptionProfiles.add('00eC0000001G9h7');  //controller
    //exceptionProfiles.add('00eC0000001G5AJ');  // VP Of Operations
    if (Trigger.isBefore) {
        //cannot change type of document after it has been verified
        for (Astrum_Doc__c doc : Trigger.new) {
            if (doc.PM_Project__c != null 
            && Trigger.oldMap.get(doc.Id).Verified__c == true
            && doc.Verified__c == true
            && (doc.Bin__c != Trigger.oldMap.get(doc.Id).Bin__c
            || doc.Category__c != Trigger.oldMap.get(doc.Id).Category__c
            || doc.Document_Key_Date__c != Trigger.oldMap.get(doc.Id).Document_Key_Date__c)) {
                doc.addError('You cannot modify a verified document.');
            }

            System.debug('*doc.Document_Key_Date__c '+doc.Document_Key_Date__c);
            System.debug('*Trigger.oldMap.get(doc.Id).Document_Key_Date__c '+Trigger.oldMap.get(doc.Id).Document_Key_Date__c);
            System.debug(Trigger.isUpdate);
            if (doc.PM_Project__c != null                
                && Trigger.oldMap.get(doc.Id).Category__c  == 'Proof Of Inspection'
                && doc.createdDate.date() != System.today()  
                && !(exceptionProfiles.contains(UserInfo.getProfileId()) && !doc.Verified__c)              
                && ((doc.Bin__c != Trigger.oldMap.get(doc.Id).Bin__c                
                    || doc.Category__c != Trigger.oldMap.get(doc.Id).Category__c
                    || doc.Document_Key_Date__c != Trigger.oldMap.get(doc.Id).Document_Key_Date__c ) )) {
                doc.addError('You cannot modify a Proof of Inspection after a day is passed or is verified.');
            }

             if (doc.PM_Project__c != null                
                && Trigger.oldMap.get(doc.Id).Category__c  == 'Proof Of Inspection'
                && doc.createdDate.date() == System.today()   
                && !(exceptionProfiles.contains(UserInfo.getProfileId()) && !doc.Verified__c)             
                && doc.Document_Key_Date__c != System.Today()  ) {
                doc.addError('You can only select current date (today) for Proof of Inspection.');
            }
        }
    }

    if (Trigger.isAfter) {
        //update inspection date on the project
        Map<Id, PM_Project__c> pmInspectionUpdates = new Map<Id, PM_Project__c>();



        Map<String, String> compCategoryFieldMap = new Map<String, String> {
        'Approved Application' => 'Grant_Comp_Approved_Last_Updated_By__c', 
        'Prepared Application' => 'Grant_Comp_Completed_Last_Updated_By__c',
        'Signed Application' => 'Grant_Comp_Signed_Last_Updated_By__c', 
        'Submitted Application' => 'Grant_Comp_Submitted_Last_Updated_By__c',   
        'Submitted Application Part 2' => 'Grant_Comp_Submitted_P2_Last_Updated_By__c',
        'Approved Application Part 2' => 'Grant_Comp_Approved_P2_Last_Updated_By__c'
        };

        Map<String, String> resCategoryFieldMap = new Map<String, String> {
        'Approved Application' => 'Grant_Res_Approved_Last_Updated_By__c', 
        'Prepared Application' => 'Grant_Res_Completed_Last_Updated_By__c',
        'Signed Application' => 'Grant_Res_Signed_Last_Updated_By__c', 
        'Submitted Application' => 'Grant_Res_Submitted_Last_Updated_By__c'
        };
    
        for (Astrum_Doc__c doc : Trigger.new) {
            //PM 2.0 Inspection verified

            if ( Trigger.isUpdate && doc.PM_Project__c != null 
            && doc.Bin__c == 'Proof of Inspection' 
            && doc.Category__c == 'Proof of Inspection'
            && doc.Verified__c == true 
            && Trigger.oldMap.get(doc.Id).Verified__c != true) {
                pmInspectionUpdates.put(doc.PM_Project__c,
	                new PM_Project__c (
	                    Id = doc.PM_Project__c, 
	                    Inspection_Verified__c = doc.Document_Key_Date__c
                	)
                );
            }

            if ( Trigger.isUpdate && doc.PM_Project__c != null 
            && doc.Bin__c == 'Proof of Inspection' 
            && doc.Category__c == 'Proof of Inspection'
            && doc.Verified__c != true 
            && exceptionProfiles.contains(UserInfo.getProfileId())
            && Trigger.oldMap.get(doc.Id).Document_Key_Date__c != doc.Document_Key_Date__c) {
                pmInspectionUpdates.put(doc.PM_Project__c,
                    new PM_Project__c (
                        Id = doc.PM_Project__c, 
                        Proof_of_Inspection__c = doc.Document_Key_Date__c
                    )
                );
            }

            if (doc.PM_Project__c != null && doc.Bin__c == 'Grant Reservation' &&  resCategoryFieldMap.get(doc.Category__c) != null) {
                PM_Project__c proj = new PM_Project__c (Id = doc.PM_Project__c );
                proj.put(resCategoryFieldMap.get(doc.Category__c), UserInfo.getName());
                pmInspectionUpdates.put(doc.PM_Project__c,proj);
            }

            if (doc.PM_Project__c != null && doc.Bin__c == 'Grant Completion' && compCategoryFieldMap.get(doc.Category__c) != null) {
                PM_Project__c proj = new PM_Project__c (Id = doc.PM_Project__c );
                proj.put(compCategoryFieldMap.get(doc.Category__c), UserInfo.getName());
                pmInspectionUpdates.put(doc.PM_Project__c,proj);
            }
        }
        
        if (!pmInspectionUpdates.isEmpty()) {
            update pmInspectionUpdates.values();
        }
    }
        
}