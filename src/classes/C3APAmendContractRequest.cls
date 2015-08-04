/*
* @Name: C3APAmendContractRequest
* @Description: Developed as the controller for supporting the "Amend" functionality of the contract request
* @date Latest:Feb 2, 2015
* @author Abhinav Gadepalli 
*/
global with sharing class C3APAmendContractRequest{     
        /* 
     * Method name : validateEligibilityForAmend
     * Description :  This method validates if the logged in user has appropriate previleges to amend the contract that is in the 
                                  right status for amendment 
     * Param :  contractId - the id of the contract request record on which the "Amend" button is clicked
     * Returns :  boolean 
    */
    webservice static boolean validateEligibilityForAmend(Id contractReqId){

                boolean isContractInitiator = false;
                boolean allowedToAmend = false;
        C3AP_Contract_Request__c contractrequest = [SELECT toLabel(C3AP_Status__c),C3AP_Legal_Approver__c,C3AP_ATS_Approver__c,
                                                                                            OwnerId,C3AP_ATC_Approver__c 
                                                                                            FROM C3AP_Contract_Request__c 
                                                                                            WHERE Id =: Id.valueOf(contractReqId)];

        /* The logged in user would be allowed to amend the contratc request if :
         *    1. The status is Pending Legal Approval and the logged in user is the Legal Approver
         *    2. The status is Pending ATC Approval and the logged in user is the ATC Approver
         *    3. The logged in user is the contract initiator and the status is "Completed" or "Pending Final Signatures" or "Not Approved by xxx"
        */ 
        if((contractrequest.C3AP_Legal_Approver__c==Userinfo.getuserid() && contractrequest.C3AP_Status__c==Label.C3AP_Status_Pending_Legal_Approval) 
                || (contractrequest.C3AP_ATC_Approver__c==Userinfo.getuserid() && contractrequest.C3AP_Status__c==Label.C3AP_Status_Pending_ATC_Approval)
                || (contractrequest.OwnerId==Userinfo.getuserid() 
                        && (contractrequest.C3AP_Status__c==Label.C3AP_Status_Pending_Final_Signatures || contractrequest.C3AP_Status__c==Label.C3AP_Status_Completed || contractrequest.C3AP_Status__c== Label.C3AP_Status_Not_Approved_By_ATS || contractrequest.C3AP_Status__c== Label.C3AP_Status_Not_Approved_By_Legal || contractrequest.C3AP_Status__c== Label.C3AP_Status_Not_Approved_By_ATC))){
                allowedToAmend = true;
        }
        return allowedToAmend;
    }
    
    /* 
     * Method name : saveAmendedContract
     * Description :  This method updates the amended flag when the logged in user confirms that the appropraite amendments/activities
                                  on the contract request object have been completed 
     * Param :  contractId - the id of the contract request record on which the "Amend" button is clicked
     * Returns :  none 
    */
    @RemoteAction
    public static void saveAmendedContract(String contractId){
       C3AP_Contract_Request__c contractrequest = [SELECT Id,toLabel(C3AP_Status__c),C3AP_Legal_Approver__c,C3AP_ATS_Approver__c,
                                                                                           OwnerId,C3AP_ATC_Approver__c,C3AP_Amend_Legal__c,C3AP_Amend__c,C3AP_Is_Amend_Transaction__c,
                                                                                           C3AP_Amended_By_CI__c,C3AP_ATC_Approved__c,C3AP_ATS_Approved__c,C3AP_Legal_Approved__c
                                                                                           FROM C3AP_Contract_Request__c 
                                                                                           WHERE Id =: Id.valueOf(contractId)];
       /* The logged in user would be allowed to amend the contract request and update the amend flag if :
         *    1. The status is Pending Legal Approval and the logged in user is the Legal Approver
         *        2. The status is Pending ATC Approval and the logged in user is the ATC Approver
        */ 
       if(contractrequest.C3AP_Legal_Approver__c==Userinfo.getuserid() && contractRequest.C3AP_Status__c == Label.C3AP_Status_Pending_Legal_Approval) {
                contractRequest.C3AP_Amend_Legal__c = true; 
                contractRequest.C3AP_Is_Amend_Transaction__c = false;                   
                update contractRequest;
       }
       else if(contractrequest.C3AP_ATC_Approver__c==Userinfo.getuserid() && contractRequest.C3AP_Status__c == Label.C3AP_Status_Pending_ATC_Approval) {
            contractRequest.C3AP_Amend__c = true;
            contractRequest.C3AP_Is_Amend_Transaction__c = false;
            update contractRequest;
       } 
       else if(contractrequest.OwnerId==Userinfo.getuserid() && (contractrequest.C3AP_Status__c== Label.C3AP_Status_Completed || contractrequest.C3AP_Status__c== Label.C3AP_Status_Pending_Final_Signatures)){
                contractRequest.C3AP_Amend__c = false;
                contractRequest.C3AP_Amend_Legal__c = false;
                contractRequest.C3AP_Amended_By_CI__c = true;                
            contractRequest.C3AP_Is_Amend_Transaction__c = false;
            update contractRequest;
       }
       else if(contractrequest.OwnerId==Userinfo.getuserid() && (contractrequest.C3AP_Status__c== Label.C3AP_Status_Not_Approved_By_ATS || contractrequest.C3AP_Status__c== Label.C3AP_Status_Not_Approved_By_Legal || contractrequest.C3AP_Status__c== Label.C3AP_Status_Not_Approved_By_ATC)){
                contractRequest.C3AP_Amend__c = false;
                contractRequest.C3AP_Amend_Legal__c = false;
                contractRequest.C3AP_Amended_By_CI__c = true;                
            	contractRequest.C3AP_Is_Amend_Transaction__c = false;
            	contractRequest.C3AP_ATC_Approved__c = false;
            	contractRequest.C3AP_ATS_Approved__c = false;
            	contractRequest.C3AP_Legal_Approved__c = false;
            	update contractRequest;
       }              
    }
    
    public C3APAmendContractRequest(ApexPages.StandardController controller) {
    
    }
}