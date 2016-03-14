public without sharing class D2D_LeadScheduledVisitsController extends D2D_BaseReferralController {

    public override List<String> getPortalReferralFields(){
        return new List<String> {
            'D2D_Scheduled_Visit_Datetime__c',
            'D2D_Lead_Status__c',
            'Full_Name__c',
            'Id',
            'Lead__c',
            'Opportunity__c',
            'D2D_Visit_Scheduled__c'
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
            'StageName'
        };
    }

    private static final Integer PAGE_SIZE = 20;

    public Integer totalReferrals { get; private set; }
    public Integer totalOpen { get; private set; }
    public Integer totalQualified { get; private set; }
    public Integer totalSold { get; private set; }
    /*public Integer[] pages { get; private set; }
    public Integer totalPages { get; private set; }
    public Integer currentPage { 
        get; 
        set {
            if (value < 1) {
                currentPage = 1;
            } else if (value > totalPages) {
                currentPage = totalPages;
            } else {
                currentPage = value;
            }
        } 
    }*/
    public Integer rowLimit { get; set; }
    public Boolean onlyScheduledVisits { get; set; }
    public String dateFilterOption { 
        get; 
        set {
            if (dateFilterOption != value) {
                dateFilterOption = value;
                filterChanged = true;
            }
        } 
    }
    public String stateFilterOption { 
        get; 
        set {
            if (stateFilterOption != value) {
                stateFilterOption = value;
                filterChanged = true;
            }
        } 
    }
    
    private Boolean filterChanged = false;
    
    public List<SelectOption> dateFilterOptions {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('entire', '--ALL--'));
            result.add(new SelectOption('TODAY', 'TODAY'));
            result.add(new SelectOption('YESTERDAY', 'YESTERDAY'));
            result.add(new SelectOption('TOMORROW', 'TOMORROW'));
            result.add(new SelectOption('LAST_N_DAYS:7', 'LAST 7 DAYS'));
            result.add(new SelectOption('NEXT_N_DAYS:7', 'NEXT 7 DAYS'));
            result.add(new SelectOption('THIS_MONTH', 'THIS MONTH'));
            result.add(new SelectOption('LAST_MONTH', 'LAST MONTH'));
            result.add(new SelectOption('LAST_N_DAYS:91', 'LAST 3 MONTHS'));
            result.add(new SelectOption('LAST_N_DAYS:182', 'LAST 6 MONTHS'));
            result.add(new SelectOption('THIS_YEAR', 'THIS YEAR'));
            result.add(new SelectOption('LAST_YEAR', 'LAST YEAR'));
            return result;
        }
    }
    
    public List<SelectOption> stateFilterOptions {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('entire', '--ALL--'));
            result.add(new SelectOption('AL', 'AL'));
            result.add(new SelectOption('AK', 'AK'));
            result.add(new SelectOption('AZ', 'AZ'));
            result.add(new SelectOption('AR', 'AR'));
            result.add(new SelectOption('CA', 'CA'));
            result.add(new SelectOption('CO', 'CO'));
            result.add(new SelectOption('CT', 'CT'));
            result.add(new SelectOption('DC', 'DC'));
            result.add(new SelectOption('DE', 'DE'));
            result.add(new SelectOption('FL', 'FL'));
            result.add(new SelectOption('GA', 'GA'));
            result.add(new SelectOption('HI', 'HI'));
            result.add(new SelectOption('ID', 'ID'));
            result.add(new SelectOption('IL', 'IL'));
            result.add(new SelectOption('IN', 'IN'));
            result.add(new SelectOption('IA', 'IA'));
            result.add(new SelectOption('KS', 'KS'));
            result.add(new SelectOption('KY', 'KY'));
            result.add(new SelectOption('LA', 'LA'));
            result.add(new SelectOption('ME', 'ME'));
            result.add(new SelectOption('MD', 'MD'));
            result.add(new SelectOption('MA', 'MA'));
            result.add(new SelectOption('MI', 'MI'));
            result.add(new SelectOption('MN', 'MN'));
            result.add(new SelectOption('MS', 'MS'));
            result.add(new SelectOption('MO', 'MO'));
            result.add(new SelectOption('MT', 'MT'));
            result.add(new SelectOption('NE', 'NE'));
            result.add(new SelectOption('NV', 'NV'));
            result.add(new SelectOption('NH', 'NH'));
            result.add(new SelectOption('NJ', 'NJ'));
            result.add(new SelectOption('NM', 'NM'));
            result.add(new SelectOption('NY', 'NY'));
            result.add(new SelectOption('NC', 'NC'));
            result.add(new SelectOption('ND', 'ND'));
            result.add(new SelectOption('OH', 'OH'));
            result.add(new SelectOption('OK', 'OK'));
            result.add(new SelectOption('OR', 'OR'));
            result.add(new SelectOption('PA', 'PA'));
            result.add(new SelectOption('RI', 'RI'));
            result.add(new SelectOption('SC', 'SC'));
            result.add(new SelectOption('SD', 'SD'));
            result.add(new SelectOption('TN', 'TN'));
            result.add(new SelectOption('TX', 'TX'));
            result.add(new SelectOption('UT', 'UT'));
            result.add(new SelectOption('VT', 'VT'));
            result.add(new SelectOption('VA', 'VA'));
            result.add(new SelectOption('WA', 'WA'));
            result.add(new SelectOption('WV', 'WV'));
            result.add(new SelectOption('WI', 'WI'));
            result.add(new SelectOption('WY', 'WY'));
            return result;
        }
    }
    
    public String sortExpression {
        get;             
        set {
            if (value == sortExpression) {
                sortDirection = sortDirection == 'ASC' ? 'DESC' : 'ASC';
            } else {
                sortDirection = 'ASC';
                //currentPage = 1;
            }            
            sortExpression = value;
        }
    }
    public String sortDirection { get; private set; }

    private Id userId;

    public String dateText {get;set;}
    public String hourText {get;set;}
    public String minuteText {get;set;}
    public String ampmText {get;set;}
	
    public D2D_LeadScheduledVisitsController() {
        try{
/*            User u = [SELECT Id, ContactId, CreatedDate FROM User WHERE Id = :UserInfo.getUserId()];
            userId = u.Id;
            AggregateResult[] minLeadDate = 
                [SELECT MIN(Lead_Created_Date__c) sinceDate 
                FROM Portal_Referral__c
                WHERE D2D_Sales_Rep__c = :userId
                AND Lead_Created_Date__c <> NULL 
                AND Status__c <> 'Duplicate'];
*/
            sortExpression = 'D2D_Scheduled_Visit_Datetime__c';
            sortDirection = 'ASC';
            /*currentPage = 1;
            if (ApexPages.currentPage().getUrl() == Page.EP_MyDashboard.getUrl()) {
                rowLimit = PAGE_SIZE;
            } else {
                rowLimit = -1;
            }*/
            rowLimit = -1;
            onlyScheduledVisits = true;
            //populateSummary();
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }
    }
    
    private void populateSummary() {
/*        totalReferrals = 
            [SELECT count() 
            FROM Portal_Referral__c 
            WHERE D2D_Sales_Rep__c = :userId 
            AND Status__c <> 'Duplicate'];
        if (totalReferrals != null && totalReferrals > PAGE_SIZE) {
            totalPages = Math.ceil(totalReferrals * 1.0 / PAGE_SIZE).intValue();
            pages = new Integer[totalPages];
            for (Integer i = 0; i < totalPages; i++) {
                pages[i] = i + 1;
            } 
        }

        //get totals by status  
        totalOpen = totalQualified = totalSold = 0; 
        AggregateResult[] statusSummary = 
            [SELECT Status__c status, count(Id) cnt 
            FROM Portal_Referral__c 
            WHERE D2D_Sales_Rep__c = :userId
            AND Status__c != NULL 
            AND Status__c IN ('OPEN', 'QUALIFIED', 'SOLD')
            GROUP BY Status__c];
        for (AggregateResult ar : statusSummary) {
            String status = (String)ar.get('status');
            Decimal cnt = (Decimal)ar.get('cnt');
            if (status != null && cnt != null) {
                if (status == 'OPEN') {
                    totalOpen = cnt.intValue();
                } else if (status == 'QUALIFIED') {
                    totalQualified = cnt.intValue();
                } else if (status == 'SOLD') {
                    totalSold = cnt.intValue();
                }
            }
        }
*/
    }

//TODO: error handing
    public List<Portal_Referral__c> referrals {
        get {
            List<Portal_Referral__c> result = new List<Portal_Referral__c>();
            try{
                String selectPart = 'SELECT Id, Full_Name__c, ' 
                    + 'Street__c, City__c, State__c, Zip__c, Phone__c, Email__c, CreatedDate, '
                    + 'D2D_Lead_Status__c, D2D_Manager__c, D2D_Sales_Rep__c, '
                    + 'Lead_Created_Date__c, D2D_Scheduled_Visit_Datetime__c ';
                String query =
                    + 'FROM Portal_Referral__c '
                    + 'WHERE Status__c <> \'Duplicate\' '
                    + 'AND ((D2D_Manager__c = \'' + UserInfo.getUserId() + '\' AND (D2D_Sales_Rep__c = null OR D2D_Sales_Rep__c = \'\')) OR D2D_Sales_Rep__c = \'' + UserInfo.getUserId() + '\')';
                if(onlyScheduledVisits){
                    query += ' AND D2D_Scheduled_Visit_Datetime__c != null';
                    if (dateFilterOption != null && dateFilterOption.trim() != '' && dateFilterOption != 'custom' && dateFilterOption != 'entire') {
                        query += ' AND D2D_Scheduled_Visit_Datetime__c = ' + dateFilterOption + ' ';
                    } else {
                        query += ' AND D2D_Scheduled_Visit_Datetime__c >= TODAY';
                    }
                } else {
                    if (dateFilterOption != null && dateFilterOption.trim() != '' && dateFilterOption != 'custom' && dateFilterOption != 'entire') {
                        query += ' AND Lead_Created_Date__c = ' + dateFilterOption + ' ';
                    }
                }
                if (stateFilterOption != null && stateFilterOption.trim() != '' && stateFilterOption != 'entire') {
                    query += ' AND State__c = \'' + stateFilterOption + '\' ';
                }
                String orderPart = ' ';
                /*if(onlyScheduledVisits){
                    orderPart += 'ORDER BY D2D_Scheduled_Visit_Datetime__c DESC';
                }*/
                if (sortExpression != null) {
                    if(orderPart.contains('ORDER')){
                        orderPart += ', ';
                    } else {
                        orderPart += 'ORDER BY ';
                    }
                    orderPart += sortExpression + ' ' + sortDirection + ' NULLS LAST';
                }
                if (rowLimit > 0) {
                    orderPart += ' LIMIT ' + rowLimit;
                }
              
                if (filterChanged == true) {
                    filterChanged = false;
                }

                result = Database.query(selectPart + query + orderPart);
            } catch (Exception ex){
                ApexPages.addMessages(ex);
                stackTrace = ex.getStackTraceString();
            }
            return result;
        }
    }
    
    public PageReference refresh() {
        return null;
    }

    private void grabPostData() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        dateText = params.get('dateText');
        hourText = params.get('selectHour');
        minuteText = params.get('selectMinute');
        ampmText = params.get('selectAmPm');
    }

    public PageReference schedule(){
        try{
            grabPostData();
            Date tempDate = Date.parse(dateText.replace('-', '/'));
            Integer hourOffset = 0;
            if (ampmText == 'PM') { hourOffset = 12; }
            referral.D2D_Scheduled_Visit_Datetime__c = Datetime.newInstance(tempDate.year(), tempDate.month(), tempDate.day(), Integer.valueOf(hourText) + hourOffset, Integer.valueOf(minuteText), 0);
			if(scheduledVisitsState!='completed'){
            	referral.D2D_Lead_Status__c = 'Visit Scheduled';
			}
            referral.D2D_Visit_Scheduled__c = true;
            update referral;
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }

        return null;
    }
}