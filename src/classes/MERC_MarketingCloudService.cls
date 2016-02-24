/*
* MERC_MarketingCloudService
* Description : Handles business logic related to Marketing Cloud processes
* Author: David Helmer (refactored from Sonoma)
* Modified By: 
* Modified Date: Dec. 11th 2015
*/
public with sharing class MERC_MarketingCloudService {
    private static final Mercury_Marketing_Cloud_Settings_MERC__c MarketingCloudSettings;
    private static final et4ae5__Configuration__c Configuration;
    private static final et4ae5__Business_Unit__c BusinessUnit;

    public static final String CreateSenderProfile = 'Create Sender Profile';
    public static final String CreateSendDefinition = 'Create Send Definition';
    public static final String StartSendDefinition = 'Start Send Definition';
    public static final String CheckSendStatus = 'Check Send Status';
    public static final String EmailSendCreated = 'Email Send Created';
    public static final String StatusProcessing = 'Processing';
    public static final String StatusCompleted = 'Completed';

    public static final Integer MaxFolderDepth = 6;
    public static final Integer HighMaxRetryCount = 299;
    public static final Integer LowMaxRetryCount = 2;

    static {
        MarketingCloudSettings = Mercury_Marketing_Cloud_Settings_MERC__c.getInstance();
        Configuration = [SELECT et4ae5__UserName__c,
                                et4ae5__Password__c, 
                                et4ae5__Auth_API_URL__c,
                                et4ae5__Root_Rest_API_URL__c,
                                et4ae5__integration_type__c,
                                et4ae5__url_root__c
                           FROM et4ae5__Configuration__c
                       ORDER BY LastModifiedDate DESC
                          LIMIT 1];
        List<et4ae5__Business_Unit__c> businessUnits = [SELECT Id,
                                                               et4ae5__Business_Unit_ID__c 
                                                          FROM et4ae5__Business_Unit__c 
                                                         WHERE Name = :MarketingCloudSettings.Business_Unit_Name_MERC__c 
                                                         LIMIT 1];
        if(businessUnits != null && !businessUnits.isEmpty()){
            BusinessUnit = businessUnits[0];
        }
    }

    public static String getUrlRoot(){
        return Configuration.et4ae5__url_root__c;
    }

    /* 
     *  thumbnails
     */
    public static String getThumbnail(String emailId){
        return MERC_MarketingCloudClient.getThumbnail(emailId, 
                                                      (Integer)MarketingCloudSettings.Thumbnail_Height_MERC__c,
                                                      (Integer)MarketingCloudSettings.Thumbnail_Width_MERC__c);
    }

    /* 
     *  sender profile select options 
     */
    public static List<SelectOption> getSenderProfileSelectOptions() {
        List<SelectOption> selectOptions = new List<SelectOption>();
        List<MERC_MarketingCloudClient.SenderProfile> senderProfiles = MERC_MarketingCloudClient.getSenderProfiles();
        if(senderProfiles != null){
            for(MERC_MarketingCloudClient.SenderProfile senderProfile : senderProfiles){
                if(String.isBlank(MarketingCloudSettings.Sender_Profile_Prefix_Filter_MERC__c) ||
                    senderProfile.profileName.startsWith(MarketingCloudSettings.Sender_Profile_Prefix_Filter_MERC__c)){
                    selectOptions.add(new SelectOption(senderProfile.id, displayNameFor(senderProfile)));
                }
            }
        }
        return selectOptions;
    }

    private static String displayNameFor(MERC_MarketingCloudClient.SenderProfile senderProfile){
        String fullName = senderProfile.fromName;
        String emailAddress = senderProfile.fromEmail;

        return fullName + ' <' + emailAddress + '>';
    }

    /* 
     *  email folders
     */
    public static List<MERC_MarketingCloudClient.EmailFolder> getEmailFolders(){
        return MERC_MarketingCloudClient.getEmailFolders();
    }

    public static List<MERC_MarketingCloudClient.EmailFolder> updateForFolder(
        List<MERC_MarketingCloudClient.EmailFolder> emailFolders, 
        String folderId){
        List<MERC_MarketingCloudClient.EmailFolder> foldersToCheck = emailFolders;
        Integer folderDepth = 0;
        Boolean folderFound = false;
        while(foldersToCheck.size() > 0 && folderDepth < MaxFolderDepth && !folderFound){
            folderDepth++;
            List<MERC_MarketingCloudClient.EmailFolder> nextFoldersToCheck = new List<MERC_MarketingCloudClient.EmailFolder>();
            for(MERC_MarketingCloudClient.EmailFolder emailFolder : foldersToCheck){
                if(emailFolder.Id == folderId){
                    folderFound = true;
                    emailFolder.subfolders = MERC_MarketingCloudClient.getEmailFolders(folderId);
                    emailFolder.emails = MERC_MarketingCloudClient.getEmails(folderId);
                    if((emailFolder.subfolders == null || emailFolder.subfolders.isEmpty()) &&
                        emailFolder.emails == null || emailFolder.emails.isEmpty()) {
                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING,'There are no emails in the "'+emailFolder.name+'" folder.') );
                    }
                    break;
                } else if(emailFolder.subfolders != null){
                    nextFoldersToCheck.addAll(emailFolder.subfolders);
                }
            }
            foldersToCheck = nextFoldersToCheck;
        }

        return emailFolders;
    }

    public static void prepareMeetingEmailSendForAttempts(Id meetingId,
                                                          MERC_MarketingCloudClient.FolderedEmail email, 
                                                          List<Meeting_Participant_MERC__c> participants, 
                                                          Boolean deDupe, 
                                                          Boolean disableIndividualTracking, 
                                                          String sendTime, 
                                                          Datetime futureSendTime, 
                                                          String additionalInformationHTML,
                                                          String additionalInformationText,
                                                          String fromSenderProfileId,
                                                          String fromClassificationId){
        DateTime now = DateTime.now();
        if(Test.isRunningTest()){
            now = DateTime.newInstanceGmt(1984, 1, 31, 7, 8, 16);
        }

        List<MERC_MarketingCloudClient.Field> fields = getFields();

        List<Meeting_Participant_MERC__c> meetingParticipants = queryParticipants(participants);
        Map<Id, Account> personAccounts = queryPersonAccounts(meetingParticipants);

        MERC_MarketingCloudClient.DataExtension dataExtension = populateDataExtension(email.subject, meetingId, futureSendTime, sendTime, fields);
        String dataExtensionId = createDataExtension(dataExtension);

        createDataExtensionEntries(meetingId, additionalInformationHTML, additionalInformationText, meetingParticipants, personAccounts, dataExtension);

        Meeting_Email_Send_MERC__c meetingEmailSend = new Meeting_Email_Send_MERC__c();
        meetingEmailSend.Meeting_MERC__c = meetingId;

        // Populate fields that will be placed on the email send
        meetingEmailSend.ET_Data_Extension_Id_MERC__c = dataExtensionId;
        meetingEmailSend.ET_Sync_Id_MERC__c = 'ETLillymeetingEmailSend' + now.format('yyyyMMdd');
        meetingEmailSend.ET_Business_Unit_MERC__c = BusinessUnit.Id;
        meetingEmailSend.ET_Recipients_Opted_In_MERC__c = true;
        meetingEmailSend.ET_Sender_Profile_Id_MERC__c = fromSenderProfileId;
        meetingEmailSend.ET_Send_Classification_Id_MERC__c = fromClassificationId;
        meetingEmailSend.ET_Dedupe_Subscribers_MERC__c = deDupe;
        meetingEmailSend.ET_Individual_Tracking_Disabled_MERC__c = disableIndividualTracking;
        meetingEmailSend.ET_Email_ID_MERC__c = email.id;
        meetingEmailSend.ET_Email_Name_MERC__c = email.name;
        meetingEmailSend.ET_Subject_MERC__c = email.subject;
        meetingEmailSend.ET_Subject_Line_MERC__c = email.subject;
        meetingEmailSend.Additional_Information_MERC__c = additionalInformationHTML;
        meetingEmailSend.Additional_Information_Plain_Text_MERC__c = additionalInformationText;

        if (sendTime == 'now') {
            meetingEmailSend.Send_Status__c = CreateSenderProfile;
            meetingEmailSend.Send_Email__c = true;
        } else {
            meetingEmailSend.Scheduled_Date__c = futureSendTime;
        }

        String thumbnailData = '';
        try {
            thumbnailData = getThumbnail(email.Id);
        } catch (Exception e) {
            System.debug ('Exception retrieving the preview image : ' + e.getMessage() + '\n' + e.getStackTraceString());
        }

        if (thumbnailData != null && thumbnailData.length() < 32768) {
            meetingEmailSend.ET_Thumbnail_MERC__c = thumbnailData; // do the same as attachment body on line 220
        } 

        //insert meetingEmailSend;
        attemptMeetingEmailSend(meetingEmailSend);

        List<Meeting_Participant_Email_Send_MERC__c> meetingParticipantEmailSends = new List<Meeting_Participant_Email_Send_MERC__c>();
        for (Meeting_Participant_MERC__c meetingParticipant : participants) {
            Meeting_Participant_Email_Send_MERC__c meetingParticipantEmailSend = new Meeting_Participant_Email_Send_MERC__c();
            meetingParticipantEmailSend.Meeting_Email_Send__c = meetingEmailSend.Id;
            meetingParticipantEmailSend.Meeting_Participant__c = meetingParticipant.Id;
            meetingParticipantEmailSends.add(meetingParticipantEmailSend);
        }
        insert meetingParticipantEmailSends;

        // at this point this should get picked up by a trigger which eventually calls attemptMeetingEmailSend
        //attemptMeetingEmailSend(meetingEmailSend);
        return;
    }  

    private static List<MERC_MarketingCloudClient.Field> getFields(){
        List<MERC_MarketingCloudClient.Field> fields = new List<MERC_MarketingCloudClient.Field>();

        MERC_MarketingCloudClient.Field fSubscriberKey = new MERC_MarketingCloudClient.Field();
        fSubscriberKey.fieldName = 'SubscriberKey';
        fSubscriberKey.fieldType = '0';
        fSubscriberKey.length = '100';
        fSubscriberKey.nullable = false;
        fSubscriberKey.isPrimaryKey = true;
        fields.add(fSubscriberKey);

        List<String> fieldNames = new List<String> {'AccountId', 'MeetingId', 'MeetingParticipantId'};

        for (String fieldName : fieldNames) {
            MERC_MarketingCloudClient.Field field = new MERC_MarketingCloudClient.Field();
            field.fieldName = fieldName;
            field.fieldType = '0'; //Text
            field.length = '255';
            field.nullable = true;
            field.isPrimaryKey = false;
            fields.add(field);
        }

        MERC_MarketingCloudClient.Field additionalInformationHTMLField = new MERC_MarketingCloudClient.Field();
        additionalInformationHTMLField.fieldName = 'AdditionalInformationHTML';
        additionalInformationHTMLField.fieldType = '0'; //Text
        additionalInformationHTMLField.length = '2000';
        additionalInformationHTMLField.nullable = true;
        additionalInformationHTMLField.isPrimaryKey = false;
        fields.add(additionalInformationHTMLField);

        MERC_MarketingCloudClient.Field additionalInformationTextField = new MERC_MarketingCloudClient.Field();
        additionalInformationTextField.fieldName = 'AdditionalInformationText';
        additionalInformationTextField.fieldType = '0'; //Text
        additionalInformationTextField.length = '2000';
        additionalInformationTextField.nullable = true;
        additionalInformationTextField.isPrimaryKey = false;
        fields.add(additionalInformationTextField);

        MERC_MarketingCloudClient.Field emailAddressField = new MERC_MarketingCloudClient.Field();
        emailAddressField.fieldName = 'EmailAddress';
        emailAddressField.fieldType = '4'; //EmailAddress
        emailAddressField.length = '200';
        emailAddressField.nullable = false;
        emailAddressField.isPrimaryKey = false;
        fields.add(emailAddressField);

        return fields;
    }

    private static List<Meeting_Participant_MERC__c> queryParticipants(List<Meeting_Participant_MERC__c> participants){
        return [SELECT Id,
                       Account_MERC__c,
                       Meeting_MERC__c
                  FROM Meeting_Participant_MERC__c
                 WHERE Id IN :participants];
    }

    private static Map<Id, Account> queryPersonAccounts(List<Meeting_Participant_MERC__c> meetingParticipants){
        Set<Id> personAccountIds = new Set<Id>();
        for (Meeting_Participant_MERC__c meetingParticipant : meetingParticipants) {
            personAccountIds.add(meetingParticipant.Account_MERC__c);
        }
        return new Map<Id, Account>([SELECT Id,
                                            PersonContactId,
                                            PersonEmail
                                       FROM Account
                                      WHERE Id IN :personAccountIds
                                        AND IsPersonAccount = true]);
    }

    private static MERC_MarketingCloudClient.DataExtension populateDataExtension(String emailSubject,
                                                                                 Id meetingId,
                                                                                 Datetime futureSendTime,
                                                                                 String sendTime,
                                                                                 List<MERC_MarketingCloudClient.Field> fields){
        DateTime now = DateTime.now();
        if(Test.isRunningTest()){
            now = DateTime.newInstanceGmt(1984, 1, 31, 7, 8, 16);
        }

        String dataExtensionSubject = emailSubject.length() > 140 ? emailSubject.substring(0, 139) : emailSubject;
        String dataExtensionName = 'SalesforceMeeting-' + meetingId + '-' + dataExtensionSubject.replaceAll('[^a-zA-Z0-9]+', '') + '-' + now.formatGmt('yyyyMMdd\'T\'HHmmssSSS');
        String dataExtensionDescription = 'Used for sending meeting from Salesforce.com';
        String dataExtensionKey = String.valueOf(meetingId) + now.formatGmt('yyyyMMdd\'T\'HHmmssSSS');

        //default expiration to 3 days for immediate sends, otherwise ensure DE will still be around when scheduled send actually goes out.
        Datetime dataExtensionExpiration = now.addDays(3);
        if (sendTime != 'now') {
            dataExtensionExpiration = futureSendTime.addDays(3);
        }
        MERC_MarketingCloudClient.DataExtension dataExtension = new MERC_MarketingCloudClient.DataExtension(
            dataExtensionName,
            dataExtensionDescription,
            dataExtensionKey,
            dataExtensionExpiration);
        dataExtension.sendableDataExtensionField = fields[0].fieldName;
        dataExtension.field.addAll(fields);

        return dataExtension;
    }

    private static String createDataExtension(MERC_MarketingCloudClient.DataExtension dataExtension){
        MERC_MarketingCloudClient.DataExtensionResponse dataExtensionResponse =
            MERC_MarketingCloudClient.createDataExtension(dataExtension);

        if (dataExtensionResponse.id == null) {
            throw new MarketingCloudServiceException('There was an error creating the data extension.');
        }

        return dataExtensionResponse.Id;
    }

    private static void createDataExtensionEntries(Id meetingId,
                                                   String additionalInformationHTML,
                                                   String additionalInformationText,
                                                   List<Meeting_Participant_MERC__c> meetingParticipants,
                                                   Map<Id, Account> personAccounts,
                                                   MERC_MarketingCloudClient.DataExtension dataExtension) {
        Integer participantIndex = 0;
        List<MERC_MarketingCloudClient.DataExtensionEntry> entries = new List<MERC_MarketingCloudClient.DataExtensionEntry>();
        meetingParticipants.sort();
        for (Meeting_Participant_MERC__c meetingParticipant : meetingParticipants) {
            // -> set data extension fields
            MERC_MarketingCloudClient.DataExtensionEntry entry = new MERC_MarketingCloudClient.DataExtensionEntry();
            entry.keys = new MERC_MarketingCloudClient.FieldEntry();
            entry.keys.fieldName = 'SubscriberKey';
            entry.keys.fieldValue = String.valueOf(personAccounts.get(meetingParticipant.Account_MERC__c).PersonContactId);

            entry.values = new List<MERC_MarketingCloudClient.FieldEntry>();

            MERC_MarketingCloudClient.FieldEntry accountId = new MERC_MarketingCloudClient.FieldEntry();
            accountId.fieldName = 'AccountId';
            accountId.fieldValue = meetingParticipant.Account_MERC__c;
            entry.values.add(accountId);

            MERC_MarketingCloudClient.FieldEntry meetingIdField = new MERC_MarketingCloudClient.FieldEntry();
            meetingIdField.fieldName = 'MeetingId';
            meetingIdField.fieldValue = meetingId;
            entry.values.add(meetingIdField);

            MERC_MarketingCloudClient.FieldEntry meetingParticipantId = new MERC_MarketingCloudClient.FieldEntry();
            meetingParticipantId.fieldName = 'MeetingParticipantId';
            meetingParticipantId.fieldValue = meetingParticipant.Id;
            entry.values.add(meetingParticipantId);

            MERC_MarketingCloudClient.FieldEntry additionalInfoFieldEntry = new MERC_MarketingCloudClient.FieldEntry();
            additionalInfoFieldEntry.fieldName = 'AdditionalInformationHTML';
            additionalInfoFieldEntry.fieldValue = additionalInformationHTML;
            entry.values.add(additionalInfoFieldEntry);

            MERC_MarketingCloudClient.FieldEntry additionalInfoTextFieldEntry = new MERC_MarketingCloudClient.FieldEntry();
            additionalInfoTextFieldEntry.fieldName = 'AdditionalInformationText';
            additionalInfoTextFieldEntry.fieldValue = additionalInformationText;
            entry.values.add(additionalInfoTextFieldEntry);

            MERC_MarketingCloudClient.FieldEntry emailAddress = new MERC_MarketingCloudClient.FieldEntry();
            emailAddress.fieldName = 'EmailAddress';
            emailAddress.fieldValue = personAccounts.get(meetingParticipant.Account_MERC__c).PersonEmail;
            entry.values.add(emailAddress);

            entries.add(entry);

            if(participantIndex >= 200){
                System.debug(LoggingLevel.DEBUG, 'createDataExtensionEntries breaking up meetingParticipants of size ' + meetingParticipants.size());
                MERC_MarketingCloudClient.createDataExtensionEntries(dataExtension, entries);
                entries.clear();
                participantIndex = 0;
            } else{
                participantIndex ++;
            }
        }

        if(participantIndex < 200){
            MERC_MarketingCloudClient.createDataExtensionEntries(dataExtension, entries);
        }
    }

    /* 
     *  Meeting Email Send attempts
     */
    @future(callout=true)
    public static void attemptMeetingEmailSendAsync(Id meetingEmailSendId){
        Meeting_Email_Send_MERC__c meetingEmailSend = queryMeetingEmailSend(meetingEmailSendId);
        attemptMeetingEmailSend(meetingEmailSend);
    }

    private static void attemptMeetingEmailSend(Meeting_Email_Send_MERC__c meetingEmailSend){
        meetingEmailSend.Retry_Count__c = 0;
        et4ae5__SendDefinition__c sendDefinition = null;
        MERC_MarketingCloudClient.SendClassification sendClassification = null;

        MERC_MarketingCloudClient.CreateSendDefinitionResponse createResponse = null;
        MERC_MarketingCloudClient.StartSendDefinitionResponse sendResponse = null;
        MERC_MarketingCloudClient.CheckSendDefinitionStatusResponse checkStatusResponse = null;

        if(meetingEmailSend.Email_Send_Number_MERC__c == null){
            sendDefinition = createSendDefinition(meetingEmailSend);
        } else {
            sendDefinition = querySendDefinition(meetingEmailSend.Email_Send_Number_MERC__c);
        }

        if (meetingEmailSend.Send_Status__c == null){
            meetingEmailSend.Send_Status__c = CreateSenderProfile;
        }

        if (meetingEmailSend.Send_Status__c == CreateSenderProfile) {
            try{
                if(String.isBlank(sendDefinition.et4ae5__SendClassificationId__c)){
                    sendClassification = getDefaultSendClassification();

                    meetingEmailSend.ET_Sender_Profile_Id_MERC__c = sendClassification.id;
                    sendDefinition.et4ae5__SendClassificationId__c = sendClassification.id;

                    System.debug('Set Sender Profile/Classification to: ' + sendClassification.id + ' from key ' + sendClassification.key);
                }
                // success creating the send profile
                meetingEmailSend.Retry_Count__c = 0;
                meetingEmailSend.Send_Status__c = CreateSendDefinition;
            }
            catch(Exception e){
                System.debug('There was an error querying the Send Classification : ' + e.getMessage() + '\n' + e.getStackTraceString());
                updateMeetingEmailSendForRetry(meetingEmailSend, LowMaxRetryCount);
                return;
            }
        }

        if (meetingEmailSend.Send_Status__c == CreateSendDefinition) {
            Datetime now = DateTime.now();

            if(Test.isRunningTest()){
                now = DateTime.newInstanceGmt(1984, 1, 31, 7, 8, 16);
            }

            String key = String.valueof(now.getTime());
            String name = 'LillySendDef' + now + meetingEmailSend.Meeting_MERC__c;
            MERC_MarketingCloudClient.SendDefinition sendDefinitionRequest = new MERC_MarketingCloudClient.SendDefinition(
                sendDefinition.et4ae5__DataExtensionId__c, 
                sendDefinition.et4ae5__DedupeSubscribers__c, 
                'Eli Lilly Send Definition Description', 
                Integer.valueOf(sendDefinition.et4ae5__EmailId__c), 
                key, 
                name, 
                sendDefinition.et4ae5__Subject__c, 
                sendDefinition.et4ae5__SendClassificationId__c,
                sendDefinition.et4ae5__SenderProfileId__c);

            try {
                createResponse = MERC_MarketingCloudClient.createSendDefinition(sendDefinitionRequest);
                
                // success creating the send definition
                meetingEmailSEnd.ET_Send_Definition_MERC__c = createResponse.id;
                sendDefinition.et4ae5__ETSendDef__c = createResponse.id;
                meetingEmailSend.Retry_Count__c = 0;
                meetingEmailSend.Send_Status__c = StartSendDefinition;
            } catch (Exception e) {
                System.debug('There was an error creating the Send Definition : ' + e.getMessage() + '\n' + e.getStackTraceString());
                updateMeetingEmailSendForRetry(meetingEmailSend, LowMaxRetryCount);
                return;
            }
        }

        if (meetingEmailSend.Send_Status__c == StartSendDefinition){
            try {
                sendResponse = MERC_MarketingCloudClient.startSendDefinition(sendDefinition.et4ae5__ETSendDef__c);
                
                // success starting the send definition
                meetingEmailSend.Retry_Count__c = 0;
                meetingEmailSend.Send_Status__c = CheckSendStatus;
            } catch (Exception e) {
                System.debug('There was an error starting the Send Definition : ' + e.getMessage() + '\n' + e.getStackTraceString());
                updateMeetingEmailSendForRetry(meetingEmailSend, LowMaxRetryCount);
                return;
            }
        }

        if (meetingEmailSend.Send_Status__c == CheckSendStatus){
            MERC_ETSendDefinition.CheckStatusResponse csr;
            try {
                checkStatusResponse = MERC_MarketingCloudClient.sendDefinitionStatus(sendDefinition.et4ae5__ETSendDef__c);
            } catch (Exception e) {
                System.debug ('There was an error retrieving the status of the send definition : ' + e.getMessage() + '\n' + e.getStackTraceString());
                updateMeetingEmailSendForRetry(meetingEmailSend, HighMaxRetryCount);
                return;
            }

            if (checkStatusResponse.sendStatus == StatusProcessing) {
                System.debug('Send definition still processing : ' + checkStatusResponse);
                
                if (meetingEmailSend.Email_Send_Number_MERC__c == null) {
                   sendDefinition.et4ae5__JobStarted__c =  true;
                   sendDefinition.et4ae5__JobId__c = checkStatusResponse.jobId;
                   insertSendDefinition(sendDefinition, meetingEmailSend);
                }
                updateMeetingEmailSendForRetry(meetingEmailSend, HighMaxRetryCount);
                return;
            } else if (checkStatusResponse.sendStatus == StatusCompleted) {
                sendDefinition.et4ae5__JobStatus__c =  'Complete';
                sendDefinition.et4ae5__JobId__c = checkStatusResponse.jobId;
                sendDefinition.et4ae5__JobStarted__c =  true;
                sendDefinition.et4ae5__SendStatus__c = StatusCompleted;
                if (meetingEmailSend.Email_Send_Number_MERC__c == null) {
                    insertSendDefinition(sendDefinition, meetingEmailSend);
                }
                else {
                    update sendDefinition;
                }
                
                meetingEmailSend.Send_Status__c = EmailSendCreated;
                upsert meetingEmailSend;
            }
        }
    }

    private static MERC_MarketingCloudClient.SendClassification getDefaultSendClassification(){
        MERC_MarketingCloudClient.SendClassification sendClassification = MERC_MarketingCloudClient.getClassification(MarketingCloudSettings.Default_Send_Classification_MERC__c);
        if(sendClassification == null){
            throw new MERC_ETNoSendClassificationException('No send classification, matching the custom setting, could be found!');
        }
        return sendClassification;
    }

    private static Meeting_Email_Send_MERC__c queryMeetingEmailSend(Id meetingEmailSendId){
        return [SELECT Id, 
                       Meeting_MERC__c,
                       Email_Send_Number_MERC__c,
                       Retry_Count__c,
                       Retry_Date__c,
                       Send_Email__c,
                       Send_Status__c,
                       ET_Data_Extension_Id_MERC__c,
                       ET_Sync_Id_MERC__c,
                       ET_Business_Unit_MERC__c,
                       ET_From_Name_MERC__c,
                       ET_Reply_to_MERC__c,
                       ET_From_Email_MERC__c,
                       ET_Recipients_Opted_In_MERC__c,
                       ET_Dedupe_Subscribers_MERC__c,
                       ET_Individual_Tracking_Disabled_MERC__c,
                       ET_Email_ID_MERC__c,
                       ET_Email_Name_MERC__c,
                       ET_Subject_MERC__c,
                       ET_Subject_Line_MERC__c,
                       Scheduled_Date__c,
                       ET_Thumbnail_MERC__c,
                       ET_Sender_Profile_Id_MERC__c,
                       ET_Send_Classification_Id_MERC__c,
                       ET_From_Address_MERC__c,
                       ET_Send_Definition_MERC__c
                  FROM Meeting_Email_Send_MERC__c
                 WHERE Id = :meetingEmailSendId];
    }

    private static et4ae5__SendDefinition__c createSendDefinition(Meeting_Email_Send_MERC__c meetingEmailSend) {
        et4ae5__SendDefinition__c sendDefinition = new et4ae5__SendDefinition__c(
            et4ae5__DataExtensionId__c = meetingEmailSend.ET_Data_Extension_Id_MERC__c,
            et4ae5__SyncId__c = meetingEmailSend.ET_Sync_Id_MERC__c,
            et4ae5__Business_Unit__c = meetingEmailSend.ET_Business_Unit_MERC__c,
            et4ae5__SyncComplete__c = true,
            et4ae5__Scheduled_Date_Time__c = meetingEmailSend.Scheduled_Date__c,
            et4ae5__TrackingOnly__c = true,
            et4ae5__FromName__c = meetingEmailSend.ET_From_Name_MERC__c,
            et4ae5__Reply_to__c = meetingEmailSend.ET_Reply_to_MERC__c,
            et4ae5__FromAddress__c = meetingEmailSend.ET_From_Address_MERC__c,
            et4ae5__FromEmail__c = meetingEmailSend.ET_From_Email_MERC__c,
            et4ae5__RecipientsOptedIn__c = meetingEmailSend.ET_Recipients_Opted_In_MERC__c,
            et4ae5__DedupeSubscribers__c = meetingEmailSend.ET_Dedupe_Subscribers_MERC__c,
            et4ae5__Individual_Tracking_Disabled__c = meetingEmailSend.ET_Individual_Tracking_Disabled_MERC__c,
            et4ae5__EmailId__c = meetingEmailSend.ET_Email_ID_MERC__c,
            et4ae5__EmailName__c = meetingEmailSend.ET_Email_Name_MERC__c,
            et4ae5__Subject__c = meetingEmailSend.ET_Subject_MERC__c,
            et4ae5__SubjectLine__c = meetingEmailSend.ET_Subject_Line_MERC__c,
            et4ae5__Thumbnail__c = meetingEmailSend.ET_Thumbnail_MERC__c,
            et4ae5__SenderProfileId__c = meetingEmailSend.ET_Sender_Profile_Id_MERC__c,
            et4ae5__SendClassificationId__c = meetingEmailSend.ET_Send_Classification_Id_MERC__c,
            et4ae5__ETSendDef__c = meetingEmailSend.ET_Send_Definition_MERC__c);
        
        return sendDefinition;
    }
    
    private static et4ae5__SendDefinition__c querySendDefinition(Id sendDefinitionId) {
        return [SELECT Id, 
                       et4ae5__DataExtensionId__c,
                       et4ae5__DedupeSubscribers__c,
                       et4ae5__EmailId__c,
                       et4ae5__Subject__c,
                       et4ae5__SendStatus__c,
                       et4ae5__TrackingOnly__c,
                       et4ae5__FromEmail__c,
                       et4ae5__FromName__c,
                       et4ae5__SendClassificationId__c,
                       et4ae5__SenderProfileId__c,
                       et4ae5__ETSendDef__c
                  FROM et4ae5__SendDefinition__c
                 WHERE Id = :sendDefinitionId];
    }

    public static void prepareMeetingEmailSendForRetry(Meeting_Email_Send_MERC__c meetingEmailSend,
                                                       Integer maxRetryCount){
        meetingEmailSend.Retry_Count__c += 1;
        meetingEmailSend.Send_Email__c = false;
        
        if (maxRetryCount <= meetingEmailSend.Retry_Count__c) {
            meetingEmailSend.Incomplete_MERC__c = true;
            meetingEmailSend.Retry_Date__c = null;
        }
        else {
            meetingEmailSend.Retry_Date__c = Datetime.now().addMinutes(1);
        }
    }

    private static void updateMeetingEmailSendForRetry(Meeting_Email_Send_MERC__c meetingEmailSend, Integer maxRetryCount){
        prepareMeetingEmailSendForRetry(meetingEmailSend, maxRetryCount);
        upsert meetingEmailSend;
    }

    private static void insertSendDefinition(et4ae5__SendDefinition__c sendDefinition, Meeting_Email_Send_MERC__c meetingEmailSend) {
        insert sendDefinition;
        
        meetingEmailSend.Email_Send_Number_MERC__c = sendDefinition.Id;
        
        // Disable this seciton for now. 
        // We cannot create an Attachment due to another future callout
        List<Attachment> meetingEmailSendAttachments = [Select Id, Body, Name, ParentId from Attachment where ParentId =:meetingEmailSend.Id];
        List<Attachment> emailSendAttachments = new List<Attachment>();
        
        for (Attachment meetingEmailSendAttachment : meetingEmailSendAttachments) {
            
            // Disable this trigger as it does a future call.
            //This trigger is not needed for ET Email Sends
            MERC_TriggerHandlerStateManager.deactivate(MERC_HandleDocusignAttachmentInsert.class);
            Attachment emailSendAttachment = new Attachment();
            emailSendAttachment.contentType = 'image/png';
            emailSendAttachment.ParentId = sendDefinition.Id;
            emailSendAttachment.Body = meetingEmailSendAttachment.Body;
            emailSendAttachment.Name = meetingEmailSendAttachment.Name;
            
            emailSendAttachments.add(emailSendAttachment);
        }
        
        insert emailSendAttachments;
    }

    /* updating subscribers */
    public static void updateSubscribersWithContacts(List<Id> personContactIds){
        Map<Id, Account> accountMap = new Map<Id, Account>();
        List<Account> accounts = [SELECT Id, 
                                          PersonEmail,
                                          Update_Subscriber_Error_ET_MERC__c,
                                          RecordTypeId,
                                          Cust_Id_GLBL__c,
                                          Prsnl_Nbr_GLBL__c,
                                          PersonContactId
                                     FROM Account 
                                    WHERE PersonContactId IN :personContactIds];
        for (Account account : accounts) {
            accountMap.put(account.PersonContactId, account);
        }
        
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id,
                                                                            DeveloperName 
                                                                       FROM RecordType]);

        List<MERC_MarketingCloudClient.Subscriber> subscribers = MERC_MarketingCloudClient.getSubscribers(personContactIds);

        if(subscribers == null || subscribers.size() == 0){
            return;
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (MERC_MarketingCloudClient.Subscriber subscriber : subscribers) {
            String subscriberKey = subscriber.SubscriberKey;

            Account tempAccount = accountMap.get(subscriberKey);
            
            // update retrieved data
            subscriber.EmailAddress = tempAccount.PersonEmail;
            
            if (recordTypeMap.get(tempAccount.RecordTypeId).DeveloperName == 'HCP_GLBL') {
                subscriber.LLYSubscriberKey = tempAccount.Cust_Id_GLBL__c;
                subscriber.SubscriberType = 'HCP';
            } else if (recordTypeMap.get(tempAccount.RecordTypeId).DeveloperName == 'Employee_GLBL') {
                subscriber.LLYSubscriberKey = tempAccount.Prsnl_Nbr_GLBL__c;
                subscriber.SubscriberType = 'Employee';
            } else if (recordTypeMap.get(tempAccount.RecordTypeId).DeveloperName == 'Designated_Individual_GLBL') {
                subscriber.LLYSubscriberKey = '-1';
                subscriber.SubscriberType = 'Business Contact';
            } else {
                subscriber.LLYSubscriberKey = '-1';
                subscriber.SubscriberType = 'Business Contact';
            }
            
            if (subscriber.LLYSubscriberKey == null || subscriber.LLYSubscriberKey == '') {
                subscriber.LLYSubscriberKey = '-1';
            }
            
            // update sub
            tempAccount.Update_Subscriber_Error_ET_MERC__c = MERC_MarketingCloudClient.updateSubscriber(subscriber);
            accountsToUpdate.add(tempAccount);
        }

        update accountsToUpdate;
    }

    public class MarketingCloudServiceException extends Exception {}
}