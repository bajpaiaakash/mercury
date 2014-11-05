@isTest
public class MERC_ETTestUtils {
    private static Map<String, RecordType> rtMap = new Map<String, RecordType>();
    public static RecordType GetRecordType(String name, String sObjectType) {
        String compositeKey = String.format('{0} - {1}', new List<String> { name, sObjectType });
        if (!rtMap.containsKey(compositeKey)) {
            RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = :name AND sObjectType = :sObjectType];
            rtMap.put(compositeKey, rt);
        }
        return rtMap.get(compositeKey);
    }

    private static Map<String, Profile> profileMap = new Map<String, Profile>();
    public static Profile GetProfile(String name) {
        if (!profileMap.containsKey(name)) {
            Profile p = [SELECT Id FROM Profile WHERE Name = :name];
            profileMap.put(name, p);
        }
        return profileMap.get(name);
    }

    public static User CreateUser(String profileName) {
        return new User(
            Alias = 'newUser', 
            Email='newuser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = GetProfile(profileName).Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='newuser@testorg.com'
        );
    }

    private static integer meetingCounter = 0;
    public static List<Meeting_MERC__c> CreateMeetings(integer numMeetings) {
        List<Meeting_MERC__c> meetings = new List<Meeting_MERC__c>();

        for (integer i = 0; i < numMeetings; i++) {
            integer localCounter = meetingCounter++;
            meetings.add(new Meeting_MERC__c(
                Name = 'Test meeting ' + String.valueOf(localCounter)
            ));
        }

        return meetings;
    }

    public static Sonoma_ET_Config__c CreateConfig() {
        return new Sonoma_ET_Config__c(
            Default_From_Email__c = 'test@test.com',
            ET_BU_Name__c = 'Test',
            Send_Configuration_Key__c = 'testkey'
        );
    }

    public static et4ae5__configuration__c CreateETConfig() {
        return new et4ae5__configuration__c(
            et4ae5__integration_type__c = 'Enterprise2.0'
        );
    }

    public static et4ae5__Business_Unit__c CreateETBU(Sonoma_ET_Config__c config) {
        return new et4ae5__Business_Unit__c(
            Name = config.ET_BU_Name__c
        );
    }

    private static integer accountCounter = 0;
    public static List<Account> CreateAccounts(integer numAccounts) {
        List<Account> accts = new List<Account>();

        for (integer i = 0; i < numAccounts; i++) {
            integer localCounter = accountCounter++;
            accts.add(new Account(
                Name = 'Test Account ' + String.valueOf(localCounter)
            ));
        }

        return accts;
    }

    public static List<Account> CreatePersonAccountsWithRecordType(String recordTypeName, Integer numAccounts) {
        List<Account> accounts = new List<Account>();
        RecordType rt = MERC_ETTestUtils.GetRecordType(recordTypeName, 'Account');

        for (Integer i = 0; i < numAccounts; i++) {
            Integer localCounter = accountCounter++;
            Account a = new Account(
                RecordTypeId = rt.Id,
                FirstName = 'Test',
                LastName = 'A ' + String.valueOf(localCounter),
                PersonMailingStreet = 'Test street',
                PersonMailingPostalCode = '12345',
                PersonMailingCity = 'SFO',
                PersonEmail = 'test@testy.com',
                PersonHomePhone = '1234567',
                PersonMobilePhone = '2345678'
            );
            accounts.add(a);
        }
        
        return accounts;
    }

    public static List<Meeting_Participant_MERC__c> CreateParticipants(Meeting_MERC__c meeting, List<Account> personAccounts) {
        List<Meeting_Participant_MERC__c> participants = new List<Meeting_Participant_MERC__c>();

        for (Account acct : personAccounts) {
            participants.add(new Meeting_Participant_MERC__c(
                Account_MERC__c = acct.Id,
                Meeting_MERC__c = meeting.Id
            ));
        }

        return participants;
    }

    public static List<et4ae5__SendDefinition__c> CreateETSend(Integer count) {
        
        List<et4ae5__SendDefinition__c> etSends = new List<et4ae5__SendDefinition__c>();

        for (Integer i = 0; i < count; i++) {
            etSends.add(new et4ae5__SendDefinition__c());
        }

        return etSends;
    }

    public static List<et4ae5__IndividualEmailResult__c> CreateEtIndividualTrackingResult(Id personContactId, 
        List<et4ae5__SendDefinition__c> etSends) {

        List<et4ae5__IndividualEmailResult__c> individualTracking = new List<et4ae5__IndividualEmailResult__c>();
        
        for (et4ae5__SendDefinition__c etSend: etSends) {
            individualTracking.add( new et4ae5__IndividualEmailResult__c(
                et4ae5__Contact__c = personContactId, 
                et4ae5__SendDefinition__c = etSend.id
            ));
        }

        return individualTracking;
    }

    public static List<Meeting_Email_Send_MERC__c> CreateMeetingEmailSend(Id meetingId, List<et4ae5__SendDefinition__c> etSends) {
        
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = new List<Meeting_Email_Send_MERC__c>();

        for (et4ae5__SendDefinition__c etSend: etSends) {
            meetingEmailSends.add(new Meeting_Email_Send_MERC__c(
                Email_Send_Number_MERC__c=etSend.id, 
                Meeting_MERC__c=meetingId,
                Retry_Count__c = 0
            ));
        }

        return meetingEmailSends;
    }
    
    public static List<Meeting_Email_Send_MERC__c> createMeetingEmailSend(Id meetingId, integer numMeetingEmailSends) {
        List<Meeting_Email_Send_MERC__c> meetingEmailSends = new List<Meeting_Email_Send_MERC__c>();
        for (integer x= 0; x < numMeetingEmailSends; x++) {
            meetingEmailSends.add(new Meeting_Email_Send_MERC__c(
                Meeting_MERC__c=meetingId
            ));
        }
        
        return meetingEmailSends;
    }

    public static List<Meeting_Participant_Email_Send_MERC__c> CreateMeetingParticipantEmailSend(Id meetingParticipantId, 
        List<Meeting_Email_Send_MERC__c> meetingEmailSends) {
        
        List<Meeting_Participant_Email_Send_MERC__c> meetingParticipantEmailSends = new List<Meeting_Participant_Email_Send_MERC__c>();

        for (Meeting_Email_Send_MERC__c meetingEmailSend: meetingEmailSends) {
            meetingParticipantEmailSends.add(new Meeting_Participant_Email_Send_MERC__c(
                Meeting_Email_Send__c = meetingEmailSend.id, 
                Meeting_Participant__c=meetingParticipantId
            ));
        }

        return meetingParticipantEmailSends;
    }
}