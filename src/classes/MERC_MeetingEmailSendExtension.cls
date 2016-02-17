/*
* Description : Allows a user to construct and attempt to send a MeetingEmailSend
* Authors: 
*   David Helmer (Refactored From Sonoma Partners MERC_ETMeetingEmailSendExtension)
*/
public with sharing class MERC_MeetingEmailSendExtension {
    private final Meeting_MERC__c meeting;

    private List<MERC_MarketingCloudClient.EmailFolder> emailFolderTree;
    private Boolean showEmailChooser;
    private String emailFolderIdToExpand;

	public MERC_MeetingEmailSendExtension(ApexPages.StandardController standardController) {
        Id meetingId = getMeetingId(standardController);
        
        try {
            meeting = queryMeeting(meetingId);
        } catch(QueryException queryException){
            addFatalMessage('No meeting was found.');
        }

        emailFolderTree = null;
        showEmailChooser = false;
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

    public Boolean getHasFatalMessages(){
        return ApexPages.hasMessages(ApexPages.Severity.FATAL);
    }

    public Boolean getShowEmailChooser(){
        return showEmailChooser;
    }

    public void openEmailChooser(){
        if(emailFolderTree == null){
            attemptGetEmailFolders();
        }
        showEmailChooser = true;
    }

    private void attemptGetEmailFolders(){
        try{
            emailFolderTree = MERC_MarketingCloudService.getEmailFolders();
            checkIfEmailFolderTreeIsEmpty();
        } catch(Exception ex){
            addFatalMessage('An exception occured while retrieving the emails:\n' + ex.getMessage());
        }
    }

    private void checkIfEmailFolderTreeIsEmpty(){
        if(emailFolderTree.isEmpty()){
            addWarningMessage('No emails were found.');
        }
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

    private void addMessage(ApexPages.Severity severity, String message){
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }

    private void addFatalMessage(String message){
        addMessage(ApexPages.Severity.FATAL, message);
    }

    private void addWarningMessage(String message){
        addMessage(ApexPages.Severity.WARNING, message);
    }
}