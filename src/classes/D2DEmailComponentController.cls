public without sharing class D2DEmailComponentController {

	public String emailBody {
		get {
			if(emailTemplateType == 'MANAGER') {
				return 'New leads have been assigned to you.  Please visit the D2D Portal to review and assign sales reps.<br/>Thank you.';
			} else if(emailTemplateType == 'SALESREP') {
				return 'New leads have been assigned to you.  Please visit the D2D Portal to review your assigned leads.<br/>Thank you.';
			} else if(emailTemplateType == 'SALESCOORDINATOR') {
				return 'A new D2D lead file has been uploaded.  Please visit the assignment page to set the D2D managers.<br/>Thank you.';
			} else if(emailTemplateType == 'SIGNER') {
				return 'This email contains a copy of the contract containing your signature.<br/>Thank you.';
			} else if(emailTemplateType == 'VISIT') {
				return 'Your scheduled visit with Direct Energy Solar is approaching.<br/>Thank you.<br/><br/>' + additionalDatetime.format('E, M/d/yyyy h:mm a');
			} else if(emailTemplateType == 'CONTRACT') {
				return 'A solar system design and a contract has been generated for the following lead: ' + additionalBody;
			} else {
				return '';
			}
		}
	}

	public String emailTemplateType {
		get;
		set{
			emailTemplateType = value.toUpperCase();
			init();
		}
	}

	public String additionalBody {
		get;
		set{
			additionalBody = value;
			init();
		}
	}

	public Datetime additionalDatetime {
		get;
		set{
			additionalDatetime = value;
			init();
		}
	}

	public String portalUrl {
		get {
			D2DSettings__c d2dSettings = D2DSettings__c.getOrgDefaults();
			return d2dSettings.D2D_Site_Url__c + 'D2D_Home';
		}
		set;
	}

	private String serverUrl {
		get {
			if(serverUrl == null){
				String sUrlRewrite = System.URL.getSalesforceBaseUrl().getHost();
				String sfBaseProtocol = System.URL.getSalesforceBaseUrl().getProtocol();
				System.debug(LoggingLevel.INFO, 'getHost: ' + sUrlRewrite);
				System.debug(LoggingLevel.INFO, 'getProtocol: ' + sfBaseProtocol);

				//remove namespace
				if(!sUrlRewrite.contains('salesforce')) {
					integer firstDotPos = sUrlRewrite.indexOf('.');
					sURlRewrite = sURlRewrite.substring(firstDotPos+1);

					//replace visual.force with salesforce
					sURlRewrite = sURlRewrite.replace('visual.force', 'salesforce');
				}
				sUrlRewrite = sfBaseProtocol+'://'+sURlRewrite;
				serverURL = sUrlRewrite;
			}
			return serverURL;
		}
		set;
	}

	public Map<String, String> documentUrls {
		get{
			if (documentUrls == null){
				Map<String, String> urls = new Map<String, String>();
				List<Document> documents = [SELECT Id, Name FROM Document WHERE Name IN ('DESLogo')];
				for(Document doc : documents){
					urls.put(doc.Name, serverUrl + '/servlet/servlet.ImageServer?id=' + doc.Id + '&oid=' + UserInfo.getOrganizationId());
				}
				documentUrls = urls;
			}
		return documentUrls;
		}
		set;
	}

	public D2DEmailComponentController() {
	}

	private void init() {
	}
}