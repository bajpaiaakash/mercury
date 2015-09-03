/*
    MERC_AccountRollups
    @author : Kyle Thornton, Mavens Consulting
    @created : 13 Jul 2015
    @description : This class will take a list of Accounts and calculate rollups for "Cap"
                   spending values from Meeting participants and a count of Preferences and
                   Consent records.
                   This class implements the Queueable interface which allows other queueable
                   jobs to be called. It will call the GLBL_AccountToAccountRollups class
                   passing in the parent accounts for each of the meeting participants.
    @modified by :
    @modified date :

*/
public class MERC_AccountRollups implements Queueable{
    Set<Id> accountIds;

    public MERC_AccountRollups(Set<Id> theAccountIds) {
        accountIds = theAccountIds;
    }

    public void execute(QueueableContext context) {
        List<Account> accounts;
        Integer MAX_ATTEMPTS = 3;

        Integer attempts = MAX_ATTEMPTS;
        //query for accounts, may need to retry attempt if records are locked by another asynchronous process
        while (attempts > 0) {
            try {
                attempts--;
                accounts = [SELECT Id,
                                   Allocated_CAP_MERC__c,
                                   Speaking_Paid_CAP_MERC__c,
                                   Reserved_CAP_MERC__c,
                                   Count_Dietary_Preferences_MERC__c,
                                   HCP_Designated_Individuals_MERC__c,
                                   HCP_Contracting_Party_MERC__c,
                                   (SELECT Final_Fee_Rollup_MERC__c,
                                           Proposed_Final_Fee_Rollup_MERC__c,
                                           Status_MERC__c,
                                           Services_Rendered_MERC__c,
                                           Meeting_MERC__r.Meeting_Status_MERC__c
                                      FROM Event_Participants__r
                                     WHERE Meeting_MERC__r.End_Date_of_Event_MERC__c = THIS_YEAR
                                       AND Include_CAP_Roll_Up_MERC__c = TRUE),
                                   (SELECT Id
                                      FROM Consent__r
                                     WHERE Preference_Type_MERC__c = 'Meals Allergy Preferences')
                              FROM Account
                              WHERE Id IN :accountIds
                              FOR UPDATE];
                attempts = 0;
            } catch (System.QueryException qEx) {
                if (!qEx.getMessage().contains('Record Currently Unavailable') || attempts == 0) {
                    attempts = 0;  // exit on any other exception
                    throw qEx;  // throw exception after MAX_ATTEMPTS attempts
                }
            }
        }

        Set<String> allocatedCapMeetingStatuses  = new Set<String>{'Registered', 'Active'};
        Set<String> allocatedCapExcludedStatuses = new Set<String>{'Cancelled', 'Rejected', 'Declined'};
        Set<String> paidCapMeetingStatuses       = new Set<String>{'Complete','Complete - Closed','Complete - Cancelled'};
        Set<String> reservedCapExcludedStatuses  = new Set<String>{'Cancelled', 'Rejected', 'Declined'};

        Set<Id> parentAccountIds = new Set<Id>();

        for (Account account : accounts) {
            account.Allocated_CAP_MERC__c     = 0;
            account.Speaking_Paid_CAP_MERC__c = 0;
            account.Reserved_CAP_MERC__c      = 0;

            for (Meeting_Participant_MERC__c participant : account.Event_Participants__r) {
                String meetingStatus     = participant.Meeting_MERC__r.Meeting_Status_MERC__c;
                String participantStatus = participant.Status_MERC__c;

                //Allocated Cap
                if (allocatedCapMeetingStatuses.contains( meetingStatus ) && !allocatedCapExcludedStatuses.contains( participantStatus )) {
                    account.Allocated_CAP_MERC__c += participant.Final_Fee_Rollup_MERC__c != null ? participant.Final_Fee_Rollup_MERC__c : 0;
                }

                //Paid Cap - Speaking
                if (participant.Services_Rendered_MERC__c == 'Yes' && paidCapMeetingStatuses.contains( meetingStatus )) {
                    account.Speaking_Paid_CAP_MERC__c += participant.Final_Fee_Rollup_MERC__c != null ? participant.Final_Fee_Rollup_MERC__c : 0;
                }

                //Reserved Cap
                if (meetingStatus == 'Forecasted' && !reservedCapExcludedStatuses.contains( participantStatus )) {
                    account.Reserved_CAP_MERC__c += participant.Proposed_Final_Fee_Rollup_MERC__c != null ? participant.Proposed_Final_Fee_Rollup_MERC__c : 0;
                }
            }

            //Number of Dietary Preferences Completed
            account.Count_Dietary_Preferences_MERC__c = account.Consent__r.size();

            if (account.HCP_Designated_Individuals_MERC__c != null) {
                parentAccountIds.add(account.HCP_Designated_Individuals_MERC__c);
            }
            if (account.HCP_Contracting_Party_MERC__c != null) {
                parentAccountIds.add(account.HCP_Contracting_Party_MERC__c);
            }
        }

        //No need to trigger anything so turn off all triggers
        MERC_TriggerHandlerStateManager.deactivateAll();
        //update accounts, may need to retry attempt if records are locked by another asynchronous process
        attempts = MAX_ATTEMPTS;
        while(attempts > 0) {
            try {
                attempts--;
                update accounts;
                attempts = 0;
            } catch (System.Exception dmlEx) {
                if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW') || attempts == 0) {
                    attempts = 0;  // exit on any other exception
                    throw dmlEx;  // throw exception after MAX_ATTEMPTS
                }
            } // end of catch
        } // end of while retry loop

        parentAccountIds.remove(null);
        //unit tests will fail if chained
        if (!parentAccountIds.isEmpty() && !Test.isRunningTest() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
        	System.enqueueJob(new MERC_AccountToAccountRollups(parentAccountIds));
        }
    }
}