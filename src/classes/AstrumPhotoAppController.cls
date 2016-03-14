/* FILE: AstrumPhotoAppController.cls
 * AUTHOR: Rohit Jain
 * DATE: Sep 30, 2013
 * PURPOSE: Controller for ImageUploader Page - Uploads the Photos from Phone to Selected Project, Bin and Category. 
 * MODIFICATION HISTORY: 
 */
 
public class AstrumPhotoAppController{

    public Static List<String> filters { get; set; }
    public String selectedBin { get; set; }
    public String newBinSelected { get; set; }
    public String selectedProject { get; set; }
    public String selectedStatus { get; set; }
    public String selectedOffice { get; set; }
    public String selectedState { get; set; }
    public String selectedLead { get; set; }    
    public String selectedCategory { get; set; }  
    public String uploadedFileId { get; set; } 
    public Attachment uploadFile { get; set; }
    public String errorFields { get; private set; }
    private String profileName;
   
    
    public Map<String,Boolean> categoryDateRequiredMap = new Map<String,Boolean> ();
    
    public AstrumPhotoAppController() {
        uploadFile = new Attachment();
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        profileName = profiles[0].Name;  
    }
    
    public List<SelectOption> Statuses{
        get { return createPickList(PM_Project__c.Status__c.getDescribe(), 'All'); }
    }
    
    public List<SelectOption> Offices{
        get { return createPickList(Property__c.Astrum_Office__c.getDescribe(), 'All'); }
    }
    
   

    public List<SelectOption> States {
        get { return createPickList(Property__c.Property_State__c.getDescribe(), 'All'); }
    }
    
    public String getSelectedFilter() {
        if(filters != null)
            return String.valueOf(filters.size()) ;
        else
            return null;
    
    }
    public List<SelectOption> getBins() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '-- Select Bin --')); 
        if(profileName == 'PM Mobile Restricted Site User')
        {
            List<Bin_Configuration__c> bins = 
                [SELECT Bin__c
                FROM Bin_Configuration__c
                WHERE Astrum_Application__r.Name = 'Astrum PM 2.0' 
                  AND Installer_electrician_Access__c = true             
                ORDER BY Bin_Grouping_Order__c,Bin_Order__C];
            for (Bin_Configuration__c bin : bins) {
                result.add(new SelectOption(bin.Bin__c, bin.Bin__c)); 
            }     
        }
        else
        {
            List<Bin_Configuration__c> bins = 
                [SELECT Bin__c
                FROM Bin_Configuration__c
                WHERE Astrum_Application__r.Name = 'Astrum PM 2.0'               
                ORDER BY Bin_Grouping_Order__c,Bin_Order__C];
            for (Bin_Configuration__c bin : bins) {
                result.add(new SelectOption(bin.Bin__c, bin.Bin__c)); 
            }           
        }   
        return result;
    }
    
    public List<SelectOption> getCategories() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '-- Select Category --')); 
        
        if(profileName == 'PM Mobile Restricted Site User')
        {       
            List<Category_Configuration__c> categories = 
                [SELECT Id,Category__c,Document_Date_Required__c
                   FROM Category_Configuration__c
                  WHERE Astrum_Application__r.Name = 'Astrum PM 2.0' 
                    AND Installer_electrician_Access__c = true   
                    AND Bin__c = :newBinSelected   
               ORDER BY Category_Order_In_Bin__c];
            for (Category_Configuration__c category : categories ) {
                result.add(new SelectOption(category.Category__c, category.Category__c)); 
                categoryDateRequiredMap.put(category.Category__c,category.Document_Date_Required__c); 
            } 
        }
        else
        {
            List<Category_Configuration__c> categories = 
                [SELECT Id,Category__c,Document_Date_Required__c
                   FROM Category_Configuration__c
                  WHERE Astrum_Application__r.Name = 'Astrum PM 2.0'  
                    AND Bin__c = :newBinSelected   
               ORDER BY Category_Order_In_Bin__c];
            for (Category_Configuration__c category : categories ) {
                result.add(new SelectOption(category.Category__c, category.Category__c)); 
                categoryDateRequiredMap.put(category.Category__c,category.Document_Date_Required__c); 
            } 
        
        }       
        return result;
    }
    
    
    

    public List<SelectOption> getProjectLeads() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('All', 'All'));
        result.add(new SelectOption('', 'Unassigned'));
        List<UserRole> roles = [SELECT Id FROM UserRole WHERE Name LIKE '%Project Lead'];
        List<User> leads = [SELECT Id, Name FROM User WHERE UserRoleId IN :roles ORDER BY Name];
        //add leads that are assigned to projects but not in a role
        leads.addAll([SELECT Id, Name FROM User WHERE Id IN (SELECT Project_Lead__c FROM PM_Project__c) AND Id NOT IN :leads]);
        //create a map to sort the names
        Map<String, User> nameMap = new Map<String, User>();
        for (User lead : leads) {
            nameMap.put(lead.Name + '|' + lead.Id, lead);
        }
        List<String> names = new List<String>();
        names.addAll(nameMap.keySet());
        names.sort();        
        for (String name : names) {
            User lead = nameMap.get(name);
            result.add(new SelectOption(lead.Name, lead.Name));
        }
        return result;
    }
    
    
    @RemoteAction
    public static List<PM_Project__c> getFilteredProjects(List<String> projectfilters) {
        List<String> statuses = new List<String>();
        List<String> statusClauses = new List<String>();
        List<String> states = new List<String>();
        List<String> offices = new List<String>();      
        List<String> projectLeads = new List<String>();
        
        System.debug('###'+projectfilters);            
        
        if(projectfilters!= null) {
        //add the filters values to the right collections
        for (String filter : projectfilters) {
            String[] parts = filter.split(':');
            if (parts[1] == 'All') {
                continue;
            }
            if (parts[0] == 'status') {
               statuses.add(parts[1]);
               
            } else if (parts[0] == 'state') {
                states.add(parts[1]);
            } else if (parts[0] == 'office') {
                offices.add(parts[1]);
            } else if (parts[0] == 'lead') {
                projectLeads.add(parts[1]);
            }
        }
        }
        
        String query = 'SELECT Id, Name';
        query += ' FROM PM_Project__c WHERE Status__c != null ';

        //add filters to the query
        if (statuses.size() > 0) {
            query += ' AND Status__c IN :statuses';
        }
        
        if (states.size() > 0) {
            query += ' AND Sales_Order__r.Property__r.Property_State__c IN :states';
        }
        if (offices.size() > 0) {
            query += ' AND Sales_Order__r.Property__r.Astrum_Office__c IN :offices';
        }
        if (projectLeads.size() > 0) {
            query += ' AND Project_Lead__r.Name IN :projectLeads';
        }
        
        query += ' ORDER BY Name limit 999 ';
        
        List<PM_Project__c> projects = Database.query(query);
        
        
        return projects ;
    
    }
    
    
    
    
    private List<SelectOption> createPickList(Schema.DescribeFieldResult dfr, String blankLabel) {
        List<SelectOption> result = new List<SelectOption>();
        if (String.isNotBlank(blankLabel)) {
            result.add(new SelectOption('All', blankLabel));
        }
        for (Schema.PicklistEntry ple : dfr.getPickListValues()) {
            result.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        return result;
    }
    
    //forced refresh of Projects
    public PageReference projectStatusChanged() {
        return null;
    }
    
    //forced refresh of Projects
    public PageReference binChanged() {
        return null;
    }
    
    private static Map<String, String> prefixSettingMap = new Map<String, String> {
        'status' => 'Status_Filter__c',
        'state' => 'State_Filter__c',
        'office' => 'Office_Filter__c',
        'lead' => 'Project_Lead_Filter__c'
    };
    
    public List<String> getdefaultFilter() {
       
        List<String> result = new List<String>();
        AstrumPhotoAppSettings__c setting = AstrumPhotoAppSettings__c.getValues(UserInfo.getUserId());
        for (String prefix : prefixSettingMap.keySet()) {
            if (setting != null) {
                String value = (String)setting.get(prefixSettingMap.get(prefix));
                if (value != null) {
                    result.add (prefix + ':' + value);
                }
            }
        }       
        return result;
    }
  
        
    @RemoteAction
    public static void setDefaultFilter(List<String> projectfilters) {
        AstrumPhotoAppSettings__c setting = AstrumPhotoAppSettings__c.getValues(UserInfo.getUserId());
        if (setting == null) {
            setting = new AstrumPhotoAppSettings__c();
            setting.SetupOwnerId = UserInfo.getUserId();
        }
        
        if(projectfilters!= null) {
            //add the filters values to the right collections
            for (String filter : projectfilters) {
                String[] parts = filter.split(':');
                if (parts[0] == 'status') {                  
                   setting.put(prefixSettingMap.get('status'), parts[1]);
                } else if (parts[0] == 'state') {
                    setting.put(prefixSettingMap.get('state'), parts[1]);
                } else if (parts[0] == 'office') {
                    setting.put(prefixSettingMap.get('office'), parts[1]);
                } else if (parts[0] == 'lead') {
                    setting.put(prefixSettingMap.get('lead'), parts[1]);
                }
            }
        }
        
        
        if (setting.Id == null) {
            insert setting;
        } else {
            update setting;
        }
    }   
    
    //validate input fields    
    private void validate(String projectId, String keyDate ) {
        errorFields = '';   
        
        //home information
        if (String.isBlank(projectId)) {
            errorFields += '[1][project]';
        }
        if (String.isBlank(selectedBin)) {
            errorFields += '[1][bin]';
        }
        if (String.isBlank(selectedCategory)) {
            errorFields += '[1][category]';
        }
        if(selectedCategory != null && categoryDateRequiredMap.get(selectedCategory))
        {
            if (String.isBlank(keyDate)) {
                errorFields += '[1][keydate]';
            }       
        }  
      /*  if (uploadFile.Body == null ) {
            errorFields += '[2][file]';
        }*/  
    }        
            
            
    public PageReference upload() { 
        uploadedFileId  = null;    
        Savepoint sp = Database.setSavepoint();
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        selectedProject  = params.get('CustomerName');  
        String keyDate= params.get('keyDate');
        System.debug('uploadFile.BodyLength ** '+uploadFile.BodyLength);
        validate(selectedProject ,keyDate);
        system.debug('*** '+errorFields);
        if (String.isNotBlank(errorFields)) {
            uploadFile = new Attachment();
            return null;
        }
        
        try {
        
            Astrum_Doc__c doc = new Astrum_Doc__c (
                PM_Project__c = selectedProject  ,
                Bin__c = selectedBin,
                Category__c = selectedCategory
            ); 
            
            if (keyDate != null && keyDate.trim().length() > 0) {
                doc.Document_Key_Date__c = Date.parse(keyDate); 
            } else {
                keyDate = '';
            }
            
            insert doc;
    
            uploadFile.ParentId = doc.Id;                
            insert uploadFile; 
            
            uploadFile = 
                [Select Id, BodyLength, Name, ContentType
                FROM Attachment 
                WHERE Id = :uploadFile.Id];
           
            uploadedFileId  = uploadFile.Name;
            
        } catch (Exception e) {
            
            //jsonResponse.getParameters().put('error', e.getMessage());
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Error in upload.'));
             uploadFile = new Attachment();
             return null;
            
        }
        
     
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File ' +uploadFile.Name+ ' uploaded successfully.'));
        uploadFile = new Attachment();
       
        return null;
  }

}