/*
 * Author: Kyle Thornton - Mavens Consulting
 * Created Date: 22 Jun 2015
 * Description : This class handles evalutation of rules on the Meeting_Process_Logic_MERC__c object
*/
public with sharing class MERC_MeetingProcessLogicHandler implements GLBL_TriggerHandler.HandlerInterface {

    public static Map<String, List<Meeting_Process_Logic_MERC__c>> meetingProcessLogicRecordsByType;

    public Boolean isActive() {
        return MERC_TriggerHandlerStateManager.isActive(MERC_MeetingProcessLogicHandler.class);
    }

    Schema.SobjectType triggeredSobjectType;

    public MERC_MeetingProcessLogicHandler(Schema.SObjectType objectType) {
        this.triggeredSobjectType = objectType;
    }

    /* The handle method determines which sObject triggered the call and passes control to the approprate method*/
    public void handle() {

		if (triggeredSobjectType == Meeting_MERC__c.SobjectType) {
			//When a meeting is inserted there is no way for there to be participants to process.
			if (Trigger.isUpdate && Trigger.isAfter) {
				handleMeetings();
			}
		} else if (triggeredSobjectType == Meeting_Participant_MERC__c.SobjectType) {
			//When a meeting participant is inserted there is no way for there to be meeting processes to process.
			//When a meeting participant is updated the update must complete before we process meeting participants.*/
			if (Trigger.isUpdate && Trigger.isAfter) {
				handleMeetingParticipants();
			}
		} else if (triggeredSobjectType == Meeting_Process_MERC__c.SobjectType) {
			if (Trigger.isInsert && Trigger.isAfter) {
				handleMeetingProcesses();
			}
		} else if (triggeredSobjectType == Meeting_Tasks_MERC__c.SobjectType) {
			handleMeetingTasks();
		} else if (triggeredSobjectType == Travel_Itinerary_MERC__c.SobjectType) {
			if (trigger.isAfter) {
				handleTravelItineraries();
			}
		}
	}

	/* This method determines when a meeting has been triggered for evaluation of Meeting Process Logic.
	   It will gather up the meetings in the trigger which have been indicated for evalutation and then
   	   update all of the participants to trigger evalutation. As of 22 Jun 2015 there are no rules that
       would be processed at the meeting level, this trigger ensures rules are evaluated for particpants
   	   of the meeting.*/
	private void handleMeetings() {
		System.debug('##### In the Meeting Process Logic Handler for Meetings.');

		List<Meeting_MERC__c> meetingsToProcess = new List<Meeting_MERC__c>();

		for (Meeting_MERC__c meeting : (List<Meeting_MERC__c>)Trigger.new) {
			if (meeting.Evaluate_Meeting_Process_Logic_MERC__c) {
				meetingsToProcess.add(meeting);
			}
		}

		List<Meeting_Participant_MERC__c> participantsToProcess = new List<Meeting_Participant_MERC__c>();

		for (Meeting_Participant_MERC__c participant : [SELECT Id,
			  												   Evaluate_Meeting_Process_Logic_MERC__c
			  										      FROM Meeting_Participant_MERC__c
			  										     WHERE Meeting_MERC__c IN :meetingsToProcess])
		{
			participant.Evaluate_Meeting_Process_Logic_MERC__c = true;
			participantsToProcess.add(participant);
		}

		//Update the participants to trigger the evaluation of any Meeting Process Logic which may apply
		update participantsToProcess;
	}

	/* Iterate over the particpants in the trigger an determine which ones need to be evaluated against
	   Meeting Process Logic then apply any matching logic*/
	private void handleMeetingParticipants() {
		System.debug('##### In the Meeting Process Logic Handler for Meeting Participants.');

		Map<String, Meeting_Process_Logic_MERC__c> logicRecords = getLogicRecords('MERC_Meeting_Participant', 'Meeting_Participant_Key_MERC__c');

		List<Meeting_Participant_MERC__c> participantsToProcess = new List<Meeting_Participant_MERC__c>();
		for (Meeting_Participant_MERC__c mp : (List<Meeting_Participant_MERC__c>) Trigger.new) {
			if (mp.Evaluate_Meeting_Process_Logic_MERC__c) {
				participantsToProcess.add(mp);
			}
		}
		System.debug('##### participantsToProcess are ' + participantsToProcess);

		//Get the participants with all of the children processes
		Map<Id, Meeting_Participant_MERC__c> participantsWithProcesses
			= new Map<Id, Meeting_Participant_MERC__c>(
				[SELECT Id, Account_Name_MERC__c,
					   (SELECT Id, Process_Type_MERC__c FROM Meeting_Processes__r)
		           FROM Meeting_Participant_MERC__c
		  	      WHERE Id IN :participantsToProcess]);

		//Get the process Ids to be used to query on
		List<Meeting_Process_MERC__c> processes = new List<Meeting_Process_MERC__c>();
		for (Meeting_Participant_MERC__c participant : participantsWithProcesses.values()) {
			processes.addAll(participant.Meeting_Processes__r);
		}

		//build a map of process Ids to a list of tasks for that process
		Map<Id, List<Meeting_Tasks_MERC__c>> processesIdToTasks = new Map<Id, List<Meeting_Tasks_MERC__c>>();
		for (Meeting_Process_MERC__c process : [SELECT Id,
			                                           (SELECT Id,
			                                           	       Task_Status_MERC__c,
			                                           	       Meeting_Process_MERC__c,
			                                           	       Meeting_Process_MERC__r.Number_of_Follow_Up_Tasks_MERC__c
			                                           	  FROM Meeting_Tasks__r)
			                                      FROM Meeting_Process_MERC__c
			                                     WHERE Id IN :processes]) {
			processesIdToTasks.put(process.Id, process.Meeting_Tasks__r);
		}

		// Meeting Participant updates can span new processes or updates to tasks in existing processes. both handled here
		//these two lists will be passed into evaluations to be populated. They will be inserted/upserted at the end of this method
		List<Meeting_Process_MERC__c> insertableMeetingProcesses = new List<Meeting_Process_MERC__c>();
		List<Meeting_Tasks_MERC__c>   upsertableTasks            = new List<Meeting_Tasks_MERC__c>();

		//we now have two Maps which will allow us to navigate from meeting participant to Meeting tasks. Process the participants
		for (Meeting_Participant_MERC__c participant : participantsToProcess) {

			if (logicRecords.containsKey(participant.Meeting_Process_Logic_Key_MERC__c)) {

				//get the logic record that matches
				Meeting_Process_Logic_MERC__c logicRecord = logicRecords.get(participant.Meeting_Process_Logic_Key_MERC__c);

				//evaluate whether a new process is needed
				if (String.isNotBlank(logicRecord.New_Process_MERC__c)) {
					insertableMeetingProcesses.add(
						new Meeting_Process_MERC__c(Name = participant.Account_Name_MERC__c + ' - ' + logicRecord.New_Process_MERC__c,
													Process_Type_MERC__c        = logicRecord.New_Process_MERC__c,
					                                Meeting_Participant_MERC__c = participant.id)
					);
				}

				//iterate over the processes and find the one that matches the logic record
				Meeting_Process_MERC__c currentProcess;
				for (Meeting_Process_MERC__c process : participantsWithProcesses.get(participant.Id).Meeting_Processes__r) {
					if (process.Process_Type_MERC__c == logicRecord.Process_MERC__c) {
						currentProcess = process;
						break;
					}
				}

				if (currentProcess != null) {
					for (Meeting_Tasks_MERC__c task : processesIdToTasks.get(currentProcess.Id)) {
						if (String.isNotBlank(logicRecord.Update_Task_Status_From_MERC__c) && task.Task_Status_MERC__c == logicRecord.Update_Task_Status_From_MERC__c) {

							//This will modify the value passed by reference
							evaluateExistingTask(task, logicRecord);

							upsertableTasks.add(task);
							if (logicRecord.Create_New_Task_MERC__c) {
								upsertableTasks.add(
									createNewTask(logicRecord,
										          currentProcess.Id,
										          task.Meeting_Process_MERC__r.Number_of_Follow_Up_Tasks_MERC__c,
										          task.Completed_Date_MERC__c));
							}
						} else if (logicRecord.Create_New_Task_MERC__c) {
							upsertableTasks.add(createNewTask(logicRecord, currentProcess.Id));
						}
					}
				}
			}
		}
		insert insertableMeetingProcesses;
		upsert upsertableTasks;

		rollupMeetingParticipants(participantsWithProcesses.keySet());
	}


	/* This method iterates over the Meeting Processes in the trigger an determines which ones need to be evaluated against
	   Meeting Process Logic then applies that logic. The only logic that will be applied is when a new process needs to be created.*/
	private void handleMeetingProcesses() {
		System.debug('##### In the Meeting Process Logic Handler for Meeting Processes.');

		Map<String, Meeting_Process_Logic_MERC__c> logicRecords = getLogicRecords('MERC_Meeting_Process', 'Meeting_Process_Key_MERC__c');
		List<Meeting_Tasks_MERC__c> newTasks = new List<Meeting_Tasks_MERC__c>();
		Set<Id> participantIds = new Set<Id>();

		for (Meeting_Process_MERC__c process : (List<Meeting_Process_MERC__c>)Trigger.new) {
			if (logicRecords.containsKey(process.Meeting_Process_Logic_Key_MERC__c )) {
				Meeting_Process_Logic_MERC__c logicRecord = logicRecords.get(process.Meeting_Process_Logic_Key_MERC__c );
				if (logicRecord.Create_New_Task_MERC__c) {
					Date relativeDate;
					//if the relative date field is defined on the logic use that api name to retrieve the value
					if (String.isNotBlank(logicRecord.New_Task_Due_Date_Relative_to_MERC__c)) {
						try {
							relativeDate = (Date)process.get(logicRecord.New_Task_Due_Date_Relative_to_MERC__c);
						} catch (exception ex) {
							//just catching the error here. We will pass null to createNewTask
						}
					}
					Meeting_Tasks_MERC__c task = createNewTask( logicRecord, process.Id, 0, relativeDate);
					newTasks.add( task );
					participantIds.add(process.Meeting_Participant_MERC__c);
				}
			}
		}

		insert newTasks;

		rollupMeetingParticipants(participantIds);
	}

	private void handleMeetingTasks() {
		System.debug('##### In the Meeting Process Logic Handler for Meeting Tasks.');

		Map<String, Meeting_Process_Logic_MERC__c> logicRecords = getLogicRecords('MERC_Meeting_Task', 'Meeting_Task_Key_MERC__c');
		Set<Id> participantIds = new Set<Id>();

		//handle existing records in the before trigger and new records in the after trigger
		if (Trigger.isBefore) {
			List<Meeting_Tasks_MERC__c> evaluatedTasks = new List<Meeting_Tasks_MERC__c>();
			Set<Id> reminderTaskProcessIds = new Set<Id>();
			for (Meeting_Tasks_MERC__c task : (List<Meeting_Tasks_MERC__c>)Trigger.new) {
				if (task.Is_Follow_Up__c) {
					reminderTaskProcessIds.add(task.Meeting_Process_MERC__c);
				}
				if (logicRecords.containsKey(task.Meeting_Process_Logic_Key_MERC__c)) {
					System.debug('##### Matched logic Record ' + logicRecords.get(task.Meeting_Process_Logic_Key_MERC__c).id);
					evaluateExistingTask(task, logicRecords.get(task.Meeting_Process_Logic_Key_MERC__c));
					evaluatedTasks.add(task);
				}
			}

			//for the evaluated tasks, retrieve their related participant ids
			for (Meeting_Tasks_MERC__c task : [SELECT Is_Follow_Up__c,
													  Meeting_Process_MERC__c,
							                          Meeting_Process_MERC__r.Meeting_Participant_MERC__c
				                                 FROM Meeting_Tasks_MERC__c
				                                WHERE Id IN :evaluatedTasks])
			{
				participantIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
			}

			if (trigger.isInsert) {
				//Figure out whether the tasks need to be updated to Unresponsive. A follow up task is unresponive
				//when the prior three tasks were follow-ups and the current task is a follow up
				Map<Id,Meeting_Process_MERC__c> processesWithTasks = new Map<Id, Meeting_Process_MERC__c>(
					[SELECT Id,Max_Non_Followup_Completed_Date_MERC__c,
					       (SELECT Id, Is_Follow_Up__c
					       	  FROM Meeting_Tasks__r
					      ORDER BY CreatedDate DESC)
					  FROM Meeting_Process_MERC__c
				      WHERE Id IN :reminderTaskProcessIds]
				);

				for (Meeting_Tasks_MERC__c task : (List<Meeting_Tasks_MERC__c>)Trigger.new) {

					if (!task.Is_Follow_Up__c) {
						continue;
					}
					Decimal taskCounter = 0;
					if (processesWithTasks.containsKey(task.Meeting_Process_MERC__c)) {
						Meeting_Process_MERC__c process = processesWithTasks.get(task.Meeting_Process_MERC__c);
						for (Meeting_Tasks_MERC__c processTask : process.Meeting_Tasks__r) {
							if (processTask.Is_Follow_Up__c) {
								taskCounter++;
							} else {
								break;
							}
						}
					}
					if (taskCounter >= 3) {
						task.Name = 'Unresponsive - Escalate to Business';
						task.Is_Follow_Up__c = false;
					}
				}
			}
		} else {
			//list that will be populated by the method it is passed to
			List<Meeting_Tasks_MERC__c> insertableTasks = new List<Meeting_Tasks_MERC__c>();

			//requery tasks in order to get necessary information to pass to createNewTask method
			List<Meeting_Tasks_MERC__c> tasks = [SELECT Id,
			                                            Meeting_Process_MERC__c,
			                                            Meeting_Process_MERC__r.Number_of_Follow_Up_Tasks_MERC__c,
			                                            Meeting_Process_MERC__r.Meeting_Participant_MERC__c,
			                                            Completed_Date_MERC__c,
			                                            Meeting_Process_Logic_Key_MERC__c
			                                       FROM Meeting_Tasks_MERC__c
			                                      WHERE Id IN :Trigger.new];

			for (Meeting_Tasks_MERC__c task : tasks) {
				if (logicRecords.containsKey(task.Meeting_Process_Logic_Key_MERC__c)) {
					System.debug('##### Matched logic Record ' + logicRecords.get(task.Meeting_Process_Logic_Key_MERC__c).id);
					Meeting_Process_Logic_MERC__c logicRecord = logicRecords.get(task.Meeting_Process_Logic_Key_MERC__c);
					if (logicRecord.Create_New_Task_MERC__c) {
						insertableTasks.add(
							createNewTask(logicRecord,
								          task.Meeting_Process_MERC__c,
								          task.Meeting_Process_MERC__r.Number_of_Follow_Up_Tasks_MERC__c,
								          task.Completed_Date_MERC__c)
						);
					}
					participantIds.add(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
				}
			}

			insert insertableTasks;
		}
		rollupMeetingParticipants(participantIds);
	}

	private void handleTravelItineraries() {
		System.debug('##### In the Meeting Process Logic Handler for Travel Itineraries.');
		if (Trigger.isInsert || Trigger.isBefore) {
			return;
		}

		Set<Id> meetingParticipantIds = new Set<Id>();
		for (Travel_Itinerary_MERC__c ti : (List<Travel_Itinerary_MERC__c>)Trigger.new) {
			if (ti.Evaluate_Meeting_Process_Logic_MERC_c__c) {
				meetingParticipantIds.add(ti.Meeting_Participant_MERC__c);
			}
		}

		if (meetingParticipantIds.isEmpty()) {
			return;
		}
		System.debug('##### Meeting Participant Ids: ' + meetingParticipantIds);
		Map<Id, List<Meeting_Tasks_MERC__c>> meetingParticipantIdToTravelTasks = new Map<Id, List<Meeting_Tasks_MERC__c>>();
		for (Meeting_Process_MERC__c process : [SELECT Id, Meeting_Participant_MERC__c,
			                                           (SELECT Id,
			                                           	       Task_Status_MERC__c,
			                                           	       Meeting_Process_MERC__c,
			                                           	       Meeting_Process_MERC__r.Number_of_Follow_Up_Tasks_MERC__c
			                                           	  FROM Meeting_Tasks__r)
			                                      FROM Meeting_Process_MERC__c
			                                     WHERE Meeting_Participant_MERC__c IN :meetingParticipantIds
			                                       AND Process_Type_MERC__c = 'Travel Proposal'])
		{
			meetingParticipantIdToTravelTasks.put(process.Meeting_Participant_MERC__c, process.Meeting_Tasks__r);
		}

		Map<Id, Meeting_Participant_MERC__c> participantsWithAccountName = new Map<Id, Meeting_Participant_MERC__c>(
			[SELECT Id, Account_Name_MERC__c FROM Meeting_Participant_MERC__c WHERE Id IN :meetingParticipantIds]
		);

		Map<Id, Meeting_Participant_MERC__c> participantInfo = new Map<Id, Meeting_Participant_MERC__c>(
			[SELECT Id, Account_Name_MERC__c FROM Meeting_Participant_MERC__c WHERE Id IN :meetingParticipantIds]
		);

		Map<String, Meeting_Process_Logic_MERC__c> logicRecords = getLogicRecords('MERC_Travel_Proposal', 'Travel_Proposal_Key_MERC__c');

		//List for new processes
		List<Meeting_Process_MERC__c> insertableMeetingProcesses = new List<Meeting_Process_MERC__c>();
		//set for new or updated tasks. Using a set in case the same task gets triggered by multiple rules. This
		//shouldn't happen but if something goes wrong with the workflows that trigger changes it could.
		Set<Meeting_Tasks_MERC__c> upsertableTasks = new Set<Meeting_Tasks_MERC__c>();

		//iterate over the itineraries in the trigger
		for (Travel_Itinerary_MERC__c ti : (List<Travel_Itinerary_MERC__c>)Trigger.new) {
			//if a logic record matches the current key
			if (logicRecords.containsKey(ti.Meeting_Process_Logic_Key_MERC__c)) {
				//get the logic record
				Meeting_Process_Logic_MERC__c logicRecord = logicRecords.get(ti.Meeting_Process_Logic_Key_MERC__c);

				//if a new process needs to be created
				if (logicRecord.Create_New_Process_MERC__c) {
					insertableMeetingProcesses.add(
						new Meeting_Process_MERC__c(Name = participantsWithAccountName.get(ti.Meeting_Participant_MERC__c).Account_Name_MERC__c + ' - ' + logicRecord.New_Process_MERC__c,
													Process_Type_MERC__c        = logicRecord.New_Process_MERC__c,
					                                Meeting_Participant_MERC__c = ti.Meeting_Participant_MERC__c)
					);
				}
				//if an update to an existing task needs to be made
				if (logicRecord.Update_Existing_Task_MERC__c) {
					System.debug('##### logicRecord is: ' + logicRecord);
					//if the logicRecord.Update_Task_Status_From_MERC__c is populated we are updating a closed task, otherwise we are updating incomplete tasks
					String statusToFind = String.isNotBlank(logicRecord.Update_Task_Status_From_MERC__c) ? logicRecord.Update_Task_Status_From_MERC__c : 'Incomplete';
					if (meetingParticipantIdToTravelTasks.containsKey(ti.Meeting_Participant_MERC__c)) {

						//iterate over the travel proposal tasks for this participant that were queried earlier
						List<Meeting_Tasks_MERC__c> travelProposalTasks = meetingParticipantIdToTravelTasks.get(ti.Meeting_Participant_MERC__c);
						for (Meeting_Tasks_MERC__c task : travelProposalTasks) {

							//use startsWith because incomplete tasks will start with inocmplete
							if (task.Task_Status_MERC__c.startsWith(statusToFind)) {
								System.debug('##### Task is: ' + task);
								evaluateExistingTask(task, logicRecord);
								upsertableTasks.add(task);
							}
						}
					}
				}
			}
		}
		insert insertableMeetingProcesses;
		upsert new List<Meeting_Tasks_MERC__c>(upsertableTasks);

		rollupMeetingParticipants(meetingParticipantIds);
	}

	/*
		Parameters
			@recordType : The name of the record type to filter records on
			@keyField   : The field to use as the key for the returned Map
		Returns:
			A map from a key to the logic object
	*/
	private Map<String, Meeting_Process_Logic_MERC__c> getLogicRecords(String recordType, String keyField) {
		////Get the correct record type
		//RecordType logicRecordType = [SELECT Id
		//                                FROM RecordType
		//                               WHERE DeveloperName = :recordType
		//                                 AND SObjectType = 'Meeting_Process_Logic_MERC__c'
		//                               LIMIT 1];

		//declare the map which will be returned
		Map<String, Meeting_Process_Logic_MERC__c> logicKeyMap = new Map<String, Meeting_Process_Logic_MERC__c>();

		if (meetingProcessLogicRecordsByType == null) {
			meetingProcessLogicRecordsByType = new Map<String, List<Meeting_Process_Logic_MERC__c>>();
			//create a new set of strings to hold the field names which need to be queried
			Set<String> fieldsToQueryFor = new Set<String>{'RecordType.DeveloperName'};

			//add all of the fieldpaths from the Process Logic Handler Fields fieldset to the fieldsToQueryFor set
			for (Schema.FieldSetMember fsm : SObjectType.Meeting_Process_Logic_MERC__c.FieldSets.Process_Logic_Handler_Fields_MERC.getFields()) {
				fieldsToQueryFor.add(fsm.getFieldPath());
			}

			//create the string of fields to query for
			String fieldsToQueryString = '';
			for (String field : fieldsToQueryFor) {
				fieldsToQueryString += field + ',';
			}

			//retieve the Meeting Process Logic records and add them to the map
			for (Meeting_Process_Logic_MERC__c mpl : database.Query('SELECT ' + fieldsToQueryString.removeEnd(',') + ' FROM Meeting_Process_Logic_MERC__c')) {
				if (meetingProcessLogicRecordsByType.containsKey(mpl.RecordType.DeveloperName)) {
					meetingProcessLogicRecordsByType.get(mpl.RecordType.DeveloperName).add(mpl);
				} else {
					meetingProcessLogicRecordsByType.put(mpl.RecordType.DeveloperName, new List<Meeting_Process_Logic_MERC__c>{mpl});
				}
			}
		}

		if (meetingProcessLogicRecordsByType.containsKey(recordType)) {
			for (Meeting_Process_Logic_MERC__c mpl : meetingProcessLogicRecordsByType.get(recordType)) {
				logicKeyMap.put((String)mpl.get(keyField), mpl);
			}
		}
		return logicKeyMap;
	}

	private void evaluateExistingTask(Meeting_Tasks_MERC__c task, Meeting_Process_Logic_MERC__c logicRecord) {
		//check for status update
		if (String.isNotBlank(logicRecord.Update_Task_Status_To_MERC__c)) {
			task.Task_Status_MERC__c = logicRecord.Update_Task_Status_To_MERC__c;
		}
		//check for name update
		if (String.isNotBlank(logicRecord.Update_Task_Name_To_MERC__c)) {
			task.Name = logicRecord.Update_Task_Name_To_MERC__c;
			task.Is_Follow_Up__c = task.Name.startsWith('Reminder');
		}
		//check for completed date update
		if (String.isNotBlank(logicRecord.Update_Task_Completed_Date_To_MERC__c)) {
			if (logicRecord.Update_Task_Completed_Date_To_MERC__c == 'Null') {
				task.Completed_Date_MERC__c = null;
			} else if (logicRecord.Update_Task_Completed_Date_To_MERC__c == 'Today') {
				if (task.Completed_Date_MERC__c == null) {
					task.Completed_Date_MERC__c = Date.today();
				}
			}
		}
		if (logicRecord.Update_Task_Due_Date_To_Today_Plus_MERC__c != null) {
			task.Due_Date_MERC__c = Date.today().addDays(Integer.valueOf(logicRecord.Update_Task_Due_Date_To_Today_Plus_MERC__c));
		}
	}

	private Meeting_Tasks_MERC__c createNewTask(Meeting_Process_Logic_MERC__c logicRecord, Id processId) {
		return createNewTask(logicRecord, processId, 0, null);
	}

	private Meeting_Tasks_MERC__c createNewTask(Meeting_Process_Logic_MERC__c logicRecord, Id processId, Decimal numFollowups, Date relativeDate) {
		//create new task linked to the process
		Meeting_Tasks_MERC__c newTask = new Meeting_Tasks_MERC__c(Meeting_Process_MERC__c = processId, Task_Status_MERC__c='Incomplete');

		//Set the task name
		newTask.Name = logicRecord.New_Task_Name_MERC__c;
		//overwrite with "Reminder" logic if necessary
		if (newTask.Name.startsWith('Reminder')) {
			newTask.Name = 'Reminder ' + String.valueOf(numFollowUps + 1);
			newTask.Is_Follow_Up__c = true;
		}

		//set the due date. If relative date supplied use that as start point, otherwise use today as start point
		newTask.Due_Date_MERC__c = relativeDate != null ? relativeDate : Date.today();
		Integer dateDifferntial = Integer.valueOf(logicRecord.New_Task_Due_Date_Days_MERC__c);

		if (String.isNotBlank(logicRecord.New_Due_Date_Direction_MERC__c) && logicRecord.New_Due_Date_Direction_MERC__c == 'Before') {
			dateDifferntial = dateDifferntial * -1;
		}

		newTask.Due_Date_MERC__c = newTask.Due_Date_MERC__c.addDays(dateDifferntial);

		return newTask;
	}

	/* This method is used to roll up the current process for each meeting participant and stamp it*/
	@future
	private static void rollupMeetingParticipants(Set<Id> participantIds) {
		//retrieve the meeting participants and the applicable fields
		List<Meeting_Participant_MERC__c> participants = [SELECT Id,
														         Current_Process_MERC__c,
														         Process_State_MERC__c,
														         Current_Task_Name_MERC__c,
														         Current_Task_Due_Date_MERC__c,
														         (SELECT Id FROM Meeting_Processes__r)
														   FROM Meeting_Participant_MERC__c
														  WHERE Id IN :participantIds];

		//gather up the meeting process ids for the meeting participants
		Set<Id> processIds = new Set<Id>();
		for (Meeting_Participant_MERC__c mp : participants) {
			for (Meeting_Process_MERC__c mpl : mp.Meeting_Processes__r) {
				processIds.add(mpl.id);
			}
		}

		//loop over the open tasks and find the "lowest" due date for each meeting participant and the
		//"latest" completed date for each participant
		Map<Id, Meeting_Tasks_MERC__c> participantToOldestDueDate = new Map<Id, Meeting_Tasks_MERC__c>();
		Map<Id, Meeting_Tasks_MERC__c> participantToLatestCompletedDate = new Map<Id, Meeting_Tasks_MERC__c>();
		for (Meeting_Tasks_MERC__c task : [SELECT Name,
			                                      Due_Date_MERC__c,
			                                      Completed_Date_MERC__c,
			                                      Open_Task_MERC__c,
												  Meeting_Process_MERC__r.Meeting_Participant_MERC__c,
			                                      Meeting_Process_MERC__r.Process_Type_MERC__c,
			                                      Meeting_Process_MERC__r.Process_Status_MERC__c
			                                 FROM Meeting_Tasks_MERC__c
			                                WHERE Meeting_Process_MERC__c IN :processIds])
		{
			if (task.Open_Task_MERC__c) {
				if (participantToOldestDueDate.containsKey(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c)) {
					Meeting_Tasks_MERC__c existingTask = participantToOldestDueDate.get(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
					//replace the task in the map if the task has a lower due date than the one in the map
					if (task.Due_Date_MERC__c < existingTask.Due_Date_MERC__c) {
						participantToOldestDueDate.put(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c, task);
					}
				} else {
					//first task for the participant so just add it to the list as the lowest due date
					participantToOldestDueDate.put(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c, task);
				}
			} else {
				if(participantToLatestCompletedDate.containsKey(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c)) {
					Meeting_Tasks_MERC__c existingTask = participantToLatestCompletedDate.get(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c);
					//replace the task in the map if the task has a lower due date than the one in the map
					if (task.Completed_Date_MERC__c > existingTask.Completed_Date_MERC__c) {
						participantToLatestCompletedDate.put(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c, task);
					}
				} else {
					participantToLatestCompletedDate.put(task.Meeting_Process_MERC__r.Meeting_Participant_MERC__c, task);
				}
			}
		}

		//for each of the participants, if there is a "youngest"
		List<Meeting_Participant_MERC__c> participantsToUpdate = new List<Meeting_Participant_MERC__c>();
		for (Meeting_Participant_MERC__c participant : participants) {
			Meeting_Tasks_MERC__c task;

			if (participantToOldestDueDate.containsKey(participant.id)) {
				task = participantToOldestDueDate.get(participant.id);
				participant.Current_Task_Name_MERC__c = task.Name;
				participant.Current_Task_Due_Date_MERC__c = task.Due_Date_MERC__c;
			} else if (participantToLatestCompletedDate.containsKey(participant.id)){
				task = participantToLatestCompletedDate.get(participant.id);
				participant.Current_Task_Name_MERC__c = '';
				participant.Current_Task_Due_Date_MERC__c = null;
			}

			if (task != null) {
				participant.Current_Process_MERC__c = task.Meeting_Process_MERC__r.Process_Type_MERC__c;
				participant.Process_State_MERC__c = task.Meeting_Process_MERC__r.Process_Status_MERC__c;
				participantsToUpdate.add(participant);
			}
		}

		MERC_TriggerHandlerStateManager.deactivateAll();
		update participantsToUpdate;
		MERC_TriggerHandlerStateManager.activateAll();
	}
}