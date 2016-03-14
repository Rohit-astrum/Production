global class DEBundle_LeadTransferJob implements Schedulable, Database.AllowsCallouts {
	global void execute(SchedulableContext sc) {
		DEBundle_LeadTransferBatch b = new DEBundle_LeadTransferBatch();
		Database.executebatch(b);
	}
}