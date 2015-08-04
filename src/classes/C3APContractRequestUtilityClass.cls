/*
 * This is a trigger utility class for C3AP_Contract_Request__Trigger
 *  
 */
public class C3APContractRequestUtilityClass{
    
    /* 
     * Method name : call_next_approval_process
     * Description : checks if any new or updated contract record has C3AP_Legal_Approver_Activated__c or C3AP_ATS_Approver_Activated__c check boxes true or not. 
     * Param - list of new or updated contract records. 
     * Returns :  none.
    */
    public void call_next_approval_process(Map<Id,C3AP_Contract_Request__c> mapContractRequests){
        Map<Id,ProcessInstance> pendingApprovals = new Map<Id,ProcessInstance>();
        for(ProcessInstance p: [Select Id,Status,TargetObjectId From ProcessInstance WHERE TargetObjectId IN :mapContractRequests.keySet() AND Status = 'Pending']){
            pendingApprovals.put(p.TargetObjectId,p);
        }
        
        for(C3AP_Contract_Request__c crRec :mapContractRequests.values()){
            // automate the submission of the legal approval process
           if(pendingApprovals.get(crRec.Id) == null && crRec.C3AP_Legal_Approver_Activated__c == True && crRec.C3AP_Status__c!= 'Pending Legal Approval' && crRec.C3AP_Legal_Approved__c == False && crRec.C3AP_Status__c!= 'Not Approved By Legal'){                
                processRequest(crRec.Id); 
            }
            // automate the submission of the ATS approval process
            else if (pendingApprovals.get(crRec.Id) == null && crRec.C3AP_ATS_Approver_Activated__c == True && crRec.C3AP_Status__c != 'Pending ATS Approval' && crRec.C3AP_ATS_Approved__c == False && crRec.C3AP_Status__c!= 'Pending Final Signatures' && crRec.C3AP_Status__c != 'Not Approved By ATS'){                
                processRequest(crRec.Id); 
            }
        }
    }
    
     /* 
     * Method name : processRequest
     * Description : submits an appproval process
     * Param : crRecId - the id of the 3AP_Contract_Request__c record. 
     * Returns :  none.
    */
    private void processRequest(Id crRecId){
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(crRecId);
        // submit the approval request for processing
        Approval.ProcessResult result = Approval.process(req);
    }
    
      /* 
     * Method name : reassignProcessRequest
     * Description : reassigns the approval to anotehr Affilate Approver
     * Param : list of of old and new contract records. 
     * Returns :  none.
     */
    public void reassignProcessRequest(map<id,C3AP_Contract_Request__c> mapOldCrRecds, map<id,C3AP_Contract_Request__c> mapNewCrRecds){
        List<ProcessInstanceWorkItem> workItemList = [SELECT p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,p.ProcessInstanceId,p.OriginalActorId,p.Id,p.ActorId
                                                      FROM ProcessInstanceWorkitem p 
                                                      WHERE p.ProcessInstance.TargetObjectId = :mapNewCrRecds.keyset()
                                                            AND p.ProcessInstance.Status = 'Pending'];
        if(!workItemList.isEmpty()){
            for(ProcessInstanceWorkItem wi :workItemList){
                for(C3AP_Contract_Request__c crRec :mapNewCrRecds.values()){                    
                    if(mapOldCrRecds.get(crRec.id).C3AP_ATC_Approver__c != mapNewCrRecds.get(crRec.id).C3AP_ATC_Approver__c && mapNewCrRecds.get(crRec.id).C3AP_Status__c == 'Pendng ATC Approval'){
                        wi.ActorId  = mapNewCrRecds.get(crRec.id).C3AP_ATC_Approver__c;
                    }
                    
                    else if(mapOldCrRecds.get(crRec.id).C3AP_Legal_Approver__c != mapNewCrRecds.get(crRec.id).C3AP_Legal_Approver__c && mapNewCrRecds.get(crRec.id).C3AP_Status__c == 'Pending Legal Approval'){
                        wi.ActorId  = mapNewCrRecds.get(crRec.id).C3AP_Legal_Approver__c;
                    }
                    
                    else if(mapOldCrRecds.get(crRec.id).C3AP_ATS_Approver__c != mapNewCrRecds.get(crRec.id).C3AP_ATS_Approver__c && mapNewCrRecds.get(crRec.id).C3AP_Status__c == 'Pending ATS Approval'){
                        wi.ActorId  = mapNewCrRecds.get(crRec.id).C3AP_ATS_Approver__c;
                    }
                }
            }
        }
        try{
            update workItemList;
            system.debug('@@@@@@@@@@@ conReq Old is: '+mapOldCrRecds);
            system.debug('@@@@@@@@@@@ conReq new is: '+mapNewCrRecds);
        }
        catch (DMLexception e){                       
            GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(   Error_Datetime__c= DateTime.Now(),
                                                                    Error_Message__c= e.getMessage(),
                                                                    Running_User__c = UserInfo.getUserId() ,
                                                                    Stack_Trace__c = e.getStackTraceString(),
                                                                    Additional_Information__c = 'C3AP_Contract_Request_Utility_Class - reassignProcessRequest'
                                                                    );  
            insert errlog;
        }
    }

     /* 
     * Method name : shareRecordWithApprovers
     * Description : share the contract request record with its specified approvers
     * Param : list of updated contract records.
     * Returns :  none.
    */
    public void shareRecordWithApprovers(Map<Id,C3AP_Contract_Request__c> oldContractReq,Map<Id,C3AP_Contract_Request__c> newContractReq){
        list<C3AP_Contract_Request__share> lstContractRequestShareRecds = new list<C3AP_Contract_Request__share> ();
        boolean sharingRevaluationRequired = false;
        for(Id i : newContractReq.keySet()){
            if(newContractReq.get(i).C3AP_ATC_Approver__c <> oldContractReq.get(i).C3AP_ATC_Approver__c 
            || newContractReq.get(i).C3AP_ATS_Approver__c <> oldContractReq.get(i).C3AP_ATS_Approver__c
            || newContractReq.get(i).C3AP_Legal_Approver__c <> oldContractReq.get(i).C3AP_Legal_Approver__c){
                sharingRevaluationRequired = true;
            }
        }
        if(sharingRevaluationRequired){
            List<C3AP_Contract_Request__Share> existShareRecords = [Select Id from C3AP_Contract_Request__Share where RowCause = 'Manual'
                                                                                                               AND ParentId IN :newContractReq.keySet() ];
            for(C3AP_Contract_Request__c  crRec :newContractReq.values()){
                C3AP_Contract_Request__share crShareAtcRec = new C3AP_Contract_Request__share ();
                C3AP_Contract_Request__share crShareLegalRec = new C3AP_Contract_Request__share ();
                C3AP_Contract_Request__share crShareAtsRec = new C3AP_Contract_Request__share ();
    
                    if(String.isNotBlank(crRec.C3AP_ATC_Approver_ID__c)){
                        crShareAtcRec.ParentId = crRec.id;
                        crShareAtcRec.UserOrGroupId = crRec.C3AP_ATC_Approver__c;
                        crShareAtcRec.AccessLevel = system.label.C3AP_Apex_Sharing_Access_Level;
                        lstContractRequestShareRecds.add(crShareAtcRec);                   
                    }
                    //provide read and write access to Legal approver
                    if(String.isNotBlank(crRec.C3AP_Legal_Approver_ID__c)){
                        crShareLegalRec.ParentId = crRec.id;
                        crShareLegalRec.UserOrGroupId = crRec.C3AP_Legal_Approver__c;
                        crShareLegalRec.AccessLevel = system.label.C3AP_Apex_Sharing_Access_Level;
                        lstContractRequestShareRecds.add(crShareLegalRec);
                    }
                    //provide read and write access to ATS approver
                    if(String.isNotBlank(crRec.C3AP_ATS_Approver_ID__c)){
                        crShareAtsRec.ParentId = crRec.id;
                        crShareAtsRec.UserOrGroupId = crRec.C3AP_ATS_Approver__c;
                        crShareAtsRec.AccessLevel = system.label.C3AP_Apex_Sharing_Access_Level;                 
                        lstContractRequestShareRecds.add(crShareAtsRec);
                    }
                  
            }
            try {
                delete existShareRecords;
                insert lstContractRequestShareRecds;
                
                system.debug('@@@@@@@@@@@ conReq Old shareRecordWithApprovers is: '+oldContractReq);
                system.debug('@@@@@@@@@@@ conReq new shareRecordWithApprovers is: '+newContractReq);
            }
            catch (Exception e) {
                System.debug(system.label.C3AP_Error_Sharing_Records+' '+ e);
                //String aId = [Select id from MICO_App__c where name=:System.Label.C3AP_Application_Name].id;                    
                GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(   Error_Datetime__c= DateTime.Now(),
                                                                        Error_Message__c= e.getMessage(),
                                                                        Running_User__c = UserInfo.getUserId() ,
                                                                        Stack_Trace__c = e.getStackTraceString(),
                                                                        Additional_Information__c = system.label.C3AP_Error_Sharing_Records+' :C3AP_Contract_Request_Utility_Class - shareRecordWithApprovers'
                                                                       // App__c = aId
                                                                        );  
                insert errlog;
             }    
        }
          
    }
    
    
    /*
     * Create or update Summary records for all passed-in contract requests
     */
     public void upsertSummaries (Map<Id, C3AP_Contract_Request__c> requests) {
        
        // initialise summaries to upsert
        List<C3AP_Contract_Request_Summary__c> summaries = new List<C3AP_Contract_Request_Summary__c>();
        
        // fetch all existing summaries to update
        List<C3AP_Contract_Request_Summary__c> existingSummaries = [SELECT 
                                                                        Id, Name, OwnerId,
                                                                        C3AP_Affiliate__c,
                                                                        C3AP_ATC_Approver_Name__c,
                                                                        C3AP_ATS_Approver_Name__c,
                                                                        C3AP_Commencement_Date__c,
                                                                        C3AP_Expiry_Date__c,
                                                                        C3AP_Contract_Request__c,
                                                                        C3AP_Contract_Request_Owner__c,
                                                                        C3AP_ETP_Entity_Name__c,
                                                                        C3AP_Legal_Approver_Name__c,
                                                                        C3AP_Status__c,
                                                                        C3AP_Services__c
                                                                    FROM C3AP_Contract_Request_Summary__c 
                                                                    WHERE C3AP_Contract_Request__c IN :requests.keySet()];

        Map<Id, C3AP_Contract_Request_Summary__c> requestSummaries = new Map<Id, C3AP_Contract_Request_Summary__c>();

        for (C3AP_Contract_Request_Summary__c summary : existingSummaries) {
            requestSummaries.put(summary.C3AP_Contract_Request__c, summary);
        }
        
        // go through each request. If we can find the summary, then update it. Otherwise make a new one
        for (Id requestId : requests.keySet()) {
            
            C3AP_Contract_Request__c request = requests.get(requestId);
            C3AP_Contract_Request_Summary__c summary;
            
            if (requestSummaries.containsKey(requestId)) {
                summary = requestSummaries.get(requestId);
            }
            else {
                summary = new C3AP_Contract_Request_Summary__c();
            }
            
            summary.C3AP_Contract_Request__c = request.Id;
            summary.Name = 'CS-' + request.Name.split('-', 2)[1];
            summary.C3AP_Contract_Request_Id__c = request.Id; //need this so we retain the Id for after delete actions
            summary.C3AP_Contract_Request_Owner__c = request.OwnerId;
            summary.C3AP_Affiliate__c = request.C3AP_Affiliate__c;
            summary.C3AP_ATC_Approver_Name__c = request.C3AP_ATC_Approver__c;
            summary.C3AP_ATS_Approver_Name__c = request.C3AP_ATS_Approver__c;
            summary.C3AP_Legal_Approver_Name__c = request.C3AP_Legal_Approver__c;
            summary.C3AP_Commencement_Date__c = request.C3AP_Commencement_Date__c;
            summary.C3AP_Expiry_Date__c = request.C3AP_Expiry_Date__c;
            summary.C3AP_ETP_Entity_Name__c = request.C3AP_ETP_Entity_Name__c;
            summary.C3AP_Status__c = request.C3AP_Status__c;
            
            system.debug('@@@@@@@ summary.C3AP_Status__c is: '+summary.C3AP_Status__c);
            system.debug('@@@@@@@ request.C3AP_Status__c is: '+request.C3AP_Status__c);
            
            summary.C3AP_Services__c = request.C3AP_Services__c;
            
            
            summaries.add(summary);
        }
        
        
        upsert summaries;
     }
     
     
     /*
      * Delete summaries for all passed-in contract requests
      */
     public void deleteSummaries (Map<Id, C3AP_Contract_Request__c> requests) {
        
        // fetch all summaries to delete
        List<C3AP_Contract_Request_Summary__c> summaries = [SELECT Id 
                                                            FROM C3AP_Contract_Request_Summary__c 
                                                            WHERE C3AP_Contract_Request_Id__c IN :requests.keySet()];
        
        delete summaries;
     }
     
     public static boolean isUserAdmin(Id userId){
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name =: Label.C3AP_App_Admin];
        List<PermissionSetAssignment> psaList = [Select Id from PermissionSetAssignment where AssigneeId =: UserInfo.getUserId() and PermissionSetId =: ps.ID];
        Id sysAdminProfileId = [Select Id from Profile where Name =: Label.C3AP_System_Administrator].Id;
        if(psaList.size() > 0 || sysAdminProfileId.equals(UserInfo.getProfileId())){
                return true;
        }
        else{
            return false;
        }
    }
    
    /* 
     * Method name : skipLegalAfterAmend
     * Description : method to set the parameters so that the legal approval is skipped after amendment
     * Param : map of old records, map of new records
     * Returns :  none.
    */
    public void skipLegalAfterAmend(Map<Id,C3AP_Contract_Request__c> oldRequests,Map<Id,C3AP_Contract_Request__c> newRequests){
        for(Id reqID : newRequests.keySet()){
            if(newRequests.get(reqId).C3AP_Legal_Approver_Activated__c && (newRequests.get(reqId).C3AP_Legal_Approver_Activated__c <> oldRequests.get(reqId).C3AP_Legal_Approver_Activated__c) && !newRequests.get(reqId).C3AP_Legal_Approver_Required__c){
                newRequests.get(reqId).C3AP_ATS_Approver_Activated__c = true;
                newRequests.get(reqId).C3AP_Legal_Approver_Activated__c = false;
            }
        }
    }
    
    /* 
     * Method name : skipLegalAfterAmend
     * Description : method to set the parameters so that the legal approval is skipped after amendment
     * Param : map of old records, map of new records
     * Returns :  none.
    */
    public void updateTranslationIndependentStatusField(List<C3AP_Contract_Request__c> newRequestList){
        Map<String,String> translationMapping = new Map<String,String>{
                                                                       System.Label.C3AP_Email_Action_Required => 'Action_Required',
                                                                       System.Label.C3AP_Status_Completed => 'Completed',
                                                                       System.Label.C3AP_Status_Expired => 'Expired',
                                                                       System.Label.C3AP_Status_Not_Approved_By_ATC => 'Not_Approved_By_ATC',
                                                                       System.Label.C3AP_Status_Not_Approved_By_ATS => 'Not_Approved_By_ATS',
                                                                       System.Label.C3AP_Status_Not_Approved_By_Legal => 'Not_Approved_By_Legal',
                                                                       System.Label.C3AP_Status_Not_Submitted => 'Not_Submitted',
                                                                       System.Label.C3AP_Status_Pending_ATC_Approval => 'Pending_ATC_Approval',
                                                                       System.Label.C3AP_Status_Pending_ATS_Approval => 'Pending_ATS_Approval',
                                                                       System.Label.C3AP_Status_Pending_Legal_Approval => 'Pending_Legal_Approval',
                                                                       System.Label.C3AP_Status_Pending_Final_Signatures => 'Pending_Final_Signatures',
                                                                       System.Label.C3AP_Status_Request_Cancelled => 'Cancelled',
                                                                       System.Label.C3AP_Terminated => 'Terminated',
                                                                       'Action Required' => 'Action_Required',  
                                                                       'Completed' => 'Completed',
                                                                       'Expired' => 'Expired',
                                                                       'Not Approved by ATC' => 'Not_Approved_By_ATC',
                                                                       'Not Approved By ATS' => 'Not_Approved_By_ATS',
                                                                       'Not Approved By Legal' => 'Not_Approved_By_Legal',
                                                                       'Not Submitted' => 'Not_Submitted',
                                                                       'Pending ATC Approval' => 'Pending_ATC_Approval',
                                                                       'Pending ATS Approval' => 'Pending_ATS_Approval',
                                                                       'Pending Legal Approval' => 'Pending_Legal_Approval',
                                                                       'Pending Final Signatures' => 'Pending_Final_Signatures',
                                                                       'Cancelled' => 'Cancelled',
                                                                       'Terminated' => 'Terminated'                                                                    
                                                                       };
         Map<String,String> translateOriginalStatus = new Map<String,String>{
                                                                       System.Label.C3AP_Email_Action_Required => 'Action Required',
                                                                       System.Label.C3AP_Status_Completed => 'Completed',
                                                                       System.Label.C3AP_Status_Expired => 'Expired',
                                                                       System.Label.C3AP_Status_Not_Approved_By_ATC => 'Not Approved by ATC',
                                                                       System.Label.C3AP_Status_Not_Approved_By_ATS => 'Not Approved By ATS',
                                                                       System.Label.C3AP_Status_Not_Approved_By_Legal => 'Not Approved By Legal',
                                                                       System.Label.C3AP_Status_Not_Submitted => 'Not Submitted',
                                                                       System.Label.C3AP_Status_Pending_ATC_Approval => 'Pending ATC Approval',
                                                                       System.Label.C3AP_Status_Pending_ATS_Approval => 'Pending ATS Approval',
                                                                       System.Label.C3AP_Status_Pending_Legal_Approval => 'Pending Legal Approval',
                                                                       System.Label.C3AP_Status_Pending_Final_Signatures => 'Pending Final Signatures',
                                                                       System.Label.C3AP_Status_Request_Cancelled => 'Cancelled',
                                                                       System.Label.C3AP_Terminated => 'Terminated',
                                                                       'Action Required' => 'Action Required',  
                                                                       'Completed' => 'Completed',
                                                                       'Expired' => 'Expired',
                                                                       'Not Approved by ATC' => 'Not Approved by ATC',
                                                                       'Not Approved By ATS' => 'Not Approved By ATS',
                                                                       'Not Approved By Legal' => 'Not Approved By Legal',
                                                                       'Not Submitted' => 'Not Submitted',
                                                                       'Pending ATC Approval' => 'Pending ATC Approval',
                                                                       'Pending ATS Approval' => 'Pending ATS Approval',
                                                                       'Pending Legal Approval' => 'Pending Legal Approval',
                                                                       'Pending Final Signatures' => 'Pending Final Signatures',
                                                                       'Cancelled' => 'Cancelled',
                                                                       'Terminated' => 'Terminated' 
        
                                                                       };                                                               
        for(C3AP_Contract_Request__c cr : newRequestList){
            if(cr.C3AP_Status__C <> null && translationMapping.get(cr.C3AP_Status__c) <> null){
                cr.C3AP_Translation_Independent_Status__c = translationMapping.get(cr.C3AP_Status__c);
            }
            if(cr.C3AP_Status__C <> null && translateOriginalStatus.get(cr.C3AP_Status__c) <> null){
                cr.C3AP_Status__c = translateOriginalStatus.get(cr.C3AP_Status__c);
            }
        }
    }
}