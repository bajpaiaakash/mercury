/* Class Name  : GLBL_Form_Execution_TriggerHandler
* Description  : Granting Read access to the executions to all the team members on Form template
* Created By   : Venugopal
* Created Date : 12/11/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/
public class GLBL_Form_Execution_TriggerHandler {
    
    public static void insertFormExecutionShare( List<GLBL_Form_Execution__c> lformExec){
        
        
        Set<Id> setsourceFormTempID = new Set<Id>();
        List<String> execOwner = new List<String>();
        for(GLBL_Form_Execution__c formExecObj : lformExec){
            
            setsourceFormTempID.add(formExecObj.Source_Form__c); 
            execOwner.add(formExecObj.OwnerId);
        }
        List<GLBL_Form_Team__c> lformTeam = [select Id, Form_Team_Member__c, Form_Template__c  from GLBL_Form_Team__c 
                                             where Form_Template__c in: setsourceFormTempID and Form_Team_Member__c not in :execOwner];
        List<GLBL_Form_Execution__Share> lformExecShare = new List<GLBL_Form_Execution__Share>();
        Map<String , List<GLBL_Form_Team__c>> mapsourceFormTeam = new Map<String , List<GLBL_Form_Team__c>>();
        
        if(lformTeam.size()>0){
            for(GLBL_Form_Team__c currentFormteam : lformTeam){
                
                //map to store the form template and team list
                if(mapsourceFormTeam.containsKey(currentFormteam.Form_Template__c)){
                    
                    mapsourceFormTeam.get(currentFormteam.Form_Template__c).add(currentFormteam );
                }
                else{
                    mapsourceFormTeam.put(currentFormteam.Form_Template__c, new List<GLBL_Form_Team__c>{currentFormteam});
                }
                
            }//end for   
            
            
            //adding Read access to the execution to all the team members on Form template
            
            for(GLBL_Form_Execution__c currentFormExec : lformExec ){
                
                List<GLBL_Form_Team__c> lcurrentFormTeam =     mapsourceFormTeam.get(currentFormExec.Source_Form__c);
                if(lcurrentFormTeam.size()>0){
                    for(GLBL_Form_Team__c currentteamObj: lcurrentFormTeam){
                        GLBL_Form_Execution__Share formExecShare = new GLBL_Form_Execution__Share();
                        formExecShare.ParentId = currentFormExec.Id;
                        formExecShare.UserOrGroupId = currentteamObj.Form_Team_Member__c;
                        formExecShare.RowCause = Schema.GLBL_Form_Execution__Share.RowCause.FormTeamMember__c;
                        formExecShare.AccessLevel = Label.FORM_Access_Level_Read;
                        lformExecShare.add(formExecShare);
                    }
                }
            }
        }
        
        if(lformExecShare.size()>0)
            insert lformExecShare;
        
    }//end of function
}//end of class