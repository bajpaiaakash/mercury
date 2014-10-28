/* Class Name  : Test_ACED_AssetActuals_Contrl
* Description  : Test Class for ACED_AssetActuals_Contrl
* Created By   : Goutham
* Created Date : 9/23/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest  (SeeAllData = false)
public class Test_ACED_AssetActuals_Contrl{

    static testMethod void assetActualController() {
    
    System.runAs(ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner')) {
	    Test.startTest();
		    ACED_AssetActuals_Contrl AssetAct = New ACED_AssetActuals_Contrl();
		    AssetAct.ACED_AssetActuals_Contrl();
		    List<ACED_Deliveries__c> lDels = ACED_DataFactory.createDeliveries(100);
		    ApexPages.currentPage().getParameters().put('id',lDels[0].Standalone_asset__c);
		    AssetAct.ACED_AssetActuals_Contrl();
		    
		    //Assert that a asset is delete after adding actual 
		    system.assert([Select id from ACED_Asset__c where id = : lDels[0].Standalone_asset__c].size()==0);
	    Test.stopTest();
    }
}
}