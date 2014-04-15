/**
 * @author Joseph Ferraro
 *
 * Controller for VF Page that enables users to manage Meeting Team via unified UI
 */

public with sharing class MERC_MeetingTeamManagerController extends GLBL_GenericRelatedListController {
	/*----  Search Fields & Dummy Account to capture input -----*/
	public String  firstName      { get; set; }
	public String  lastName       { get; set; }
	public Account searchAccount  { get; set; }
	public String  searchForUsers { get; set; } //indicates the search will ony be for field users

	/*----- dummy team member for the set access picklist -----*/
	public Team_Member_MERC__c dummyMember { get; set; }

	public List<SearchResult> searchResults { get; set; }

	private final Id employeeRecordTypeId = [SELECT Id
	                                           FROM RecordType
	                                          WHERE SObjectType = 'Account'
	                                            AND DeveloperName='Employee_GLBL' LIMIT 1].Id;
	@TestVisible private static final Id externalUsersRecordTypeId = [SELECT Id
	                                                                    FROM RecordType
	                                                                   WHERE SObjectType = 'Team_Member_MERC__c'
	                                                                     AND DeveloperName ='External_User_MERC' LIMIT 1].Id;

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

		searchAccount  = new Account(RecordTypeId=employeeRecordTypeId);
		searchResults  = new List<SearchResult>();
		dummyMember    = new Team_Member_MERC__c();
		searchForUsers = 'field';
	}

	public override PageReference add() {
		String recordTypeId                   = [SELECT ID FROM RecordType WHERE DeveloperName = :recordTypeDeveloperNameParam].ID;
		GenericSobjectWrapper newItem         = new GenericSobjectWrapper(new Team_Member_MERC__c(RecordTypeId=recordTypeId));
		newItem.index                         = children.size()+1;
		List<GenericSobjectWrapper> addToList = childrenMap.get(recordTypeDeveloperNameParam);
		addToList.add(newItem);
		return null;
	}

	public void addSelected() {
		for (SearchResult sr : searchResults) {
			if (sr.selected) {
				GenericSobjectWrapper newItem = new GenericSobjectWrapper(sr.member);
				newItem.index = children.size()+1;
				children.add(newItem);
				List<GenericSobjectWrapper> addToList = childrenMap.get('External_User_MERC');
				addToList.add(newItem);
			}
		}
		save();
		doSearch();
	}

	public List<SelectOption> getRadioOptions() {
		return new List<SelectOption> { new SelectOption('field','Field Users'), new SelectOption('all', 'All Users') };
	}

	public void doSearch() {
		searchResults.clear();

		Set<Id> existingTeamMemberAccountIds = new Set<Id>();
    	for(GenericSobjectWrapper member : childrenMap.get('External_User_MERC')) {
    		existingTeamMemberAccountIds.add(((Team_Member_MERC__c)member.so).Account_MERC__c);
    	}

		for (Account a: Database.query(buildAccountQueryString()))
    	{
    		/*----- only add accounts to search results that aren't already team members -----*/
    		if (!existingTeamMemberAccountIds.contains(a.Id))
    		{
    			searchResults.add( new SearchResult(a));
    		}
    	}
	}

	private String buildAccountQueryString()
    {

    	String queryString = 'SELECT Id';

    	for (String s : MERC_Util.getFieldSetFieldList('Account', new List<String>{'Meeting_Team_Manager_Mass_Add'})) {
    		queryString += ', ' + s;
    	}

    	/*----- only ever search for employees -----*/
    	queryString += ' FROM Account WHERE RecordTypeId = \'' + employeeRecordTypeId + '\'';

    	/*----- decide which search terms were entered and build the query appropriately -----*/
    	queryString += String.isNotBlank(firstName) ? ' AND FirstName LIKE \'' + firstName + '%\'' : '';
    	queryString += String.isNotBlank(lastName ) ? ' AND LastName LIKE \''  + lastName  + '%\'' : '';
    	queryString += String.isNotBlank(searchAccount.PersonEmail) ? ' AND PersonEmail=\'' + searchAccount.PersonEmail + '\'' : '';
    	queryString += String.isNotBlank(searchAccount.Country_of_Residence_GLBL__c) ? ' AND Country_of_Residence_GLBL__c=:searchAccount.Country_of_Residence_GLBL__c' : '';
    	queryString += String.isNotBlank(searchAccount.Territory_Id_GLBL__c) ? ' AND Territory_Id_GLBL__c LIKE \'%' + searchAccount.Territory_Id_GLBL__c + '%\'' : '';
    	queryString += String.isNotBlank(searchAccount.Trtry_Cd_GLBL__c) ? ' AND Trtry_Cd_GLBL__c LIKE \'%' + searchAccount.Trtry_Cd_GLBL__c + '%\'' : '';
    	queryString += String.isNotBlank(searchAccount.Trtry_Desc_GLBL__c) ? ' AND Trtry_Desc_GLBL__c LIKE \'%' + searchAccount.Trtry_Desc_GLBL__c + '%\'' : '';

    	/*----- return only field employees (defined as having a territory)? -----*/
    	queryString += searchForUsers == 'field' ? ' AND Territory_Id_GLBL__c != null' : '';

    	System.debug('\n\n\n### queryString is: ' + queryString + '\n\n\n');

    	return queryString;
    }

    public class SearchResult
    {
    	public Account acct               { get; set; }
    	public Team_Member_MERC__c member { get; set; }
    	public Boolean selected           { get; set; }

    	public SearchResult(Account a)
    	{
			this.acct     = a;
			this.selected = false;
			/*----- it is assumed that a new SearchResult will not be created for employees
			that are already team members so we create a new team member -----*/
			this.member   = new Team_Member_MERC__c( Access_MERC__c ='Can Add Attendees'
								                   , RecordTypeId=MERC_MeetingTeamManagerController.externalUsersRecordTypeId
								                   , Account_MERC__c = a.Id
								                   , Attendee_Invite_Limit_MERC__c = 1);
		}

    }
}