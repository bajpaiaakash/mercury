public with sharing class MERC_MarketingCloudService {
    private static final Mercury_Marketing_Cloud_Settings_MERC__c MarketingCloudSettings;

    private static final String CreateSenderProfile = 'Create Sender Profile';
    private static final String CreateSendDefinition = 'Create Send Definition';
    private static final String StartSendDefinition = 'Start Send Definition';
    private static final String CheckSendStatus = 'Check Send Status';
    private static final String StatusProcessing = 'Processing';
    private static final String StatusCompleted = 'Completed';

    public static final Integer MaxFolderDepth = 6;

    static {
        MarketingCloudSettings = Mercury_Marketing_Cloud_Settings_MERC__c.getInstance();
    }

    public static List<MERC_MarketingCloudClient.EmailFolder> getEmailFolders(){
        return MERC_MarketingCloudClient.getEmailFolders();
    }

    public static List<MERC_MarketingCloudClient.EmailFolder> updateForFolder(List<MERC_MarketingCloudClient.EmailFolder> emailFolders, String folderId){
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

    @future(callout=true)
    public static void attemptMeetingEmailSend(Id meetingEmailSendId){
        Meeting_Email_Send_MERC__c meetingEmailSend = queryMeetingEmailSend(meetingEmailSendId);
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
                updateMeetingEmailSendForRetry(meetingEmailSend, 2);
                return;
            }
        }

        if (meetingEmailSend.Send_Status__c == CreateSendDefinition) {
            String key = String.valueof(datetime.now().getTime());
            String name = 'LillySendDef' + datetime.now() + meetingEmailSend.Meeting_MERC__c;
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
                updateMeetingEmailSendForRetry(meetingEmailSend, 2);
                return;
            }
        }

        if (meetingEmailSend.Send_Status__c == StartSendDefinition){
            try {
                sendResponse = MERC_MarketingCloudClient.getStartSendDefinition(sendDefinition.et4ae5__ETSendDef__c);
                
                // success starting the send definition
                meetingEmailSend.Retry_Count__c = 0;
                meetingEmailSend.Send_Status__c = CheckSendStatus;
            } catch (Exception e) {
                System.debug('There was an error starting the Send Definition : ' + e.getMessage() + '\n' + e.getStackTraceString());
                updateMeetingEmailSendForRetry(meetingEmailSend,2);
                return;
            }
        }

        if (meetingEmailSend.Send_Status__c == CheckSendStatus){
            MERC_ETSendDefinition.CheckStatusResponse csr;
            try {
                checkStatusResponse = MERC_MarketingCloudClient.getSendDefinitionStatus(sendDefinition.et4ae5__ETSendDef__c);
            } catch (Exception e) {
                System.debug ('There was an error retrieving the status of the send definition : ' + e.getMessage() + '\n' + e.getStackTraceString());
                updateMeetingEmailSendForRetry(meetingEmailSend, 299);
                return;
            }

            if (checkStatusResponse.sendStatus == StatusProcessing) {
                System.debug('Send definition still processing : ' + checkStatusResponse);
                
                if (meetingEmailSend.Email_Send_Number_MERC__c == null) {
                   sendDefinition.et4ae5__JobStarted__c =  true;
                   sendDefinition.et4ae5__JobId__c = checkStatusResponse.jobId;
                   insertSendDefinition(sendDefinition, meetingEmailSend);
                }
                updateMeetingEmailSendForRetry(meetingEmailSend, 299);
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
                
                meetingEmailSend.Send_Status__c = 'Email Send Created';
                update meetingEmailSend;
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
                 WHERE Id =:sendDefinitionId];
    }

    private static void updateMeetingEmailSendForRetry(Meeting_Email_Send_MERC__c meetingEmailSend, Integer maxRetryCount){
        meetingEmailSend.Retry_Count__c += 1;
        meetingEmailSend.Send_Email__c = false;
        
        if (maxRetryCount <= meetingEmailSend.Retry_Count__c) {
            meetingEmailSend.Incomplete_MERC__c = true;
            meetingEmailSend.Retry_Date__c = null;
        }
        else {
            meetingEmailSend.Retry_Date__c = Datetime.now().addMinutes(1);
        }
        update meetingEmailSend;
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
}