public class PortalContactUsController {

    public transient Boolean submitted { get; private set; }
    public String issue { get; set; }
    public String errorFields { get; private set; }

    public PageReference submitIssue() {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        Messaging.SingleEmailMessage email2 = new Messaging.SingleEmailMessage(); 
        
        try {
            
            errorFields = '';
            
            if (issue == null || issue.trim() == '') {
                errorFields += '[1][issue]';
                return null;
            }

            User u = [SELECT Id, ContactId,Contact.Name,Contact.Email  FROM User WHERE Id = :UserInfo.getUserId()];
            
            PartnerPortalSettings__c mc = PartnerPortalSettings__c.getValues('Portal Contact');
            
            String[] toAddresses = new String[]{mc.Portal_Contact__c};
            // Sets the paramaters of the email
            email.setSubject( 'Partner Portal Contact Inquiry from - '+ u.Contact.Name);
            email.setToAddresses( toAddresses );
            email.setPlainTextBody( issue );
    
            // Sends the email
            Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            
            EmailTemplate et=[Select id from EmailTemplate where name = 'PortalContactUsConfirmation'];
            email2.setTargetObjectId(u.Id);
            email2.setSaveAsActivity(false);
            email2.setSenderDisplayName('Duncan Hinkle');
            email2.setTemplateId(et.id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email2 });
            
            
            //Contact c = [SELECT Id, AccountId FROM Contact WHERE Id = :u.ContactId];
            /*Case newCase = new Case (
                ContactId = c.Id,
                AccountId = c.AccountId,
                Type = 'Professional Referral Network',
                Origin = 'Partner Contact',
                Description = issue 
            );
            insert newCase;
            */
            
            submitted = true;
            
        } catch (Exception e) {
            
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            logError(e.getMessage() + ' ' + e.getStackTraceString());
            errorFields += '[unknown]';
            
        }
        return null;        
    }
    
    @future
    private static void logError(String errorMsg) {
        if(!Test.isRunningTest())
        {
            System.assert(false, errorMsg);
        }
    }

}