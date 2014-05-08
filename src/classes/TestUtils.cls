@isTest
public class TestUtils {
    private static Map<String, RecordType> rtMap = new Map<String, RecordType>();
    public static RecordType GetRecordType(String name, String sObjectType) {
        String compositeKey = String.format('{0} - {1}', new List<String> { name, sObjectType });
        if (!rtMap.containsKey(compositeKey)) {
            RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = :name AND sObjectType = :sObjectType];
            rtMap.put(compositeKey, rt);
        }
        return rtMap.get(compositeKey);
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
            Default_From_Email__c = 'test@test.com'
        );
    }

    private static integer accountCounter = 0;
    public static List<Account> CreatePersonAccounts(integer numAccounts) {
        List<Account> accts = new List<Account>();

        for (integer i = 0; i < numAccounts; i++) {
            integer localCounter = accountCounter++;
            accts.add(new Account(
                Name = 'Test Account ' + String.valueOf(localCounter),
                RecordTypeId = GetRecordType('Person Account', 'Account').Id
            ));
        }

        return accts;
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
}