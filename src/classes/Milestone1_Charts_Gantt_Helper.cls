public with sharing class Milestone1_Charts_Gantt_Helper {

	public String myId {get;set;}
	public Boolean allowView {get;set;}
	
	ApexPages.StandardController stdCont;
	
	public Milestone1_Charts_Gantt_Helper(ApexPages.StandardController stc){
		myId = stc.getId();
		allowView = Apexpages.currentPage().getParameters().get('p') == null;
	}
	
}