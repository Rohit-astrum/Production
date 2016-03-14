public without sharing class D2D_PropertyPhotosController extends D2D_BaseReferralController {

    public override List<String> getPortalReferralFields(){
        return new List<String> {
            'Id',
            'Lead__c',
            'Opportunity__c',
            'Full_Name__c',
            'D2D_Lead_Status__c'
        };
    }

    public override List<String> getLeadFields(){
        return new List<String> {
            'Id'
        };
    }

    public override List<String> getOpportunityFields(){
        return new List<String> {
            'Id',
            'StageName',
            'Property__c'
        };
    }

    public String uploadedFileId { get; set; } 
    public Attachment uploadFile { get; set; }
    public String photoType { get; set; }
    public Boolean soldStatus { get; private set; }
    public Boolean hasSalesOrder { get; private set; }
    

    /*public Attachment fpImage {get;set;}
    public Attachment rpImage {get;set;}
    public Attachment s1Image {get;set;}
    public Attachment s2Image {get;set;}
    public Attachment ubImage {get;set;}
    public Attachment emImage {get;set;}*/

    /*public Integer fpIndex {get;set;}
    public Integer rpIndex {get;set;}
    public Integer s1Index {get;set;}
    public Integer s2Index {get;set;}
    public Integer ubIndex {get;set;}
    public Integer emIndex {get;set;}*/

    private Map<String, String> photoNames;
    private Map<String, Id> parentIds;

	public D2D_PropertyPhotosController() {
        try{
            photoNames = new Map<String, String>();
            photoNames.put('fp', 'Front Home');
            photoNames.put('rp', 'Rear Home');
            photoNames.put('s1', 'Side One');
            photoNames.put('s2', 'Side Two');
            photoNames.put('ub', 'Utility Bill');
            photoNames.put('em', 'Electric Meter');
            photoNames.put('vc', 'Voided Check');

            uploadFile = new Attachment();
            photoType = '';
            soldStatus = (referral.D2D_Lead_Status__c == 'Sold');

            parentIds = new Map<String, Id>();
            parentIds.put('Property', relatedOpportunity.Property__c);
            hasSalesOrder = false;
            if(soldStatus){
                List<SCRB_SalesOrder__c> salesOrders = [SELECT Id FROM SCRB_SalesOrder__c WHERE OpportunityId__c = :relatedOpportunity.Id LIMIT 1];
                if(salesOrders.size() == 1){
                    parentIds.put('Sales Order', salesOrders[0].Id);
                    hasSalesOrder = true;
                } else {
                    hasSalesOrder = false;
                    ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.WARNING, 'This record must have a sales order before uploading voided check images.'));
                }
            }

            LoadPropertyImages();
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }
	}
	
	public List<Attachment> propertyAttachments = new List<Attachment>();
    

	private void LoadPropertyImages(){
        if(relatedOpportunity != null && String.isNotBlank(relatedOpportunity.Id) && String.isNotBlank(relatedOpportunity.Property__c)){
            propertyAttachments = new List<Attachment>();
            propertyAttachments.addAll([SELECT Id, Name FROM Attachment WHERE ParentId = :parentIds.get('Property') ORDER BY Name]);
            if(hasSalesOrder){
                propertyAttachments.addAll([SELECT Id, Name FROM Attachment WHERE ParentId = :parentIds.get('Sales Order') AND Name LIKE '%Voided Check%' ORDER BY Name]);
            }
			/*for(Attachment att : propertyAttachments){
				if(att.Name.contains('Front Home')){
					fpImage = att;
				} else if(att.Name.contains('Rear Home')){
					rpImage = att;
				} else if(att.Name.contains('Side One')){
					s1Image = att;
				} else if(att.Name.contains('Side Two')){
					s2Image = att;
				} else if(att.Name.contains('Utility Bill')){
					ubImage = att;
				} else if(att.Name.contains('Electric Meter')){
					emImage = att;
				}
			}*/
		}
	}
	
	public Integer findFileNameIndex(String PhotoName){
		
		Integer index = 1;
		for(Attachment att : propertyAttachments){
			if(att.Name.contains(PhotoName)){
				Integer temp = Integer.valueOf(att.Name.split(PhotoName+' ')[1]);
				if(temp >= index) {
					index = temp + 1;
				}
			}
		}
			
		return index;
	}
	
	public Attachment[] getFpAttachments(){
        return getAttachments('Front Home');
    }
	
	public Attachment[] getRpAttachments(){
        return getAttachments('Rear Home');
    }
	
	public Attachment[] getS1Attachments(){
        return getAttachments('Side One');
    }
	
	public Attachment[] getS2Attachments(){
        return getAttachments('Side Two');
    }
	
	public Attachment[] getUbAttachments(){
        return getAttachments('Utility Bill');
    }
	
	public Attachment[] getEmAttachments(){
        return getAttachments('Electric Meter');
    }

    public Attachment[] getVcAttachments(){
        return getAttachments('Voided Check');
    }

    private Attachment[] getAttachments(String photoName){
        Attachment[] attachmentList = new Attachment[]{};
        for(Attachment att : propertyAttachments){
            if(att.Name.contains(photoName)){
                attachmentList.add(att);
            }
        }
        return attachmentList;
    }
        
	
    public PageReference upload() { 
        uploadedFileId  = null;    

        // Ensure relatedOpportunity
        if(relatedOpportunity == null || String.isBlank(relatedOpportunity.Id) || String.isBlank(relatedOpportunity.Property__c)){
            ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.WARNING, 'This record must have an opportunity before uploading a file.'));
            uploadFile = new Attachment();
            return null;
        }

        try {
            Id parentId = (photoType == 'vc') ? parentIds.get('Sales Order') : parentIds.get('Property');

        	String photoName = photoNames.get(photoType);
        	Integer fileIndex = findFileNameIndex(photoName);
        	uploadFile.Name = photoName + ' '+ String.valueOf(fileIndex);
            uploadFile.ParentId = parentId;
            insert uploadFile; 

            uploadFile = [SELECT Id, BodyLength, Name, ContentType
                FROM Attachment 
                WHERE Id = :uploadFile.Id];

            uploadedFileId  = uploadFile.Name;

            uploadFile = new Attachment();
            photoType = '';
            LoadPropertyImages();
            
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
            uploadFile = new Attachment();
            return null;
        }

        return null;
    }
    
    
    public PageReference submit() { 
    	
        if(referral.D2D_Lead_Status__c == 'Customer Opt-In' || referral.D2D_Lead_Status__c == 'Visit Scheduled'|| referral.D2D_Lead_Status__c == 'Photos Submitted' || referral.D2D_Lead_Status__c == 'Missing Utility Bill'){
        	
        	if(getAttachments('Utility Bill').size() > 0) {
    			referral.D2D_Lead_Status__c = 'Photos Submitted';
        	}
        	
        	else
        	{
    			referral.D2D_Lead_Status__c = 'Missing Utility Bill';
        	}
            update referral;
        }
        
        PageReference pr = new PageReference(dashboardUrl);
        pr.setRedirect(true);
        return pr;
    }
}