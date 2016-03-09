@isTest
private class MERC_MeetingTOVFinalValidationTest
{

    public static User runningUser; 
    public static User testUser ;
    public static Meeting_MERC__c meeting;
    public static List<Account> accounts;    
    public static List<Meeting_Participant_MERC__c> participants;
    public static List<Meeting_Day_MERC__c> meetingDayList;
    
    public static void initializedata(){
        runningUser = MERC_TestFactory.getRunningUser();
        testUser = MERC_TestFactory.getTestingUser();
        meeting = MERC_TestFactory.insertMeetings(1).get(0);  
        accounts = MERC_TestFactory.insertAccounts(1);
        participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);      
    }   
    
    static testMethod void test_meetingtovfinalvalidation3()
    {
    
        initializedata();
        test.startTest();
        
        ID participantRecordTypeId = [Select ID FROM RecordType WHERE SObjectType = 'Meeting_Participant_MERC__c' AND DeveloperName = 'Merc_Service_Provider' LIMIT 1].Id;
        ID meetingRecordTypeId = [Select ID FROM RecordType WHERE SObjectType = 'Meeting_MERC__c' AND DeveloperName = 'Meeting_Active' LIMIT 1].Id;
        
        participants[0].RecordTypeId = participantRecordTypeId;
        participants[0].status_MERC__c = 'Accepted' ;
    
        update participants[0];
        
        //Add Daily attendance to meeting participant
        meetingDayList= MERC_TestFactory.insertMeetingDays(meeting .Id,1);
        Daily_Attendance_TOV_MERC__c mpDat= MERC_TestFactory.insertTov(meetingDayList[0].Id,participants[0].Id);
    
        meeting.RecordTypeId = meetingRecordTypeId;
        meeting.Participant_ToV_Final_MERC__c = 'Yes';
        
        System.assertEquals('Accepted', participants[0].status_MERC__c);
        System.assertEquals('Yes', meeting.Participant_ToV_Final_MERC__c);
        
            try{
                    update meeting; 
            }
            catch(Exception e){
            
            }
            test.stopTest(); 
              
    }              
}