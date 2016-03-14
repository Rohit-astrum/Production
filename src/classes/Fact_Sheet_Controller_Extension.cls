//TCM 03/01/2012 - Constellation Lease Inverters - calculate lease inverters required
//TCM 03/06/2012 - Constellation Lease Inverters - new calculation
public with sharing class Fact_Sheet_Controller_Extension  {
    
    private final Milestone1_Project__c project; 
    public List<System_Design_Array__c> systemDesignArrays{get;set;}
    public List<System_Design_Item__c> systemDesignItems{get;set;}
    public List<Install_Location__c> installLocations{get;set;}
    public List<Contact> contacts{get;set;}
    public List<Utility_Service__c> utilityServices{get;set;}
    public List<CB_Panel__c> cbPanels{get;set;}
    public List<Milestone1_Milestone__c> milestones{get;set;}
    public Property__c projectProperty{get;set;}
    public System_Design__c systemDesign{get;set;}
    public System_Design_Quote__c systemDesignQuote{get;set;}
    public SCRB_SalesOrder__c salesOrder{get;set;}
    public String leasedInverters { get; private set; }
     
    private void LoadData(){
       this.salesOrder = [SELECT id, AccountId__c, System_Design_Quote__c, Name, Has_Field_Survey_Been__c, Hand_Off_Notes__c, Financing_Type__c, Financing_Option__c, Leasing_Option__c, Constellation_Lease_Inverters__c FROM SCRB_SalesOrder__c WHERE id=:this.project.Sales_Order__c LIMIT 1];
       this.contacts = [SELECT id, FirstName, LastName, Email, HomePhone, MobilePhone, Phone, Work_Phone__c FROM Contact WHERE AccountId=:this.salesOrder.AccountId__c];
       this.systemDesignQuote = [SELECT id, Name, Final_Adjusted_Price__c, Final_Adjusted_Price_per_Watt__c, System_Design__c FROM System_Design_Quote__c WHERE id=:this.salesOrder.System_Design_Quote__c LIMIT 1];
       leasedInverters = 'Constellation Lease Inverters Required: ' + salesOrder.Constellation_Lease_Inverters__c;
       this.systemDesign = [SELECT id, Property__c, Name, Total_Projected_Annual_Output_kWh_y__c, Total_System_Size_kW__c, Ground_Mount_Arrays__c, Panel_Count__c, System_Makeup__c, Number_of_Arrays__c, Number_of_Arrays_on_Flat_Roofs__c, Overall_Site_Quality__c, Overall_TSRF__c, Max_Install_Location_Pitch__c, Max_Install_Location_Stories__c, Includes_Outbuilding_Installation__c, Inside_Only_Conduit__c, Trenching_Required__c, Vent_Stack_Movement_Required__c, Notes__c FROM System_Design__c WHERE id=:this.systemDesignQuote.System_Design__c LIMIT 1];
       this.systemDesignArrays = [SELECT id, Name, Mounting_Type__c, Special_Parts_Required__c, Electrical_Adder__c, CB_Panel__c, Array_Size_kW__c, Items_On_Flat_Roof__c, Max_Install_Location_Pitch__c, Max_Install_Location_Stories__c, Panel_Count__c, Projected_Annual_Output_kWh_y__c FROM System_Design_Array__c WHERE System_Design__c=:this.systemDesign.id];
       this.systemDesignItems = [SELECT id, System_Design_Array__c, Name, Property__c, Install_Location__c, Quantity__c, System_Design_Product__r.Description__c  FROM System_Design_Item__c WHERE System_Design_Array__c in :this.systemDesignArrays ORDER BY System_Design_Array__c];
       this.projectProperty = [SELECT id, Name, Property_Address_2__c, Property_City__c, Property_State__c, Property_ZIP__c, Property_County__c, Permit_Jurisdiction__c, HOA_Contact_Name__c, HOA_Contact_Phone__c, HOA_Contact_Email__c, Optimal_Site_Quality_kWh_y_kW__c, Astrum_Office__c, Hours_From_Nearest_Office__c FROM Property__c WHERE id=:this.systemDesign.Property__c LIMIT 1];
       this.installLocations = [SELECT id, Property__c, Name, Azimuth__c, Pitch__c, Number_of_Stories__c, Stuctural_Members__c, Surface_Type__c, TSRF__c FROM Install_Location__c WHERE Physical_Surface__r.Property__c=:this.projectProperty.id]; //MK - 2014-05-04 - Updated for PS
       this.utilityServices = [SELECT id, Property__c, Name, Service_Account_Number__c, Utility_Company__c, Amperage__c FROM Utility_Service__c WHERE Property__c=:this.projectProperty.id];
       this.cbPanels = [SELECT id, Name, Utility_Service__c, Panel_Location__c, Parent_CB_Panel__c, Main_Breaker_Rating_Amps__c, Bus_Rating_Amps__c FROM CB_Panel__c WHERE Utility_Service__c in :this.utilityServices];
       this.milestones = [SELECT id, Name, Kickoff__c, Deadline__c, Complete__c, Description__c, Total_Complete_Tasks__c, Total_Late_Tasks__c, Total_Blocked_Tasks__c, Total_Open_Tasks__c FROM Milestone1_Milestone__c WHERE Project__c=:this.project.id];
    }
    
    public Fact_Sheet_Controller_Extension(ApexPages.StandardController stdController) {
        this.project = (Milestone1_Project__c)stdController.getRecord();
        LoadData();
    }
    
}