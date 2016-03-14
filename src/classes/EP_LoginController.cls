/* FILE: EP_LoginController.cls
 * AUTHOR: Tino Mattheou
 * DATE: December 13, 2012
 * PURPOSE: Employee Portal login controller
 * MODIFICATION HISTORY
 *
 */
 
public with sharing class EP_LoginController {

    public String username {get; set;}
    public String password {get; set;}
    public Boolean rememberMe { get; set; }
    
    private String url = '/EP_SubmitLeads';
    
    public EP_LoginController() {
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
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        //return Site.login(username, password, startUrl);
        PageReference result;
        if (Test.isRunningTest()){
            result = new PageReference(url);
        } else {
            result = Site.login(username, password, startUrl == null || startUrl.trim() == '' ? url : startUrl);
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
        return result; 
    }

}