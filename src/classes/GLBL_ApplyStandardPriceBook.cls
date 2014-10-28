/**
 * Test implemetnation of IDeserializeCallback, automatically applies Standard Pricebook to new PricebookEntry's
 * This was extracted from GLBL_SobjectDataLoaderTest because it was causing salesforce to count all the lines
 * of the test class under coverage. ***This is only meant to assist in unit tests.***
**/
public class GLBL_ApplyStandardPriceBook implements GLBL_SobjectDataLoader.IDeserializeCallback{
	private Pricebook2 standardPricebook;

	public GLBL_ApplyStandardPricebook()
	{
		standardPricebook = [select Id from Pricebook2 where IsStandard = true];
	}

	public void cloneMapHAndler(Map<Id, SObject> cloneMap) {}

	public void unresolvedReferences(Schema.SObjectType sObjectType, List<GLBL_SobjectDataLoader.UnresolvedReferences> unresolvedReferences)
	{
		if(sObjectType == PricebookEntry.sObjectType) // PricebookEntry object?
			for(GLBL_SobjectDataLoader.UnresolvedReferences unresolvedReference : unresolvedReferences)
				if(unresolvedReference.References.contains(PricebookEntry.Pricebook2Id)) // Pricebook2Id field?
					unresolvedReference.Record.put(PricebookEntry.Pricebook2Id, standardPricebook.id); // Set Standard Pricebook
	}
}