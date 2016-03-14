/* FILE: PartnerDashboardController.cls
 * AUTHOR: Tino Mattheou
 * DATE: December 14, 2012
 * PURPOSE: Controller for PartnerDashboard page, EP_DashboardPrint page, and EP_DashboardExport page
 *          Displays dashboard in the employee portal user's account
 * MODIFICATION HISTORY
 *          10/14/14  DK  Updated references from Community_Program__c (picklist) to Community_Program_Offer__c (lookup)
 */
 
public class PartnerDashboardController {
    
    private static final Integer PAGE_SIZE = 20;

    public Integer totalReferrals { get; private set; }
    public Integer totalOpen { get; private set; }
    public Integer totalQualified { get; private set; }
    public Integer totalSold { get; private set; }
    public Decimal totalKwhSold { get; private set; }
    public Integer[] pages { get; private set; }
    public Integer totalPages { get; private set; }
    public Integer totalPayments { get; private set; }
    public Decimal earnings { get; private set; }
    public String partnerSince { get; private set; }
    
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
    private Id communityProgram;    //Community_Program_Offer__c ID
    private String partnerType;
    private Datetime commProgramStartDatetime;
    
    private  Date commProgramStartDate;
    
    public PartnerDashboardController () {
        User u = [SELECT Id, ContactId, CreatedDate FROM User WHERE Id = :UserInfo.getUserId()];
        Contact c = [SELECT Id, AccountId, Account.Community_Program__c, Account.Community_Program_Offer__c, Account.Community_Program_Start_Date__c, Account.Partner_Type__c FROM Contact WHERE Id = :u.ContactId];
        accountId = c.AccountId;
        communityProgram = c.Account.Community_Program_Offer__c;
        commProgramStartDatetime = c.Account.Community_Program_Start_Date__C;
        system.debug('*'+ commProgramStartDatetime );
        if( commProgramStartDatetime != null)
        {
            system.debug('**'+ commProgramStartDatetime );
            commProgramStartDate = date.newinstance(commProgramStartDatetime.year(), commProgramStartDatetime.month(), commProgramStartDatetime.day());
        }    
        partnerType = c.Account.Partner_Type__c;
        AggregateResult[] minLeadDate = 
            [SELECT MIN(Lead_Created_Date__c) sinceDate 
            FROM Portal_Referral__c
            WHERE Account__c = :accountId
            AND Lead_Created_Date__c <> NULL 
            AND Status__c <> 'Duplicate'];
        
        if (minLeadDate.size() > 0 && minLeadDate[0].get('sinceDate') != null) {
          partnerSince = DateTime.newInstance((Date)minLeadDate[0].get('sinceDate'), Time.newInstance(0, 0, 0, 0)).format('MMMM, yyyy');
        } else {
          partnerSince = u.CreatedDate.format('MMMM, yyyy');
        }    
        
        System.debug(' * partnerSince '+partnerSince );
        
        sortExpression = 'Lead_Created_Date__c';
        sortDirection = 'DESC';
        currentPage = 1;
        if (ApexPages.currentPage().getUrl() == Page.PartnerDashboard.getUrl()) {
            rowLimit = PAGE_SIZE;
        } else {
            rowLimit = -1;
        }
        populateSummary();
    }
    
    private void populateSummary() {
        
        System.debug(' * partnerType '+partnerType );
        System.debug(' * communityProgram '+communityProgram );
        
        if (partnerType == 'Strategic' && communityProgram != null)
        {
             
                 //get earnings
            AggregateResult[] sumEarnings1 = 
              [SELECT COUNT(Id) referrals 
              FROM Portal_Referral__c 
              WHERE Community_Program_Offer__c = :communityProgram
              AND Status__c <> 'Duplicate' ];            
            
            Decimal total = 0;
            
            if (sumEarnings1.size() > 0) {              
              total = (Decimal)sumEarnings1[0].get('referrals');              
            } 
            
            Decimal total2 = 0;
            if(commProgramStartDate != null)
            {
                      //get earnings
                AggregateResult[] sumEarnings2 = 
                  [SELECT COUNT(Id) referrals 
                  FROM Portal_Referral__c 
                  WHERE Community_Program_Offer__c = :communityProgram
                  AND Status__c <> 'Duplicate' 
                  AND Opportunity__c != NULL
                  AND Opportunity__r.isClosed = true
                  AND Opportunity__r.CloseDate < :commProgramStartDate]; 
               
               if(sumEarnings2.size() > 0) 
               {
                   total2 = (Decimal)sumEarnings2[0].get('referrals');      
               }      
            }
            
            
            total = total - total2;
            if (total != null) {
                totalReferrals = total.intValue();
                if (totalReferrals > PAGE_SIZE) {
                  totalPages = Math.ceil(totalReferrals * 1.0 / PAGE_SIZE).intValue();
                  pages = new Integer[totalPages];
                  for (Integer i = 0; i < totalPages; i++) {
                    pages[i] = i + 1;
                  } 
                }
              }        
             
             //get totals by status  
            totalOpen = totalQualified = totalSold = 0; 
            AggregateResult[] statusSummary1 = 
                [SELECT Status__c status, count(Id) cnt 
                FROM Portal_Referral__c 
                WHERE Community_Program_Offer__c = :communityProgram
                AND Status__c != NULL 
                AND Status__c IN ('OPEN', 'QUALIFIED', 'SOLD')
                GROUP BY Status__c];
            for (AggregateResult ar : statusSummary1) {
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
            totalKwhSold  = 0;
            //get earnings
            AggregateResult[] kwh= 
              [SELECT SUM(Opportunity__r.Quoted_System_Size_kW__c) totalkwh  
              FROM Portal_Referral__c 
              WHERE Community_Program_Offer__c = :communityProgram
              AND Status__c <> 'Duplicate'
              AND Opportunity__c != null
              AND Opportunity__r.StageName = 'Closed - Won'];
            
             if (kwh.size() > 0) {
                 totalKwhSold  = (Decimal)kwh[0].get('totalkwh'); 
             } 
             if (totalKwhSold  == null)
             {
                 totalKwhSold  = 0;
             }
             
        }
        else
        {
                //get earnings
            AggregateResult[] sumEarnings = 
              [SELECT SUM(Referral_Earnings__c) earnings, COUNT(Id) referrals 
              FROM Portal_Referral__c 
              WHERE Account__c = :accountId 
              AND Status__c <> 'Duplicate'];
            
            if (sumEarnings.size() > 0) {
              earnings = (Decimal)sumEarnings[0].get('earnings');
              Decimal total = (Decimal)sumEarnings[0].get('referrals');
              if (total != null) {
                totalReferrals = total.intValue();
                if (totalReferrals > PAGE_SIZE) {
                  totalPages = Math.ceil(totalReferrals * 1.0 / PAGE_SIZE).intValue();
                  pages = new Integer[totalPages];
                  for (Integer i = 0; i < totalPages; i++) {
                    pages[i] = i + 1;
                  } 
                }
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
        
    }

//TODO: error handing
    public List<Portal_Referral__c> referrals {
        get {
            List<Portal_Referral__c> result = new List<Portal_Referral__c>();
            List<Portal_Referral__c> filteredresult = new List<Portal_Referral__c>();
                        
            String selectPart = 'SELECT Id, Full_Name__c, Status__c, Detail__c, Lead_Source__c, ' 
                + 'Street__c, City__c, State__c, Zip__c, Phone__c, Email__c, CreatedDate, '
                + 'Mobile_Phone__c, Work_Phone__c, Primary_Phone__c, '
                + 'Referral_Earnings__c, Lead_Created_Date__c, Method_of_Contact__c,community_Program__c , Opportunity__C, Opportunity__r.CloseDate, Opportunity__r.isClosed,  '
                + 'Self_Generated__c ';
            String query =
                + 'FROM Portal_Referral__c ';
            
            if (partnerType == 'Strategic' && communityProgram != null)
                query += ' WHERE Community_Program_Offer__c = :communityProgram ';
            else    
                query +=  ' WHERE Account__c = :accountId ';
                
                query += ' AND Status__c <> \'Duplicate\' ';
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
            System.debug(' * Query- '+selectPart + ' ' + query + orderPart ); 
            result = Database.query(selectPart + query + orderPart);
            
            if (partnerType == 'Strategic' && communityProgram != null)
            {
                for(Portal_Referral__c pr : result )
                {
                    if(pr.Opportunity__c != null && pr.Opportunity__r.isClosed == true)
                    {
                        if(commProgramStartDate !=null)
                        {
                            if(!(pr.Opportunity__r.CloseDate < commProgramStartDate))
                                filteredresult.add(pr);     
                        } 
                        else
                        {       
                            filteredresult.add(pr);
                        }    
                    }
                    else
                    {    
                     filteredresult.add(pr);
                    } 
                }
                return filteredresult ;
            } 
            else {
                return result;
            }    
        }
    }
    

    
   public List<PortalPayment> payments {
    get {
      List<PortalPayment> result = new List<PortalPayment>();
      
      System.debug(' * payments -1 ' );  
      List<Portal_Referral_Payment__c> payments =
        [SELECT Id, Payment_Date__c, Payment_Amount__c
        FROM Portal_Referral_Payment__c
        WHERE Account__c = :accountId
        ORDER BY Payment_Date__c DESC];
      
      System.debug(' * payments -2 '+payments  );  
      for (Portal_Referral_Payment__c payment : payments) {
        result.add(new PortalPayment(payment.Payment_Date__c, payment.Payment_Amount__c));
      }
       System.debug(' * payments -3 '+result);  
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