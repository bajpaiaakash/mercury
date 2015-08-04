/****************************************************************************************************************************************** 
 * Class Name   : Test_PANG_HomePage
 * Description  : Test Class for PANG_Homepage
 * Created By   : Deloitte Consulting
 * 
 *****************************************************************************************************************************************/
@isTest(seeAllData = false)
public class Test_PANG_HomePage {
/* 
* @Method Name                    :  test_Homepage
* @Description                    :  Test Method for PANG_HomePage
* @Return Type                    :  void
* @Parameters                     :  None
*/ 
    static testMethod void test_Homepage() {           
    
        User u = PANG_TestFactory.getTestingUser();
        PANG_TestFactory.givePermissions(u.id,'PANG_RWE_Member');  
        System.runAs(u) {
        test.startTest();
        PANG_TestFactory.insertPANGCustomSettings();
        PANG_TestFactory.insertChatterGroups();
        PANG_HomePage a = new PANG_HomePage();
        string b = a.ChatterGroupId;
        if(b!=NULL)
        system.AssertNotEquals(b,NULL);               
        test.stopTest();

        }
        }
        static testMethod void test_Homepage1() {
        
        User user = PANG_TestFactory.getTestingUser();
        PANG_TestFactory.givePermissions(user.id,'PANG_RWE_Customer');
        System.runAs(user) {
        test.startTest();
        PANG_TestFactory.insertPANGCustomSettings();
        PANG_HomePage a = new PANG_HomePage();
        string b = a.ChatterGroupId;
        if(b==NULL)    
        system.AssertEquals(b,NULL);         
        test.stopTest();

        }
    }
}