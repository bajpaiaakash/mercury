public with sharing class ETDataExtensionProcessor {
    public ETDataExtensionProcessor() {}

    public void createDataExtensionForSendEmail(SendEmailWrapper wrapper) {
        List<Meeting_Participant_MERC__c> meetingParticipants = [SELECT Id, Name, Account_MERC__c, Meeting_MERC__c
                                                                 FROM Meeting_Participant_MERC__c
                                                                 WHERE Id IN :wrapper.Participants];
        Id meetingId = meetingParticipants[0].Meeting_MERC__c;

        List<ETDataExtension.Field> fields = new List<ETDataExtension.Field>();
        ETDataExtension.Field fSubscriberKey = new ETDataExtension.Field();
        fSubscriberKey.fieldName = 'SubscriberKey';
        fSubscriberKey.fieldType = '0';
        fSubscriberKey.length = '100';
        fSubscriberKey.nullable = false;
        fSubscriberKey.isPrimaryKey = true;
        fields.add(fSubscriberKey);

        List<String> fieldNames = new List<String> {'Meeting Name', 'City of Meeting', 'Venue Name', 'Meeting Start Date', 'Meeting End Date', 'Event Id', 'Meeting Participant Num', 'First Name', 'Last Name'};
        for (String n : fieldNames) {
            ETDataExtension.Field f = new ETDataExtension.Field();
            f.fieldName = n;
            f.fieldType = '0';
            f.length = '255';
            f.nullable = true;
            f.isPrimaryKey = false;
            fields.add(f);
        }
        ETDataExtension.Field fEmailAddress = new ETDataExtension.Field();
        fEmailAddress.fieldName = 'EmailAddress';
        fEmailAddress.fieldType = '0';
        fEmailAddress.length = '255';
        fEmailAddress.nullable = false;
        fEmailAddress.isPrimaryKey = false;
        fields.add(fEmailAddress);

        ETAuthorizer authorizer = new ETAuthorizer();

        Blob deAESKey = Crypto.generateAesKey(256);
        String hexDeAESKey = EncodingUtil.convertToHex(deAESKey);
        String deKey = Datetime.now().format('yyyyMMdd\'T\'HHmmssSSS');
        ETDataExtension.DataExtensionResponse deResponse = this.createDataExtensionWithKeyFieldsAndSoapAuth(deKey, fields, authorizer.soapAuthToken);

        if (deResponse.id == null) {
            throw new DataExtensionException('There was an error creating the data extension.');
        }

        Meeting_MERC__c theMeeting = [SELECT Id, Name, City_of_Meeting_MERC__c, Preferred_Venue_MERC__c, Date_of_Event_MERC__c, End_Date_of_Event_MERC__c, Event_Id_MERC__c
                                      FROM Meeting_MERC__c
                                      WHERE Id = :meetingId];
        Set<Id> personAccountIds = new Set<Id>();
        for (Meeting_Participant_MERC__c mp : meetingParticipants) {
            personAccountIds.add(mp.Account_MERC__c);
        }
        Map<Id, Account> personAccounts = new Map<Id, Account>([SELECT Id, PersonContactId, FirstName, LastName, PersonEmail
                                                                FROM Account
                                                                WHERE Id IN :personAccountIds AND IsPersonAccount = true]);

        List<ETDataExtension.DataExtensionEntry> entries = new List<ETDataExtension.DataExtensionEntry>();
        for (Meeting_Participant_MERC__c mp : meetingParticipants) {
            ETDataExtension.DataExtensionEntry e = new ETDataExtension.DataExtensionEntry();
            e.keys = new ETDataExtension.FieldEntry();
            e.keys.fieldName = 'SubscriberKey';
            e.keys.fieldValue = String.valueOf(personAccounts.get(mp.Account_MERC__c).PersonContactId);

            e.values = new List<ETDataExtension.FieldEntry>();
            ETDataExtension.FieldEntry fe1 = new ETDataExtension.FieldEntry();
            fe1.fieldName = 'Meeting Name';
            fe1.fieldValue = theMeeting.Name;
            e.values.add(fe1);
            ETDataExtension.FieldEntry fe2 = new ETDataExtension.FieldEntry();
            fe2.fieldName = 'City of Meeting';
            fe2.fieldValue = theMeeting.City_of_Meeting_MERC__c;
            e.values.add(fe2);
            ETDataExtension.FieldEntry fe3 = new ETDataExtension.FieldEntry();
            fe3.fieldName = 'Venue Name';
            fe3.fieldValue = theMeeting.Preferred_Venue_MERC__c;
            e.values.add(fe3);
            String dateFormatString = 'MM/dd/yyyy\'T\'HH:mm:ss.SSSZ';
            ETDataExtension.FieldEntry fe4 = new ETDataExtension.FieldEntry();
            fe4.fieldName = 'Meeting Start Date';
            Date startDate = theMeeting.Date_of_Event_MERC__c;
            Datetime startDateTime = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day());
            fe4.fieldValue = startDateTime.format(dateFormatString);
            e.values.add(fe4);
            ETDataExtension.FieldEntry fe5 = new ETDataExtension.FieldEntry();
            fe5.fieldName = 'Meeting End Date';
            Date endDate = theMeeting.End_Date_of_Event_MERC__c;
            Datetime endDateTime = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day());
            fe5.fieldValue = endDateTime.format(dateFormatString);
            e.values.add(fe5);
            ETDataExtension.FieldEntry fe6 = new ETDataExtension.FieldEntry();
            fe6.fieldName = 'Event Id';
            fe6.fieldValue = theMeeting.Event_Id_MERC__c;
            e.values.add(fe6);
            ETDataExtension.FieldEntry fe7 = new ETDataExtension.FieldEntry();
            fe7.fieldName = 'Meeting Participant Num';
            fe7.fieldValue = mp.Name;
            e.values.add(fe7);
            ETDataExtension.FieldEntry fe8 = new ETDataExtension.FieldEntry();
            fe8.fieldName = 'First Name';
            fe8.fieldValue = personAccounts.get(mp.Account_MERC__c).FirstName;
            e.values.add(fe8);
            ETDataExtension.FieldEntry fe9 = new ETDataExtension.FieldEntry();
            fe9.fieldName = 'Last Name';
            fe9.fieldValue = personAccounts.get(mp.Account_MERC__c).LastName;
            e.values.add(fe9);
            ETDataExtension.FieldEntry fe10 = new ETDataExtension.FieldEntry();
            fe10.fieldName = 'EmailAddress';
            fe10.fieldValue = personAccounts.get(mp.Account_MERC__c).PersonEmail;
            e.values.add(fe10);

            entries.add(e);
        }

        HttpResponse res = this.populateDataExtensionForKeyWithValuesAndFuelAuth(deKey, entries, authorizer.fuelAuthToken);

        if (!(res.getStatusCode() >= 200 && res.getStatusCode() < 300)) {
            throw new DataExtensionException('There was an error populating the data extension with key : ' + deKey + '\n' + res.getBody());
        }

        Sonoma_ET_Config__c config = Sonoma_ET_Config__c.getInstance();
        List<et4ae5__Business_Unit__c> bus = [SELECT Id, et4ae5__Business_Unit_ID__c FROM et4ae5__Business_Unit__c WHERE Name = :config.ET_BU_Name__c LIMIT 1];
        et4ae5__SendDefinition__c send = new et4ae5__SendDefinition__c();
        send.et4ae5__DataExtensionId__c = deResponse.Id;
        send.et4ae5__SyncId__c = Datetime.now().format('yyyyMMdd');
        send.et4ae5__Business_Unit__c = bus[0].Id;
        send.et4ae5__SendStatus__c = 'New';
        send.et4ae5__FromName__c = config.Default_From_Name__c;
        send.et4ae5__Reply_to__c = config.Default_From_Email__c + ' <' + wrapper.FromAddress + '>';
        send.et4ae5__FromEmail__c = wrapper.FromAddress;
        send.et4ae5__RecipientsOptedIn__c = true;
        send.et4ae5__DedupeSubscribers__c = wrapper.DeDupSubscribers;
        send.et4ae5__Individual_Tracking_Disabled__c = wrapper.DisableIndividualTracking;
        //send.et4ae5__SendTime__c = Datetime.now();
        send.et4ae5__EmailId__c = wrapper.Email.id;
        send.et4ae5__EmailName__c = wrapper.Email.name;
        send.et4ae5__Subject__c = wrapper.Email.title;
        send.et4ae5__SubjectLine__c = wrapper.Email.title;
        insert send;

        send = [SELECT Id, et4ae5__SyncComplete__c FROM et4ae5__SendDefinition__c WHERE Id = :send.Id];
        send.et4ae5__SyncComplete__c = true;
        update send;

        Meeting_Email_Send_MERC__c meetingEmailSend = new Meeting_Email_Send_MERC__c();
        meetingEmailSend.Meeting_MERC__c = meetingId;
        meetingEmailSend.Email_Send_Number_MERC__c = send.Id;
        insert meetingEmailSend;

        List<Meeting_Participant_Email_Send_MERC__c> mpEmailSends = new List<Meeting_Participant_Email_Send_MERC__c>();
        for (Meeting_Participant_MERC__c mp : wrapper.Participants) {
            Meeting_Participant_Email_Send_MERC__c mpes = new Meeting_Participant_Email_Send_MERC__c();
            mpes.Meeting_Email_Send__c = meetingEmailSend.Id;
            mpes.Meeting_Participant__c = mp.Id;
            mpEmailSends.add(mpes);
        }
        insert mpEmailSends;

        return;
    }

    public ETDataExtension.DataExtensionResponse createDataExtensionWithKeyFieldsAndSoapAuth(String deKey, List<ETDataExtension.Field> fields, String authToken) {
        String deName = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss') + ' Data Extension';
        ETDataExtension de = new ETDataExtension(deName, deName, deKey);
        de.sendableDataExtensionField = fields[0].fieldName;
        de.field.addAll(fields);
    
        et4ae5__Configuration__c configInfo = [SELECT et4ae5__Root_Rest_API_URL__c FROM et4ae5__Configuration__c LIMIT 1];
        String endPoint = configInfo.et4ae5__Root_Rest_API_URL__c + '/rest/beta/object/?oauth_token=' + authToken;

        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Accept', 'application/json');
        req.setBody(JSON.serialize(de));
        System.debug('req body : ' + req.getBody());

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('res : ' + res);
        System.debug('res body : ' + res.getBody());

        ETDataExtension.DataExtensionResponse deResponse = (ETDataExtension.DataExtensionResponse)JSON.deserialize(res.getBody(), ETDataExtension.DataExtensionResponse.class);
        return deResponse;
    }

    public HttpResponse populateDataExtensionForKeyWithValuesAndFuelAuth(String deKey, List<ETDataExtension.DataExtensionEntry> entries, String authToken) {
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartArray();
        for (ETDataExtension.DataExtensionEntry dee : entries) {
            gen.writeStartObject();
                gen.writeFieldName('keys');
                gen.writeStartObject();
                    gen.writeStringField(dee.keys.fieldName, dee.keys.fieldValue);
                gen.writeEndObject();
                gen.writeFieldName('values');
                gen.writeStartObject();
                for (ETDataExtension.FieldEntry fe : dee.values) {
                    if (fe.fieldValue != null) {
                        gen.writeStringField(fe.fieldName, fe.fieldValue);
                    } else {
                        gen.writeStringField(fe.fieldName, '');
                    }
                }
                gen.writeEndObject();
            gen.writeEndObject();
        }
        gen.writeEndArray();

        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint('https://www.exacttargetapis.com/hub/v1/dataevents/key:' + EncodingUtil.urlEncode(deKey, 'UTF-8') + '/rowset');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('authorization', 'Bearer ' + authToken);
        req.setBody(gen.getAsString());

        Http h = new Http();
        HttpResponse res = h.send(req);

        return res;
    }

    public class DataExtensionException extends Exception {}
}