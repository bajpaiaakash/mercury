/****************************************************************************************************************************************** 
 * Class Name   : Test_PANG_RWEFinalDeliverablesList
 * Description  : Test Class for PANG_RWEFinalDeliverablesList
 * Created By   : Deloitte Consulting
 * 
 *****************************************************************************************************************************************/
@isTest(seeAllData = false)
public class Test_PANG_RWEFinalDeliverablesList {
    /* 
* @Method Name                    :  test_RWEFinalDeliverablesList
* @Description                    :  Test Method for PANG_RWEFinalDeliverablesList
* @Return Type                    :  void
* @Parameters                     :  None
*/ 
    static testMethod void test_RWEFinalDeliverablesList() {

        User u = PANG_TestFactory.getTestingUser();
        String gname = 'PANG_RWE_Pangaea_Support_Team';
        PANG_TestFactory.assignGroup(u.id,gname);
        System.runAs(u) {

            PANG_Request__c req1;
            req1 = new PANG_Request__c();
            req1.name = 'test request1';
            req1.Requestor_Functional_Area__c = 'DISCOVERY';
            req1.Therapeutic_Area_PE__c = 'Autoimmune';
            insert req1;

            PANG_Data_Asset__c dataasset;
            dataasset = new PANG_Data_Asset__c();
            dataasset.Name = 'test';
            dataasset.Description_of_Database__c = 'test';
            insert dataasset;


            PANG_Project__c proj;
            proj = new PANG_Project__c();
            proj.Name = ' test project1';
            insert proj;


            ContentVersion doc = new ContentVersion();
            string before = 'Test';
            Blob beforeblob = Blob.valueOf(before);
            doc.Title = 'title';
            doc.PathOnClient = 'xyz';
            doc.VersionData = beforeblob;
            insert doc;
            doc.PANG_Request__c = req1.id;
            update doc;
            doc.PANG_Project__c = proj.id;
            update doc;
            doc.PANG_Data_Asset__c = dataasset.id;
            update doc;
            
            System.assertNotEquals(doc.PANG_Request__c, NULL);
            System.assertNotEquals(req1, NULL);
            System.assertNotEquals(doc.PANG_Project__c, NULL);
            System.assertNotEquals(proj, NULL);
            System.assertNotEquals(doc.PANG_Data_Asset__c, NULL);
            System.assertNotEquals(dataasset, NULL);

            test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(req1);
            PANG_RWEFinalDeliverablesList controller = new PANG_RWEFinalDeliverablesList(stdController);
            ApexPages.StandardController stdController2 = new ApexPages.StandardController(proj);
            PANG_RWEFinalDeliverablesList controller2 = new PANG_RWEFinalDeliverablesList(stdController2);
            ApexPages.StandardController stdController3 = new ApexPages.StandardController(dataasset);
            PANG_RWEFinalDeliverablesList controller3 = new PANG_RWEFinalDeliverablesList(stdController3);
            controller.RequestPage();
            controller2.StudyPage();
            controller3.AssetPage();
            test.stopTest();
            System.assert(true);
        }
    }
}