/* FILE: D2D_LoginController.cls
 * AUTHOR: Stephanie Pratt
 * DATE: Aug 3, 2015
 * PURPOSE: Door 2 Door login controller
 * MODIFICATION HISTORY
 *
 */
 
public with sharing class D2D_LoginController {

    public String username {get; set;}
    public String password {get; set;}
    public Boolean rememberMe { get; set; }
    public Boolean showLogout { get; set; }

    private String managerUrl = '/D2D_ManagerDashboard';
    private String salesrepUrl = '/D2D_SalesRepDashboard';

    public D2D_LoginController() {
        showLogout = false;
        PageReference pr = ApexPages.currentPage();
        Cookie userNameCookie = pr.getCookies().get('username');
        if (userNameCookie != null) {
            username = userNameCookie.getValue();
            rememberMe = true;
        } else {
            rememberMe = false;
        }
    }
    
    public PageReference login() {
        PageReference result;
        try {
            String startUrl = System.currentPageReference().getParameters().get('startURL');
            System.debug('startUrl '+startUrl);
            //return Site.login(username, password, startUrl);
            if (Test.isRunningTest()){
                result = new PageReference(managerUrl);
            } else {
                List<User> users = new List<User>();
                try {
                    users = [SELECT Profile.Name, UserType FROM User WHERE Username = :username LIMIT 1];
                } catch(Exception ex) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '<br/>' + ex.getStackTraceString()));
                }
                if(users.size() == 1){
                    if(users[0].Profile.Name == 'D2D Manager' || users[0].Profile.Name == 'D2D Admin'){
                        result = Site.login(username, password, startUrl == null || startUrl.trim() == '' ? managerUrl : startUrl);
                    } else if(users[0].Profile.Name == 'D2D Sales Rep' || users[0].Profile.Name == 'D2D Portal User'){
                        result = Site.login(username, password, startUrl == null || startUrl.trim() == '' ? salesrepUrl : startUrl);
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The provided username is not authorized for this site.'));
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The provided username could not be found.  You may already be logged in as another user.  Click the LOG OUT link below and try again.'));
                    showLogout = true;
                    return null;
                }
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '<br/>' + ex.getStackTraceString()));
        }
        if (result != null) {
            Cookie userNameCookie;
            if (rememberMe == true) {
                userNameCookie = new Cookie('username', username, null, 60 * 60 * 24 * 60, false); //save cookie for 60 days
            } else {
                userNameCookie = new Cookie('username', null, null, 0, false); //delete cookie
            }
            result.getCookies().put('username', userNameCookie);
        }

        if(result != null){
            result.setRedirect(true);
        }
        return result; 
    }

}