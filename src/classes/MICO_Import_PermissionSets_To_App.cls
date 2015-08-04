public with sharing class MICO_Import_PermissionSets_To_App {
Public id Current_App_Id;
Public String recType {get;set;}

    public MICO_Import_PermissionSets_To_App(ApexPages.StandardController MICO_App) {
    Current_App_Id = MICO_App.getRecord().id;
    recType = 'Permission Set';
    }

     public List<MICO_App_Security_Controls__c> getrelatedPermissionSetRecs(){
       List<MICO_App_Security_Controls__c> conList = New List<MICO_App_Security_Controls__c>();
       for(MICO_App__c rel:[select id,name,(select id, name, description__c from App_Security_Controls__r WHERE Type__c=:recType) from MICO_App__c where id=:Current_App_Id]){
           for(MICO_App_Security_Controls__c con:rel.App_Security_Controls__r)
               conList.add(con); 
       }
       return conList;
    }

}