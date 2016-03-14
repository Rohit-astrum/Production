/* FILE: EP_MyDashboardController.cls
 * AUTHOR: Tino Mattheou
 * DATE: December 14, 2012
 * PURPOSE: Controller for D2D_ManagerDashboard page, D2D_ManagerDashboardPrint page, and D2D_ManagerDashboardExport page
 *          Displays dashboard in the employee portal user's account
 * MODIFICATION HISTORY
 * 
 */
 
public class D2D_ManagerDashboardController extends D2D_BaseReferralController{

    public override Boolean getIdRequired(){
        return false;
    }

    public Boolean allowLeadCreation {
        get { return D2D_Utility.d2dSettings.Allow_Lead_Creation__c; }
    } 

    //private static final Integer PAGE_SIZE = 800;

    //public Integer totalReferrals { get; private set; }
    //public Integer totalOpen { get; private set; }
    //public Integer totalQualified { get; private set; }
    //public Integer totalSold { get; private set; }
    public Integer rowLimit { get; set; }
    public Integer currentPage { get; set; }
    public Boolean isLastPage { get; set; }
    public List<SelectOption> carrierRoutes {get;private set;}
    public D2D_User_Session_Filter__c userSessionFilter {get; set;}
    public Integer scrollYPos { get; set; } 
    public String dateFilterOption { 
        get; 
        set {
            if (dateFilterOption != value) {
                dateFilterOption = value;
                //filterChanged = true;
            }
        } 
    }
    public String segmentFilterOption { 
        get; 
        set {
            if (segmentFilterOption != value) {
                segmentFilterOption = value;
                //filterChanged = true;
            }
        } 
    }
    public String stateFilterOption { 
        get; 
        set {
            if (stateFilterOption != value) {
                stateFilterOption = value;
                //filterChanged = true;
            }
        } 
    }
    public String statusFilterOption {
        get;
        set {
            if(statusFilterOption != value) {
                statusFilterOption = value;
                //filterChanged = true;
            }
        }
    }
    public String systemSizeFilterOption {
        get;
        set {
            if(systemSizeFilterOption != value) {
                systemSizeFilterOption = value;
                //filterChanged = true;
            }
        }
    }
    public String managerFilterOption {
        get;
        set {
            if(managerFilterOption != value) {
                managerFilterOption = value;
                //filterChanged = true;
            }
        }
    }
    public String salesRepFilterOption {
        get;
        set {
            if(salesRepFilterOption != value) {
                salesRepFilterOption = value;
                //filterChanged = true;
            }
        }
    }
    public String carrierRouteFilterOption {
        get;
        set {
            if(carrierRouteFilterOption != value) {
                carrierRouteFilterOption = value;
                //filterChanged = true;
            }
        }
    }
    public String streetArg { 
        get; 
        set {
            if (streetArg != value) {
                streetArg = value;
                //filterChanged = true;
            }
        } 
    }
    public String cityArg { 
        get; 
        set {
            if (cityArg != value) {
                cityArg = value;
                //filterChanged = true;
            }
        } 
    }
    public String zipArg { 
        get; 
        set {
            if (zipArg != value) {
                zipArg = value;
                //filterChanged = true;
            }
        } 
    }
    public String searchArg { 
        get; 
        set {
            if (searchArg != value) {
                searchArg = value;
                //filterChanged = true;
            }
        } 
    }
    public String displayAssigned { 
        get;
        set {
            if (displayAssigned != value) {
                displayAssigned = value;
                //filterChanged = true;
            }
        } 
    }
/*    public String displaySubOwned { 
        get;
        set {
            if (displaySubOwned != value) {
                displaySubOwned = value;
                //filterChanged = true;
            }
        } 
    }*/
    public String assignedManagerOption {
        get;
        set {
            if (assignedManagerOption != value) {
                assignedManagerOption = value;
            }
        }
    }
    public String assignedSalesRepOption {
        get;
        set {
            if (assignedSalesRepOption != value) {
                assignedSalesRepOption = value;
            }
        }
    }
    
    private Boolean filterChanged {
        get;
        set {
            filterChanged = value;
            if (filterChanged && allowFiltering) {
                referrals = GetWrapperList();
    			carrierRoutes = GetCarrierRouteList();
            }
        }
    }

    public List<SelectOption> rowLimitOptions {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('10', '10'));
            result.add(new SelectOption('25', '25'));
            result.add(new SelectOption('50', '50'));
            result.add(new SelectOption('100', '100'));
            return result;
        }
    }
    
    public List<SelectOption> dateFilterOptions {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('entire', '--ALL--'));
            result.add(new SelectOption('TODAY', 'TODAY'));
            result.add(new SelectOption('YESTERDAY', 'YESTERDAY'));
            result.add(new SelectOption('LAST_N_DAYS:7', 'LAST 7 DAYS'));
            result.add(new SelectOption('THIS_MONTH', 'THIS MONTH'));
            result.add(new SelectOption('LAST_MONTH', 'LAST MONTH'));
            result.add(new SelectOption('LAST_N_DAYS:91', 'LAST 3 MONTHS'));
            result.add(new SelectOption('LAST_N_DAYS:182', 'LAST 6 MONTHS'));
            result.add(new SelectOption('THIS_YEAR', 'THIS YEAR'));
            result.add(new SelectOption('LAST_YEAR', 'LAST YEAR'));
            return result;
        }
    }
    
    
    
    public List<Portal_Referral__c> selectedReferrals = new List<Portal_Referral__c>();
        
    public List<SelectOption> segmentFilterOptions {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('entire', '--ALL--'));
            result.add(new SelectOption('1', '1'));
            result.add(new SelectOption('2', '2'));
            result.add(new SelectOption('3', '3'));
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

    public List<SelectOption> managerFilterOptions {
        get {
            if(managerFilterOptions == null){
                List<SelectOption> result = new List<SelectOption>();
                result.add(new SelectOption('entire', '--None--'));
                for(User user : availableManagers.values()){
                    result.add(new SelectOption(user.Id, user.FirstName + ' ' + user.LastName));
                }
                managerFilterOptions = result;
            }
            return managerFilterOptions;
        }
        set;
    }

    public List<SelectOption> salesRepFilterOptions {
        get {
            if(salesRepFilterOptions == null){
                List<SelectOption> result = new List<SelectOption>();
                result.add(new SelectOption('entire', '--None--'));
                for(User user : availableSalesReps.values()){
                    result.add(new SelectOption(user.Id, user.FirstName + ' ' + user.LastName));
                }
                salesRepFilterOptions = result;
            }
            return salesRepFilterOptions;
        }
        set;
    }

    public List<SelectOption> assignedManagerOptions {
        get {
            if(assignedManagerOptions == null){
                List<SelectOption> result = new List<SelectOption>();
                result.add(new SelectOption('0', '--None--'));
                for(User user : availableManagers.values()){
                    result.add(new SelectOption(user.Id, user.FirstName + ' ' + user.LastName));
                }
                assignedManagerOptions = result;
            }
            return assignedManagerOptions;
        }
        set;
    }

    public List<SelectOption> assignedSalesRepOptions {
        get {
            if(assignedSalesRepOptions == null){
                List<SelectOption> result = new List<SelectOption>();
                result.add(new SelectOption('0', '--None--'));
                for(User user : availableSalesReps.values()){
                    result.add(new SelectOption(user.Id, user.FirstName + ' ' + user.LastName));
                }
                assignedSalesRepOptions = result;
            }
            return assignedSalesRepOptions;
        }
        set;
    }
    
    public List<SelectOption> statusFilterOptions {
        get { return D2D_Utility.GetPicklistOptions(Portal_Referral__c.D2D_Lead_Status__c.getDescribe(), true, '--ALL--', 'entire'); }
    }

    public List<SelectOption> systemSizeFilterOptions {
        get { return D2D_Utility.GetPicklistOptions(Portal_Referral__c.D2D_System_Size__c.getDescribe(), true, '--ALL--', 'entire'); }
    }

    
   	private List<SelectOption> GetCarrierRouteList() {
        	
            List<SelectOption> result = new List<SelectOption>();
            List<Portal_Referral__c> prList = new List<Portal_Referral__c>();
            
            List<String> fieldset = new List<String> { 'Id', 'Carrier_Route__c' };
            String query = ConstructQuery(fieldset, false);
            
            prList = Database.query(query);
            
            result.add(new SelectOption('entire', '--ALL--'));
            
            Set<String> routeSet = new Set<String>();
            for(Portal_Referral__c pr : prList) {
                if(!routeSet.contains(pr.Carrier_Route__c) && pr.Carrier_Route__c != null)
                { 
                    routeSet.add(pr.Carrier_Route__c);
                	result.add(new SelectOption(pr.Carrier_Route__c,pr.Carrier_Route__c));
                }     
            }
            
             if(carrierRouteFilterOption != null && carrierRouteFilterOption.trim() != '' && carrierRouteFilterOption != 'entire') { 
            	if(!routeSet.contains(carrierRouteFilterOption)) {
                	routeSet.add(carrierRouteFilterOption);
                	result.add(new SelectOption(carrierRouteFilterOption,carrierRouteFilterOption));
            	}
            } 
            
            return result;
    }

    public String sortExpression {
        get;             
        set {
            if (value == sortExpression) {
                sortDirection = sortDirection == 'ASC' ? 'DESC' : 'ASC';
            } else {
                sortDirection = 'ASC';
            }            
            sortExpression = value;
            currentPage = 0;
        }
    }
    public String sortDirection { get; private set; }

    private Id userId;

    public List<PortalReferralWrapper> referrals {get;private set;}
    private Map<Id, User> availableManagers {get;private set;}
    private Map<Id, User> availableSalesReps {get;private set;}

    private Boolean allowFiltering = false;
    public Boolean showManagerFilter { get;private set; }

    public D2D_ManagerDashboardController() {
        try{
            if(D2D_Utility.CurrentUserIsD2DAdmin){
                availableManagers = new Map<Id, User>([SELECT Id, FirstName, LastName, Email FROM User WHERE Profile.Name = 'D2D Admin' OR Profile.Name = 'D2D Manager']);
                availableSalesReps = new Map<Id, User>([SELECT Id, FirstName, LastName, Email FROM User WHERE Profile.Name = 'D2D Sales Rep']);
                showManagerFilter = true;
            } else {
                availableManagers = new Map<Id, User>([SELECT Id, FirstName, LastName, Email FROM User WHERE Profile.Name = 'D2D Manager' AND CompanyName = :D2D_Utility.CurrentUserCompanyName]);
                availableSalesReps = new Map<Id, User>([SELECT Id, FirstName, LastName, Email FROM User WHERE Profile.Name = 'D2D Sales Rep' AND D2D_Manager__c = :UserInfo.getUserId() AND CompanyName = :D2D_Utility.CurrentUserCompanyName]);
                showManagerFilter = false;
            }

            displayAssigned = 'false';
            searchArg = '';

            //system.debug('**SZ: getting user');
            
/*          User u = [SELECT Id, ContactId, CreatedDate FROM User WHERE Id = :UserInfo.getUserId()];
            userId = u.Id;
            AggregateResult[] minLeadDate = 
                [SELECT MIN(Lead_Created_Date__c) sinceDate 
                FROM Portal_Referral__c
                WHERE D2D_Manager__c = :userId
                AND Lead_Created_Date__c <> NULL 
                AND Status__c <> 'Duplicate'];
*/
            sortExpression = 'Lead_Created_Date__c';
            sortDirection = 'DESC';
            rowLimit = 100;
            currentPage = 0;
            isLastPage = false;
            //populateSummary();

            filterChanged = false;

            allowFiltering = true;
    		
    		List<D2D_User_Session_Filter__c> userSessionFilterList =  
	            [SELECT Id, Email__c, Filter_Data__c, LastModifiedDate 
	            FROM D2D_User_Session_Filter__c 
	            WHERE Email__c = :UserInfo.getUserEmail() 
	            LIMIT 1];
	         
	        if(userSessionFilterList.size() == 1) {
	        	userSessionFilter = userSessionFilterList[0];
                
                String lastModifiedDate = userSessionFilter.LastModifiedDate.format('MM/dd/yyyy');
				Datetime todaysDateTime = Datetime.now();
				String todaysDate = todaysDateTime.format('MM/dd/yyyy');
            	
            	if(lastModifiedDate == todaysDate) {
            		
	            	Map<String, String> savedFilters = (Map<String, String>)JSON.deserialize(userSessionFilter.Filter_Data__c, Map<String, String>.class);

	            	dateFilterOption = savedFilters.get('date');
	            	streetArg = savedFilters.get('street');
	            	cityArg = savedFilters.get('city');
	            	stateFilterOption = savedFilters.get('state');
	            	zipArg = savedFilters.get('zip');
	            	carrierRouteFilterOption = savedFilters.get('carrierRoute');
	            	statusFilterOption = savedFilters.get('status');
	            	systemSizeFilterOption = savedFilters.get('systemSize');
	            	displayAssigned = savedFilters.get('displayAssigned');
	            	searchArg = savedFilters.get('search');
                    scrollYPos = (savedFilters.get('scrollPos') != null) ? Integer.valueOf(savedFilters.get('scrollPos')) : 0;
                    sortExpression =  (savedFilters.get('sortExp') != null) ? savedFilters.get('sortExp') : 'Lead_Created_Date__c';
                    sortDirection = (savedFilters.get('sortDir') != null) ? savedFilters.get('sortDir') : 'DESC';
                    rowLimit = (savedFilters.get('rowLimit') != null) ? Integer.valueOf(savedFilters.get('rowLimit')) : 100;
                    currentPage = (savedFilters.get('currentPage') != null) ? Integer.valueOf(savedFilters.get('currentPage')) : 0;
                    managerFilterOption =  savedFilters.get('currentManager');
                    salesRepFilterOption = savedFilters.get('currentSalesRep');
            	}
            } 
            
            referrals = GetWrapperList();
            
    		carrierRoutes = GetCarrierRouteList();
    		
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }
    }
    
/*    private void populateSummary() {
        totalReferrals = 
            [SELECT count() 
            FROM Portal_Referral__c 
            WHERE D2D_Manager__c = :userId 
            AND Status__c <> 'Duplicate'];
        

        //get totals by status  
        totalOpen = totalQualified = totalSold = 0; 
        AggregateResult[] statusSummary = 
            [SELECT Status__c status, count(Id) cnt 
            FROM Portal_Referral__c 
            WHERE D2D_Manager__c = :userId
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
    }*/

    private List<PortalReferralWrapper> GetWrapperList() {
        List<PortalReferralWrapper> retList = new List<PortalReferralWrapper>();
        try{
            List<Portal_Referral__c> result = new List<Portal_Referral__c>();
            List<String> fieldset = new List<String> {
                'Id', 'Full_Name__c', 'Street__c', 'City__c', 'State__c', 'Zip__c', 'Carrier_Route__c', 'Walk_Sequence__c', 'Phone__c', 'Email__c', 'CreatedDate',
                'Segment_Priority__c', 'D2D_Lead_Status__c', 'D2D_Manager__c', 'D2D_Manager__r.Name', 'D2D_Sales_Rep__c', 'D2D_Sales_Rep__r.Name',
                'Lead_Created_Date__c', 'D2D_System_Size__c'
            };
            String query = ConstructQuery(fieldset, true);
           
            if (filterChanged == true) {
                filterChanged = false;
            }

            result = Database.query(query);
            isLastPage = (result.size() < rowLimit);

            for(Portal_Referral__c pr : result) {
                retList.add(new PortalReferralWrapper(false, pr));
            }
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }
        return retList;
    }

    private String ConstructQuery(List<String> fieldset, Boolean usePaging){
        String selectPart = 'SELECT ' + String.join(fieldset, ',');
        String query =
            + ' FROM Portal_Referral__c'
            + ' WHERE Status__c <> \'Duplicate\' AND D2D_Lead_Status__c != null AND D2D_Lead_Status__c != \'\'';
        if(!D2D_Utility.CurrentUserIsD2DAdmin){
            query += ' AND D2D_Manager__c = \'' + UserInfo.getUserId() + '\'';
        }
        //system.debug('**SZ: manager filter option = ' + Option);
        if (managerFilterOption != null && managerFilterOption.trim() != '' && managerFilterOption != 'entire') {
            query += ' AND D2D_Manager__c = \'' + managerFilterOption + '\' ';
        }
        if (salesRepFilterOption != null && salesRepFilterOption.trim() != '' && salesRepFilterOption != 'entire') {
            query += ' AND D2D_Sales_Rep__c = \'' + salesRepFilterOption + '\' ';
        }
        if (displayAssigned == 'false') {
            query += ' AND D2D_Sales_Rep__c = Null ';
        }
        if (dateFilterOption != null && dateFilterOption.trim() != '' && dateFilterOption != 'custom' && dateFilterOption != 'entire') {
            query += ' AND Lead_Created_Date__c = ' + dateFilterOption + ' ';
        }
        if (segmentFilterOption != null && segmentFilterOption.trim() != '' && segmentFilterOption != 'entire') {
            query += ' AND Segment_Priority__c = \'' + segmentFilterOption + '\' ';
        }
        if (carrierRouteFilterOption != null && carrierRouteFilterOption.trim() != '' && carrierRouteFilterOption != 'entire') {
            query += ' AND Carrier_Route__c = \'' + carrierRouteFilterOption + '\' ';
        }
        if (streetArg != null && streetArg.trim() != '') {
            query += ' AND Street__c LIKE \'%' + String.escapeSingleQuotes(streetArg.replace('*','%')) + '%\'';
        }
        if (cityArg != null && cityArg.trim() != '') {
            query += ' AND City__c LIKE \'%' + String.escapeSingleQuotes(cityArg.replace('*','%')) + '%\'';
        }
        if (zipArg != null && zipArg.trim() != '') {
            query += ' AND Zip__c LIKE \'%' + String.escapeSingleQuotes(zipArg.replace('*','%')) + '%\'';
        }
        if (stateFilterOption != null && stateFilterOption.trim() != '' && stateFilterOption != 'entire') {
            query += ' AND State__c = \'' + stateFilterOption + '\' ';
        }
        if (statusFilterOption != null && statusFilterOption.trim() != '' && statusFilterOption != 'entire') {
            query += ' AND D2D_Lead_Status__c = \'' + statusFilterOption + '\' ';
        }
        if (systemSizeFilterOption != null && systemSizeFilterOption.trim() != '' && systemSizeFilterOption != 'entire') {
            query += ' AND D2D_System_Size__c = \'' + systemSizeFilterOption + '\' ';
        }
        if (searchArg != null && searchArg.trim() != '') {
            query += ' AND Full_Name__c LIKE \'%' + String.escapeSingleQuotes(searchArg.replace('*','%')) + '%\'';
        }

        String orderPart = '';
        String offsetPart = '';
        if(usePaging){
            if (sortExpression != null) {
                orderPart += ' ORDER BY ' + sortExpression + ' ' + sortDirection + ' NULLS LAST';
            }
            if (rowLimit > 0) {
                orderPart += ' LIMIT ' + rowLimit;
            }
            if(currentPage > 0){
                offsetPart = ' OFFSET ' + (rowLimit * currentPage);
            }
        } else {
            orderPart += ' LIMIT 45000';
        }

        return selectPart + query + orderPart + offsetPart;
    }
    
    public PageReference refresh() {
        filterChanged = true;
        return null;
    }

    public PageReference filter() {
        currentPage = 0;
        filterChanged = true;
        return null;
    }

    public PageReference prev() {
        currentPage--;
        filterChanged = true;
        return null;
    }

    public PageReference next() {
        if(!isLastPage){ currentPage++; }
        filterChanged = true;
        return null;
    }

    public void processSelected() {
        selectedReferrals.clear();
        for(PortalReferralWrapper prw : referrals){
            if(prw.Selected){
                selectedReferrals.add(prw.PortalReferral);
            }
        }
    }
    
    
    public PageReference assign() {
        Boolean isValid = true;
        if(assignedSalesRepOption == null || assignedSalesRepOption == '' || assignedSalesRepOption == '0'){
            ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.WARNING, 'You must select a sales rep to assign.'));
            isValid = false;
        } else {
            if(selectedReferrals.size() == 0){
                ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.WARNING, 'You must select at least one row to assign.'));
                isValid = false;
            }
        }

        if(isValid){
            try{
                for(Portal_Referral__c pr : selectedReferrals){
                    pr.D2D_Sales_Rep__c = assignedSalesRepOption;
                }
                update selectedReferrals;

                // Send email to the assignedSalesRepOption
                //SendEmail();
                displayAssigned = 'true';
                filterChanged = true;
            } catch (DmlException dmlex){
                ApexPages.addMessages(dmlex);
                stackTrace = dmlex.getStackTraceString();
            } catch (Exception ex){
                ApexPages.addMessages(ex);
                stackTrace = ex.getStackTraceString();
            }
        }
        
        currentPage = 0;
        return null;
    }
    
    public PageReference transfer() {
        Boolean isValid = true;
        if(assignedManagerOption == null || assignedManagerOption == '' || assignedManagerOption == '0'){
            ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.WARNING, 'You must select a manager to transfer.'));
            isValid = false;
        } else {
            if(selectedReferrals.size() == 0){
                ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.WARNING, 'You must select at least one row to transfer.'));
                isValid = false;
            }
        }

        if(isValid){
            try{
                for(Portal_Referral__c pr : selectedReferrals){
                    pr.D2D_Manager__c = assignedManagerOption;
                }
                update selectedReferrals;

                // Send email to the assignedManagerOption
                //SendEmail(true);
                filterChanged = true;
            } catch (DmlException dmlex){
                ApexPages.addMessages(dmlex);
                stackTrace = dmlex.getStackTraceString();
            } catch (Exception ex){
                ApexPages.addMessages(ex);
                stackTrace = ex.getStackTraceString();
            }
        }
        
        currentPage = 0;
        return null;
    }

/*    private void SendEmail(){
        SendEmail(false);
    }

    private void SendEmail(Boolean isForManager){
        ApexPages.Message message = null;
        if(isForManager){
            message = D2D_Utility.SendEmail('Notify D2D Manager', assignedManagerOption, null);
        } else {
            message = D2D_Utility.SendEmail('Notify D2D Sales Rep', assignedSalesRepOption, null);
        }
        if(message != null){
            ApexPages.addMessage(message);
        }
    }*/

    public class PortalReferralWrapper {
        public Boolean Selected {get;set;}
        public Portal_Referral__c PortalReferral {get;set;}

        public PortalReferralWrapper(Boolean sel, Portal_Referral__c pr) {
            this.Selected = sel;
            this.PortalReferral = pr;
        }
    }
    
     public PageReference saveUserFilters() {
    	
    	Map<String, String> filterMap = new Map<String, String>();
		
		filterMap.put('date', dateFilterOption);
		filterMap.put('street', streetArg);
		filterMap.put('city', cityArg);
		filterMap.put('state', stateFilterOption);
		filterMap.put('zip', zipArg);
		filterMap.put('carrierRoute', carrierRouteFilterOption);
		filterMap.put('status', statusFilterOption);
		filterMap.put('systemSize', systemSizeFilterOption);
		filterMap.put('displayAssigned', displayAssigned);
		filterMap.put('search', searchArg);
        filterMap.put('scrollPos', String.valueOf(scrollYPos));
        filterMap.put('sortExp', sortExpression);
        filterMap.put('sortDir', sortDirection);
        filterMap.put('rowLimit', String.valueOf(rowLimit));
        filterMap.put('currentPage', String.valueOf(currentPage));
        filterMap.put('currentManager', managerFilterOption);
        filterMap.put('currentSalesRep', salesRepFilterOption);
        
		
		String filterMapSerialized = JSON.serialize(filterMap);
		
		if(userSessionFilter != null && userSessionFilter.Filter_Data__c != null)
		{
			userSessionFilter.Filter_Data__c = filterMapSerialized;
			update userSessionFilter;
		}
		else
		{
			D2D_User_Session_Filter__c newUserSessionFilter = new D2D_User_Session_Filter__c(
				Filter_Data__c = filterMapSerialized,
				Email__c = UserInfo.getUserEmail()
			);
			upsert newUserSessionFilter;
		}
    	
        return null;
    }
}