/* FILE: PMProjectFactSheetExtension.cls
 * AUTHOR: Tino Mattheou
 * DATE: May 11, 2012
 * PURPOSE: Provides data to PMProjectFactSheet page  
 * MODIFICATION HISTORY
 *      RJ - 06/07/13 - CHange for Lease Funding
 *      DK - 09/08/15 - Adding sample sketch JPG from System Design. CPQ-662.
 *      RJ   01/14/2016 : MIS-201
 */ 
public with sharing class PMProjectFactSheetExtension { 

    private PM_Project__c project;
    public String nrgLeaseFundId {set;get;}
    public String sunnovaLeaseFundId {set;get;}
    public String sampleSketchID {get; set;}   //DK  CPQ-662
    public String soldScenarioPricingURL {get; set;}    //DK  CPQ-662
    public String systemDesignArrayViewURL {get; set;}    //RJ  SOA-46
    
    public PMProjectFactSheetExtension(ApexPages.StandardController stdController) { 
        project = (PM_Project__c)stdController.getRecord();
        project = [Select Id,Lease_Funding_Status__C,Sales_Order__c,Sales_Order__r.AccountId__c,Sales_Order__r.Property__c
        ,Sales_Order__r.System_Design_Quote__r.System_Design__c 
        ,Sales_Order__r.System_Design_Quote__r.Community_Program_Offer__r.RecordType.Name 
        from PM_Project__C where Id = :project.Id];
        nrgLeaseFundId = [SELECT Id FROM Lease_Fund__c WHERE Name = 'NRG Residential Solar Solutions, LLC'].Id;
        sunnovaLeaseFundId = [SELECT Id FROM Lease_Fund__c WHERE Name = 'Sunnova Energy Corporation'].Id;

        Attachment[] sampleSketch = [SELECT ID FROM Attachment WHERE ParentID = :project.Sales_Order__r.System_Design_Quote__r.System_Design__c
                                        AND Name = 'sample_sketch.jpg' AND ContentType = 'image/jpeg' LIMIT 1];
        if (!sampleSketch.isEmpty())
            sampleSketchID = sampleSketch[0].ID;

        if(!Test.isRunningTest())
        {
            systemDesignArrayViewURL = new PageReference('/apex/SystemDesignArraysView?id=' + project.Sales_Order__r.System_Design_Quote__r.System_Design__c +  '&fromFactsheet=true').getContent().toString() ;
        }
        else
        {
            systemDesignArrayViewURL = 'Unit.Test';    
        }

        if(!Test.isRunningTest())
        {
            soldScenarioPricingURL = new PageReference('/apex/SoldScenarioItemizedPricing?id=' + project.Sales_Order__c).getContent().toString();
        }
        else
        {
            soldScenarioPricingURL = 'Unit.Test';    
        }

    }

    public List<Contact> contacts {
        get {
            if (contacts == null && project != null) {
                contacts = 
                    [SELECT Id, FirstName, LastName, Email, MobilePhone, HomePhone, Phone, Work_Phone__c 
                    FROM Contact
                    WHERE AccountId = :project.Sales_Order__r.AccountId__c];
            }
            return contacts;
        }
        private set;
    }

    public String installQRCode {
        get {
            Install_Project__c install;
            if (installQRCode == null && project != null) {
                 install =  
                    [SELECT Id, QR_Code__c
                    FROM Install_Project__c
                    WHERE PM_Project__C = :project.Id];
            }
            if(install != null)
            {
                return install.QR_Code__c;
            }
            else
            {
                return null;
            }
            
        }
        private set;
    }
    
    public List<Change_Request__c> changeRequests {
        get {
            if (changeRequests == null && project != null) {
                changeRequests = 
                    [SELECT Id, Name, Status__c,Type_1__c,Type_1_Detail__c, Reason_For_Change_1__c,Type_2__c, Type_2_Detail__c ,Reason_For_Change_2__c,CR_Overall_Status__c, Change_From__c, Change_To__c
                    FROM Change_Request__c
                    WHERE PM_Project__C = :project.Id order by CR_Overall_Status__c DESC];
            }
            return changeRequests ;
        }
        private set;
    }
    
    public String changeRequestSubmitted {
        get {
            if (changeRequestSubmitted  == null && project != null) {
              try{ 
                    List<Change_Request__c> changeRequests = 
                        [SELECT Id, Name, Type_1__c,Type_1_Detail__c, Reason_For_Change_1__c,Type_2__c, Type_2_Detail__c ,Reason_For_Change_2__c,CR_Overall_Status__c
                        FROM Change_Request__c
                        WHERE PM_Project__C = :project.Id and CR_Overall_Status__c != null order by CR_Overall_Status__c ];
                    
                    if(changeRequests.size() > 0)
                    {
                        for(Change_Request__c cr : changeRequests)
                        {
                            if(cr.CR_Overall_Status__c == 'S')
                                changeRequestSubmitted  = 'Change Request Submitted. DO NOT INSTALL. Talk to Operations Manager for Details.';
                            else if (cr.CR_Overall_Status__c == 'P')    
                                changeRequestSubmitted  = 'Change Request Pending. DO NOT INSTALL. Talk to Operations Manager for Details.';
                            else if (cr.CR_Overall_Status__c == 'C') 
                                changeRequestSubmitted  = 'This project has been changed. PLEASE CONFIRM that it is ready to install before installing.';    
                        }    
                    }    
                  
                }
               catch(Exception e)
               {
                   changeRequestSubmitted   = null;
               }                     
            }
            return changeRequestSubmitted ;
        }
        private set;
    }
    
    public String leaseFundStatusMessage {
        get {
            if (leaseFundStatusMessage  == null && project != null) {              
                if(project.Lease_Funding_status__c == 'Change Pending')
                    leaseFundStatusMessage = 'Change Pending - DO NOT INSTALL. Talk to Operations Manager for Details.';
                else if (project.Lease_Funding_status__c == 'Ready to Prepare')    
                    leaseFundStatusMessage = 'Change Pending - DO NOT INSTALL. Talk to Operations Manager for Details.';
                else if (project.Lease_Funding_status__c == 'Ready to Install') 
                    leaseFundStatusMessage = 'This project has been changed. PLEASE CONFIRM that it is ready to install before installing.';   
                else
                    leaseFundStatusMessage = null; 
             }   
                    
            return leaseFundStatusMessage;
        }
        private set;
    }
        
    
    public List<Install_Location__c> installLocations {
        get {
            if (installLocations == null && project != null) {
                installLocations = 
                    [SELECT id, Property__c, Name, Azimuth__c, Pitch__c, Number_of_Stories__c, Stuctural_Members__c, 
                        Surface_Type__c, TSRF__c 
                    FROM Install_Location__c 
                    WHERE Property__c = :project.Sales_Order__r.Property__c];
            }
            return installLocations;
        }
        private set; 
    }
    
    public List<Utility_Service__c> utilityServices {
        get {
            if (utilityServices == null && project != null) {
                utilityServices = 
                    [SELECT id, Property__c, Name, Service_Account_Number__c, Utility_Company__c, Amperage__c 
                    FROM Utility_Service__c 
                    WHERE Property__c = :project.Sales_Order__r.Property__c];
            }
            return utilityServices;
        }
        private set;
    }

    public List<CB_Panel__c> cbPanels {
        get {
            if (cbPanels == null && project != null) {
                cbPanels = 
                    [SELECT id, Name, Utility_Service__c, Panel_Location__c, Parent_CB_Panel__c, Main_Breaker_Rating_Amps__c, Bus_Rating_Amps__c 
                    FROM CB_Panel__c 
                    WHERE Utility_Service__c in :utilityServices];          
            }
            return cbPanels;
        }
        private set;
    }

    public List<System_Design_Array__c> systemDesignArrays {
        get {
            if (systemDesignArrays == null && project != null) {
                systemDesignArrays = 
                    [SELECT id, Name, Mounting_Type__c, Special_Parts_Required__c, Electrical_Adder__c, CB_Panel__c, Array_Size_kW__c, Items_On_Flat_Roof__c, 
                        Max_Install_Location_Pitch__c, Max_Install_Location_Stories__c, Panel_Count__c, Projected_Annual_Output_kWh_y__c 
                FROM System_Design_Array__c 
                WHERE System_Design__c = :project.Sales_Order__r.System_Design_Quote__r.System_Design__c];          
            }
            return systemDesignArrays;
        }
        private set;
    }

    public List<Price_Adjustment__c> priceAdjustments {
        get {
            if (priceAdjustments == null && project != null) {
                priceAdjustments = 
                    [SELECT Name,Amount__c,Amount_per_Watt__c,Percent__c,Type__c 
                       FROM Price_Adjustment__c 
                      WHERE System_Design_Quote__c = :project.Sales_Order__r.System_Design_Quote__c 
                        And Type__c = 'Line Item'];          
            }
            return priceAdjustments;
        }
        private set;
    }

    public List<System_Design_Item__c> systemDesignItems {
        get {
            if (systemDesignItems == null && project != null) {
                systemDesignItems = 
                    [SELECT id, System_Design_Array__c, Name, Property__c, Install_Location__c, Quantity__c, System_Design_Product__r.Description__c
                    FROM System_Design_Item__c 
                    WHERE System_Design_Array__c IN :systemDesignArrays 
                    ORDER BY System_Design_Array__c];           
            }
            return systemDesignItems;
        }
        private set;
    }
    
    public Document getNRGDocuments() {
    
        //List<Document> result;    
        
        Document result = [
        SELECT Id,Name  , Description
         FROM Document
         WHERE Folder.Name like 'NRG%' Limit 1 ];
    
    
    return result;
    
  } 
  
  public Document getSunnovaDocuments() {
    
        //List<Document> result;    
        
        Document result = [
        SELECT Id,Name  , Description
         FROM Document
         WHERE Folder.Name like 'Sunnova%' Limit 1 ];
    
    
    return result;
    
  } 
    
}