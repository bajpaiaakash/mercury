/*************************************************************************\
    @ Author        : Shoumyabrata Chanda
    @ Date          : 1-Sep-2014
    @ Description   : Test Class for class MICO_opProjectRecords
****************************************************************************/

@isTest(seeAllData = false)
private class Test_MICO_projectRecords{

   
         public static List<User> sysOwnerLst;
         public static User sysOwner1;
         public static User sysCust ;
         public static User SysQual ;
         
         static testMethod void createProjectRecord1() 
          {
          
          sysOwnerLst = new list<User>();
          
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
           
            sysOwnerLst.add(sysCust);
            
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
       
            
            sysOwnerLst.add(SysQual);
           
             //Creating the test user for System Admin
            sysOwner1 = new User();
            sysOwner1.username = 'sysOwner@Test.com.env';
            sysOwner1.Email = 'sysOwner@Test.com';
            sysOwner1.profileid = UserInfo.getProfileId();
            sysOwner1.lastname = 'Owner';
            sysOwner1.firstname = 'System';
            sysOwner1.Alias = 'syo';
            sysOwner1.TimeZoneSidKey = 'America/Los_Angeles';
            sysOwner1.LocaleSidKey = 'en_US';
            sysOwner1.EmailEncodingKey = 'UTF-8';
            sysOwner1.LanguageLocaleKey = 'en_US';
            
            sysOwnerLst.add(sysOwner1);
            
           
            insert sysOwnerLst;
          
             //List<User> sysOwnerLst1=[select id,name from User where isactive = true and profileId = :UserInfo.getProfileId() ];
            // Profile adminProfiel = [SELECT Id,Name from Profile where name = 'System Administrator' LIMIT 1];
            //List<User> adminUserList = [select id,name from User where isactive = true and profileId = :adminProfiel.Id];
           
            
            MICO_Project__c micoProjct_test=new MICO_Project__c(Name='Mico Project for test class');
            
            System.runAs(sysOwner1){
            
            insert micoProjct_test;
            
            List<MICO_Project__share> mico_ProjectShareLst=new List<MICO_Project__share>();
            
            for(Integer i=0;i<2;i++)
            {
              MICO_Project__share obj1=new MICO_Project__share(accesslevel='Edit',UserOrGroupId=sysOwnerLst[i].Id,rowcause=MICO_Project__share.RowCause.Manual,parentId=micoProjct_test.Id);
              mico_ProjectShareLst.add(obj1);
            }
            
           /* List<MICO_Project__share> mico_projctShareLst=new List<MICO_Project__share>();
           
            mico_projctShareLst.add(mico_ProjectShare);*/
      
            
            insert mico_ProjectShareLst;
            }
            
           //List<MICO_Project__share> getProjectOwner=[SELECT id from MICO_Project__share where rowcause='Owner'and parentId=:micoProjct_test.Id];
           
            Test.startTest();
            
            System.runAs(SysQual){
            
            micoProjct_test.OwnerId = sysOwnerLst[1].Id;
            
            update micoProjct_test;
            
            
            MICO_Project__share  ManualSharing = new MICO_Project__share();
            ManualSharing= ([SELECT Id, accesslevel, UserOrGroupId
            FROM MICO_Project__share
            WHERE rowcause = 'Manual' and  parentId=:micoProjct_test.Id
            LIMIT 1])[0];
    
           // check manual sharing is retained
            System.assertEquals(true, ManualSharing.accesslevel == 'Edit');
            System.assertEquals(true, ManualSharing.UserOrGroupId == sysOwnerLst[0].Id);
            }
            
            Test.stopTest();
          }
          

        

}