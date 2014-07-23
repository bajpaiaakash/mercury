/**
 * @author Kyle Thornton
 * Test domain class used by the GLBL_SObjectDomainTest
 * extracted to separate class because salesforce includes unit tests in
 * overall coverage if it includes an innerclass
 **/
public with sharing class GLBL_TestSObjectDomain extends GLBL_SObjectDomain
{
	public GLBL_TestSObjectDomain(List<Opportunity> sObjectList)
	{
		// Domain classes are initialised with lists to enforce bulkification throughout
		super(sObjectList);
	}

	public override void onApplyDefaults()
	{
		// Not required in production code
		super.onApplyDefaults();

		// Apply defaults to TestSObjectDomain
		for(Opportunity opportunity : (List<Opportunity>) Records)
		{
			opportunity.CloseDate = System.today().addDays(30);
		}
	}

	public override void onValidate()
	{
		// Not required in production code
		super.onValidate();

		// Validate TestSObjectDomain
		for(Opportunity opp : (List<Opportunity>) Records)
		{
			if(opp.Type!=null && opp.Type.startsWith('Existing') && opp.AccountId == null)
			{
				opp.AccountId.addError( error('You must provide an Account for Opportunities for existing Customers.', opp, Opportunity.AccountId) );
			}
		}
	}

	public override void onValidate(Map<Id,SObject> existingRecords)
	{
		// Not required in production code
		super.onValidate(existingRecords);

		// Validate changes to TestSObjectDomain
		for(Opportunity opp : (List<Opportunity>) Records)
		{
			Opportunity existingOpp = (Opportunity) existingRecords.get(opp.Id);
			if(opp.Type != existingOpp.Type)
			{
				opp.Type.addError( error('You cannot change the Opportunity type once it has been created.', opp, Opportunity.Type) );
			}
		}
	}

	public override void onBeforeDelete()
	{
		// Not required in production code
		super.onBeforeDelete();

		// Validate changes to TestSObjectDomain
		for(Opportunity opp : (List<Opportunity>) Records)
		{
			opp.addError( error('You cannot delete this Opportunity.', opp) );
		}
	}

	/**
	 * Typically an inner class to the domain class, supported here for test purposes
	 **/
	public class TestSObjectDomainConstructor implements GLBL_SObjectDomain.IConstructable
	{
		public GLBL_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new GLBL_TestSObjectDomain(sObjectList);
		}
	}
}