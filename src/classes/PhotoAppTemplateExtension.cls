public class PhotoAppTemplateExtension {

  public PhotoAppTemplateExtension (PortalDummyController controller) {  
  }
  
  public PhotoAppTemplateExtension (ApexPages.StandardController controller) {    
  }

  //determine which template to use
  public PageReference getTemplate() {
    if (MobileHelper.isPhone) {
      return Page.PhotoAppSiteTemplate;
    }
    return Page.PhotoAppSiteTemplate;
  }

}