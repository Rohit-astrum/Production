public with sharing class My_Projects_Holder {

    public Milestone1_Project__c project {get; set;}
	public Map<String, String> complete {get; set;}
	public Map<String, Id> completeId {get; set;}
	
	public My_Projects_Holder() {
		complete = new Map<String, String>();
		completeId = new Map<String, Id>();
	}
}