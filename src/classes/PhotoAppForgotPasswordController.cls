/* FILE: PhotoAppForgotPasswordController.cls
 * AUTHOR: Rohit Jain
 * DATE: Oct 7, 2013
 * PURPOSE: Controller for PhotoAppForgotPassword page
 * MODIFICATION HISTORY
 * 
 */
 
public with sharing class PhotoAppForgotPasswordController {

    public String username {get; set;}   
       
    public PageReference forgotPassword() {
        Boolean success = Site.forgotPassword(username);
        PageReference pr = Page.PhotoAppForgotPasswordConfirm;
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        return null;
    }
    
}