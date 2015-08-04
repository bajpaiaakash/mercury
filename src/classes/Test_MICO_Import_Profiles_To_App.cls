/*************************************************************************\
    @ Author        : Saurabh Teotia
    @ Date          :17-Feb-2014
    @ Description   : Test Class for MICO_Import_Profiles_To_App class
****************************************************************************/
@
isTest
private class Test_MICO_Import_Profiles_To_App {


    public static User sysCust;
    public static User sysOwner;
    public static User BysQual;
    public static User SysQual;
    public static MICO_App__c TestApp;
 static testMethod void setupTestData() {
 
 //Creating the test user for System Custodian
        sysCust = new User();
        sysCust.username = 'sysCust@Test.com.env';
        sysCust.Email = 'sysCust@Test.com';
        sysCust.profileid = UserInfo.getProfileId();
        sysCust.lastname = 'Custodian';
        sysCust.firstname = 'System';
        sysCust.Alias = 'syc';
        sysCust.TimeZoneSidKey = 'America/Los_Angeles';
        sysCust.LocaleSidKey = 'en_US';
        sysCust.EmailEncodingKey = 'UTF-8';
        sysCust.LanguageLocaleKey = 'en_US';
        insert sysCust;

        //Creating the test user for System Owner
        sysOwner = new User();
        sysOwner.username = 'sysOwner@Test.com.env';
        sysOwner.Email = 'sysOwner@Test.com';
        sysOwner.profileid = UserInfo.getProfileId();
        sysOwner.lastname = 'Owner';
        sysOwner.firstname = 'System';
        sysOwner.Alias = 'syo';
        sysOwner.TimeZoneSidKey = 'America/Los_Angeles';
        sysOwner.LocaleSidKey = 'en_US';
        sysOwner.EmailEncodingKey = 'UTF-8';
        sysOwner.LanguageLocaleKey = 'en_US';
        try{
        insert sysOwner;
        }
        catch(exception e){}

        //Creating the test user for Business Quality
        BysQual = new User();
        BysQual.username = 'BysQual@Test.com.env';
        BysQual.Email = 'BysQual@Test.com';
        BysQual.profileid = UserInfo.getProfileId();
        BysQual.lastname = 'Quality';
        BysQual.firstname = 'Business';
        BysQual.Alias = 'byq';
        BysQual.TimeZoneSidKey = 'America/Los_Angeles';
        BysQual.LocaleSidKey = 'en_US';
        BysQual.EmailEncodingKey = 'UTF-8';
        BysQual.LanguageLocaleKey = 'en_US';
        insert BysQual;

       
        //Creating the test user for Computer Systems Quality
        SysQual = new User();
        SysQual.username = 'SysQual@Test.com.env';
        SysQual.Email = 'SysQual@Test.com';
        SysQual.profileid = UserInfo.getProfileId();
        SysQual.lastname = 'Quality';
        SysQual.firstname = 'System';
        SysQual.Alias = 'syq';
        SysQual.TimeZoneSidKey = 'America/Los_Angeles';
        SysQual.LocaleSidKey = 'en_US';
        SysQual.EmailEncodingKey = 'UTF-8';
        SysQual.LanguageLocaleKey = 'en_US';
        try{
        insert SysQual;
        }
        catch(Exception e){}
        
        try{
        System.runAs(sysOwner) {

            TestApp= new MICO_App__c();
            TestApp.Name = 'Test App';
            TestApp.System_Custodian__c=sysCust.id;
            TestApp.System_Owner__c=sysOwner.id;
            TestApp.Data_Criticality__c='Not Assessed';
            TestApp.GxP__c='Not Assessed';
            TestApp.Quality_Critical__c='Not Assessed';
            insert TestApp;
            
            
            MICO_App_Security_Controls__c AppSec=new MICO_App_Security_Controls__c();
            AppSec.Name='Test Name';
            AppSec.App__c=TestApp.id;
            AppSec.description__c='Test';  
            AppSec.Type__c='Profile';
            insert AppSec;
            
            ApexPages.StandardController Scon= new ApexPages.StandardController(TestApp);
            MICO_Import_Profiles_To_App Imp_Prof=new MICO_Import_Profiles_To_App(Scon);
            List<MICO_App_Security_Controls__c> SecList=Imp_Prof.getrelatedProfileRecs();
            
            Document dc= new Document();
            dc.AuthorId = UserInfo.getUserId();
            dc.FolderId = UserInfo.getUserId();
            dc.DeveloperName='LillyLogo';
            insert dc;
            Imp_Prof.getLogoURLs();
            

            
           }
           }
           catch(Exception e){}
           
          
           
    
 



}

}