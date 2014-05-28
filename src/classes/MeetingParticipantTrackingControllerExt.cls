public with sharing class MeetingParticipantTrackingControllerExt {

    private Meeting_Participant_MERC__c meetingParticipant;
    public List<et4ae5__IndividualEmailResult__c> individualEmailResults {get; private set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public MeetingParticipantTrackingControllerExt(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(new List<String>{'Account_MERC__c', 'Meeting_Merc__c', 'Account_MERC__r.PersonContactId'});
        }
        this.meetingParticipant = (Meeting_Participant_MERC__c)stdController.getRecord();
        RetrieveIndividualEmailResults();
    }

    private void RetrieveIndividualEmailResults(){
        try{
            List<Meeting_Email_Send_MERC__c> meetingEmailSends = 
                [SELECT Email_Send_Number_MERC__c
                FROM Meeting_Email_Send_MERC__c 
                WHERE Meeting_MERC__c =: meetingParticipant.Meeting_Merc__c AND
                    Id in (SELECT Meeting_Email_Send__c FROM Meeting_Participant_Email_Send_MERC__c WHERE Meeting_Participant__c =: meetingParticipant.Id)];

            Set<Id> meetingEmailSendIds = new Set<Id>();

            for(Meeting_Email_Send_MERC__c meetingEmailSend: meetingEmailSends){
                meetingEmailSendIds.add(meetingEmailSend.Email_Send_Number_MERC__c);
            }

            individualEmailResults =
                [SELECT Id, name, et4ae5__DateSent__c, et4ae5__Opened__c, et4ae5__DateOpened__c, et4ae5__Clicked__c, 
                    et4ae5__HardBounce__c, et4ae5__SoftBounce__c, et4ae5__DateUnsubscribed__c
                FROM et4ae5__IndividualEmailResult__c
                WHERE et4ae5__Contact__c =:meetingParticipant.Account_MERC__r.PersonContactId AND 
                    et4ae5__SendDefinition__c in: meetingEmailSendIds
                ORDER BY et4ae5__DateSent__c DESC];
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
        }
    }

    public boolean getHasErrors() {
        return ApexPages.hasMessages();
    }
}