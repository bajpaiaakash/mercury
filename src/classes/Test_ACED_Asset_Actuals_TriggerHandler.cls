@isTest(SeeAllData=false)
public class Test_ACED_Asset_Actuals_TriggerHandler{

    static testMethod void insertNewAssetActuals() {
	    System.runAs( ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner')) {
		    Test.startTest();
		    List<ACED_Asset_Indication__c> lAssetActs = ACED_DataFactory.createAssetActualsWithInd(100);
		    //Assert the asset Indications have brand indication populated
		    system.assert([Select id, asset__c from ACED_Asset_Indication__c where id IN: lAssetActs limit 1].asset__c != null);
		    Test.stopTest();
	    }
	}
}