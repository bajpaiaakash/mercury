/**
  @Created Date: 25-Feb-2016
  @Description: For Scheduling the batch class 'MERC_AllocatedConsCapCalculatorBatch'
*/

@isTest
private class Test_MERC_AllocatedConsCapCalculatorSch{
      static testmethod void mytestmethod(){
     User testUser = MERC_TestFactory.getTestingUser(); 
     System.runAs(testUser) {
         Test.startTest();    
         MERC_AllocatedConsCapCalculatorSchedule.scheduleName='MERC_AllocatedConsCapCalculatorSchTest';   
         MERC_AllocatedConsCapCalculatorSchedule.executeAllocatedConsCapCalculatorSch();
         Test.stopTest();
       }
    }
    
}