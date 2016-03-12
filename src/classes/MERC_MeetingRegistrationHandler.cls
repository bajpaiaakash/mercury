/*
*   MERC_MeetingRegistrationHandler
*   Authors: David Helmer
*/
public class MERC_MeetingRegistrationHandler implements GLBL_TriggerHandler.HandlerInterface {
    public Boolean isActive(){
        return MERC_TriggerHandlerStateManager.isActive(MERC_MeetingRegistrationHandler.class);
    }

    public void handle(){
        List<Id> meetingParticipantIds = getParticipantIdsWhereStatusChangedToAccepted();
        sendMeetingRegistrationConfirmationsTo(meetingParticipantIds);
    }

    @future(callout=true)
    private static void sendMeetingRegistrationConfirmationsTo(List<Id> meetingParticipantIds){
        List<Meeting_Participant_MERC__c> participants = [SELECT Id,
                                                                 Account_MERC__r.Country_of_Residence_GLBL__c,
                                                                 Meeting_MERC__c
                                                            FROM Meeting_Participant_MERC__c
                                                           WHERE Id IN :meetingParticipantIds];
        MERC_MarketingCloudService.sendMeetingRegistrationConfirmations(participants);
    }

    private List<Id> getParticipantIdsWhereStatusChangedToAccepted(){
        Map<Id, Meeting_Participant_MERC__c> oldParticipantsMap = (Map<Id, Meeting_Participant_MERC__c>)Trigger.oldMap;
        Map<Id, Meeting_Participant_MERC__c> newParticipantsMap = (Map<Id, Meeting_Participant_MERC__c>)Trigger.newMap;
        List<Id> participantIds = new List<Id>();

        for(Id participantId : newParticipantsMap.keySet()){
            Meeting_Participant_MERC__c oldParticipant = oldParticipantsMap.get(participantId);
            Meeting_Participant_MERC__c newParticipant = newParticipantsMap.get(participantId);

            if(isParticipantStatusChangedToAccepted(oldParticipant, newParticipant)){
                participantIds.add(newParticipant.Id);
            } else {
                System.debug(LoggingLevel.FINE, 'isParticipantStatusChangedToAccepted returned false for\n' + oldParticipant + '\n' + newParticipant);
            }
        }
        System.debug('getParticipantIdsWhereStatusChangedToAccepted: ' + participantIds);
        return participantIds;
    }

    private Boolean isParticipantStatusChangedToAccepted(Meeting_Participant_MERC__c oldParticipant, Meeting_Participant_MERC__c newParticipant){
        return newParticipant.WS_Updt_Dt_MERC__c != null
            && newParticipant.WS_Updt_Dt_MERC__c == Date.today()
            && newParticipant.Status_MERC__c != oldParticipant.Status_MERC__c
            && newParticipant.Status_MERC__c == 'Accepted';
    }
}