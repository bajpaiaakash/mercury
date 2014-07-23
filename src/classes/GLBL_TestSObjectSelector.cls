/**
 * @author Kyle Thornton
 * Extracted fro GLBL_SObjectSelectorTest.cls as it was causing salesforce to count lines of the unit
 * test as uncovered. This is only used for unit tests
 */
public class GLBL_TestSObjectSelector extends GLBL_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Account.Name,
			Account.Id,
			Account.AccountNumber,
			Account.AnnualRevenue
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Account.sObjectType;
	}
}