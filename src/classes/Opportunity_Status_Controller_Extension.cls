public class Opportunity_Status_Controller_Extension {

	public List<Opportunity_Status_Holder> earlyStageOpportunitiesToContact {get; private set;}
	public List<Opportunity_Status_Holder> mediumStageOpportunitiesToContact {get; private set;}
	public List<Opportunity_Status_Holder> lateStageOpportunitiesToContact {get; private set;}
	public List<Opportunity_Status_Holder> allOpportunitiesForUser {get; private set;}

	public List<Opportunity_Status_Holder> assignedToFieldSalesOpportunities {get; private set;}
	public List<Opportunity_Status_Holder> siteVisitScheduledOpportunities {get; private set;}
	public List<Opportunity_Status_Holder> salesProcessOngoingOpportunities {get; private set;}
	public List<Opportunity_Status_Holder> closedWonOpportunities {get; private set;}
	public List<Opportunity_Status_Holder> contractCancelledOpportunities {get; private set;}
	public List<Opportunity_Status_Holder> closedLostOpportunities {get; private set;}
	public List<Opportunity_Status_Holder> unqualifiedSiteQualityOpportunities {get; private set;}
	public List<Opportunity_Status_Holder> unresponsiveOpportunities {get; private set;}
	public List<Opportunity_Status_Holder> onHoldOpportunities {get; private set;}
	public List<Opportunity_Status_Holder> qualifiedOpportunities {get; private set;}
	
    public static final String SCHEDULED_COLOR = '#FFFFFF';
    public static final String PAST_DUE_COLOR = '#EF4839';
    public static final String COMPLETED_COLOR = '#04B404';

	public String scheduledColor {get; private set;}
	public String pastDueColor {get; private set;}
	public String completedColor {get; private set;}
	
	private void loadData() {
		// test code
		earlyStageOpportunitiesToContact = new List<Opportunity_Status_Holder>();
		mediumStageOpportunitiesToContact = new List<Opportunity_Status_Holder>();
		lateStageOpportunitiesToContact = new List<Opportunity_Status_Holder>();
		allOpportunitiesForUser = new List<Opportunity_Status_Holder>();
		
		earlyStageOpportunitiesToContact = Opportunity_Status_Utility.getEarlyStageOpportunitiesToContact();
		mediumStageOpportunitiesToContact = Opportunity_Status_Utility.getMediumStageOpportunitiesToContact();
		lateStageOpportunitiesToContact = Opportunity_Status_Utility.getLateStageOpportunitiesToContact();

		allOpportunitiesForUser = Opportunity_Status_Utility.getAllOpportunitiesForUser();		
		assignAllOpportunitiesToIndividualStages(allOpportunitiesForUser);
		
		scheduledColor = SCHEDULED_COLOR;
		pastDueColor = PAST_DUE_COLOR;
		completedColor = COMPLETED_COLOR;
	}
	
	public Opportunity_Status_Controller_Extension(ApexPages.StandardController stdController) {
		loadData();	
	}
	
	private void assignAllOpportunitiesToIndividualStages(List<Opportunity_Status_Holder> opportunityStatusHolders) {	
    	Map<String, List<Opportunity_Status_Holder>> oppsStatusHoldersMap = new Map<String, List<Opportunity_Status_Holder>>();
		
		assignedToFieldSalesOpportunities = new List<Opportunity_Status_Holder>();
		siteVisitScheduledOpportunities = new List<Opportunity_Status_Holder>();
		salesProcessOngoingOpportunities = new List<Opportunity_Status_Holder>();
		closedWonOpportunities = new List<Opportunity_Status_Holder>();
		contractCancelledOpportunities = new List<Opportunity_Status_Holder>();
		closedLostOpportunities = new List<Opportunity_Status_Holder>();
		unqualifiedSiteQualityOpportunities = new List<Opportunity_Status_Holder>();
		unresponsiveOpportunities = new List<Opportunity_Status_Holder>();
		onHoldOpportunities = new List<Opportunity_Status_Holder>();
		qualifiedOpportunities = new List<Opportunity_Status_Holder>();
		
		oppsStatusHoldersMap.put(Opportunity_Status_Utility.ASSIGNED_TO_FIELD_SALES, assignedToFieldSalesOpportunities);
		oppsStatusHoldersMap.put(Opportunity_Status_Utility.SALES_VISIT_SCHEDULED, siteVisitScheduledOpportunities);
		oppsStatusHoldersMap.put(Opportunity_Status_Utility.SALES_PROCESS_ONGOING, salesProcessOngoingOpportunities);
		oppsStatusHoldersMap.put(Opportunity_Status_Utility.CLOSED_WON, closedWonOpportunities);
		oppsStatusHoldersMap.put(Opportunity_Status_Utility.CONTRACT_CANCELLED, contractCancelledOpportunities);
		oppsStatusHoldersMap.put(Opportunity_Status_Utility.CLOSED_LOST, closedLostOpportunities);
		oppsStatusHoldersMap.put(Opportunity_Status_Utility.UNQUALIFIED_SITE_QUALITY, unqualifiedSiteQualityOpportunities);
		oppsStatusHoldersMap.put(Opportunity_Status_Utility.UNRESPONSIVE, unresponsiveOpportunities);
		oppsStatusHoldersMap.put(Opportunity_Status_Utility.ON_HOLD, onHoldOpportunities);
		oppsStatusHoldersMap.put(Opportunity_Status_Utility.QUALIFIED, qualifiedOpportunities);
    	
    	// assign by stage
    	for (Opportunity_Status_Holder tempStatusHolder : opportunityStatusHolders) {
    		String theStage = tempStatusHolder.theOpportunity.StageName;
    		
    		List<Opportunity_Status_Holder> theOpps = oppsStatusHoldersMap.get(theStage);	

			if (theOpps != null) {
				theOpps.add(tempStatusHolder);    
			}		
    	}
    	
    	// update the indexes
    	List<List<Opportunity_Status_Holder>> oppsList = oppsStatusHoldersMap.values();
    	for (List<Opportunity_Status_Holder> tempList : oppsList) {
    		updateIndexes(tempList);
    	}
    	    	
    }
    
    private void updateIndexes(List<Opportunity_Status_Holder> leads) {
    	Integer index = 1;
    	
    	for (Opportunity_Status_Holder temp : leads) {
    		temp.index = index;
    		index++;
    	}	
    }
}