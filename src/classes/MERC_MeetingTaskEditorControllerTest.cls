/*
* MERC_MeetingTaskEditorControllerTest
* Description : Test the MeetingTaskEditor controller. The MeetingTaskEditorController 
*               provides functionality for MERC_MeetingTaskEditor.page.
* Author: Rick Locke (Mavens Consulting)
* Created Date: July 13, 2015
*/

@isTest
private class MERC_MeetingTaskEditorControllerTest {


	private static Meeting_MERC__c buildData() {

		//create data necessary for MeetingTaskEditor page.
		Meeting_MERC__c meeting = Merc_TestFactory.insertMeetings(1)[0];
		Account acc = Merc_TestFactory.insertAccounts(1)[0];
		Meeting_Participant_MERC__c participant = Merc_TestFactory.insertParticipants(meeting.Id, new List<Account>{acc})[0];

		Meeting_Process_MERC__c process = new Meeting_Process_MERC__c(
			Meeting_Participant_MERC__c = participant.Id,
			Process_Type_MERC__c = 'Registration'
			);

		insert process;

		List<Meeting_Tasks_MERC__c> tasks = new List<Meeting_Tasks_MERC__c>();

		Meeting_Tasks_MERC__c task0 = new Meeting_Tasks_MERC__c(
			Meeting_Process_MERC__c = process.Id,
			Task_Status_MERC__c = 'Completed - Process Complete'
			);

		tasks.add(task0);

		Meeting_Tasks_MERC__c task1 = new Meeting_Tasks_MERC__c(
			Meeting_Process_MERC__c = process.Id,
			Task_Status_MERC__c = 'Completed - Process Complete'
			);

		tasks.add(task1);

		Meeting_Tasks_MERC__c task2 = new Meeting_Tasks_MERC__c(
			Meeting_Process_MERC__c = process.Id,
			Task_Status_MERC__c = 'Completed - Process Complete'
			);

		tasks.add(task2);

		insert tasks;

		return meeting;

	}

	@isTest static void controllerUsageWithDataTest() {

		Meeting_MERC__c meeting = buildData();

		PageReference pageRef = Page.MERC_MeetingTaskEditor;
		Test.setCurrentPage(pageRef);    

		//Add parameters to page URL
		ApexPages.currentPage().getParameters().put('meetingid', meeting.Id);

		MERC_MeetingTaskEditorController controller = new MERC_MeetingTaskEditorController();

		Meeting_Process_MERC__c filterProcess = controller.filterProcess;
		filterProcess.Process_Type_MERC__c = 'Registration';

		Meeting_Tasks_MERC__c filterTask = controller.filterTask;
		filterTask.Task_Status_MERC__c = 'Completed - Process Complete';

		System.debug('##### getMeetingHeader = ' + controller.getMeetingHeader());
		System.debug('##### getHasPrevious = ' + controller.getHasPrevious());
		System.debug('##### getHasNext = ' + controller.getHasNext());
		System.assertEquals(false, controller.getHasPrevious());
		System.assertEquals(false, controller.getHasNext());

		System.debug('##### meetingTasks.getHasPrevious = ' + controller.meetingTasks.getHasPrevious());
		System.debug('##### meetingTasks.getHasNext = ' + controller.meetingTasks.getHasNext());
		System.debug('##### meetingTasks.getPageNumber' + controller.meetingTasks.getPageNumber());
		System.assertEquals(false, controller.meetingTasks.getHasPrevious());
		System.assertEquals(false, controller.meetingTasks.getHasNext());
		System.assertEquals(1, controller.meetingTasks.getPageNumber());

		System.debug('##### updateTasks = ' + controller.updateTasks());
		pageRef = controller.updateTasks();

		System.debug('##### returnToMeeting = ' + controller.returnToMeeting());
		pageRef = controller.returnToMeeting();

		System.debug('##### updateSelected = ' + controller.updateSelected());
		controller.tasks[0].selected = true;
		controller.updateTask.Task_Status_MERC__c = 'Complete - Unresponsive';
		pageRef = controller.updateSelected();

		controller.tasks[0].selected = true;
		controller.tasks[1].selected = true;
		controller.updateTask.Task_Status_MERC__c = 'Complete - Process Complete';
		pageRef = controller.updateSelected();

		System.debug('##### accountNameSuffix = ' + controller.accountNameSuffix);
		System.assertEquals(controller.meetingProcessSuffix, ' ');
		System.assertEquals(controller.meetingTaskSuffix, ' ');
		System.assertEquals(controller.meetingParticipantSuffix, ' ');
		System.assertEquals(controller.recordTypeSuffix, ' ');
		System.assertEquals(controller.taskStatusSuffix, ' ');
		System.assertEquals(controller.dueDateSuffix, ' ');
		System.assertEquals(controller.accountNameSuffix, '^');

		controller.sortField = 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Account_MERC__r.Name';
		System.assertEquals(controller.accountNameSuffix, 'v');		

		controller.sortField = 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Account_MERC__r.Name';
		System.assertEquals(controller.accountNameSuffix, '^');		


	}

	@isTest static void parameterMissingTest() {

		PageReference pageRef = Page.MERC_MeetingTaskEditor;
		Test.setCurrentPage(pageRef);    

		MERC_MeetingTaskEditorController controller = new MERC_MeetingTaskEditorController();
	}
}