/*
*@ Class Name                                                    : Test_C3APContractRequestUtilityClass
*@ Description                                                   : Test Class for C3APContractRequestUtilityClass
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 10-06-2014
*@ Modification Log                                              : 10-08-2014                    
*/



@isTest(seeAllData=false)
public  class Test_C3AP_ContractRequestUtilityClass{
 public static List<C3AP_Contract_Request__c> contractReqList = new List <C3AP_Contract_Request__c> ();
    /* 
            * @Method Name                    :  checkApproval_ATS
            * @Description                    :  Testing for Submission to ATS Approval process through the trigger
            * @Return Type                    :  void
                                              
    */      
     public static testmethod void checkApproval_ATS() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
        System.runAs(u) {          
            contractReqList=Test_C3AP_TestData_Utility.createContractReq(1);     
            createApprovers();
            contractReqList[0].C3AP_Status__c=System.Label.C3AP_Status_Not_Submitted;                     
            insert contractReqList;            
            C3AP_Contract_Request__c updatedCR = [Select Id,C3AP_ATS_Approver_Activated__c from C3AP_Contract_Request__c where Id =:contractReqList[0].Id];            
            C3APContractRequestUtilityClass cUtil=new C3APContractRequestUtilityClass();
            Test.startTest();
                updatedCR.C3AP_ATS_Approver_Activated__c = true;            
                updatedCR.C3AP_ATC_Approver_ID__c = null;
                updatedCr.C3AP_ATC_Approver__c = null;
                update updatedCR;
                C3AP_Contract_Request__c updatedCRFinal = [Select C3AP_ATS_Approver__c,C3AP_Status__c,C3AP_ATS_Approver_ID__c,C3AP_Legal_Approver_Required__c,C3AP_ATC_Approval_Required__c from C3AP_Contract_Request__c where Id =:contractReqList[0].Id];
                System.assertNotEquals(updatedCRFinal.C3AP_ATS_Approver__c,null);
                System.assert(!updatedCRFinal.C3AP_Legal_Approver_Required__c);
                System.assert(!updatedCRFinal.C3AP_ATC_Approval_Required__c);
                System.assertEquals(updatedCRFinal.C3AP_Status__c,'Pending ATS Approval');
            Test.stopTest();
        }
     } 
     
     /* 
            * @Method Name                    :  checkApproval_ATCApprovalSubmission
            * @Description                    :  Testing for Submission to ATC Approval process through the trigger
            * @Return Type                    :  void
                                              
    */      
     public static testmethod void checkApproval_ATCApprovalSubmission() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
        System.runAs(u) {          
            contractReqList=Test_C3AP_TestData_Utility.createContractReq(1);     
            createApprovers();
            contractReqList[0].C3AP_Status__c=System.Label.C3AP_Status_Not_Submitted;                     
            insert contractReqList;            
            C3AP_Contract_Request__c updatedCR = [Select Id,C3AP_ATS_Approver_Activated__c,C3AP_ATS_Approver_ID__c,C3AP_ATS_Approver__c from C3AP_Contract_Request__c where Id =:contractReqList[0].Id];            
            C3APContractRequestUtilityClass cUtil=new C3APContractRequestUtilityClass();
            Test.startTest();
                 updatedCR.C3AP_ATS_Approver_ID__c = null;
                 updatedCr.C3AP_ATS_Approver__c = null;
                 updatedCR.C3AP_ATS_Approver_Activated__c = true;
                 update updatedCR;
                 C3AP_Contract_Request__c updatedCRFinal = [Select C3AP_ATS_Approver__c,C3AP_Status__c,C3AP_ATS_Approver_ID__c,C3AP_Legal_Approver_Required__c,C3AP_ATC_Approval_Required__c from C3AP_Contract_Request__c where Id =:contractReqList[0].Id];
                 System.assertEquals(updatedCRFinal.C3AP_ATS_Approver__c,null);
                 System.assert(!updatedCRFinal.C3AP_Legal_Approver_Required__c);
                 System.assert(!updatedCRFinal.C3AP_ATC_Approval_Required__c);                  
                 System.assertEquals(updatedCRFinal.C3AP_Status__c,'Pending ATC Approval');
             Test.stopTest();
        }
     } 
     
     /* 
            * @Method Name                    :  checkApproval_ATCApprovalSubmission
            * @Description                    :  Testing for Submission to ATC Approval process through the trigger
            * @Return Type                    :  void
                                              
    */      
     public static testmethod void checkApproval_ApprovalSubmission() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
        System.runAs(u) {          
            contractReqList=Test_C3AP_TestData_Utility.createContractReq(1);     
            createApprovers();
            contractReqList[0].C3AP_Status__c=System.Label.C3AP_Status_Not_Submitted;                     
            insert contractReqList;            
            C3AP_Contract_Request__c updatedCR = [Select Id,C3AP_ATS_Approver_Activated__c,C3AP_Legal_Approver_Activated__c from C3AP_Contract_Request__c where Id =:contractReqList[0].Id];
            
            C3APContractRequestUtilityClass cUtil=new C3APContractRequestUtilityClass();
            Test.startTest();
                 updatedCR.C3AP_Legal_Approver_Activated__c = true;
                 update updatedCR;
                 C3AP_Contract_Request__c updatedCRFinal = [Select C3AP_ATS_Approver__c,C3AP_Status__c,C3AP_ATS_Approver_ID__c,C3AP_Legal_Approver_Required__c,C3AP_ATC_Approval_Required__c from C3AP_Contract_Request__c where Id =:contractReqList[0].Id];
                 System.assert(!updatedCRFinal.C3AP_Legal_Approver_Required__c);
                 System.assert(!updatedCRFinal.C3AP_ATC_Approval_Required__c);                  
                 System.assertEquals(updatedCRFinal.C3AP_Status__c,'Pending ATC Approval');
             Test.stopTest();
        }
     }
     
     /* 
            * @Method Name                    :  checkApproval_ATS
            * @Description                    :  Testing for Submission to ATS Approval process through the trigger
            * @Return Type                    :  void
                                              
    */      
     public static testmethod void approverReassignTest() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
        System.runAs(u) {          
            contractReqList=Test_C3AP_TestData_Utility.createContractReq(1);     
            createApprovers();
            contractReqList[0].C3AP_Status__c=System.Label.C3AP_Status_Not_Submitted;                     
            insert contractReqList;            
            C3AP_Contract_Request__c updatedCR = [Select Id,C3AP_ATS_Approver_Activated__c from C3AP_Contract_Request__c where Id =:contractReqList[0].Id];            
            C3APContractRequestUtilityClass cUtil=new C3APContractRequestUtilityClass();
            Test.startTest();
                updatedCR.C3AP_ATS_Approver_Activated__c = true;            
                updatedCR.C3AP_ATC_Approver_ID__c = null;
                updatedCr.C3AP_ATC_Approver__c = null;
                update updatedCR;
                C3AP_Contract_Request__c updatedCRFinal = [Select C3AP_ATS_Approver__c,C3AP_Status__c,C3AP_ATS_Approver_ID__c,C3AP_Legal_Approver_Required__c,C3AP_ATC_Approval_Required__c from C3AP_Contract_Request__c where Id =:contractReqList[0].Id];
                System.assertNotEquals(updatedCRFinal.C3AP_ATS_Approver__c,null);
                System.assert(!updatedCRFinal.C3AP_Legal_Approver_Required__c);
                System.assert(!updatedCRFinal.C3AP_ATC_Approval_Required__c);
                System.assertEquals(updatedCRFinal.C3AP_Status__c,'Pending ATS Approval');
                C3AP_Contract_Request__c removeATSApprover = [Select C3AP_ATS_Approver__c,C3AP_Status__c,C3AP_ATS_Approver_ID__c,C3AP_Legal_Approver_Required__c,C3AP_ATC_Approval_Required__c from C3AP_Contract_Request__c where Id =:contractReqList[0].Id];
                removeATSApprover.C3AP_ATS_Approver_ID__c = null;
                removeATSApprover.C3AP_ATS_Approver__c = null;
                update removeATSApprover;
            Test.stopTest();
        }
     } 
      
     /* 
            * @Method Name                    :  isUserAdminTest_Negative
            * @Description                    :  Testing for negative scenario when the logged in user is not an admin(C3 App Admin/System Admin)
            * @Return Type                    :  void
                                              
    */
     public static testmethod void isUserAdminTest_Negative() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
        System.runAs(u) {           
            System.assert(!C3APContractRequestUtilityClass.isUserAdmin(u.Id));
        }
     }
     
     
     /* 
            * @Method Name                    :  isUserAdminTest_Positive
            * @Description                    :  Testing for positive scenario when the logged in user is an admin(C3 App Admin/System Admin)
            * @Return Type                    :  void
                                              
    */
     public static testmethod void isUserAdminTest_Positive() {
        User u1=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);   
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'C3AP_App_Admin'];
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);   
        u.Username = u.Username +String.valueOf(1);  
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.id,PermissionSetId = ps.ID);
        insert psa;           
        System.runAs(u){  
            Test.startTest();       
                System.assert(C3APContractRequestUtilityClass.isUserAdmin(u.Id));
            Test.stopTest();
        }
     }
   
   /**
   * test if the contract request summary records are getting created and deleted correctly
   */
    static testmethod void testSummaryActions(){
      
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name); 
              
        System.runAs(u){  
            Test.startTest();       
                List<C3AP_Contract_Request__c> requests = Test_C3AP_TestData_Utility.createContractReq(1);
                insert requests[0];
                
                List<C3AP_Contract_Request_Summary__c> summaries = [SELECT 
                                            Id, 
                                       C3AP_ATC_Approver_Name__c,
                                    C3AP_ATS_Approver_Name__c,
                                    C3AP_Commencement_Date__c,
                                    C3AP_Contract_Request_Id__c,
                                    C3AP_Contract_Request__c,
                                    C3AP_Contract_Request_Owner__c,
                                    C3AP_ETP_Entity_Name__c,
                                    C3AP_Legal_Approver_Name__c
                                   FROM C3AP_Contract_Request_Summary__c];
         
         // check that the summary has been correctly created
         system.assertEquals(1, summaries.size());
         C3AP_Contract_Request_Summary__c summary = summaries[0];
         system.assertEquals(summary.C3AP_Contract_Request__c, requests[0].Id);
         
         
         C3AP_Contract_Request__c request = requests[0];
         delete request;
         
         // check that the summary has been correctly deleted
        summaries = [SELECT Id FROM C3AP_Contract_Request_Summary__c]; 
        system.assertEquals(0, summaries.size());
         

            Test.stopTest();
        }
    }
  
    /* 
            * @Method Name                    :  createApprovers
            * @Description                    :  Creates Affiliate approvers for the Contract Request records
            * @Return Type                    :  void
                                              
    */
    public static void createApprovers() {
        String cId = contractReqList[0].C3AP_Affiliate__c;
        C3AP_Affiliate__c aff = [Select id, Name from C3AP_Affiliate__c where id=:cId];
        List<C3AP_Affiliate_Approvers__c> C3APAffiliateAppLst=new List<C3AP_Affiliate_Approvers__c>();
        C3APAffiliateAppLst.add(Test_C3AP_TestData_Utility.createAffApprOnly(System.Label.C3AP_Approver_Type_ATC, aff));
        C3APAffiliateAppLst.add(Test_C3AP_TestData_Utility.createAffApprOnly(System.Label.C3AP_Approver_Type_Legal, aff));
        C3APAffiliateAppLst.add(Test_C3AP_TestData_Utility.createAffApprOnly(System.Label.C3AP_Approver_Type_ATS, aff));            
        insert C3APAffiliateAppLst;  
        
        for (C3AP_Contract_Request__c c: contractReqList) {                         
            c.C3AP_ATC_Approver_ID__c=C3APAffiliateAppLst[0].Id;
            c.C3AP_ATC_Approver__c=C3APAffiliateAppLst[0].C3AP_Approver_Name__c;
            c.C3AP_Legal_Approver_ID__c=C3APAffiliateAppLst[1].Id;
            c.C3AP_Legal_Approver__c=C3APAffiliateAppLst[1].C3AP_Approver_Name__c;       
            c.C3AP_ATS_Approver_ID__c=C3APAffiliateAppLst[2].Id;  
            c.C3AP_ATS_Approver__c=C3APAffiliateAppLst[2].C3AP_Approver_Name__c;             
        }
    }
}