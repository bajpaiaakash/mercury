@isTest
global class Mock_DataExtensionCallout implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        ETDataExtension de = (ETDataExtension)JSON.deserialize(req.getBody(), ETDataExtension.class);
        System.assert(de != null);

        List<ETDataExtension.Field> fields = de.field;
        String primaryField = de.sendableDataExtensionField;
        Boolean hasPrimaryFieldInFields = false;
        for (ETDataExtension.Field f : fields) {
            System.debug('field f : ' + f);
            if (f.fieldName.equals(primaryField) && !f.nullable && f.isPrimaryKey) {
                hasPrimaryFieldInFields = true;
                continue;
            }
        }

        String status = '';
        Integer code = 200;
        ETDataExtension.DataExtensionResponse deRes = new ETDataExtension.DataExtensionResponse();
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