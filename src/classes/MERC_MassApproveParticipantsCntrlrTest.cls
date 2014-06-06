/**
* @author Kyle Thornton
*
* This is the test class for the MERC_MassApproveParticipants controller that executes
* tests against the methods to ensure everything is working as expected.
*/


@isTest
private class MERC_MassApproveParticipantsCntrlrTest
{
	static User testUser = MERC_TestFactory.getRunningUser();
	static List<Account> accounts  = MERC_TestFactory.insertAccounts(200);
	static Meeting_MERC__c meeting = MERC_TestFactory.insertMeetings(1).get(0);
	static List<Meeting_Participant_MERC__c> participants = MERC_TestFactory.insertParticipants(meeting.Id, accounts, 'Pending Approval');
	static ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new List<Meeting_MERC__c>{meeting});

	@isTest static void test_should_return_meeting_from_getter()
	{
		System.runAs(testUser)
		{
			PageReference pageRef = Page.MERC_MassApproveParticipants;
			pageRef.getParameters().put('id', meeting.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();
			MERC_MassApproveParticipantsController controller = new MERC_MassApproveParticipantsController(ssc);
			System.assert(controller.meeting.Id == meeting.Id);
			System.assert(controller.meeting.Name == meeting.Name);
			Test.stopTest();
		}
	}

	@isTest static void test_should_return_two_select_options()
	{
		System.runAs(testUser)
		{
			PageReference pageRef = Page.MERC_MassApproveParticipants;
			pageRef.getParameters().put('id', meeting.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();
			MERC_MassApproveParticipantsController controller = new MERC_MassApproveParticipantsController(ssc);
			System.assertEquals(2, controller.statusOptions.size());
			System.assertEquals('Approved', controller.statusOptions[0].getValue());
			System.assertEquals('Rejected', controller.statusOptions[1].getValue());
			Test.stopTest();
		}
	}

	@isTest static void test_should_bulid_pending_participant_list_correctly()
	{
		System.runAs(testUser)
		{
			PageReference pageRef = Page.MERC_MassApproveParticipants;
			pageRef.getParameters().put('id', meeting.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();
			MERC_MassApproveParticipantsController controller = new MERC_MassApproveParticipantsController(ssc);
			System.assertEquals(200, controller.participantsPendingApproval.participants.size());
			System.assertEquals(0, controller.participantsApproved.participants.size());
			System.assertEquals(0, controller.participantsRejected.participants.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_bulid_approved_participant_list_correctly()
	{
		for (Meeting_Participant_MERC__c mp : participants)
		{
			mp.Status_MERC__c = 'Approved';
		}
		update participants;

		System.runAs(testUser)
		{
			PageReference pageRef = Page.MERC_MassApproveParticipants;
			pageRef.getParameters().put('id', meeting.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();
			MERC_MassApproveParticipantsController controller = new MERC_MassApproveParticipantsController(ssc);
			System.assertEquals(0, controller.participantsPendingApproval.participants.size());
			System.assertEquals(200, controller.participantsApproved.participants.size());
			System.assertEquals(0, controller.participantsRejected.participants.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_bulid_rejected_participant_list_correctly()
	{
		for (Meeting_Participant_MERC__c mp : participants)
		{
			mp.Status_MERC__c = 'Rejected';
		}
		update participants;

		System.runAs(testUser)
		{
			PageReference pageRef = Page.MERC_MassApproveParticipants;
			pageRef.getParameters().put('id', meeting.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();
			MERC_MassApproveParticipantsController controller = new MERC_MassApproveParticipantsController(ssc);
			System.assertEquals(0, controller.participantsPendingApproval.participants.size());
			System.assertEquals(0, controller.participantsApproved.participants.size());
			System.assertEquals(200, controller.participantsRejected.participants.size());
			Test.stopTest();
		}
	}

	@isTest static void test_should_set_status_to_approved_for_selected()
	{
		System.runAs(testUser)
		{
			PageReference pageRef = Page.MERC_MassApproveParticipants;
			pageRef.getParameters().put('id', meeting.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();
			MERC_MassApproveParticipantsController controller = new MERC_MassApproveParticipantsController(ssc);
			for (MERC_MassApproveParticipantsController.SelectableParticipant sp : controller.participantsPendingApproval.participants)
			{
				sp.selected = true;
			}
			controller.participantsPendingApproval.approveSelected();
			controller.refreshTables();

			System.assertEquals(0, controller.participantsPendingApproval.participants.size());
			System.assertEquals(200, controller.participantsApproved.participants.size());
			System.assertEquals(0, controller.participantsRejected.participants.size());

			Test.stopTest();
		}
	}

	@isTest static void test_should_set_status_to_rejected_for_selected()
	{
		System.runAs(testUser)
		{
			PageReference pageRef = Page.MERC_MassApproveParticipants;
			pageRef.getParameters().put('id', meeting.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();
			MERC_MassApproveParticipantsController controller = new MERC_MassApproveParticipantsController(ssc);
			for (MERC_MassApproveParticipantsController.SelectableParticipant sp : controller.participantsPendingApproval.participants)
			{
				sp.selected = true;
			}
			controller.participantsPendingApproval.rejectSelected();
			controller.refreshTables();

			System.assertEquals(0, controller.participantsPendingApproval.participants.size());
			System.assertEquals(0, controller.participantsApproved.participants.size());
			System.assertEquals(200, controller.participantsRejected.participants.size());

			Test.stopTest();
		}
	}

	@isTest static void test_should_set_status_for_single_record()
	{
		System.runAs(testUser)
		{
			PageReference pageRef = Page.MERC_MassApproveParticipants;
			pageRef.getParameters().put('id', meeting.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();
			MERC_MassApproveParticipantsController controller = new MERC_MassApproveParticipantsController(ssc);
			//pick a random participant, I like 20
			controller.activeParticipantId = controller.participantsPendingApproval.participants[20].detail.Id;
			controller.activeParticipantStatus = 'Approved';

			controller.updateSingleParticipant();
			controller.refreshTables();

			System.assertEquals(199, controller.participantsPendingApproval.participants.size());
			System.assertEquals(1, controller.participantsApproved.participants.size());
			System.assertEquals(0, controller.participantsRejected.participants.size());

			Test.stopTest();
		}
	}

}