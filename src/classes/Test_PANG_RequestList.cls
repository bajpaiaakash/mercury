/* Class Name  : Test_PANG_RequestList
* Description  : Test Class for PANG_RequestList
* Created By   : Deloitte
* Created Date : 4/10/2015
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/
 
@isTest(SeeAllData = false)

public class Test_PANG_RequestList {

    static testMethod void PANG_RequestList() {

        User u = PANG_TestFactory.getTestingUser();
        PANG_TestFactory.givePermissions(u.id, 'PANG_RWE_Administrator');

        System.runAs(u) {

            List < PANG_Request__c > lRequests = PANG_TestFactory.returnRequests(1000, 1000);
            insert lRequests;
            System.assertNotEquals(lRequests.size(), 0);

            Test.startTest();

            ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(lRequests);
            PANG_RequestList controller = new PANG_RequestList();

            //Checking check boxes for filters
            List < PANG_RequestList.wFilterWrapper > lTherapeuticArea = controller.mRequestObjectStructure.get('Therapeutic_Area_Primary__c');
            List < PANG_RequestList.wFilterWrapper > lRecType = controller.mRequestObjectStructure.get('RecordTypeDevName');
            List < PANG_RequestList.wFilterWrapper > lRegion = controller.mRequestObjectStructure.get('Region__c');
            List < PANG_RequestList.wFilterWrapper > lStatus = controller.mRequestObjectStructure.get('Request_Status__c');

            controller.iPageNumber = 50;
            controller.pNoLimit = 10;
            controller.sort();
            controller.sort();
            controller.previousSField = 'Therapeutic_Area_Primary__c';

            system.assertEquals(controller.previousSField, 'Therapeutic_Area_Primary__c');

            controller.sort();
            controller.FetchDataForCriteria();
            controller.getRequests();

            system.assertNotEquals(controller.getRequests().size(), 0);

            controller.GoToPageNumber();
            controller.NextPageSeries();
            controller.PreviousPageSeries();

            lRegion[0].isSelected = true;
            controller.FetchDataForCriteria();

            lTherapeuticArea[0].isSelected = true;
            controller.FetchDataForCriteria();

            lStatus[0].isSelected = true;
            controller.FetchDataForCriteria();

            lRecType[0].isSelected = true;
            controller.FetchDataForCriteria();

            controller.sSearchWord = 'test';
            controller.FetchDataForCriteria();

            system.assertEquals(controller.sSearchWord, 'test');

            Test.stopTest();
        }
    }
}