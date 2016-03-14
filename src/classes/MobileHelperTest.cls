/* FILE: MobileHelperTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: July 25, 2012
 * PURPOSE: Tests MobileHelper using known User-Agent strings 
 * MODIFICATION HISTORY
 *
 */
 
public class MobileHelperTest {

	static testMethod void testAndroidMobile() {
		PageReference pg = Page.PortalMobileNewReferral;
		pg.getHeaders().put('User-Agent', 'Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1');
		Test.setCurrentPage(pg);
		System.assertEquals(true, MobileHelper.isAndroidMobile);
	}

	static testMethod void testAndroidMobile2() {
		PageReference pg = Page.PortalMobileNewReferral;
		pg.getHeaders().put('User-Agent', 'Mozilla/5.0 (Linux; U; Android 2.1-update1; de-de; HTC Desire 1.19.161.5 Build/ERE27) AppleWebKit/530.17 (KHTML, like Gecko) Version/4.0 Mobile Safari/530.17');
		Test.setCurrentPage(pg);
		System.assertEquals(true, MobileHelper.isAndroidMobile);
	}

	static testMethod void testAndroidMobile3() {
		PageReference pg = Page.PortalMobileNewReferral;
		pg.getHeaders().put('User-Agent', 'Mozilla/5.0 (Linux; U; Android 2.2; en-us; DROID2 GLOBAL Build/S273) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1');
		Test.setCurrentPage(pg);
		System.assertEquals(true, MobileHelper.isAndroidMobile);
	}

	static testMethod void testAndroidTablet() {
		System.debug(MobileHelper.userAgent);
		PageReference pg = Page.PortalMobileNewReferral;
		pg.getHeaders().put('User-Agent', 'Mozilla/5.0 (Linux; U; Android 3.0; en-us; Xoom Build/HRI39) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13');
		Test.setCurrentPage(pg);
		System.assertEquals(true, MobileHelper.isAndroidTablet);
	}
	
	static testMethod void testIPhone() {
		System.debug(MobileHelper.userAgent);
		PageReference pg = Page.PortalMobileNewReferral;
		pg.getHeaders().put('User-Agent', 'Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3');
		Test.setCurrentPage(pg);
		System.assertEquals(true, MobileHelper.isIphone);
	}

	static testMethod void testIPhone2() {
		System.debug(MobileHelper.userAgent);
		PageReference pg = Page.PortalMobileNewReferral;
		pg.getHeaders().put('User-Agent', 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16');
		Test.setCurrentPage(pg);
		System.assertEquals(true, MobileHelper.isIphone);
	}
	
	static testMethod void testIPad() {
		System.debug(MobileHelper.userAgent);
		PageReference pg = Page.PortalMobileNewReferral;
		pg.getHeaders().put('User-Agent', 'Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.10');
		Test.setCurrentPage(pg);
		System.assertEquals(true, MobileHelper.isIPad);
	}

	static testMethod void testBlackberry() {
		System.debug(MobileHelper.userAgent);
		PageReference pg = Page.PortalMobileNewReferral;
		pg.getHeaders().put('User-Agent', 'Mozilla/5.0 (BlackBerry; U; BlackBerry AAAA; en-US) AppleWebKit/534.11+ (KHTML, like Gecko) Version/X.X.X.X Mobile Safari/534.11+');
		Test.setCurrentPage(pg);
		System.assertEquals(true, MobileHelper.isBlackberry);
	}

	static testMethod void testWindowsPhone() {
		System.debug(MobileHelper.userAgent);
		PageReference pg = Page.PortalMobileNewReferral;
		pg.getHeaders().put('User-Agent', 'Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0; SAMSUNG; SGH-i917)');
		Test.setCurrentPage(pg);
		System.assertEquals(true, MobileHelper.isWindowsPhone);
	}
	
}