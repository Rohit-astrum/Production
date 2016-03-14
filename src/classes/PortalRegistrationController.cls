/* FILE: PortalRegistrationController.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 19, 2012
 * PURPOSE: Allow partner to register with Astrum Solar Connect portal site
 * MODIFICATION HISTORY
 * 11/16/2012 TCM - make fax not required, remove how did you hear about us
 * 11/16/2012 TCM - remove agree with terms and conditions
 * 04/03/2015 SZ - Comment out "if" statement in getOrgIndustries that is no longer relevant to the picklist values
 */
 
public class PortalRegistrationController {

    public Boolean done { get; set; }
    public Partner_Application__c app_prof  { get; set; }
    public Partner_Application__c aff_app { get; set; }
    public Partner_Application__c afn_app { get; set; }
    public Partner_Application__c app;
    public String errorFields { get; set; }
    public Boolean accept { get; set; }
    public String partnerType{ get; set; }
    private String hearAboutusText = 'I am an MNCBIA Member';
    private String hearAboutus = 'No';
    
    public PortalRegistrationController() {
        app_prof = new Partner_Application__c();
        aff_app = new Partner_Application__c();
        afn_app = new Partner_Application__c();
        //app = new Partner_Application__c();
        done = false;
        accept = false;
        errorFields = '';
        hearAboutus = ApexPages.currentPage().getParameters().get('hearabtus');
        System.debug(' * errorFields  - '+ errorFields );
        app_prof.Comments__c = (hearAboutus == 'Yes' ? hearAboutusText : null) ; 
       
    }   

     //Grabs radio button values from post data (non-visualforce inputs)
    private void grabPostData() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        partnerType = params.get('programType');           
        if( partnerType != null && partnerType  == 'Professional' )
        {
            app = App_prof;
            app.Partner_Type__c = partnerType ;           
        }
        else if (partnerType != null && partnerType  == 'Affiliate' )   
        {
            app = aff_App;
            app.Partner_Type__c = partnerType ;
        }
        else if (partnerType != null && partnerType == 'Affinity' )   
        {
            app = afn_App;
            app.Partner_Type__c = partnerType ;
        }
        System.debug('*Inside grabPostData app '+ app);
    }
    
    public PageReference apply() {       
        grabPostData();       
        validate();       
        if (errorFields != null && errorFields.trim() != '') {
            System.debug('*Inside Apply errorfields '+errorFields );
            return null;
        }

        try {

            Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Partner_Application_Queue'];
            app.OwnerId = queue.Id;
            insert app;           
            done = true;
            
        } catch (Exception e) {
            
            if (e instanceof DMLException) {
                System.DMLException dmlExcp = (System.DMLException)e;
                for (String field : dmlExcp.getDmlFieldNames(0)) {
                    if (field == 'Email__c') {
                        errorFields += '[1][email]';
                    }
                }
            }

            if (errorFields == null || errorFields.trim() == '') {
                errorFields += '[unknown]';
                logError(String.valueOf(e));
            }
            //TODO: send an email or log
            
        }

        return null;
    }
    
    @future
    public static void logError(String errorMsg) {
        if (!Test.isRunningTest()) {
            System.assert(false, errorMsg);
        }
    }
    
    private void validate() {
        
        errorFields = '';
        
        //YOU
        if (app.First_Name__c == null || app.First_Name__c.trim() == '') {
            errorFields += '[1][fname]';
        }
        if (app.Last_Name__c == null || app.Last_Name__c.trim() == '') {
            errorFields += '[1][lname]';
        }
        if (app.Title__c == null || app.Title__c.trim() == '') {
            errorFields += '[1][title]';
        }
        if (app.Email__c == null || app.Email__c.trim() == '') {
            errorFields += '[1][email]';
        }
        if (app.Phone__c == null || app.Phone__c.trim() == '') {
            errorFields += '[1][phone]';
        }
        
        //YOUR ORGANIZATION
        if (app.Company_Name__c == null || app.Company_Name__c.trim() == '') {
            errorFields += '[2][cname]';
        }
        if (app.Address__c == null || app.Address__c.trim() == '') {
            errorFields += '[2][addr]';
        }
        if (app.City__c == null || app.City__c.trim() == '') {
            errorFields += '[2][city]';
        }
        if (app.State__c == null || app.State__c.trim() == '') {
            errorFields += '[2][state]';
        }
        if (app.Zip_Code__c == null || app.Zip_Code__c.trim() == '') {
            errorFields += '[2][zip]';
        }
       
        if( partnerType != null && partnerType  != 'Affinity')
        {
            if (app.Industry__c == null || app.Industry__c.trim() == '') {
                errorFields += '[2][indu]';
            }
        }          
        
        if( partnerType != null && partnerType  == 'Affinity')
        {
            if (app.website__c == null || app.website__c.trim() == '') {
                errorFields += '[2][website]';
            }
        }  
        
        if( partnerType != null && partnerType  == 'Professional')
        {
            if (app.Employees__c == null || app.Employees__c.trim() == '') {
                errorFields += '[2][emp]';
            }
        }    
        else if (partnerType != null && partnerType  != 'Professional') 
        {
            if (app.Number_of_Members__c == null || app.Number_of_Members__c.trim() == '') {
                errorFields += '[2][mem]';
            }
            else if (app.Number_of_Members__c != null && app.Number_of_Members__c == '< 100 Not Eligible for Program') {
                System.debug('*app.Number_of_Members__c '+app.Number_of_Members__c);
                errorFields += '[3][E100]';
            }
        } 
        
        if (partnerType != null && partnerType  == 'Affiliate')
        {    
            if (app.EIN_Number__c == null || app.EIN_Number__c.trim() == '') {
                errorFields += '[2][ein]';
            }        
        }  
        
        if (app.Terms_Accepted__c == null || app.Terms_Accepted__c == false) {
            errorFields += '[3][term]';
        } 
        
        
        if (errorFields != null && errorFields.trim() != '') {
            if( partnerType != null && partnerType  == 'Professional')
            {
                errorFields  += '[prof]';    
            }
            else if (partnerType != null && partnerType  == 'Affiliate')
            {
                errorFields  += '[afl]'; 
            }
            else if (partnerType != null && partnerType  == 'Affinity')
            {
                errorFields  += '[afn]';    
            }
        } 
        
    }
    
    public List<SelectOption> getStates() {
        return buildPickList(Partner_Application__c.State__c, '-- Select --'); 
    }
    
    public List<SelectOption> getOrganizations() {
        return buildPickList(Partner_Application__c.Affiliate_Organization_Type__c, '-- Select --'); 
    }
    
    public List<SelectOption> getPartnerTypes() {
        return buildPickList(Partner_Application__c.Partner_Type__c, null); 
    }

    public List<SelectOption> getIndustries() {
        List<SelectOption> result = new List<SelectOption>();       
        result.add(new SelectOption('', '-- Select One --'));        
        Schema.DescribeFieldResult state = Partner_Application__c.Industry__c.getDescribe();
        for (Schema.PicklistEntry ple : state.getPickListValues()) {           
            result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            if(ple.getValue() == 'Other Industry')
                break;
        }
        return result;
    }
    
    public List<SelectOption> getOrgIndustries() {
        List<SelectOption> result = new List<SelectOption>();       
        result.add(new SelectOption('', '-- Select One --'));        
        Schema.DescribeFieldResult state = Partner_Application__c.Industry__c.getDescribe();
        for (Schema.PicklistEntry ple : state.getPickListValues()) {
            // 04/03/2015 SZ - Commented out to use all picklist values
            //if(ple.getValue() == 'Nonprofit' || ple.getValue() == 'Membership Organization' || ple.getValue() == 'Other' )
            result.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        return result;
    }


    public List<SelectOption> getEmployees() {
        return buildPickList(Partner_Application__c.Employees__c, '-- Select One --'); 
    }
    
    public List<SelectOption> getMembers() {
        return buildPickList(Partner_Application__c.Number_of_Members__c, '-- Select One --'); 
    }

    public List<SelectOption> getSources() {
        return buildPickList(Partner_Application__c.Source__c, '-- Select One --'); 
    }

    private List<SelectOption> buildPickList(Schema.SObjectField field, String emptyLabel) {
        List<SelectOption> result = new List<SelectOption>();
        if (emptyLabel != null) {
            result.add(new SelectOption('', emptyLabel));
        }
        Schema.DescribeFieldResult state = field.getDescribe();
        for (Schema.PicklistEntry ple : state.getPickListValues()) {
            result.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        return result;
    }
    
}