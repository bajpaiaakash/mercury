@isTest
global class MERC_ETDataExtensionCallout_Mock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        MERC_ETDataExtension de = (MERC_ETDataExtension)JSON.deserialize(req.getBody(), MERC_ETDataExtension.class);
        System.assert(de != null);

        List<MERC_ETDataExtension.Field> fields = de.field;
        String primaryField = de.sendableDataExtensionField;
        Boolean hasPrimaryFieldInFields = false;
        for (MERC_ETDataExtension.Field f : fields) {
            System.debug('field f : ' + f);
            if (f.fieldName.equals(primaryField) && !f.nullable && f.isPrimaryKey) {
                hasPrimaryFieldInFields = true;
                continue;
            }
        }

        String status = '';
        Integer code = 200;
        MERC_ETDataExtension.DataExtensionResponse deRes = new MERC_ETDataExtension.DataExtensionResponse();
        if (hasPrimaryFieldInFields) {
            deRes.id = '1234id';
        } else {
            deRes.id = null;
            status = 'BAD REQUEST';
            code = 400;
        }

        HttpResponse res = new HttpResponse();
        res.setStatus(status);
        res.setStatusCode(code);
        res.setBody(JSON.serializePretty(deRes));

        return res;
    }
}