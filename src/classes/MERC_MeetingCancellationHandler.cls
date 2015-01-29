/**
 * @author Kyle Thornton
 *
 * Trigger handler that queries Mercury User Team Members of cancelled
 *  meetings and sends and email. Note that this trigger uses a work around
 *  to bypass a Salesforce.com limitation. Read the following for details:
 *  http://www.opfocus.com/blog/sending-emails-in-salesforce-to-non-contacts-using-apex/
 */

public with sharing class MERC_MeetingCancellationHandler implements GLBL_TriggerHandler.HandlerInterface {

    public Boolean isActive() 
    {
        return MERC_TriggerHandlerStateManager.isActive(MERC_MeetingCancellationHandler.class);
    }

    public void handle()
    {
        List<Meeting_MERC__c> cancelledMeetings = new List<Meeting_MERC__c>();
        for (Meeting_MERC__c meeting : (List<Meeting_MERC__c>) Trigger.new)
        {
            if (meeting.Send_Meeting_Team_Cancelled_Email_MERC__c == 'TRUE' &&
                (Trigger.isInsert || ((Meeting_MERC__c)Trigger.oldMap.get(meeting.id)).Send_Meeting_Team_Cancelled_Email_MERC__c != 'TRUE'))
            {
                cancelledMeetings.add( meeting );
            }
        }

        if (cancelledMeetings.isEmpty()) return;

        /* retrieve the Mercury_User_MERC record type Id for the Team Member object */
        Id mercUserRecordTypeId = [SELECT Id
                                     FROM RecordType
                                    WHERE SObjectType='Team_Member_MERC__c'
                                      AND DeveloperName='Mercury_User_MERC' limit 1].Id;

        /* requery each meeting retrieving only 'Mercury User' team members */
        cancelledMeetings = [SELECT Id
                                  , (SELECT User_MERC__r.Email
                                       FROM Team_Members__r
                                      WHERE RecordTypeId = :mercUserRecordTypeId)
                             FROM Meeting_MERC__c
                             WHERE Id IN :cancelledMeetings];

        /* the emails that we create will use the Cancelled_Meeting_MERC Email Template */
        Id templateId = [SELECT Id
                           FROM EmailTemplate
                          WHERE DeveloperName='Cancelled_Meeting_MERC' limit 1].Id;

        /* select a dummy contact. This is a workaround to a gap in salesforce functionality
           per: http://www.opfocus.com/blog/sending-emails-in-salesforce-to-non-contacts-using-apex/ */
        Contact dummyContact = [select Name, Email from Contact where email <> null AND FirstName <> null AND LastName <> null AND IsPersonAccount = true AND IsEmailBounced = false AND AccountId <> null LIMIT 1];

        List<Messaging.SingleEmailMessage> emailsToPopulateList = new List<Messaging.SingleEmailMessage>();
        for (Meeting_MERC__c meeting : cancelledMeetings)
        {
            /* create a list of email address for this meeting*/
            List<String> userEmailAddresses = new List<String>();
            for (Team_Member_MERC__c member : meeting.Team_Members__r)
            {
                userEmailAddresses.add( member.User_MERC__r.Email );
            }

            /* no need to create the email if there is nobody to send it to */
            if (userEmailAddresses.isEmpty()) continue;

            /* create the email using the dummy contact as the targetObjectId and load the
               userEmailAddresses into the toAddresses */
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(dummyContact.Id);
            mail.setTemplateID(templateId);
            mail.setSaveAsActivity(false);
            mail.setWhatId(meeting.Id);
            mail.setToAddresses(userEmailAddresses);

            emailsToPopulateList.add(mail);
        }

        /* as part of our work around we are going to create a savepoint, "send" the emails
           and then roll back. This will allow us to get the populated emails with merge fields
           etc. but not send the email to the dummy contact */
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(emailsToPopulateList);
        Database.rollback(sp);

        /* now we can loop through the emailsToPopulateList and create a new list of emails using the plainTextBody
           and htmlBody that has been populated with the correct merge fields. We can also prune off the
           toAddresses so we only send to those addresses */
        List<Messaging.SingleEmailMessage> emailsToSendList = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : emailsToPopulateList)
        {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());

            emailsToSendList.add(emailToSend);
        }

        /* according to this knowledge article
           http://help.salesforce.com/apex/HTViewSolution?id=000002490&language=en_US
           we cannot catch the exception thrown by reserveSingleEmailCapacity so no use trying */
        Messaging.reserveSingleEmailCapacity( emailsToSendList.size() );

        Messaging.sendEmail(emailsToSendList);
    }
}