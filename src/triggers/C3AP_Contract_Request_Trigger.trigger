trigger C3AP_Contract_Request_Trigger on C3AP_Contract_Request__c (after insert, after update, after delete, before update) {
    
    //instantiate the utility class
    C3APContractRequestUtilityClass cruc = new C3APContractRequestUtilityClass();
    
    if(Trigger.isAfter) {
        
        if(Trigger.isInsert || Trigger.isUpdate){
            
            
            // always call approval process on create or update.
            cruc.call_next_approval_process(Trigger.newMap);
            system.debug('@@@@@@@@trigger.newMap after call next is:'+trigger.newMap);
            
            /************/
            // fetch all new Contract Request records from database 
            Map<Id, C3AP_Contract_Request__c> mapConRequestsNew = new Map<Id, C3AP_Contract_Request__c>();
            
            for(C3AP_Contract_Request__c conReq:[SELECT Id, Name, OwnerId, C3AP_Affiliate__c, Affiliate__c, 
                                                            C3AP_Amend__c, C3AP_Amended_By_CI__c, 
                                                            C3AP_Amend_Legal__c, C3AP_Approver_Comments__c, 
                                                            C3AP_ATC_Approval_Required__c, C3AP_ATC_Approved__c,
                                                            C3AP_ATC_Approver_ID__c, C3AP_ATC_Approver_Activated__c, 
                                                            C3AP_ATC_Approver_Feedback__c, C3AP_ATC_Approver__c, 
                                                            C3AP_ATC_Approver_Name__c, C3AP_Amendment_Accepted__c, 
                                                            C3AP_ATC_Required_Questions_Count__c, C3AP_ATS_Approved__c, 
                                                            C3AP_ATS_Approver_ID__c, C3AP_ATS_Approver_Activated__c, 
                                                            C3AP_ATS_Approver__c, C3AP_ATS_Approver_Name__c, 
                                                            C3AP_Base_URL__c, C3AP_Commencement_Date__c, 
                                                            C3AP_Contract_Request_ID__c, C3AP_Contract_Save_Toggle__c, 
                                                            C3AP_Contract_Template__c, C3AP_Contract_Type__c, 
                                                            C3AP_Department__c, C3AP_ETP_Contact_Name__c, 
                                                            C3AP_ETP_Contact_Number__c, C3AP_ETP_Entity_Name__c, 
                                                            C3AP_ETP_ID__c, C3AP_Expiry_Date__c, 
                                                            C3AP_External_Id__c, C3AP_Final_Sign__c, 
                                                            C3AP_High_Risk_Contract__c, C3AP_High_Risk_Questions_Answered_Yes__c, 
                                                            C3AP_Is_Amend_Transaction__c, C3AP_IsApprover__c, 
                                                            C3AP_IsOwner__c, C3AP_Legal_Amendment_Accepted__c, 
                                                            C3AP_Legal_Approver_Required__c, C3AP_Legal_Approved__c, 
                                                            C3AP_Legal_Approver_ID__c, C3AP_Legal_Approver_Activated__c, 
                                                            C3AP_Legal_Approver_Email__c, C3AP_Legal_Approver_Feedback__c, 
                                                            C3AP_Legal_Approver__c, C3AP_Legal_Approver_Name__c, 
                                                            C3AP_Legal_Answered__c, C3AP_Legal_Required_Questions_Count__c, 
                                                            C3AP_Other_Contract_Archival_System__c, C3AP_ATC_Reject__c, 
                                                            C3AP_Rejected_by_ATS__c, C3AP_Legal_Reject__c, 
                                                            C3AP_Reminder_Date__c, C3AP_Services__c, 
                                                            C3AP_Status__c, C3AP_Submitted_for_Approval__c, 
                                                            C3AP_Terminated__c, C3AP_Translation_Independent_Status__c, 
                                                            C3AP_Owner__c 
                                                            FROM C3AP_Contract_Request__c 
                                                            WHERE Id IN :Trigger.newMap.keyset()] ){
                mapConRequestsNew.put(conReq.Id,conReq);
            }
            
            
            
            // create or update the summary record for these requests.
            //cruc.upsertSummaries (trigger.newMap);
            
            // sending the queried map of contract requests with latest values from database
            cruc.upsertSummaries (mapConRequestsNew);
            
            system.debug('@@@@@@@@trigger.newMap is:'+trigger.newMap);
            
            // if it's an update, also amend sharing and send emails.
            if(Trigger.isUpdate){               
                cruc.shareRecordWithApprovers(Trigger.oldMap,Trigger.newMap);
                cruc.reassignProcessRequest(Trigger.oldMap, Trigger.newMap);
            }
        }
        
        if (trigger.isDelete) {
            // remove summary records if we remove the parent request.
            cruc.deleteSummaries (trigger.oldMap);
        }
        

    } 

    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            cruc.skipLegalAfterAmend(Trigger.oldMap, Trigger.newMap);
        }
        if(trigger.isInsert || trigger.isUpdate){
            cruc.updateTranslationIndependentStatusField(trigger.new);
        }
    }
}