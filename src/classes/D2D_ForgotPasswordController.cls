/* FILE: D2D_ForgotPasswordController.cls
 * AUTHOR: Stephanie Pratt
 * DATE: Aug 4, 2015
 * PURPOSE: Controller for D2D_ForgotPassword page
 * MODIFICATION HISTORY
 * 
 */

public with sharing class D2D_ForgotPasswordController {
	
	public String username {get; set;}   
       
    public PageReference forgotPassword() {
        Boolean success = (Test.isRunningTest()) ? true : Site.forgotPassword(username);
        PageReference pr = Page.D2D_ForgotPasswordConfirm;
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        return null;
    }

}