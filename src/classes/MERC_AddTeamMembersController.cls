public with sharing class MERC_AddTeamMembersController {

	/*----  Search Fields & Dummy Account ---------*/
	public String  firstName			{ get; set; }
	public String  lastName 			{ get; set; }
	public String  email 				{ get; set; }
	public Account searchAccount 		{ get; set; }
	public String  territoryCode 		{ get; set; }
	public String  territoryId 			{ get; set; }
	public String  territoryDescription { get; set; }

	public List<SearchResult> searchResults = new List<SearchResult>();

	/*-- The meeting passed in the id param --*/
	private final Meeting_MERC__c meeting;

	private final Id employeeRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName='Employee_GLBL' LIMIT 1].Id;

    /* The extension constructor initializes the private member
       variable acct by using the getRecord method from the standard
       controller.*/
    public MERC_AddTeamMembersController(ApexPages.StandardController stdController) {
        this.meeting = (Meeting_MERC__c)stdController.getRecord();
        searchAccount = new Account();
    }

    public void performSearch()
    {
    	searchResults.clear();
    	String queryString = buildAccountQueryString();

    	for (Account a: Database.query(queryString))
    	{
    		searchResults.add( new SearchResult(a));
    	}
    }

    private String buildAccountQueryString()
    {
    	String queryString = 'SELECT Id';
    	queryString += ' FROM Account WHERE RecordTypeId = :employeeRecordTypeId';
    	queryString += String.isNotBlank(firstName) ? ' AND FirstName LIKE \'' + firstName + '%\'' : '';
    	queryString += String.isNotBlank(lastName ) ? ' AND LastName LIKE \''  + lastName  + '%\'' : '';
    	queryString += String.isNotBlank(email) ? ' AND PersonEmail=:email' : '';
    	queryString += String.isNotBlank(searchAccount.Country_of_Residence_GLBL__c) ? ' AND Country_of_Residence_GLBL__c=:searchAccount.Country_of_Residence_GLBL__c' : '';

    	return queryString;
    }

    public class SearchResult
    {
    	public Account acct { get; private set; }

    	public SearchResult(Account a)
    	{
    		this.acct = a;
    	}
    }
}