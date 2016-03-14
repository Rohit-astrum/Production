/* FILE: LeadTrigger_BI.cls
 * AUTHOR: Rohit Jain
 * DATE: June 19, 2014
 * PURPOSE: Copy Web to Lead Referral Id to Referral Account
 * MODIFICATION HISTORY
 * 12/09/2014 PB - MARK-40 Change lead status to Unresponsive upon 6th(nth) dial
 * 09/10/2015 PB - FPO-Phase4
 *
 */
trigger LeadTrigger_BI on Lead (before insert, before update) {
	
	//FPO-Phase4
	Set<String> leadzipcodes = new Set<String>();
	for(Lead newLead:Trigger.new){
		if(String.isNotBlank(newLead.PostalCode) && newLead.PostalCode.length() >= 5 ){
			leadzipcodes.add(newLead.PostalCode.substring(0,5));
		}
	}
	Map<String,Id> officezipcodeMap = new Map<String,Id>();
	List<Office_Zip_Code__c> officeZipCodes = new List<Office_Zip_Code__C>();
	officeZipCodes = [SELECT Name, Office_Location__c 
						FROM Office_Zip_Code__c 
						WHERE Office_Location__r.Active__c = true 
						AND Name in:leadzipcodes];
	for(Office_Zip_Code__c officeZip: officeZipCodes){
		officezipcodeMap.put(officeZip.Name,officeZip.Office_Location__c);
	}

	if(Trigger.isInsert){
		for(Lead newLead:Trigger.new){       
	        if (newLead.Web_To_Lead_Referral_Account_Id__c !=null) {            
	            String acctTextId = newLead.Web_To_Lead_Referral_Account_Id__c;           
	            Id acctID = acctTextId ;           
	            newLead.Referring_Account__c = acctID;

	        }

	        //FPO-Phase4 office assignment
            if(String.isNotBlank(newLead.PostalCode) && newLead.PostalCode.length() >= 5 && officezipcodeMap.containsKey(newLead.PostalCode.substring(0,5))){
            	newLead.Orig_Company_Office__c = officezipcodeMap.get(newLead.PostalCode.substring(0,5));
            	newLead.Current_Company_Office__c = officezipcodeMap.get(newLead.PostalCode.substring(0,5));
            }     
    	}   
	}

	if(Trigger.isUpdate){
		
        Map<Id, Lead> mnl = Trigger.newMap;
        Map<Id, Lead> mol = Trigger.oldMap;
        
        for(Id i:mnl.KeySet()){
            if(((mnl.get(i)).qbdialer__Dials__c == Lead_Status_Change_Setting__c.getOrgDefaults().Number_Of_Dials__c)
               && ( (mol.get(i)).qbdialer__Dials__c == (mnl.get(i)).qbdialer__Dials__c - 1 )       
            ){
                (mnl.get(i)).status = 'Unresponsive';
                (mnl.get(i)).OwnerId = UserInfo.getUserId();               
                
            }

            //FPO-Phase4 office assignment
            if(String.isNotBlank((mnl.get(i)).PostalCode)
            	&& (mnl.get(i)).PostalCode.length() >= 5
				&& officezipcodeMap.containsKey((mnl.get(i)).PostalCode.substring(0,5))
				&& ((mnl.get(i)).PostalCode != (mol.get(i)).PostalCode)
				)//String.isBlank((mnl.get(i)).Current_Company_Office__c) 
            {
            	(mnl.get(i)).Current_Company_Office__c = officezipcodeMap.get((mnl.get(i)).PostalCode.substring(0,5));
            	if(String.isBlank((mnl.get(i)).Orig_Company_Office__c)){
            		(mnl.get(i)).Orig_Company_Office__c = (mnl.get(i)).Current_Company_Office__c;
            	}
            }  
        }
	}     
}