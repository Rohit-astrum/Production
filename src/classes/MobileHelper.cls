/* FILE: MobileHelper.cls
 * AUTHOR: Tino Mattheou
 * DATE: July 25, 2012
 * PURPOSE: Determines type of mobile device based on User-Agent string 
 * MODIFICATION HISTORY
 *
 */

public class MobileHelper {
	
	//android mobile, iphone, winphone, blackberry
	public static Boolean isPhone {
		get {
			return isAndroidMobile || isIPhone || isWindowsPhone || isBlackberry;
		}
	}

	//shows the user agent for the current page	
	public static String userAgent {
		get { 
			return userAgent;
		}
		private set;
	}
	
	public static Boolean isBlackberry {
		get { 
			if (userAgent == null) {
				checkUserAgent();
			}
			return isBlackberry;
		}
		private set; 
	}
	
	public static Boolean isIPhone { 
		get { 
			if (userAgent == null) {
				checkUserAgent();
			}
			return isIPhone;
		}
		private set; 
	}
	
  	public static Boolean isIPad {
		get { 
			if (userAgent == null) {
				checkUserAgent();
			}
			return isIPad;
		}
		private set; 
	}
	
  	public static boolean isAndroidMobile {
		get { 
			if (userAgent == null) {
				checkUserAgent();
			}
			return isAndroidMobile;
		}
		private set; 
	}

  	public static boolean isAndroidTablet {
		get { 
			if (userAgent == null) {
				checkUserAgent();
			}
			return isAndroidTablet;
		}
		private set; 
	}
	
	public static boolean isWindowsPhone {
		get { 
			if (userAgent == null) {
				checkUserAgent();
			}
			return isWindowsPhone;
		}
		private set; 
	}
  	
	private static void checkUserAgent() {

		userAgent = System.currentPageReference().getHeaders().get('User-Agent');
		
		isIPhone = userAgent.contains('iPhone');
		
        isIPad = userAgent.contains('iPad');
        
        isBlackberry = userAgent.contains('BlackBerry');
        
        isAndroidMobile = userAgent.contains('Android') && userAgent.contains('Mobile');

        isAndroidTablet = userAgent.contains('Android') && !userAgent.contains('Mobile');
        
        isWindowsPhone = userAgent.contains('MSIE') && userAgent.contains('Windows Phone OS');
    }

}