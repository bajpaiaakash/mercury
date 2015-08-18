/*
* MERC_MeetingTaskEditorController
* Description : Controller which provides functionality for MERC_MeetingTaskEditor.page.
*			   Allows users to filter meeting tasks for a meeting by Process and Process State.
*			   Allows users to set status of meetings en masse
* Author: Kyle Thornton (Mavens Consulting)
* Created Date: June 9, 2015
*
* Modified By:
* Modified Date:
* Modification Description:
*/

public with sharing class MERC_MeetingTaskEditorController {

	// static pageSize integer will allow for manipulation in unit tests.
	public static Integer pageSize = 100;
	public static String  noMeetingIdError = 'No meetingid URL Parameter provided';
	public static String  cannotLocatMeetingError = 'Unable to locate meeting with meetingid provided';

	public Meeting_Process_MERC__c filterProcess { get; set; } //used to drive filter dropdowns
	public Meeting_Tasks_MERC__c   filterTask { get; set; } //used to drive filter dropdowns
	public Meeting_Tasks_MERC__c   updateTask { get; set; } //used to drive values of selected records
	public Meeting_MERC__c		 meeting	{ get; private set; }
	public Boolean				 noErrors   { get; private set; }
	public List<Task>			  tasks = new List<Task>();

	private String meetingId;
	private Integer pageNumber;

	public String meetingProcessSuffix { 
		get {
			if (sortField == 'Meeting_Process_MERC__r.Name') {
				if (sortDirection == 'ASC') {
					return '^';
				} else {
					return 'v';
				}
			}
			else {
				return ' ';
			}
		}
		set; 
	}
	public String meetingTaskSuffix { 
		get {
			if (sortField == 'Name') {
				if (sortDirection == 'ASC') {
					return '^';
				} else {
					return 'v';
				}
			}
			else {
				return ' ';
			}
		}
		set; 
	}
	public String meetingParticipantSuffix { 
		get {
			if (sortField == 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Name') {
				if (sortDirection == 'ASC') {
					return '^';
				} else {
					return 'v';
				}
			}
			else {
				return ' ';
			}
		}
		set; 
	}
	public String recordTypeSuffix { 
		get {
			if (sortField == 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.RecordType.Name') {
				if (sortDirection == 'ASC') {
					return '^';
				} else {
					return 'v';
				}
			}
			else {
				return ' ';
			}
		}
		set; 
	}
	public String taskStatusSuffix { 
		get {
			if (sortField == 'Task_Status_MERC__c') {
				if (sortDirection == 'ASC') {
					return '^';
				} else {
					return 'v';
				}
			}
			else {
				return ' ';
			}
		}
		set; 
	}
	public String dueDateSuffix { 
		get {
			if (sortField == 'Due_Date_MERC__c') {
				if (sortDirection == 'ASC') {
					return '^';
				} else {
					return 'v';
				}
			}
			else {
				return ' ';
			}
		}
		set; 
	}
	public String accountNameSuffix { 
		get {
			if (sortField == 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Account_MERC__r.Name') {
				if (sortDirection == 'ASC') {
					return '^';
				} else {
					return 'v';
				}
			}
			else {
				return ' ';
			}
		}
		set; 
	}

	// the current field to sort by. defaults to last name
	public String sortField {
		// To set a Field for sorting.
		get  { 
				if (sortField == null) {
					sortField = 'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Account_MERC__r.Name';
				}
				return sortField;  
			}
		set {
			if (sortField == value) {
				if (sortDirection == 'ASC') {
					sortDirection = 'DESC';
				} else {
					sortDirection = 'ASC';
				}
			}
			sortField = value;
		}
	} 

	public String sortDirection { 
		get {
			if (sortDirection == null) {
				sortDirection = 'ASC';
			}
			return sortDirection;
		} 
		set; 
	}

	public MERC_MeetingTaskEditorController() {
		noErrors = false;


		meetingId = ApexPages.currentPage().getParameters().get('meetingid');


		if (String.isBlank(meetingId)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, noMeetingIdError));
			return;
		}

		meetingId = String.escapeSingleQuotes(meetingId);

		try {
			meeting = [SELECT Id, Name, Start_Date_Meeting_Time_Zone_MERC__c, End_Date_Meeting_Time_Zone_MERC__c FROM Meeting_MERC__c WHERE Id =:meetingid];
		} catch (System.queryException ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, cannotLocatMeetingError));
			return;
		}

		filterProcess = new Meeting_Process_MERC__c();
		filterProcess.Process_Type_MERC__c = '';
		filterTask = new Meeting_Tasks_MERC__c();
		filterTask.Task_Status_MERC__c = 'Incomplete';
		updateTask = new Meeting_Tasks_MERC__c();
		updateTask.Task_Status_MERC__c = '';

		noErrors = true;
	}

	/*
		- creates standardSetController allowing for pagination of records
		- query is built dynamically based on the Process and Process State Filters
	*/
	public ApexPages.StandardSetController meetingTasks {
		get {
			if(meetingTasks == null) {
				String soqlQuery = 'SELECT Name, ' +
										  'Due_Date_MERC__c, ' +
										  'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Account_MERC__r.IsPersonAccount, ' +
										  'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Account_MERC__r.Name, ' +
										  'Meeting_Process_MERC__r.Meeting_Participant_MERC__r.RecordTypeId, ' +
										  'Meeting_Process_MERC__r.Process_Type_MERC__c, ' +
										  'Meeting_Process_MERC__r.Process_Status_MERC__c, ' +
										  'Meeting_Process_MERC__r.Meeting_Participant_MERC__c, ' +
										  'Task_Status_MERC__c ' +
									 'FROM Meeting_Tasks_MERC__c ' +
									'WHERE Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Meeting_MERC__c=\'' + String.escapeSingleQuotes(meetingId) + '\' ';
				if (String.isNotBlank(filterProcess.Process_Type_MERC__c)) {
					soqlQuery += 'AND Meeting_Process_MERC__r.Process_Type_MERC__c = \'' + String.escapeSingleQuotes(filterProcess.Process_Type_MERC__c) + '\'';
				}
				if (String.isNotBlank(filterTask.Task_Status_MERC__c)) {
					soqlQuery += 'AND Task_Status_MERC__c = \'' + String.escapeSingleQuotes(filterTask.Task_Status_MERC__c) + '\'';
				}

				soqlQuery += 'ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
				System.debug(soqlQuery);

				meetingTasks = new ApexPages.StandardSetController(Database.getQueryLocator(soqlQuery));
				// sets the number of records in each page set
				meetingTasks.setPageSize(pageSize);

				// If page number is set then update the page number in the meeting tasks
				if (pageNumber != null) {
					meetingTasks.setPageNumber(pageNumber);
				}
			}
			return meetingTasks;
		}
		set;
	}

	/*
		- return a list of wrapped meeting tasks
		- deepClone the records from the standard set controller to avoid "modified rows exist in the records collection!" error.
	*/
	public List<Task> getTasks() {
		tasks = new List<Task>();
		for (Meeting_Tasks_MERC__c task : (List<Meeting_Tasks_MERC__c>)meetingTasks.getRecords().deepClone(true, true, true)) {
			tasks.add(new Task(task));
		}
		return tasks;
	}

	/*
		- null out meeting tasks so that the standard set controller can be requeried with new filters
		- null out pageNumber so that the requeried meetingTasks will start at page 1
	*/
	public PageReference updateTasks() {
		meetingTasks = null;
		pageNumber = null;
		return null;
	}

	/*
		- provide meetingHeader string
	*/
	public String getMeetingHeader() {
		return meeting.Name + ' (' + meeting.Start_Date_Meeting_Time_Zone_MERC__c + ' to ' + meeting.End_Date_Meeting_Time_Zone_MERC__c + ')';
	}

	/*
		- determine whether there are more meeting tasks in the recordset
		- meetingTasks may be null so need to check that here
	*/
	public Boolean getHasNext() {
		return (meetingTasks != null) && meetingTasks.getHasNext();
	}

	/*
		- determine whether there are prior meeting tasks in the recordset
		- meetingTasks may be null so need to check that here
	*/
	public Boolean getHasPrevious() {
		return (meetingTasks != null) && meetingTasks.getHasPrevious();
	}

	/*
		- return pagereference for the meeting
	*/
	public PageReference returnToMeeting() {
		return new PageReference('/' + meeting.Id);
	}


	/*
		- update selected records, setting the Task Status to the status chosen by the user on the "updateTask"
		- get the current page number so it can be set after the data is requeried
		- null out meetingTasks to force a requery
	*/
	public PageReference updateSelected() {
		List<Meeting_Tasks_MERC__c> tasksToUpdate = new List<Meeting_Tasks_MERC__c>();
		Integer tasksUpdated = 0;
		for (Task task : tasks) {
			if (task.selected) {
				task.detail.Task_Status_MERC__c = updateTask.Task_Status_MERC__c;
				tasksToUpdate.add(task.detail);
				tasksUpdated++;
			}
		}
		update tasksToUpdate;
		pageNumber = meetingTasks.getPageNumber();

		meetingTasks = null;

		String successMessage = 'Success! ';
		if (tasksUpdated == 1) {
			successMessage += tasksUpdated + ' Task updated.';
		} else {
			successMessage += tasksUpdated + ' Tasks updated.';
		}

		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, successMessage));
		return null;
	}

	/*
		- Wrapper class for meeting task which allows for selection of tasks.
	*/
	public Class Task {
		public Boolean selected { get; set; }
		public Meeting_Tasks_MERC__c detail { get; set; }

		public Task(Meeting_Tasks_MERC__c meetingTask) {
			this.selected = false;
			this.detail = meetingTask;
		}
	}
}