trigger Project_Status_Update on Data_Tracking_Project__c (before update, before insert){
 
List<Data_Tracking_Project__c> recs = Trigger.new;
 
for(Data_Tracking_Project__c l:recs){

 if(
(l.Account_ID__c=='Already Correct' || l.Account_ID__c== 'Added' || l.Account_ID__c== 'Corrected')&&
 
(l.Address__c == 'Already Correct' || l.Address__c== 'Added' || l.Address__c== 'Corrected') &&
 
(l.Attachment_Installed_System__c  == 'Already Correct' || l.Attachment_Installed_System__c== 'Added' || l.Attachment_Installed_System__c== 'Corrected')&&
 
(l.Billing_Address__c  == 'Already Correct' || l.Billing_Address__c== 'Added' || l.Billing_Address__c== 'Corrected')&&
 
(l.CB_Panel__c == 'Already Correct' || l.CB_Panel__c== 'Added' || l.CB_Panel__c== 'Corrected')&&
 
(l.Contact__c  == 'Already Correct' || l.Contact__c== 'Added' || l.Contact__c== 'Corrected')&&
 
(l.Contact_Role_Contract__c  == 'Already Correct' || l.Contact_Role_Contract__c  == 'Added' || l.Contact_Role_Contract__c  == 'Corrected')&&
 
(l.Contact_Role__c == 'Already Correct' || l.Contact_Role__c  == 'Added' || l.Contact_Role__c  == 'Corrected')&&
 
(l.Contact_Role_Grant__c == 'Already Correct' || l.Contact_Role_Grant__c == 'Added' || l.Contact_Role_Grant__c == 'Corrected')&&
 
(l.Contact_Role_SREC_Contract__c    == 'Already Correct' || l.Contact_Role_SREC_Contract__c  == 'Added' || l.Contact_Role_SREC_Contract__c  == 'Corrected')&&
 
(l.Contract_Matches_SO__c  == 'Already Correct' || l.Contract_Matches_SO__c  == 'Added' || l.Contract_Matches_SO__c  == 'Corrected')&&
 
(l.Contract_Uploaded__c   == 'Already Correct' || l.Contract_Uploaded__c  == 'Added' || l.Contract_Uploaded__c  == 'Corrected')&&
 
(l.Enphase_ID__c == 'Already Correct' || l.Enphase_ID__c == 'Added' || l.Enphase_ID__c  == 'Corrected')&&
 
(l.Generation_Start_Date__c == 'Already Correct' || l.Generation_Start_Date__c == 'Added' || l.Generation_Start_Date__c == 'Corrected')&&
 
(l.Inspection_Date__c == 'Already Correct' || l.Inspection_Date__c == 'Added' || l.Inspection_Date__c == 'Corrected')&&
 
(l.Installation_Date__c == 'Already Correct' || l.Installation_Date__c == 'Added' || l.Installation_Date__c == 'Corrected')&&
 
(l.Installed_Inverter__c == 'Already Correct' || l.Installed_Inverter__c == 'Added' || l.Installed_Inverter__c == 'Corrected')&&
 
(l.Installed_Panel__c  == 'Already Correct' || l.Installed_Panel__c == 'Added' || l.Installed_Panel__c == 'Corrected')&&
 
(l.Installed_System_Picklist__c == 'Already Correct' || l.Installed_System_Picklist__c == 'Added' || l.Installed_System_Picklist__c == 'Corrected')&&
 
(l.Install_Locations__c == 'Already Correct' || l.Install_Locations__c == 'Added' || l.Install_Locations__c == 'Corrected')&&
 
(l.Jpeg_Uploaded__c == 'Already Correct' || l.Jpeg_Uploaded__c == 'Added' || l.Jpeg_Uploaded__c == 'Corrected')&&
 
(l.Multiple_Contact_Roles__c  == 'Already Correct' || l.Multiple_Contact_Roles__c == 'Added' || l.Multiple_Contact_Roles__c == 'Corrected')&&
 
(l.Name__c == 'Already Correct' || l.Name__c == 'Added' || l.Name__c == 'Corrected')&&
 
(l.Opportunity_Picklist__c == 'Already Correct' || l.Opportunity_Picklist__c == 'Added' || l.Opportunity_Picklist__c == 'Corrected')&&
 
(l.Paid_in_Full_Date__c == 'Already Correct' || l.Paid_in_Full_Date__c == 'Added' || l.Paid_in_Full_Date__c == 'Corrected')&&
 
(l.Pitch_and_Azimuth__c == 'Already Correct' || l.Pitch_and_Azimuth__c == 'Added' || l.Pitch_and_Azimuth__c == 'Corrected')&&
 
(l.PJM_ID__c == 'Already Correct' || l.PJM_ID__c == 'Added' || l.PJM_ID__c == 'Corrected')&&
 
(l.Production_Start_Date__c == 'Already Correct' || l.Production_Start_Date__c == 'Added' || l.Production_Start_Date__c == 'Corrected')&&
 
(l.Project_Lead__c == 'Already Correct' || l.Project_Lead__c == 'Added' || l.Project_Lead__c == 'Corrected')&&
 
(l.Project_Picklist__c == 'Already Correct' || l.Project_Picklist__c == 'Added' || l.Project_Picklist__c == 'Corrected')&&
 
(l.Property_Picklist__c == 'Already Correct' || l.Property_Picklist__c == 'Added' || l.Property_Picklist__c == 'Corrected')&&
 
(l.Sales_Order_Picklist__c == 'Already Correct' || l.Sales_Order_Picklist__c == 'Added' || l.Sales_Order_Picklist__c == 'Corrected')&&
 
(l.SDQ_Matches_Contract__c == 'Already Correct' || l.SDQ_Matches_Contract__c == 'Added' || l.SDQ_Matches_Contract__c == 'Corrected')&&
 
(l.System_Design_Array__c == 'Already Correct' || l.System_Design_Array__c == 'Added' || l.System_Design_Array__c == 'Corrected')&&
 
(l.System_Design_Items__c == 'Already Correct' || l.System_Design_Items__c == 'Added' || l.System_Design_Items__c == 'Corrected')&&
 
(l.System_Design_Quote__c == 'Already Correct' || l.System_Design_Quote__c == 'Added' || l.System_Design_Quote__c == 'Corrected')&&
 
(l.System_Makeup_Opp__c == 'Already Correct' || l.System_Makeup_Opp__c == 'Added' || l.System_Makeup_Opp__c == 'Corrected')&&
 
(l.System_Makeup_SO__c == 'Already Correct' || l.System_Makeup_SO__c == 'Added' || 
l.System_Makeup_SO__c == 'Corrected')&&
 
(l.TSRF__c == 'Already Correct' || l.TSRF__c == 'Added' || l.TSRF__c == 'Corrected')&&
 
(l.Utility__c == 'Already Correct' || l.Utility__c == 'Added' || l.Utility__c == 'Corrected')&&  

(l.Panel_Serial_Numbers_Leased_Systems_Onl__c == 'Already Correct' || l.Panel_Serial_Numbers_Leased_Systems_Onl__c == 'Added' || l.Panel_Serial_Numbers_Leased_Systems_Onl__c == 'Corrected')&& 

(l.Inverter_Serial_Numbers__c == 'Already Correct' || l.Inverter_Serial_Numbers__c == 'Added' || l.Inverter_Serial_Numbers__c == 'Corrected')&&

(l.System_Design_Q__c!=null)&&(l.Account__c!=null)&&(l.Opportunity__c!=null)&&(l.Property__c!=null)&&(l.Sales_Order__c!=null)&&(l.Project__c!=null)&&(l.Installed_System__c!=null)&&

(l.Account_Check__c==true)&&(l.Sales_Check__c==true)&&(l.Ops_Check__c==true)

){l.Project_Status__c='Completed';}

else if(
(l.Account_ID__c=='Already Correct' || l.Account_ID__c== 'Added' || l.Account_ID__c== 'Corrected')&&
 
(l.Address__c == 'Already Correct' || l.Address__c== 'Added' || l.Address__c== 'Corrected') &&
 
(l.Attachment_Installed_System__c  == 'Already Correct' || l.Attachment_Installed_System__c== 'Added' || l.Attachment_Installed_System__c== 'Corrected')&&
 
(l.Billing_Address__c  == 'Already Correct' || l.Billing_Address__c== 'Added' || l.Billing_Address__c== 'Corrected')&&
 
(l.CB_Panel__c == 'Already Correct' || l.CB_Panel__c== 'Added' || l.CB_Panel__c== 'Corrected')&&
 
(l.Contact__c  == 'Already Correct' || l.Contact__c== 'Added' || l.Contact__c== 'Corrected')&&
 
(l.Contact_Role_Contract__c  == 'Already Correct' || l.Contact_Role_Contract__c  == 'Added' || l.Contact_Role_Contract__c  == 'Corrected')&&
 
(l.Contact_Role__c == 'Already Correct' || l.Contact_Role__c  == 'Added' || l.Contact_Role__c  == 'Corrected')&&
 
(l.Contact_Role_Grant__c == 'Already Correct' || l.Contact_Role_Grant__c == 'Added' || l.Contact_Role_Grant__c == 'Corrected')&&
 
(l.Contact_Role_SREC_Contract__c    == 'Already Correct' || l.Contact_Role_SREC_Contract__c  == 'Added' || l.Contact_Role_SREC_Contract__c  == 'Corrected')&&
 
(l.Contract_Matches_SO__c  == 'Already Correct' || l.Contract_Matches_SO__c  == 'Added' || l.Contract_Matches_SO__c  == 'Corrected')&&
 
(l.Contract_Uploaded__c   == 'Already Correct' || l.Contract_Uploaded__c  == 'Added' || l.Contract_Uploaded__c  == 'Corrected')&&
 
(l.Enphase_ID__c == 'Already Correct' || l.Enphase_ID__c == 'Added' || l.Enphase_ID__c  == 'Corrected')&&
 
(l.Generation_Start_Date__c == 'Already Correct' || l.Generation_Start_Date__c == 'Added' || l.Generation_Start_Date__c == 'Corrected')&&
 
(l.Inspection_Date__c == 'Already Correct' || l.Inspection_Date__c == 'Added' || l.Inspection_Date__c == 'Corrected')&&
 
(l.Installation_Date__c == 'Already Correct' || l.Installation_Date__c == 'Added' || l.Installation_Date__c == 'Corrected')&&
 
(l.Installed_Inverter__c == 'Already Correct' || l.Installed_Inverter__c == 'Added' || l.Installed_Inverter__c == 'Corrected')&&
 
(l.Installed_Panel__c  == 'Already Correct' || l.Installed_Panel__c == 'Added' || l.Installed_Panel__c == 'Corrected')&&
 
(l.Installed_System_Picklist__c == 'Already Correct' || l.Installed_System_Picklist__c == 'Added' || l.Installed_System_Picklist__c == 'Corrected')&&
 
(l.Install_Locations__c == 'Already Correct' || l.Install_Locations__c == 'Added' || l.Install_Locations__c == 'Corrected')&&
 
(l.Jpeg_Uploaded__c == 'Already Correct' || l.Jpeg_Uploaded__c == 'Added' || l.Jpeg_Uploaded__c == 'Corrected')&&
 
(l.Multiple_Contact_Roles__c  == 'Already Correct' || l.Multiple_Contact_Roles__c == 'Added' || l.Multiple_Contact_Roles__c == 'Corrected')&&
 
(l.Name__c == 'Already Correct' || l.Name__c == 'Added' || l.Name__c == 'Corrected')&&
 
(l.Opportunity_Picklist__c == 'Already Correct' || l.Opportunity_Picklist__c == 'Added' || l.Opportunity_Picklist__c == 'Corrected')&&
 
(l.Paid_in_Full_Date__c == 'Already Correct' || l.Paid_in_Full_Date__c == 'Added' || l.Paid_in_Full_Date__c == 'Corrected')&&
 
(l.Pitch_and_Azimuth__c == 'Already Correct' || l.Pitch_and_Azimuth__c == 'Added' || l.Pitch_and_Azimuth__c == 'Corrected')&&
 
(l.PJM_ID__c == 'Already Correct' || l.PJM_ID__c == 'Added' || l.PJM_ID__c == 'Corrected')&&
 
(l.Production_Start_Date__c == 'Already Correct' || l.Production_Start_Date__c == 'Added' || l.Production_Start_Date__c == 'Corrected')&&
 
(l.Project_Lead__c == 'Already Correct' || l.Project_Lead__c == 'Added' || l.Project_Lead__c == 'Corrected')&&
 
(l.Project_Picklist__c == 'Already Correct' || l.Project_Picklist__c == 'Added' || l.Project_Picklist__c == 'Corrected')&&
 
(l.Property_Picklist__c == 'Already Correct' || l.Property_Picklist__c == 'Added' || l.Property_Picklist__c == 'Corrected')&&
 
(l.Sales_Order_Picklist__c == 'Already Correct' || l.Sales_Order_Picklist__c == 'Added' || l.Sales_Order_Picklist__c == 'Corrected')&&
 
(l.SDQ_Matches_Contract__c == 'Already Correct' || l.SDQ_Matches_Contract__c == 'Added' || l.SDQ_Matches_Contract__c == 'Corrected')&&
 
(l.System_Design_Array__c == 'Already Correct' || l.System_Design_Array__c == 'Added' || l.System_Design_Array__c == 'Corrected')&&
 
(l.System_Design_Items__c == 'Already Correct' || l.System_Design_Items__c == 'Added' || l.System_Design_Items__c == 'Corrected')&&
 
(l.System_Design_Quote__c == 'Already Correct' || l.System_Design_Quote__c == 'Added' || l.System_Design_Quote__c == 'Corrected')&&
 
(l.System_Makeup_Opp__c == 'Already Correct' || l.System_Makeup_Opp__c == 'Added' || l.System_Makeup_Opp__c == 'Corrected')&&
 
(l.System_Makeup_SO__c == 'Already Correct' || l.System_Makeup_SO__c == 'Added' || 
l.System_Makeup_SO__c == 'Corrected')&&
 
(l.TSRF__c == 'Already Correct' || l.TSRF__c == 'Added' || l.TSRF__c == 'Corrected')&&
 
(l.Utility__c == 'Already Correct' || l.Utility__c == 'Added' || l.Utility__c == 'Corrected')&&  

(l.Panel_Serial_Numbers_Leased_Systems_Onl__c == 'Already Correct' || l.Panel_Serial_Numbers_Leased_Systems_Onl__c == 'Added' || l.Panel_Serial_Numbers_Leased_Systems_Onl__c == 'Corrected')&& 

(l.Inverter_Serial_Numbers__c == 'Already Correct' || l.Inverter_Serial_Numbers__c == 'Added' || l.Inverter_Serial_Numbers__c == 'Corrected')&&

(l.System_Design_Q__c!=null)&&(l.Account__c!=null)&&(l.Opportunity__c!=null)&&(l.Property__c!=null)&&(l.Sales_Order__c!=null)&&(l.Project__c!=null)&&(l.Installed_System__c!=null)

){l.Project_Status__c='Ready for Check';}

else if((l.Account_ID__c !=null)&&
 
(l.Address__c != null) &&
 
(l.Attachment_Installed_System__c != null)&&
 
(l.Billing_Address__c != null)&&
 
(l.CB_Panel__c != null)&&
 
(l.Contact__c  != null)&&
 
(l.Contact_Role_Contract__c  != null)&&
 
(l.Contact_Role__c != null)&&
 
(l.Contact_Role_Grant__c != null)&&
 
(l.Contact_Role_SREC_Contract__c != null)&&
 
(l.Contract_Matches_SO__c  != null)&&
 
(l.Contract_Uploaded__c   != null)&&
 
(l.Enphase_ID__c != null)&&
 
(l.Generation_Start_Date__c != null)&&
 
(l.Inspection_Date__c != null)&&
 
(l.Installation_Date__c != null)&&
 
(l.Installed_Inverter__c != null)&&
 
(l.Installed_Panel__c  != null)&&
 
(l.Installed_System_Picklist__c != null)&&
 
(l.Install_Locations__c != null)&&
 
(l.Jpeg_Uploaded__c != null)&&
 
(l.Multiple_Contact_Roles__c  != null)&&
 
(l.Name__c != null)&&
 
(l.Opportunity_Picklist__c != null)&&
 
(l.Paid_in_Full_Date__c != null)&&
 
(l.Pitch_and_Azimuth__c != null)&&
 
(l.PJM_ID__c != null)&&
 
(l.Production_Start_Date__c != null)&&
 
(l.Project_Lead__c != null)&&
 
(l.Project_Picklist__c != null)&&
 
(l.Property_Picklist__c != null)&&
 
(l.Sales_Order_Picklist__c != null)&&
 
(l.SDQ_Matches_Contract__c != null)&&
 
(l.System_Design_Array__c != null)&&
 
(l.System_Design_Items__c != null)&&
 
(l.System_Design_Quote__c != null)&&
 
(l.System_Makeup_Opp__c != null)&&
 
(l.System_Makeup_SO__c != null)&&
 
(l.TSRF__c != null)&&
 
(l.Utility__c != null)&&

(l.Panel_Serial_Numbers_Leased_Systems_Onl__c !=null)&& 

(l.Inverter_Serial_Numbers__c != null)&&

(l.System_Design_Q__c!=null)&&(l.Account__c!=null)&&(l.Opportunity__c!=null)&&(l.Property__c!=null)&&(l.Sales_Order__c!=null)&&(l.Project__c!=null)&&(l.Installed_System__c!=null)
){l.Project_Status__c='Needs Review';}

else if((l.Account_ID__c ==null)&&
 
(l.Address__c == null) &&
 
(l.Attachment_Installed_System__c == null)&&
 
(l.Billing_Address__c == null)&&
 
(l.CB_Panel__c == null)&&
 
(l.Contact__c  == null)&&
 
(l.Contact_Role_Contract__c  == null)&&
 
(l.Contact_Role__c == null)&&
 
(l.Contact_Role_Grant__c == null)&&
 
(l.Contact_Role_SREC_Contract__c == null)&&
 
(l.Contract_Matches_SO__c  == null)&&
 
(l.Contract_Uploaded__c   == null)&&
 
(l.Enphase_ID__c == null)&&
 
(l.Generation_Start_Date__c == null)&&
 
(l.Inspection_Date__c == null)&&
 
(l.Installation_Date__c == null)&&
 
(l.Installed_Inverter__c == null)&&
 
(l.Installed_Panel__c  == null)&&
 
(l.Installed_System_Picklist__c == null)&&
 
(l.Install_Locations__c == null)&&
 
(l.Jpeg_Uploaded__c == null)&&
 
(l.Multiple_Contact_Roles__c  == null)&&
 
(l.Name__c == null)&&
 
(l.Opportunity_Picklist__c == null)&&
 
(l.Paid_in_Full_Date__c == null)&&
 
(l.Pitch_and_Azimuth__c == null)&&
 
(l.PJM_ID__c == null)&&
 
(l.Production_Start_Date__c == null)&&
 
(l.Project_Lead__c == null)&&
 
(l.Project_Picklist__c == null)&&
 
(l.Property_Picklist__c == null)&&
 
(l.Sales_Order_Picklist__c == null)&&
 
(l.SDQ_Matches_Contract__c == null)&&
 
(l.System_Design_Array__c == null)&&
 
(l.System_Design_Items__c == null)&&
 
(l.System_Design_Quote__c == null)&&
 
(l.System_Makeup_Opp__c == null)&&
 
(l.System_Makeup_SO__c == null)&&
 
(l.TSRF__c == null)&&
 
(l.Utility__c == null)&&

(l.Panel_Serial_Numbers_Leased_Systems_Onl__c ==null)&& 

(l.Inverter_Serial_Numbers__c == null)&&

(l.System_Design_Q__c==null)&&(l.Account__c==null)&&(l.Opportunity__c==null)&&(l.Property__c==null)&&(l.Sales_Order__c==null)&&(l.Project__c==null)&&(l.Installed_System__c==null)
){l.Project_Status__c='Not Started';}

else{l.Project_Status__c='In Progress';}
}
}