/* Class Name  : Test_PANG_PartnerShipList
* Description  : Test Class for PANG_PartnerShipList
* Created By   : Deloitte
* Created Date : 4/10/2015
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/
@
isTest(SeeAllData = false)

public class Test_PANG_PartnerShipList {

    static testMethod void test_partnershiplist() {

        User u = PANG_TestFactory.getTestingUser();
        PANG_TestFactory.givePermissions(u.id, 'PANG_RWE_Administrator');

        System.runAs(u) {

            List < PANG_Request__c > lRequests = PANG_TestFactory.returnRequests(1000, 1000);
            insert lRequests;
            System.assertNotEquals(lRequests.size(), 0);

            test.startTest();
            ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(lRequests);
            PANG_PartnerShipList controller = new PANG_PartnerShipList();

            //Checking check boxes for filters
            List < PANG_PartnerShipList.wFilterWrapper > lStatus = controller.mPartnershipStructure.get('Partnership_Status__c');
            List < PANG_PartnerShipList.wFilterWrapper > lSponser = controller.mPartnershipStructure.get('Partnership_Sponsor__c');
            List < PANG_PartnerShipList.wFilterWrapper > lRegion = controller.mPartnershipStructure.get('Region__c');


            controller.iPageNumber = 50;
            controller.pNoLimit = 10;
            controller.sort();
            controller.sort();
            controller.previousSField = 'Partnership_Sponsor__c';

            system.assertEquals(controller.previousSField, 'Partnership_Sponsor__c');

            controller.sort();
            controller.FetchDataForCriteria();
            controller.getPartnerships();

            system.assertNotEquals(controller.getPartnerships().size(), 0);

            controller.GoToPageNumber();
            controller.NextPageSeries();
            controller.PreviousPageSeries();

            lRegion[0].isSelected = true;
            controller.FetchDataForCriteria();

            lStatus[0].isSelected = true;
            controller.FetchDataForCriteria();

            lSponser[0].isSelected = true;
            controller.FetchDataForCriteria();

            controller.sSearchWord = 'test';
            controller.FetchDataForCriteria();

            system.assertEquals(controller.sSearchWord, 'test');

            controller.sPartnershipType = 'Payer';
            controller.FetchDataForCriteria();

            system.assertEquals(controller.sPartnershipType, 'Payer');

            test.stopTest();

        }
    }
}