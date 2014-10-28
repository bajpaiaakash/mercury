public with sharing class ETAuthTestPageController {
    public ETAuthTestPageController() {
        authorizer = new MERC_ETAuthorizer();
        processor = new MERC_ETDataExtensionProcessor();

        showSoapAuthString = false;
        showFuelAuthString = false;
        showDEResponse = false;
    }

    public MERC_ETAuthorizer authorizer { get; set; }
    public MERC_ETDataExtensionProcessor processor { get; set; }

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
    
    public String sendClassificationBody { get; set; }
    public Boolean showSendClassification { get; set; }
    public PageReference toggleShowSendClassification() {
        showSendClassification = true;
        
        List<MERC_ETSendClassification> classifications = MERC_ETSendClassification.GetSendClassifications(authorizer.soapAuthToken);
        sendClassificationBody = JSON.serialize(classifications);
        
        return null;
    } 

    public String deKey { get; set; }
    public Boolean showDEResponse { get; set; }
    public MERC_ETDataExtension.DataExtensionResponse deResponse { get; set; }
    public PageReference toggleShowDEResponse() {
        showDEResponse = true;
        deKey = Datetime.now().format('yyyyMMddHHmmssSSS');
        List<MERC_ETDataExtension.Field> fields = new List<MERC_ETDataExtension.Field>();
        MERC_ETDataExtension.Field f1 = new MERC_ETDataExtension.Field();
        f1.fieldName = 'SubscriberKey';
        f1.fieldType = '0';
        f1.length = '100';
        f1.nullable = false;
        f1.isPrimaryKey = true;
        fields.add(f1);
        List<String> fieldNames = new List<String> {'Meeting Name', 'City of Meeting', 'Venue Name', 'Meeting Start Date', 'Meeting End Date', 'Event Id', 'Meeting Participant Num', 'First Name', 'Last Name'};
        for (String n : fieldNames) {
            MERC_ETDataExtension.Field f = new MERC_ETDataExtension.Field();
            f.fieldName = n;
            f.fieldType = '0';
            f.length = '1000';
            f.nullable = false;
            f.isPrimaryKey = false;
            fields.add(f);
        }
        MERC_ETDataExtension.Field f2 = new MERC_ETDataExtension.Field();
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
        List<MERC_ETDataExtension.DataExtensionEntry> entries = new List<MERC_ETDataExtension.DataExtensionEntry>();
        MERC_ETDataExtension.DataExtensionEntry e1 = new MERC_ETDataExtension.DataExtensionEntry();
        e1.keys = new MERC_ETDataExtension.FieldEntry();
        e1.keys.fieldName = 'SubscriberKey';
        e1.keys.fieldValue = '0031100000N0RrnAAF';
        e1.values = new List<MERC_ETDataExtension.FieldEntry>();
        MERC_ETDataExtension.FieldEntry fe1 = new MERC_ETDataExtension.FieldEntry();
        fe1.fieldName = 'EmailAddress';
        fe1.fieldValue = 'mdearing@sonomapartners.com';
        e1.values.add(fe1);
        MERC_ETDataExtension.FieldEntry fe2 = new MERC_ETDataExtension.FieldEntry();
        fe2.fieldName = 'Meeting Name';
        fe2.fieldValue = 'test';
        e1.values.add(fe2);
        MERC_ETDataExtension.FieldEntry fe3 = new MERC_ETDataExtension.FieldEntry();
        fe3.fieldName = 'City of Meeting';
        fe3.fieldValue = 'Lawrence';
        e1.values.add(fe3);
        MERC_ETDataExtension.FieldEntry fe4 = new MERC_ETDataExtension.FieldEntry();
        fe4.fieldName = 'Venue Name';
        fe4.fieldValue = 'town hall';
        e1.values.add(fe4);
        MERC_ETDataExtension.FieldEntry fe5 = new MERC_ETDataExtension.FieldEntry();
        fe5.fieldName = 'Meeting Start Date';
        fe5.fieldValue = Datetime.now().formatGmt('MM/dd/yyyy\'T\'HH:mm:ss.SSSZ');
        e1.values.add(fe5);
        MERC_ETDataExtension.FieldEntry fe6 = new MERC_ETDataExtension.FieldEntry();
        fe6.fieldName = 'Meeting End Date';
        fe6.fieldValue = Datetime.now().addMonths(1).formatGmt('MM/dd/yyyy\'T\'HH:mm:ss.SSSZ');
        e1.values.add(fe6);
        MERC_ETDataExtension.FieldEntry fe7 = new MERC_ETDataExtension.FieldEntry();
        fe7.fieldName = 'Event Id';
        fe7.fieldValue = 'M-37367AT14';
        e1.values.add(fe7);
        MERC_ETDataExtension.FieldEntry fe8 = new MERC_ETDataExtension.FieldEntry();
        fe8.fieldName = 'Meeting Participant Num';
        fe8.fieldValue = 'MP-084627';
        e1.values.add(fe8);
        MERC_ETDataExtension.FieldEntry fe9 = new MERC_ETDataExtension.FieldEntry();
        fe9.fieldName = 'First Name';
        fe9.fieldValue = 'Test';
        e1.values.add(fe9);
        MERC_ETDataExtension.FieldEntry fe10 = new MERC_ETDataExtension.FieldEntry();
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
    public MERC_ETSendDefinition.CreateSenderProfileResponse createProfileResponse{get;set;}
    public PageReference toggleShowCreateSendProfileResponseBody() {
        /*showCreateSendProfileResponseBody = true;

        MERC_ETSendDefinition.SenderProfileCreate sendProfCreate = new MERC_ETSendDefinition.SenderProfileCreate('Test Lilly', 'donotreply@lilly.com');

        MERC_ETSendDefinitionProcessor sendDefProcessor = new MERC_ETSendDefinitionProcessor();
        try{
            createProfileResponse = sendDefProcessor.createSenderProfile(sendProfCreate, authorizer.soapAuthToken);
            createSendProfileResponseBody = JSON.serialize(createProfileResponse);
        }
        catch(Exception e){
            createSendProfileResponseBody = String.valueOf(e);
        }*/
        return null;
    }

    public String createSendDefResponseBody { get; set; }
    public Boolean showCreateSendDefResponseBody { get; set; }
    public MERC_ETSendDefinition.CreateResponse createResponse{get;set;}
    public PageReference toggleShowCreateSendDefResponseBody() {
        showCreateSendDefResponseBody = true;
        String key = String.valueof(datetime.now().getTime());
        Integer emailId = 12588; //Sonoma Test Template
        MERC_ETSendDefinition sendDef = new MERC_ETSendDefinition(deResponse.id, false, 'ETAuthTestPageNameDescription', emailId, key, key, 'ETAuthTestSubject', createProfileResponse.id);

        MERC_ETSendDefinitionProcessor sendDefProcessor = new MERC_ETSendDefinitionProcessor();
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
        MERC_ETSendDefinitionProcessor sendDefProcessor = new MERC_ETSendDefinitionProcessor();
        try{
            MERC_ETSendDefinition.StartResponse response = sendDefProcessor.start(createResponse.id, authorizer.soapAuthToken);
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
        MERC_ETSendDefinitionProcessor sendDefProcessor = new MERC_ETSendDefinitionProcessor();
        try{
            MERC_ETSendDefinition.CheckStatusResponse response = sendDefProcessor.checkStatus(createResponse.id, authorizer.soapAuthToken);
            checkStatusSendDefResponseBody = JSON.serialize(response);
        }
        catch(Exception e){
            checkStatusSendDefResponseBody = String.valueOf(e);
        }
        return null;
    }
}