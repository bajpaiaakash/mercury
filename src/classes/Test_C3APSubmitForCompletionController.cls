@isTest(seeAllData = false)
private class Test_C3APSubmitForCompletionController {
    
    /* 
     * Method name : validateSubmission_PositiveScenario_ContractInitiator
     * Description :  This methods is used to test the scenario of the logged in user being the contract initiator and trying to submit contract for completion
     * Param :  None 
     * Returns :  None
    */
    static testMethod void validateSubmission_PositiveScenario_ContractInitiator() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);       
        System.runAs(u){  
            Test.startTest();       
                boolean returnBoolean = C3APSubmitForCompletionController.validateSubmission(u.Id,'Pending_Final_Signatures');
                System.assert(returnBoolean);
            Test.stopTest();
        }
    }
    /* 
     * Method name : validateSubmission_PositiveScenario_ContractInitiator
     * Description :  This methods is used to test the scenario of a System Administrotor trying to move a contract 
                      to completion 
     * Param :  None 
     * Returns :  None
    */
    static testMethod void validateSubmission_PositiveScenario_SystemAdmin() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);   
        User u1=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_System_Administrator); 
        u1.Username = u1.Username +String.valueOf(1);          
        System.runAs(u1){  
            Test.startTest();       
                boolean returnBoolean = C3APSubmitForCompletionController.validateSubmission(u.Id,'Pending_Final_Signatures');
                System.assert(returnBoolean);
            Test.stopTest();
        }
    }
    /* 
     * Method name : validateSubmission_PositiveScenario_ContractInitiator
     * Description : This methods is used to test the scenario of a C3 App Admin trying to move a contract 
                     to completion   
     * Param :  None 
     * Returns :  None
    */
    static testMethod void validateSubmission_PositiveScenario_C3AppAdmin() {
        User u1=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);   
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'C3AP_App_Admin'];
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);   
        u.Username = u.Username +String.valueOf(1);  
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.id,PermissionSetId = ps.ID);
        insert psa;           
        System.runAs(u){  
            Test.startTest();       
                boolean returnBoolean = C3APSubmitForCompletionController.validateSubmission(u1.Id,'Pending_Final_Signatures');
                System.assert(returnBoolean);
            Test.stopTest();
        }
    }
    /* 
     * Method name : validateSubmission_NegativeScenario_CompletedStatus
     * Description :  This methods is used to test the scenario of trying to move a contract that is not in
                      "Pending Final Signatures" to completion                    
     * Param :  None 
     * Returns :  None
    */
    static testMethod void validateSubmission_NegativeScenario_CompletedStatus() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);       
        System.runAs(u){  
            Test.startTest();       
                boolean returnBoolean = C3APSubmitForCompletionController.validateSubmission(u.Id,'Completed');
                System.assert(!returnBoolean);
            Test.stopTest();
        }
    }
    
    /* 
     * Method name : returnConfirmationMessage_PositiveTest
     * Description :  This methods is used to test the confirmation message that the user must confirm 
                      before submitting the contract for completion
     * Param :  None 
     * Returns :  None
    */
    static testMethod void returnConfirmationMessage_PositiveTest() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);       
        System.runAs(u){  
            Test.startTest();       
                String returnString = C3APSubmitForCompletionController.returnConfirmationMessage();
                System.assertEquals(returnString,System.Label.C3AP_Completion_Checkpoints);
            Test.stopTest();
        }
    }
    
    /* 
     * Method name : validateCancellation_PositiveScenario_ContractInitiator
     * Description :  This methods is used to test the scenario of the logged in user being the contract initiator and trying to submit contract for completion
     * Param :  None 
     * Returns :  None
    */
    static testMethod void validateCancellation_PositiveScenario_ContractInitiator() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);       
        System.runAs(u){  
            Test.startTest();       
                boolean returnBoolean = C3APSubmitForCompletionController.validateCancellation(u.Id,'Not_Approved_By_ATC');
                System.assert(returnBoolean);
            Test.stopTest();
        }
    }
    
    /* 
     * Method name : validateCancellation_PositiveScenario_ContractInitiator
     * Description :  This methods is used to test the scenario of the logged in user being the contract initiator and trying to submit contract for completion
     * Param :  None 
     * Returns :  None
    */
    static testMethod void validateCancellation_NegativeScenario_InvalidStatus() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);       
        System.runAs(u){  
            Test.startTest();       
                boolean returnBoolean = C3APSubmitForCompletionController.validateCancellation(u.Id,'Pending_Legal_Approval');
                System.assert(!returnBoolean);
            Test.stopTest();
        }
    }
    
    /* 
     * Method name : validateReverseTermination_Positive
     * Description :  This methods is used to test the scenario of the logged in user being the C3 App Admin and trying to reverse terminate contract
     * Param :  None 
     * Returns :  None
    */
    static testMethod void validateReverseTermination_Positive() {    
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'C3AP_App_Admin'];
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);   
        u.Username = u.Username +String.valueOf(1);  
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.id,PermissionSetId = ps.ID);
        insert psa;     
        System.runAs(u){  
            Test.startTest();       
                boolean returnBoolean = C3APSubmitForCompletionController.validateReverseTermination('Terminated');
                System.assert(returnBoolean);
            Test.stopTest();
        }
    }
    
    /* 
     * Method name : validateReverseTermination_Positive
     * Description :  This methods is used to test the scenario of the logged in user being the C3 App Admin and trying to reverse terminate contract
     * Param :  None 
     * Returns :  None
    */
    static testMethod void validateReverseTermination_Negative() {
        User u=Test_C3AP_TestData_Utility.createUser(System.Label.C3AP_GSO_Profile_Name);   
        System.runAs(u){  
            Test.startTest();       
                boolean returnBoolean = C3APSubmitForCompletionController.validateReverseTermination('Terminated');
                System.assert(!returnBoolean);
            Test.stopTest();
        }
    }
}