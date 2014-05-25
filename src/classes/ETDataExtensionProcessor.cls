public with sharing class ETDataExtensionProcessor {
    public ETDataExtensionProcessor() {}

    public void createDataExtensionForSendEmail(SendEmailWrapper wrapper) {
        if (wrapper.Participants.size() > 1000) {
            throw new DataExtensionException('There can be at most 1000 participants per email send.');
        }

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
        fEmailAddress.fieldType = '4'; //EmailAddress
        fEmailAddress.length = '200';
        fEmailAddress.nullable = false;
        fEmailAddress.isPrimaryKey = false;
        fields.add(fEmailAddress);

        ETAuthorizer authorizer = new ETAuthorizer();

        Blob deAESKey = Crypto.generateAesKey(256);
        String hexDeAESKey = EncodingUtil.convertToHex(deAESKey);
        //account for max length of DE name
        String deSubject = wrapper.Email.title.length() > 140 ? wrapper.Email.title.substring(0, 139) : wrapper.Email.title;
        String deName = 'SalesforceMeeting-' + meetingId + '-' + deSubject.replaceAll('[^a-zA-Z0-9]+', '') + '-' + Datetime.now().format('yyyyMMdd\'T\'HHmmssSSS');
        String deKey = String.valueOf(meetingId) + Datetime.now().format('yyyyMMdd\'T\'HHmmssSSS');

        //default expiration to 3 days for immediate sends, otherwise ensure DE will still be around when scheduled send actually goes out.
        Datetime deExpiration = Datetime.now().addDays(3);
        if (wrapper.SendTime != 'now') {
            deExpiration = wrapper.FutureSendTime.addDays(3);
        }

        ETDataExtension.DataExtensionResponse deResponse = this.createDataExtensionWithNameKeyFieldsAndSoapAuth(deName, deKey, fields, authorizer.soapAuthToken, deExpiration);

        if (deResponse.id == null) {
            throw new DataExtensionException('There was an error creating the data extension.');
        }

        Meeting_MERC__c theMeeting = [SELECT Id, Name, City_of_Meeting_MERC__c, Preferred_Venue_MERC__c, Date_of_Event_MERC__c, End_Date_of_Event_MERC__c, Event_Id_MERC__c, Start_Time_of_Meeting_MERC__c, End_Time_of_Meeting_MERC__c
                                      FROM Meeting_MERC__c
                                      WHERE Id = :meetingId];
        Set<Id> personAccountIds = new Set<Id>();
        for (Meeting_Participant_MERC__c mp : meetingParticipants) {
            personAccountIds.add(mp.Account_MERC__c);
        }
        Map<Id, Account> personAccounts = new Map<Id, Account>([SELECT Id, PersonContactId, FirstName, LastName, PersonEmail
                                                                FROM Account
                                                                WHERE Id IN :personAccountIds AND IsPersonAccount = true]);

        List<List<Meeting_Participant_MERC__c>> participantSublists = new List<List<Meeting_Participant_MERC__c>>();
        Integer participantIndex = 0;
        Integer participantsSize = meetingParticipants.size();
        while (participantIndex < participantsSize) {
            List<Meeting_Participant_MERC__c> sublist = new List<Meeting_Participant_MERC__c>();
            for (Integer count = 0; count < 200 && participantIndex < participantsSize; count++) {
                sublist.add(meetingParticipants[participantIndex]);
                participantIndex++;
            }
            participantSublists.add(sublist);
        }

        for (List<Meeting_Participant_MERC__c> sublist : participantSublists) {
            List<ETDataExtension.DataExtensionEntry> entries = new List<ETDataExtension.DataExtensionEntry>();
            for (Meeting_Participant_MERC__c mp : sublist) {
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
                String dateFormatString = 'MM/dd/yyyy HH:mm:ss z';
                ETDataExtension.FieldEntry fe4 = new ETDataExtension.FieldEntry();
                fe4.fieldName = 'Meeting Start Date';
                Datetime startDateTime = theMeeting.Start_Time_of_Meeting_MERC__c;
                fe4.fieldValue = startDateTime.format(dateFormatString);
                e.values.add(fe4);
                ETDataExtension.FieldEntry fe5 = new ETDataExtension.FieldEntry();
                fe5.fieldName = 'Meeting End Date';
                Datetime endDateTime = theMeeting.End_Time_of_Meeting_MERC__c;
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

            System.debug('authorizer.fuelAuthToken : ' + authorizer.fuelAuthToken);
            HttpResponse res = this.populateDataExtensionForKeyWithValuesAndFuelAuth(deKey, entries, authorizer.fuelAuthToken);

            if (!(res.getStatusCode() >= 200 && res.getStatusCode() < 300)) {
                throw new DataExtensionException('There was an error populating the data extension with key : ' + deKey + '\n' + res.getBody());
            }
        }

        Sonoma_ET_Config__c config = Sonoma_ET_Config__c.getInstance();
        List<et4ae5__Business_Unit__c> bus = [SELECT Id, et4ae5__Business_Unit_ID__c FROM et4ae5__Business_Unit__c WHERE Name = :config.ET_BU_Name__c LIMIT 1];
        et4ae5__SendDefinition__c send = new et4ae5__SendDefinition__c();
        send.et4ae5__DataExtensionId__c = deResponse.Id;
        send.et4ae5__SyncId__c = 'ETLillySend' + Datetime.now().format('yyyyMMdd');
        send.et4ae5__Business_Unit__c = bus[0].Id;
        if (wrapper.SendTime == 'now') {
            send.et4ae5__SendStatus__c = 'New';
        } else {
            send.et4ae5__SendStatus__c = 'Scheduled';
            send.et4ae5__Scheduled_Date_Time__c = wrapper.FutureSendTime;
        }
        send.et4ae5__FromName__c = config.Default_From_Name__c;
        send.et4ae5__Reply_to__c = config.Default_From_Email__c + ' <' + wrapper.FromAddress + '>';
        send.et4ae5__FromEmail__c = wrapper.FromAddress;
        send.et4ae5__RecipientsOptedIn__c = true;
        send.et4ae5__DedupeSubscribers__c = wrapper.DeDupSubscribers;
        send.et4ae5__Individual_Tracking_Disabled__c = wrapper.DisableIndividualTracking;
        send.et4ae5__EmailId__c = wrapper.Email.id;
        send.et4ae5__EmailName__c = wrapper.Email.name;
        send.et4ae5__Subject__c = wrapper.Email.title;
        send.et4ae5__SubjectLine__c = wrapper.Email.title;

        String thumbnailData = '';
        try {
            thumbnailData = retrieveThumbnailForEmailSend(send, authorizer.soapAuthToken);
        } catch (Exception e) {
            System.debug ('Exception retrieving the preview image : ' + e.getMessage() + '\n' + e.getStackTraceString());
        }


        insert send;

        send = [SELECT Id, et4ae5__SyncComplete__c, et4ae5__Thumbnail__c FROM et4ae5__SendDefinition__c WHERE Id = :send.Id];
        if (thumbnailData.length() < 32768) {
            send.et4ae5__Thumbnail__c = thumbnailData;
            //update send;
        } else {
            try {
                Attachment a = new Attachment();
                a.ParentId = send.Id;
                a.Body = Blob.valueOf(thumbnailData);
                a.Name = 'Thumbnail Data';
                insert a;
            } catch (Exception e) {
                System.debug('Exception saving attachment of preview : ' + e.getMessage() + '\n' + e.getStackTraceString());
            }
        }

        //if scheduled a workflow will set SyncComplete flag when ScheduledDateTime is reached
        if (wrapper.SendTime == 'now') {
            send.et4ae5__SyncComplete__c = true;
        }

        update send;

        // queue up a future method to retrieve the thumbnail
        //ETDataExtensionProcessor.retrieveThumbnailForEmailSend(send.Id);

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

    public ETDataExtension.DataExtensionResponse createDataExtensionWithNameKeyFieldsAndSoapAuth(String deName, String deKey, List<ETDataExtension.Field> fields, 
        String authToken, DateTime expiresIn) {
        //String deName = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss') + ' Data Extension';
        String deDescription = 'Used for sending meeting from Salesforce.com';
        ETDataExtension de = new ETDataExtension(deName, deDescription, deKey, expiresIn);
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

    //@future (callout=true)
    public String retrieveThumbnailForEmailSend(et4ae5__SendDefinition__c emailSend, String soapAuthToken) {
        et4ae5__Configuration__c configInfo = [SELECT et4ae5__Root_Rest_API_URL__c, et4ae5__url_root__c, et4ae5__url_part__c
                                       FROM et4ae5__Configuration__c
                                       ORDER BY LastModifiedDate DESC
                                       LIMIT 1];

        String thumbnailURL = configInfo.et4ae5__Root_Rest_API_URL__c;
        thumbnailURL = thumbnailURL.replace('rest', configInfo.et4ae5__url_root__c);
        thumbnailURL += String.format('/{0}/utilities/ImageThumbnailSecure.ashx/?h={1}&w={2}&emailid={3}&oauth_token={4}', 
                                      new List<String> { configInfo.et4ae5__url_part__c, '700', '700', emailSend.et4ae5__EmailId__c, soapAuthToken });
        System.debug('thumbnailURL : ' + thumbnailURL);

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(thumbnailURL);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('res : ' + res.getBody());
        ImageThumbnailSecureResponse thumbnailResponse = (ImageThumbnailSecureResponse)JSON.deserialize(res.getBody(), ImageThumbnailSecureResponse.class);
        return thumbnailResponse.data;
    }

    public class ImageThumbnailSecureResponse {
        public String data;
    }

    public class DataExtensionException extends Exception {}
}