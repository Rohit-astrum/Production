/* FILE: PortalContactUsTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: September 6, 2012
 * PURPOSE: test class for PortalContactUs page and PortalContactUsController
 * MODIFICATION HISTORY
 *
 */

@isTest
public class PortalContactUsTest {

    static testMethod void portalUser_submitIssue_caseCreated() {
        
        User u = PortalToolsTest.createPortalUser();

        String issueText = 'This is the issue.\n More information here.';
        
        System.runAs(u) {
            
            Test.setCurrentPage(Page.PortalContactUs);
            PortalContactUsController controller = new PortalContactUsController();
            
            controller.issue = issueText;

            System.assertEquals(null, controller.submitIssue());
            System.assertNotEquals('', controller.errorFields);
        
            PartnerPortalSettings__c mc = new PartnerPortalSettings__c();
            mc.Name = 'Portal Contact';
            mc.Portal_Contact__c = u.Username;
            insert mc;

            System.assertEquals(null, controller.submitIssue());
            System.assertEquals(true, controller.submitted);
            System.assertEquals('', controller.errorFields);
        }
        
       /* Case c = [SELECT Id, ContactId, AccountId, Type, Origin, Description FROM Case];
        
        System.assertEquals(u.ContactId, c.ContactId);
        System.assertEquals('Professional Referral Network', c.Type);
        System.assertEquals('Partner Contact', c.Origin);
        System.assertEquals(issueText, c.Description);*/
        
    }
    
    static testMethod void portalUser_blankIssue_error() {
        
        User u = PortalToolsTest.createPortalUser();

        System.runAs(u) {
            
            Test.setCurrentPage(Page.PortalContactUs);
            PortalContactUsController controller = new PortalContactUsController();
            
            System.assertEquals(null, controller.submitIssue());
            System.assertNotEquals(true, controller.submitted);
            System.assert(controller.errorFields.contains('[1]'));
            System.assert(controller.errorFields.contains('[issue]'));
        }
        
        List<Case> cases = [SELECT Id, ContactId, AccountId, Type, Origin, Description FROM Case];
        
        System.assertEquals(0, cases.size());
        
    }

}