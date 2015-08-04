/*
* MERC_MeetingTaskEditorControllerTest
* Description : Test the MeetingTaskEditor controller. The MeetingTaskEditorController 
*               provides functionality for MERC_MeetingTaskEditor.page.
* Author: Rick Locke (Mavens Consulting)
* Created Date: July 13, 2015
*/

@isTest
private class MERC_MeetingTaskEditorControllerTest {

	// Test all the functions when the controller has data.
	@isTest static void controllerUsageWithDataTest() {

		// get the necessary data
		Meeting_MERC__c meeting = buildData();

		// data has been created
		PageReference pageRef = Page.MERC_MeetingTaskEditor;
		Test.setCurrentPage(pageRef);  

		// add parameters to page URL
		ApexPages.currentPage().getParameters().put('meetingid', meeting.Id);

		// initialize controller
		MERC_MeetingTaskEditorController controller = new MERC_MeetingTaskEditorController();

		/* set the process filter to 'Registration' 
		 * and assert that it was set correctly.
		 * in the controller.
		 */
		Meeting_Process_MERC__c filterProcess = controller.filterProcess;
		filterProcess.Process_Type_MERC__c = 'Registration';
		System.assertEquals('Registration',filterProcess.Process_Type_MERC__c);

		/* set the task filter to 'Registration'
		 * and assert that it was set correctly
		 * in the controller.
		 */
		Meeting_Tasks_MERC__c filterTask = controller.filterTask;
		filterTask.Task_Status_MERC__c = 'Incomplete';
		System.assertEquals('Incomplete',filterTask.Task_Status_MERC__c);

		// Test to make sure there is no hasPrevious or hasNext
		System.assertEquals(false, controller.getHasPrevious());
		System.assertEquals(false, controller.getHasNext());

		/* Test to make certain the meetingTasks have no hasPrevious or hasNext 
		 * and that the controller is on page 1.
		 */
		System.assertEquals(false, controller.meetingTasks.getHasPrevious());
		System.assertEquals(false, controller.meetingTasks.getHasNext());
		System.assertEquals(1, controller.meetingTasks.getPageNumber());

		/* use all the methods that can be access from 
		 * the page to ensure nothing crashes.
		 */
		pageRef = controller.updateTasks();
		pageRef = controller.returnToMeeting();
		pageRef = controller.updateSelected();

		// Ensure no tasks are actually in the controller.
		System.assertEquals(0, controller.getTasks().size());

		// Test if the initial header sorting is correct.
		System.assertEquals(controller.meetingProcessSuffix, ' ');
		System.assertEquals(controller.meetingTaskSuffix, ' ');
		System.assertEquals(controller.meetingParticipantSuffix, ' ');
		System.assertEquals(controller.recordTypeSuffix, ' ');
		System.assertEquals(controller.taskStatusSuffix, ' ');
		System.assertEquals(controller.dueDateSuffix, ' ');
		System.assertEquals(controller.accountNameSuffix, '^');

		// Simulate clicking on Account Name header.
		controller.sortField = 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Account_MERC__r.Name';
		System.assertEquals(controller.accountNameSuffix, 'v');		

		// Simulate clicking on the Account Name header again.
		controller.sortField = 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Account_MERC__r.Name';
		System.assertEquals(controller.accountNameSuffix, '^');		
	}

	// Test all the functions when the controller has no parameters set.
	@isTest static void parameterMissingTest() {

		PageReference pageRef = Page.MERC_MeetingTaskEditor;
		Test.setCurrentPage(pageRef);    

		MERC_MeetingTaskEditorController controller = new MERC_MeetingTaskEditorController();
	}

	// Builds necessary data for controller to operate.
	static Meeting_MERC__c buildData () {
		//create data necessary for MeetingTaskEditor page.
		Meeting_MERC__c meeting = Merc_TestFactory.insertMeetings(1)[0];
		Account acc = Merc_TestFactory.insertAccounts(1)[0];
		Meeting_Participant_MERC__c participant = Merc_TestFactory.insertParticipants(meeting.Id, new List<Account>{acc})[0];

		Meeting_Process_MERC__c process = new Meeting_Process_MERC__c(
			Meeting_Participant_MERC__c = participant.Id,
			Process_Type_MERC__c = 'Registration'
			);

		insert process;

		return meeting;
	}
}