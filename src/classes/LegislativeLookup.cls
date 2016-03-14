public class LegislativeLookup {
	
	public static String getLegislativeDistrict(Decimal latitude, Decimal longitude) {
	
		Http h = new Http();

	    HttpRequest req = new HttpRequest();
	    req.setEndpoint('http://congress.mcommons.com/districts/lookup.xml?lat=' + latitude + '&lng=' + longitude);
	    req.setMethod('GET');

    	HttpResponse res = h.send(req);
    	
    	Dom.Document doc = res.getBodyDocument();
    	
    	Dom.XmlNode response = doc.getRootElement();
    	String congressionalDistrict = response.getChildElement('federal', null).getChildElement('district', null).getText(); 
    	String legislativeDistrict = response.getChildElement('state_lower', null).getChildElement('district', null).getText(); 
    	
    	return congressionalDistrict + '/' + legislativeDistrict;
	
	}

}