/* FILE: GrantProjectsController.cls
 * AUTHOR: Tino Mattheou
 * DATE: April 9, 2012
 * PURPOSE: Controller class for GrantProjectsBase component
 *          Used in 3 GrantProjects pages - grants/rebates, srecs, and property tax
 * MODIFICATION HISTORY
 *
 */
  
//TODO: subclass base controller to share bin and project info
public class GrantProjectsController {

    public static List<Bin_Configuration__c> binConfig { 
        get { 
            if (binConfig == null) {
                binConfig = DocumentConfigurationHelper.getBins(DocumentConfigurationHelper.APP_ASTRUM_PM_20);
            }
            return binConfig;
        }
        private set;
    }
    
    public static List<DocumentConfigurationHelper.SpecialCategory> specialCategories {
        get {
            if (specialCategories == null) {
                specialCategories = DocumentConfigurationHelper.getSpecialCategories(DocumentConfigurationHelper.APP_ASTRUM_PM_20);
            }
            return specialCategories;       
        }
        private set;
    }
    
    public List<String> getStates() {
        List<String> result = new List<String>();
        Schema.DescribeFieldResult states = Property__c.Property_State__c.getDescribe();
        for (Schema.PicklistEntry state : states.getPicklistValues()) {
            result.add(state.getLabel());
        }
        return result;
    }
    
    public String getStateSettings() {
        String result;
        AstrumPM2__c setting = AstrumPM2__c.getValues(UserInfo.getUserId());
        if (setting != null) {
            result = setting.State_Filter__c;
        }
        return result;
    }

    @RemoteAction
    public static void setStateSettings(String value) {
        AstrumPM2__c setting = AstrumPM2__c.getValues(UserInfo.getUserId());
        if (setting == null) {
            setting = new AstrumPM2__c();
            setting.SetupOwnerId = UserInfo.getUserId();
        }
        setting.State_Filter__c = value;
        if (setting.Id == null) {
            insert setting;
        } else {
            update setting;
        }
    }
    
    @RemoteAction
    public static List<PM_Project__c> getProjects(String appName, String status, List<String> filters) {
        
        List<String> states = new List<String>();
        
        for (String filter : filters) {
            String[] parts = filter.split(':');
            if (parts[1] == 'All') {
                continue;
            }
            if (parts[0] == 'state') {
                states.add(parts[1]);
            }
        }
        
        String query = 'SELECT Id, Name';
        query += ',Sales_Order__r.Property__r.Name,Sales_Order__r.Property__r.Property_City__c,Sales_Order__r.Property__r.Property_State__c,Sales_Order__r.Property__r.Property_County__c';
        query += ',Sales_Order__r.Financing_Type__c';
        
        Set<String> binFields = new Set<String>();
        
        for (Bin_Configuration__c config : binConfig) {
            if (!binFields.contains(config.Field_Name__c)) {
                query += ',' + config.Field_Name__c;
                binFields.add(config.Field_Name__c);
            }
        }
        
        //GRANTS
        if (!binFields.contains('Work_Completed__c')) {
            query += ',Work_Completed__c';
            binFields.add('Work_Completed__c');
        }
        if (!binFields.contains('Grant_Reservation_Number__c')) {
            query += ',Grant_Reservation_Number__c';
            binFields.add('Grant_Reservation_Number__c');
        }
        if (!binFields.contains('Grant_Reservation_Amount__c')) {
            query += ',Grant_Reservation_Amount__c';
            binFields.add('Grant_Reservation_Amount__c');
        }
        
        //SREC
        if (!binFields.contains('Approved_Utility_Interconnect_Part_2__c')) {
            query += ',Approved_Utility_Interconnect_Part_2__c';
            binFields.add('Approved_Utility_Interconnect_Part_2__c');
        }
        if (!binFields.contains('NJ_SREC_Docs__c')) {
            query += ',NJ_SREC_Docs__c';
            binFields.add('NJ_SREC_Docs__c');
        }

        //Property Tax
        if (!binFields.contains('Property_Tax_Approved__c')) {
            query += ',Property_Tax_Approved__c';
            binFields.add('Property_Tax_Approved__c');
        }
        if (!binFields.contains('Installation_Photos__c')) {
            query += ',Installation_Photos__c';
            binFields.add('Installation_Photos__c');
        }
        if (!binFields.contains('Building_Permit__c')) {
            query += ',Building_Permit__c';
            binFields.add('Building_Permit__c');
        }
        if (!binFields.contains('Electrical_Permit__c')) {
            query += ',Electrical_Permit__c';
            binFields.add('Electrical_Permit__c');
        }
        if (!binFields.contains('Proof_of_Inspection__c')) {
            query += ',Proof_of_Inspection__c';
            binFields.add('Proof_of_Inspection__c');
        }
        
        for (DocumentConfigurationHelper.SpecialCategory cat : specialCategories) {
            if (binFields.contains(cat.binDateFieldName)) {
                query += ',' + cat.categoryDateFieldName;
            }
        }
        
        query += ',Kickoff__c,Install__c,Inspection__c,Customer_Care_Handoff__c,Paid_In_Full__c';
        query += ',(SELECT Id, Bin__c, Description__c ,Status__c,To__c  FROM PM_Project_Issues__r WHERE (Status__c = \'Open\')';
        query += ' OR (Status__c = \'Fixed\'))';
        query += ',(SELECT Bin__c From Astrum_Docs__r WHERE IsNote__c = true)';
        query += ' FROM PM_Project__c WHERE Status__c = :status';
        
        //add filters
        if (states.size() > 0) {
            query += ' AND Sales_Order__r.Property__r.Property_State__c IN :states';
        }

        query += ' ORDER BY Name';
        
        List<PM_Project__c> projects = Database.query(query);
        
        Set<String> specialBins = new Set<String>();
        for (DocumentConfigurationHelper.SpecialCategory sc : specialCategories) {
            if (binFields.contains(sc.binDateFieldName)) {
                specialBins.add(sc.binDateFieldName);
            }
        }

        for (PM_Project__c project : projects) {
            for (String specialBin : specialBins) {
                Date dt = (Date)project.get(specialBin);
                if (dt == null) {
                    for (DocumentConfigurationHelper.SpecialCategory sc : specialCategories) {
                        if (sc.binDateFieldName == specialBin) {
                            Date dt2 = (Date)project.get(sc.categoryDateFieldName);
                            if (dt2 != null && sc.binState != null) {
                                if (sc.binState == 'Ready to Sign') {
                                    project.put(specialBin, dt2.addYears(2000));
                                } else if (sc.binState == 'Signed') {
                                    project.put(specialBin, dt2.addYears(4000));
                                } else { //submitted
                                    project.put(specialBin, dt2.addYears(6000));
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return projects;
    }
    
    @RemoteAction
    public static void setProjectField(Id projectId, String fieldName, String fieldValue) {
        PM_Project__c project = new PM_Project__c ( Id = projectId );
        if (fieldValue == null || fieldValue.trim().length() == 0) {
            project.put(fieldName, null);
        } else {
            if (fieldName == 'Grant_Reservation_Amount__c') {
                project.put(fieldName, Decimal.valueOf(fieldValue));
            } else {
                project.put(fieldName, fieldValue);
            }
        }
        update project;
    }
}