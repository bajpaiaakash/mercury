/**
 * @author Kyle Thornton
 *
 * This utility is implemented without sharing in order to bypass restrictions where a salesforce
 * user cannot create a share record for somebody higher than them in the role hierarchy.
 *
 * By implmenting as @future and without sharing we effectively run this in system mode
 *
 * both methods accepted a JSON serialized string representing a list of Meeting_MERC_Share records
 **/


public without sharing class MERC_TeamMemberShareHandlerUtility {

	@future
	public static void insertShareRecords(String shareRecordsString) {
		Type t = Type.forName('List<Meeting_MERC__Share>');
		List<SObject> shareRecordsToInsert = (List<SObject>)JSON.deserialize(shareRecordsString, t);
		System.debug('\n\n\nshareRecordsToInsert: ' + shareRecordsToInsert);
		insert shareRecordsToInsert;
	}

	@future
	public static void deleteShareRecords(String shareRecordsString) {
		Type t = Type.forName('List<Meeting_MERC__Share>');
		List<SObject> shareRecordsToDelete = (List<SObject>)JSON.deserialize(shareRecordsString, t);
		System.debug('\n\n\nshareRecordsToDelete: ' + shareRecordsToDelete);
		delete shareRecordsToDelete;
	}
}