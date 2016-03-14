global class Lead_Status_Late_Stage_Scheduler {

	global void Lead_Status_Late_Stage_Scheduler() {}
	
	public static void start() {
		// Run every day at 9am
		String cronExpression = '0 0 9 * * ?';
		System.schedule('Lead Status Emailer - Late Stage', cronExpression, new Lead_Status_Late_Stage_Scheduled_Task());
	}
}