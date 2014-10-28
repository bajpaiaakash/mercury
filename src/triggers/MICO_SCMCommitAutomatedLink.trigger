/****************************************************************************************************************************************** 
* Class Name   : SCMCommmitAutomatedLink
* Description  : Trigger that will be run when a new SCM Record has been created. Then this trigger will create a link between the SCM 
*                Record and the SCM Link (US/def)   
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/


trigger MICO_SCMCommitAutomatedLink on MICO_SCM_Commit__c (after insert) {
    
    // Check only for newly created SCM_Commit__c records
    for(MICO_SCM_Commit__c scmNew : Trigger.new) {
        // Iterate over each new object
        // See if the Trigger was run after an insert of a SCM_Commit__c record
        System.Debug('New Commit: ' + scmNew);
        if(scmNew != null) {
            if(Trigger.isInsert) {
                // Get the Related To field from the newly SCM Record
                String tmpRelatedTo = scmNew.Related_To__c;
                
                
                if(tmpRelatedTo != null) {
                    
                    // See if the Related to belongs to a US or a DEF and create the right record
                    if(tmpRelatedTo.startsWithIgnoreCase('US')) {
                        // Create a SCM Commit User Story Link
                        MICO_SCM_Commit_Requirement_Link__c scmUSLink = new MICO_SCM_Commit_Requirement_Link__c();
                        
                        // Link the SCM Commit User Story Link to the SCM Commit 
                        scmUSLink.SCM_Commit__c = scmNew.Id;
                        
                        // Link the SCM Commit to the US Ref
                        List<MICO_User_Story__c> lstUSRef = [SELECT Name FROM MICO_User_Story__c WHERE Name =: tmpRelatedTo LIMIT 1];
                        
                        if(lstUSRef.size() != 0) {
                            for(MICO_User_Story__c s: lstUSRef) {
                                scmUSLink.Requirement__c = s.Id;
                                insert scmUSLink;
                            }
                        }
                    }
                    else if(tmpRelatedTo.startsWithIgnoreCase('DEF')) {
                        // Create the SCM Commit Defect Link
                        MICO_SCM_Commit_Bug_Link__c scmDefLink = new MICO_SCM_Commit_Bug_Link__c();
                        
                        // Link the SCM Commit Def Link to the SCM Commit
                        scmDefLink.SCM_Commit__c = scmNew.Id;
                        
                        // Link the SCM Commit to the Def Ref
                        List<MICO_Bug__c> lstDefRef = [SELECT Name FROM MICO_Bug__c WHERE Name =: tmpRelatedTo LIMIT 1];
                        
                        // Check if there is a record
                        if(lstDefRef.size() != 0) {
                            for(MICO_Bug__c s: lstDefRef) {
                                scmDefLink.Defect__c = s.Id;
                                insert scmDefLink;
                            }
                        }
                    }
                }
            }
        }
    
    } 
}