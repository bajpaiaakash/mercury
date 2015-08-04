public with sharing class MICO_Import_Profiles_To_App {
Public id Current_App_Id;
Public String recType {get;set;}
public String lillyLogoURL{get;set;}
public String cirrusLogoURL{get;set;}

    public MICO_Import_Profiles_To_App(ApexPages.StandardController MICO_App) {
    Current_App_Id = MICO_App.getRecord().id;
    recType = 'Profile';
    getlogoURLs();
    }

     public List<MICO_App_Security_Controls__c> getrelatedProfileRecs(){
       List<MICO_App_Security_Controls__c> conList = New List<MICO_App_Security_Controls__c>();
       for(MICO_App__c rel:[select id,name,(select id, name, description__c from App_Security_Controls__r WHERE Type__c=:recType) from MICO_App__c where id=:Current_App_Id]){
           for(MICO_App_Security_Controls__c con:rel.App_Security_Controls__r)
               conList.add(con); 
       }
       return conList;
    }
    
   
   public void getLogoURLs()
   {
   List<Document> docList = [Select Id,DeveloperName  from Document where DeveloperName ='LillyLogo' OR DeveloperName='Cirrus_Logo'];
   Id lillyLogoId;
   Id cirrusLogoId;
   for(Document d :docList){
    if(d.DeveloperName.equals('LillyLogo')){
        lillyLogoId = d.Id;
    }
    else{
        cirrusLogoId = d.Id;
    }
}
    Id oId = UserInfo.getOrganizationId();

    String baseURl = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()) ;
    lillyLogoURL = baseURl +'/servlet/servlet.ImageServer?id='+lillyLogoId+'&oid='+oId;
    cirrusLogoURL = baseURl +'/servlet/servlet.ImageServer?id='+cirrusLogoId+'&oid='+oId;

   
   
   }

}