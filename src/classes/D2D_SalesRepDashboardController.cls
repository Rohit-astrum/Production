/* FILE: D2D_SalesRepDashboardController.cls 
 * AUTHOR: Stephanie Pratt
 * DATE: Aug 7, 2015
 * PURPOSE: Controller for D2D_SalesRepDashboard page, D2D_SalesRepDashboardPrint page, and D2D_SalesRepDashboardExport page
 *          Displays dashboard in the employee portal user's account
 * MODIFICATION HISTORY
 * 
 */
 
public class D2D_SalesRepDashboardController extends D2D_BaseReferralController{
    
    public override Boolean getIdRequired(){
        return false;
    }

    public Boolean allowLeadCreation {
        get { return D2D_Utility.d2dSettings.Allow_Lead_Creation__c; }
    } 
    
    private static final Integer PAGE_SIZE = 20;
    
    
    public Integer totalReferrals { get; private set; } 
    public Integer totalOpen { get; private set; }
    public Integer totalQualified { get; private set; }
    public Integer totalSold { get; private set; }
    public List<SelectOption> carrierRoutes {get;private set;}
    public D2D_User_Session_Filter__c userSessionFilter {get; set;}
    public Integer scrollYPos { get; set; } 
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
    public String segmentFilterOption { 
        get; 
        set {
            if (segmentFilterOption != value) {
                segmentFilterOption = value;
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
    public String statusFilterOption {
        get;
        set {
            if(statusFilterOption != value) {
                statusFilterOption = value;
                filterChanged = true;
            }
        }
    }
    public String systemSizeFilterOption {
        get;
        set {
            if(systemSizeFilterOption != value) {
                systemSizeFilterOption = value;
                filterChanged = true;
            }
        }
    }
    public String carrierRouteFilterOption {
        get;
        set {
            if(carrierRouteFilterOption != value) {
                carrierRouteFilterOption = value;
                filterChanged = true;
            }
        }
    }
    public String streetArg { 
        get; 
        set {
            if (streetArg != value) {
                streetArg = value;
                filterChanged = true;
            }
        } 
    }
    public String cityArg { 
        get; 
        set {
            if (cityArg != value) {
                cityArg = value;
                filterChanged = true;
            }
        } 
    }
    public String zipArg { 
        get; 
        set {
            if (zipArg != value) {
                zipArg = value;
                filterChanged = true;
            }
        } 
    }
    public String searchArg { 
        get; 
        set {
            if (searchArg != value) {
                searchArg = value;
                filterChanged = true;
            }
        } 
    }
    
    //private Boolean filterChanged = false;
    
    private Boolean filterChanged {
        get;
        set {
            filterChanged = value;
            if (filterChanged) {
                carrierRoutes = GetCarrierRouteList();
            }
        }
    }
    
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

    public List<SelectOption> statusFilterOptions {
        get { return D2D_Utility.GetPicklistOptions(Portal_Referral__c.D2D_Lead_Status__c.getDescribe(), true, '--ALL--', 'entire'); }
    }

    public List<SelectOption> systemSizeFilterOptions {
        get { return D2D_Utility.GetPicklistOptions(Portal_Referral__c.D2D_System_Size__c.getDescribe(), true, '--ALL--', 'entire'); }
    }
    
    private List<SelectOption> GetCarrierRouteList() {
            
            List<SelectOption> result = new List<SelectOption>();
            Set<string>routeSet = new set<string>();
            List<Portal_Referral__c> prList = new List<Portal_Referral__c>();
            
            String selectPart = 'SELECT Id, Full_Name__c, ' 
                + 'Street__c, City__c, State__c, Zip__c, Carrier_Route__c, Walk_Sequence__c, Phone__c, Email__c, CreatedDate, '
                + 'Segment_Priority__c, D2D_Lead_Status__c, D2D_Sales_Rep__c, D2D_System_Size__c, '
                + 'Lead_Created_Date__c, D2D_Scheduled_Visit_Datetime__c ';
            String query =
                + 'FROM Portal_Referral__c '
                + 'WHERE Status__c <> \'Duplicate\' '
                + 'AND Carrier_Route__c != Null '
                + 'AND D2D_Sales_Rep__c = \'' + UserInfo.getUserId() + '\'';
            if(onlyScheduledVisits){
                query += ' AND D2D_Scheduled_Visit_Datetime__c != null';
                if (dateFilterOption != null && dateFilterOption.trim() != '' && dateFilterOption != 'custom' && dateFilterOption != 'entire') {
                    query += ' AND D2D_Scheduled_Visit_Datetime__c = ' + dateFilterOption + ' ';
                } else {
                    query += ' AND D2D_Scheduled_Visit_Datetime__c > TODAY';
                }
            } else {
                if (dateFilterOption != null && dateFilterOption.trim() != '' && dateFilterOption != 'custom' && dateFilterOption != 'entire') {
                    query += ' AND Lead_Created_Date__c = ' + dateFilterOption + ' ';
                }
            }
            if (segmentFilterOption != null && segmentFilterOption.trim() != '' && segmentFilterOption != 'entire') {
                query += ' AND Segment_Priority__c = \'' + segmentFilterOption + '\' ';
            }
            /*if (carrierRouteFilterOption != null && carrierRouteFilterOption.trim() != '' && carrierRouteFilterOption != 'entire') {
                query += ' AND Carrier_Route__c = \'' + carrierRouteFilterOption + '\' ';
            }*/
            if (stateFilterOption != null && stateFilterOption.trim() != '' && stateFilterOption != 'entire') {
                query += ' AND State__c = \'' + stateFilterOption + '\' ';
            }
            if (statusFilterOption != null && statusFilterOption.trim() != '' && statusFilterOption != 'entire') {
                query += ' AND D2D_Lead_Status__c = \'' + statusFilterOption + '\' ';
            }
            if (systemSizeFilterOption != null && systemSizeFilterOption.trim() != '' && systemSizeFilterOption != 'entire') {
                query += ' AND D2D_System_Size__c = \'' + systemSizeFilterOption + '\' ';
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
            
            prList = Database.query(selectPart + query);
            
            result.add(new SelectOption('entire', '--ALL--'));
            
            for(Portal_Referral__c pr : prList) {
                if(!routeSet.contains(pr.Carrier_Route__c)) { 
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
                //currentPage = 1;
            }            
            sortExpression = value;
        }
    }
    public String sortDirection { get; private set; }

    private Id userId;
    
    public D2D_SalesRepDashboardController() {
        try{
        	
        	scrollYPos =0;
/*            User u = [SELECT Id, ContactId, CreatedDate FROM User WHERE Id = :UserInfo.getUserId()];
            userId = u.Id;
            AggregateResult[] minLeadDate = 
                [SELECT MIN(Lead_Created_Date__c) sinceDate 
                FROM Portal_Referral__c
                WHERE D2D_Sales_Rep__c = :userId
                AND Lead_Created_Date__c <> NULL 
                AND Status__c <> 'Duplicate'];
*/
            sortExpression = 'Lead_Created_Date__c';
            sortDirection = 'DESC';
            /*currentPage = 1;
            if (ApexPages.currentPage().getUrl() == Page.EP_MyDashboard.getUrl()) {
                rowLimit = PAGE_SIZE;
            } else {
                rowLimit = -1;
            }*/
            rowLimit = -1;
            onlyScheduledVisits = false;
            filterChanged = false;
            //populateSummary();
            carrierRoutes = GetCarrierRouteList();

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
                    
                    onlyScheduledVisits = Boolean.valueOf(savedFilters.get('onlyScheduledVisits'));
                    dateFilterOption = savedFilters.get('date');
                    streetArg = savedFilters.get('street');
                    cityArg = savedFilters.get('city');
                    stateFilterOption = savedFilters.get('state');
                    zipArg = savedFilters.get('zip');
                    carrierRouteFilterOption = savedFilters.get('carrierRoute');
                    statusFilterOption = savedFilters.get('status');
                    systemSizeFilterOption = savedFilters.get('systemSize');
                    searchArg = savedFilters.get('search');
                    scrollYPos = (savedFilters.get('scrollPos') != null) ? Integer.valueOf(savedFilters.get('scrollPos')) : 0;
                    sortExpression =  (savedFilters.get('sortExp') != null) ? savedFilters.get('sortExp') : 'Lead_Created_Date__c';
                    sortDirection = (savedFilters.get('sortDir') != null) ? savedFilters.get('sortDir') : 'DESC';
                }
            } 
            
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }
    }
    
/*    private void populateSummary() {
        totalReferrals = 
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
    }*/

//TODO: error handing
    public List<Portal_Referral__c> referrals {
        get {
            List<Portal_Referral__c> result = new List<Portal_Referral__c>();
            try{
                String selectPart = 'SELECT Id, Full_Name__c, ' 
                    + 'Street__c, City__c, State__c, Zip__c, Carrier_Route__c, Walk_Sequence__c, Phone__c, Email__c, CreatedDate, '
                    + 'Segment_Priority__c, D2D_Lead_Status__c, D2D_Sales_Rep__c, D2D_System_Size__c, '
                    + 'Lead_Created_Date__c, D2D_Scheduled_Visit_Datetime__c ';
                String query =
                    + 'FROM Portal_Referral__c '
                    + 'WHERE Status__c <> \'Duplicate\' '
                    + 'AND D2D_Sales_Rep__c = \'' + UserInfo.getUserId() + '\'';
                if(onlyScheduledVisits){
                    query += ' AND D2D_Scheduled_Visit_Datetime__c != null';
                    if (dateFilterOption != null && dateFilterOption.trim() != '' && dateFilterOption != 'custom' && dateFilterOption != 'entire') {
                        query += ' AND D2D_Scheduled_Visit_Datetime__c = ' + dateFilterOption + ' ';
                    } else {
                        query += ' AND D2D_Scheduled_Visit_Datetime__c > TODAY';
                    }
                } else {
                    if (dateFilterOption != null && dateFilterOption.trim() != '' && dateFilterOption != 'custom' && dateFilterOption != 'entire') {
                        query += ' AND Lead_Created_Date__c = ' + dateFilterOption + ' ';
                    }
                }
                if (segmentFilterOption != null && segmentFilterOption.trim() != '' && segmentFilterOption != 'entire') {
                    query += ' AND Segment_Priority__c = \'' + segmentFilterOption + '\' ';
                }
                if (carrierRouteFilterOption != null && carrierRouteFilterOption.trim() != '' && carrierRouteFilterOption != 'entire') {
                    query += ' AND Carrier_Route__c = \'' + carrierRouteFilterOption + '\' ';
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
                if (streetArg != null && streetArg.trim() != '') {
                    query += ' AND Street__c LIKE \'%' + String.escapeSingleQuotes(streetArg.replace('*','%')) + '%\'';
                }
                if (cityArg != null && cityArg.trim() != '') {
                    query += ' AND City__c LIKE \'%' + String.escapeSingleQuotes(cityArg.replace('*','%')) + '%\'';
                }
                if (zipArg != null && zipArg.trim() != '') {
                    query += ' AND Zip__c LIKE \'%' + String.escapeSingleQuotes(zipArg.replace('*','%')) + '%\'';
                }
                if (searchArg != null && searchArg.trim() != '') {
                    query += ' AND Full_Name__c LIKE \'%' + String.escapeSingleQuotes(searchArg.replace('*','%')) + '%\''; 
                }
                String orderPart = ' ';
                if(onlyScheduledVisits){
                    orderPart += 'ORDER BY D2D_Scheduled_Visit_Datetime__c DESC';
                }
                if (sortExpression != null) {
                    if(orderPart.contains('ORDER')){
                        orderPart += ', ';
                    } else {
                        orderPart += 'ORDER BY ';
                    }
                    orderPart += sortExpression + ' ' + sortDirection + ' NULLS LAST';
                }
                //if (rowLimit > 0) {
                    orderPart += ' LIMIT 800'; // + rowLimit;
                //}
              
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
    
    public PageReference saveUserFilters() {
        
        Map<String, String> filterMap = new Map<String, String>();
        filterMap.put('onlyScheduledVisits', String.valueOf(onlyScheduledVisits));
        filterMap.put('date', dateFilterOption);
        filterMap.put('street', streetArg);
        filterMap.put('city', cityArg);
        filterMap.put('state', stateFilterOption);
        filterMap.put('zip', zipArg);
        filterMap.put('carrierRoute', carrierRouteFilterOption);
        filterMap.put('status', statusFilterOption);
        filterMap.put('systemSize', systemSizeFilterOption);
        filterMap.put('search', searchArg);
        filterMap.put('scrollPos', String.valueOf(scrollYPos));
        filterMap.put('sortExp', sortExpression);
        filterMap.put('sortDir', sortDirection);
        
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