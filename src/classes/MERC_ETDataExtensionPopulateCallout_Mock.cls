@isTest
global class MERC_ETDataExtensionPopulateCallout_Mock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        String status = 'OK';
        Integer code = 200;

        try {
            String body = req.getBody();
            System.debug('body : ' + req.getBody());
            JSONParser parser = JSON.createParser(body);
            JSONToken currToken = parser.nextToken();
            String tokenName = '';
            System.assertEquals(JSONToken.START_ARRAY, currToken);
            while(parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_ARRAY) {
                currToken = parser.getCurrentToken();
                System.assertEquals(JSONToken.START_OBJECT, currToken);
                    currToken = parser.nextToken();
                    tokenName = parser.getCurrentName();
                    System.assertEquals('keys', tokenName);
                    currToken = parser.nextToken();
                    System.assertEquals(JSONToken.START_OBJECT, currToken);
                        currToken = parser.nextToken();
                        System.assertEquals(JSONToken.FIELD_NAME, currToken);
                        currToken = parser.nextToken();
                        System.assertEquals(JSONToken.VALUE_STRING, currToken);
                    currToken = parser.nextToken();
                    System.assertEquals(JSONToken.END_OBJECT, currToken);
                    currToken = parser.nextToken();
                    System.assertEquals(JSONToken.FIELD_NAME, currToken);
                    tokenName = parser.getCurrentName();
                    System.assertEquals('values', tokenName);
                    currToken = parser.nextToken();
                    System.debug('currToken : ' + currToken);
                    System.assertEquals(JSONToken.START_OBJECT, currToken);
                    while (parser.nextToken() !=  JSONToken.END_OBJECT) {
                        currToken = parser.getCurrentToken();
                        System.debug('currToken : ' + currToken);
                        System.debug('currToken value : ' + parser.getCurrentName());
                        System.assertEquals(JSONToken.FIELD_NAME, currToken);
                        currToken = parser.nextToken();
                        System.debug('currToken : ' + currToken);
                        System.debug('currToken value : ' + parser.getText());
                        System.assertEquals(JSONToken.VALUE_STRING, currToken);
                    }
                    currToken = parser.getCurrentToken();
                    System.assertEquals(JSONToken.END_OBJECT, currToken);
                currToken = parser.nextToken();
                System.assertEquals(JSONToken.END_OBJECT, currToken);
            }
        } catch (Exception e ) {
            System.debug('the formatting is incorrect : ' + req.getBody());
            status = 'BAD REQUEST';
            code = 400;
        }

        HttpResponse res = new HttpResponse();
        res.setStatus(status);
        res.setStatusCode(code);
        res.setBody('just some dummy text, as we are currently testing that');

        return res;
    }
}