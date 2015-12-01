@isTest
global class MERC_ETAuthorizerCallout_Mock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        System.debug('#### req : ' + req + '\n' + req.getBody());

        HttpResponse res = new HttpResponse();
        System.debug('#### endpoint is : ' + req.getEndpoint());
        if (req.getEndpoint().containsIgnoreCase('Auth.svc')) {
            System.debug('#### using soapAuthResponse');
            res = soapAuthResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('exacttargetapis.com')) {
            System.debug('#### using fuelAuthResponse');
            res = fuelAuthResponse(req);
        } else {
            System.debug('#### using blankResponse');
            System.debug('#### req.getMethod() = ' + req.getMethod());
            System.debug('#### req.getHeader(\'Content-Type\') = ' + req.getHeader('Content-Type'));
        }

        return res;
    }

    global HttpResponse soapAuthResponse(HttpRequest req) {
        HttpResponse soapRes = new HttpResponse();
        soapRes.setStatusCode(200);

        System.assertEquals('POST', req.getMethod());
        System.assertEquals(req.getHeader('SOAPAction'), 'urn:authentication.exacttarget.com/2010/06/11/Auth/OAuthLogin');

        List<String> reqSplits = req.getBody().split('<wsse:Username>');
        reqSplits = reqSplits[1].split('</wsse:Username>');
        String userName = reqSplits[0];
        reqSplits = reqSplits[1].split('<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">');
        reqSplits = reqSplits[1].split('</wsse:Password>');
        String password = reqSplits[0];
        System.assertNotEquals(null, userName);
        System.assertNotEquals(null, password);

        soapRes.setBody('<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><s:Body> <OAuthLoginResponse         xmlns="urn:authentication.exacttarget.com/2010/06/11">  <OAuthLoginResult xmlns:i="http://www.w3.org/2001/XMLSchema-instance"> <OAuthToken xmlns:a="urn:authentication.exacttarget.com/2011/03/11"> <a:AccessToken>testSoapToken</a:AccessToken> </OAuthToken> </OAuthLoginResult> </OAuthLoginResponse></s:Body></s:Envelope>');
        System.debug('#### body set to: ' + soapRes.getBody());
        return soapRes;
    }

    global HttpResponse fuelAuthResponse(HttpRequest req) {
        HttpResponse fuelRes = new HttpResponse();
        fuelRes.setStatusCode(200);

        System.assertEquals('POST', req.getMethod());
        System.assertEquals('application/json', req.getHeader('Content-Type'));

        MERC_ETAuthorizer.FuelRequestBody reqBody = (MERC_ETAuthorizer.FuelRequestBody)JSON.deserialize(req.getBody(), MERC_ETAuthorizer.FuelRequestBody.Class);
        System.assertNotEquals(null, reqBody.clientId, reqBody);
        System.assertNotEquals('', reqBody.clientId, reqBody);
        System.assertNotEquals(null, reqBody.clientSecret, reqBody);
        System.assertNotEquals('', reqBody.clientSecret, reqBody);
        System.assertNotEquals(null, reqBody.scope, reqBody);
        System.assertNotEquals('', reqBody.scope, reqBody);

        MERC_ETAuthorizer.FuelResponseBody resBody = new MERC_ETAuthorizer.FuelResponseBody();
        resBody.accessToken = 'testFuelAccessToken';
        resBody.expiresIn = 10000;
        resBody.legacyToken = 'testFuelLegacyToken';

        fuelRes.setBody(JSON.serialize(resBody));
        System.debug('#### body set to: ' + fuelRes.getBody());
        return fuelRes;
    }
}