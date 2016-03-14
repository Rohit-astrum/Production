public class Lead_Status_Controller_Extension {

    public List<Lead_Status_Holder> leadsEarlyStageToContact {get; private set;}
    public List<Lead_Status_Holder> leadsMediumStageToContact {get; private set;}
    public List<Lead_Status_Holder> leadsLateStageToContact {get; private set;}
    public List<Lead_Status_Holder> allLeads {get; private set;}

    public List<Lead_Status_Holder> openNewLeads {get; private set;}
    public List<Lead_Status_Holder> contactedByUsLeads {get; private set;}
    public List<Lead_Status_Holder> contactedUsBackLeads {get; private set;}
    public List<Lead_Status_Holder> qualifiedLeads {get; private set;}
    public List<Lead_Status_Holder> onHoldLeads {get; private set;}
    public List<Lead_Status_Holder> unqualifiedLeads {get; private set;}
    public List<Lead_Status_Holder> unresponsiveLeads {get; private set;}
    public List<Lead_Status_Holder> marketingInfluencerLeads {get; private set;}
    public List<Lead_Status_Holder> lostCompetitionLeads {get; private set;}
        
    private void loadData() {
        leadsEarlyStageToContact = Lead_Status_Utility.getEarlyStageLeadsToContact();
        leadsMediumStageToContact = Lead_Status_Utility.getMediumStageLeadsToContact();
        leadsLateStageToContact = Lead_Status_Utility.getLateStageLeadsToContact();
        allLeads = Lead_Status_Utility.getAllLeadsForUser();
        
        assignAllLeadsToIndividualStatuses(allLeads);
    }
    
    public Lead_Status_Controller_Extension(ApexPages.StandardController stdController) {
        loadData(); 
    }
    
    private void assignAllLeadsToIndividualStatuses(List<Lead_Status_Holder> leadStatusHolders) {
    	Map<String, List<Lead_Status_Holder>> leadStatusHoldersMap = new Map<String, List<Lead_Status_Holder>>();
    	
    	openNewLeads = new List<Lead_Status_Holder>();
    	contactedByUsLeads = new List<Lead_Status_Holder>();
    	contactedUsBackLeads = new List<Lead_Status_Holder>();
    	qualifiedLeads = new List<Lead_Status_Holder>();
    	onHoldLeads = new List<Lead_Status_Holder>();
    	unqualifiedLeads = new List<Lead_Status_Holder>();
    	unresponsiveLeads = new List<Lead_Status_Holder>();
    	marketingInfluencerLeads = new List<Lead_Status_Holder>();
    	lostCompetitionLeads = new List<Lead_Status_Holder>();
    	
    	leadStatusHoldersMap.put(Lead_Status_Utility.OPEN_NEW_STATUS, openNewLeads);
    	leadStatusHoldersMap.put(Lead_Status_Utility.CONTACT_BY_US_STATUS, contactedByUsLeads);
    	leadStatusHoldersMap.put(Lead_Status_Utility.CONTACT_US_BACK_STATUS, contactedUsBackLeads);
    	leadStatusHoldersMap.put(Lead_Status_Utility.QUALIFIED_STATUS, qualifiedLeads);
    	leadStatusHoldersMap.put(Lead_Status_Utility.ON_HOLD_STATUS, onHoldLeads);
    	leadStatusHoldersMap.put(Lead_Status_Utility.UNQUALIFIED_STATUS, unqualifiedLeads);
    	leadStatusHoldersMap.put(Lead_Status_Utility.UNRESPONSIVE_STATUS, unresponsiveLeads);
    	leadStatusHoldersMap.put(Lead_Status_Utility.MARKETING_INFLUENCER_STATUS, marketingInfluencerLeads);
    	leadStatusHoldersMap.put(Lead_Status_Utility.LOST_COMPETITION_STATUS, lostCompetitionLeads);
    	
    	for (Lead_Status_Holder tempStatusHolder : leadStatusHolders) {
    		String theStatus = tempStatusHolder.theLead.status;
    		
    		List<Lead_Status_Holder> theLeads = leadStatusHoldersMap.get(theStatus);	

			if (theLeads != null) {
				theLeads.add(tempStatusHolder);    
			}		
    	}
    	
    	// update the indexes
    	List<List<Lead_Status_Holder>> leadsList = leadStatusHoldersMap.values();
    	for (List<Lead_Status_Holder> tempLeadsList : leadsList) {
    		updateIndexes(tempLeadsList);
    	}
    	    	
    }
    
    private void updateIndexes(List<Lead_Status_Holder> leads) {
    	Integer index = 1;
    	
    	for (Lead_Status_Holder temp : leads) {
    		temp.index = index;
    		index++;
    	}	
    }
}