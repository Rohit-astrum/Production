/* FILE: EP_OutreachToolsController.cls
 * DATE: December 19, 2012
 * AUTHOR: Tino Mattheou
 * PURPOSE: Controller for EP_OutreachTools page - shows only tools designated to the employee portal
 * MODIFICATION HISTORY
 *
 */ 
    
public without sharing class EP_OutreachToolsController {

    public List<Portal_Outreach_Tool__c> getTools() {   
    
        List<Portal_Outreach_Tool__c> result =
            [SELECT Id, Name, Description__c,
                (SELECT Id, Name, BodyLength, ContentType, Description
                FROM Attachments)
            FROM Portal_Outreach_Tool__c
            WHERE Active__c = TRUE
            AND Portal_Availability__c INCLUDES ('Employee Portal') order by Name];

        return result;
        
    }
    
}