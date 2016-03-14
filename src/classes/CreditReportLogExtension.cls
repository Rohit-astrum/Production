/* FILE: CreditReportLogExtension .cls
 * AUTHOR: Tino Mattheou
 * DATE: January 4, 2013
 * PURPOSE: Extension for CreditReportLogEdit. Gets account-related opportunities.
 * MODIFICATION HISTORY
 */

public class CreditReportLogExtension {

    private ApexPages.StandardController controller;
    
    public String opportunityId { get; set; }

    public CreditReportLogExtension (ApexPages.StandardController controller) {
        this.controller = controller;
        Credit_Report_Log__c crl = (Credit_Report_Log__c)controller.getRecord();
        this.opportunityId = crl.Related_Opportunity__c;
    }

    public List<SelectOption> opportunities {
        get {
            if (opportunities == null) {
                opportunities = new List<SelectOption>();
                Credit_Report_Log__c crl = (Credit_Report_Log__c)controller.getRecord();
                if (crl.Account__c != null) {
                    List<Opportunity> opps = 
                        [SELECT Id, Name, CloseDate, StageName
                        FROM Opportunity
                        WHERE AccountId = :crl.Account__c
                        ORDER BY CloseDate DESC];
                    if (opps.size() > 1) {
                        opportunities.add(new SelectOption('', '-- Select --'));
                    }
                    for (Opportunity opp : opps) {
                        opportunities.add(new SelectOption(opp.Id,
                            opp.Name + ' (' + opp.CloseDate.format() + ' ' + opp.StageName + ')'));
                    }
                }
            }
            return opportunities;
        }
        private set;
    }

    public PageReference savePage() {
        try {
            Credit_Report_Log__c crl = (Credit_Report_Log__c)controller.getRecord();
            if (String.isNotBlank(opportunityId)) {
                crl.Related_Opportunity__c = opportunityId;
            } else {
                crl.Related_Opportunity__c = null;
            }
            controller.save();
            return controller.view();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
}