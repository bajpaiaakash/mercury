/*************************************************************************\
    @ Author        : Neelam Dalwani
    @ Date          : 03-Sept-2014
    @ Description   : Test Class for GLBL_LoginAutherizationClass class
****************************************************************************/
@
isTest
private class Test_MICO_TestExecutionApprovalClass {


    public static User sysCust;
    public static User sysOwner;
    public static MICO_Project__c project;
    public static MICO_Test__c testExecObj;



    static testMethod void setupTestData() {

        

        //Creating the test user for Approver
        sysOwner = new User();
        sysOwner.username = 'sysOwner@Test.com.env';
        sysOwner.Email = 'sysOwner@Test.com';
        sysOwner.profileid = UserInfo.getProfileId();
        sysOwner.lastname = 'Owner';
        sysOwner.firstname = 'System';
        sysOwner.Alias = 'syo';
        sysOwner.TimeZoneSidKey = 'America/Los_Angeles';
        sysOwner.LocaleSidKey = 'en_US';
        sysOwner.EmailEncodingKey = 'UTF-8';
        sysOwner.LanguageLocaleKey = 'en_US';
        insert sysOwner;

        sysCust = new User();
        sysCust.username = 'sysCust@Test.com.env';
        sysCust.Email = 'sysCust@Test.com';
        sysCust.profileid = UserInfo.getProfileId();
        sysCust.lastname = 'Custodian';
        sysCust.firstname = 'System';
        sysCust.Alias = 'syc';
        sysCust.TimeZoneSidKey = 'America/Los_Angeles';
        sysCust.LocaleSidKey = 'en_US';
        sysCust.EmailEncodingKey = 'UTF-8';
        sysCust.LanguageLocaleKey = 'en_US';
        insert sysCust;

        

        System.runAs(sysOwner) {

            project = new MICO_Project__c();
            project.Name = 'Test Project';
            insert project;

            testExecObj=new MICO_Test__c(Submitter__c=UserInfo.getUserid(),Approval_Status__c='Open',approver__c=sysOwner.id,Project__c=project.id);
            
            insert testExecObj;
            ApexPages.StandardController controller = new ApexPages.StandardController(testExecObj);

            MICO_TestExecutionApprovalClass testApprovalClass = new MICO_TestExecutionApprovalClass(controller);
            Boolean checkRecall=testApprovalClass.getcheckRecallButton();
            
            testExecObj.Approval_Status__c = 'Pending Approval';
           update testExecObj;
           
           checkRecall=testApprovalClass.getcheckRecallButton();
           
           testApprovalClass.recallApprovalRequest();
           }
           
           
           
          
    }

    static testMethod void testApprovalProcess() {

        setupTestData();

        //Negative Scenarios if the status is not equal to Pending approval the button should not be active
        ApexPages.StandardController controller = new ApexPages.StandardController(testExecObj);

        MICO_TestExecutionApprovalClass testApprovalClass = new MICO_TestExecutionApprovalClass(controller);
        Boolean approveCheck = testApprovalClass.getcheckApproveRejectButton();
    
        System.assertEquals(approveCheck, false);

        Test.StartTest();
       
        // Postive Case Scenario (Button should be enabled only for System Admin and Custodian)
        System.runAs(sysOwner) {
            testExecObj.Approval_Status__c = 'Pending Approval';
           update testExecObj;
            Boolean approveChecksysOwner = testApprovalClass.getcheckApproveRejectButton();
            System.assertEquals(approveChecksysOwner, true);
        }

        // Negative Case Scenario (Button should not be enabled only for Business Quality and System Quality User)
        System.runAs(sysCust) {
            Boolean approveCheckSysQual = testApprovalClass.getcheckApproveRejectButton();
            System.assertEquals(approveCheck, false);
        }

        //Setting the Test Page
        testApprovalClass.redirectToApprovalPage();
        PageReference pageRef = Page.MICO_TestExecutionApproval;
        Test.setCurrentPageReference(pageRef);

        System.runAs(sysOwner) {
            testApprovalClass.approveUserStory();
            
        }

        

        //Button should be enabled for Business Quality and System Quality User when Sys Custodian and System Owner have approved the story
        //Positive Scenarios
       
        
        // User story should be approved
         System.assertEquals(true, testExecObj.Approval_Status__c == 'Approved');

        Test.StopTest();
    }

    static testMethod void testRejectionProcess() {
        setupTestData();

        ApexPages.StandardController controller = new ApexPages.StandardController(testExecObj);

        MICO_TestExecutionApprovalClass testRejectionClass = new MICO_TestExecutionApprovalClass(controller);

        Test.StartTest();
        
        System.runAs(sysOwner) {
            testRejectionClass.rejectUserStory();
            
        }
        
        System.assertEquals(true, testExecObj.Approval_Status__c == 'Rejected');
        Test.StopTest();
    }


}