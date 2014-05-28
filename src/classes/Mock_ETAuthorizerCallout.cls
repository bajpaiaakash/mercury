@isTest
global class Mock_ETAuthorizerCallout implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        System.debug('req : ' + req + '\n' + req.getBody());

        HttpResponse res = new HttpResponse();
        if (req.getEndpoint().containsIgnoreCase('Auth.svc')) {
            res = soapAuthResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('exacttargetapis.com')) {
            res = fuelAuthResponse(req);
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

        soapRes.setBody('<a:AccessToken>testSoapToken</a:AccessToken>');
        
        return soapRes;
    }

    global HttpResponse fuelAuthResponse(HttpRequest req) {
        HttpResponse fuelRes = new HttpResponse();
        fuelRes.setStatusCode(200);

        System.assertEquals('POST', req.getMethod());
        System.assertEquals('application/json', req.getHeader('Content-Type'));

        ETAuthorizer.FuelRequestBody reqBody = (ETAuthorizer.FuelRequestBody)JSON.deserialize(req.getBody(), ETAuthorizer.FuelRequestBody.Class);
        System.assertNotEquals(null, reqBody.clientId);
        System.assertNotEquals('', reqBody.clientId);
        System.assertNotEquals(null, reqBody.clientSecret);
        System.assertNotEquals('', reqBody.clientSecret);
        System.assertNotEquals(null, reqBody.scope);
        System.assertNotEquals('', reqBody.scope);

        ETAuthorizer.FuelResponseBody resBody = new ETAuthorizer.FuelResponseBody();
        resBody.accessToken = 'testFuelAccessToken';
        resBody.expiresIn = 10000;
        resBody.legacyToken = 'testFuelLegacyToken';

        fuelRes.setBody(JSON.serialize(resBody));

        return fuelRes;
    }
}