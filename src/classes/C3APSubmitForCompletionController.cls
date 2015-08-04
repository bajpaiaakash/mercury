/*
* @Name: C3APSubmitForCompletionController
* @Description: Developed for supporting the "Submit for Completion" functionality that is invoked through the button
                on the Contract Request page layout. It contains methods that move a contract to completed status from 'Pending Final Signatures'
* @date Latest:Jan 22, 2015
* @author Abhinav Gadepalli
*/

global with sharing class C3APSubmitForCompletionController{

	/* 
     * Method name : validateSubmission
     * Description :  This method is used to validate if a contract that is submitted for completion meets the apropriate criteria for it to be completed
     * Param :  Id of the Contract Initiator, status of the contract
     * Returns :  String 
    */
    webservice static boolean validateSubmission(Id contractInitiator,String contractStatus){
    	PermissionSet ps = [SELECT ID From PermissionSet WHERE Name =: Label.C3AP_App_Admin];
    	List<PermissionSetAssignment> psaList = [Select Id from PermissionSetAssignment where AssigneeId =: UserInfo.getUserId() and PermissionSetId =: ps.ID];
    	boolean returnBoolean = false;
    	Id sysAdminProfileId = [Select Id from Profile where Name =: Label.C3AP_System_Administrator].Id;
    	if((UserInfo.getUserId() == contractInitiator || psaList.size() > 0 || sysAdminProfileId.equals(UserInfo.getProfileId())) && contractStatus == 'Pending_Final_Signatures'){
    		returnBoolean = true;
    	}
    	else{
    		returnBoolean =  false;
    	}
    	return returnBoolean;
    }
    
    /* 
     * Method name : returnConfirmationMessage
     * Description :  This method is used to show the confirmation message when the contract initiator is trying to submit a contract for submission
     * Param :  none
     * Returns :  String 
    */
    webservice static String returnConfirmationMessage(){
    	return System.Label.C3AP_Completion_Checkpoints; 	
    }
    
    /* 
     * Method name : validateSubmission
     * Description :  This method is used to validate if a contract that is submitted for completion meets the apropriate criteria for it to be completed
     * Param :  Id of the Contract Initiator, status of the contract
     * Returns :  String 
    */
    webservice static boolean validateCancellation(Id contractInitiator,String contractStatus){
    	//PermissionSet ps = [SELECT ID From PermissionSet WHERE Name =: Label.C3AP_App_Admin];
    	//List<PermissionSetAssignment> psaList = [Select Id from PermissionSetAssignment where AssigneeId =: UserInfo.getUserId() and PermissionSetId =: ps.ID];
    	boolean returnBoolean = false;
    	//Id sysAdminProfileId = [Select Id from Profile where Name =: Label.C3AP_System_Administrator].Id;
    	if(UserInfo.getUserId() == contractInitiator  && (contractStatus == 'Not_Approved_By_ATC' || contractStatus == 'Not_Approved_By_ATS' || contractStatus == 'Not_Approved_By_Legal')){
    		returnBoolean = true;
    	}
    	else{
    		returnBoolean =  false;
    	}
    	return returnBoolean;
    }
    
    /* 
     * Method name : validateSubmission
     * Description :  This method is used to validate if a contract that is submitted for completion meets the apropriate criteria for it to be completed
     * Param :  Id of the Contract Initiator, status of the contract
     * Returns :  String 
    */
    webservice static boolean validateReverseTermination(String contractStatus){
    	PermissionSet ps = [SELECT ID From PermissionSet WHERE Name =: Label.C3AP_App_Admin];
    	List<PermissionSetAssignment> psaList = [Select Id from PermissionSetAssignment where AssigneeId =: UserInfo.getUserId() and PermissionSetId =: ps.ID];
    	boolean returnBoolean = false;    	
    	if(psaList.size() > 0  && contractStatus == 'Terminated'){
    		returnBoolean = true;
    	}
    	else{
    		returnBoolean =  false;
    	}
    	return returnBoolean;
    }
}