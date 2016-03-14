public with sharing class TriggerUtility {
 
    public static boolean isOpportunityUpdate;
    public static boolean isMilestoneUpdate;

	public static boolean taskTriggerHasNotRun_Before = true;
	public static boolean taskTriggerHasNotRun_After = true;

	public static boolean milestoneTriggerHasNotRun = true;
	
	//public static boolean isSystemDesignTriggerRunning = false;  //Moved this to the trigger handler instead
	//public static boolean isSystemDesignQuoteTriggerRunning = false;  //Moved this to the trigger handler instead
	public static boolean skipSystemDesignRollupTrigger = false;
	public static boolean skipSystemDesignArrayRollupTrigger = false;
	public static boolean skipSystemDesignItemRollupTrigger = false;
	public static boolean isAstrumEventTriggerRunning = false;	
	public static boolean isEventTriggerRunning = false;	
	public static boolean skipEventTrigger = false;

	public static boolean isTaskTriggerRunning = false;	
	public static boolean skipTaskTrigger = false;

	public static boolean skipAstrumEventTrigger = false;
	public static boolean skipAstrumDocVerificationTrigger = false;
	public static boolean skipDlrsTriggers = false;


	//Batch Processing 
	public static boolean bypassLeadTriggersForBatchProcessing = false;
	public static boolean bypassPhysicalSurfaceTriggersForBatchProcessing = false; 
	public static boolean bypassInstallLocationTriggersForBatchProcessing = false;	
	public static boolean bypassSystemDesignArrayTriggersForBatchProcessing = false;
	 
}