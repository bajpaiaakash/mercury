/*
*   MERC_MeetingEmailSendAttemptHandler
*   Created By:     David Helmer
*   Created Date:   December 3rd 2015
*   Description:    Handles attempts to send Meeting Email Sends to Marketing Cloud. Includes retry logic.
*/
public class MERC_MeetingEmailSendAttemptHandler implements GLBL_TriggerHandler.HandlerInterface {
    private final Integer MaxFutureCalls = 10;

    public Boolean isActive(){
        return MERC_TriggerHandlerStateManager.isActive(MERC_MeetingEmailSendAttemptHandler.class);
    }

    public void handle(){
        List<Meeting_Email_Send_MERC__c> newMeetingEmailSends = Trigger.new;
        Map<Id, Meeting_Email_Send_MERC__c> newMeetingEmailSendMap = (Map<Id, Meeting_Email_Send_MERC__c>)Trigger.newMap;
        List<Meeting_Email_Send_MERC__c> oldMeetingEmailSends = null;
        Integer maxAttempts = MaxFutureCalls;

        if(Trigger.isInsert && Trigger.isAfter){
            maxAttempts = 1;
        } else if(Trigger.isUpdate && Trigger.isBefore) {
            oldMeetingEmailSends = Trigger.old;
        } else {
            throw new MeetingEmailSendAttemptHandlerException('Expecting afterinsert or beforeupdate');
        }

        List<MeetingEmailSendWrapper> filteredMeetingEmailSends = filterSends(oldMeetingEmailSends, newMeetingEmailSends, newMeetingEmailSendMap);
        System.debug(LoggingLevel.FINE, 'filteredMeetingEmailSends: ' + filteredMeetingEmailSends);
        if (filteredMeetingEmailSends.size() <= maxAttempts) {
            attemptSends(filteredMeetingEmailSends, 0, filteredMeetingEmailSends.size());
        } else {
            filteredMeetingEmailSends.sort();
        
            attemptSends(filteredMeetingEmailSends, 0, maxAttempts);
            retrySends(filteredMeetingEmailSends, maxAttempts);
        }
    }

    @TestVisible
    private List<MeetingEmailSendWrapper> filterSends(List<Meeting_Email_Send_MERC__c> oldMeetingEmailSends,
                                                      List<Meeting_Email_Send_MERC__c> newMeetingEmailSends,
                                                      Map<Id, Meeting_Email_Send_MERC__c> newMeetingEmailSendMap) {
        List<MeetingEmailSendWrapper> meetingEmailSendWrappers = new List<MeetingEmailSendWrapper>();

        if (oldMeetingEmailSends == null) {
            for (Meeting_Email_Send_MERC__c meetingEmailSend : newMeetingEmailSends) {
                if (meetingEmailSend.Send_Email__c) {
                    meetingEmailSendWrappers.add(new MeetingEmailSendWrapper(meetingEmailSend));
                }
            }
        } else {
            for (Meeting_Email_Send_MERC__c oldMeetingEmailSend : oldMeetingEmailSends) {
                Meeting_Email_Send_MERC__c newMeetingEmailSend = newMeetingEmailSendMap.get(oldMeetingEmailSend.Id);
                if (oldMeetingEmailSend.Send_Email__c == false && newMeetingEmailSend.Send_Email__c == true) {
                    meetingEmailSendWrappers.add(new MeetingEmailSendWrapper(newMeetingEmailSend, oldMeetingEmailSend));
                }
            }
        }

        return meetingEmailSendWrappers;
    }

    private void attemptSends(List<MeetingEmailSendWrapper> meetingEmailSends, Integer startIndex, Integer maxIndex) {
        for (Integer index = startIndex; index < maxIndex; index++) {
            Meeting_Email_Send_MERC__c meetingEmailSend = meetingEmailSends[index].meetingEmailSend;
            MERC_MarketingCloudService.attemptMeetingEmailSendAsync(meetingEmailSend.Id);
        }
    }

    private void retrySends(List<MeetingEmailSendWrapper> meetingEmailSendsWrappers, Integer startIndex){
        List<Meeting_Email_Send_MERC__c> sendsToRetry = new List<Meeting_Email_Send_MERC__c>();
        List<Meeting_Email_Send_MERC__c> sendsToProcess = new List<Meeting_Email_Send_MERC__c>();
        
        for (Integer index = startIndex; index < meetingEmailSendsWrappers.size(); index++) {
            Meeting_Email_Send_MERC__c meetingEmailSend = meetingEmailSendsWrappers[index].meetingEmailSend;
            sendsToProcess.add(meetingEmailSend);
        }

        if(Trigger.isAfter){
            sendsToProcess = [SELECT Id, Retry_Count__c, Send_Email__c, Incomplete_MERC__c, Retry_Date__c FROM Meeting_Email_Send_MERC__c WHERE Id IN :sendsToProcess];
        }

        for (Meeting_Email_Send_MERC__c meetingEmailSend : sendsToProcess) {
            MERC_MarketingCloudService.prepareMeetingEmailSendForRetry(meetingEmailSend, MERC_MarketingCloudService.HighMaxRetryCount);
            sendsToRetry.add(meetingEmailSend);
        }

        if(Trigger.isAfter){
            update sendsToRetry;
        }
    }

    public class MeetingEmailSendAttemptHandlerException extends Exception {}

    private class MeetingEmailSendWrapper implements Comparable
    {
        public Meeting_Email_Send_MERC__c meetingEmailSend;
        public Meeting_Email_Send_MERC__c oldMeetingEmailSend;
        
        public MeetingEmailSendWrapper(Meeting_Email_Send_MERC__c emailSend) {
            meetingEmailSend = emailSend;
        }
        
        public MeetingEmailSendWrapper(Meeting_Email_Send_MERC__c emailSend, Meeting_Email_Send_MERC__c oldEmailSend) {
            meetingEmailSend = emailSend;
            oldMeetingEmailSend = oldEmailSend;
        }
        
        public Integer retrieveValueforSendStatus(string sendStatus){
            if (sendStatus == 'Check Send Status') {
                return 1;
            }
            else {
                return 0;
            }
        }
        
        public Integer compareTo(Object compareTo) {
            MeetingEmailSendWrapper compareToWrapper = (MeetingEmailSendWrapper)compareTo;
            Meeting_Email_Send_MERC__c compareToMeetingEmailSend = compareToWrapper.MeetingEmailSend;
            Meeting_Email_Send_MERC__c oldCompareToMeetingEmailSend = compareToWrapper.oldMeetingEmailSend;
            if(oldCompareToMeetingEmailSend == null || oldMeetingEmailSend == null){
                return 1;
            }

            Integer currentStatusValue = retrieveValueforSendStatus(meetingEmailSend.Send_Status__c);
            Integer compareToStatusValue = retrieveValueforSendStatus(compareToMeetingEmailSend.Send_Status__c);
            if (currentStatusValue > compareToStatusValue) {
                return 1;
            }
            else if (oldMeetingEmailSend.LastModifiedDate > oldCompareToMeetingEmailSend.LastModifiedDate) {
                return 1;
            }
            else if (oldMeetingEmailSend.LastModifiedDate < oldCompareToMeetingEmailSend.LastModifiedDate) {
                return -1;
            }
            
            return 0;
        }
    }
}