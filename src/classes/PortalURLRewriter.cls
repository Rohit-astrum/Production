/* FILE: PortalURLRewriter.cls
 * AUTHOR: Tino Mattheou
 * DATE: September 13, 2012
 * PURPOSE: Support for friendly portal urls
 * MODIFICATION HISTORY
 * 09/18/2012 TCM - remove URL rewriting for mobile pages 
 * 11/19/2012 TCM - rewrite portal registration page to apply
 * 12/04/2012 TCM - add partner landing page logic
 */
 
global class PortalURLRewriter implements Site.UrlRewriter {

    private static final String VF_PORTAL_HOME = '/portalhome';
    private static final String VF_DASHBOARD = '/partnerdashboard';
    private static final String VF_OUTREACH_TOOLS = '/portaltools';
    private static final String VF_RESOURCES = '/portalresources';
    private static final String VF_CONTACT_US = '/portalcontactus';
    private static final String VF_FAQ = '/portalfaq';
    private static final String VF_REGISTRATION = '/portalregistration';
    private static final String VF_PARTNER_LANDING_PAGE = '/partnerlandingpage';
    
    private static final String FRIENDLY_WELCOME_PAGE = '/network-portal';
    private static final String FRIENDLY_DASHBOARD = '/dashboard';
    private static final String FRIENDLY_OUTREACH = '/outreach-tools';
    private static final String FRIENDLY_RESOURCES = '/resources';
    private static final String FRIENDLY_CONTACT_US = '/contact-us';
    private static final String FRIENDLY_APPLY = '/apply';
    private static final String FRIENDLY_FAQ = '/faq';
    
    public static Id partnerPageId;
    
    private static Map<String, Partner_Landing_Page__c> PARTNER_URLS {
        get {
            if (PARTNER_URLS == null) {
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
                PARTNER_URLS = urlMap;
            }
            return PARTNER_URLS;
        }
    }

    global PageReference mapRequestUrl(PageReference friendlyUrl) {

        System.debug('*Friendly URL - '+friendlyUrl.getUrl());
        String[] urls = friendlyUrl.getUrl().split('\\?');
        
        String url = urls[0].toLowerCase();
        
        System.debug('*URL - '+url );
        
        if (url.startsWith(FRIENDLY_WELCOME_PAGE)) {
            return Page.PortalHome;
        } else if (url.startsWith(FRIENDLY_DASHBOARD)) {
            return Page.PartnerDashboard;
        } else if (url.startsWith(FRIENDLY_OUTREACH)) {
            return Page.PortalTools;
        } else if (url.startsWith(FRIENDLY_RESOURCES)) {
            return Page.PortalResources;
        } else if (url.startsWith(FRIENDLY_CONTACT_US)) {
            return Page.PortalContactUs;
        } else if (url.startsWith(FRIENDLY_APPLY)) {
            return Page.PortalRegistration;
        } else if (url.startsWith(FRIENDLY_FAQ)) {
            System.debug('*FRIENDLY_FAQ - '+FRIENDLY_FAQ);
            return Page.PortalFAQ;
            
        } else if (PARTNER_URLS.containsKey(url)) {

            PageReference pr = Page.PartnerLandingPage;
            pr.getParameters().put('templateId', PARTNER_URLS.get(url).ID);
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
                
            if (url.startsWith(VF_PORTAL_HOME)) {
                result.add(new PageReference(FRIENDLY_WELCOME_PAGE));
            } else if (url.equals(VF_DASHBOARD)) {
                result.add(new PageReference(FRIENDLY_DASHBOARD));
            } else if (url.startsWith(VF_OUTREACH_TOOLS)) {
                result.add(new PageReference(FRIENDLY_OUTREACH));
            } else if (url.startsWith(VF_RESOURCES)) {
                result.add(new PageReference(FRIENDLY_RESOURCES));
            } else if (url.startsWith(VF_CONTACT_US)) {
                result.add(new PageReference(FRIENDLY_CONTACT_US));
            } else if (url.startsWith(VF_REGISTRATION)) {
                result.add(new PageReference(FRIENDLY_APPLY));
            } else if (url.startsWith(VF_FAQ)) {
                result.add(new PageReference(FRIENDLY_FAQ));
            /* } else if (PartnerLandingPageController.landingPageId != null) {
                PageReference pr = Page.PartnerLandingPage;
                pr.getParameters().putAll(vfUrl.getParameters());
                //pr.getParameters().put('templateId', PartnerLandingPageController.landingPageId);
                result.add(pr);
                List<Partner_Landing_Page__c> pages = 
                    [SELECT Id, Site_Url__c 
                    FROM Partner_Landing_Page__c
                    WHERE Id = :PartnerLandingPageController.landingPageId];
                if (!pages.isEmpty()) {
                    result.add(new PageReference('/' + pages[0].Site_Url__c));
                } else {
                    result.add(vfUrl);
                } */
            } else { 
                result.add(vfUrl);
            }
            
        }
        
        return result;
        
    }

}