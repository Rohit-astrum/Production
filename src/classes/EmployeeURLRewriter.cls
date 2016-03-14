/* FILE: EmployeeURLRewriter.cls
 * AUTHOR: Tino Mattheou
 * DATE: September 13, 2012
 * PURPOSE: Support for friendly portal urls
 * MODIFICATION HISTORY
 * 09/18/2012 TCM - remove URL rewriting for mobile pages 
 * 11/19/2012 TCM - rewrite portal registration page to apply
 * 12/04/2012 TCM - add partner landing page logic
 */
 
global class EmployeeURLRewriter implements Site.UrlRewriter {

    
    private static final String VF_PARTNER_LANDING_PAGE = '/employeelandingpage';
    
    private static final String FRIENDLY_WELCOME_PAGE = '/network-portal';
    private static final String FRIENDLY_DASHBOARD = '/dashboard';
    private static final String FRIENDLY_OUTREACH = '/outreach-tools';
    private static final String FRIENDLY_RESOURCES = '/resources';
    private static final String FRIENDLY_CONTACT_US = '/contact-us';
    private static final String FRIENDLY_APPLY = '/apply';
    
    public static Id partnerPageId;
    
    private static Map<String, Partner_Landing_Page__c> EMPLOYEE_URLS {
        get {
            if (EMPLOYEE_URLS == null) {
                Map<String, Partner_Landing_Page__c> urlMap = new Map<String, Partner_Landing_Page__c>();
                try {
                    String siteName = Site.getName(); //API Name
                    if (siteName != null) {
                        Site s = [SELECT Id, MasterLabel FROM Site WHERE Name = :siteName];
                        siteName = s.MasterLabel + '%';
                        List<Partner_Landing_Page__c> pages 
                            = [SELECT Id, Site_Url__c 
                            FROM Partner_Landing_Page__c
                            WHERE Portal_Site__c LIKE :siteName];
                        for (Partner_Landing_Page__c p : pages) {
                            urlMap.put('/' + p.Site_Url__c.toLowerCase(), p);
                        }
                    }
                } catch (Exception e) {
//TODO: log this somewhere
                }
                EMPLOYEE_URLS = urlMap;
            }
            return EMPLOYEE_URLS;
        }
    }

    global PageReference mapRequestUrl(PageReference friendlyUrl) {

        System.debug(friendlyUrl.getUrl());
        String[] urls = friendlyUrl.getUrl().split('\\?');
        
        String url = urls[0].toLowerCase();
        
        if (EMPLOYEE_URLS.containsKey(url)) {
            PageReference pr = Page.EmployeeLandingPage;
            pr.getParameters().put('templateId', EMPLOYEE_URLS.get(url).ID);
            return pr;
        }
        
        return null;
        
    }
    
    global List<PageReference> generateUrlFor(List<PageReference> vfUrls) {
        
        List<PageReference> result = new List<PageReference>();
        
        for (PageReference vfUrl : vfUrls) {

            String url = vfUrl.getUrl().toLowerCase();
                
System.debug('URL: ' + url);                
System.debug('Landing Page ID: ' + PartnerLandingPageController.landingPageId);             
                
            
                result.add(vfUrl);
           
            
        }
        
        return result;
        
    }

}