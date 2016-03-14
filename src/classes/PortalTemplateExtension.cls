public class PortalTemplateExtension {

	public PortalTemplateExtension(PortalDummyController controller) {	
	}
	
	public PortalTemplateExtension(ApexPages.StandardController controller) {		
	}

	//determine which template to use
	public PageReference getTemplate() {
System.debug(MobileHelper.userAgent);
System.debug(ApexPages.currentPage().getUrl());
		if (MobileHelper.isPhone) {
			return Page.PortalMobileSiteTemplate;
		}
		return Page.PortalSiteTemplate;
	}

}