@isTest
global class MERC_ETSubscriberProcessorCallout_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assert(req.getEndPoint() == 'https://webservice.s6.exacttarget.com/Service.asmx',
                      'Endpoint should be "https://webservice.s6.exacttarget.com/Service.asmx", not ' + req.getEndpoint());
    	System.assert(req.getMethod() == 'POST', 'Method should be "POST", not ' + req.getMethod());
    	
    	MERC_ETSubscriberProcessor subProcessor = new MERC_ETSubscriberProcessor();
    	
        String status = 'OK';
        Integer code = 200;
        String bodyXML = '';
        String reqBody = req.getBody();
        
        if (req.getHeader('SOAPAction') == 'Retrieve') {
            bodyXML += '<OverallStatus>OK</OverallStatus>';
            
        	reqBody = reqBody.subStringBetween('<Filter', '</Filter>');
        	List<String> values = reqBody.split('<Value>', 0);
        	for (String val : values) {
        		if (val.subStringBefore('</Value>') == 'testSubKey') {
        			bodyXML += '<Results xsi:type="Subscriber">';
	                bodyXML += '<SubscriberKey>testSubKey</SubscriberKey>';
	                bodyXML += '<Name>LLYSubscriberKey</Name><Value>testLLYKey</Value>';
	                bodyXML += '<EmailAddress>test@testy.com</EmailAddress>';
	                bodyXML += '<Name>SubscriberType</Name><Value>testType</Value>';
	                bodyXML += '</Results>';
        		}
        	}
        } else if (req.getHeader('SOAPAction') == 'Update') {
        	Pattern emailPattern = Pattern.compile('\\D[^\\@]*@[^\\.\\@]*\\.[^\\.]*');
        	Matcher emailMatcher = emailPattern.matcher(reqBody.subStringBetween('<EmailAddress>', '</EmailAddress>'));
        	
        	if (reqBody.subStringBetween('<SubscriberKey>', '</SubscriberKey>') == 'testSubKey' &&
                emailMatcher.matches()) {
                // return OK result
                bodyXML += '<OverallStatus>OK</OverallStatus>';
            } else if (!emailMatcher.matches()){
                // return error result
                bodyXML += '<OverallStatus>ERROR</OverallStatus>';
                bodyXML += '<StatusMessage>Invalid email</StatusMessage>';
                status = 'ERROR';
            } else {
                bodyXML += '<OverallStatus>ERROR</OverallStatus>';
                bodyXML += '<StatusMessage>Standard error message</StatusMessage>';
                status = 'ERROR';
            }
        }

        HttpResponse res = new HttpResponse();
        res.setStatus(status);
        res.setStatusCode(code);
        res.setBody(bodyXML);
        
        return res;
    }
}