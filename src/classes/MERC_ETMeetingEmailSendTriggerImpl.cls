public without sharing class MERC_ETMeetingEmailSendTriggerImpl {
    public MERC_ETMeetingEmailSendTriggerImpl() {}
    private final integer maxFutureCalls = 10;
    
    public void doAfterInsert (Meeting_Email_Send_MERC__c[] newSends, Map<Id, Meeting_Email_Send_MERC__c> newSendsMap) {
        List<MeetingEmailSendWrapper> filteredSends = filterSends(null, newSends, newSendsMap);
        if (filteredSends.size() == 1) {
            MERC_ETMeetingEmailSendFutureProcessor.handleSendDefinitionProcessForMeetingEmailSend(filteredSends[0].meetingEmailSend.Id);
        }
        else if (filteredSends.size() > 1) {
            throw new MeetingEmailSendTriggerImplException('Only one Meeting Email Send can be sent at a time.');
        }
    }

    public void doBeforeUpdate (Meeting_Email_Send_MERC__c[] oldSends, Meeting_Email_Send_MERC__c[] newSends, Map<Id, Meeting_Email_Send_MERC__c> newSendsMap) {
        List<MeetingEmailSendWrapper> filteredSends = filterSends(oldSends, newSends, newSendsMap);
        if (filteredSends.size() < maxFutureCalls) {
            sendFirstTenEmailSends(filteredSends);
            return;
        }
        
        filteredSends.sort();
        
        sendFirstTenEmailSends(filteredSends);
        retryExtraEmailSends(filteredSends);
    }
    
    private void sendFirstTenEmailSends(List<MeetingEmailSendWrapper> meetingEmailSends) {
        for (integer x =0; x < maxFutureCalls && x < meetingEmailSends.size(); x++) {
            MERC_ETMeetingEmailSendFutureProcessor.handleSendDefinitionProcessForMeetingEmailSend(meetingEmailSends[x].meetingEmailSend.Id);
        }
    }
    
    private void retryExtraEmailSends(List<MeetingEmailSendWrapper> meetingEmailSends) {
        List<Meeting_Email_Send_MERC__c> sendsToRetry = new List<Meeting_Email_Send_MERC__c>();
        
        for (integer x = maxFutureCalls; x < meetingEmailSends.size(); x++) {
            Meeting_Email_Send_MERC__c meetingEmailSend = meetingEmailSends[x].meetingEmailSend;
            meetingEmailSend.Retry_Date__c = Datetime.now().addMinutes(1);
            meetingEmailSend.Send_Email__c = true;
            sendsToRetry.add(meetingEmailSend);
        }
    }

    @TestVisible
    private List<MeetingEmailSendWrapper> filterSends(Meeting_Email_Send_MERC__c[] oldSends, Meeting_Email_Send_MERC__c[] newSends, Map<Id, Meeting_Email_Send_MERC__c> newSendsMap) {
        List<MeetingEmailSendWrapper> retVal = new List<MeetingEmailSendWrapper>();

        if (oldSends == null) {
            for (Meeting_Email_Send_MERC__c mes : newSends) {
                if (mes.Send_Email__c) {
                    retVal.add(new MeetingEmailSendWrapper(mes));
                }
            }
        } else {
            for (Meeting_Email_Send_MERC__c oldMES : oldSends) {
                Meeting_Email_Send_MERC__c currMES = newSendsMap.get(oldMES.Id);
                if (oldMES.Send_Email__c == false && currMES.Send_Email__c == true) {
                    retVal.add(new MeetingEmailSendWrapper(currMES, oldMES));
                }
            }
        }

        return retVal;
    }
    
    public class MeetingEmailSendTriggerImplException extends Exception {}
    
    public class MeetingEmailSendWrapper implements Comparable
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
            
            integer currentStatusValue = retrieveValueforSendStatus(meetingEmailSend.Send_Status__c);
            integer compareToStatusValue = retrieveValueforSendStatus(compareToMeetingEmailSend.Send_Status__c);
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