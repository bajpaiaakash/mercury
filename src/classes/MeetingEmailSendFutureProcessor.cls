public without sharing class MeetingEmailSendFutureProcessor {
    @future (callout=true)
    public static void handleSendDefinitionProcessForMeetingEmailSend(Id meetingEmailSendId) {
        Meeting_Email_Send_MERC__c meetingEmailSend = [SELECT Id, Email_Send_Number_MERC__c, Retry_Count__c, Retry_Date__c, Send_Email__c, Send_Status__c, ET_Data_Extension_Id_MERC__c, ET_Sync_Id_MERC__c, ET_Business_Unit_MERC__c, ET_From_Name_MERC__c, ET_Reply_to_MERC__c, ET_From_Email_MERC__c, ET_Recipients_Opted_In_MERC__c, ET_Dedupe_Subscribers_MERC__c, ET_Individual_Tracking_Disabled_MERC__c, ET_Email_ID_MERC__c, ET_Email_Name_MERC__c, ET_Subject_MERC__c, ET_Subject_Line_MERC__c, Scheduled_Date__c, ET_Thumbnail_MERC__c, ET_Sender_Profile_Id_MERC__c, ET_From_Address_MERC__c, ET_Send_Definition_MERC__c
                                                       FROM Meeting_Email_Send_MERC__c
                                                       WHERE Id = :meetingEmailSendId];
        et4ae5__SendDefinition__c sendDefinition = meetingEmailSend.Email_Send_Number_MERC__c == null
                                                   ? setupTrackingOnlyEmailSend(meetingEmailSend)
                                                   : retrieveEmailSend(meetingEmailSend.Email_Send_Number_MERC__c);

        ETAuthorizer authorizer = new ETAuthorizer();
        ETSendDefinitionProcessor processor = new ETSendDefinitionProcessor();

        if (meetingEmailSend.Send_Status__c == null){
        	meetingEmailSend.Send_Status__c = 'Create Sender Profile';
        }
        
        ETSendDefinition.SenderProfileCreate sendProfCreate;        
        ETSendDefinition.CreateSenderProfileResponse cpr;
        if (meetingEmailSend.Send_Status__c == 'Create Sender Profile') {
	        try{
	        	sendProfCreate = new ETSendDefinition.SenderProfileCreate(sendDefinition.et4ae5__FromName__c, sendDefinition.et4ae5__FromEmail__c);
	            cpr = processor.createSenderProfile(sendProfCreate, authorizer.soapAuthToken);
	            meetingEmailSend.ET_Sender_Profile_Id_MERC__c = cpr.id;
	            sendDefinition.et4ae5__SenderProfileId__c = cpr.id;
	            
	            // success creating the send profile
                meetingEmailSend.Retry_Count__c = 0;
	            meetingEmailSend.Send_Status__c = 'Create Send Definition';
	        }
	        catch(Exception e){
	        	System.debug('There was an error creating the Sender Profile : ' + e.getMessage() + '\n' + e.getStackTraceString());
	        	setMeetingEmailSendForRetry(meetingEmailSend, 2);
	            return;
	        }
        }
        
        ETSendDefinition.CreateResponse cr;
        if (meetingEmailSend.Send_Status__c == 'Create Send Definition') {
	        String key = String.valueof(datetime.now().getTime());
	        ETSendDefinition newSendDef = new ETSendDefinition(sendDefinition.et4ae5__DataExtensionId__c, sendDefinition.et4ae5__DedupeSubscribers__c, 'Eli Lilly Send Definition Description', Integer.valueOf(sendDefinition.et4ae5__EmailId__c), key, key, sendDefinition.et4ae5__Subject__c, sendDefinition.et4ae5__SenderProfileId__c);

	        try {
	        	
	            cr = processor.create(newSendDef, authorizer.soapAuthToken);
	            
	            // success creating the send definition
	            meetingEmailSEnd.ET_Send_Definition_MERC__c = cr.id;
	            sendDefinition.et4ae5__ETSendDef__c = cr.id;
                meetingEmailSend.Retry_Count__c = 0;
                meetingEmailSend.Send_Status__c = 'Start Send Definition';
	        } catch (Exception e) {
	            System.debug('There was an error creating the Send Definition : ' + e.getMessage() + '\n' + e.getStackTraceString());
	            setMeetingEmailSendForRetry(meetingEmailSend, 2);
	            
	            //Update the Send Definition to verify SenderProfileId was set
	            update sendDefinition;
	            return;
	        }
        }

        ETSendDefinition.StartResponse sr;
        if (meetingEmailSend.Send_Status__c == 'Start Send Definition'){
	        try {
	            sr = processor.start(sendDefinition.et4ae5__ETSendDef__c, authorizer.soapAuthToken);
	            
	            // success starting the send definition
                meetingEmailSend.Retry_Count__c = 0;
	            meetingEmailSend.Send_Status__c = 'Check Send Status';
	        } catch (Exception e) {
	            System.debug('There was an error starting the Send Definition : ' + e.getMessage() + '\n' + e.getStackTraceString());
	            setMeetingEmailSendForRetry(meetingEmailSend,2);
	            return;
	        }
        }

        
        if (meetingEmailSend.Send_Status__c == 'Check Send Status'){
	        ETSendDefinition.CheckStatusResponse csr;
	        try {
	            csr = processor.checkStatus(sendDefinition.et4ae5__ETSendDef__c, authorizer.soapAuthToken);
	        } catch (Exception e) {
	            System.debug ('There was an error retrieving the status of the send definition : ' + e.getMessage() + '\n' + e.getStackTraceString());
	            setMeetingEmailSendForRetry(meetingEmailSend, 299);
	            return;
	        }
	        System.debug('csr : ' + csr);
	
	        // the send status was retrieved successfully
	        if (csr.sendStatus == 'Processing') {
	            System.debug('Send definition still processing : ' + csr);
	            
	            if (meetingEmailSend.Email_Send_Number_MERC__c == null) {
	               sendDefinition.et4ae5__JobStarted__c =  true;
	               sendDefinition.et4ae5__JobId__c = csr.jobId;
	               createSend(sendDefinition, meetingEmailSend);
	            }
	            setMeetingEmailSendForRetry(meetingEmailSend, 299);
	            return;
	        } else if (csr.sendStatus == 'Completed') {
	        	sendDefinition.et4ae5__JobStatus__c =  'Complete';
	        	sendDefinition.et4ae5__JobId__c = csr.jobId;
	        	sendDefinition.et4ae5__JobStarted__c =  true;
	        	sendDefinition.et4ae5__SendStatus__c = 'Completed';
	            if (meetingEmailSend.Email_Send_Number_MERC__c == null) {
	            	createSend(sendDefinition, meetingEmailSend);
	            }
	            else {
	            	update sendDefinition;
	            }
	            
	            meetingEmailSend.Send_Status__c = 'Email Send Created';
	            update meetingEmailSend;
	        }
        }
    }
    
    private static et4ae5__SendDefinition__c setupTrackingOnlyEmailSend(Meeting_Email_Send_MERC__c meetingEmailSend) {
    	et4ae5__SendDefinition__c send = new et4ae5__SendDefinition__c();
        send.et4ae5__DataExtensionId__c = meetingEmailSend.ET_Data_Extension_Id_MERC__c;
        send.et4ae5__SyncId__c = meetingEmailSend.ET_Sync_Id_MERC__c;
        send.et4ae5__Business_Unit__c = meetingEmailSend.ET_Business_Unit_MERC__c;
        send.et4ae5__SyncComplete__c = true;
        send.et4ae5__Scheduled_Date_Time__c = meetingEmailSend.Scheduled_Date__c;
        send.et4ae5__TrackingOnly__c = true;
        send.et4ae5__FromName__c = meetingEmailSend.ET_From_Name_MERC__c;
        send.et4ae5__Reply_to__c = meetingEmailSend.ET_Reply_to_MERC__c;
        send.et4ae5__FromAddress__c = meetingEmailSend.ET_From_Address_MERC__c;
        send.et4ae5__FromEmail__c = meetingEmailSend.ET_From_Email_MERC__c;
        send.et4ae5__RecipientsOptedIn__c = meetingEmailSend.ET_Recipients_Opted_In_MERC__c;
        send.et4ae5__DedupeSubscribers__c = meetingEmailSend.ET_Dedupe_Subscribers_MERC__c;
        send.et4ae5__Individual_Tracking_Disabled__c = meetingEmailSend.ET_Individual_Tracking_Disabled_MERC__c;
        send.et4ae5__EmailId__c = meetingEmailSend.ET_Email_ID_MERC__c;
        send.et4ae5__EmailName__c = meetingEmailSend.ET_Email_Name_MERC__c;
        send.et4ae5__Subject__c = meetingEmailSend.ET_Subject_MERC__c;
        send.et4ae5__SubjectLine__c = meetingEmailSend.ET_Subject_Line_MERC__c;
        send.et4ae5__Thumbnail__c = meetingEmailSend.ET_Thumbnail_MERC__c;
        send.et4ae5__SenderProfileId__c = meetingEmailSend.ET_Sender_Profile_Id_MERC__c;
        send.et4ae5__ETSendDef__c = meetingEmailSend.ET_Send_Definition_MERC__c;
        
        return send;
    }
    
    private static void createSend(et4ae5__SendDefinition__c sendDefinition, Meeting_Email_Send_MERC__c meetingEmailSend) {
    	insert sendDefinition;
    	
    	meetingEmailSend.Email_Send_Number_MERC__c = sendDefinition.Id;

    	List<Attachment> meetingEmailSendAttachments = [Select Id, Body, Name, ParentId from Attachment where ParentId =: meetingEmailSend.Id];
    	List<Attachment> emailSendAttachments = new List<Attachment>();
    	
    	for (Attachment meetingEmailSendAttachment : meetingEmailSendAttachments) {
    		Attachment emailSendAttachment = new Attachment();
    		emailSendAttachment.ParentId = sendDefinition.Id;
    		emailSendAttachment.Body = meetingEmailSendAttachment.Body;
    		emailSendAttachment.Name = meetingEmailSendAttachment.Name;
    		
    		emailSendAttachments.add(emailSendAttachment);
    	}
    	
    	insert emailSendAttachments;
    }
    
    private static et4ae5__SendDefinition__c retrieveEmailSend(Id emailSendId) {
    	return [SELECT Id, et4ae5__DataExtensionId__c, et4ae5__DedupeSubscribers__c, et4ae5__EmailId__c, et4ae5__Subject__c, et4ae5__SendStatus__c, et4ae5__TrackingOnly__c, et4ae5__FromEmail__c, et4ae5__FromName__c, et4ae5__SenderProfileId__c, et4ae5__ETSendDef__c
                FROM et4ae5__SendDefinition__c
                WHERE Id =: emailSendId];
    }

    private static void setMeetingEmailSendForRetry(Meeting_Email_Send_MERC__c meetingEmailSend, Integer maxRetryCount) {
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
}