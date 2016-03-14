public with sharing class String_Utils {

	public static String getDefaultStringWithComma(String data) {
		String result = null;
		
		if (data == null || data.trim().length() == 0) {
			result = '';
		}
		else {
			result = data + ', ';
		}
		
		return result;
	}
	
	public static String getDefaultString(String data) {
		String result = null;
		
		if (data == null || data.trim().length() == 0) {
			result = '';
		}
		else {
			result = data;
		}

		return result;
	}

	public static String toStringYesNo(Boolean flag) {
		String result = null;
		
		if ((flag != null) && flag) {
			result = 'Yes';
		}
		else {
			result = 'No';
		}
		
		return result;
	}
}