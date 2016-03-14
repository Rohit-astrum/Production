/* FILE: EP_ForgotPasswordController.cls
 * AUTHOR: Tino Mattheou
 * DATE: December 13, 2012
 * PURPOSE: Controller for EP_ForgotPassword page
 * MODIFICATION HISTORY
 * 
 */
 
public with sharing class EP_ForgotPasswordController {

    public String username {get; set;}   
       
    public PageReference forgotPassword() {
        Boolean success = Site.forgotPassword(username);
        PageReference pr = Page.EP_ForgotPasswordConfirm;
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        return null;
    }
    
}