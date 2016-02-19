/*
    @created : On 12-FEB-2016 for US-39907
    @description : Batch Class that calculates MERC_Allocated_CAP__c on Account based on an Account's participation in Consulting Meeting where  meeting end date has been passed and lies in 6 month time period or Meeting has not been complete-closed/complete-cancelled.
   
*/



global class MERC_AllocatedConsCapCalculatorBatch implements Database.Batchable<sObject> {

  String query;
  List<Meeting_Participant_MERC__c> mp_list= new List<Meeting_Participant_MERC__c>();
  List<Account> acclist = new List<Account>();
  List<Meeting_Participant_MERC__c> mp_out_6_months = new List<Meeting_Participant_MERC__c>();
  List<Meeting_Participant_MERC__c> mp_in_6_months = new List<Meeting_Participant_MERC__c>();
  Set<Id> accountIds = new Set<Id>();
  Set<String> allocatedCapExcludedStatuses = new Set<String>{'Cancelled', 'Rejected', 'Declined'};
  

  global MERC_AllocatedConsCapCalculatorBatch() {
      
    /* query to get Consulting Meeting details where meeting end date has been passed and lies in 6 month time period or Meeting has not been complete-closed/complete-cancelled. */
    query = 'SELECT Id,Date_of_Event_MERC__c,Meeting_Status_MERC__c,End_Date_of_Event_MERC__c,MERC_Meeting_Complete_Canceled_Clsd_Date__c,RecordType.DeveloperName,MERC_Meeting_End_date_plus_6_months__c,MERC_Meeting_End_Date_Inactive__c from Meeting_MERC__c where Date_of_Event_MERC__c != THIS_YEAR AND Meeting_Status_MERC__c != \'Forecasted\' AND RecordType.DeveloperName = \'Ad_Hoc_Consulting\' AND MERC_Meeting_End_Date_Inactive__c = TRUE AND MERC_Meeting_out_of_six_months__c = TRUE';
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

     global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<Id> meetingIds = new Set<Id>();
        Set<Id> MPIds = new Set<Id>();
         for (Meeting_MERC__c meeting : (List<Meeting_MERC__c>)scope) {
        meetingIds.add(meeting.id);
        }
        
        /* To get Meeting Participants Ids associated to Consulting Meeting where meeting end date has been passed and lies in 6 month time period or Meeting has not been complete-closed/complete-cancelled. */
        Map<Id, Meeting_Participant_MERC__c> mpList = new Map<Id, Meeting_Participant_MERC__c>([select 
        id, name,Status_MERC__c,Final_Fee_Rollup_MERC__c,Services_Rendered_MERC__c,Include_CAP_Roll_Up_MERC__c,Meeting_MERC__c,Account_MERC__c,Record_Type_Name_MERC__c 
                                            From Meeting_Participant_MERC__c 
                                            Where Meeting_MERC__c IN :meetingIds AND
                                            Include_CAP_Roll_Up_MERC__c = TRUE AND
                                            Meeting_MERC__r.RecordType.DeveloperName = 'Ad_Hoc_Consulting']);
                                            
        system.debug('------------mpList-----------' + mpList);
        
        /* To get Account Ids associated Meeting Participants of Consulting Meeting where meeting end date has been passed and lies in 6 month time period or Meeting has not been complete-closed/complete-cancelled. */
        for (ID mpID : mpList.keySet()) {
                accountIds.add(mpList.get(mpID).Account_MERC__c);
                
            }
         for (Meeting_Participant_MERC__c mp: mpList.values()) {
                mp_list.add(mpList.get(mp.Id));
               
            }
        
            
        System.debug('********'+accountIds);
           
        
        
        /* Query to calculate Paid Invoices for Consulting Meetings till where meeting end date has been passed and lies in 6 month time period or Meeting has not been complete-closed/complete-cancelled. */
         List<AggregateResult> Cons_Invoices_res = [SELECT
                                            Meeting_Participant_MERC__r.Account_MERC__c inv_acc,
                                            Sum(MERC_Consulting_Contracted_Amt_excl_VAT__c) lre0
                                                FROM Invoice_MERC__c
                                                    WHERE
                                                        Meeting_Participant_MERC__r.Account_MERC__c IN :accountIds AND
                                                        (Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_End_Date_Inactive__c = TRUE AND Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_End_date_plus_6_months__c = TRUE AND Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_Complete_Canceled_Clsd_Date__c = NULL) AND Meeting_Participant_MERC__r.Meeting_MERC__r.Date_of_Event_MERC__c != THIS_YEAR AND
                                                        Submit_for_Payment_MERC__c = 'Yes' AND
                                                        Meeting_Participant_MERC__r.RecordType.DeveloperName IN('MERC_Consulting','MERC_Service_Provider') AND
                                                        Meeting_Participant_MERC__r.Status_MERC__c NOT IN ('Cancelled', 'Rejected', 'Declined') AND
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.RecordType.DeveloperName = 'Ad_Hoc_Consulting' AND
                                                        RecordType.DeveloperName = 'Invoice_Locked_MERC' AND
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.Meeting_Status_MERC__c != 'Forecasted' AND          Meeting_Participant_MERC__r.Types_of_Service_MERC__c != 'Medical Research Consultant'  
                                                        GROUP BY Meeting_Participant_MERC__r.Account_MERC__c];
         System.debug('^^^^^^^'+Cons_Invoices_res);                                          
                                                        
        Map<Id,AggregateResult> Cons_Invoices_res_Map = new Map<Id,AggregateResult>(); 

         for(AggregateResult rset: Cons_Invoices_res)
        { 
            if(rset.get('inv_acc')!= NULL){
                Cons_Invoices_res_Map.put((ID)rset.get('inv_acc'),rset);  
        
            }
        } 


            Set<Account> Cons_Invoices_res_accounts = new Set<Account>();
            for(ID accntID: accountIds)
            {
                /* To assign the calculated Paid Invoices for Consulting Meetings to 'MERC_Paid_Invoice_after_meeting_end_date__c' field of a account associated to invoice  */
                if(Cons_Invoices_res_Map.containskey(accntID))
                {

                    for(AggregateResult res : Cons_Invoices_res){
                        Id masterRecId = (Id)res.get('inv_acc');
                        if (masterRecId == null) {
                            System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
                            continue;
                        }
                        Object aggregatedDetailVal = res.get('lre0');
                        Account a = new Account();
                        a.Id = masterRecId;
                        a.MERC_Paid_Invoice_after_meeting_end_date__c = (Decimal)aggregatedDetailVal;
                        Cons_Invoices_res_accounts.add(a);
                        
                        system.debug('%%%%%%' + a.MERC_Paid_Invoice_after_meeting_end_date__c);
                    }
            
                }
                else
                {
                    Account acc = new Account();
                    acc.Id = accntID;
                    acc.MERC_Paid_Invoice_after_meeting_end_date__c = 0;
                    Cons_Invoices_res_accounts.add(acc);
                    
                    system.debug('%%%%%%%%%%%' + acc.MERC_Paid_Invoice_after_meeting_end_date__c);
                }
            
            }
            
            //Converting set into list for Cons_Invoices_accounts
            List<Account> Cons_Invoices_accounts = new List<Account>(Cons_Invoices_res_accounts);
            update Cons_Invoices_accounts;
                                                        
        /* Query to calculate Paid Credit Note for Consulting Meetings till where meeting end date has been passed and lies in 6 month time period or Meeting has not been complete-closed/complete-cancelled. */                                                
        List<AggregateResult> Cons_CreditNote_res = [SELECT
                                            Meeting_Participant_MERC__r.Account_MERC__c inv_acc,
                                            Sum(MERC_Consulting_Contracted_Amt_excl_VAT__c) lre0
                                                FROM Invoice_MERC__c
                                                    WHERE
                                                        Meeting_Participant_MERC__r.Account_MERC__c IN :accountIds AND
                                                        (Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_End_Date_Inactive__c = TRUE AND Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_End_date_plus_6_months__c = TRUE AND Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_Complete_Canceled_Clsd_Date__c = NULL) AND Meeting_Participant_MERC__r.Meeting_MERC__r.Date_of_Event_MERC__c != THIS_YEAR AND
                                                        Submit_for_Payment_MERC__c = 'Yes' AND
                                                        Meeting_Participant_MERC__r.RecordType.DeveloperName IN('MERC_Consulting','MERC_Service_Provider') AND
                                                        Meeting_Participant_MERC__r.Status_MERC__c NOT IN ('Cancelled', 'Rejected', 'Declined') AND
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.RecordType.DeveloperName = 'Ad_Hoc_Consulting' AND
                                                        RecordType.DeveloperName = 'Credit_Note_Locked_MERC' AND Meeting_Participant_MERC__r.Types_of_Service_MERC__c != 'Medical Research Consultant'   
                                                        GROUP BY Meeting_Participant_MERC__r.Account_MERC__c];
                                                        
                                                        
        Map<Id,AggregateResult> Cons_CreditNote_res_map = new Map<Id,AggregateResult>(); 

         for(AggregateResult rset: Cons_CreditNote_res)
        { 
            if(rset.get('inv_acc')!= NULL){
                Cons_CreditNote_res_map.put((ID)rset.get('inv_acc'),rset);  
        
            }
        }

        Set<Account> Cons_CreditNote_res_accounts = new Set<Account>();
            for(ID accntID: accountIds)
            {
                /* To assign the calculated Paid Credit Note for Consulting Meetings to 'MERC_Paid_CN_after_meeting_end_date__c' field of a account associated to invoice  */
                if(Cons_CreditNote_res_map.containskey(accntID))
                {

                    for (AggregateResult res : Cons_CreditNote_res){
                        Id masterRecId = (Id)res.get('inv_acc');
                        if (masterRecId == null) {
                            System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
                            continue;
                        }
                        Object aggregatedDetailVal = res.get('lre0');
                        Account a = new Account();
                        a.Id = masterRecId;
                        a.MERC_Paid_CN_after_meeting_end_date__c = (Decimal)aggregatedDetailVal;
                        Cons_CreditNote_res_accounts.add(a);
                        
                        system.debug('@@@@@@@' + a.MERC_Paid_CN_after_meeting_end_date__c);
                    }
            
                }
                else
                {
                    Account acc = new Account();
                    acc.Id = accntID;
                    acc.MERC_Paid_CN_after_meeting_end_date__c = 0;
                    Cons_CreditNote_res_accounts.add(acc);
                    
                    system.debug('@@@@@@@@@@@@' + acc.MERC_Paid_CN_after_meeting_end_date__c);
                }
        
            }
            
            //converting set into list for Cons_CN_accounts
            List<Account> Cons_CN_accounts = new List<Account>(Cons_CreditNote_res_accounts);
            update Cons_CN_accounts;
            
            
            
            
        Map<Id, Meeting_Participant_MERC__c> mp_in_6_months = new Map<Id, Meeting_Participant_MERC__c> ( [select id, name,Status_MERC__c,Final_Fee_Rollup_MERC__c,Services_Rendered_MERC__c,Include_CAP_Roll_Up_MERC__c, Meeting_MERC__c,Account_MERC__c FROM Meeting_Participant_MERC__c where Id IN : mpList.keySet() AND(Meeting_MERC__r.MERC_Meeting_End_Date_Inactive__c = TRUE AND  Meeting_MERC__r.MERC_Meeting_End_date_plus_6_months__c = TRUE AND Meeting_MERC__r.MERC_Meeting_Complete_Canceled_Clsd_Date__c = NULL) AND Meeting_MERC__r.Date_of_Event_MERC__c != THIS_YEAR AND RecordType.DeveloperName IN('MERC_Consulting','MERC_Service_Provider') AND Status_MERC__c NOT IN ('Cancelled', 'Rejected', 'Declined') AND Meeting_MERC__r.RecordType.DeveloperName = 'Ad_Hoc_Consulting' AND Types_of_Service_MERC__c != 'Medical Research Consultant']);
             
        acclist = [select id,MERC_Allocated_CAP__c,MERC_Allocated_Fee_for_6_months__c,MERC_Paid_Invoice_after_meeting_end_date__c,MERC_Paid_CN_after_meeting_end_date__c,(select id, name,Status_MERC__c, Final_Fee_Rollup_MERC__c,Services_Rendered_MERC__c,Include_CAP_Roll_Up_MERC__c,Meeting_MERC__c,Account_MERC__c 
                            FROM Event_Participants__r) FROM Account where Id IN : accountIds];
        
       
        system.debug('~~~~~~' + acclist);
        
         for (Account account : acclist) {
                account.MERC_Allocated_Fee_for_6_months__c = 0;
            
                for (Meeting_Participant_MERC__c participant : account.Event_Participants__r) {
                  String participantStatus = participant.Status_MERC__c;
            
                    if(mp_in_6_months.containsKey(participant.Id))
                    { 
                        account.MERC_Allocated_Fee_for_6_months__c += participant.Final_Fee_Rollup_MERC__c != null ? participant.Final_Fee_Rollup_MERC__c : 0;
                
                    }

                }
            
            }
            
        update acclist;
        
       
        // For calling Cap calculator classes so that there should not be any duplicate records
        
        List<sObject> myobj =(List<sObject>)mp_list;
        MERC_AllocatedCapCalculator Cap_class = new MERC_AllocatedCapCalculator(Meeting_Participant_MERC__c.sObjectType);
        Cap_class.execute(myobj);
        
        if (!accountIds.isEmpty() && !Test.isRunningTest() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {

            //turn off trigger so we don't adjust the time on the meeting when we roll up to the participant
            MERC_TriggerHandlerStateManager.deactivate(MERC_MVIMeetingTimeZoneHandler.class);
            System.enqueueJob(new MERC_AccountRollups(accountIds));
        }
        
        
  }


  global void finish(Database.BatchableContext BC) {

  }
}