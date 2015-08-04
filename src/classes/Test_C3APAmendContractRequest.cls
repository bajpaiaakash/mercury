/*
*@ Class Name                                                    : Test_C3APAmendContractRequest
*@ Description                                                   : Test Class for C3APAmendContractRequest 
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 10-03-2014
*@ Modification Log                                              : Modified on 10-07-2014                   
*/



@isTest(seeAllData=false)
public  class Test_C3APAmendContractRequest{
	public static List<C3AP_Contract_Request__c> contractReqList = new List <C3AP_Contract_Request__c> ();

    /* 
            * @Method Name                    :  checkAmendAndEmailForATC
            * @Description                    :  Testing for successful ATC Amendment 
            * @Return Type                    :  void
                                              
    */

     
     static testmethod void validateEligibilityForAmendTest_Positive(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);       
        System.runAs(u){  
            Test.startTest();       
                List<C3AP_Contract_Request__c> contractReqLst=Test_C3AP_TestData_Utility.createContractReq(1);
                contractReqLst[0].C3AP_Status__c = Label.C3AP_Status_Pending_Final_Signatures;
                insert contractReqLst[0];
                System.assert(C3APAmendContractRequest.validateEligibilityForAmend(contractReqLst[0].Id));
            Test.stopTest();
        }
    }
 /* 
            * @Method Name                    :  checkAmendAndEmailForATC
            * @Description                    :  Testing for successful ATC Amendment 
            * @Return Type                    :  void
                                              
    */

     
     static testmethod void validateEligibilityForAmendTest_Negative(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);       
        System.runAs(u){  
            Test.startTest();       
                List<C3AP_Contract_Request__c> contractReqLst=Test_C3AP_TestData_Utility.createContractReq(1);
                contractReqLst[0].C3AP_Status__c = Label.C3AP_Status_Pending_ATC_Approval;
                insert contractReqLst[0];
                System.assert(!C3APAmendContractRequest.validateEligibilityForAmend(contractReqLst[0].Id));
            Test.stopTest();
        }
    }
    
     /* 
            * @Method Name                    :  checkAmendAndEmailForATC
            * @Description                    :  Testing for successful ATC Amendment 
            * @Return Type                    :  void
                                              
    */

     
     static testmethod void saveAmendedContract_CITest1(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);       
        System.runAs(u){  
            Test.startTest();       
                List<C3AP_Contract_Request__c> contractReqLst=Test_C3AP_TestData_Utility.createContractReq(1);
                contractReqLst[0].C3AP_Status__c = Label.C3AP_Status_Pending_Final_Signatures;
                insert contractReqLst[0];
                C3APAmendContractRequest.saveAmendedContract(contractReqLst[0].Id);
                C3AP_Contract_Request__c contractrequest = [SELECT Id,C3AP_Status__c,C3AP_Legal_Approver__c,C3AP_ATS_Approver__c,
                                                                                           OwnerId,C3AP_ATC_Approver__c,C3AP_Amend_Legal__c,C3AP_Amend__c,C3AP_Is_Amend_Transaction__c,
                                                                                           C3AP_Amended_By_CI__c,C3AP_ATC_Approved__c,C3AP_ATS_Approved__c,C3AP_Legal_Approved__c
                                                                                           FROM C3AP_Contract_Request__c 
                                                                                           WHERE Id =: contractReqLst[0].Id];
                System.assert(contractRequest.C3AP_Amended_By_CI__c);                                                                           
            Test.stopTest();
        }
    }
    
    /* 
            * @Method Name                    :  checkAmendAndEmailForATC
            * @Description                    :  Testing for successful ATC Amendment 
            * @Return Type                    :  void
                                              
    */

     
     static testmethod void saveAmendedContract_CITest2(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);       
        System.runAs(u){  
            Test.startTest();       
                List<C3AP_Contract_Request__c> contractReqLst=Test_C3AP_TestData_Utility.createContractReq(1);
                contractReqLst[0].C3AP_Status__c = Label.C3AP_Status_Not_Approved_By_ATS;
                insert contractReqLst[0];
                C3APAmendContractRequest.saveAmendedContract(contractReqLst[0].Id);
                C3AP_Contract_Request__c contractrequest = [SELECT Id,C3AP_Status__c,C3AP_Legal_Approver__c,C3AP_ATS_Approver__c,
                                                                                           OwnerId,C3AP_ATC_Approver__c,C3AP_Amend_Legal__c,C3AP_Amend__c,C3AP_Is_Amend_Transaction__c,
                                                                                           C3AP_Amended_By_CI__c,C3AP_ATC_Approved__c,C3AP_ATS_Approved__c,C3AP_Legal_Approved__c
                                                                                           FROM C3AP_Contract_Request__c 
                                                                                           WHERE Id =: contractReqLst[0].Id];
                System.assert(contractRequest.C3AP_Amended_By_CI__c);                                                                           
            Test.stopTest();
        }
    }
    
    /* 
            * @Method Name                    :  checkAmendAndEmailForATC
            * @Description                    :  Testing for successful ATC Amendment 
            * @Return Type                    :  void
                                              
    */

     
     static testmethod void saveAmendedContract_LegalTest(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
                 
        System.runAs(u){  
        	    contractReqList=Test_C3AP_TestData_Utility.createContractReq(1);
                contractReqList[0].C3AP_Status__c = Label.C3AP_Status_Pending_Legal_Approval;
                createApprovers();
                insert contractReqList[0];
        }
        User legalUser = [Select Id from User where Id =: contractReqList[0].C3AP_Legal_Approver__c LIMIT 1];
        System.runAs(legalUser){
        		Test.startTest();
                C3APAmendContractRequest.saveAmendedContract(contractReqList[0].Id);
                C3AP_Contract_Request__c contractrequest = [SELECT Id,C3AP_Status__c,C3AP_Legal_Approver__c,C3AP_ATS_Approver__c,
                                                                                           OwnerId,C3AP_ATC_Approver__c,C3AP_Amend_Legal__c,C3AP_Amend__c,C3AP_Is_Amend_Transaction__c,
                                                                                           C3AP_Amended_By_CI__c,C3AP_ATC_Approved__c,C3AP_ATS_Approved__c,C3AP_Legal_Approved__c
                                                                                           FROM C3AP_Contract_Request__c 
                                                                                           WHERE Id =: contractReqList[0].Id];
                System.assert(!contractRequest.C3AP_Amended_By_CI__c);    
                System.assert(contractRequest.c3AP_Amend_Legal__c);                                                                       
            Test.stopTest();
        }
    }
    
    /* 
            * @Method Name                    :  checkAmendAndEmailForATC
            * @Description                    :  Testing for successful ATC Amendment 
            * @Return Type                    :  void
                                              
    */

     
     static testmethod void saveAmendedContract_ATCTest(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
                 
        System.runAs(u){  
        	    contractReqList=Test_C3AP_TestData_Utility.createContractReq(1);
                contractReqList[0].C3AP_Status__c = Label.C3AP_Status_Pending_ATC_Approval;
                createApprovers();
                insert contractReqList[0];
        }
        User atcUser = [Select Id from User where Id =: contractReqList[0].C3AP_ATC_Approver__c LIMIT 1];
        System.runAs(atcUser){
        		Test.startTest();
                C3APAmendContractRequest.saveAmendedContract(contractReqList[0].Id);
                C3AP_Contract_Request__c contractrequest = [SELECT Id,C3AP_Status__c,C3AP_Legal_Approver__c,C3AP_ATS_Approver__c,
                                                                                           OwnerId,C3AP_ATC_Approver__c,C3AP_Amend_Legal__c,C3AP_Amend__c,C3AP_Is_Amend_Transaction__c,
                                                                                           C3AP_Amended_By_CI__c,C3AP_ATC_Approved__c,C3AP_ATS_Approved__c,C3AP_Legal_Approved__c
                                                                                           FROM C3AP_Contract_Request__c 
                                                                                           WHERE Id =: contractReqList[0].Id];
                System.assert(!contractRequest.C3AP_Amended_By_CI__c);    
                System.assert(contractRequest.c3AP_Amend__c);                                                                       
            Test.stopTest();
        }
    }
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