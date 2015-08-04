/* Class Name  : Test_PANG_CreateRequestController
* Description  : Test Class for PANG_CreateRequestController
* Created By   : Deloitte
* Created Date : 4/10/2015
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/
@
isTest(SeeAllData = false)

public class Test_PANG_CreateRequestController {

    /* 
    * @Method Name                    :  createDataMartWithOutDataAssets
    * @Description                    :  Method to insert datamart project without inhouse data assets 
    * @Return Type                    :  void
    * @Parameters                     :  None
    */      
    static testMethod void createDataMartWithOutDataAssets() {

        User u = PANG_TestFactory.getTestingUser();
        PANG_TestFactory.givePermissions(u.id, 'PANG_RWE_Administrator');

        System.runAs(u) {

            Test.startTest();
            
            list < PANG_Data_Asset__c > lDataAssets = PANG_TestFactory.returnDataAssets(3);
            Insert lDataAssets;

            PageReference pageRef = new pageReference('/apex/PANG_CreateRequests?recTypeName=Internal_Real_World_Data_Analysis');
            Test.setCurrentPage(pageRef);

            PANG_Request__c oRequest = new PANG_Request__c();

            ApexPages.StandardController stdController = new ApexPages.StandardController(oRequest);
            PANG_CreateRequestController controller = new PANG_CreateRequestController(stdController);
            
            controller.displayAcknowledge();
            
            controller.save();

            controller.attachmentBody1 = Blob.valueOf('Test Data1');
            controller.attachmentName1 = 'test1';
            controller.attachmentBody2 = Blob.valueOf('Test Data2');
            controller.attachmentName2 = 'test2';
            controller.attachmentBody3 = Blob.valueOf('Test Data3');
            controller.attachmentName3 = 'test2';

            oRequest = PANG_TestFactory.returnRequests(0, 1)[0];
            
            system.assertEquals(oRequest.id, null);
            controller.save();

            Test.stopTest();
        }
    }

    
        /* 
    * @Method Name                    :  createDataMartWithDataAssets
    * @Description                    :  Method to insert datamart project with inhouse data assets
    * @Return Type                    :  void
    * @Parameters                     :  None
    */  
    static testMethod void createDataMartWithDataAssets() {

        User u = PANG_TestFactory.getTestingUser();
        PANG_TestFactory.givePermissions(u.id, 'PANG_RWE_Administrator');

        System.runAs(u) {

            Test.startTest();

            list < PANG_Data_Asset__c > lDataAssets = PANG_TestFactory.returnDataAssets(3);
            Insert lDataAssets;

            System.assertNotEquals(lDataAssets.size(), 0);

            PageReference pageRef = new pageReference('/apex/PANG_CreateRequests?recTypeName=Internal_Real_World_Data_Analysis');
            Test.setCurrentPage(pageRef);

            PANG_Request__c oRequest = new PANG_Request__c();
            oRequest.name = 'test';
            oRequest.Requestor__c = userinfo.getUserID();
            oRequest.Requestor_Functional_Area__c = 'MEDICAL';
            oRequest.Therapeutic_Area_Primary__c = 'Cardiovascular';

            ApexPages.StandardController stdController = new ApexPages.StandardController(oRequest);
            PANG_CreateRequestController controller = new PANG_CreateRequestController(stdController);

            list < PANG_CreateRequestController.wDataAsset > lwDataAsset = controller.lDisplayAssets;

            lwDataAsset[0].isSelected = true;

            controller.displayAcknowledge();
            
            controller.save();

            controller.isAcknowledgeChecked = true;

            controller.attachmentBody1 = Blob.valueOf('Test Data1');
            controller.attachmentName1 = 'test1';
            controller.attachmentBody2 = Blob.valueOf('Test Data2');
            controller.attachmentName2 = 'test2';
            controller.attachmentBody3 = Blob.valueOf('Test Data3');
            controller.attachmentName3 = 'test2';

            system.assertEquals(oRequest.id, null);
            controller.save();
            Test.stopTest();
        }
    }

    
     /* 
    * @Method Name                    :  createOtherRequests
    * @Description                    :  Method to insert data sourcing request
    * @Return Type                    :  void
    * @Parameters                     :  None
    */ 
    static testMethod void createOtherRequests() {

        User u = PANG_TestFactory.getTestingUser();
        PANG_TestFactory.givePermissions(u.id, 'PANG_RWE_Administrator');

        System.runAs(u) {

            Test.startTest();

            list < string > lRecordtypes = new list < string > ();
            lRecordtypes.add('EXPERT_Review');
            lRecordtypes.add('EXPERT_or_ACT_Consultation');
            lRecordtypes.add('RWE_Strategic_Consultation');
            lRecordtypes.add('Data_Sourcing');

            for (string s: lRecordtypes) {
                PageReference pageRef = new pageReference('/apex/PANG_CreateRequests?recTypeName=' + s);
                Test.setCurrentPage(pageRef);
                PANG_Request__c oRequest = new PANG_Request__c();
                ApexPages.StandardController stdController = new ApexPages.StandardController(oRequest);
                PANG_CreateRequestController controller = new PANG_CreateRequestController(stdController);

                if (s == 'Data_Sourcing') {
                    oRequest.name = 'test';
                    oRequest.Requestor__c = userinfo.getUserID();
                    oRequest.Requestor_Functional_Area__c = 'MEDICAL';
                    oRequest.Therapeutic_Area_Primary__c = 'Cardiovascular';

                    controller.attachmentBody1 = Blob.valueOf('Test Data1');
                    controller.attachmentName1 = 'test1';
                    controller.attachmentBody2 = Blob.valueOf('Test Data2');
                    controller.attachmentName2 = 'test2';
                    controller.attachmentBody3 = Blob.valueOf('Test Data3');
                    controller.attachmentName3 = 'test2';

                    system.assertEquals(oRequest.id, null);
                    controller.save();
                }
            }
            Test.stopTest();
        }
    }

}