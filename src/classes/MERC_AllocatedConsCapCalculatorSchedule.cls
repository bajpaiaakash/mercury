/**
  @author: Aakash Bajpai
   @Created Date: 22-Feb-2016
  @Description: For Scheduling the batch class 'MERC_AllocatedConsCapCalculatorBatch'
*/

global class MERC_AllocatedConsCapCalculatorSchedule implements Schedulable {

    global void execute(SchedulableContext sc) {
        MERC_AllocatedConsCapCalculatorBatch b = new MERC_AllocatedConsCapCalculatorBatch();
        database.executeBatch(b);
    }
    global static void executeAllocatedConsCapCalculatorSch(){
        MERC_AllocatedConsCapCalculatorSchedule  m = new MERC_AllocatedConsCapCalculatorSchedule();
        String sch = '0 5 0 * * ?';
        String jobID = system.schedule('MERC_AllocatedConsCapCalculatorSchedule', sch, m);    
    }
    
}