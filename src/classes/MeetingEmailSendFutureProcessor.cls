public without sharing class MeetingEmailSendFutureProcessor {
    @future (callout=true)
    public static void handleSendDefinitionProcessForMeetingEmailSend(Id meetingEmailSendId) {
        Meeting_Email_Send_MERC__c meetingEmailSend = [SELECT Id, Email_Send_Number_MERC__c, Retry_Count__c, Retry_Date__c, Send_Email__c, Send_Status__c
                                                       FROM Meeting_Email_Send_MERC__c
                                                       WHERE Id = :meetingEmailSendId];
        et4ae5__SendDefinition__c sendDefinition = [SELECT Id, et4ae5__DataExtensionId__c, et4ae5__DedupeSubscribers__c, et4ae5__EmailId__c, et4ae5__Subject__c, et4ae5__SendStatus__c, et4ae5__TrackingOnly__c
                                                    FROM et4ae5__SendDefinition__c
                                                    WHERE Id = :meetingEmailSend.Email_Send_Number_MERC__c];

        ETAuthorizer authorizer = new ETAuthorizer();
        ETSendDefinitionProcessor processor = new ETSendDefinitionProcessor();

        String key = String.valueof(datetime.now().getTime());
        ETSendDefinition newSendDef = new ETSendDefinition(sendDefinition.et4ae5__DataExtensionId__c, sendDefinition.et4ae5__DedupeSubscribers__c, 'Eli Lilly Send Definition Description', Integer.valueOf(sendDefinition.et4ae5__EmailId__c), key, key, sendDefinition.et4ae5__Subject__c);

        ETSendDefinition.CreateResponse cr;
        try {
            cr = processor.create(newSendDef, authorizer.soapAuthToken);
        } catch (Exception e) {
            System.debug('There was an error creating the Send Definition : ' + e.getMessage() + '\n' + e.getStackTraceString());

            meetingEmailSend.Send_Status__c = 'Create Send Definition';
            meetingEmailSend.Send_Email__c = false;
            meetingEmailSend.Retry_Date__c = Datetime.now().addMinutes(1);
            meetingEmailSend.Retry_Count__c += 1;
            update meetingEmailSend;

            return;
        }

        // success creating the send definition
        meetingEmailSend.Retry_Count__c = 0;

        ETSendDefinition.StartResponse sr;
        try {
            sr = processor.start(cr.id, authorizer.soapAuthToken);
        } catch (Exception e) {
            System.debug('There was an error starting the Send Definition : ' + e.getMessage() + '\n' + e.getStackTraceString());

            meetingEmailSend.Send_Status__c = 'Start Send Definition';
            meetingEmailSend.Send_Email__c = false;
            meetingEmailSend.Retry_Date__c = Datetime.now().addMinutes(1);
            meetingEmailSend.Retry_Count__c += 1;
            update meetingEmailSend;

            return;
        }

        // success starting the send definition
        meetingEmailSend.Retry_Count__c = 0;

        ETSendDefinition.CheckStatusResponse csr;
        try {
            csr = processor.checkStatus(cr.id, authorizer.soapAuthToken);
        } catch (Exception e) {
            System.debug ('There was an error retrieving the status of the send definition : ' + e.getMessage() + '\n' + e.getStackTraceString());

            meetingEmailSend.Send_Status__c = 'Check Send Definition';
            meetingEmailSend.Send_Email__c = false;
            meetingEmailSend.Retry_Date__c = Datetime.now().addMinutes(1);
            meetingEmailSend.Retry_Count__c += 1;
            update meetingEmailSend;

            return;
        }
        System.debug('csr : ' + csr);

        // the send status was retrieved successfully
        if (csr.sendStatus == 'Processing') {
            System.debug('Send definition still processing : ' + csr);

            meetingEmailSend.Send_Status__c = 'Check Send Definition';
            meetingEmailSend.Send_Email__c = false;
            meetingEmailSend.Retry_Date__c = Datetime.now().addMinutes(1);
            meetingEmailSend.Retry_Count__c += 1;
            update meetingEmailSend;

            return;
        } else if (csr.sendStatus == 'Completed') {
            sendDefinition.et4ae5__SendStatus__c = 'Completed';
            sendDefinition.et4ae5__TrackingOnly__c = true;
            update sendDefinition;
        }
    }
}