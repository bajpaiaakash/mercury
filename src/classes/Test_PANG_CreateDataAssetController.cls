/****************************************************************************************************************************************** 
* Class Name   : Test_PANG_CreateDataAssetController 
* Description  : test class for PANG_CreateDataAssetController
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Test_PANG_CreateDataAssetController {

    /* 
    * @Method Name                    :  createDataAsset
    * @Description                    :  Test Method for Create Data Asset Controller
    * @Return Type                    :  void
    * @Parameters                     :  None
    */   
    static testMethod void createDataAsset() {
    
    User u = PANG_TestFactory.getTestingUser();
     System.runAs(u) {
        
        Boolean isSaved = false;
        PANG_Data_asset__c oDataAsset = new PANG_Data_asset__c();
        oDataAsset.Name = 'test';
        oDataAsset.Description_of_Database__c = 'test';
        insert oDataAsset;
        System.assertNotEquals(oDataAsset,NULL);      
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = oDataAsset.id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        insert(attachment);
        System.assertNotEquals(attachment,NULL); 
        Test.startTest(); 
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(oDataAsset);
        PANG_CreateDataAssetController controller = new  PANG_CreateDataAssetController(stdController);
        controller.attachmentBody1 = b;
        controller.attachmentName1 = 'Test Attachment for Parent';
        controller.attachmentBody2 = b;
        controller.attachmentName2 = 'Test Attachment for Parent';
        controller.attachmentBody3 = b;
        controller.attachmentName3 = 'Test Attachment for Parent';
        controller.saveApplicant();
        System.assert(true);
        Test.stopTest();  
    }
    
    }
    
    }