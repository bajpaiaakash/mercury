/*
* MERC_MeetingRegistrationReviewController
* Authors: David Helmer
*/
public with sharing class MERC_MeetingRegistrationReviewController {
	public MERC_ParticipantListDataObject participantsToReview { get; set; }

    private final String MISSING_MEETING_ID = 'Missing id parameter. Please pass a meeting record id in as the id parameter';
    private final String REGISTRATION_STATUS_FILTERS = '(\'Incomplete\',\'Pending Review\')';
    private final Integer PAGE_SIZE = 10;
    private final Set<Integer> PAGE_SIZE_SET = null;

    public MERC_MeetingRegistrationReviewController() {
		String meetingId = getMeetingIdFromParameters();

        if(String.isBlank(meetingId)){
            ApexPages.addMessage(buildErrorMessage(MISSING_MEETING_ID));
        }

        String participantWhereClause = 'Meeting_MERC__c = \'' + meetingId + '\' '
                                      + 'AND Registration_Status_MERC__c IN ' + REGISTRATION_STATUS_FILTERS;
        participantsToReview = new MERC_ParticipantListDataObject(participantWhereClause, PAGE_SIZE, PAGE_SIZE_SET);
	}

    private String getMeetingIdFromParameters(){
        return ApexPages.currentPage().getParameters().get('id');
    }

    private ApexPages.Message buildErrorMessage(String message){
        return new ApexPages.Message(ApexPages.Severity.ERROR, message);
    }

    public Boolean getHasErrors(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }
}