/**
 * @author Kyle Thornton
 *
 * This is the test class for the MERC_MeetingParticipantTovValidation class
 *
 */
@isTest
private class MERC_MeetingParticipantTovValidationTest
{

	static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
	static List<Account> accounts = MERC_TestFactory.insertAccounts(200);
	static List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts);
	static User testUser;

	static
	{
		System.runAs(new User(Id=UserInfo.getUserId()))
		{
			testUser = MERC_TestFactory.insertTestUsers(1, null).get(0);
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='Mercury_Customer_Meeting_Services_Edit' limit 1];
			insert new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=testUser.id);
			update new User(id=testUser.Id, UserRoleId=[SELECT Id FROM UserRole WHERE Name='CEO' limit 1].id);
		}
		//reset the Meeting Participant Validation trigger
		MERC_MeetingParticipantTovValidation.tovValidationByPass = false;
	}

	@isTest static void test_cannot_edit_validated_fields_when_meeting_tov_reported()
	{
		//the meeting is simply forecasted at this point as it defaulted to that value when created in the factory
		meeting.Participant_ToV_Final_MERC__c = 'Yes';
		meeting.Start_Time_of_Meeting_MERC__c = Date.today().addDays(-3);
		meeting.End_Time_of_Meeting_MERC__c = Date.today().addDays(-1);
		meeting.Confirm_Meeting_Date_Change_MERC__c = true;
		update meeting;

		System.runAs(testUser) {
			Schema.FieldSet validationFields = Schema.SObjectType.Meeting_Participant_MERC__c.fieldSets.ToV_Validation_Fields;
			for (Meeting_Participant_MERC__c participant : participants)
			{
				for (Schema.FieldSetMember fsm : validationFields.getFields())
				{
					participant.put(fsm.getFieldPath(), 100.00);
				}
			}
			Test.startTest();
			Boolean errorCaught = false;
			try
			{
				update participants;
			}
			catch(System.DMLException ex)
			{
				errorCaught = true;
				System.assert(ex.getMessage().contains(Label.ToV_Already_Reported));
			}
			System.assert(errorCaught, 'no exception thrown. that is bad');
			Test.stopTest();
		}
	}

	@isTest static void test_can_edit_validated_fields_when_meeting_tov_reported_and_confirm_tov_checked()
	{
		//the meeting is simply forecasted at this point as it defaulted to that value when created in the factory
		meeting.Participant_ToV_Final_MERC__c = 'Yes';
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