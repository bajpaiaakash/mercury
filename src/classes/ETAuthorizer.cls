public without sharing class ETAuthorizer {
    public ETAuthorizer() {
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
        // get root rest api config info
        et4ae5__Configuration__c configInfo = [SELECT et4ae5__Root_Rest_API_URL__c
                                               FROM et4ae5__Configuration__c
                                               ORDER BY LastModifiedDate DESC
                                               LIMIT 1];

        // determine client id and secret based on root rest api url
        String clientId = '';
        String clientSecret = '';
        String restAuthURL = '';
        if (configInfo.et4ae5__Root_Rest_API_URL__c.containsIgnoreCase('s1.qa1')) {
            clientId = 'mrvftgqk7eae9e65s4namb7m';
            clientSecret = 'EqvjgVvQWgsapeSUMbRjF7CE';
            restAuthURL = 'https://auth-qa1s1.exacttargetapis.com';
        } else if (configInfo.et4ae5__Root_Rest_API_URL__c.containsIgnoreCase('s1.qa2')) {
            clientId = 'geavv2ncce5w3bzgwvc7vj6s';
            clientSecret = 'ntxbHHuuzdtdEQExPnT7VPSk';
            restAuthURL = 'https://auth-qa2s1.exacttargetapis.com';
        } else { // must be production
            clientId = 'x3tmhb2dgz33gsvfwr3hy868';
            clientSecret = 'aAvqCVBQUW6KnHKwwXgY6FZa';
            restAuthURL = 'https://auth.exacttargetapis.com';
        }
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

        String authToken = '';
        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            FuelResponseBody fuelResBody = (FuelResponseBody)JSON.deserialize(res.getBody(), FuelResponseBody.class);
            authToken = fuelResBody.accessToken;
        }

        return authToken;
    }

    public ETDataExtension.DataExtensionResponse createDataExtensionWithKey(String deKey) {
        String deName = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss') + ' Data Extension';
        ETDataExtension de = new ETDataExtension(deName, deName, deKey);

        Integer numFields = 3;
        List<ETDataExtension.Field> fields = new List<ETDataExtension.Field>();
        for (Integer fieldCount = 0; fieldCount < numFields; fieldCount++) {
            ETDataExtension.Field f = new ETDataExtension.Field();
            f.fieldName = 'Field Number ' + fieldCount;
            f.fieldType = '0';
            f.id = null;
            f.nullable = true;
            f.isPrimaryKey = false;
            f.length = String.valueOf(50);
            f.scale = null;
            fields.add(f);
        }
        fields[0].nullable = false;
        fields[0].isPrimaryKey = true;
        de.sendableDataExtensionField = fields[0].fieldName;
        de.field.addAll(fields);

        et4ae5__Configuration__c configInfo = [SELECT et4ae5__Root_Rest_API_URL__c FROM et4ae5__Configuration__c LIMIT 1];
        String endPoint = configInfo.et4ae5__Root_Rest_API_URL__c + '/rest/beta/object/?oauth_token=' + soapAuthToken;

        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Accept', 'application/json');
        req.setBody(JSON.serialize(de));

        Http h = new Http();
        HttpResponse res = h.send(req);

        ETDataExtension.DataExtensionResponse deResponse = (ETDataExtension.DataExtensionResponse)JSON.deserialize(res.getBody(), ETDataExtension.DataExtensionResponse.class);
        return deResponse;
    }

    public String createDummyDataExtensionDataForKey(String deKey) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
            gen.writeStartObject();
                gen.writeFieldName('keys');
                gen.writeStartObject();
                    gen.writeStringField('Field Number 0', 'Test Field 0 Data');
                gen.writeEndObject();
                gen.writeFieldName('values');
                gen.writeStartObject();
                    gen.writeStringField('Field Number 1', 'Test Field 1 Data');
                    gen.writeStringField('Field Number 2', 'Test Field 2 Data');
                gen.writeEndObject();
            gen.writeEndObject();
        gen.writeEndArray();

        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint('https://www.exacttargetapis.com/hub/v1/dataevents/key:' + deKey + '/rowset');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('authorization', 'Bearer ' + fuelAuthToken);
        req.setBody(gen.getAsString());

        Http h = new Http();
        HttpResponse res = h.send(req);

        return res.getStatus() + ' ' + res.getStatusCode() + ' ' + res.getBody();
    }

    public void createETSendForDataExtensionId(String deId) {
        et4ae5__SendDefinition__c send = new et4ae5__SendDefinition__c();
        //send.et4ae5__Campaign__c = Id.valueOf('70111000000B2aN');
        send.et4ae5__DataExtensionId__c = deId;
        send.et4ae5__SyncId__c = Datetime.now().format('yyyyMMdd');
        insert send;
    }

    // private class to simplify serializing the fuel authorization request
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
    private class FuelResponseBody {
        public String accessToken { get; set; }
        public Integer expiresIn { get; set; }
        public String legacyToken { get; set; }
    }
}