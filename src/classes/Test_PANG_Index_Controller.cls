/****************************************************************************************************************************************** 
 * Class Name   : Test_PANG_Index_Controller
 * Description  : Test Class for PANG_Index_Controller
 * Created By   : Deloitte Consulting
 * 
 *****************************************************************************************************************************************/
@isTest(seeAllData = false)
public class Test_PANG_Index_Controller {
    /* 
* @Method Name                    :  test_Index_Controller
* @Description                    :  Test Method for PANG_Index_Controller
* @Return Type                    :  void
* @Parameters                     :  None
*/ 
    static testMethod void test_Index_Controller(){
    
        User u = PANG_TestFactory.getTestingUser();
        System.runAs(u) {
        
        test.startTest();
        
        PANG_Index_Controller a = new PANG_Index_Controller();
        a.searchWord = 'test';       
        pagereference p = a.populateGlobalURL();
        //checking if search word is populating in global search page redirect
        system.assertEquals(p.getParameters().get('searchWord'),'test');
        PANG_Index_Controller.getHomeUrl();
        
        test.stopTest();
      }
    }
}