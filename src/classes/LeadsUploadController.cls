public with sharing class LeadsUploadController {

	public transient Blob contentFile {get;set;}
	public transient String fileNameUploaded {get;set;}

	public Boolean fileIsParsed {get;set;}
	public Boolean fileIsValid {get;set;}
	public Boolean validationError {get;set;}

	public Map<Integer, InvalidLeadWrapper> invalidLeads {get;set;}
	public Map<Integer, InvalidLeadWrapper> duplicateLeads {get;set;}
	public Integer parsedRowCount {get;private set;}
	public Integer invalidRowCount{
		get{
			return invalidLeads.size();
		}
	}
	public Integer duplicateRowCount{
		get{
			return duplicateLeads.size();
		}
	}

	private String uploadTimestamp {get;private set;}
	private Map<Integer, Lead> leads {get;set;}
	private Map<Integer, Portal_Referral__c> portalReferrals {get;set;}

	private Group webLeadQueue {get;private set;}

	public LeadsUploadController() {
		uploadTimestamp = String.valueOf(Datetime.now().getTime());
		webLeadQueue = [SELECT Id, Name FROM Group WHERE Name = 'Web Lead Queue' LIMIT 1];
		init();
	}

	private void init(){
		fileIsParsed = false;
		fileIsValid = false;
		validationError = false;
		contentFile = null;
		fileNameUploaded = null;
	}

	public PageReference parseUploadFile(){
		fileIsParsed = false;
		validationError = false;
		if(!fileNameUploaded.endsWith('.csv')){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'File upload must be a csv file.'));
			validationError = true;
		} else {
			Map<String, Integer> hdrs = new Map<String, Integer>();
			List<List<String>> parsedLeads = parseCSV(contentFile.toString());
			Integer index = 0;
			for(String header : parsedLeads[0]){
				hdrs.put(header, index);
				index++;
			}

			Map<String, Integer> addressKeyMap = new Map<String, Integer>();
			Map<Integer, Lead> tempLeads = new Map<Integer, Lead>();
			invalidLeads = new Map<Integer, InvalidLeadWrapper>();
			portalReferrals = new Map<Integer, Portal_Referral__c>();
			leads = new Map<Integer, Lead>();
			index = -1;
			for(List<String> row : parsedLeads){
				index++;
				if(index == 0){
					continue;
				}

				Boolean invalidRow = false;

				// Check for required fields
				String invalidReason = '';
				List<String> reasons = new List<String>();
				system.debug('**SZ: row = ' + row);
				if(row[hdrs.get('Last Name')] == ''){ reasons.add('[LastName]'); }
				if(row[hdrs.get('First Name')] == ''){ reasons.add('[FirstName]'); }
				if(row[hdrs.get('Street')] == ''){ reasons.add('[Street]'); }
				if(row[hdrs.get('City')] == ''){ reasons.add('[City]'); }
				if(row[hdrs.get('State')] == ''){ reasons.add('[State]'); }
				if(row[hdrs.get('Zip')] == ''){ reasons.add('[PostalCode]'); }
				if(row[hdrs.get('County')] == ''){ reasons.add('[County]'); }
				if(row[hdrs.get('System Size')] == ''){ reasons.add('[SystemSize]'); }
				if(row[hdrs.get('ACP')] == ''){ reasons.add('[ACP]'); }
				if(row[hdrs.get('PSC')] == ''){ reasons.add('[PSC]'); }
				if(reasons.size() > 0){
					invalidReason = 'REQUIRED FIELDS: ' + String.join(reasons, ',');
					invalidRow = true;
					if(!validationError){ validationError = true; }
				}

				addressKeyMap.put(row[hdrs.get('Street')].toUpperCase() + row[hdrs.get('City')].toUpperCase() + row[hdrs.get('State')].toUpperCase() + row[hdrs.get('Zip')].toUpperCase(), index);

				String uploadId = uploadTimestamp + '.' + index;
				tempLeads.put(index, new Lead(
					D2D_Upload_Id__c = uploadId, OwnerId = webLeadQueue.Id, LastName = row[hdrs.get('Last Name')], FirstName = row[hdrs.get('First Name')], Company = row[hdrs.get('Last Name')] + ', ' + row[hdrs.get('First Name')], 
					Street = row[hdrs.get('Street')], City = row[hdrs.get('City')], State = row[hdrs.get('State')], D2D_State__c = row[hdrs.get('State')], County__c = row[hdrs.get('County')], PostalCode = row[hdrs.get('Zip')],
					Site_Type__c = 'Residential', Status = 'Prospect New', LeadSource = 'Canvassing', Lead_Source_Detail__c = 'Canvassing', Method_of_Contact__c = 'In-Person', Lead_Date__c = Date.today(),
					Affiliate_Community_Program__c = row[hdrs.get('ACP')], Primary_Source_Campaign__c = row[hdrs.get('PSC')]
				));
				portalReferrals.put(index, new Portal_Referral__c(
					D2D_System_Size__c = row[hdrs.get('System Size')] + ' Panel', D2D_Lead_Status__c = 'Prospect New', Last_Name__c = row[hdrs.get('Last Name')], First_Name__c = row[hdrs.get('First Name')],
					Street__c = row[hdrs.get('Street')], City__c = row[hdrs.get('City')], State__c = row[hdrs.get('State')], Zip__c = row[hdrs.get('Zip')], Lead_Created_Date__c = Date.today()
				));

				if(invalidRow){
					invalidLeads.put(index, new InvalidLeadWrapper(tempLeads.get(index), invalidReason));
				}
			}

			// Check for duplicate leads
			duplicateLeads = new Map<Integer, InvalidLeadWrapper>();
			List<Lead> duplicates = [SELECT Id, Address_Key__c FROM Lead WHERE Address_Key__c IN :addressKeyMap.keySet()];
			for(Lead lead : duplicates){
				if(addressKeyMap.containsKey(lead.Address_Key__c)){
					Integer idx = addressKeyMap.get(lead.Address_Key__c);
					if(!invalidLeads.containsKey(idx) && !duplicateLeads.containsKey(idx)){
						duplicateLeads.put(idx, new InvalidLeadWrapper(tempLeads.get(idx), ''));
					}
				}
			}

			// Create the map of leads to upload
			for(Integer idx : tempLeads.keySet()){
				if(!invalidLeads.containsKey(idx) && !duplicateLeads.containsKey(idx)){
					leads.put(idx, tempLeads.get(idx));
				}
			}

			parsedRowCount = tempLeads.size();
		}

		fileIsParsed = true;
		if(!validationError){
			fileIsValid = true;
		}
		return null;
	}

	public PageReference save(){
		Integer messagesSize = ApexPages.getMessages().size();
		try{
			// save the valid leads
			insert leads.values();

			// Create the Portal Referrals
			for(Lead lead : [SELECT Id, D2D_Upload_Id__c FROM Lead WHERE D2D_Upload_Id__c LIKE :uploadTimestamp + '.%']){
				Integer index = Integer.valueOf(lead.D2D_Upload_Id__c.replace(uploadTimestamp + '.', ''));
				portalReferrals.get(index).Lead__c = lead.Id;
			}
			for(Integer index : duplicateLeads.keySet()){
				portalReferrals.get(index).Status__c = 'Duplicate';
				portalReferrals.get(index).D2D_Lead_Status__c = 'Duplicate';
			}
			insert portalReferrals.values();

			// Send email to D2DSettings.Sales Coordinator
			SendEmail();
		} catch (DmlException dmlex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, dmlex.getMessage() + '<br/>' + dmlex.getStackTraceString()));
		} catch (Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage() + '<br/>' + ex.getStackTraceString()));
		}

		if(messagesSize == ApexPages.getMessages().size()){
			init();
		}

		return null;
	}

	public PageReference cancel(){
		init();
		return null;
	}

	private List<List<String>> parseCSV(String contents) {
		List<List<String>> allFields = new List<List<String>>();
		// replace instances where a double quote begins a field containing a comma
		// in this case you get a double quote followed by a doubled double quote
		// do this for beginning and end of a field
		contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
		// now replace all remaining double quotes - we do this so that we can reconstruct
		// fields with commas inside assuming they begin and end with a double quote
		contents = contents.replaceAll('""','DBLQT');
		// we are not attempting to handle fields with a newline inside of them
		// so, split on newline to get the spreadsheet rows

		List<String> lines = new List<String>();
		try {
		//lines = contents.split('\n'); //correction: this only accomodates windows files
			lines = contents.split('\r\n'); // using carriage return accomodates windows, unix, and mac files
		//http://www.maxi-pedia.com/Line+termination+line+feed+versus+carriage+return+0d0a
		} catch (System.ListException e) {
			System.debug('Limits exceeded?' + e.getMessage());
		}
		Integer num = 0;
		for(String line: lines) {
			system.debug('**SZ: line = ' + line);
			// check for blank CSV lines (only commas)
			if (line.replaceAll(',','').trim().length() == 0) break;

			List<String> fields = line.split(',', -1);
			system.debug('**SZ: fields = ' + fields + '; size = ' + fields.size());  
			List<String> cleanFields = new List<String>();
			String compositeField;
			Boolean makeCompositeField = false;
			for(String field: fields) {
				if (field.startsWith('"') && field.endsWith('"')) {
					cleanFields.add(field.replaceAll('DBLQT','"'));
				} else if (field.startsWith('"')) {
					makeCompositeField = true;
					compositeField = field;
				} else if (field.endsWith('"')) {
					compositeField += ',' + field;
					cleanFields.add(compositeField.replaceAll('DBLQT','"'));
					makeCompositeField = false;
				} else if (makeCompositeField) {
					compositeField +=  ',' + field;
				} else {
					cleanFields.add(field.replaceAll('DBLQT','"'));
				}
			}

			allFields.add(cleanFields);
		}
		return allFields;
	}

	private void SendEmail(){
		D2DSettings__c d2dSettings = D2DSettings__c.getOrgDefaults();

		EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'Notify Sales Coordinator' LIMIT 1];
		User salesCoordinator = [SELECT Id FROM User WHERE Email = :d2dSettings.Sales_Coordinator__c LIMIT 1];
		if(templateId != null && salesCoordinator != null){
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setTemplateID(templateId.Id); 
			email.setSaveAsActivity(false);
			email.setTargetObjectId(salesCoordinator.Id);

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'The email template or sales coordinator could not be found.'));
		}
	}

	public class InvalidLeadWrapper{
		public Lead InvalidLead {get;set;}
		public String InvalidReason {get;set;}

		public InvalidLeadWrapper(Lead lead, String reason){
			this.InvalidLead = lead;
			this.InvalidReason = reason;
		}
	}
}