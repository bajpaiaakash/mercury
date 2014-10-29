/*************************************************************************\
    @ Author        : Neelam Dalwani
    @ Date          : 03-Sept-2014
    @ Description   : Test Class for GLBL_LoginAutherizationClass class
****************************************************************************/
@
isTest
private class Test_MICO_TestScriptApprovalClass {


    public static User sysCust;
    public static User sysOwner;
    public static MICO_Project__c project;
    public static MICO_Test_Templates__c testExecObj;



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

            User stakeholderUser = new User(Alias             = 'stkhldr',
                        Email             = 'stakeholderUser@mico-test.com',
                        EmailEncodingKey  = 'UTF-8',
                        LastName          = 'User',
                        FirstName         = 'Stakeholder',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey      = 'en_US',
                        ProfileId         = [select Id from Profile where Name = 'System Administrator' limit 1].Id,
                        TimeZoneSidKey    = 'America/Chicago',
                        Username          = 'stakeholder@mico-test' + Math.round(Math.random() * 10000) + '.com',
                        UserRoleId        = null,
                        Country           = 'Great Britain');
        insert stakeholderUser;
         project = new MICO_Project__c();
        project.Name = 'mico-project';
        insert project;
        MICO_App__c app = new MICO_App__c();
        app.Name = 'mico-app';
        app.System_Custodian__c = stakeholderUser.Id;
        app.System_Owner__c = stakeholderUser.Id;
        app.Business_Quality__c = stakeholderUser.Id;
        app.Computer_Systems_Quality__c = stakeholderUser.Id;
        insert app;
        
        MICO_User_Story__c story = new MICO_User_Story__c();
        story.App__c = app.Id;
        story.Project__c = project.Id;
        story.Submitter__c=UserInfo.getUserId();
        story.approval_status__c='Approved';
        insert story;

            testExecObj=new MICO_Test_Templates__c(Submitter__c=UserInfo.getUserid(),Approval_Status__c='Open',approver__c=sysOwner.id,Title__c='test',Introduction__c='test',User_Story__c=story.id);
            
            insert testExecObj;
            ApexPages.StandardController controller = new ApexPages.StandardController(testExecObj);

            MICO_TestScriptApprovalClass testApprovalClass = new MICO_TestScriptApprovalClass(controller);
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

        MICO_TestScriptApprovalClass testApprovalClass = new MICO_TestScriptApprovalClass(controller);
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
        PageReference pageRef = Page.MICO_TestScriptApproval;
        Test.setCurrentPageReference(pageRef);

        System.runAs(sysOwner) {
            testApprovalClass.approveUserStory();
            
        }

        
        // User story should be approved
         System.assertEquals(true, testExecObj.Approval_Status__c == 'Approved');

        Test.StopTest();
    }

    static testMethod void testRejectionProcess() {
        setupTestData();

        ApexPages.StandardController controller = new ApexPages.StandardController(testExecObj);

        MICO_TestScriptApprovalClass testRejectionClass = new MICO_TestScriptApprovalClass(controller);

        Test.StartTest();
        
        System.runAs(sysOwner) {
            testRejectionClass.rejectUserStory();
            
        }
        
        System.assertEquals(true, testExecObj.Approval_Status__c == 'Rejected');
        Test.StopTest();
    }


}