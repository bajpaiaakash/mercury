/* Class Name  : Test_PANG_StudyList
* Description  : Test Class for PANG_StudyList
* Created By   : Deloitte
* Created Date : 4/10/2015
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*/

@isTest(SeeAllData = false)
public class Test_PANG_StudyList {


/* 
* @Method Name                    :  test_studylist
* @Description                    :  Tesing PANG_StudyList for fetching & displaying Study records.
* @Return Type                    :  void
* @Parameters                     :  None
*/ 
    static testMethod void test_studylist() {

        User u = PANG_TestFactory.getTestingUser();
        PANG_TestFactory.givePermissions(u.id, 'PANG_RWE_Administrator');

        System.runAs(u) {

            List < PANG_Project__c > lprojects = PANG_TestFactory.returnStudies(1000);
            insert lprojects;
            System.assertNotEquals(lprojects.size(), 0);

            test.startTest();
            ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(lprojects);
            PANG_StudyList controller = new PANG_StudyList();

            //Checking check boxes for filters
            List < PANG_StudyList.wStudyObject > lTherapeuticArea = controller.mStudyObjectStructure.get('Therapeutic_Area_Primary__c');
            List < PANG_StudyList.wStudyObject > lRegion = controller.mStudyObjectStructure.get('Region__c');
            List < PANG_StudyList.wStudyObject > lStatus = controller.mStudyObjectStructure.get('Project_Status__c');

            controller.iPageNumber = 50;
            controller.pNoLimit = 10;
            controller.sort();
            controller.sort();
            controller.previousSField = 'Project_Lead_Owner__r.name';
            
            system.assertEquals(controller.previousSField, 'Project_Lead_Owner__r.name');
            
            controller.sort();
            controller.FetchDataForCriteria();
            controller.getStudies();
            
            system.assertNotEquals(controller.getStudies().size(), 0);
            
            controller.GoToPageNumber();
            controller.NextPageSeries();
            controller.PreviousPageSeries();

            lRegion[0].isSelected = true;
            controller.FetchDataForCriteria();
            lTherapeuticArea[0].isSelected = true;
            controller.FetchDataForCriteria();
            lStatus[0].isSelected = true;
            controller.FetchDataForCriteria();

            controller.sSearchWord = 'test';
            controller.FetchDataForCriteria();

            test.stopTest();

        }
    }
}