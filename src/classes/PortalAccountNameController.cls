/* File: PortalAccountNameController.cls
 * Date: July 13, 2012
 * Author: Tino Mattheou
 * Purpose: Controller for PortalAccountName component
 * MODIFICATION HISTORY
 */
 
public class PortalAccountNameController {

	public String accountName { get; private set; }

	public PortalAccountNameController() {
		User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()]; 
		if (u.ContactId != null) {
			Contact c = [SELECT Id, Account.Name FROM Contact WHERE Id = :u.ContactId];
			accountName = c.Account.Name;
		} 
	}

}