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
                                   MERC_Allocated_Fee_for_Current_Year__c,
                                   MERC_Allocated_Fee_for_Next_Yr_Cons_Only__c,
                                   Reserved_CAP_MERC__c,
                                   Count_Dietary_Preferences_MERC__c,
                                   HCP_Designated_Individuals_MERC__c,
                                   HCP_Contracting_Party_MERC__c,
                                   Dietary_Preferences_MERC__c,
                                   (SELECT Final_Fee_Rollup_MERC__c,
                                           Proposed_Final_Fee_Rollup_MERC__c,
                                           Status_MERC__c,
                                           Meeting_MERC__r.MERC_Meeting_Complete_Canceled_Clsd_Date__c,
                                           Meeting_MERC__r.MERC_Meeting_End_date_plus_6_months__c,
                                           Meeting_MERC__r.MERC_Meeting_End_Date_Inactive__c,
                                           Services_Rendered_MERC__c,
                                           Meeting_MERC__r.Meeting_Status_MERC__c,
                                           Meeting_MERC__r.Date_of_Event_MERC__c,
                                           Meeting_MERC__r.End_Date_of_Event_MERC__c,
                                           Meeting_MERC__r.RecordType.DeveloperName,RecordType.DeveloperName
                                      FROM Event_Participants__r
                                     WHERE Include_CAP_Roll_Up_MERC__c = TRUE
                                       AND Confirm_Final_Fee_MERC__c = 'Confirmed'
                                       AND RecordType.DeveloperName IN('MERC_Consulting','MERC_Service_Provider') ),
                                   (SELECT Id, Preference_Sub_Type_MERC__c
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
            account.Reserved_CAP_MERC__c      = 0;
            account.MERC_Allocated_Fee_for_Current_Year__c = 0; //Added by Namrata Aggarwal On 09-FEB-2016 for US-39907
            account.MERC_Allocated_Fee_for_Next_Yr_Cons_Only__c = 0; //Added by Namrata Aggarwal On 09-FEB-2016 for US-39907

            for (Meeting_Participant_MERC__c participant : account.Event_Participants__r) {
                String meetingStatus     = participant.Meeting_MERC__r.Meeting_Status_MERC__c;
                String participantStatus = participant.Status_MERC__c;

                /* Added by Namrata Aggarwal On 09-FEB-2016 for US-39907 to calculate Allocated final fee for Consulting meetings when start date is equal to current year */
                if (!allocatedCapExcludedStatuses.contains( participantStatus ) && meetingStatus != 'Forecasted' && participant.Meeting_MERC__r.Date_of_Event_MERC__c.year() == Date.Today().year() && participant.Meeting_MERC__r.RecordType.DeveloperName == 'Ad_Hoc_Consulting' && participant.Meeting_MERC__r.MERC_Meeting_Complete_Canceled_Clsd_Date__c == NULL ){
                   account.MERC_Allocated_Fee_for_Current_Year__c += participant.Final_Fee_Rollup_MERC__c != null ? participant.Final_Fee_Rollup_MERC__c : 0;

                }

                /* Added by Namrata Aggarwal On 09-FEB-2016 for US-39907 to calculate Allocated final fee for Non-Consulting meetings when start date is equal to current year */
                if (!allocatedCapExcludedStatuses.contains( participantStatus ) && meetingStatus != 'Forecasted' && meetingStatus != 'Complete - Cancelled'&& participant.Meeting_MERC__r.Date_of_Event_MERC__c.year() == Date.Today().year() && participant.Meeting_MERC__r.RecordType.DeveloperName != 'Ad_Hoc_Consulting'){
                   account.MERC_Allocated_Fee_for_Current_Year__c += participant.Final_Fee_Rollup_MERC__c != null ? participant.Final_Fee_Rollup_MERC__c : 0;

                }

                /* Added by Namrata Aggarwal On 09-FEB-2016 for US-39907 to calculate Allocated final fee for consulting meetings when start date is not equal to current year and Meeting end date has not been passed */
                if (!allocatedCapExcludedStatuses.contains( participantStatus ) && meetingStatus != 'Forecasted' && participant.Meeting_MERC__r.Date_of_Event_MERC__c.year() < Date.Today().year() && participant.Meeting_MERC__r.RecordType.DeveloperName == 'Ad_Hoc_Consulting' && participant.Meeting_MERC__r.MERC_Meeting_End_Date_Inactive__c == false && participant.Meeting_MERC__r.MERC_Meeting_Complete_Canceled_Clsd_Date__c == NULL) {
                   account.MERC_Allocated_Fee_for_Next_Yr_Cons_Only__c += participant.Final_Fee_Rollup_MERC__c != null ? participant.Final_Fee_Rollup_MERC__c : 0;

                }

                //Reserved Cap
                if (meetingStatus == 'Forecasted' && !reservedCapExcludedStatuses.contains( participantStatus ) && participant.Meeting_MERC__r.Date_of_Event_MERC__c.year() == Date.Today().year()) {
                    account.Reserved_CAP_MERC__c += participant.Final_Fee_Rollup_MERC__c != null ? participant.Final_Fee_Rollup_MERC__c : 0;
                }
            }

            //Number of Dietary Preferences Completed
            account.Count_Dietary_Preferences_MERC__c = account.Consent__r.size();

            // Stamp the dietary preference with a semi-colon delimited string
            String dietaryPrefs = '';
            for (Preferences_and_Consent_GLBL__c pref : account.Consent__r) {
              dietaryPrefs += pref.Preference_Sub_Type_MERC__c + ';';
            }
            account.Dietary_Preferences_MERC__c = dietaryPrefs;

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