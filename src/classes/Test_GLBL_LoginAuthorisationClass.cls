/*************************************************************************\
    @ Author        : Nitish Kumar
    @ Date          : 25-July-2014
    @ Description   : Test Class for GLBL_LoginAuthorisationClass class
****************************************************************************/
@isTest
private class Test_GLBL_LoginAuthorisationClass {

    static testMethod void LoginAuthorisationClassTest() {
        
        //Creating the test user
        User testUser = new User();
        testUser.username = 'testuser@Test.com.env';
        testUser.Email = 'testuser@Test.com';
        testUser.profileid = UserInfo.getProfileId();
        testUser.lastname = 'User';
        testUser.firstname = 'Test';
        testUser.Alias = 'Test';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;
        
        //Password Set for Test User
        System.setPassword(testUser.Id, 'testPassWord#101');

        System.runAs(testUser) {

            Test.startTest();

            GLBL_LoginAuthorisationClass authorisationTest = new GLBL_LoginAuthorisationClass();
            authorisationTest.password = 'testPassWord#101';

            authorisationTest.checkLogin();
            
            System.assertEquals(authorisationTest.doVerify(), true);

            Test.stopTest();
        }

    }
}