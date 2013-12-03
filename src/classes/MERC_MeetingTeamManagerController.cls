/**
 * @author Joseph Ferraro
 *
 * Controller for VF Page that enables users to manage Meeting Team via unified UI
 */

public with sharing class MERC_MeetingTeamManagerController extends GLBL_GenericRelatedListController {
	public MERC_MeetingTeamManagerController(ApexPages.StandardSetController controller) {
		super (
			controller, 
			'Meeting_MERC__c', 
			'Team_Member_MERC__c', 
			'Meeting_MERC__c',
			new List<String> { 'Id', 'Name' },
			MERC_Util.getFieldSetFieldList('Team_Member_MERC__c', new List<String>{'Team_External_MERC', 'Team_Mercury_MERC'}),
			new List<String> { 'External_User_MERC', 'Mercury_User_MERC' }
		);	
	}

	public override PageReference add() {
		String recordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = :recordTypeDeveloperNameParam].ID;
		GenericSobjectWrapper newItem = new GenericSobjectWrapper(new Team_Member_MERC__c(RecordTypeId=recordTypeId));
		newItem.index = children.size()+1;
		List<GenericSobjectWrapper> addToList = childrenMap.get(recordTypeDeveloperNameParam);
		addToList.add(newItem);
		return null;
	}
}