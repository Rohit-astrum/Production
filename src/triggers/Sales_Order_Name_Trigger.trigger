trigger Sales_Order_Name_Trigger on SCRB_SalesOrder__c (before insert) {

//MK - 2014-04-04 - inactivated trigger and commented out lines.
    /*  inactive trigger
    List<SCRB_SalesOrder__c> recs = Trigger.new;
    
        for(SCRB_SalesOrder__c rec : recs)
        {
            if(Trigger.isBefore && Trigger.isInsert){
                
                datetime DT = Datetime.now();
                String dateString = DT.format('yyMMdd');  // 2 Digit Year followed by Month and Day 
                
                Integer soCount = [Select Count() from SCRB_SalesOrder__c so WHERE so.CreatedDate = TODAY];
                String soName = 'SO-' + dateString + '-' + soCount;     
                rec.Name = soName;
    */            
                
               // RJ: Moved the Logic to SalesORderController
               // User Owner = [
                  //  Select u.id, u.Sales_Order_Approver__c, u.Operations_Approved_Sales_Order_Recipien__c  
                    //from User u where u.id = :rec.OwnerId
                //]; 

                //if (Owner.Sales_Order_Approver__c != null){
                  //System.debug('**'+rec.Property__r.Astrum_Office_New__r.Sales_Coordinator__c);
                //rec.Sales_Coordinator__c = rec.Property__r.Astrum_Office_New__r.Sales_Coordinator__c;
                //}

                //if (Owner.Operations_Approved_Sales_Order_Recipien__c != null){
                //rec.Director_of_Operations__c = rec.Property__r.Astrum_Office_New__r.Director_of_Operations__c ;
                //}
          /*  inactive trigger
                if (rec.Assign_to_Dir_of_Ops__c){
                    rec.OwnerId = rec.Director_of_Operations__r.Id;
                    rec.Assign_to_Dir_of_Ops__c = false;
                }
                
                // Added by RJ - 12/17/12 Zen-48 - Moved the Logic to SalesORderController
               // rec.Sales_Alert_Email__c = rec.Property__r.Astrum_Office_New__r.Sales_Alert_Email__c;
        */
                // Commented by RJ - 12/17/12 Zen-48
                /*String AstrumOffice = [select id,Astrum_Office__c from Property__c where id = :rec.Property__c ].Astrum_Office__c;
                
                if(AstrumOffice == 'Annapolis Junction, MD'){
                    rec.Sales_Alert_Email__c = 'salesalertmd@astrumsolar.com';
                } 
                else if(AstrumOffice == 'Norristown, PA'){
                    rec.Sales_Alert_Email__c = 'salesalertpa@astrumsolar.com';
                }
                else if(AstrumOffice == 'Youngstown, OH'){
                    rec.Sales_Alert_Email__c = 'salesalertoh@astrumsolar.com';
                }
                else if(AstrumOffice == 'NY'){
                    rec.Sales_Alert_Email__c = 'salesalertny@astrumsolar.com';
                }
                else if(AstrumOffice == 'MI'){
                    rec.Sales_Alert_Email__c = 'salesalertoh@astrumsolar.com';
                }
                else if(AstrumOffice == 'MA'){
                    rec.Sales_Alert_Email__c = 'salesalertma@astrumsolar.com';
                }
                else {
                    rec.Sales_Alert_Email__c = 'salesalertmd@astrumsolar.com';
                }
                */

    /*  inactive trigger
            }
        }
    */
}