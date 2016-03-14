global class Opportunity_Status_Early_Scheduler {

	public static void start() {
		// Run every day at 9am
		String cronExpression = '0 0 9 * * ?';
		System.schedule('Opportunity Status Emailer - Early Stage', cronExpression, new Opportunity_Status_Early_Scheduled_Task());
	}

}