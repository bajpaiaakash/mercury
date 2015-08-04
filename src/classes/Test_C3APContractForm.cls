/*
*@ Class Name                                                    : Test_C3APContractForm
*@ Description                                                   : Test Class for C3AP Contract form extension 
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 09-16-2014
*@ Modification Log                                              :                     
*/

@istest(seeAllData=false)
public with sharing class Test_C3APContractForm {

    /* 
            * @Method Name                    :  testPositiveUpdateContractRequest 
            * @Description                    :  Testing of Different Positive Scenarios that user can do using naviagtion in actual UI  
            * @Return Type                    :  void
                                              
    */
    public static testMethod void testPositiveUpdateContractRequest(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
        System.runAs(u) {       
            //Creates an instance of Mico_App__c
            //Test_C3AP_TestData_Utility.createApp();
            // Create affliate record
            List<C3AP_Affiliate__c> affliateList = Test_C3AP_TestData_Utility.createAffiliate(1);
            insert affliateList ;
            
            // Create affliate contract record 
            List<C3AP_Affiliate_Contracts__c> affContList = Test_C3AP_TestData_Utility.createAffliateContracts(affliateList[0]);
            insert affContList;
            
            // Create contract request record
            List<C3AP_Contract_Request__c> contractReqLst=Test_C3AP_TestData_Utility.createContractReq(1);
            
            // Adding other Contract Request Details 
            contractReqLst[0].C3AP_Department__c = 'Department';
            contractReqLst[0].C3AP_Affiliate__c = affliateList[0].id;
            contractReqLst[0].Affiliate__c = affliateList[0].Name;        
            contractReqLst[0].C3AP_Contract_Type__c = affContList[0].id;  
            contractReqLst[0].C3AP_Amendment_Accepted__c=true;
            contractReqLst[0].C3AP_Final_Sign__c=false;
            contractReqLst[0].C3AP_Status__c =System.Label.C3AP_Status_Not_Submitted;
            contractReqLst[0].C3AP_Contract_Save_Toggle__c=true;
    
            //Adding Approvers to the Affiliate
            createAffApprover(contractReqLst, System.Label.C3AP_Approver_Type_ATC);
            createAffApprover(contractReqLst, System.Label.C3AP_Approver_Type_Legal);
            createAffApprover(contractReqLst, System.Label.C3AP_Approver_Type_ATS);
            //Adding Approvers to the Contract Request
            contractReqLst[0].C3AP_ATC_Approver_ID__c= [Select id from C3AP_Affiliate_Approvers__c where Approver_Type__c=:System.Label.C3AP_Approver_Type_ATC limit 1].id;
            contractReqLst[0].C3AP_ATS_Approver_ID__c= [Select id from C3AP_Affiliate_Approvers__c where Approver_Type__c=:System.Label.C3AP_Approver_Type_ATS limit 1].id;
            contractReqLst[0].C3AP_Legal_Approver_ID__c= [Select id from C3AP_Affiliate_Approvers__c where Approver_Type__c=:System.Label.C3AP_Approver_Type_Legal limit 1].id;      
            contractReqLst[0].C3AP_Amendment_Accepted__c=false;
            contractReqLst[0].C3AP_Amend__c=true;
    
            insert contractReqLst; 
            //Creating Attachments to simulate Contract Attachments/Supporting Documentation
            List <Attachment> attachLst = Test_C3AP_TestData_Utility.createContractAttachments(contractReqLst[0]);
            insert attachLst;    
            //Initializing
            ApexPages.StandardController C3APStandardContractRequest = new ApexPages.standardController(contractReqLst[0]); 
            PageReference testPage = Page.C3AP_Contract_Request_Form;
            testPage.getParameters().put('contractId',contractReqLst[0].id);      
    
            test.setCurrentPage(testPage);
            
            C3APContractForm aTestContractForm = new C3APContractForm(C3APStandardContractRequest ); 
    
          
            Test.StartTest();           
               
               C3AP_Contract_Request__c resultContrReq = [SELECT id,C3AP_Legal_Answered__c FROM C3AP_Contract_Request__c  WHERE id=: contractReqLst[0].id];   
              
               aTestContractForm.cancel();

               PageReference pg=aTestContractForm.toLegal();
               System.assertNotEquals(pg,null);
               
               PageReference intro=aTestContractForm.toIntroductory();
               System.assertNotEquals(intro,null);

               aTestContractForm.getTemplate();
               System.assertEquals(aTestContractForm.renderTemplate, true);
                
               aTestContractForm.getAttachmentTypes();
               aTestContractForm.preUpload();   
               System.assertEquals(aTestContractForm.renderUpload, true);               
               aTestContractForm.forUpload.body=Blob.valueof('Hello');
               aTestContractForm.forUpload.Name='Filename';
               aTestContractForm.attachmentType = 'Other';
               try {
                   aTestContractForm.upload();  
               }
               catch(exception exp){ 
                // Asserting the exception caught and displayed while uploading attachment               
               System.assert(exp.getMessage().contains('Error uploading attachment'));
               }  
                        
               aTestContractForm.forUpload.body=Blob.valueof('Hello');
               aTestContractForm.closeUpload(); 
               aTestContractForm.forUpload.Name='Filename';
               aTestContractForm.attachmentType = 'Other';
               try {
                   aTestContractForm.upload();  
               }
               catch(exception exp){ 
                // Asserting the exception caught and displayed while uploading attachment               
                    System.assert(exp.getMessage().contains('Error uploading attachment'));
               } 
               System.assertEquals(aTestContractForm.forUpload.body, null);                                             

               aTestContractForm.save();               
               C3AP_Contract_Request__c conR = [Select id, C3AP_Contract_Save_Toggle__c, C3AP_ATC_Approver__c, C3AP_ATS_Approver__c, C3AP_Legal_Approver__c FROM C3AP_Contract_Request__c  WHERE id=: contractReqLst[0].id];
               System.assertEquals(conR.C3AP_Contract_Save_Toggle__c, false);   
               System.assertNotEquals(conR.C3AP_ATC_Approver__c, null);
               System.assertNotEquals(conR.C3AP_ATS_Approver__c, null);     
               System.assertNotEquals(conR.C3AP_Legal_Approver__c, null);         
               
               conR = [Select id, C3AP_Status__c from C3AP_Contract_Request__c  where id=: contractReqLst[0].id];       
               System.assertEquals(conR.C3AP_Status__c, 'Not Submitted');  
              Test.StopTest();               
        }
    }  
 
 
    /* 
            * @Method Name                    :  testNegativeUpdateContractRequest
            * @Description                    :  Testing of Negative Alternate Scenarios  
            * @Return Type                    :  void
                                              
    */
   
       public static testMethod void testNegativeUpdateContractRequest(){
           User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
           System.runAs(u) {
           
            //Creates an instance of Mico_App__c
            //Test_C3AP_TestData_Utility.createApp();           
           
            //Create affliate record
            List<C3AP_Affiliate__c> affliateList = Test_C3AP_TestData_Utility.createAffiliate(1);
            insert affliateList ;
            
            // Create Affliate Contract record 
            List<C3AP_Affiliate_Contracts__c> affContList = Test_C3AP_TestData_Utility.createAffliateContracts(affliateList[0]);
            insert affContList;
            
            // Create Contract Request record
            List<C3AP_Contract_Request__c> contractReqLst=Test_C3AP_TestData_Utility.createContractReq(1);
            
            //Adding other Contract Request Details 
            contractReqLst[0].C3AP_Department__c = 'Department';
            contractReqLst[0].C3AP_Affiliate__c = affliateList[0].id;
            contractReqLst[0].Affiliate__c = affliateList[0].Name;        
            contractReqLst[0].C3AP_Contract_Type__c = affContList[0].id;  
            contractReqLst[0].C3AP_Amendment_Accepted__c=false;
            contractReqLst[0].C3AP_Final_Sign__c=true;
            contractReqLst[0].C3AP_Status__c =System.Label.C3AP_Status_Pending_Final_Signatures;
            contractReqLst[0].C3AP_Contract_Save_Toggle__c=false;
            contractReqLst[0].C3AP_Legal_Amendment_Accepted__c=false;   
            contractReqLst[0].C3AP_Amend_Legal__c=true;     
            contractReqLst[0].C3AP_Final_Sign__c=false;         
            //Adding Approvers to the Affiliate
            createAffApprover(contractReqLst, System.Label.C3AP_Approver_Type_Legal);
            createAffApprover(contractReqLst, System.Label.C3AP_Approver_Type_ATS);
            //Adding Approvers to the Contract Request
            contractReqLst[0].C3AP_ATS_Approver_ID__c= [Select id from C3AP_Affiliate_Approvers__c where Approver_Type__c=:System.Label.C3AP_Approver_Type_ATS limit 1].id;
            contractReqLst[0].C3AP_Legal_Approver_ID__c= [Select id from C3AP_Affiliate_Approvers__c where Approver_Type__c=:System.Label.C3AP_Approver_Type_Legal limit 1].id;                

            insert contractReqLst; 
            //Creating Attachments to simulate Contract Attachments/Supporting Documentation
            List <Attachment> attachLst = Test_C3AP_TestData_Utility.createContractAttachments(contractReqLst[0]);
            insert attachLst;
    
            //Creating a Custom setting value
            C3AP_Email_Address__c mycs = C3AP_Email_Address__c.getValues(UserInfo.getUserId());
            if(mycs == null) {
                mycs = new C3AP_Email_Address__c(Name= 'CustomValues');
                mycs.Email_Address__c = 'tphil@deloitte.com';
                insert mycs;
                }
            //Initializing   
            ApexPages.StandardController C3APStandardContractRequest = new ApexPages.standardController(contractReqLst[0]); 
            PageReference testPage = Page.C3AP_Contract_Request_Form;
            testPage.getParameters().put('contractId',contractReqLst[0].id);    
            test.setCurrentPage(testPage);       
            C3APContractForm aTestContractForm = new C3APContractForm(C3APStandardContractRequest );     
          
            Test.StartTest();           
               
               C3AP_Contract_Request__c resultContrReq = [SELECT id,C3AP_Legal_Answered__c FROM C3AP_Contract_Request__c  WHERE id=: contractReqLst[0].id];
               
               // Testing whether the parameter set in URL is used up for setting the value of contract request legal approver required field to true via update on contract request
               //system.assertEquals(resultContrReq.C3AP_Legal_Approval_Required__c , false);
    
               Pagereference pg = aTestContractForm.toLegal();
               System.assertNotEquals(pg, null);
    
               pg = aTestContractForm.getTemplate();
               System.assertEquals(pg, null);
              
               aTestContractForm.forUpload.body=Blob.valueof('Hello');
               try {          
               aTestContractForm.save();
                }
               catch(exception exp){ 
                   // Asserting the exception caught and displayed while saving contract request               
                   System.assert(exp.getMessage().contains('Error updating Contract Request'));
                  }             
        
               C3AP_Contract_Request__c conR= [Select id, C3AP_ATC_Approver__c, C3AP_ATS_Approver__c, C3AP_Legal_Approver__c FROM C3AP_Contract_Request__c  WHERE id=: contractReqLst[0].id];
               System.assertEquals(conR.C3AP_ATC_Approver__c, null);
               System.assertEquals(conR.C3AP_ATS_Approver__c, null);     
               System.assertEquals(conR.C3AP_Legal_Approver__c, null);  
                  
              Test.StopTest();
         }
        
    }   

    /* 
            * @Method Name                    :  testNegativeNextUpdateContractRequest
            * @Description                    :  Testing of Alternative Scenarios
            * @Return Type                    :  void
                                              
    */
   
    
    public static testMethod void testNegativeNextUpdateContractRequest(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);
        System.runAs(u) {
            //Creates an instance of Mico_App__c
            //Test_C3AP_TestData_Utility.createApp();        
        
           //create affliate record
            List<C3AP_Affiliate__c> affliateList = Test_C3AP_TestData_Utility.createAffiliate(1);
            insert affliateList ;
            
            // create affliate contract record 
            List<C3AP_Affiliate_Contracts__c> affContList = Test_C3AP_TestData_Utility.createAffliateContracts(affliateList[0]);
            insert affContList;
            
            // create contract request record
            List<C3AP_Contract_Request__c> contractReqLst=Test_C3AP_TestData_Utility.createContractReq(1);
            
            //adding other Contract Request Details 
            contractReqLst[0].C3AP_Department__c = 'Department';
            contractReqLst[0].C3AP_Affiliate__c = affliateList[0].id;
            contractReqLst[0].Affiliate__c = affliateList[0].Name;        
            contractReqLst[0].C3AP_Contract_Type__c = null;  
            contractReqLst[0].C3AP_Status__c =System.Label.C3AP_Status_Pending_Requestor_Review;
            contractReqLst[0].C3AP_Contract_Save_Toggle__c=true;
            insert contractReqLst; 
            //create an attachment list
            List <Attachment> attachLst = Test_C3AP_TestData_Utility.createContractAttachments(contractReqLst[0]);
            insert attachLst;    
            ApexPages.StandardController C3APStandardContractRequest = new ApexPages.standardController(contractReqLst[0]); 
            PageReference testPage = Page.C3AP_Contract_Request_Form;
            testPage.getParameters().put('id',contractReqLst[0].id);   
            testPage.getParameters().put('affiliateId', 'true');
            test.setCurrentPage(testPage);
            
            C3APContractForm aTestContractForm = new C3APContractForm(C3APStandardContractRequest );   
          
            Test.StartTest();           
               
               aTestContractForm.cancel();
               aTestContractForm.getTemplate();        
               aTestContractForm.upload();
               C3AP_Contract_Request__c conR = [Select id, C3AP_Contract_Save_Toggle__c FROM C3AP_Contract_Request__c  WHERE id=: contractReqLst[0].id];
               System.assertEquals(conR.C3AP_Contract_Save_Toggle__c, true);   
               aTestContractForm.save();                                 
               Test.StopTest();   
        }                  
    }  
 
 
    public static C3AP_Affiliate_Approvers__c createAffApprover(List <C3AP_Contract_Request__c> conReqObjLst, String type) {
            C3AP_Affiliate_Approvers__c affP= new C3AP_Affiliate_Approvers__c();
            affP.C3AP_Affiliate__c=conReqObjLst[0].C3AP_Affiliate__c;
            affP.C3AP_Approver_Name__c=UserInfo.getUserId();
            affP.Approver_Type__c=type;
            insert affP;
            return affP;
    }
    
   /* 
            * @Method Name                    :  codeBreakageTest
            * @Description                    :  Testing of scenario where contract update would fail and error would be 
                                                 logged in the GLBL_Error_Log__c object
            * @Return Type                    :  void
                                              
    */
    public static testMethod void codeBreakageTest(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);       
        System.runAs(u){  
            Test.startTest();       
                List<C3AP_Contract_Request__c> contractReqLst=Test_C3AP_TestData_Utility.createContractReq(1);
                contractReqLst[0].C3AP_Legal_Approver__c = u.Id;
                contractReqLst[0].C3AP_ATC_Approver__c = u.Id;
                contractReqLst[0].C3AP_ATS_Approver__c = u.Id;
                insert contractReqLst[0];
                ApexPages.StandardController C3APStandardContractRequest = new ApexPages.standardController(contractReqLst[0]); 
                PageReference testPage = Page.C3AP_Contract_Request_Form;
                TestPage.getParameters().put('contractId',contractReqLst[0].id);      
                Test.setCurrentPage(testPage);
                ApexPages.StandardController sc = new ApexPages.standardController(contractReqLst[0]);
                C3APContractForm ccf = new C3APContractForm(sc);
                ccf.contractRequest = new C3AP_Contract_Request__c();
                ccf.updateContractDML();
                System.assert([Select Additional_Information__c from GLBL_Error_Log__c Order By CreatedDate Desc Limit 1].Additional_Information__c.contains('Error updating Contract Request :')); 
            Test.stopTest();
        }
    }
}