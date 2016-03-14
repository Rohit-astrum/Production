trigger AstrumTime_Employee_Trigger on Employee__c (before insert, before update) {

    AstrumTime_Employee_Trigger_Utility.checkForDuplicateEmployeeName(trigger.new);
    AstrumTime_Employee_Trigger_Utility.copyHourlyRates(trigger.new);
}