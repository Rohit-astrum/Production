public with sharing class Milestone1_General_Utility {
	
	/**
	 * Get the state code from an office
	 *
	 * Input: 'Norristown, PA'  ->  Output: 'PA'
	 * Input: 'MA'  ->  Output: 'MA'
	 *
	 */
	public static String getStateFromAstrumOffice(String astrumOffice) {
		List<String> data = astrumOffice.split(',');		
		Integer index = data.size() - 1;		
		String state = data[index].trim();		
		return state;
	}
	
	/**
	 * Truncate id from 18 digits to 15 digits.
	 */
	public static String truncateId(String theId) {
		// project id is 18 digits
		// truncate to 15 digits
		
		// we can safely truncate to 15 digits based on
		// - http://www.salesforce.com/us/developer/docs/api/Content/field_types.htm#i1435616
		// - http://stackoverflow.com/questions/6688508/visualforceapex-update-record-with-known-id/6688547#6688547					

		Integer length = theId.length();
		
		String shortId = null;
		
		if (length == 18) {
			shortId = theId.substring(0, length-3);
		}
		else if (length == 15) {
			shortId = theId;
		}
		else {
			shortId = null;
		}
		
		return shortId;
	}
	
    public static String processTaskName(String name) {
        String nameString = name;
        
        if(nameString.length() >= 80) {
            nameString = nameString.subString(0,76);
            Integer lastSpaceLocation = Milestone1_General_Utility.truncateStringAtSpace(nameString);

            if(lastSpaceLocation > -1) {
                nameString = nameString.subString(0,lastSpaceLocation);
            }
            
            nameString = namesTring + '...';
        }

        return nameString;
    }

	/**
    * Checks if the current User have Permissions like System Admin
    * @return 		boolean
    * @author 		Sebastian Muñoz
    * @createDate 	January 19, 2011
    */
    public static Boolean isSysAdmin() {
    	Profile pObj = [SELECT PermissionsModifyAllData, Id FROM Profile WHERE Id=:Userinfo.getProfileId() limit 1];
		return pObj.PermissionsModifyAllData;
    }
    
    public static Integer truncateStringAtSpace(String inputString) {
        Integer location = inputString.lastIndexOf(' ');
        return location;
    }

}