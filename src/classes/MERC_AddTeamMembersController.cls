public with sharing class MERC_AddTeamMembersController {

	/*----  Search Fields & Dummy Account to capture input -----*/
	public Account searchAccount  { get; set; }
	public Boolean onlyFieldUsers { get; set; } //indicates the search will ony be for field users

	public List<SearchResult> searchResults = new List<SearchResult>();

	/*----- The meeting passed in the id param -----*/
	private final Meeting_MERC__c meeting;

	private final Id employeeRecordTypeId = [SELECT Id
	                                           FROM RecordType
	                                          WHERE SObjectType = 'Account'
	                                            AND DeveloperName='Employee_GLBL' LIMIT 1].Id;
	@TestVisible private static final Id externalUsersRecordTypeId = [SELECT Id
	                                                                    FROM RecordType
	                                                                   WHERE SObjectType = 'Team_Member_MERC__c'
	                                                                     AND DeveloperName='External_User_MERC' LIMIT 1].Id;


    /*----- The extension constructor initializes the private member variable
             meeting by using the getRecord method from the standard controller. -----*/
    public MERC_AddTeamMembersController(ApexPages.StandardController stdController) {
        meeting = (Meeting_MERC__c)stdController.getRecord();
        searchAccount = new Account(RecordTypeId = [Select ID From RecordType Where SObjectType = 'Account' and DeveloperName = 'Employee_GLBL'].ID);
        onlyFieldUsers = true;
    }

    public void performSearch()
    {
    	searchResults.clear();
    	String queryString = buildAccountQueryString();

    	Set<Id> existingTeamMemberAccountIds = new Set<Id>();
    	for(Team_Member_MERC__c member : existingTeamMembers) {
    		existingTeamMemberAccountIds.add(member.Account_MERC__c);
    	}

    	for (Account a: Database.query(queryString))
    	{
    		/*----- only add accounts to search results that aren't already team members -----*/
    		if (!existingTeamMemberAccountIds.contains(a.Id))
    		{
    			searchResults.add( new SearchResult(a));
    		}
    	}
    }

    private List<Team_Member_MERC__c> existingTeamMembers {
    	get {
    		/*----- This list can easily change so we want to
    		        always return the most up to date list -----*/
    		return [SELECT Id, Account_MERC__c FROM Team_Member_MERC__c WHERE Meeting_MERC__c =:meeting.id];
    	}
    }

    private String buildAccountQueryString()
    {
    	String queryString = 'SELECT Id';
    	/*----- only ever search for employees? -----*/
    	queryString += ' FROM Account WHERE RecordTypeId = :employeeRecordTypeId';

    	/*----- decide which search terms were entered and build the query appropriately -----*/
    	queryString += String.isNotBlank(searchAccount.FirstName) ? ' AND FirstName LIKE \'' + searchAccount.FirstName + '%\'' : '';
    	queryString += String.isNotBlank(searchAccount.LastName ) ? ' AND LastName LIKE \''  + searchAccount.LastName  + '%\'' : '';
    	queryString += String.isNotBlank(searchAccount.PersonEmail) ? ' AND PersonEmail=\'' + searchAccount.PersonEmail + '\'' : '';
    	queryString += String.isNotBlank(searchAccount.Country_of_Residence_GLBL__c) ? ' AND Country_of_Residence_GLBL__c=:searchAccount.Country_of_Residence_GLBL__c' : '';
    	queryString += String.isNotBlank(searchAccount.Territory_Id_GLBL__c) ? ' AND Territory_Id_GLBL__c LIKE \'%' + searchAccount.Territory_Id_GLBL__c + '%\'' : '';
    	queryString += String.isNotBlank(searchAccount.Trtry_Cd_GLBL__c) ? ' AND Trtry_Cd_GLBL__c LIKE \'%' + searchAccount.Trtry_Cd_GLBL__c + '%\'' : '';
    	queryString += String.isNotBlank(searchAccount.Trtry_Desc_GLBL__c) ? ' AND Trtry_Desc_GLBL__c LIKE \'%' + searchAccount.Trtry_Desc_GLBL__c + '%\'' : '';

    	/*----- return only field employees (defined as having a territory)? -----*/
    	queryString += onlyFieldUsers ? ' AND Territory_Id_GLBL__c != null' : '';

    	System.debug('\n\n\n### queryString is: ' + queryString + '\n\n\n');

    	return queryString;
    }

    public class SearchResult
    {
    	public Account acct               { get; private set; }
    	public Team_Member_MERC__c member { get; set; }
    	public Boolean selected           { get; set; }

    	public SearchResult(Account a)
    	{
			this.acct     = a;
			this.selected = false;
			/*----- it is assumed that a new SearchResult will not be created for employees
			that are already team members so we create a new team member -----*/
			this.member   = new Team_Member_MERC__c(Access_MERC__c ='Can Add Attendees'
										            , RecordTypeId = MERC_AddTeamMembersController.externalUsersRecordTypeId);
    	}
    }
}