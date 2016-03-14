trigger Event_Add_Property_Trigger on Event (before insert, before update, before delete) {
    /* //MK - 2016-06-16 - merged into single trigger


    // Modified - RJ 02/11/13 : Use Discription to Copy Notes from Task
    // get record type    
    RecordType siteSurveyRecordType = [SELECT Id FROM RecordType WHERE (Name = 'Site Survey Onsite' or  Name = 'Site Survey Remote') AND SobjectType = 'Event' limit 1];
    
    //get all of the objects from org
    Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
    Map<String, String> keyPrefixMap = new Map<String, String>{};
    
    //get the prefix of the objects in Ids
    Set<String> keyPrefixSet = gd.keySet();
    for(String sObj : keyPrefixSet) {
        Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
        //store all the Objects with their prefixes
        keyPrefixMap.put(r.getKeyPrefix(),r.getName());
    }
    
    List<Id> createdByList = new List<Id>();
    Map<Id,User> userRoleMap;
    String currentUserRole;
    
    if(Trigger.isUpdate || Trigger.isDelete)
    {
        for (Event rec:Trigger.old) {
            createdByList.add(rec.CreatedById); 
            System.debug('**Created '+rec.CreatedById);
            System.debug('**Current '+UserInfo.getUserRoleId());        
        }
    }  
    
    if(createdByList.size() > 0)
    {
        userRoleMap  = new Map<Id,User>([Select Id,UserRoleId,UserRole.Name from User Where Id in :createdByList]);
        List<UserRole> urs = [Select Name from UserRole Where id = :UserInfo.getUserRoleId()];
        if(urs != null && urs.size() > 0)
        {
            currentUserRole = urs[0].Name;    
        }
    } 
    
    if(Trigger.isDelete)
    {
        for (Event rec:Trigger.old) {
        
        
            if(userRoleMap != null && userRoleMap.get(rec.CreatedById) !=null && userRoleMap.get(rec.CreatedById).UserRole != null )
            {
                System.debug('**Created '+ userRoleMap.get(rec.CreatedById).UserRole.Name);
                System.debug('**Current '+currentUserRole );
                if(userRoleMap.get(rec.CreatedById).UserRole.Name == 'Inside Sales Consultant' && !(currentUserRole == 'Inside Sales Consultant' || currentUserRole == 'Inside Sales Manager' || currentUserRole == 'VP of Sales' ))
                {
                     rec.addError('You do not have permission to modify/delete this record.');    
                }
            }   
                
        
        }    
        
    }
    
    if(Trigger.isUpdate || Trigger.isInsert)
    {
        for (Event rec:Trigger.new) {
        
        
            if( !rec.Run_Trigger__c && userRoleMap != null && userRoleMap.get(rec.CreatedById) !=null && userRoleMap.get(rec.CreatedById).UserRole != null )
            {
                System.debug('**Created '+ userRoleMap.get(rec.CreatedById).UserRole.Name);
                System.debug('**Current '+currentUserRole );
                if(userRoleMap.get(rec.CreatedById).UserRole.Name == 'Inside Sales Consultant' && !(currentUserRole == 'Inside Sales Consultant' || currentUserRole == 'Inside Sales Manager' || currentUserRole == 'VP of Sales' ))
                {
                     rec.addError('You do not have permission to modify/delete this record.');    
                }
            }   
            else
            {
                rec.Run_Trigger__c = false;
            }
                
        
      
    
            String whatPrefix = rec.WhatId;
            
            if (whatPrefix != null) {
                whatPrefix = whatPrefix.subString(0,3);
                String objectType = keyPrefixMap.get(whatPrefix);
                
                if (rec.WhatId != null && objectType == 'Opportunity') {
                    Opportunity op = [Select Property__c, Property__r.Name, Schedule_Site_Survey_Task_id__c from Opportunity where id=:rec.WhatId];
                    
                    rec.Related_Property_Link__c = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + op.Property__c;
                    rec.Related_Property_Name__c = op.Property__r.Name;            
        
                    // pull over the notes
                    if (rec.RecordTypeId == siteSurveyRecordType.id) {
                        // get the original site survey task
                        List<Task> tasks = [Select Notes__c,Description From Task where id = :op.Schedule_Site_Survey_Task_id__c];
    
                        if (tasks != null && !tasks.isEmpty()) {
                            Task theTask = tasks[0];
                                            
                            // assign the notes to the new event
                            if(rec.Description != null)                        
                                rec.Description = rec.Description+'\n'+theTask.Description;
                            else
                                rec.Description = theTask.Description;
                                
                            if(theTask.Notes__c != null)
                            {
                                rec.Description = rec.Description +'\n'+theTask.Notes__c;
                            }   
    
                        }
                    }
                }
            }  
        }     
    }

    */
}