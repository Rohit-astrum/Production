trigger SystemDesignArrayRollup_AIAUAD on System_Design_Array__c  (after insert, after update, 
                                        after delete, after undelete) {
                                            
                                            
     if(TriggerUtility.skipSystemDesignArrayRollupTrigger || TriggerUtility.bypassSystemDesignArrayTriggersForBatchProcessing) return; 
    
      // modified objects whose parent records should be updated
     System_Design_Array__c [] objects = null;   

     if (Trigger.isDelete) {
         objects = Trigger.old;
     } else {
          
        objects = Trigger.new; 
     }

     
     SystemDesignRollupCalcUtility.Context ctx = new SystemDesignRollupCalcUtility.Context(System_Design__C.SobjectType, // parent object
                                            System_Design_Array__c.SobjectType,  // child object
                                            Schema.SObjectType.System_Design_Array__c.fields.System_Design__c// relationship field name
                                            );     
     //METHOD_# ROLLUPS

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
     //**** REACHED LIMIT OF 100 ALIASED FIELDS, if rolling up more fields, use ctx2 below
     //**************************
                                      

     Sobject[] masters = SystemDesignRollupCalcUtility.rollUp(ctx, objects);    

     //MK - 2014-03-13 - PERFORMANCE: Need to skip upstream triggers from firing before the last DML.  If we don't skip them, then all upstream rollups will fire 2 times total instead of 1. 
     // Persiste the changes in master
     SystemDesignTriggerHandler.skipSystemDesignTrigger = true;
     update masters;



     //OTHER FIELD ROLLUPS, NON-"METHOD_#" FIELDS
     SystemDesignRollupCalcUtility.Context ctx2 = new SystemDesignRollupCalcUtility.Context(System_Design__C.SobjectType, // parent object
                                            System_Design_Array__c.SobjectType,  // child object
                                            Schema.SObjectType.System_Design_Array__c.fields.System_Design__c// relationship field name
                                            );     
     ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'NRG_Projected_Annual_Output_kWh_y__c', 
                                            'NRG_Projected_Annual_Output_kWh_y__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         )); 
     
     ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Total_TSRF__c',
                                            'Total_TSRF__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         ));  

     //MK - 2014-03-13 - Added these 2 rollups for the Pricing calculation requirements.
     ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Total_System_Size_PTC_rating_kW__c',
                                            'Array_Size_PTC_Rating_kW__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         ));

     ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Suneye_TSRF_Multiplier__c',
                                            'Suneye_TSRF_Multiplier__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         ));         

    //MK - 2014-04-25 - Added this rollup for proper tree removal calculation
    ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Number_of_Locations_with_Tree_Removal__c',
                                            'Number_of_Locations_with_Tree_Removal__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                         ));

    //MK - 2014-08-28: New fields for pricing calulations
    ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Weighted_Panel_Tilt_Sum__c',
                                            'Weighted_Panel_Tilt_Sum__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                        ));    

    ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Weighted_Panel_Azimuth_Sum__c',
                                            'Weighted_Panel_Azimuth_Sum__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                        ));

    ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Inverter_Efficiency_AC_System_Size_kW__c',
                                            'Inverter_Efficiency_AC_System_Size_kW__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                        ));
    
    ctx2.add(
            new SystemDesignRollupCalcUtility.RollupSummaryField(
                                            'Max_Inverter_Output_AC_System_Size_kW__c',
                                            'Max_Inverter_Output_AC_System_Size_kW__c',
                                            SystemDesignRollupCalcUtility.RollupOperation.Sum 
                                        ));

    Sobject[] masters2 = SystemDesignRollupCalcUtility.rollUp(ctx2, objects);   

    //MK - 2014-03-13 - PERFORMANCE: Need to skip upstream triggers from firing before the last DML.  If we don't skip them, then all upstream rollups will fire 2 times total instead of 1.     
    SystemDesignTriggerHandler.skipSystemDesignTrigger = false;
    // Persiste the changes in master
    update masters2;
}