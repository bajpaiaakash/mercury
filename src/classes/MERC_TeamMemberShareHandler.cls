public with sharing class MERC_TeamMemberShareHandler implements GLBL_TriggerHandler.HandlerInterface {
	
	//TODO: handle modifications to record type

	public void handle() {
		if (Trigger.isInsert || Trigger.isUpdate) {
	    	execute(Trigger.new);
	   	} else if (Trigger.isDelete) {
	   		execute(Trigger.old);
	   	}
	}

	Map<Id, Set<Id>> getMeetingIdToTriggerUserIds(List<Team_Member_MERC__c> teamMembers) {
		Map<Id, Set<Id>> meetingIdToUserIds = new Map<Id, Set<Id>>();
		for (Team_Member_MERC__c m : teamMembers) {
			if (meetingIdToUserIds.containsKey(m.Meeting_MERC__c)) {
				Set<Id> existingSet = meetingIdToUserIds.get(m.Meeting_MERC__c);
				existingSet.add(m.User_MERC__c);
				meetingIdToUserIds.put(m.Meeting_MERC__c, existingSet);
			} else {
				Set<Id> newSet = new Set<Id>();
				newSet.add(m.User_MERC__c);
				meetingIdToUserIds.put(m.Meeting_MERC__c, newSet);
			}
		}
		return meetingIdToUserIds;
	}

	public void execute(list<Sobject> sobjects) {        
		Id mercuryUserRecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Mercury_User_MERC' AND SobjectType = 'Team_Member_MERC__c'].ID;
		List<Team_Member_MERC__c> teamMembers = (List<Team_Member_MERC__c>)sobjects;
		List<Team_Member_MERC__c> teamMembersToProcess = new List<Team_Member_MERC__c>();
		Set<Id> meetingIds = new Set<Id>();
		for (Team_Member_MERC__c tm : teamMembers) {
			if (tm.RecordTypeId == mercuryUserRecordTypeId) {
				teamMembersToProcess.add(tm);	
				meetingIds.add(tm.Meeting_MERC__c);
			}
		}
		Map<Id, Meeting_MERC__c> meetingMap = new Map<ID, Meeting_MERC__c>([SELECT ID, OwnerId FROM Meeting_MERC__c WHERE ID in :meetingIds]);

		if (Trigger.isInsert || Trigger.isUndelete) {
			Map<Id, Set<Id>> meetingIdToNewUserIds = getMeetingIdToTriggerUserIds(teamMembersToProcess);
			
			List<Meeting_MERC__Share> shareRecordsToInsert = new List<Meeting_MERC__Share>();
			for (Id meetingId : meetingIdToNewUserIds.keySet()) {
				Set<Id> userIdsToAddToShareTable = meetingIdToNewUserIds.get(meetingId);
				for (Id userId : userIdsToAddToShareTable) {
					if (userId != meetingMap.get(meetingId).OwnerId) {
						Meeting_MERC__Share shareRecord = new Meeting_MERC__Share();
						shareRecord.ParentId = meetingId;
						shareRecord.UserOrGroupId = userId;
						shareRecord.AccessLevel = 'Edit';
						shareRecordsToInsert.add(shareRecord);
					}
				}
			}
			insert shareRecordsToInsert;

		} else if (Trigger.isUpdate) {
			
			Map<Id, Set<Id>> meetingIdToRemovedUserIds = new Map<Id, Set<Id>>();
			Map<Id, Set<Id>> meetingIdToNewUserIds = new Map<Id, Set<Id>>();

			for (Team_Member_MERC__c m : teamMembersToProcess) {
				Id oldMapUser = (Id)Trigger.oldmap.get(m.Id).get('User_MERC__c');
				Id newMapUser = (Id)Trigger.newmap.get(m.Id).get('User_MERC__c');

				if (oldMapUser != newMapUser) {
					if (oldMapUser != null) {
						//oldmapuser needs to be removed from share table
						if (meetingIdToRemovedUserIds.containsKey(m.Meeting_MERC__c)) {
							Set<Id> existingSet = meetingIdToRemovedUserIds.get(m.Meeting_MERC__c);
							existingSet.add(oldMapUser);
							meetingIdToRemovedUserIds.put(m.Meeting_MERC__c, existingSet);
						} else {
							Set<Id> newSet = new Set<Id>();
							newSet.add(oldMapUser);
							meetingIdToRemovedUserIds.put(m.Meeting_MERC__c, newSet);
						}
					}
					if (newMapUser != null) {
						//newmapuser needs to be added to share table
						if (meetingIdToNewUserIds.containsKey(m.Meeting_MERC__c)) {
							Set<Id> existingSet = meetingIdToNewUserIds.get(m.Meeting_MERC__c);
							existingSet.add(newMapUser);
							meetingIdToNewUserIds.put(m.Meeting_MERC__c, existingSet);
						} else {
							Set<Id> newSet = new Set<Id>();
							newSet.add(newMapUser);
							meetingIdToNewUserIds.put(m.Meeting_MERC__c, newSet);
						}
					}
				}
			}

			if (meetingIdToRemovedUserIds.keySet().size() > 0) {
				List<Meeting_MERC__Share> shareRecordsToDelete = new List<Meeting_MERC__Share>();
				for (Meeting_MERC__Share share : [SELECT ID, UserOrGroupId, ParentId From Meeting_MERC__Share WHERE ParentId in :meetingIdToRemovedUserIds.keySet()]) {
					if (meetingIdToRemovedUserIds.get(share.ParentId) != null) {
						Set<Id> removedUserIds = meetingIdToRemovedUserIds.get(share.ParentId);
						if (removedUserIds.contains(share.UserOrGroupId)) {
							system.debug('DELETING FROM SHARE >>>> '+share);
							shareRecordsToDelete.add(share);
						}
					}
				}
				delete shareRecordsToDelete;
			}

			if (meetingIdToNewUserIds.keySet().size() > 0) {
				List<Meeting_MERC__Share> shareRecordsToInsert = new List<Meeting_MERC__Share>();
				for (Id meetingId : meetingIdToNewUserIds.keySet()) {
					Set<Id> userIdsToAddToShareTable = meetingIdToNewUserIds.get(meetingId);
					for (Id userId : userIdsToAddToShareTable) {
						if (userId != meetingMap.get(meetingId).OwnerId) {
							Meeting_MERC__Share shareRecord = new Meeting_MERC__Share();
							shareRecord.ParentId = meetingId;
							shareRecord.UserOrGroupId = userId;
							shareRecord.AccessLevel = 'Edit';
							system.debug('INSERTING TO SHARE >>>> '+shareRecord);

							shareRecordsToInsert.add(shareRecord);
						}
					}
				}
				insert shareRecordsToInsert;
			}

		} else if (Trigger.isDelete) {
			Map<Id, Set<Id>> meetingIdToRemovedUserIds = getMeetingIdToTriggerUserIds(teamMembersToProcess);
			
			List<Meeting_MERC__Share> shareRecordsToDelete = new List<Meeting_MERC__Share>();
			for (Meeting_MERC__Share share : [SELECT ID, UserOrGroupId, ParentId From Meeting_MERC__Share WHERE ParentId in :meetingIdToRemovedUserIds.keySet()]) {
				if (meetingIdToRemovedUserIds.get(share.ParentId) != null) {
					Set<Id> removedUserIds = meetingIdToRemovedUserIds.get(share.ParentId);
					if (removedUserIds.contains(share.UserOrGroupId)) {
						shareRecordsToDelete.add(share);
					}
				}
			}
			delete shareRecordsToDelete;
		}
		
	}

}