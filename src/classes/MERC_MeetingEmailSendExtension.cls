/*
* Description : Allows a user to construct and attempt to send a MeetingEmailSend
* Authors: 
*   David Helmer (Refactored From Sonoma Partners MERC_ETMeetingEmailSendExtension)
*/
public with sharing class MERC_MeetingEmailSendExtension {
    private final Meeting_MERC__c meeting;

    public String selectedEmailId { get; set; }
    public String selectedEmailSubject { get; set; }
    public String selectedEmailName { get; set; }
    public MERC_MarketingCloudClient.FolderedEmail selectedEmail { get; private set; }

    public String fromEmailId { get; set; }

    public Boolean dedupeSubscribers { get; set; }
    public Boolean disableIndividualLevelTracking { get; set; }
    public String additionalInformationHTML { get; set; }
    public String additionalInformationText { get; set; }
    public Boolean participantsHaveOptedIn { get; set; }

    public String sendInFuture {
        get { return getSendInFuture(); }
        set { setSendInFuture(value); }
    }

    private List<MERC_MarketingCloudClient.EmailFolder> emailFolderTree;
    private Boolean showEmailChooser;
    private String emailFolderIdToExpand;

    private String selectedEmailThumbnail;

    private List<SelectOption> fromEmailOptions;

    private Set<Id> selectedParticipantIds;

    private Boolean isSendInFuture;
    private Event sendInFutureDate;

	public MERC_MeetingEmailSendExtension(ApexPages.StandardController standardController) {
        Id meetingId = getMeetingId(standardController);
        
        try {
            meeting = queryMeeting(meetingId);
        } catch(QueryException queryException){
            addFatalMessage('No meeting was found.');
        }

        if(selectedParticipantIds == null){
            selectedParticipantIds = new Set<Id>();
        }

        attemptGetEmailFolders();
        showEmailChooser = false;
        selectedEmail = new MERC_MarketingCloudClient.FolderedEmail();

        attemptGetFromEmailOptions();

        isSendInFuture = null;
	}

    private Id getMeetingId(ApexPages.StandardController standardController){
        if(standardController.getRecord() != null){
            return standardController.getRecord().Id;
        } else {
            return null;
        }
    }

    private Meeting_MERC__c queryMeeting(Id meetingId){
        return [SELECT OwnerId,
                       Id
                  FROM Meeting_MERC__c
                 WHERE Id = :meetingId
                 LIMIT 1];
    }

    private void attemptGetEmailFolders(){
        try{
            emailFolderTree = MERC_MarketingCloudService.getEmailFolders();
            checkIfEmailFolderTreeIsEmpty();
        } catch(Exception ex){
            System.Debug(ex);
            addFatalMessage('An exception occured while retrieving the emails:\n' + ex.getMessage());
        }
    }

    private void checkIfEmailFolderTreeIsEmpty(){
        if(emailFolderTree.isEmpty()){
            addWarningMessage('No emails were found. Please contact your Administrator.');
        }
    }

    public void attemptGetFromEmailOptions(){
        try{
            fromEmailOptions = MERC_MarketingCloudService.getSenderProfileSelectOptions();
            checkIfFromEmailOptionsIsEmpty();
        } catch(Exception ex){
            System.Debug(ex);
            addFatalMessage('An exception occured while retrieving From Email Options:\n' + ex.getMessage());
        }
    }

    private void checkIfFromEmailOptionsIsEmpty(){
        if(fromEmailOptions.isEmpty()){
            addWarningMessage('No From Emails were found. Please contact your Administrator.');
        }
    }

    public Boolean getShowEmailChooser(){
        return showEmailChooser;
    }

    public void openEmailChooser(){
        showEmailChooser = true;
    }

    public void closeEmailChooser(){
        showEmailChooser = false;
    }

    public List<MERC_MarketingCloudClient.EmailFolder> getEmailFolderTree(){
        return emailFolderTree;
    }

    public void setEmailFolderIdToExpand(String emailFolderId){
        emailFolderIdToExpand = emailFolderId;
    }

    public void expandEmailFolder(){
        attemptUpdateForFolder();
    }

    private void attemptUpdateForFolder(){
        try {
            MERC_MarketingCloudService.updateForFolder(emailFolderTree, emailFolderIdToExpand);
        } catch(Exception ex){
            addFatalMessage('An exception occured while expanding the folder:\n' + ex.getMessage());
        }
    }

    public void selectEmail(){
        selectedEmail = new MERC_MarketingCloudClient.FolderedEmail();
        selectedEmail.id = selectedEmailId;
        selectedEmail.name = selectedEmailName;
        selectedEmail.subject = selectedEmailSubject;

        selectedEmailThumbnail = attemptRequestThumbnail(selectedEmail.id);
    }

    private String attemptRequestThumbnail(String emailId){
        try {
            return MERC_MarketingCloudService.getThumbnail(emailId);
        } catch(Exception ex){
            addWarningMessage('An exception occured while retrieving the thumbnail:\n' + ex.getMessage());
        }
        return null;
    }

    public String getSelectedEmailThumbnail(){
        return selectedEmailThumbnail;
    }

    public List<SelectOption> getFromEmailOptions(){
        return fromEmailOptions;
    }

    public void setSelectedParticipantIds(Set<Id> participantIds){
        selectedParticipantIds = participantIds;
    }

    public Set<Id> getSelectedParticipantIds(){
        return selectedParticipantIds;
    }

    public Integer getSelectedParticipantCount(){
        return selectedParticipantIds.size();
    }

    public void setSendInFuture(String sendInFutureToParse){
        if(sendInFutureToParse.equalsIgnoreCase('now')){
            isSendInFuture = false;
        } else if(sendInFutureToParse.equalsIgnoreCase('future')) {
            isSendInFuture = true;
        } else {
            isSendInFuture = null;
            addWarningMessage(sendInFutureToParse + ' is not a valid value for sending in future');
        }
    }

    public String getSendInFuture(){
        if(isSendInFuture == null){
            return 'none';
        } else if(isSendInFuture) {
            return 'future';
        } else {
            return 'now';
        }
    }

    public Event getSendInFutureDate(){
        if(sendInFutureDate == null){
            sendInFutureDate = new Event();
        }
        return sendInFutureDate;
    }

    public void setSendInFutureDate(Event event){
        sendInFutureDate = event;
    }

    public PageReference send(){
        List<Meeting_Participant_MERC__c> selectedParticipants = queryParticipants(selectedParticipantIds);

        if(sendIsNotValid(selectedParticipants)){
            return null;
        }

        try {
            MERC_MarketingCloudService.prepareMeetingEmailSendForAttempts(meeting.Id,
                                                                          selectedEmail,
                                                                          selectedParticipants,
                                                                          dedupeSubscribers,
                                                                          disableIndividualLevelTracking,
                                                                          isSendInFuture ? 'future' : 'now',
                                                                          getSendInFutureDate().ActivityDateTime,
                                                                          additionalInformationHTML,
                                                                          additionalInformationText,
                                                                          fromEmailId,
                                                                          null);
            return new PageReference('/' + meeting.Id);
        }
        catch (Exception sendException) {
            System.debug(sendException);
            addFatalMessage('An exception occured while sending the email.');
            ApexPages.addMessages(sendException);
            return null;
        }
    }

    private List<Meeting_Participant_MERC__c> queryParticipants(Set<Id> participantIds){
        if(participantIds == null){
            return new List<Meeting_Participant_MERC__c>();
        }
        return [SELECT Id, Status_MERC__c, Docusign_Contract_Status_MERC__c,
                       Record_Type_MERC__c, Has_Signed_Contract_MERC__c,
                       Account_MERC__r.Name, Account_MERC__r.FirstName,
                       Account_MERC__r.PersonEmail,
                       Account_MERC__r.LastName,
                       Account_MERC__r.Communication_Channel_MERC__c,
                       Account_MERC__r.Title_Desc_GLBL__c,
                       Account_MERC__r.Sfx_Nm_GLBL__c,
                       Account_MERC__r.Prfrd_Lang_Cd_GLBL__c
                  FROM Meeting_Participant_MERC__c
                 WHERE Id in :participantIds];
    }

    private Boolean sendIsNotValid(List<Meeting_Participant_MERC__c> participants){
        if (participants.size() == 0) {
            AddErrorMessage('You must select at least 1 Recipient.');
        }

        if (isSendInFuture == null) {
            AddErrorMessage('You must select a send date and time.');
        } else if (isSendInFuture && isNullOrInPast(sendInFutureDate)) {
            AddErrorMessage('The send date must be in the future.');
        }

        if (selectedEmail.Id == null) {
            AddErrorMessage('You must select an email template.');
        } else if (selectedEmail.subject == null) {
            AddErrorMessage('The subject must be filled in.');
        }

        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }

    private Boolean isNullOrInPast(Event event){
        return event == null || isNullOrInPast(event.ActivityDateTime);
    }

    private Boolean isNullOrInPast(Datetime datetimeToCheck){
        return datetimeToCheck == null || datetimeToCheck <= Datetime.now();
    }

    public PageReference goToSelectParticipants() {
        PageReference selectParticipantsPage = Page.MeetingEmailSendSelectRecipients;
        selectParticipantsPage.getParameters().put('id', meeting.Id);
        return selectParticipantsPage;
    }

    public String getUrlRoot(){
        return MERC_MarketingCloudService.getUrlRoot();
    }

    public Boolean getHasFatalMessages(){
        return ApexPages.hasMessages(ApexPages.Severity.FATAL);
    }

    private void addMessage(ApexPages.Severity severity, String message){
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }

    private void addFatalMessage(String message){
        addMessage(ApexPages.Severity.FATAL, message);
    }

    private void addWarningMessage(String message){
        addMessage(ApexPages.Severity.WARNING, message);
    }

    private void addErrorMessage(String message){
        addMessage(ApexPages.Severity.ERROR, message);
    }
}