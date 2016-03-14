/*  FILE: PreviewProposalCtrl.cls
    AUTHOR: Dan Kelner
    DATE: 02/16/15
    PURPOSE: 
    MODIFICATION HISTORY
        03/13/15  DK  Redesigned for broader Contract support
*/
public class PreviewProposalCtrl {
    
    //Fields needed for PreviewProposal and SalesWorkflowValidationUtility.proposalWorkflowMakeCurrent()
    private String propFields = 'Name, System_Design_Quote__c, Proposal_Expiration_Date__c, Scenario_1_Included__c, Scenario_2_Included__c, Scenario_3_Included__c, Scenario_4_Included__c, ' + 
                                'Scenario_1_Financing_Plan__c, Scenario_2_Financing_Plan__c, Scenario_3_Financing_Plan__c, Scenario_4_Financing_Plan__c, Current__c, Valid__c, Locked__c, ' + 
                                'SDQ_Reconstruction_Record__c, System_Design_Quote__r.System_Design__c, System_Design_Quote__r.Panel_Count__c, System_Design_Quote__r.System_Size_kW__c, ' + 
                                'System_Design_Quote__r.System_Design__r.Property__r.Property_Owner__r.Name, System_Design_Quote__r.System_Design__r.Property__r.Name, ' + 
                                'System_Design_Quote__r.System_Design__r.Property__r.Property_City__c, System_Design_Quote__r.System_Design__r.Property__r.Property_State__c, ' + 
                                'System_Design_Quote__r.System_Design__r.Property__r.Property_Zip__c, System_Design_Quote__r.System_Design__r.Property__r.Property_Owner__r.Phone, ' +
                                'System_Design_Quote__r.System_Design__r.Property__r.Property_Owner__r.Billing_Email_Address__c, System_Design_Reconstruction_Record__c, System_Design_Stored_State__c ';
    private System_Design_Item__c[] sdItems;

    public Proposal__c prop {get; set;}
    public Proposal__c[] propList {get; set;}
    public Astrum_Contract__c contr1 {get; set;}
    public Astrum_Contract__c contr2 {get; set;}
    public Astrum_Contract__c contr3 {get; set;}
    public Astrum_Contract__c contr4 {get; set;}
    public ID propPdfID {get; set;}
    public String makeCurrentResult {get; set;}

    public PreviewProposalCtrl(ApexPages.StandardController stdController){
        if (!Test.isRunningTest())
            stdController.addFields(new String[]{'System_Design_Quote__c'});
        prop = (Proposal__c)stdController.getRecord();

        queryProposals();   //Build propList and set "prop" to the current Proposal

        queryContracts();   //Define the four Contract objects

        querySystemDesignItems();   //For displaying panel info

        List<Integer> scenarios = new List<Integer>();
        if(prop.Scenario_1_Included__c) { scenarios.add(1); }
        if(prop.Scenario_2_Included__c) { scenarios.add(2); }
        if(prop.Scenario_3_Included__c) { scenarios.add(3); }
        if(prop.Scenario_4_Included__c) { scenarios.add(4); }

        Map<Integer, List<Object>> sightenScenarios = SightenAPIIntegrator.GetSightenScenariosAndPayments(prop.System_Design_Quote__c, scenarios);
        scenario1IsSighten = sightenScenarios.containsKey(1) ? Boolean.valueOf(sightenScenarios.get(1)[0]) : false;
        scenario2IsSighten = sightenScenarios.containsKey(2) ? Boolean.valueOf(sightenScenarios.get(2)[0]) : false;
        scenario3IsSighten = sightenScenarios.containsKey(3) ? Boolean.valueOf(sightenScenarios.get(3)[0]) : false;
        scenario4IsSighten = sightenScenarios.containsKey(4) ? Boolean.valueOf(sightenScenarios.get(4)[0]) : false;

        Map<Integer, Boolean> sightenScenariosMap = new Map<Integer, Boolean>();
        sightenScenariosMap.put(1, scenario1IsSighten);
        sightenScenariosMap.put(2, scenario2IsSighten);
        sightenScenariosMap.put(3, scenario3IsSighten);
        sightenScenariosMap.put(4, scenario4IsSighten);

        Map<Integer, Sighten_Credit_Approval__c> sightenCreditApprovals = SightenAPIIntegrator.GetSightenCreditApprovals(prop.System_Design_Quote__c, sightenScenariosMap);
system.debug('**SZ: credit approvals = ' + sightenCreditApprovals);
        credit1 = sightenCreditApprovals.containsKey(1) ? sightenCreditApprovals.get(1) : null;
        credit2 = sightenCreditApprovals.containsKey(2) ? sightenCreditApprovals.get(2) : null;
        credit3 = sightenCreditApprovals.containsKey(3) ? sightenCreditApprovals.get(3) : null;
        credit4 = sightenCreditApprovals.containsKey(4) ? sightenCreditApprovals.get(4) : null;
    }

    private void queryProposals(){
        propList = Database.query('SELECT ' + propFields + 'FROM Proposal__c WHERE System_Design_Quote__c = \'' + prop.System_Design_Quote__c + '\' LIMIT 10000');
        for (Proposal__c p : propList){
            if (prop.ID == p.ID){
                prop = p;   //This sets the "active" Proposal in the VF page
                break;
            }
        }
    }

    private void queryContracts(){
        for (Astrum_Contract__c contr : [SELECT Scenario__c FROM Astrum_Contract__c WHERE Proposal__c = :prop.ID AND Current__c = true]){
            if (contr.Scenario__c == '1' && prop.Scenario_1_Included__c){
                contr1 = contr;
            } else if (contr.Scenario__c == '2' && prop.Scenario_2_Included__c){
                contr2 = contr;
            } else if (contr.Scenario__c == '3' && prop.Scenario_3_Included__c){
                contr3 = contr;
            } else if (contr.Scenario__c == '4' && prop.Scenario_4_Included__c){
                contr4 = contr;
            }
        }
    }

    private void querySystemDesignItems(){
        //Get System Design Products (through System Design Items)
        sdItems = [SELECT System_Design_Product__r.Description__c, System_Design_Product__r.RecordType.DeveloperName, RecordType.DeveloperName 
                   FROM System_Design_Item__c WHERE System_Design_Array__r.System_Design__c = :prop.System_Design_Quote__r.System_Design__c AND Quantity__c > 0 AND System_Design_Product__c != null LIMIT 10000];
        if (sdItems.isEmpty())
            sdItems = new System_Design_Item__c[]{};
    }

    private ID createContract(Integer scenario){
        try {
            Proposal__c proposal = [SELECT Id, Sighten_Scenario_1_Quote_uuid__c, Sighten_Scenario_2_Quote_uuid__c, Sighten_Scenario_3_Quote_uuid__c, Sighten_Scenario_4_Quote_uuid__c FROM Proposal__c WHERE Id = :prop.Id LIMIT 1];

            Astrum_Contract__c contr = AstrumContractCalculations.initilizeContract(prop.ID, scenario);
            contr.Current__c = true;
            String scenarioStr = String.valueOf(scenario);
            Astrum_Contract__c[] previousVersions = [SELECT ID FROM Astrum_Contract__c WHERE Proposal__c = :prop.ID AND Scenario__c = :scenarioStr AND Current__c = true];
            ID newContractID;
            if (scenario == 1){
                contr1 = contr;
                if(scenario1IsSighten){
                    contr1.Sighten_Signing_Status__c = 'NOT SENT';
                    contr1.Sighten_Contract_uuid__c = proposal.Sighten_Scenario_1_Quote_uuid__c;
                }
                insert contr1;
                newContractID = contr1.ID;
            } else if (scenario == 2){
                contr2 = contr;
                if(scenario2IsSighten){
                    contr2.Sighten_Signing_Status__c = 'NOT SENT';
                    contr2.Sighten_Contract_uuid__c = proposal.Sighten_Scenario_2_Quote_uuid__c;
                }
                insert contr2;
                newContractID = contr2.ID;
            } else if (scenario == 3){
                contr3 = contr;
                if(scenario3IsSighten){
                    contr3.Sighten_Signing_Status__c = 'NOT SENT';
                    contr3.Sighten_Contract_uuid__c = proposal.Sighten_Scenario_3_Quote_uuid__c;
                }
                insert contr3;
                newContractID = contr3.ID;
            } else if (scenario == 4){
                contr4 = contr;
                if(scenario4IsSighten){
                    contr4.Sighten_Signing_Status__c = 'NOT SENT';
                    contr4.Sighten_Contract_uuid__c = proposal.Sighten_Scenario_4_Quote_uuid__c;
                }
                insert contr4;
                newContractID = contr4.ID;
            }

            //Set sibling Contracts of the same scenario to "not current"
            for (Astrum_Contract__c c : previousVersions)
                c.Current__c = false;
            update previousVersions;

            return newContractID;
        } catch (Exception e){
            System.debug(e.getStackTraceString());
            return null;
        }
    }

    public PageReference saveContractPDF(){
        String scenarioNum = ApexPages.currentPage().getParameters().get('scenarioNum');
        if (String.isBlank(scenarioNum) || !scenarioNum.isNumeric()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid scenario number: ' + scenarioNum));
            return null;
        }
        Integer n = Integer.valueOf(scenarioNum);

        //Insert new Contract
        ID contractID = createContract(n);

        //Get the Conga Composer URL
        String congaURL = generateCongaComposerURL(contractID);
        System.debug('congaURL: ' + congaURL);
        
        PageReference pg = new PageReference(congaURL);
        pg.setRedirect(true);
        return pg;
    }

    public void saveProposalPDF(){
        Attachment[] existingAttchs = [SELECT ID FROM Attachment WHERE ParentID = :prop.ID AND Name = 'Proposal.pdf' AND ContentType = 'application/pdf' LIMIT 1];
        if (existingAttchs.isEmpty()){
            try {
                PageReference pg = Page.CPQproposal;
                pg.getParameters().put('id', prop.ID);
                Blob pdf = pg.getContentAsPdf();
                Attachment attch = new Attachment();
                attch.ParentID = prop.ID;
                attch.Body = pdf;
                attch.Name = 'Proposal.pdf';
                attch.ContentType = 'application/pdf';
                insert attch;
                propPdfID = attch.ID;
            } catch (Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: ' + e.getStackTraceString()));
            }
        } else {
            propPdfID = existingAttchs[0].ID;
        }
    }

    public PageReference goToProposalPDF(){
        PageReference pg = new PageReference('/servlet/servlet.FileDownload?file=' + propPdfID);
        pg.setRedirect(true);
        return pg;
    }

    private String generateCongaComposerURL(ID contractID){
        String base = 'https://www.appextremes.com/apps/Conga/Composer.aspx';
        String sessionID = UserInfo.getSessionID();
        String apiServerURL = ApexPages.currentPage().getParameters().get('apiServerURL');
        String templateIDs = '';    //Examples in Pricing: 'aAI190000004C98,aAI190000004C9I';
        try {
            Astrum_Contract__c contract = [SELECT Contract_Template_IDs__c FROM Astrum_Contract__c WHERE ID = :contractID LIMIT 1];
            templateIDs = contract.Contract_Template_IDs__c;
        } catch (Exception e){}
        String fileName = 'TestFile';   //Remember to URL encode
        String congaURL = base + '?SessionId=' + sessionID + '&ServerUrl=' + apiServerURL + '&Id=' + contractID + 
                        '&AttachmentParentId=' + contractID + '&TemplateId=' + templateIDs + '&DS7=1&DefaultPDF=1&OFN=' + fileName;
        return congaURL;
    }

    public PageReference switchProposal(){
        String newProposalID = ApexPages.currentPage().getParameters().get('proposalID');
        if (String.isBlank(newProposalID) || prop.ID == newProposalID)
            return null;

        //for (Proposal__c p : propList){
        //    if (newProposalID == p.ID){
        //        prop = p;
        //        break;
        //    }
        //}

        //saveProposalPDF();  //This might not insert a new Attachment, in which case, it will only update the value of "propPdfID"

        //queryContracts();

        //querySystemDesignItems();

        PageReference pg = new PageReference('/apex/PreviewProposal?id=' + newProposalID);
        pg.setRedirect(true);
        return pg;
    }

    public PageReference makeProposalCurrent(){
        String propID = ApexPages.currentPage().getParameters().get('proposalID');
        if (String.isBlank(propID))
            return null;

        Proposal__c prp;
        for (Proposal__c p : propList){
            if (propID == p.ID){
                prp = p;
                break;
            }
        }
        try {
            makeCurrentResult = SalesWorkflowValidationUtility.proposalWorkflowMakeCurrent(prp);
            PageReference pg = new PageReference('/apex/PreviewProposal?id=' + prp.ID);
            pg.setRedirect(true);
            return pg;
        } catch (Exception e){
            makeCurrentResult = e.getMessage();
            System.debug(e.getStackTraceString());
            return null;
        }
    }

    private System_Design_Product__c getSystemDesignProduct(String recordType){
        System_Design_Product__c prod = new System_Design_Product__c();     //Temp object for encapsulating data
        for (System_Design_Item__c sdi : sdItems){
            if (sdi.RecordType.DeveloperName == recordType && sdi.System_Design_Product__r.RecordType.DeveloperName == recordType){
                prod.Description__c = sdi.System_Design_Product__r.Description__c;
                break;
            }
        }
        return prod;
    }
    
    public System_Design_Product__c getPanelProduct(){
        return getSystemDesignProduct('Panel');
    }
    
    public System_Design_Product__c getInverterProduct(){
        return getSystemDesignProduct('Inverter');
    }

    public Property__c getProperty(){
        return prop.System_Design_Quote__r.System_Design__r.Property__r;
    }


    /*************************************/
    /* SIGHTEN METHODS                    /
    /*************************************/

    public Boolean displaySightenPopup {get;set;}
    public String buttonScenario {get;set;}

    public Boolean scenario1IsSighten {get;set;}
    public Boolean scenario2IsSighten {get;set;}
    public Boolean scenario3IsSighten {get;set;}
    public Boolean scenario4IsSighten {get;set;}

    public Sighten_Credit_Approval__c credit1 {get;set;}
    public Sighten_Credit_Approval__c credit2 {get;set;}
    public Sighten_Credit_Approval__c credit3 {get;set;}
    public Sighten_Credit_Approval__c credit4 {get;set;}

    public PageReference initiateCreditCheck(){
        Map<String, Id> scaLookupIds = SightenAPIIntegrator.GetLookupIdsForSightenCreditApprovals(prop.System_Design_Quote__c, Integer.valueOf(buttonScenario));
        String contactId = scaLookupIds.get('Contact');
        String leaseFundId = scaLookupIds.get('Lease_Fund__c');
        String propertyId = scaLookupIds.get('Property__c');

        SightenAPIHelper.SightenAPIHelperResponse sightenResponse = SightenAPIIntegrator.InitiateCreditCheck(prop.Id, Integer.valueOf(buttonScenario));
        SightenAPIHelper helper = new SightenAPIHelper();
        if(sightenResponse.responseStatusCode == 200){
            SightenAPICredit.SightenAPICreditList apiCreditList = (SightenAPICredit.SightenAPICreditList)helper.parseResponseBody(sightenResponse.responseBody, SightenAPICredit.SightenAPICreditList.class);
            // Create the Sighten_Credit_Approval__c

            Sighten_Credit_Approval__c sca = new Sighten_Credit_Approval__c(
                Sighten_Qualification_uuid__c = apiCreditList.data[0].uuid,
                Contact__c = contactId,
                Lease_Fund__c = leaseFundId,
                Property__c = propertyId,
                Credit_Status__c = 'INITIATED'
            );
            insert sca;

            if(buttonScenario == '1'){
                credit1 = sca;
            } else if(buttonScenario == '2'){
                credit2 = sca;
            } else if(buttonScenario == '3'){
                credit3 = sca;
            } else if(buttonScenario == '4'){
                credit4 = sca;
            }
            //writeMessage('apiQuote = ' + apiQuote);
        } else {
            SightenAPIEntity.SightenAPIErrorHelper errorHelper = (SightenAPIEntity.SightenAPIErrorHelper)helper.parseResponseBodyToError(sightenResponse.responseBody);
            if(errorHelper.errorResponse != null){
                String errorMessage = 'Scenario ' + buttonScenario + '<br/>Sighten API Error: ' + errorHelper.errorResponse.messages.error[0].message;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                showSightenPopup();
            } else if(errorHelper.errorResponseList != null){
                String errorMessage = 'Scenario ' + buttonScenario + '<br/>Sighten API Error: ' + errorHelper.errorResponseList.messages.error[0].message + '<br/>' + errorHelper.errorResponseList.data[0][0].rule.name + ', min: ' + errorHelper.errorResponseList.data[0][0].rule.min_bound + ', max: ' + errorHelper.errorResponseList.data[0][0].rule.max_bound + '<br/>Value(s): ' + errorHelper.errorResponseList.data[0][0].values;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                showSightenPopup();
            }
        }

/*        PageReference pr = Page.PreviewProposal;
        pr.getParameters().put('id', prop.Id);
        pr.setRedirect(true);
        return pr;*/
        return null;
    }

    public PageReference updateCreditStatus(){
        Map<String, Id> scaLookupIds = SightenAPIIntegrator.GetLookupIdsForSightenCreditApprovals(prop.System_Design_Quote__c, Integer.valueOf(buttonScenario));
        String contactId = scaLookupIds.get('Contact');
        String leaseFundId = scaLookupIds.get('Lease_Fund__c');
        String propertyId = scaLookupIds.get('Property__c');

        String sightenQualificationId = '';
        String currentStatus = '';
        String currentId = '';
        if(buttonScenario == '1'){
            sightenQualificationId = credit1.Sighten_Qualification_uuid__c;
            currentStatus = credit1.Credit_Status__c;
            currentId = credit1.Id;
        } else if(buttonScenario == '2'){
            sightenQualificationId = credit2.Sighten_Qualification_uuid__c;
            currentStatus = credit2.Credit_Status__c;
            currentId = credit2.Id;
        } else if(buttonScenario == '3'){
            sightenQualificationId = credit3.Sighten_Qualification_uuid__c;
            currentStatus = credit3.Credit_Status__c;
            currentId = credit3.Id;
        } else if(buttonScenario == '4'){
            sightenQualificationId = credit4.Sighten_Qualification_uuid__c;
            currentStatus = credit4.Credit_Status__c;
            currentId = credit4.Id;
        }

        SightenAPIHelper.SightenAPIHelperResponse sightenResponse = SightenAPIIntegrator.CheckCreditQualification(sightenQualificationId);
        SightenAPIHelper helper = new SightenAPIHelper();
        if(sightenResponse.responseStatusCode == 200){
            SightenAPICredit apiCredit = (SightenAPICredit)helper.parseResponseBody(sightenResponse.responseBody, SightenAPICredit.class);
            // Create the Sighten_Credit_Approval__c

            if(currentStatus == apiCredit.data.credit_qualifications[0].status.toUpperCase()){
                return null;
            } else {
                Sighten_Credit_Approval__c sca = new Sighten_Credit_Approval__c(
                    Id = currentId,
                    Credit_Status__c = apiCredit.data.credit_qualifications[0].status.toUpperCase()
                );
                update sca;
                
                if(buttonScenario == '1'){
                    credit1 = sca;
                } else if(buttonScenario == '2'){
                    credit2 = sca;
                } else if(buttonScenario == '3'){
                    credit3 = sca;
                } else if(buttonScenario == '4'){
                    credit4 = sca;
                }
            }

            //writeMessage('apiQuote = ' + apiQuote);
        } else {
            SightenAPIEntity.SightenAPIErrorHelper errorHelper = (SightenAPIEntity.SightenAPIErrorHelper)helper.parseResponseBodyToError(sightenResponse.responseBody);
            if(errorHelper.errorResponse != null){
                String errorMessage = 'Scenario ' + buttonScenario + '<br/>Sighten API Error: ' + errorHelper.errorResponse.messages.error[0].message;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                showSightenPopup();
            } else if(errorHelper.errorResponseList != null){
                String errorMessage = 'Scenario ' + buttonScenario + '<br/>Sighten API Error: ' + errorHelper.errorResponseList.messages.error[0].message + '<br/>' + errorHelper.errorResponseList.data[0][0].rule.name + ', min: ' + errorHelper.errorResponseList.data[0][0].rule.min_bound + ', max: ' + errorHelper.errorResponseList.data[0][0].rule.max_bound + '<br/>Value(s): ' + errorHelper.errorResponseList.data[0][0].values;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                showSightenPopup();
            }
        }
        return null;
    }

    public void showSightenPopup(){        
        displaySightenPopup = true;
    }

    public void closeSightenPopup(){
        displaySightenPopup = false;
    }
}