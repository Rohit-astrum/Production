global class Lead_Status_Early_Stage_Scheduler {

	public Lead_Status_Early_Stage_Scheduler() {
		
	}
	
	public static void start() {
		
		// run once per hour at the top of the hour
		String cronExpression = '0 0 1-23 * * ?';
		System.schedule('Lead Status Emailer - Early Stage', cronExpression, new Lead_Status_Early_Stage_Scheduled_Task());
	}

}