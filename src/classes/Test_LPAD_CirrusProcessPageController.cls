@isTest(seeAllData=false)
public class Test_LPAD_CirrusProcessPageController{
          
          public static testmethod void checkProcessSteps()
          {
           List<GLBL_GSO_Content__c> processStepsList=new List<GLBL_GSO_Content__c>();
           for(Integer i=0;i<5;i++)
           {
               GLBL_GSO_Content__c obj_GLBL_GSO_Content=GLBL_TestDataUtilityClass.CreateGSOContentForTest();
               processStepsList.add(obj_GLBL_GSO_Content);
           }
           //System.debug('processStepsList---------------------------------------->'+processStepsList);
           insert processStepsList;
           
           Test.startTest();
           LPAD_CirrusProcessPageController LPAD_CirrusProcessPageController_Obj=new LPAD_CirrusProcessPageController ();
           LPAD_CirrusProcessPageController_Obj.getProcessSteps();
           Test.stopTest();
           delete processStepsList;
           processStepsList=null;
           LPAD_CirrusProcessPageController_Obj.getProcessSteps();
          
          }
}