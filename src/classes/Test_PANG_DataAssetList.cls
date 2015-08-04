/* Class Name  : Test_PANG_DataAssetList
* Description  : Test Class for PANG_DataAssetList
* Created By   : Deloitte
* Created Date : 4/10/2015
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest(SeeAllData = false)

public class Test_PANG_DataAssetList 
{
 /* 
* @Method Name                    :  test_dataassetlist
* @Description                    :  Tesing PANG_DataAssetList for fetching and displaying Data Asset records.
* @Return Type                    :  void
* @Parameters                     :  None
*/ 
    static testMethod void test_dataassetlist() 
    {

        User u = PANG_TestFactory.getTestingUser();
        PANG_TestFactory.givePermissions(u.id, 'PANG_RWE_Administrator');

        System.runAs(u) 
        {

            List < PANG_Data_Asset__c > ldataasset = PANG_TestFactory.returnDataAssets(1000);
            insert ldataasset;
            
            System.assertNotEquals(ldataasset.size(), 0);

            test.startTest();
            ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(ldataasset);
            PANG_DataAssetList controller = new PANG_DataAssetList();

            //Checking check boxes for filters
            List < PANG_DataAssetList.wDataAssetObject > lTherapeuticArea = controller.mDataAssetObjectStructure.get('Relevant_Therapeutic_Area__c');
            List < PANG_DataAssetList.wDataAssetObject > lRegion = controller.mDataAssetObjectStructure.get('Region__c');
            List < PANG_DataAssetList.wDataAssetObject > lDataBase = controller.mDataAssetObjectStructure.get('Type_of_Database__c');
            List < PANG_DataAssetList.wDataAssetObject > lAccessMethod = controller.mDataAssetObjectStructure.get('Access_Method__c');

            controller.iPageNumber = 50;
            controller.pNoLimit = 10;
            controller.sort();
            controller.sort();
            controller.previousSField = 'Relevant_Therapeutic_Area__c';

            system.assertEquals(controller.previousSField, 'Relevant_Therapeutic_Area__c');

            controller.sort();
            controller.FetchDataForCriteria();
            controller.getDataAssets();

            system.assertNotEquals(controller.getDataAssets().size(), 0);

            controller.GoToPageNumber();
            controller.NextPageSeries();
            controller.PreviousPageSeries();

            lRegion[0].isSelected = true;
            controller.FetchDataForCriteria();
            
            lTherapeuticArea[0].isSelected = true;
            controller.FetchDataForCriteria();
            
            lDataBase[0].isSelected = true;
            controller.FetchDataForCriteria();
            
            lAccessMethod[0].isSelected = true;
            controller.FetchDataForCriteria();
            
            controller.sSearchWord = 'test';
            controller.FetchDataForCriteria();
            system.assertEquals(controller.sSearchWord , 'test');
            
            controller.sOwnerType = 'Vendor';
            controller.FetchDataForCriteria();
            system.assertEquals(controller.sOwnerType , 'Vendor');

            test.stopTest();

        }
    }
}