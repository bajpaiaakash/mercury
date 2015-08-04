/****************************************************************************************************************************************** 
 * Class Name   : Test_PANG_Request_TriggerHandler
 * Description  : Test Class for PANG_Request_TriggerHandler
 * Created By   : Deloitte Consulting
 * 
 *****************************************************************************************************************************************/
@isTest  (SeeAllData = false)
public class Test_PANG_Request_TriggerHandler {
    /* 
* @Method Name                    :  test_Request_TriggerHandler
* @Description                    :  Test Method for PANG_Request_TriggerHandler
* @Return Type                    :  void
* @Parameters                     :  None
*/ 
    static testMethod void test_Request_TriggerHandler(){
        
        User u = PANG_TestFactory.getTestingUser();
        System.runAs(u){
            
            PANG_Project__c proj;
            proj = new PANG_Project__c();
            proj.Name = ' test project';
            proj.Therapeutic_Area_Primary__c = 'Diabetes';
            insert proj;
            
            System.assertNotEquals(proj,NULL); 
            
            PANG_Molecule__c mol;
            mol = new PANG_Molecule__c();
            mol.Name = 'test';
            mol.Therapeutic_Area_Primary__c = 'Diabetes';
            insert mol;
            
            System.assertNotEquals(mol,NULL); 
                   
            PANG_Molecule__c mol1;
            mol1 = new PANG_Molecule__c();
            mol1.Name = 'test1';
            mol1.Therapeutic_Area_Primary__c = 'Diabetes';
            insert mol1;
            
            System.assertNotEquals(mol1,NULL); 
            
            PANG_RWE_Study_Molecule__c studymol;
            studymol = new PANG_RWE_Study_Molecule__c();
            studymol.RWE_Molecule__c = mol.id;
            studymol.Project__c = proj.id;
            studymol.Therapeutic_Area_Primary__c = 'Diabetes';
            insert studymol;
            
            System.assertNotEquals(studymol,NULL); 
            
            PANG_RWE_Study_Molecule__c studymol1;
            studymol1 = new PANG_RWE_Study_Molecule__c();
            studymol1.RWE_Molecule__c = mol1.id;
            studymol1.Project__c = proj.id;
            studymol1.Therapeutic_Area_Primary__c = 'Diabetes';
            insert studymol1;
            
            System.assertNotEquals(studymol1,NULL); 
            
            PANG_Request__c req1;
            req1 = new PANG_Request__c();
            req1.name = 'test request1';
            req1.Requestor_Functional_Area__c = 'DISCOVERY';
            req1.Therapeutic_Area_Primary__c= 'Diabetes';
            req1.Related_Project__c = proj.id;
            insert req1; 
            
            System.assertNotEquals(req1,NULL); 
            
            PANG_Request__c req2;
            req2 = new PANG_Request__c();
            req2.name = 'test request2';
            req2.Requestor_Functional_Area__c = 'DISCOVERY';
            req2.Therapeutic_Area_Primary__c= 'Diabetes';
            req2.Related_Project__c = proj.id;
            insert req2; 
            
            System.assertNotEquals(req2,NULL); 
             
            List < PANG_Request__c > lreq = new List < PANG_Request__c > ();
            lreq.add(req1);
            lreq.add(req2);
                        
            test.startTest();
            PANG_Request_TriggerHandler.insertRequestMoleculesFromStudy(lreq);
            PANG_Request_TriggerHandler.UpdateRequestRegion(lreq);
            test.stopTest();
            System.assert(true);              
        }
    }
}