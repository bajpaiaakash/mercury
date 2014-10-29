@isTest(seeAllData=false)
public class Test_LPAD_FooterController {

         
         public static testmethod void  checkForFooterEmail()
         {
             
              LPAD_Settings__c lpadSettings = GLBL_TestDataUtilityClass.createLPADSettingsDataForTest();
              insert lpadSettings;
              
              Test.startTest();
              LPAD_FooterController obj_FooterController=new LPAD_FooterController();
              String emailId=obj_FooterController.getFooterEmail();
              System.assertEquals('xyz@gso1.lly.com',emailId);
              
              delete lpadSettings;
              obj_FooterController.footerEmail = '';
              String emailId2=obj_FooterController.getFooterEmail();
              System.assertEquals('dummy@gso1.lly.com',emailId2);
              
              
              Test.stopTest();
           
           
            
           
           
            
            
            
         }
        

}