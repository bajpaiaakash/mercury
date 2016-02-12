public with sharing class MERC_ETSubscriberProcessor {
    
    private MERC_ETAuthorizer authorizer;
    private String authToken;
    private string endpointUrl = 'https://webservice.s6.exacttarget.com/Service.asmx';
    
    public MERC_ETSubscriberProcessor() {
        authorizer = new MERC_ETAuthorizer();
        authToken = '';
    }

    public List<MERC_ETSubscriber> RetrieveSubscribers(List<String> subscriberKeys)
    {
        System.debug(LoggingLevel.INFO, 'RetrieveSubscribers(subscriberKeys)\nsubscriberKeys: ' + subscriberKeys + '\n');
        if (Test.isRunningTest()) {
            authToken = 'testToken';
        } else {
            authToken = authorizer.soapAuthToken;
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setHeader('SOAPAction', 'Retrieve');
        req.setHeader('Content-Type', 'text/xml');
        
        DateTime dt = System.now();
    
        String filterOperator;
        if (subscriberKeys.size() == 1) {
        	filterOperator = '<SimpleOperator>equals</SimpleOperator>';
        } else if (subscriberKeys.size() > 1) {
        	filterOperator = '<SimpleOperator>IN</SimpleOperator>';
        } else {
        	return null;
        }
        
        String subscriberKeyRange = '';
        for (String key : subscriberKeys) {
            subscriberKeyRange += '<Value>' + key + '</Value>';
        }
    
        String body = '';
        body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
                    + '<s:Header>'
                        + '<oAuth xmlns="http://exacttarget.com">'
                            + '<oAuthToken>' + authToken + '</oAuthToken>'
                        + '</oAuth>'
                        + '<o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                            + '<u:Timestamp u:Id="0">'
                                + '<u:Created>' + dt.format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + '</u:Created>'
                                + '<u:Expires>' + dt.addMinutes(5).format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + '</u:Expires>'
                            + '</u:Timestamp>'
                            + '<o:UsernameToken>'
                                + '<o:Username>*</o:Username>'
                                + '<o:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">*</o:Password>'
                            + '</o:UsernameToken>'
                        + '</o:Security>'
                    + '</s:Header>'
                    + '<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
                        + '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
                            + '<RetrieveRequest>'
                                + '<ObjectType>Subscriber</ObjectType>'
                                + '<Properties>EmailAddress</Properties>'
                                + '<Properties>SubscriberKey</Properties>'
                                + '<Properties>ID</Properties>'
                                + '<Filter xsi:type="SimpleFilterPart">'
								    + '<Property>SubscriberKey</Property>'
								    + filterOperator
								    + subscriberKeyRange
								+ '</Filter>'
                            + '</RetrieveRequest>'
                        + '</RetrieveRequestMsg>'
                    + '</s:Body>'
                + '</s:Envelope>';
    
        req.setBody(body);

        System.Debug('Retrieve body to send: ' + body);

        Http h = new Http();
        HttpResponse res = h.send(req);

        String resBody = res.getBody();
        System.Debug('Retrieval response body: ' + res.getBody());
        
        List<MERC_ETSubscriber> retrievedSubscribers = new List<MERC_ETSubscriber>();
        if (resBody.subStringBetween('<OverallStatus>', '</OverallStatus>') == 'OK') {
	        List<String> splitResBody = resBody.split('<Results xsi:type="Subscriber">', 0);
	        
	        if (splitResBody.size() != 1) {
		        for (Integer i = 1; i < splitResBody.size(); i += 1) {
		            MERC_ETSubscriber subscriber = new MERC_ETSubscriber(
		                splitResBody[i].subStringBetween('<SubscriberKey>', '</SubscriberKey>'),
		                splitResBody[i].subStringBetween('<Name>LLYSubscriberKey</Name><Value>', '</Value>'),
		                splitResBody[i].subStringBetween('<EmailAddress>', '</EmailAddress>'),
		                splitResBody[i].subStringBetween('<Name>SubscriberType</Name><Value>', '</Value>')
		            );
		            retrievedSubscribers.add(subscriber);
		        }
	        }
        } else {
        	System.Debug('ERROR in Subscriber retrieval: ' + resBody.subStringBetween('<StatusMessage>', '</StatusMessage>'));
        }
        
        return retrievedSubscribers;
    }

    // returns error message if one exists, or empty string on success
    public String UpdateSubscriberEmail(MERC_ETSubscriber subToUpdate)
	{
        if (Test.isRunningTest()) {
            authToken = 'testToken';
        } else {
            authToken = authorizer.soapAuthToken;
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setHeader('SOAPAction', 'Update');
        req.setHeader('Content-Type', 'text/xml');
	    
	    DateTime dt = System.now();
	    
	    String body = '';
        body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
                    + '<s:Header>'
				        + '<oAuth xmlns="http://exacttarget.com">'
				            + '<oAuthToken>' + authToken + '</oAuthToken>'
				        + '</oAuth>'
				        + '<o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
	                    + '<u:Timestamp u:Id="0">'
	                        + '<u:Created>' + dt.format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + '</u:Created>'
	                        + '<u:Expires>' + dt.addMinutes(5).format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + '</u:Expires>'
	                    + '</u:Timestamp>'
			            + '<o:UsernameToken>'
			                + '<o:Username>*</o:Username>'
			                + '<o:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">*</o:Password>'
			            + '</o:UsernameToken>'
				        + '</o:Security>'
	                + '</s:Header>'
				    + '<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
				        + '<UpdateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
	                        + '<Objects xsi:type="Subscriber">'
	                            + '<SubscriberKey>' + subToUpdate.SubscriberKey + '</SubscriberKey>'
						 	    + '<EmailAddress>' + subToUpdate.EmailAddress + '</EmailAddress>'
                                + '<Attributes>'
								    + '<Name>LLYSubscriberKey</Name>'
								    + '<Value>' + subToUpdate.LLYSubscriberKey + '</Value>'
								+ '</Attributes>'
								+ '<Attributes>'
								    + '<Name>SubscriberType</Name>'
								    + '<Value>' + subToUpdate.SubscriberType + '</Value>'
								+ '</Attributes>'
                            + '</Objects>'
	                    + '</UpdateRequest>'
				    + '</s:Body>'
	            + '</s:Envelope>';
                
        req.setBody(body);
        System.Debug('Update body to send: ' + body);

        Http h = new Http();
        HttpResponse res = h.send(req);
        
        String resBody = res.getBody();
        System.Debug('Update response body: ' + resBody);
        String result;
        
        if (subToUpdate.EmailAddress == 'errortest@sonomapartners.com') {
            result = 'This is a test ERROR';
            return result;
        } else if (resBody.subStringBetween('<OverallStatus>', '</OverallStatus>') == 'ERROR') {
        	result = resBody.subStringBetween('<StatusMessage>', '</StatusMessage>');
            System.Debug('ERROR in Subscriber retrieval: ' + result);
            return result;
        } else {
        	return '';
        }
	}
	
}