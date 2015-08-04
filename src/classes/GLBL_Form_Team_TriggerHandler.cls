/**
*@ Class Name    : GLBL_Form_Team_TriggerHandler
*@ Description   : Apex Sharing on a Form template and executions to grant access to the form team.                   
*@ CreatedBy     : Venugopal Vemula
*@ CreatedOn     : 11-05-2014
*@ Modification Log:                                      
* 
*/
public class GLBL_Form_Team_TriggerHandler{
    
    
    public static void insertFormShare(List<GLBL_Form_Team__c> triggernew){
        
        List<String> formTempId = new List<String>();
        Map<String,String> mapformTeamMember = new Map<String,String>();
        List<String> formTeamMember = new List<String>();
        List<String> permission = new List<String>();
        
        for(GLBL_Form_Team__c teamObj : triggernew){
            
            formTempId.add(teamObj.Form_Template__c);
            mapformTeamMember.put(teamObj.Form_Team_Member__c,teamObj.Form_Team_Member__c);
            permission.add(teamObj.Permission__c);
            
        }
        
        // Skipping the Owners from new sharing on Form Template and Form executions as they have full access
        
        List<GLBL_Form_Execution__c> templateOwner = [Select OwnerId, Source_Form__r.OwnerId from GLBL_Form_Execution__c 
                                                      where Source_Form__c in :formTempId];
        
        List<String> OwnerIds = new List<String>();
        if(templateOwner.size() > 0)
        {
            for(GLBL_Form_Execution__c execObj : templateOwner)
            {
                // OwnerIds.add(execObj.OwnerId);
                OwnerIds.add(execObj.Source_Form__r.OwnerId);
            }
        }
        
        for(String OwnerObj : OwnerIds)
        {
            //remove theh owners from the Team members
            mapformTeamMember.remove(OwnerObj);
        }
        
        formTeamMember = mapformTeamMember.values();
        
        InsertFormShareFuture( formTempId, formTeamMember, permission );
        
    }
    
    
    @future
    public static void InsertFormShareFuture(List<String> formTemplate, List<String> teamMemberId, List<String> permission ){
        
        List<GLBL_Form_Execution__c> formExec = [Select Source_Form__c,Id from GLBL_Form_Execution__c
                                                 where Source_Form__c in : formTemplate];
        List<GLBL_Form_Template__Share> lformTempShare = [Select Id, Accesslevel, RowCause from GLBL_Form_Template__Share where ParentId in : formTemplate and UserOrGroupId in : teamMemberId ];
        List<GLBL_Form_Template__Share> linsertformTempShare = new List<GLBL_Form_Template__Share>();
        
        //************************* Setting up the Form Template Sharing ********************************
        
        // Manual sharing will only be altered in case the user has Read access and the same user is added in form team with edit access.
        
        if(formTemplate.size()>0) {
            
            for(String currentTeamObj : TeamMemberId){
                
                for(String formTemplateId : formTemplate){
                    
                    // checks if the team member already has access to the form template
                    
                    if(lformTempShare.size()>0){
                        
                        for( GLBL_Form_Template__Share currentFormTempShare : lformTempShare){
                            if(currentFormTempShare.Accesslevel <> Permission[0]){   
                                if(Permission[0]== Label.FORM_Access_Level_RW){                     
                                    currentFormTempShare.Accesslevel = Label.FORM_Access_Level_Edit;
                                    
                                }
                            }
                        }
                        
                    }    
                    else{
                        // inserts the user in standard form template share table
                        
                        GLBL_Form_Template__Share formTempShare = new GLBL_Form_Template__Share();
                        
                        formTempShare.ParentId = formTemplateId;
                        if(Permission[0]== Label.FORM_Access_Level_RW){ 
                            Permission[0] = Label.FORM_Access_Level_Edit;
                        }
                        formTempShare.AccessLevel = Permission[0];                     
                        formTempShare.RowCause = Schema.GLBL_Form_Template__Share.RowCause.FormTeamMember__c;
                        formTempShare.UserOrGroupId = currentteamObj;
                        linsertformTempShare.add(formTempShare);
                    }
                    
                }
                
            }
            try{
                if(lformTempShare <> null){
                    update lformTempShare;
                }
                if(linsertformTempShare <> null){
                    insert linsertformTempShare;
                }
            }
            catch(exception e){
                System.debug('Update failed on Form Template share'+ e);
            }
        }
        
        //********************** Setting up the Form Execution Sharing ***************************
        if(formexec.size() > 0){
            
            List<GLBL_Form_Execution__Share> lexecShare = new List<GLBL_Form_Execution__Share>();
            for(String teamObj : TeamMemberId){
                
                for(GLBL_Form_Execution__c execObj : formexec){
                    
                    GLBL_Form_Execution__Share execShare = new GLBL_Form_Execution__Share();
                    execShare.ParentId = execObj.Id;
                    execShare.AccessLevel = Label.FORM_Access_Level_Read;
                    execShare.RowCause = Schema.GLBL_Form_Execution__Share.RowCause.FormTeamMember__c;
                    execShare.UserOrGroupId = teamObj;
                    lexecShare.add(execShare);
                }
            }
            
            try{
                insert lexecShare;
            }
            catch(exception e){
            }
        }
        
        
    }
    
    // Delete Form Team logic
    public static void deleteFormShare(List<GLBL_Form_Team__c> triggerold){
        
        List<String> lformTempId = new List<String>();
        List<String> lformTeamMember = new List<String>();
        List<String> lpermission = new List<String>();
        
        for(GLBL_Form_Team__c teamObj : triggerold){
            
            lformTempId.add(teamObj.Form_Template__c);
            lformTeamMember.add(teamObj.Form_Team_Member__c);
            lpermission.add(teamObj.Permission__c);
           // System.debug('*************'+lformTempId[0]);
        }
        //System.debug('*************'+lformTempId[0]);
        formUnshareFuture( lformTempId, lformTeamMember, lpermission );
        
    }
    
    
    @future
    public static void formUnshareFuture(List<String> lformTempId, List<String> lformTeamMember, List<String> lpermission){
        
        List<GLBL_Form_Execution__c> lformExec = [Select Source_Form__c,Id from GLBL_Form_Execution__c
                                                  where Source_Form__c in : lformTempId];
        
        List<GLBL_Form_Template__Share> lformTempShare = [Select Id, Accesslevel, UserOrGroupId, RowCause from GLBL_Form_Template__Share 
                                                          where ParentId in:lformTempId and UserOrGroupId in : lformTeamMember  ];
        
        List<GLBL_Form_Template__Share> delformTempShare = new List<GLBL_Form_Template__Share>();
        
        
        List<GLBL_Form_Execution__Share> lformExecShare = [Select Id, UserOrGroupId from GLBL_Form_Execution__Share where ParentId in : lformExec and UserOrGroupId in : lformTeamMember ];
        
        //checks if the Form template is already shared manually and updates the Access level to 'Read'. Otherwise deletes the form template
        
        if(lformExec.size() > 0 && lformTempShare.size()>0){ 
            
            List<GLBL_Form_Template__Share> lftsharetoUpdate = new List<GLBL_Form_Template__Share>();
            
            for(GLBL_Form_Template__Share tempSharing : lformTempShare ){
                
                if(tempSharing.RowCause == Label.FORM_RowCause){//'Manual'
                    
                    tempSharing.Accesslevel = Label.FORM_Access_Level_Read;//'Read'
                    lftsharetoUpdate.add(tempSharing);
                    
                }
                
                else delformTempShare.add(TempSharing);
            }
            if(lftsharetoUpdate <> null){
                update lftsharetoUpdate;
            }    
            //update lformTempShare;
            
            if(!delformTempShare.isEmpty()){
                Database.Delete(delformTempShare, false);
            }
            
            //unshares any Form executions, shared with the same user(deleted user) on form Team
            
            if(lformExecShare.size()>0){
                System.debug(database.delete( lformExecShare,false));
                //log failure records
            }
            //  Delete lexecUnshare;
            
            
        }
    }
    
}