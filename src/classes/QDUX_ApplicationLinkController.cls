/**
 * Created by: Eric Montelibano (PwC)- 21/05/2015
 * Application: Quality in Design User Experience (QDUX)
 * 
 * Description: Controller class for the QDUX_ApplcationLinks Visualforce Page Component
 * Retrieve Common Applicatoin Links that is used to set for the QDUX App Home Page
*/

public without sharing class QDUX_ApplicationLinkController {
    public List<GLBL_Application_Link__c> getApplicationLinks(){
        
        List <GLBL_Application_Link__c> commProc = [Select Id, Name, Link_URL__c, Link_Name__c, Link_Description__c 
                                                    from GLBL_Application_Link__c where Active__c = true and RecordType.Name =: Label.QDUX_ApplicationLinkRecordTypeLabel 
                                                    and Application_Code__c =: Label.QDUX_Application_Link_App_Code
                                                    limit 10];
        system.debug('what is my list size ' +commProc.size());
        return commProc;
        
    }

}