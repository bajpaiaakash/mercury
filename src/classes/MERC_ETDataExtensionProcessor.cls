public with sharing class MERC_ETDataExtensionProcessor {
    public MERC_ETDataExtensionProcessor() {}

    public void createDataExtensionForSendEmail(MERC_ETSendEmailWrapper wrapper) {
        if (wrapper.Participants.size() > 1000) {
            throw new DataExtensionException('There can be at most 1000 participants per email send.');
        }

        List<Meeting_Participant_MERC__c> meetingParticipants = [SELECT Id, Name, Account_MERC__c, Meeting_MERC__c, Types_of_Service_MERC__c
                                                                 FROM Meeting_Participant_MERC__c
                                                                 WHERE Id IN :wrapper.Participants];
        Id meetingId = meetingParticipants[0].Meeting_MERC__c;

        List<MERC_ETDataExtension.Field> fields = new List<MERC_ETDataExtension.Field>();
        MERC_ETDataExtension.Field fSubscriberKey = new MERC_ETDataExtension.Field();
        fSubscriberKey.fieldName = 'SubscriberKey';
        fSubscriberKey.fieldType = '0';
        fSubscriberKey.length = '100';
        fSubscriberKey.nullable = false;
        fSubscriberKey.isPrimaryKey = true;
        fields.add(fSubscriberKey);

        List<String> fieldNames = new List<String> {'Meeting Name', 'City of Meeting', 'Venue Name', 'Meeting Start Date', 'Meeting End Date', 'Event Id', 'Meeting Participant Num', 'First Name', 'Last Name', 'Salutation', 'Type of Service'};
        for (String n : fieldNames) {
            MERC_ETDataExtension.Field f = new MERC_ETDataExtension.Field();
            f.fieldName = n;
            f.fieldType = '0';
            f.length = '255';
            f.nullable = true;
            f.isPrimaryKey = false;
            fields.add(f);
        }
        MERC_ETDataExtension.Field fEmailAddress = new MERC_ETDataExtension.Field();
        fEmailAddress.fieldName = 'EmailAddress';
        fEmailAddress.fieldType = '4'; //EmailAddress
        fEmailAddress.length = '200';
        fEmailAddress.nullable = false;
        fEmailAddress.isPrimaryKey = false;
        fields.add(fEmailAddress);

        MERC_ETAuthorizer authorizer = new MERC_ETAuthorizer();

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

        MERC_ETDataExtension.DataExtensionResponse deResponse = this.createDataExtensionWithNameKeyFieldsAndSoapAuth(deName, deKey, fields, authorizer.soapAuthToken, deExpiration);

        if (deResponse.id == null) {
            throw new DataExtensionException('There was an error creating the data extension.');
        }

        Meeting_MERC__c theMeeting = [SELECT Id, Name, City_of_Meeting_MERC__c, Venue_ET_Email_Template_MERC__c, Date_of_Event_MERC__c, End_Date_of_Event_MERC__c, Event_Id_MERC__c, Start_Time_of_Meeting_MERC__c, End_Time_of_Meeting_MERC__c
                                      FROM Meeting_MERC__c
                                      WHERE Id = :meetingId];
        Set<Id> personAccountIds = new Set<Id>();
        for (Meeting_Participant_MERC__c mp : meetingParticipants) {
            personAccountIds.add(mp.Account_MERC__c);
        }
        Map<Id, Account> personAccounts = new Map<Id, Account>([SELECT Id, PersonContactId, FirstName, LastName, PersonEmail, Salutation
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
            List<MERC_ETDataExtension.DataExtensionEntry> entries = new List<MERC_ETDataExtension.DataExtensionEntry>();
            for (Meeting_Participant_MERC__c mp : sublist) {
                MERC_ETDataExtension.DataExtensionEntry e = new MERC_ETDataExtension.DataExtensionEntry();
                e.keys = new MERC_ETDataExtension.FieldEntry();
                e.keys.fieldName = 'SubscriberKey';
                e.keys.fieldValue = String.valueOf(personAccounts.get(mp.Account_MERC__c).PersonContactId);

                e.values = new List<MERC_ETDataExtension.FieldEntry>();
                
                MERC_ETDataExtension.FieldEntry fe1 = new MERC_ETDataExtension.FieldEntry();
                fe1.fieldName = 'Meeting Name';
                fe1.fieldValue = theMeeting.Name;
                e.values.add(fe1);
                
                MERC_ETDataExtension.FieldEntry fe2 = new MERC_ETDataExtension.FieldEntry();
                fe2.fieldName = 'City of Meeting';
                fe2.fieldValue = theMeeting.City_of_Meeting_MERC__c;
                e.values.add(fe2);
                
                MERC_ETDataExtension.FieldEntry fe3 = new MERC_ETDataExtension.FieldEntry();
                fe3.fieldName = 'Venue Name';
                fe3.fieldValue = theMeeting.Venue_ET_Email_Template_MERC__c;
                e.values.add(fe3);
                
                String dateFormatString = 'MM/dd/yyyy HH:mm:ss z';
                MERC_ETDataExtension.FieldEntry fe4 = new MERC_ETDataExtension.FieldEntry();
                fe4.fieldName = 'Meeting Start Date';
                Datetime startDateTime = theMeeting.Start_Time_of_Meeting_MERC__c;
                fe4.fieldValue = startDateTime.format(dateFormatString);
                e.values.add(fe4);
                
                MERC_ETDataExtension.FieldEntry fe5 = new MERC_ETDataExtension.FieldEntry();
                fe5.fieldName = 'Meeting End Date';
                Datetime endDateTime = theMeeting.End_Time_of_Meeting_MERC__c;
                fe5.fieldValue = endDateTime.format(dateFormatString);
                e.values.add(fe5);
                
                MERC_ETDataExtension.FieldEntry fe6 = new MERC_ETDataExtension.FieldEntry();
                fe6.fieldName = 'Event Id';
                fe6.fieldValue = theMeeting.Event_Id_MERC__c;
                e.values.add(fe6);
                
                MERC_ETDataExtension.FieldEntry fe7 = new MERC_ETDataExtension.FieldEntry();
                fe7.fieldName = 'Meeting Participant Num';
                fe7.fieldValue = mp.Name;
                e.values.add(fe7);
                
                MERC_ETDataExtension.FieldEntry fe8 = new MERC_ETDataExtension.FieldEntry();
                fe8.fieldName = 'First Name';
                fe8.fieldValue = personAccounts.get(mp.Account_MERC__c).FirstName;
                e.values.add(fe8);
                
                MERC_ETDataExtension.FieldEntry fe9 = new MERC_ETDataExtension.FieldEntry();
                fe9.fieldName = 'Last Name';
                fe9.fieldValue = personAccounts.get(mp.Account_MERC__c).LastName;
                e.values.add(fe9);
                
                MERC_ETDataExtension.FieldEntry fe10 = new MERC_ETDataExtension.FieldEntry();
                fe10.fieldName = 'Salutation';
                fe10.fieldValue = personAccounts.get(mp.Account_MERC__c).Salutation;
                e.values.add(fe10);
                
                MERC_ETDataExtension.FieldEntry fe11 = new MERC_ETDataExtension.FieldEntry();
                fe11.fieldName = 'EmailAddress';
                fe11.fieldValue = personAccounts.get(mp.Account_MERC__c).PersonEmail;
                e.values.add(fe11);

				MERC_ETDataExtension.FieldEntry fe12 = new MERC_ETDataExtension.FieldEntry();
				fe12.fieldName = 'Type of Service';
				fe12.fieldValue = mp.Types_of_Service_MERC__c;
				e.values.add(fe12);

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

        // queue up a future method to retrieve the thumbnail
        //MERC_ETDataExtensionProcessor.retrieveThumbnailForEmailSend(send.Id);

        Meeting_Email_Send_MERC__c meetingEmailSend = new Meeting_Email_Send_MERC__c();
        meetingEmailSend.Meeting_MERC__c = meetingId;
        
        // Populate fields that will be placed on the email send
        meetingEmailSend.ET_Data_Extension_Id_MERC__c = deResponse.Id;
        meetingEmailSend.ET_Sync_Id_MERC__c = 'ETLillymeetingEmailSend' + Datetime.now().format('yyyyMMdd');
        meetingEmailSend.ET_Business_Unit_MERC__c = bus[0].Id;
        meetingEmailSend.ET_From_Name_MERC__c = config.Default_From_Name__c;
        meetingEmailSend.ET_Reply_to_MERC__c = config.Default_From_Email__c + ' <' + wrapper.FromAddress + '>';
        meetingEmailSend.ET_From_Email_MERC__c = wrapper.FromAddress;
        meetingEmailSend.ET_From_Address_MERC__c = wrapper.FromAddress;
        meetingEmailSend.ET_Recipients_Opted_In_MERC__c = true;
        meetingEmailSend.ET_Dedupe_Subscribers_MERC__c = wrapper.DeDupSubscribers;
        meetingEmailSend.ET_Individual_Tracking_Disabled_MERC__c = wrapper.DisableIndividualTracking;
        meetingEmailSend.ET_Email_ID_MERC__c = wrapper.Email.id;
        meetingEmailSend.ET_Email_Name_MERC__c = wrapper.Email.name;
        meetingEmailSend.ET_Subject_MERC__c = wrapper.Email.title;
        meetingEmailSend.ET_Subject_Line_MERC__c = wrapper.Email.title;
        
        if (wrapper.SendTime == 'now') {
            meetingEmailSend.Send_Status__c = 'Create Sender Profile';
            meetingEmailSend.Send_Email__c = true;
        } else {
            meetingEmailSend.Scheduled_Date__c = wrapper.FutureSendTime;
        }
        
        String thumbnailData = '';
        try {
            thumbnailData = retrieveThumbnailForEmailSend(meetingEmailSend, authorizer.soapAuthToken);
        } catch (Exception e) {
            System.debug ('Exception retrieving the preview image : ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        insert meetingEmailSend;
        
        meetingEmailSend = [SELECT Id, ET_Thumbnail_MERC__c FROM Meeting_Email_Send_MERC__c WHERE Id = :meetingEmailSend.Id LIMIT 1];
        
        if (thumbnailData != null && thumbnailData.length() < 32768) {
            meetingEmailSend.ET_Thumbnail_MERC__c = thumbnailData; // do the same as attachment body on line 220
        } else {
	        try {
	            Attachment a = new Attachment();
	            a.contentType = 'image/png';
	            a.ParentId = meetingEmailSend.Id;
	            a.Body = Blob.valueOf(thumbnailData);//EncodingUtil.base64Decode(thumbnailData);
	            a.Name = 'Thumbnail Data';
	            insert a;
	        } catch (Exception e) {
	            System.debug('Exception saving attachment of preview : ' + e.getMessage() + '\n' + e.getStackTraceString());
	        }
        }
        
        update meetingEmailSend;

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

    public MERC_ETDataExtension.DataExtensionResponse createDataExtensionWithNameKeyFieldsAndSoapAuth(String deName, String deKey, List<MERC_ETDataExtension.Field> fields, 
        String authToken, DateTime expiresIn) {
        //String deName = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss') + ' Data Extension';
        String deDescription = 'Used for sending meeting from Salesforce.com';
        MERC_ETDataExtension de = new MERC_ETDataExtension(deName, deDescription, deKey, expiresIn);
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

        MERC_ETDataExtension.DataExtensionResponse deResponse = (MERC_ETDataExtension.DataExtensionResponse)JSON.deserialize(res.getBody(), MERC_ETDataExtension.DataExtensionResponse.class);
        return deResponse;
    }

    public HttpResponse populateDataExtensionForKeyWithValuesAndFuelAuth(String deKey, List<MERC_ETDataExtension.DataExtensionEntry> entries, String authToken) {
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartArray();
        for (MERC_ETDataExtension.DataExtensionEntry dee : entries) {
            gen.writeStartObject();
                gen.writeFieldName('keys');
                gen.writeStartObject();
                    gen.writeStringField(dee.keys.fieldName, dee.keys.fieldValue);
                gen.writeEndObject();
                gen.writeFieldName('values');
                gen.writeStartObject();
                for (MERC_ETDataExtension.FieldEntry fe : dee.values) {
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
    public String retrieveThumbnailForEmailSend(Meeting_Email_Send_MERC__c meetingEmailSend, String soapAuthToken) {
        et4ae5__Configuration__c configInfo = [SELECT et4ae5__Root_Rest_API_URL__c, et4ae5__url_root__c, et4ae5__url_part__c
                                       FROM et4ae5__Configuration__c
                                       ORDER BY LastModifiedDate DESC
                                       LIMIT 1];

        String thumbnailURL = configInfo.et4ae5__Root_Rest_API_URL__c;
        thumbnailURL = thumbnailURL.replace('rest', configInfo.et4ae5__url_root__c);
        thumbnailURL += String.format('/{0}/utilities/ImageThumbnailSecure.ashx/?h={1}&w={2}&emailid={3}&oauth_token={4}', 
                                      new List<String> { configInfo.et4ae5__url_part__c, '700', '700', meetingEmailSend.ET_Email_Id_MERC__c, soapAuthToken });
        System.Debug('thumbnailURL: ' + thumbnailURL);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(thumbnailURL);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(5000);

        Http h = new Http();
        HttpResponse res = h.send(req);
        
        System.debug('res body: ' + res.getBody());
        ImageThumbnailSecureResponse thumbnailResponse = (ImageThumbnailSecureResponse)JSON.deserialize(res.getBody(), ImageThumbnailSecureResponse.class);
        return thumbnailResponse.data;
    }

    public class ImageThumbnailSecureResponse {
        public String data;
    }

    public class DataExtensionException extends Exception {}
}