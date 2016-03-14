global class Opportunity_Status_Late_Scheduler {

	public static void start() {
		// Run every day at 9am
		String cronExpression = '0 0 9 * * ?';
		System.schedule('Opportunity Status Emailer - Late Stage', cronExpression, new Opportunity_Status_Late_Scheduled_Task());
	}

}