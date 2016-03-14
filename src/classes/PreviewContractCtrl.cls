/*  FILE: PreviewContractCtrl.cls
    AUTHOR: Dan Kelner
    DATE: 03/17/15
    PURPOSE: 
    MODIFICATION HISTORY
*/
public class PreviewContractCtrl {

	public Astrum_Contract__c selectedContr {get; set;}
	public Astrum_Contract__c[] contractList {get; set;}
	public ID pdfID {get; set;}
	public Integer preventSelling {get; set;}	//0: Don't prevent selling. 1: Contract is closed. 2: Proposal is not current. 3: Contract is not current. 4: Proposal is locked.
	
	public PreviewContractCtrl(ApexPages.StandardController stdController){
		preventSelling = 0;
		if (!Test.isRunningTest())
            stdController.addFields(new String[]{'Proposal__c'});
        selectedContr = (Astrum_Contract__c)stdController.getRecord();
		
		contractList = [SELECT Name, Current__c, Open_Quote__c, Closed__c, Proposal__c, CreatedDate, Proposal__r.System_Design_Quote__c, Proposal__r.System_Design_Quote__r.Name, 
						Proposal__r.Current__c, Proposal__r.Locked__c, Scenario__c, Locked__c
                        , Sighten_Signing_Status__c
						FROM Astrum_Contract__c WHERE Proposal__c = :selectedContr.Proposal__c LIMIT 10000];
		for (Astrum_Contract__c c : contractList){
			if (selectedContr.ID == c.ID){
				selectedContr = c;
				break;
			}
		}

		if (selectedContr.Closed__c){
			preventSelling = 1;
		} else if (!selectedContr.Proposal__r.Current__c){
			preventSelling = 2;
		} else if (!selectedContr.Current__c){
			preventSelling = 3;
		} else if (selectedContr.Proposal__r.Locked__c) {
			preventSelling = 4;
		}

		pdfID = getAttachmentID();

		// SIGHTEN UPDATES
		isSightenContract = SightenAPIIntegrator.IsSightenScenario(selectedContr.Proposal__r.System_Design_Quote__c, Integer.valueOf(selectedContr.Scenario__c));
        sightenStatus = selectedContr.Sighten_Signing_Status__c;
        if(sightenStatus == 'ERROR'){
            Sighten_Callback_Log__c lastLogMessage = SightenAPIHelper.GetLatestLog(selectedContr.ID);
            if(lastLogMessage != null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, lastLogMessage.Error_Message__c, lastLogMessage.Error_Detail__c));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'The status is ERROR, but a log message for this contract could not be found.  Please contact an administrator.'));
            }
        }
	}

	private ID getAttachmentID(){
		Attachment[] attchs = [SELECT ID FROM Attachment WHERE ParentID = :selectedContr.ID AND ContentType = 'application/pdf' AND (NOT Name LIKE '%Signed%') LIMIT 1];
		ID attchID;
		if (!attchs.isEmpty())
			attchID = attchs[0].ID;
		return attchID;
	}
	
	public PageReference goToContractPDF(){
        PageReference pg = new PageReference('/servlet/servlet.FileDownload?file=' + pdfID);
        pg.setRedirect(true);
        return pg;
    }

    public void switchContract(){
    	String newContractID = ApexPages.currentPage().getParameters().get('contractID');
    	if (String.isBlank(newContractID) || selectedContr.ID == newContractID)
    		return;

    	for (Astrum_Contract__c c : contractList){
			if (newContractID == c.ID){
				selectedContr = c;
				break;
			}
		}

		if (selectedContr.Closed__c){
			preventSelling = 1;
		} else if (!selectedContr.Proposal__r.Current__c){
			preventSelling = 2;
		} else if (!selectedContr.Current__c){
			preventSelling = 3;
		} else if (selectedContr.Proposal__r.Locked__c) {
			preventSelling = 4;
		}
		
		pdfID = getAttachmentID();

		isSightenContract = SightenAPIIntegrator.IsSightenScenario(selectedContr.Proposal__r.System_Design_Quote__c, Integer.valueOf(selectedContr.Scenario__c));
        sightenStatus = selectedContr.Sighten_Signing_Status__c;
    }

    public PageReference sellContract(){
    	//Close the Contract and its chain of parent objects
    	String acceptedResult = SalesWorkflowValidationUtility.contractWorkflowOnAccepted(selectedContr);
    	if (acceptedResult != 'Valid'){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: ' + acceptedResult));
            return null;
    	} 
    	return new PageReference('/apex/CloseContract?id=' + selectedContr.ID);
    }


    /*************************************/
    /* SIGHTEN METHODS                    /
    /*************************************/

    public Boolean isSightenContract {get;set;}
    public String sightenStatus {get;set;}

    public PageReference generateAndSendContract(){
        Boolean success = processContractAtSighten('send');
        return null;
    }

    public PageReference downloadContract(){
        Boolean success = processContractAtSighten('download');
        return null;
    }

    private Boolean processContractAtSighten(String processType){
        Boolean success = true;
        if(processType != 'send' && processType != 'download'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide a valid process type to the API method.'));
            return false;
        }

        try{
            Id proposalId = selectedContr.Proposal__c;
            Proposal__c proposal = [SELECT Id, Sighten_Scenario_1_Quote_uuid__c, Sighten_Scenario_2_Quote_uuid__c, Sighten_Scenario_3_Quote_uuid__c, Sighten_Scenario_4_Quote_uuid__c FROM Proposal__c WHERE Id = :proposalId LIMIT 1];
            String sightenQuoteId = '';
            if(selectedContr.Scenario__c == '1'){
                sightenQuoteId = proposal.Sighten_Scenario_1_Quote_uuid__c;
            } else if(selectedContr.Scenario__c == '2'){
                sightenQuoteId = proposal.Sighten_Scenario_2_Quote_uuid__c;
            } else if(selectedContr.Scenario__c == '3'){
                sightenQuoteId = proposal.Sighten_Scenario_3_Quote_uuid__c;
            } else if(selectedContr.Scenario__c == '4'){
                sightenQuoteId = proposal.Sighten_Scenario_4_Quote_uuid__c;
            }

            // Make API call with sightenQuoteId
            SightenAPIHelper.SightenAPIHelperResponse sightenResponse = null;
            if(processType == 'send'){
                sightenResponse = SightenAPIIntegrator.SendContract(sightenQuoteId);
            } else if(processType == 'download'){
                sightenResponse = SightenAPIIntegrator.DownloadContract(sightenQuoteId);
            }

            SightenAPIHelper helper = new SightenAPIHelper();
            if(sightenResponse.responseStatusCode == 200){
                if(processType == 'send'){
                    SightenAPIContract apiContract = (SightenAPIContract)helper.parseResponseBody(sightenResponse.responseBody, SightenAPIContract.class);
                    sightenStatus = 'SENT';
                    selectedContr.Sighten_Signing_Status__c = 'SENT';
                    update selectedContr;
                } else if(processType == 'download'){
                    Attachment att = new Attachment(
                        ParentID = selectedContr.Id,
                        Name = selectedContr.Name + '_ext_Signed.pdf',
                        Body = sightenResponse.responseBlob,
                        ContentType = 'application/pdf'
                    );
                    insert att;

                    sightenStatus = 'DOWNLOADED';
                    selectedContr.Sighten_Signing_Status__c = 'DOWNLOADED';
                    update selectedContr;

                    att.Body = null;
                    att = null;
                    sightenResponse.responseBody = null;
                    sightenResponse.responseBlob = null;
                }
            } else {
                SightenAPIEntity.SightenAPIErrorHelper errorHelper = (SightenAPIEntity.SightenAPIErrorHelper)helper.parseResponseBodyToError(sightenResponse.responseBody);
                if(errorHelper.errorResponse != null){
                    String errorMessage = 'Sighten API Error (' + processType + '): ' + errorHelper.errorResponse.messages.error[0].message;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                    SightenAPIHelper.LogErrorMessage(selectedContr.Id, errorMessage, '');
                    success = false;
                } else if(errorHelper.errorResponseList != null){
                    String errorMessage = 'Sighten API Error (' + processType + '): ' + errorHelper.errorResponseList.messages.error[0].message + '<br/>' + errorHelper.errorResponseList.data[0][0].rule.name + ', min: ' + errorHelper.errorResponseList.data[0][0].rule.min_bound + ', max: ' + errorHelper.errorResponseList.data[0][0].rule.max_bound + '<br/>Value(s): ' + errorHelper.errorResponseList.data[0][0].values;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                    SightenAPIHelper.LogErrorMessage(selectedContr.Id, errorMessage, '');
                    success = false;
                }

                sightenStatus = 'ERROR';
                selectedContr.Sighten_Signing_Status__c = 'ERROR';
                update selectedContr;
            }
        } catch(Exception ex){
            ApexPages.addMessages(ex);
            success = false;
        }

        return success;
    }
}