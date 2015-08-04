/****************************************************************************************************************************************** 
* Class Name   : PANG_AutoPopulateFieldsOnRequest 
* Description  : Class to Autopopulate fields from Study Object
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
Public with sharing class PANG_AutoPopulateFieldsOnRequest {
    
    Public PANG_Project__c oProject;
    Public PANG_Request__c oRequest;
    Public User uname;
    Public Boolean isFromStudy;
    public String PickValues;
    
    //Loading the constructor the page
    public PANG_AutoPopulateFieldsOnRequest(ApexPages.StandardController controller) {
        
        uname = [select Id, Name from User where Id = : UserInfo.getUserId() LIMIT 1];
        
        If((PANG_Request__c) controller.getRecord() != NULL) {
            
            oRequest = (PANG_Request__c) controller.getRecord();
            
            If(oRequest.Related_Project__c != NULL && oRequest.RWD_Inventory__c == NULL && String.valueOf(oRequest.Related_Project__c) != '') {
                
                oProject = [SELECT id, Business_Unit_Primary__c, Therapeutic_Area_Primary__c, Region__c, Project_ID__c FROM PANG_Project__c WHERE id = : oRequest.Related_Project__c];
                
                isFromStudy = True;
                
            } else if (oRequest.Related_Project__c != NULL) {
                isFromStudy = False;
            }
        }
    }
    
    /* 
* @Method Name                    :  autoPopulateFieldsOnRequest
* @Description                    :  This method populates the Therapeutic area , business unit, study id fields on request considering wheter the request is secondary or coming from study
* @Return Type                    :  pagereference
* @Parameters                     :  None
*/     
    
    public pagereference autoPopulateFieldsOnRequest() {
        
        PANG_Request_FieldId_Settings__c oCustSetting = PANG_Request_FieldId_Settings__c.getOrgDefaults();
        
        String sRecordTypeDeveloperName;
        
        String keyPrefix = PANG_Request__c.sObjectType.getDescribe().getKeyPrefix();
        
        Pagereference p = new pagereference('/' + keyPrefix + '/e?');
        p.getparameters().putall(ApexPages.currentPage().getparameters());
        p.getparameters().put('nooverride', '1');
        p.getparameters().remove('sfdc.override');
        p.getparameters().remove('save_new');
        
        if (oRequest.Primary_Request__c != NULL) {
            p.getparameters().put('saveURL', oRequest.Primary_Request__c);
        } 
        Else If(oRequest.Related_Project__c != NULL) {
            p.getparameters().put('saveURL', oRequest.Related_Project__c);
        } 
        
        if (oRequest.recordtypeid != null) {
            sRecordTypeDeveloperName = [Select developername from RecordType where id = : oRequest.recordtypeid].developername;
            p.getparameters().put('CF' + oCustSetting.Requestor__c + '_lkid', Uname.id);
            p.getparameters().put('CF' + oCustSetting.Requestor__c, Uname.Name);
        }
        if (sRecordTypeDeveloperName == 'EXPERT_Review' && isFromStudy == TRUE) {
            p.getparameters().put(oCustSetting.Study_Alias_Project_ID__c, oProject.Project_ID__c);
            p.getparameters().put(oCustSetting.Business_Unit_Primary__c, oProject.Business_Unit_Primary__c);
            p.getparameters().put(oCustSetting.Primary_Therapeutic_Area__c, oProject.Therapeutic_Area_Primary__c);
            
        } else if (sRecordTypeDeveloperName == 'EXPERT_or_ACT_Consultation' && isFromStudy == TRUE) {
            p.getparameters().put(oCustSetting.Study_Alias_Project_ID__c, oProject.Project_ID__c);
            p.getparameters().put(oCustSetting.Business_Unit_Primary__c, oProject.Business_Unit_Primary__c);
            p.getparameters().put(oCustSetting.Primary_Therapeutic_Area__c, oProject.Therapeutic_Area_Primary__c);
            
        } else if (sRecordTypeDeveloperName == 'EXPERT_Exception' && isFromStudy == TRUE) {
            p.getparameters().put(oCustSetting.Study_Alias_Project_ID__c, oProject.Project_ID__c);
            p.getparameters().put(oCustSetting.Business_Unit_Primary__c, oProject.Business_Unit_Primary__c);
            
        } else if (sRecordTypeDeveloperName == 'EXPERT_Workstream' && isFromStudy == TRUE) {
            p.getparameters().put(oCustSetting.Study_Alias_Project_ID__c, oProject.Project_ID__c);
            p.getparameters().put(oCustSetting.Business_Unit_Primary__c, oProject.Business_Unit_Primary__c);
            
        } else if (sRecordTypeDeveloperName == 'Data_Sourcing' && isFromStudy == TRUE) {
            p.getparameters().put(oCustSetting.Study_Alias_Project_ID__c, oProject.Project_ID__c);
            p.getparameters().put(oCustSetting.Business_Unit_Primary__c, oProject.Business_Unit_Primary__c);
            p.getparameters().put(oCustSetting.Primary_Therapeutic_Area__c, oProject.Therapeutic_Area_Primary__c);
            
        } else if (sRecordTypeDeveloperName == 'Internal_Real_World_Data_Analysis' && isFromStudy == TRUE) {
            p.getparameters().put(oCustSetting.Study_Alias_Project_ID__c, oProject.Project_ID__c);
            p.getparameters().put(oCustSetting.Business_Unit_Primary__c, oProject.Business_Unit_Primary__c);
            p.getparameters().put(oCustSetting.Primary_Therapeutic_Area__c, oProject.Therapeutic_Area_Primary__c);
            
        } else if (sRecordTypeDeveloperName == 'RWE_Strategic_Consultation' && isFromStudy == TRUE) {
            p.getparameters().put(oCustSetting.Study_Alias_Project_ID__c, oProject.Project_ID__c);
            p.getparameters().put(oCustSetting.Business_Unit_Primary__c, oProject.Business_Unit_Primary__c);
            p.getparameters().put(oCustSetting.Primary_Therapeutic_Area__c, oProject.Therapeutic_Area_Primary__c);
        }
        p.setRedirect(true);
        return p;
    }
}