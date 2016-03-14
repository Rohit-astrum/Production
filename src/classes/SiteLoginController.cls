/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}
    global Boolean rememberMe { get; set; }
    
    global String url = '/PortalNewReferral';
    global String aff_url = '/PortalAffiliateHomePage';
    
    global SiteLoginController () {
        PageReference pr = ApexPages.currentPage();
        Cookie userNameCookie = pr.getCookies().get('username');
        if (userNameCookie != null) {
            username = userNameCookie.getValue();
            rememberMe = true;
        } else {
            rememberMe = false;
        }
    }
    
    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');    
        PageReference result;   
        User portalUser;
        // Determine the profile based on Username
        try{
            portalUser = [Select Id, Profile.Name from User Where Username = :username];
            System.debug('*Username '+portalUser );
        }
        catch(Exception e)
        {
            System.debug('*Username Not Exist ');            
        }
        //return Site.login(username, password, startUrl);
        
        if(portalUser !=null && (portalUser.Profile.Name == 'Affiliate Partner Portal - Full User' || portalUser.Profile.Name == 'Affinity Partner Portal - Full User')  )
            result = Site.login(username, password,aff_url );
        else
            result = Site.login(username, password,url );    
            
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
    
    
    @IsTest(SeeAllData=true) global static void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
}