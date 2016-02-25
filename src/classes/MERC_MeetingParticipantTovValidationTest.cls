/**
 * @author Kyle Thornton
 *
 * This is the test class for the MERC_MeetingParticipantTovValidation class
 *
 */
@isTest
private class MERC_MeetingParticipantTovValidationTest
{

  //  static User runningUser = MERC_TestFactory.getRunningUser();
    static User testUser = MERC_TestFactory.getTestingUser();
    static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
   
    static List<Account> accounts = MERC_TestFactory.insertAccounts(200);
    static List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
    

    static
    {
     /*
        System.runAs(runningUser)
        {
            MERC_TriggerHandlerStateManager.deactivateAll();
            meeting = MERC_TestFactory.insertMeetings(1).get(0);
            accounts = MERC_TestFactory.insertAccounts(200);
            participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
            MERC_TriggerHandlerStateManager.activateAll();
        }
     */  
        //reset the Meeting Participant Validation trigger
        MERC_MeetingParticipantTovValidation.tovValidationByPass = false;
    }

    @isTest static void test_cannot_edit_validated_fields_when_meeting_tov_reported()
    {
        //the meeting is simply forecasted at this point as it defaulted to that value when created in the factory
        MERC_TriggerHandlerStateManager.deactivateAll();
        meeting.Participant_ToV_Final_MERC__c = 'Yes';
        meeting.Start_Time_of_Meeting_MERC__c = Date.today().addDays(-3);
        meeting.End_Time_of_Meeting_MERC__c = Date.today().addDays(-1);
        meeting.Confirm_Meeting_Date_Change_MERC__c = true;
        
        Test.startTest();
        MERC_TriggerHandlerStateManager.deactivateAll();
        update meeting;
        MERC_TriggerHandlerStateManager.deactivateAll();
        System.runAs(testUser) {
            Schema.FieldSet validationFields = Schema.SObjectType.Meeting_Participant_MERC__c.fieldSets.ToV_Validation_Fields;
            for (Meeting_Participant_MERC__c participant : participants)
            {
                for (Schema.FieldSetMember fsm : validationFields.getFields())
                {
                    participant.put(fsm.getFieldPath(), 100.00);
                }
            }
            //Test.startTest();
            Boolean errorCaught = false;
            try
            {
                update participants;
            
            }
            catch(System.DMLException ex)
            {
                errorCaught = true;
                System.assert(ex.getMessage().contains(Label.ToV_Already_Reported));
                System.assert(errorCaught, 'no exception thrown. that is bad');
            }
            //System.assert(errorCaught, 'no exception thrown. that is bad');
            
            Test.stopTest();
            MERC_TriggerHandlerStateManager.deactivateAll();
            
        }
    
    }

    @isTest static void test_can_edit_validated_fields_when_meeting_tov_reported_and_confirm_tov_checked()
    {
        //the meeting is simply forecasted at this point as it defaulted to that value when created in the factory
        //meeting.Participant_ToV_Final_MERC__c = 'Yes';
        meeting.Start_Time_of_Meeting_MERC__c = Date.today().addDays(-3);
        meeting.End_Time_of_Meeting_MERC__c = Date.today().addDays(-1);
        meeting.Confirm_Meeting_Date_Change_MERC__c = true;
        update meeting;

        System.runAs(testUser) {
            Schema.FieldSet validationFields = Schema.SObjectType.Meeting_Participant_MERC__c.fieldSets.ToV_Validation_Fields;
            for (Meeting_Participant_MERC__c participant : participants)
            {
                //populate rollup fields which will, in turn, populate the actual fields
                //then populate all the other fields
                participant.put('Total_Registration_ToV_Rollup_MERC__c', 100.00);
                participant.put('Total_Ground_Transport_ToV_Rollup_MERC__c', 100.00);
                participant.put('Total_Food_Beverage_ToV_Rollup_MERC__c', 100.00);
                for (Schema.FieldSetMember fsm : validationFields.getFields())
                {
                    participant.put(fsm.getFieldPath(), 100.00);
                }
                participant.Confirm_ToV_Reporting_Change_MERC__c = true;
            }
            Test.startTest();
            update participants;
            Test.stopTest();

            String soqlString = 'SELECT Id FROM Meeting_Participant_MERC__c WHERE ';
            for (Schema.FieldSetMember fsm : validationFields.getFields())
            {
                soqlString += fsm.getFieldPath() + '=100 AND ';
            }
            soqlString = soqlString.left(soqlString.length()-4);

            System.assertEquals(200, Database.query(soqlString).size());
        }
    }

    @isTest static void test_can_edit_validated_fields_when_meeting_not_tov_reported()
    {
       
        System.runAs(testUser) {
            Schema.FieldSet validationFields = Schema.SObjectType.Meeting_Participant_MERC__c.fieldSets.ToV_Validation_Fields;
            for (Meeting_Participant_MERC__c participant : participants)
            {
                //populate rollup fields which will, in turn, populate the actual fields
                //then populate all the other fields
                participant.put('Total_Registration_ToV_Rollup_MERC__c', 100.00);
                participant.put('Total_Ground_Transport_ToV_Rollup_MERC__c', 100.00);
                participant.put('Total_Food_Beverage_ToV_Rollup_MERC__c', 100.00);
                for (Schema.FieldSetMember fsm : validationFields.getFields())
                {
                    participant.put(fsm.getFieldPath(), 100.00);
                }
            }
            Test.startTest();
            update participants;
            Test.stopTest();

            String soqlString = 'SELECT Id FROM Meeting_Participant_MERC__c WHERE ';
            for (Schema.FieldSetMember fsm : validationFields.getFields())
            {
                soqlString += fsm.getFieldPath() + '=100.00 AND ';
            }
            soqlString = soqlString.left(soqlString.length()-4);
            System.debug([SELECT Id, Total_Registration_ToV_MERC__c, Total_Ground_Transporation_ToV_MERC__c FROM Meeting_Participant_MERC__c]);

            System.assertEquals(200, Database.query(soqlString).size());
        }
    
    }
   

}