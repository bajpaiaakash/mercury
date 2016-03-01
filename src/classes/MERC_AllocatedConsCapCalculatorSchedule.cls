/**
  @author: Aakash Bajpai
   @Created Date: 22-Feb-2016
  @Description: For Scheduling the batch class 'MERC_AllocatedConsCapCalculatorBatch'
*/

global class MERC_AllocatedConsCapCalculatorSchedule implements Schedulable {

      public static string strScheduleName='MERC_AllocatedConsCapCalculatorSchedule';
        public static String scheduleName {
          get { return strScheduleName; }
          set { strScheduleName = value; }
       }

    global void execute(SchedulableContext sc) {
        MERC_AllocatedConsCapCalculatorBatch b = new MERC_AllocatedConsCapCalculatorBatch();
        database.executeBatch(b);
    }
    global static void executeAllocatedConsCapCalculatorSch(){
        MERC_AllocatedConsCapCalculatorSchedule  m = new MERC_AllocatedConsCapCalculatorSchedule();
        String sch = '0 5 0 * * ?';
        // This runs a scheduled job at 12:05am every day
        String jobID = system.schedule(scheduleName, sch, m);    
    }
    
}