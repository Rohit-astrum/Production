public class Sales_Visit_Complete_Utility {
    
    
    public static void sendNotificationEmail(Event theEvent, String Reason) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        List<Opportunity> opps = [Select o.Property__r.Property_ZIP__c, o.Property__r.Property_State__c, o.Property__r.Property_City__c, o.Property__r.Name, o.Property__c, 
                                  o.Owner.Email, o.Owner.FirstName, o.Owner.LastName, o.Owner.Manager.Email, o.OwnerId, o.Name 
                                  From Opportunity o 
                                  where id = :theEvent.WhatId 
                                  ];

        if (opps == null || opps.isEmpty()) {
            return; 
        }
        
        Opportunity opp = opps[0];
        
        String email = opp.Owner.Manager.Email;
        
        if (email != null) {
            // mail.setToAddresses(new String[] {opp.Owner.Email});
            mail.setToAddresses(new String[] {email});
            
            if(Reason == 'Disqualified')
            {
                mail.setSubject('Approval Request for Sales Visit Disqualified: ' + opp.Name + ',  Solar Consultant: ' + opp.Owner.LastName + ', ' + opp.Owner.FirstName);
            }
            String plainTextContent = getPlainTextContent(theEvent, opp , Reason);
            String htmlContent = getHtmlContent(theEvent, opp, Reason);
                    
            mail.setPlainTextBody(plainTextContent);
            mail.setHtmlBody(htmlContent);
                
            Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });           
        }
    }
    
    
    public static void sendNotificationEmail(Event theEvent) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        List<Opportunity> opps = [Select o.Property__r.Property_ZIP__c, o.Property__r.Property_State__c, o.Property__r.Property_City__c, o.Property__r.Name, o.Property__c, 
                                  o.Owner.Email, o.Owner.FirstName, o.Owner.LastName, o.Owner.Manager.Email, o.OwnerId, o.Name 
                                  From Opportunity o 
                                  where id = :theEvent.WhatId 
                                  ];

        if (opps == null || opps.isEmpty()) {
            return; 
        }
        
        Opportunity opp = opps[0];
        
        String email = opp.Owner.Manager.Email;
        
        if (email != null) {
            // mail.setToAddresses(new String[] {opp.Owner.Email});
            mail.setToAddresses(new String[] {email});
    
            mail.setSubject('Sales Visit Completed: ' + opp.Name + ',  Solar Consultant: ' + opp.Owner.LastName + ', ' + opp.Owner.FirstName);
    
            String plainTextContent = getPlainTextContent(theEvent, opp);
            String htmlContent = getHtmlContent(theEvent, opp);
                    
            mail.setPlainTextBody(plainTextContent);
            mail.setHtmlBody(htmlContent);
                
            Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });           
        }
    }

    public static String getPlainTextContent(Event theEvent, Opportunity theOpp) {
        String content = '';
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/';
        String propertyAddress = theOpp.Property__r.Name + ', ' + theOpp.Property__r.Property_City__c + ', ' + theOpp.Property__r.Property_State__c + ', ' + theOpp.Property__r.Property_ZIP__c;
        
        content += 'The Sales Visit is complete.\n\n';
        content += 'Solar Consultant: ' + theOpp.Owner.LastName + ', ' + theOpp.Owner.FirstName + '\n';
        content += 'Link to the Opportunity:  ' + theOpp.Name + '.  ' + baseUrl + theEvent.WhatId + '\n';
        content += 'Link to the Property: ' + propertyAddress + '.  ' + theEvent.Related_Property_Link__c + '\n';
        
        return content;
    }

    public static String getHtmlContent(Event theEvent, Opportunity theOpp) {
        String content = '';

        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/';
        
        String propertyAddress = theOpp.Property__r.Name + ', ' + theOpp.Property__r.Property_City__c + ', ' + theOpp.Property__r.Property_State__c + ', ' + theOpp.Property__r.Property_ZIP__c;
        
        content += 'The Sales Visit is complete.<br>';
        
        content += '<ul>';
        content += '<li>Solar Consultant: ' + theOpp.Owner.LastName + ', ' + theOpp.Owner.FirstName + '</li>';
        content += '<li>Opportunity: <a href="' + baseUrl + theEvent.WhatId + '">' + theOpp.name + '</a></li>';
        content += '<li>Property: <a href="' + theEvent.Related_Property_Link__c + '">' + propertyAddress + '</a></li>';
        content += '</ul>';
        
        return content;
    }
    
    public static String getPlainTextContent(Event theEvent, Opportunity theOpp , String Reason) {
        String content = '';
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/';
        String propertyAddress = theOpp.Property__r.Name + ', ' + theOpp.Property__r.Property_City__c + ', ' + theOpp.Property__r.Property_State__c + ', ' + theOpp.Property__r.Property_ZIP__c;
        if(Reason == 'Disqualified')
        {
            content += 'The Sales Visit is not completed and is Disqualified. Please approve the same. \n\n';
        }
        content += 'Solar Consultant: ' + theOpp.Owner.LastName + ', ' + theOpp.Owner.FirstName + '\n';
        content += 'Link to the Event:  ' + theEvent.Subject+ '.  ' + baseUrl + theEvent.Id + '\n';
        content += 'Link to the Opportunity:  ' + theOpp.Name + '.  ' + baseUrl + theEvent.WhatId + '\n';
        content += 'Link to the Property: ' + propertyAddress + '.  ' + theEvent.Related_Property_Link__c + '\n';
        
        return content;
    }

    public static String getHtmlContent(Event theEvent, Opportunity theOpp, String Reason) {
        String content = '';

        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/';
        
        String propertyAddress = theOpp.Property__r.Name + ', ' + theOpp.Property__r.Property_City__c + ', ' + theOpp.Property__r.Property_State__c + ', ' + theOpp.Property__r.Property_ZIP__c;
        
        if(Reason == 'Disqualified')
        {
            content += 'The Sales Visit is not completed and is Disqualified. Please approve the same.<br>';
        }
        content += '<ul>';
        
        content += '<li>Solar Consultant: ' + theOpp.Owner.LastName + ', ' + theOpp.Owner.FirstName + '</li>';   
        content += '<li>Event: <a href="' + baseUrl + theEvent.Id+ '">' + theEvent.Subject + '</a></li>';     
        content += '<li>Opportunity: <a href="' + baseUrl + theEvent.WhatId + '">' + theOpp.name + '</a></li>';
        content += '<li>Property: <a href="' + theEvent.Related_Property_Link__c + '">' + propertyAddress + '</a></li>';
        content += '</ul>';
        
        return content;
    }
}