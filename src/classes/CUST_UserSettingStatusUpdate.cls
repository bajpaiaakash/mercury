public class CUST_UserSettingStatusUpdate implements GLBL_TriggerHandler.HandlerInterface
{
    public void handle() {
        if (Trigger.isUpdate || Trigger.isInsert) {
            execute(Trigger.new);
        }
    }
  
    void execute(List<CST_User_Settings_CUST__c> userSettings) {
        for (CST_User_Settings_CUST__c ust : userSettings){
            if (Trigger.isUpdate){
                if (ust.Access_Status_CUST__c != Trigger.oldMap.get(ust.Id).get('Access_Status_CUST__c')){
                    ust.Last_Status_CUST__c = (String)Trigger.oldMap.get(ust.Id).get('Access_Status_CUST__c');
                }    
            }
            
            //Need to update to check if the status is going to approved. 
            if (ust.Access_Status_CUST__c == 'Approved' && Trigger.oldMap.get(ust.Id).get('Access_Status_CUST__c') != 'Approved'){
                ust.Start_Date_CUST__c = Date.Today();
                //Set the audit day to the 15th 5 months from now.
                Date fiveMonths = Date.Today().addMonths(5).toStartOfMonth().addDays(14);
                ust.Audit_Date_CUST__c = fiveMonths;
            }
        }
    }
}