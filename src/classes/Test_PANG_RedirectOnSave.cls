/****************************************************************************************************************************************** 
 * Class Name   : Test_PANG_RedirectOnSave
 * Description  : Test Class for Test_PANG_RedirectOnSave
 * Created By   : Deloitte Consulting
 * 
 *****************************************************************************************************************************************/
@isTest  (SeeAllData = false)
public class Test_PANG_RedirectOnSave {
    /* 
* @Method Name                    :  test_RedirectOnSave
* @Description                    :  Test Method for PANG_RedirectOnSave
* @Return Type                    :  void
* @Parameters                     :  None
*/ 
    static testMethod void test_RedirectOnSave() {
    
        User u = PANG_TestFactory.getTestingUser();
        PermissionSet ps = [Select id From PermissionSet WHERE Name = 'PANG_RWE_Member'];   
        List <PermissionSetAssignment> perSetAsLst = new List <PermissionSetAssignment>();
        
        PermissionSetAssignment psAssignments = new PermissionSetAssignment();
        psAssignments=new PermissionSetAssignment(AssigneeId = u.id,PermissionSetId = ps.id);
        perSetAsLst.add(psAssignments);
        insert perSetAsLst;
        
        System.runAs(u){
            
        PANG_Request__c req1;
        req1 = new PANG_Request__c();
        req1.name = 'test request1';
        req1.Requestor_Functional_Area__c = 'DISCOVERY';
        req1.Therapeutic_Area_PE__c = 'Autoimmune';
        insert req1;
        System.assertNotEquals(req1,null); 
        
        PANG_Project__c proj;
        proj = new PANG_Project__c();
        proj.Name='test';
        insert proj;
        System.assertNotEquals(proj,null); 
        
        PANG_Country__c country;
        country = new PANG_Country__c();
        country.Name='Japan';
        insert country;
        
        PANG_Related_Country__c relcountry;
        relcountry = new PANG_Related_Country__c();
        relcountry.Project__c=proj.id;
        relcountry.Country__c=country.id;
        insert relcountry;
        System.assertNotEquals(relcountry,null);
        
        test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(req1);
        ApexPages.StandardController stdController1 = new ApexPages.StandardController(relcountry);
        PANG_RedirectOnSave controller = new  PANG_RedirectOnSave(stdController);
        PANG_RedirectOnSave controller1 = new  PANG_RedirectOnSave(stdController1);
        
        controller.onloadFromInventory();
        controller1.onloadFromRequest();
        controller1.onloadFromRequestForResource();
        controller1.onloadFromStudy();
        System.assert(true);
        test.stopTest();
            
        }
    }
}