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
	static User runningUser = MERC_TestFactory.getRunningUser();
	static User testUser = MERC_TestFactory.getTestingUser();

	static Id mercuryUserRecordTypeId;
	static Id nonMercuryUserRecordTypeId;
	static List<Meeting_MERC__c> meetings;
	static
	{
		Contact dummyContact;
		Account accnt;

		System.runAs(runningUser) {
			testUsers = MERC_TestFactory.insertTestUsers(2, null);
			mercuryUserRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Mercury_User_MERC' AND SobjectType = 'Team_Member_MERC__c'].ID;
			nonMercuryUserRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'External_User_MERC' AND SobjectType = 'Team_Member_MERC__c'].ID;

			/* insert a dummy contact for the workaround in the trigger
			MERC_MeetingCancellationHandler expecting:  
			    line 52:    Contact dummyContact = [
			    	select Name, Email from Contact 
			    	where email <> null AND FirstName <> null AND LastName <> null AND 
			    	IsPersonAccount = true AND IsEmailBounced = false AND AccountId <> null AND FirstName = 'David' LIMIT 1
			    ];
			*/
			dummyContact = new Contact(FirstName = 'David', LastName='Dummy', Email='dummy@dummy.com');
			insert dummyContact;
			accnt = new Account();
			accnt.RecordTypeId = MERC_TestFactory.employeeRecordTypeId;
			accnt.FirstName = 'David';
			accnt.LastName='Dummy';
			accnt.PersonEmail = 'dummy@dummy.com';
			insert accnt;

			MERC_TriggerHandlerStateManager.deactivateAll();  // reduce some of the overhead
			meetings  = MERC_TestFactory.insertMeetings(200);
			MERC_TriggerHandlerStateManager.activateAll();
		}

		   	/* set up sosl serach results */
		   	Id [] fixedSearchResults= new Id[1];
	       	fixedSearchResults[0] = accnt.Id;
	       	Test.setFixedSearchResults(fixedSearchResults);
	}

	@isTest static void test_should_send_emails_to_team_members() {
		List<Team_Member_MERC__c> teamMembers = new List<Team_Member_MERC__c>();
		Boolean oddNumber = true;

		System.runAs(runningUser) {
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
		}

		Test.startTest();
		Integer emailInvocationsBefore = Limits.getEmailInvocations();
		System.runAs(testUser) {
	        update meetings;
	    }
        System.assertNotEquals(emailInvocationsBefore, Limits.getEmailInvocations());
		Test.stopTest();
	}
}