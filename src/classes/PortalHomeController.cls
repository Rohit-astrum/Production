public class PortalHomeController {
	
  	public SiteLoginController controller { get; set; }
  	
  	public PortalHomeController() {
  		controller = new SiteLoginCOntroller();
  		checkMobile();
  	}
	
	public PageReference checkMobile() {
System.debug(MobileHelper.userAgent);
System.debug(ApexPages.currentPage().getUrl());
		
		if (MobileHelper.isPhone) {
			PageReference pg = Page.PortalMobileHome;
			pg.setRedirect(true); 
			return pg;
		}
        return null;
    }
    
    public PageReference login() {
    	controller.url = '/PortalMobileNewReferral';
    	PageReference result = controller.login();
    	return result;
    }
    

}