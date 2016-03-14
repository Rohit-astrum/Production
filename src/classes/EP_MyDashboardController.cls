/* FILE: EP_MyDashboardController.cls
 * AUTHOR: Tino Mattheou
 * DATE: December 14, 2012
 * PURPOSE: Controller for EP_MyDashboard page, EP_DashboardPrint page, and EP_DashboardExport page
 *          Displays dashboard in the employee portal user's account
 * MODIFICATION HISTORY
 * 
 */
 
public class EP_MyDashboardController{
    
    private static final Integer PAGE_SIZE = 20;

    public Integer totalReferrals { get; private set; }
    public Integer totalOpen { get; private set; }
    public Integer totalQualified { get; private set; }
    public Integer totalSold { get; private set; }
    public Integer[] pages { get; private set; }
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
    }
    public Integer rowLimit { get; set; }
    public String filterOption { 
    	get; 
    	set {
    		if (filterOption != value) {
    			filterOption = value;
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
    
    private Boolean filterChanged = false;
    
    public List<SelectOption> filterOptions {
    	get {
    		List<SelectOption> result = new List<SelectOption>();
    		result.add(new SelectOption('', '-- Filter by Date --'));
    		//result.add(new SelectOption('custom', 'CUSTOM'));  //phase 2?
    		result.add(new SelectOption('TODAY', 'TODAY'));
    		result.add(new SelectOption('YESTERDAY', 'YESTERDAY'));
    		result.add(new SelectOption('LAST_N_DAYS:7', 'LAST 7 DAYS'));
    		result.add(new SelectOption('THIS_MONTH', 'THIS MONTH'));
    		result.add(new SelectOption('LAST_MONTH', 'LAST MONTH'));
    		result.add(new SelectOption('LAST_N_DAYS:91', 'LAST 3 MONTHS'));
    		result.add(new SelectOption('LAST_N_DAYS:182', 'LAST 6 MONTHS'));
    		result.add(new SelectOption('THIS_YEAR', 'THIS YEAR'));
    		result.add(new SelectOption('LAST_YEAR', 'LAST YEAR'));
    		result.add(new SelectOption('entire', 'ENTIRE TIME'));
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
                currentPage = 1;
            }            
            sortExpression = value;
        }
    }
    public String sortDirection { get; private set; }

    private Id accountId;
    
    public EP_MyDashboardController() {
        User u = [SELECT Id, ContactId, CreatedDate FROM User WHERE Id = :UserInfo.getUserId()];
        Contact c = [SELECT Id, AccountId FROM Contact WHERE Id = :u.ContactId];
        accountId = c.AccountId;
        AggregateResult[] minLeadDate = 
            [SELECT MIN(Lead_Created_Date__c) sinceDate 
            FROM Portal_Referral__c
            WHERE Account__c = :accountId
            AND Lead_Created_Date__c <> NULL 
            AND Status__c <> 'Duplicate'];
        sortExpression = 'Lead_Created_Date__c';
        sortDirection = 'DESC';
        currentPage = 1;
        if (ApexPages.currentPage().getUrl() == Page.EP_MyDashboard.getUrl()) {
            rowLimit = PAGE_SIZE;
        } else {
            rowLimit = -1;
        }
        populateSummary();
    }
    
    private void populateSummary() {
        totalReferrals = 
            [SELECT count() 
            FROM Portal_Referral__c 
            WHERE Account__c = :accountId 
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
            WHERE Account__c = :accountId
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
    }

//TODO: error handing
    public List<Portal_Referral__c> referrals {
        get {
            List<Portal_Referral__c> result = new List<Portal_Referral__c>();
            String selectPart = 'SELECT Id, Full_Name__c, Status__c, Detail__c, Lead_Source__c, ' 
                + 'Street__c, City__c, State__c, Zip__c, Phone__c, Email__c, CreatedDate, '
                + 'Mobile_Phone__c, Work_Phone__c, Primary_Phone__c, '
                + 'Referral_Earnings__c, Lead_Created_Date__c, Method_of_Contact__c, '
                + 'Self_Generated__c ';
            String query =
                + 'FROM Portal_Referral__c '
                + 'WHERE Account__c = :accountId '
                + ' AND Status__c <> \'Duplicate\' ';
            if (filterOption != null && filterOption.trim() != '' && filterOption != 'custom' && filterOption != 'entire') {
                query += ' AND Lead_Created_Date__c = ' + filterOption + ' ';
            	
            }
            if (searchArg != null && searchArg.trim() != '') {
            	query += ' AND Full_Name__c LIKE \'%' + String.escapeSingleQuotes(searchArg.replace('*','%')) + '%\''; 
            }
            String orderPart = ' ';
            if (sortExpression != null) {
                orderPart += 'ORDER BY ' + sortExpression + ' ' + sortDirection + ' NULLS LAST';
            }
            if (rowLimit > 0) {
                orderPart += ' LIMIT ' + rowLimit;
            }
            if (currentPage > 1) {
                orderPart += ' OFFSET ' + (PAGE_SIZE * (currentPage - 1));
            }

			//if the filter changes, change the number of pages            
            if (filterChanged == true) {
            	filterChanged = false;
            	Integer filterCount = Database.countQuery('SELECT count() ' + query);
            	totalPages = null;
            	pages = null; 
				if (filterCount != null && filterCount > PAGE_SIZE) {
					totalPages = Math.ceil(filterCount * 1.0 / PAGE_SIZE).intValue();
					pages = new Integer[totalPages];
					for (Integer i = 0; i < totalPages; i++) {
						pages[i] = i + 1;
					} 
		        } 
            }
             
            result = Database.query(selectPart + query + orderPart);
            return result;
        }
    }
    
    public PageReference refresh() {
        return null;
    }
    
    public class PortalPayment {
        public PortalPayment(Date paymentDate, Decimal paymentAmount) {
            this.paymentDate = paymentDate;
            this.paymentAmount = paymentAmount;
        }
        public Date paymentDate { get; private set; }
        public Decimal paymentAmount { get; private set; }
    }
    
}