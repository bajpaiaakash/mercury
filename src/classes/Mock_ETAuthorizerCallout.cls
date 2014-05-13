@isTest
global class Mock_ETAuthorizerCallout implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        if (req.getEndpoint().containsIgnoreCase('Auth.svc')) {
            res = soapAuthResponse(req);
        } else if (req.getEndpoint().containsIgnoreCase('exacttargetais.com')) {
            res = fuelAuthResponse(req);
        }

        return res;
    }

    global HttpResponse soapAuthResponse(HttpRequest req) {
        HttpResponse soapRes = new HttpResponse();

        System.assertEquals('POST', req.getMethod());
        System.assertEquals('SOAPAction', 'urn:authentication.exacttarget.com/2010/06/11/Auth/OAuthLogin');

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

        return fuelRes;
    }
}