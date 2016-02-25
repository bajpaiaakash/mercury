/**
  @Created Date: 25-Feb-2016
  @Description: For Scheduling the batch class 'MERC_AllocatedConsCapCalculatorBatch'
*/

@isTest
private class MERC_AllocatedConsCapCalculatorSch_Test{
     static testmethod void mytestmethod(){
     User testUser = MERC_TestFactory.getTestingUser(); 
     System.runAs(testUser) {
         Test.startTest();       
         MERC_AllocatedConsCapCalculatorSchedule.executeAllocatedConsCapCalculatorSch();
         Test.stopTest();
       }
    }
    
}