public with sharing class ETAuthTestPageController {
    public ETAuthTestPageController() {
        authorizer = new ETAuthorizer();
        processor = new ETDataExtensionProcessor();

        showSoapAuthString = false;
        showFuelAuthString = false;
        showDEResponse = false;
    }

    public ETAuthorizer authorizer { get; set; }
    public ETDataExtensionProcessor processor { get; set; }

    public Boolean showSoapAuthString { get; set; }
    public PageReference toggleShowSoapAuthString() {
        showSoapAuthString = true;
        return null;
    }

    public Boolean showFuelAuthString { get; set; }
    public PageReference toggleShowFuelAuthString() {
        showFuelAuthString = true;
        return null;
    }

    public String deKey { get; set; }
    public Boolean showDEResponse { get; set; }
    public ETDataExtension.DataExtensionResponse deResponse { get; set; }
    public PageReference toggleShowDEResponse() {
        showDEResponse = true;
        deKey = Datetime.now().format('yyyyMMddHHmmssSSS');
        List<ETDataExtension.Field> fields = new List<ETDataExtension.Field>();
        ETDataExtension.Field f1 = new ETDataExtension.Field();
        f1.fieldName = 'SubscriberKey';
        f1.fieldType = '0';
        f1.length = '100';
        f1.nullable = false;
        f1.isPrimaryKey = true;
        fields.add(f1);
        List<String> fieldNames = new List<String> {'Meeting Name', 'City of Meeting', 'Venue Name', 'Meeting Start Date', 'Meeting End Date', 'Event Id', 'Meeting Participant Num', 'First Name', 'Last Name'};
        for (String n : fieldNames) {
            ETDataExtension.Field f = new ETDataExtension.Field();
            f.fieldName = n;
            f.fieldType = '0';
            f.length = '1000';
            f.nullable = false;
            f.isPrimaryKey = false;
            fields.add(f);
        }
        ETDataExtension.Field f2 = new ETDataExtension.Field();
        f2.fieldName = 'EmailAddress';
        f2.fieldType = '0';
        f2.length = '254';
        f2.nullable = false;
        f2.isPrimaryKey = false;
        fields.add(f2);

        deResponse = processor.createDataExtensionWithNameKeyFieldsAndSoapAuth('ETAuthTestPageController' + Datetime.now().format('yyyyMMddHHmmssSSS'), deKey, fields, authorizer.soapAuthToken, datetime.now().addMinutes(15));
        return null;
    }

    public String dataCreateResponseBody { get; set; }
    public Boolean showDataCreateResponseBody { get; set; }
    public PageReference toggleShowDataCreateResponseBody() {
        showDataCreateResponseBody = true;
        //dataCreateResponseBody = authorizer.createDummyDataExtensionDataForKey(deKey);
        List<ETDataExtension.DataExtensionEntry> entries = new List<ETDataExtension.DataExtensionEntry>();
        ETDataExtension.DataExtensionEntry e1 = new ETDataExtension.DataExtensionEntry();
        e1.keys = new ETDataExtension.FieldEntry();
        e1.keys.fieldName = 'SubscriberKey';
        e1.keys.fieldValue = '0031100000N0RrnAAF';
        e1.values = new List<ETDataExtension.FieldEntry>();
        ETDataExtension.FieldEntry fe1 = new ETDataExtension.FieldEntry();
        fe1.fieldName = 'EmailAddress';
        fe1.fieldValue = 'mdearing@sonomapartners.com';
        e1.values.add(fe1);
        ETDataExtension.FieldEntry fe2 = new ETDataExtension.FieldEntry();
        fe2.fieldName = 'Meeting Name';
        fe2.fieldValue = 'test';
        e1.values.add(fe2);
        ETDataExtension.FieldEntry fe3 = new ETDataExtension.FieldEntry();
        fe3.fieldName = 'City of Meeting';
        fe3.fieldValue = 'Lawrence';
        e1.values.add(fe3);
        ETDataExtension.FieldEntry fe4 = new ETDataExtension.FieldEntry();
        fe4.fieldName = 'Venue Name';
        fe4.fieldValue = 'town hall';
        e1.values.add(fe4);
        ETDataExtension.FieldEntry fe5 = new ETDataExtension.FieldEntry();
        fe5.fieldName = 'Meeting Start Date';
        fe5.fieldValue = Datetime.now().formatGmt('MM/dd/yyyy\'T\'HH:mm:ss.SSSZ');
        e1.values.add(fe5);
        ETDataExtension.FieldEntry fe6 = new ETDataExtension.FieldEntry();
        fe6.fieldName = 'Meeting End Date';
        fe6.fieldValue = Datetime.now().addMonths(1).formatGmt('MM/dd/yyyy\'T\'HH:mm:ss.SSSZ');
        e1.values.add(fe6);
        ETDataExtension.FieldEntry fe7 = new ETDataExtension.FieldEntry();
        fe7.fieldName = 'Event Id';
        fe7.fieldValue = 'M-37367AT14';
        e1.values.add(fe7);
        ETDataExtension.FieldEntry fe8 = new ETDataExtension.FieldEntry();
        fe8.fieldName = 'Meeting Participant Num';
        fe8.fieldValue = 'MP-084627';
        e1.values.add(fe8);
        ETDataExtension.FieldEntry fe9 = new ETDataExtension.FieldEntry();
        fe9.fieldName = 'First Name';
        fe9.fieldValue = 'Test';
        e1.values.add(fe9);
        ETDataExtension.FieldEntry fe10 = new ETDataExtension.FieldEntry();
        fe10.fieldName = 'Last Name';
        fe10.fieldValue = 'User';
        e1.values.add(fe10);
        entries.add(e1);
        HttpResponse res = processor.populateDataExtensionForKeyWithValuesAndFuelAuth(deKey, entries, authorizer.fuelAuthToken);
        dataCreateResponseBody = res.getStatus() + ' ' + res.getStatusCode() + ' : ' + res.getBody();
        return null;
    }

    public String createSendProfileResponseBody { get; set; }
    public Boolean showCreateSendProfileResponseBody { get; set; }
    public ETSendDefinition.CreateSenderProfileResponse createProfileResponse{get;set;}
    public PageReference toggleShowCreateSendProfileResponseBody() {
        showCreateSendProfileResponseBody = true;

        ETSendDefinition.SenderProfileCreate sendProfCreate = new ETSendDefinition.SenderProfileCreate('Test Lilly', 'donotreply@lilly.com');

        ETSendDefinitionProcessor sendDefProcessor = new ETSendDefinitionProcessor();
        try{
            createProfileResponse = sendDefProcessor.createSenderProfile(sendProfCreate, authorizer.soapAuthToken);
            createSendProfileResponseBody = JSON.serialize(createProfileResponse);
        }
        catch(Exception e){
            createSendProfileResponseBody = String.valueOf(e);
        }
        return null;
    }

    public String createSendDefResponseBody { get; set; }
    public Boolean showCreateSendDefResponseBody { get; set; }
    public ETSendDefinition.CreateResponse createResponse{get;set;}
    public PageReference toggleShowCreateSendDefResponseBody() {
        showCreateSendDefResponseBody = true;
        String key = String.valueof(datetime.now().getTime());
        Integer emailId = 12588; //Sonoma Test Template
        ETSendDefinition sendDef = new ETSendDefinition(deResponse.id, false, 'ETAuthTestPageNameDescription', emailId, key, key, 'ETAuthTestSubject');
        //todo: add to constructor
        sendDef.senderProfileId = createProfileResponse.id;

        ETSendDefinitionProcessor sendDefProcessor = new ETSendDefinitionProcessor();
        try{
            createResponse = sendDefProcessor.create(sendDef, authorizer.soapAuthToken);
            createSendDefResponseBody = JSON.serialize(createResponse);
        }
        catch(Exception e){
            createSendDefResponseBody = String.valueOf(e);
        }
        return null;
    }

    public String startSendDefResponseBody { get; set; }
    public Boolean showStartSendDefResponseBody { get; set; }
    public PageReference toggleShowStartSendDefResponseBody() {
        showStartSendDefResponseBody = true;
        ETSendDefinitionProcessor sendDefProcessor = new ETSendDefinitionProcessor();
        try{
            ETSendDefinition.StartResponse response = sendDefProcessor.start(createResponse.id, authorizer.soapAuthToken);
            startSendDefResponseBody = JSON.serialize(response);
        }
        catch(Exception e){
            startSendDefResponseBody = String.valueOf(e);
        }
        return null;
    }

    public String checkStatusSendDefResponseBody { get; set; }
    public Boolean showCheckStatusSendDefResponseBody { get; set; }
    public PageReference toggleShowCheckStatusSendDefResponseBody() {
        showCheckStatusSendDefResponseBody = true;
        ETSendDefinitionProcessor sendDefProcessor = new ETSendDefinitionProcessor();
        try{
            ETSendDefinition.CheckStatusResponse response = sendDefProcessor.checkStatus(createResponse.id, authorizer.soapAuthToken);
            checkStatusSendDefResponseBody = JSON.serialize(response);
        }
        catch(Exception e){
            checkStatusSendDefResponseBody = String.valueOf(e);
        }
        return null;
    }
}