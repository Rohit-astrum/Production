/* FILE: DocumentConfigurationHelper.cls
 * AUTHOR: Tino Mattheou
 * DATE: March 26, 2012
 * PURPOSE: Astrum PM Bin/Category Document Configuration
 * MODIFICATION HISTORY:
 * 4/2/2012 TCM - added new config options
 */ 
 
public class DocumentConfigurationHelper {
	
	public static final String APP_ASTRUM_PM_20 = 'Astrum PM 2.0';
	public static final String APP_ASTRUM_GRANTS = 'Astrum Grants';

	public static List<Bin_Configuration__c> getBins(String appName) {
		
		List<Bin_Configuration__c> configuration = 
			[SELECT Id, Bin__c, Bin_Grouping_Name__c, Field_Name__c, Bin_Column_Width__c
			FROM Bin_Configuration__c
			WHERE Astrum_Application__r.Name = :appName 	
			ORDER BY Bin_Order__c, Bin__c];

		return configuration;
	}

	public static List<Category_Configuration__c> getBinCategories(String appName, String binName) { 
	
		LIST<Category_Configuration__c> configuration = 
			[SELECT Id, Bin__c, Category__c, Category_Order_In_Bin__c, Document_Types_Restriction__c, 
					Maximum_Allowed__c, Minimum_Required__c,
					Document_Date_Required__c, Document_Bin_State__c, Field_Name__c 
			FROM Category_Configuration__c
			WHERE Bin__c = :binName
			AND Astrum_Application__r.Name = :appName 	
			ORDER BY Category_Order_In_Bin__c, Category__c];
			
		return configuration;
	}
	
	public static List<Category_Configuration__c> getAllCategories(String appName) { 
	
		LIST<Category_Configuration__c> configuration = 
			[SELECT Id, Bin__c, Category__c, Category_Order_In_Bin__c, Document_Types_Restriction__c, 
					Maximum_Allowed__c, Minimum_Required__c,
					Document_Date_Required__c, Document_Bin_State__c, Field_Name__c 
			FROM Category_Configuration__c
			WHERE Astrum_Application__r.Name = :appName 	
			ORDER BY Bin__c, Category_Order_In_Bin__c, Category__c];
			
		return configuration;
	}
	
	//returns categories in bins with 
	public static List<SpecialCategory> getSpecialCategories(String appName) {
		List<SpecialCategory> result = new List<SpecialCategory>();
		Map<String, String> binToDateMap = new Map<String, String>();
		
		Astrum_Application__c config = 
			[SELECT Id,
				(SELECT Bin__c, Field_Name__c 
				FROM Bin_Configuration__r), 
				(SELECT Bin__c, Field_Name__c, Category__c, Category_Order_In_Bin__c, Document_Bin_State__c 
				FROM Category_Configuration__r 
				WHERE Field_Name__c <> null
				ORDER BY Category_Order_In_Bin__c) 
			FROM Astrum_Application__c 
			WHERE Name = :appName];
			
		for (Bin_Configuration__c bin : config.Bin_Configuration__r) {
			binToDateMap.put(bin.Bin__c, bin.Field_Name__c);
		}
		
		//only include categories that don't match the bin date
		for (Category_Configuration__c cat : config.Category_Configuration__r) {
			String binFieldName = binToDateMap.get(cat.Bin__c);
			if (binFieldName != cat.Field_Name__c) {
				SpecialCategory sg = new SpecialCategory();
				sg.binName = cat.Bin__c;
				sg.categoryName = cat.Category__c;
				sg.categoryOrderInBin = cat.Category_Order_In_Bin__c; 
				sg.binDateFieldName = binFieldName;
				sg.categoryDateFieldName = cat.Field_Name__c;
				sg.binState = cat.Document_Bin_State__c;
				result.add(sg);
			}
		}
		
		return result;
	} 	
	
	public class SpecialCategory {
		public String binName;
		public String categoryName;
		public Double categoryOrderInBin;
		public String binDateFieldName;
		public String categoryDateFieldName;
		public String binState;
	}

}