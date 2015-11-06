public without sharing class MERC_ETAuthorizer {
    public MERC_ETAuthorizer() {
        soapAuthToken = '';
        fuelAuthToken = '';
    }

    public String soapAuthToken { 
        get {
            if (soapAuthToken == null || soapAuthToken == '') {
                soapAuthToken = requestSoapAuthToken();
            }
            return soapAuthToken;
        }
        private set;
    }
    private String requestSoapAuthToken() {
        // retrieve the config information necessary for this call
        et4ae5__Configuration__c configInfo = [SELECT et4ae5__UserName__c, et4ae5__Password__c, et4ae5__Auth_API_URL__c 
                                               FROM et4ae5__Configuration__c
                                               ORDER BY LastModifiedDate DESC
                                               LIMIT 1];

        String bodyXML = '';
        bodyXML = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                    + '<SOAP-ENV:Header>'
                        + '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
                            + '<wsse:UsernameToken xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                                + '<wsse:Username>' + configInfo.et4ae5__UserName__c + '</wsse:Username>'
                                + '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + configInfo.et4ae5__Password__c + '</wsse:Password>'
                            + '</wsse:UsernameToken>'
                        + '</wsse:Security>'
                    + '</SOAP-ENV:Header>'
                    + '<SOAP-ENV:Body>'
                        + '<OAuthLogin xmlns="urn:authentication.exacttarget.com/2010/06/11">'
                            + '<applicationId>6C7F3A46-9BFD-40E9-87EE-456577D4FFE7</applicationId>'
                            + '<customerSecret> Not used currently </customerSecret>'
                            + '<scopeToken />'
                        + '</OAuthLogin>'
                    + '</SOAP-ENV:Body>'
                + '</SOAP-ENV:Envelope>';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(configInfo.et4ae5__Auth_API_URL__c);
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setHeader('SOAPAction', 'urn:authentication.exacttarget.com/2010/06/11/Auth/OAuthLogin');
        req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
        req.setBody(bodyXML);

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('#### Authorizer res.header :' + res.getHeader('Content-Type'));
        System.debug('#### Authorizer res.body : ' + res.getBody());

        String authToken = '';
        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            List<String> splits = res.getBody().split('<a:AccessToken>');
            splits = splits[1].split('</a:AccessToken>');
            authToken = splits[0];
        }

        return authToken;
    }

    public String fuelAuthToken { 
        get {
            if (fuelAuthToken == null || fuelAuthToken == '') {
                fuelAuthToken = requestFuelAuthToken();
            }
            return fuelAuthToken;
        }
        private set;
    }
    private String requestFuelAuthToken() {
        Mercury_Marketing_Cloud_Settings_MERC__c marketingCloudSettings = Mercury_Marketing_Cloud_Settings_MERC__c.getInstance();
        String clientId = marketingCloudSettings.Fuel_API_Client_ID_MERC__c;
        String clientSecret = marketingCloudSettings.Fuel_API_Client_Secret_MERC__c;
        String restAuthURL = marketingCloudSettings.Fuel_API_Auth_Root_URL_MERC__c;

        
        FuelRequestBody fuelReqBody = new FuelRequestBody(clientId, clientSecret, soapAuthToken);
        restAuthURL += '/v1/requestToken?legacy=1';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(restAuthURL);
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setBody(JSON.serialize(fuelReqBody));

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('#### FuelResponse res.header : ' + res.getHeader('Content-Type'));
        System.debug('#### FuelResponse res.body : ' + res.getBody());

        String authToken = '';
        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            FuelResponseBody fuelResBody = (FuelResponseBody)JSON.deserialize(res.getBody(), FuelResponseBody.class);
            authToken = fuelResBody.accessToken;
        } else {
            System.debug('soapAuthToken: ' + soapAuthToken);
            System.debug(LoggingLevel.WARN, 'Failed to get FuelAuthToken ('
                + res.getStatusCode() + '):\n\nRequest:\n' 
            + JSON.serialize(fuelReqBody) + '\n\nResponse:\n' + res.getBody());
        }

        return authToken;
    }

    // private class to simplify serializing the fuel authorization request
    @TestVisible
    private class FuelRequestBody {
        public String clientId { get; private set; }
        public String clientSecret { get; private set; }
        public String scope {
            get {
                return 'cas:' + scope;
                //return scope;
            }
            private set;
        }

        public FuelRequestBody(String cId, String cSecret, String s) {
            this.clientId = cId;
            this.clientSecret = cSecret;
            this.scope = s;
        }
    }

    // private class to simplify deserializing the fuel authorization response
    @TestVisible
    private class FuelResponseBody {
        public String accessToken { get; set; }
        public Integer expiresIn { get; set; }
        public String legacyToken { get; set; }
    }
}