public without sharing class MeetingEmailSendTriggerImpl {
    public MeetingEmailSendTriggerImpl() {}

    public void doAfterInsert (Meeting_Email_Send_MERC__c[] newSends, Map<Id, Meeting_Email_Send_MERC__c> newSendsMap) {
        List<Meeting_Email_Send_MERC__c> filteredSends = filterSends(null, newSends, newSendsMap);
        if (filteredSends.size() > 0) {
            MeetingEmailSendFutureProcessor.handleSendDefinitionProcessForMeetingEmailSend(filteredSends[0].Id);
        }
    }

    public void doAfterUpdate (Meeting_Email_Send_MERC__c[] oldSends, Meeting_Email_Send_MERC__c[] newSends, Map<Id, Meeting_Email_Send_MERC__c> newSendsMap) {
        List<Meeting_Email_Send_MERC__c> filteredSends = filterSends(oldSends, newSends, newSendsMap);
        if (filteredSends.size() > 0) {
            MeetingEmailSendFutureProcessor.handleSendDefinitionProcessForMeetingEmailSend(filteredSends[0].Id);
        }
    }

    @TestVisible
    private List<Meeting_Email_Send_MERC__c> filterSends(Meeting_Email_Send_MERC__c[] oldSends, Meeting_Email_Send_MERC__c[] newSends, Map<Id, Meeting_Email_Send_MERC__c> newSendsMap) {
        List<Meeting_Email_Send_MERC__c> retVal = new List<Meeting_Email_Send_MERC__c>();

        if (oldSends == null) {
            for (Meeting_Email_Send_MERC__c mes : newSends) {
                if (mes.Send_Email__c) {
                    retVal.add(mes);
                }
            }
        } else {
            for (Meeting_Email_Send_MERC__c oldMES : oldSends) {
                Meeting_Email_Send_MERC__c currMES = newSendsMap.get(oldMES.Id);
                if (oldMES.Send_Email__c == false && currMES.Send_Email__c == true) {
                    retVal.add(currMES);
                }
            }
        }

        return retVal;
    }
}