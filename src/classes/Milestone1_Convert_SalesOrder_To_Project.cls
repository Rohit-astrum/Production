global with sharing class Milestone1_Convert_SalesOrder_To_Project {

	webService static Id CreateProjectFromSalesOrder(String SalesOrderId) { 
        	
        	Milestone1_Settings__c orgDefaultSettings = Milestone1_Settings__c.getOrgDefaults();
			String ProjTemplateId = orgDefaultSettings.Project_Template_Id__c;
        	String xml;
        	List<Document> docs = [Select Id, Body, ContentType From Document Where Id = :ProjTemplateId limit 1];
	        if(docs.size() != 0) {
	            xml = docs.get(0).body.toString();
	        } else {
	            throw new Milestone1_Import_Exception(Milestone1_Import_Exception.ERROR_NO_FILE_SELECTED);
	        }

            Milestone1_XML_Import_Utility importUtility = new Milestone1_XML_Import_Utility();
            Milestone1_Project__c project = importUtility.importProject(xml, SalesOrderId);
                       
            //Integer start = System.Now().millisecond();
        	//Wait 5 seconds for triggers to complete
        	//while(System.Now().millisecond()< start+5000){}
             
           	List<Milestone1_Milestone__c> milestoneDeleteList = [
				Select id 
				from Milestone1_Milestone__c
				Where Milestone1_Milestone__c.To_Be_Deleted__c = true];
			List<Milestone1_Task__c> taskDeleteList = [
				Select id 
				from Milestone1_Task__c
				Where Milestone1_Task__c.To_Be_Deleted__c = true];
		
			delete milestoneDeleteList;
			delete taskDeleteList;
         
        return project.id; 
    }



}