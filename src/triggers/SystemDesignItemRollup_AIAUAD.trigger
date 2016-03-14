trigger SystemDesignItemRollup_AIAUAD on System_Design_Item__c  (after insert, after update, 
                                        after delete, after undelete) {
                                            
     // modified objects whose parent records should be updated
     System_Design_Item__c [] objects = null;   

     if (Trigger.isDelete) {
         objects = Trigger.old;
     } else {
          
        objects = Trigger.new;
     }

     
     SystemDesignRollupCalcUtility.Context ctx = new SystemDesignRollupCalcUtility.Context(System_Design_Array__C.SobjectType, // parent object
                                            System_Design_Item__c.SobjectType,  // child object
                                            Schema.SObjectType.System_Design_Item__c.fields.System_Design_Array__c,// relationship field name
                                            'RecordType.Name = \'Panel\' '
                                            );     
     
          
     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jan_Peak_kWh__c',
                                            'Method_1_Jan_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Feb_Peak_kWh__c',
                                            'Method_1_Feb_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
     
     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Mar_Peak_kWh__c',
                                            'Method_1_Mar_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Apr_Peak_kWh__c',
                                            'Method_1_Apr_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_May_Peak_kWh__c',
                                            'Method_1_May_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jun_Peak_kWh__c',
                                            'Method_1_Jun_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jul_Peak_kWh__c',
                                            'Method_1_Jul_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Aug_Peak_kWh__c',
                                            'Method_1_Aug_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Sep_Peak_kWh__c',
                                            'Method_1_Sep_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Oct_Peak_kWh__c',
                                            'Method_1_Oct_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Nov_Peak_kWh__c',
                                            'Method_1_Nov_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Dec_Peak_kWh__c',
                                            'Method_1_Dec_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jan_Flat_kWh__c',
                                            'Method_1_Jan_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Feb_Flat_kWh__c',
                                            'Method_1_Feb_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
     
     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Mar_Flat_kWh__c',
                                            'Method_1_Mar_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Apr_Flat_kWh__c',
                                            'Method_1_Apr_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_May_Flat_kWh__c',
                                            'Method_1_May_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jun_Flat_kWh__c',
                                            'Method_1_Jun_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jul_Flat_kWh__c',
                                            'Method_1_Jul_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Aug_Flat_kWh__c',
                                            'Method_1_Aug_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Sep_Flat_kWh__c',
                                            'Method_1_Sep_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Oct_Flat_kWh__c',
                                            'Method_1_Oct_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Nov_Flat_kWh__c',
                                            'Method_1_Nov_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Dec_Flat_kWh__c',
                                            'Method_1_Dec_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
     
     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jan_Part_Peak_kWh__c',
                                            'Method_1_Jan_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Feb_Part_Peak_kWh__c',
                                            'Method_1_Feb_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
     
     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Mar_Part_Peak_kWh__c',
                                            'Method_1_Mar_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Apr_Part_Peak_kWh__c',
                                            'Method_1_Apr_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_May_Part_Peak_kWh__c',
                                            'Method_1_May_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jun_Part_Peak_kWh__c',
                                            'Method_1_Jun_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jul_Part_Peak_kWh__c',
                                            'Method_1_Jul_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Aug_Part_Peak_kWh__c',
                                            'Method_1_Aug_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Sep_Part_Peak_kWh__c',
                                            'Method_1_Sep_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Oct_Part_Peak_kWh__c',
                                            'Method_1_Oct_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Nov_Part_Peak_kWh__c',
                                            'Method_1_Nov_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Dec_Part_Peak_kWh__c',
                                            'Method_1_Dec_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         ));    

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jan_Off_Peak_kWh__c',
                                            'Method_1_Jan_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Feb_Off_Peak_kWh__c',
                                            'Method_1_Feb_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
     
     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Mar_Off_Peak_kWh__c',
                                            'Method_1_Mar_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Apr_Off_Peak_kWh__c',
                                            'Method_1_Apr_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_May_Off_Peak_kWh__c',
                                            'Method_1_May_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jun_Off_Peak_kWh__c',
                                            'Method_1_Jun_Off_Peak_kWh__c', 
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Jul_Off_Peak_kWh__c',
                                            'Method_1_Jul_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Aug_Off_Peak_kWh__c',
                                            'Method_1_Aug_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Sep_Off_Peak_kWh__c',
                                            'Method_1_Sep_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Oct_Off_Peak_kWh__c',
                                            'Method_1_Oct_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Nov_Off_Peak_kWh__c',
                                            'Method_1_Nov_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_1_Dec_Off_Peak_kWh__c',
                                            'Method_1_Dec_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jan_Peak_kWh__c',
                                            'Method_2_Jan_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Feb_Peak_kWh__c',
                                            'Method_2_Feb_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
     
     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Mar_Peak_kWh__c',
                                            'Method_2_Mar_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Apr_Peak_kWh__c',
                                            'Method_2_Apr_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_May_Peak_kWh__c',
                                            'Method_2_May_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jun_Peak_kWh__c',
                                            'Method_2_Jun_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jul_Peak_kWh__c',
                                            'Method_2_Jul_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Aug_Peak_kWh__c',
                                            'Method_2_Aug_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Sep_Peak_kWh__c',
                                            'Method_2_Sep_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Oct_Peak_kWh__c',
                                            'Method_2_Oct_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Nov_Peak_kWh__c',
                                            'Method_2_Nov_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Dec_Peak_kWh__c',
                                            'Method_2_Dec_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jan_Part_Peak_kWh__c',
                                            'Method_2_Jan_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Feb_Part_Peak_kWh__c',
                                            'Method_2_Feb_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
     
     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Mar_Part_Peak_kWh__c',
                                            'Method_2_Mar_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Apr_Part_Peak_kWh__c',
                                            'Method_2_Apr_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_May_Part_Peak_kWh__c',
                                            'Method_2_May_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jun_Part_Peak_kWh__c',
                                            'Method_2_Jun_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jul_Part_Peak_kWh__c',
                                            'Method_2_Jul_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Aug_Part_Peak_kWh__c',
                                            'Method_2_Aug_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Sep_Part_Peak_kWh__c',
                                            'Method_2_Sep_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Oct_Part_Peak_kWh__c',
                                            'Method_2_Oct_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Nov_Part_Peak_kWh__c',
                                            'Method_2_Nov_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Dec_Part_Peak_kWh__c',
                                            'Method_2_Dec_Part_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         ));    

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jan_Off_Peak_kWh__c',
                                            'Method_2_Jan_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Feb_Off_Peak_kWh__c',
                                            'Method_2_Feb_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
     
     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Mar_Off_Peak_kWh__c',
                                            'Method_2_Mar_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Apr_Off_Peak_kWh__c',
                                            'Method_2_Apr_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_May_Off_Peak_kWh__c',
                                            'Method_2_May_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jun_Off_Peak_kWh__c',
                                            'Method_2_Jun_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jul_Off_Peak_kWh__c',
                                            'Method_2_Jul_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Aug_Off_Peak_kWh__c',
                                            'Method_2_Aug_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Sep_Off_Peak_kWh__c',
                                            'Method_2_Sep_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Oct_Off_Peak_kWh__c',
                                            'Method_2_Oct_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Nov_Off_Peak_kWh__c',
                                            'Method_2_Nov_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Dec_Off_Peak_kWh__c',
                                            'Method_2_Dec_Off_Peak_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jan_Flat_kWh__c',
                                            'Method_2_Jan_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Feb_Flat_kWh__c',
                                            'Method_2_Feb_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
     
     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Mar_Flat_kWh__c',
                                            'Method_2_Mar_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Apr_Flat_kWh__c',
                                            'Method_2_Apr_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_May_Flat_kWh__c',
                                            'Method_2_May_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jun_Flat_kWh__c',
                                            'Method_2_Jun_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Jul_Flat_kWh__c',
                                            'Method_2_Jul_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Aug_Flat_kWh__c',
                                            'Method_2_Aug_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Sep_Flat_kWh__c',
                                            'Method_2_Sep_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Oct_Flat_kWh__c',
                                            'Method_2_Oct_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Nov_Flat_kWh__c',
                                            'Method_2_Nov_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     ctx.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Method_2_Dec_Flat_kWh__c',
                                            'Method_2_Dec_Flat_kWh__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
    
     
     //**************************
     //MK - 2014-04-30
     //**** REACHED LIMIT OF 100 ALIASED FIELDS, if rolling up more "panel" item fields, use ctx4 below
     //**************************
                                         
     Sobject[] masters = SystemDesignRollupCalcUtility.rollUp(ctx, objects);    

     //MK - 2014-03-13 - PERFORMANCE: Need to skip upstream triggers from firing before the last DML.  If we don't skip them, then all upstream rollups will fire 3 times total instead of 1. 
     TriggerUtility.skipSystemDesignArrayRollupTrigger = true;
     SystemDesignTriggerHandler.skipSystemDesignTrigger = true;
     // Persiste the changes in master
     update masters;

     SystemDesignRollupCalcUtility.Context ctx2 = new SystemDesignRollupCalcUtility.Context(System_Design_Array__C.SobjectType, // parent object
                                            System_Design_Item__c.SobjectType,  // child object
                                            Schema.SObjectType.System_Design_Item__c.fields.System_Design_Array__c,// relationship field name
                                            'RecordType.Name = \'Inverter\' '
                                            );  
     ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Inverter_CEC_Efficiency__c',
                                            'Inverter_CEC_Efficiency__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Avg
                                         )); 

    ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'DC_Optimizer_Efficiency__c',
                                            'DC_Optimizer_Efficiency__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Avg
                                         ));

    //MK - 2014-08-28: New fields for pricing calulations
    ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Inverter_Rating_W__c',
                                            'Inverter_Rating_W__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Avg
                                         ));

    Sobject[] masters2 = SystemDesignRollupCalcUtility.rollUp(ctx2, objects);    

     // Persiste the changes in master
     update masters2;
     
     
     
     //MK - 2014-03-13 - Rollup for Trenching Items only, but will affect the values for all Arrays
     SystemDesignRollupCalcUtility.Context ctx3 = new SystemDesignRollupCalcUtility.Context(System_Design_Array__C.SobjectType, // parent object
                                            System_Design_Item__c.SobjectType,  // child object
                                            Schema.SObjectType.System_Design_Item__c.fields.System_Design_Array__c,// relationship field name
                                            'RecordType.Name = \'Trenching\' '
                                            );  
     ctx3.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Total_Trenching_Length_ft__c',
                                            'Total_Trenching_Lengthft__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum                                            
                                         )); 

    Sobject[] masters3 = SystemDesignRollupCalcUtility.rollUp(ctx3, objects);    

     // Persiste the changes in master
     update masters3;


     SystemDesignRollupCalcUtility.Context ctx4 = new SystemDesignRollupCalcUtility.Context(System_Design_Array__C.SobjectType, // parent object
                                            System_Design_Item__c.SobjectType,  // child object
                                            Schema.SObjectType.System_Design_Item__c.fields.System_Design_Array__c,// relationship field name
                                            'RecordType.Name = \'Panel\' '
                                            );

     ctx4.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Total_TSRF__c',
                                            'Total_TSRF__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 

     //MK - 2014-03-13 - Added these 2 rollups for the Pricing calculation requirements.
     ctx4.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Array_Size_PTC_Rating_kW__c',
                                            'PTC_Rating_kW__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         ));
     ctx4.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Suneye_TSRF_Multiplier__c',
                                            'Suneye_TSRF_Multiplier__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         ));                                         

    //MK - 2014-04-25 - Added this rollup for proper tree removal calculation
    //I had to create a whole new ctx because when I added this field to the large roll-up from above, I got this error: maximum number of aliased fields exceeded: 100     
    ctx4.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Number_of_Locations_with_Tree_Removal__c',
                                            'Location_has_Tree_Removal__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         ));

    /*
    ctx4.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Number_of_Locations_with_Tree_Removal__c',
                                            'Location_has_Tree_Removal__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                        ));
    */
    
    //MK - 2014-08-28: New fields for pricing calulations
    ctx4.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Weighted_Panel_Tilt_Sum__c',
                                            'Weighted_Panel_Tilt_Sum__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                        ));    

    ctx4.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Weighted_Panel_Azimuth_Sum__c',
                                            'Weighted_Panel_Azimuth_Sum__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                        ));

    Sobject[] masters4 = SystemDesignRollupCalcUtility.rollUp(ctx4, objects);   

    //MK - 2014-03-13 - PERFORMANCE: Need to skip upstream triggers from firing before the last DML.  If we don't skip them, then all upstream rollups will fire 3 times total instead of 1. 
    TriggerUtility.skipSystemDesignArrayRollupTrigger = false; //let the trigger fire this time to run the parent rollups.
    SystemDesignTriggerHandler.skipSystemDesignTrigger = false;
    // Persiste the changes in master
    update masters4;
     
                                           
}