@isTest(seeAllData=false)
public with sharing class Test_C3APAttachmentTrigger {
    static testmethod void preventDeletionAttachment_ContractInitiator(){
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);       
        System.runAs(u){  
            Test.startTest();       
                List<C3AP_Contract_Request__c> contractReqLst=Test_C3AP_TestData_Utility.createContractReq(1);
                insert contractReqLst[0];
                List <Attachment> attachLst = Test_C3AP_TestData_Utility.createContractAttachments(contractReqLst[0]);
                insert attachLst;   
                List<Database.DeleteResult> delResults = Database.delete([Select Id from Attachment where ParentId =:contractReqLst[0].Id],false);
                for(Database.DeleteResult dr : delResults){
                    System.assert(!dr.isSuccess());
                }
                System.assertEquals([Select Id from Attachment where ParentId =:contractReqLst[0].Id].size(),attachLst.size());
            Test.stopTest();
        }
    }
    
    static testmethod void preventDeletionAttachment_C3AppAdmin(){
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'C3AP_App_Admin'];
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);   
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.id,PermissionSetId = ps.ID);
        insert psa;
        System.runAs(u){  
            Test.startTest();       
                List<C3AP_Contract_Request__c> contractReqLst=Test_C3AP_TestData_Utility.createContractReq(1);
                insert contractReqLst[0];
                List <Attachment> attachLst = Test_C3AP_TestData_Utility.createContractAttachments(contractReqLst[0]);
                insert attachLst;           
                Attachment updateAttachments = [Select Id,Description from Attachment where PArentId =:contractReqLst[0].Id LIMIT 1];
                updateAttachments.Description = 'Test Update';
                Database.SaveResult updResults = Database.update(updateAttachments,false);
                System.assert(!updResults.isSuccess());                
                List<Database.DeleteResult> delResults = Database.delete([Select Id from Attachment where ParentId =:contractReqLst[0].Id],false);
                for(Database.DeleteResult dr : delResults){
                    System.assert(!dr.isSuccess());
                }
                System.assertEquals([Select Id from Attachment where ParentId =:contractReqLst[0].Id].size(),attachLst.size());
            Test.stopTest();
        }
    }
    
    static testmethod void preventDeletionAttachment_ContractApprover(){
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'C3AP_Approvers'];
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);   
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.id,PermissionSetId = ps.ID);
        insert psa;
        System.runAs(u){  
            Test.startTest();       
                List<C3AP_Contract_Request__c> contractReqLst=Test_C3AP_TestData_Utility.createContractReq(1);
                insert contractReqLst[0];
                List <Attachment> attachLst = Test_C3AP_TestData_Utility.createContractAttachments(contractReqLst[0]);
                insert attachLst;           
                List<Database.DeleteResult> delResults = Database.delete([Select Id from Attachment where ParentId =:contractReqLst[0].Id],false);
                for(Database.DeleteResult dr : delResults){
                    System.assert(!dr.isSuccess());
                }
                System.assertEquals([Select Id from Attachment where ParentId =:contractReqLst[0].Id].size(),attachLst.size());
            Test.stopTest();
        }
    }
}