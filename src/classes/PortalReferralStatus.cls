/* FILE: PortalReferralStatus.cls
 * AUTHOR: Tino Mattheou
 * DATE: September 4, 2012
 * PURPOSE: determines the status of a portal referral based on Lead and Opportunity
 * MODIFICATION HISTORY
 * 10/09/2012 TCM - updates to connect referring account leads to portal
 * 02/09/16  RJ SFS-662
 */
 
public class PortalReferralStatus { 
	
	public static final String OPEN_STATUS = 'OPEN';
	public static final String QUALIFIED_STATUS = 'QUALIFIED';
	public static final String CLOSED_STATUS = 'CLOSED';
	public static final String SOLD_STATUS = 'SOLD';
	public static final String DUPLICATE_STATUS = 'Duplicate';
	
	public static final Set<String> LEAD_STATUS_OPEN = new Set<String> {
		'Open – New', 'Contacted by Us', 'Contacted Us Back', 'On Hold', 'Unresponsive'	};
	public static final Set<String> LEAD_STATUS_CLOSED = new Set<String> {
		'Unqualified', 'Lost – Competition', 'Did Not Want Contact', 'Bad Contact Information' };
	public static final Set<String> OPPORTUNITY_STAGE_QUALIFIED = new Set<String> {
		'Qualified', 'Assigned to Field Sales', 'Sales Visit Scheduled', 'Sales Process Ongoing', 'Unresponsive', 'On Hold' };

	public static Boolean setReferralStatus(Lead l, Opportunity opp, Event salesEvent, Portal_Referral__c referral) {

		if (referral == null) {
			return false;
		}
		if (l != null && opp == null) {
			return leadReferralStatus(l, referral);
		} else if (opp != null) {
			return opportunityReferralStatus(opp, salesEvent, referral);
		}
		return false;
		
	}
	
	public static List<Portal_Referral__c> duplicateReferrals;
	
	public static Boolean creatingLeadInPortal = false;
	
	private static Boolean leadReferralStatus(Lead l, Portal_Referral__c referral) {
		
		String newStatus;
		String newDetail;
		
		if (LEAD_STATUS_OPEN.contains(l.Status)) {
			newStatus = OPEN_STATUS;
			if (l.Status == 'Open – New') {
				newDetail = 'New';
			} else if (l.Status == 'Contacted by Us') {
				newDetail = 'Contacted By Us';
			} else if (l.Status == 'Contacted Us Back') {
				newDetail = 'In Progress';
			} else if (l.Status == 'On Hold') {
				if (l.On_Hold_Until__c != null) {
					newDetail = 'On Hold Until ' + l.On_Hold_Until__c.month() + '/' + Math.mod(l.On_Hold_Until__c.year(),100);
				} else {
					newDetail = 'On Hold';
				}
			} else if (l.Status == 'Unresponsive') {
				newDetail = 'Unresponsive';
				if (referral.Last_Status_Change_Date__c != null 
				&& referral.Last_Status_Change_Date__c.daysBetween(Date.today()) > 60) { //less than 60 days open, over 60 closed
					newStatus = CLOSED_STATUS;
				}
			}
		} else if (l.Status == 'Qualified') {
			newStatus = QUALIFIED_STATUS;
			newDetail = 'Evaluation In Progress';
	    } else if (l.Status == 'Not a Lead - Duplicate') {
			newStatus = DUPLICATE_STATUS;
			newDetail = '';
		} else if (LEAD_STATUS_CLOSED.contains(l.Status)) {
			newStatus = CLOSED_STATUS;
			if (l.Status == 'Unqualified') {
				if (l.Unqualified_Reason__c == 'Site Quality') {
					newDetail = 'Unqualified - Site';
				} else if (l.Unqualified_Reason__c == 'Cost/Financial') {
					newDetail = 'Unqualified - $';
				} else {
					newDetail = 'Not Going Solar';
				}
			} else if (l.Status == 'Lost – Competition') {
				newDetail = 'Unqualified - Interest';
			} else if (l.Status == 'Did Not Want Contact') {
				newDetail = 'Did Not Want Contact';
			} else if (l.Status == 'Bad Contact Information') {
				newDetail = 'Bad Contact Info';
			}
		}
		
		if (newStatus != null && newDetail != null 
		&& (referral.Status__c != newStatus || referral.Detail__c != newDetail)) {
			referral.Status__c = newStatus;
			referral.Detail__c = newDetail;
			referral.Last_Status_Change_Date__c = Date.today();
			return true; 
		}
		
		return false;
		
	}
	
	private static Boolean opportunityReferralStatus(Opportunity opp, Event salesEvent, Portal_Referral__c referral) {

		String newStatus;
		String newDetail;
		
		if (OPPORTUNITY_STAGE_QUALIFIED.contains(opp.StageName)) {
			newStatus = QUALIFIED_STATUS;
			if (opp.StageName == 'On Hold') {
				if (opp.On_Hold_Until__c != null) {
					newDetail = 'On Hold Until ' + opp.On_Hold_Until__c.month() + '/' + opp.On_Hold_Until__c.month(); 
				} else {
					newDetail = 'On Hold';
				}
			} else if (opp.StageName == 'Unresponsive') {
				newDetail = 'Unresponsive';
			} else {
				Date surveyDate, createdDate, salesCallDate; 
				if (opp.Date_Site_Survey_Completed__c != null) {
					surveyDate = opp.Date_Site_Survey_Completed__c.date();
				}
				if (opp.CreatedDate != null) {
					createdDate = opp.CreatedDate.date();
				} else {
					createdDate = Date.today();
				}
				if (salesEvent != null && salesEvent.EndDateTime != null) {
					salesCallDate = salesEvent.EndDateTime.date();
				}
				if (salesCallDate != null) {
					if (salesCallDate.daysBetween(Date.today()) < 30) {
						newDetail = 'Sales Call Completed';
					} else if (salesCallDate.daysBetween(Date.today()) < 90) {
						newDetail = 'Sales Process Ongoing';
					} else {
						newDetail = 'Long-Term Opportunity';
					}
				} else if (surveyDate != null) {
					if (surveyDate.daysBetween(Date.today()) < 90) {
						newDetail = 'Site Survey Completed';
					} else {
						newDetail = 'Long-Term Opportunity';
					}
				} else if (createdDate.daysBetween(Date.today()) < 90) {
					newDetail = 'Evaluation in Progress';
				} else {
					newDetail = 'Long-Term Opportunity';
				}
			} 
		} else if (opp.StageName == 'Closed - Won') {
			newStatus = SOLD_STATUS;
			newDetail = opp.CloseDate.format();
		} else if (opp.StageName == 'Closed - Lost') {
			newStatus = CLOSED_STATUS;
			if (opp.Closed_Reason__c == 'Site Quality'
			|| opp.Closed_Reason__c == 'Roof/Installation Problems') {
				newDetail = 'Unqualified - Site';
			} else if (opp.Closed_Reason__c == 'Cannot Afford/Borrow'
			|| opp.Closed_Reason__c == 'ROI - Not Worth It'
			|| opp.Closed_Reason__c == 'Denied Credit') { //SFS-662
				newDetail = 'Unqualified - $';
			} else if (opp.Closed_Type__c == 'Competition' 
			|| opp.Closed_Reason__c == 'Spouse Veto'
			|| opp.Closed_Reason__c == 'Aesthetics') {
				newDetail = 'Unqualified - Interest';
			} else {
				newDetail = 'Not Going Solar';
			}
		} else if (opp.StageName == 'Unresponsive') { //over 120 days
			newStatus = CLOSED_STATUS;
			newDetail = 'Unresponsive';
		} else if (opp.StageName == 'Contract Cancelled') {
			newStatus = CLOSED_STATUS;
			newDetail = 'Cancelled Sale';
		}
		
		if (newStatus != null && newDetail != null 
		&& (referral.Status__c != newStatus || referral.Detail__c != newDetail)) {
			//if was sold and now not sold
			if (referral.Status__c == SOLD_STATUS) {
				referral.Sold_Referral_Fee__c = 0;
			}
			referral.Status__c = newStatus;
			referral.Detail__c = newDetail;
			referral.Last_Status_Change_Date__c = Date.today();
			return true; 
		}
		
		return false;
		
	}
	
	//processes earnings on newly added referrals
	public static void processUnsoldEarnings(List<Portal_Referral__c> unsoldReferrals) {
		
		Set<Id> referralAccountIds = new Set<Id>(); 
		Set<Id> paymentPlanIds = new Set<Id>();
		
		for (Portal_Referral__c referral : unsoldReferrals) {
			if (referral.Id == null) {
				referralAccountIds.add(referral.Account__c);
				paymentPlanIds.add(referral.Portal_Payment_Plan__c);
			}
		}
		
		if (referralAccountIds.isEmpty() || paymentPlanIds.isEmpty()) {
			return;
		}
			
		//get payment plan info
		Map<Id, Portal_Payment_Plan__c> planMap = new Map<Id, Portal_Payment_Plan__c>(
			[SELECT Id, Per_Referral_Fee__c, Per_Sale_Fixed_Amount__c, Per_Referral_Maximum_Number__c, Stop_Per_Referral_After_First_Sale__c
			FROM Portal_Payment_Plan__c
			WHERE Id IN :paymentPlanIds]
		);
		
		if (planMap.isEmpty()) {
			return;
		}
		
		//get total earnings so far
		AggregateResult[] results =
			[SELECT Account__c acct, Portal_Payment_Plan__c plan, COUNT(Portal_Referral_Fee__c) unsold_count, SUM(Portal_Referral_Fee__c) unsold, SUM(Sold_Referral_Fee__c) sold
			FROM Portal_Referral__c
			WHERE Account__c IN :referralAccountIds
			AND Portal_Payment_Plan__c IN :paymentPlanIds
			AND Status__c <> :PortalReferralStatus.DUPLICATE_STATUS
			AND Status__c <> NULL
			GROUP BY Account__c, Portal_Payment_Plan__c];

		//accumulate earnings for each account and plan		
		Map<Id, AccountEarnings> accountMap = new Map<Id, AccountEarnings>();
		for (AggregateResult result : results) {
			Id accountId = (Id)result.get('acct');
			Id planId = (Id)result.get('plan');
			AccountEarnings acctEarnings = accountMap.get(accountId);
			if (acctEarnings == null) {
				acctEarnings = new AccountEarnings();
				accountMap.put(accountId, acctEarnings);
			}
			PlanEarnings plnEarnings = acctEarnings.planMap.get(planId);
			if (plnEarnings == null) {
				plnEarnings = new PlanEarnings();
				acctEarnings.planMap.put(planId, plnEarnings);
			}
			Decimal unsold = (Decimal)result.get('unsold');
			if (unsold != null) {
				plnEarnings.unsoldEarnings += unsold;
			}
			Decimal unsoldCount = (Decimal)result.get('unsold_count');
			if (unsoldCount != null) {
				plnEarnings.unsoldCount += unsoldCount;
			}
			Decimal sold = (Decimal)result.get('sold');
			if (sold != null) {
				plnEarnings.soldEarnings += sold;
			}
		}		
		
		//process the sold referrals
		for (Portal_Referral__c referral : unsoldReferrals) {
			if (referral.Id != null) {
				continue;
			}
			Portal_Payment_Plan__c plan = planMap.get(referral.Portal_Payment_Plan__c);
			if (plan == null || plan.Per_Referral_Fee__c == null) {
				continue;
			}
			AccountEarnings acctEarnings = accountMap.get(referral.Account__c);
			if (acctEarnings == null) {
				acctEarnings = new AccountEarnings();
				accountMap.put(referral.Account__c, acctEarnings);
			}
			PlanEarnings plnEarnings = acctEarnings.planMap.get(referral.Portal_Payment_Plan__c);
			if (plnEarnings == null) {
				plnEarnings = new PlanEarnings();
				acctEarnings.planMap.put(referral.Portal_Payment_Plan__c, plnEarnings);
			}
			//no more per referral fees after first sale
			if (plnEarnings.soldEarnings != 0 && plan.Stop_Per_Referral_After_First_Sale__c == true) {
				continue;  
			}
			//if more than the max per referral - nothing
			if (plan.Per_Referral_Maximum_Number__c != null && plnEarnings.unsoldCount >= plan.Per_Referral_Maximum_Number__c) {
				continue;
			}  
			referral.Portal_Referral_Fee__c = plan.Per_Referral_Fee__c;
			plnEarnings.unsoldCount++;
		}
		
	}
	
	public static void processSoldEarnings(List<Portal_Referral__c> newlySoldReferrals) {
		
		Set<Id> referralAccountIds = new Set<Id>(); 
		Set<Id> paymentPlanIds = new Set<Id>();
		
		for (Portal_Referral__c referral : newlySoldReferrals) {
			referralAccountIds.add(referral.Account__c);
			paymentPlanIds.add(referral.Portal_Payment_Plan__c);
		}
			
		//get payment plan info
		Map<Id, Portal_Payment_Plan__c> planMap = new Map<Id, Portal_Payment_Plan__c>(
			[SELECT Id, Per_Sale_Fixed_Amount__c
			FROM Portal_Payment_Plan__c
			WHERE Id IN :paymentPlanIds]
		);
		
		//get total earnings so far
		AggregateResult[] results =
			[SELECT Account__c acct, Portal_Payment_Plan__c plan, SUM(Portal_Referral_Fee__c) unsold, SUM(Sold_Referral_Fee__c) sold
			FROM Portal_Referral__c
			WHERE Account__c IN :referralAccountIds
			AND Portal_Payment_Plan__c IN :paymentPlanIds
			AND Status__c <> :PortalReferralStatus.DUPLICATE_STATUS
			AND Status__c <> NULL
			GROUP BY Account__c, Portal_Payment_Plan__c];

		//accumulate earnings for each account and plan		
		Map<Id, AccountEarnings> accountMap = new Map<Id, AccountEarnings>();
		for (AggregateResult result : results) {
			Id accountId = (Id)result.get('acct');
			Id planId = (Id)result.get('plan');
			AccountEarnings acctEarnings = accountMap.get(accountId);
			if (acctEarnings == null) {
				acctEarnings = new AccountEarnings();
				accountMap.put(accountId, acctEarnings);
			}
			PlanEarnings plnEarnings = acctEarnings.planMap.get(planId);
			if (plnEarnings == null) {
				plnEarnings = new PlanEarnings();
				acctEarnings.planMap.put(planId, plnEarnings);
			}
			Decimal unsold = (Decimal)result.get('unsold');
			if (unsold != null) {
				plnEarnings.unsoldEarnings += unsold;
			}
			Decimal sold = (Decimal)result.get('sold');
			if (sold != null) {
				plnEarnings.soldEarnings += sold;
			}
		}		
		
		//process the sold referrals
		for (Portal_Referral__c referral : newlySoldReferrals) {
			Portal_Payment_Plan__c plan = planMap.get(referral.Portal_Payment_Plan__c);
			if (plan == null || plan.Per_Sale_Fixed_Amount__c == null) {
				continue;
			}
			AccountEarnings acctEarnings = accountMap.get(referral.Account__c);
			if (acctEarnings == null) {
				acctEarnings = new AccountEarnings();
				accountMap.put(referral.Account__c, acctEarnings);
			}
			PlanEarnings plnEarnings = acctEarnings.planMap.get(referral.Portal_Payment_Plan__c);
			if (plnEarnings == null) {
				plnEarnings = new PlanEarnings();
				acctEarnings.planMap.put(referral.Portal_Payment_Plan__c, plnEarnings);
			}
			if (plnEarnings.soldEarnings == 0) { //first sale
				Decimal soldEarnings = plan.Per_Sale_Fixed_Amount__c - plnEarnings.unsoldEarnings; //difference from unsold
				referral.Sold_Referral_Fee__c = soldEarnings;
				plnEarnings.soldEarnings += soldEarnings;
			} else { //subsequent sale
				referral.Sold_Referral_Fee__c = plan.Per_Sale_Fixed_Amount__c;
				plnEarnings.soldEarnings += referral.Sold_Referral_Fee__c;
			}
		}
		
	}
	
	static testMethod void referral_deleteLead_duplicateStatus() {
		
		Portal_Referral__c referral = LeadPortalReferralTriggerTest.createPortalReferral();
		
		referral = [SELECT Id, Lead__c, Status__c, Detail__c
			FROM Portal_Referral__c
			WHERE Id = :referral.Id];
			
		System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
		System.assertEquals('New', referral.Detail__c);		
		
		Test.startTest();
		
		Lead ld = new Lead (
			Id = referral.Lead__c
		);
		delete ld;
		
		Test.stopTest();

		referral = [SELECT Id, Lead__c, Status__c, Detail__c
			FROM Portal_Referral__c
			WHERE Id = :referral.Id];

		System.assertEquals(null, referral.Lead__c);
		System.assertEquals(PortalReferralStatus.DUPLICATE_STATUS, referral.Status__c);
		
	}
	
	public class AccountEarnings {
		public Map<Id, PlanEarnings> planMap = new Map<Id, PlanEarnings>();
	}
	
	public class PlanEarnings {
		public Decimal unsoldEarnings = 0;
		public Decimal unsoldCount = 0;
		public Decimal soldEarnings = 0;
	}

}