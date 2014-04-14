/**
 * @author Kyle Thornton
 *
 * Tests the MERC_MeetingCancellationHandler
 * As this is testing a class with the sole purpose of sending email
 * we can only exercise the code. Salesforce provides no mechanism to
 * indicate emails were sent. We use the Limits.getEmailInvocations()
 * method but that isn't really accurate as there is other code or
 * workflows that might invoke email so we just check that the number
 * increases.
 */

@isTest
private class MERC_MeetingCancellationHandlerTest {

	static List<User> testUsers;
	static Id mercuryUserRecordTypeId;
	static Id nonMercuryUserRecordTypeId;
	static List<Meeting_MERC__c> meetings;
	static
	{
		testUsers = MERC_TestFactory.insertTestUsers(2, null);
		mercuryUserRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Mercury_User_MERC' AND SobjectType = 'Team_Member_MERC__c'].ID;
		nonMercuryUserRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'External_User_MERC' AND SobjectType = 'Team_Member_MERC__c'].ID;

		/* insert a dummy contact for the workaround in the trigger */
		insert new Contact(LastName='Dummy', Email='dummy@dummy.com');
		meetings  = MERC_TestFactory.insertMeetings(200);
	}

	@isTest static void test_should_send_emails_to_team_members() {
		List<Team_Member_MERC__c> teamMembers = new List<Team_Member_MERC__c>();
		Boolean oddNumber = true;
		/* create team members for each meeting. 1/2 mercury users, 1/2 not */
		for (Meeting_MERC__c meeting : meetings)
		{
			Team_Member_MERC__c member = new Team_Member_MERC__c();
			member.User_MERC__c = oddNumber ? testUsers.get(0).Id : testUsers.get(1).Id;
			member.Meeting_MERC__c = meeting.Id;
			member.RecordTypeId = oddNumber ? mercuryUserRecordTypeId : nonMercuryUserRecordTypeId;
			teamMembers.add(member);

			oddNumber = !oddNumber;
			meeting.Send_Meeting_Team_Cancelled_Email_MERC__c = 'TRUE';
		}

		insert teamMembers;

		Test.startTest();
		Integer emailInvocationsBefore = Limits.getEmailInvocations();
        update meetings;
        System.assertNotEquals(emailInvocationsBefore, Limits.getEmailInvocations());
		Test.stopTest();
	}
}