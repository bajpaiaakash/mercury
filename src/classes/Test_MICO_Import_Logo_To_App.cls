/*************************************************************************
    @ Author        : Madhuri Nittala
    @ Date          : 10-Apr-2015
    @ Description   : Test Class for MICO_Import_Logo_To_App class
****************************************************************************/
@isTest(seeAllData = false)
private class Test_MICO_Import_Logo_To_App {


    public static User sysOwner;
    public static MICO_App__c TestApp; 
    
     public static User createUser(){
       
        Profile pfl = [select id from profile where name='System Administrator'];
         //Declaring the User
        User runAsUser = new User(alias = 'Admin', email='appAdmin@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = pfl.Id,  country='United States', CommunityNickname = 'u1',
            timezonesidkey='America/Los_Angeles', username='appAdmin'+String.valueOf(System.now().getTime())+'@gso_org.com' );
        
        insert runAsUser;  
        return runAsUser;       
        }
        
    static testMethod void setupTestData() { 
        sysOwner= createUser();
        System.runAs(sysOwner) {
            TestApp= new MICO_App__c();
            TestApp.Name = 'Test App';
            TestApp.System_Custodian__c=sysOwner.id;
            TestApp.System_Owner__c=sysOwner.id;
            TestApp.Data_Criticality__c='Not Assessed';
            TestApp.GxP__c='Not Assessed';
            TestApp.Quality_Critical__c='Not Assessed';
            insert TestApp;
            Test.startTest();                                    
                Document dc= new Document();
                dc.AuthorId = UserInfo.getUserId();
                dc.FolderId = UserInfo.getUserId();
                dc.DeveloperName='LillyLogo';
                dc.Name = 'LillyLogo'; 
                insert dc;
                ApexPages.StandardController Scon= new ApexPages.StandardController(TestApp);
                MICO_Import_Logo_To_App Imp_Logo=new MICO_Import_Logo_To_App(Scon);  
                Imp_Logo.getPrintView();
                System.assert(Imp_Logo.lillyLogoURL.contains(String.valueOf(URL.getSalesforceBaseUrl().toExternalForm())));   
            Test.stopTest();        
       }           
    }
 }