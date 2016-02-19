/*
    @author : Namrata Aggarwal, Tata Consultancy Services
    @created : On 12-FEB-2016 for US-39907
    @description : Trigger handler that calculates MERC_Allocated_CAP__c on Account based on an Account's participation in Consulting/Non Consulting meeting 
   
*/

public with sharing class MERC_AllocatedCapCalculator implements GLBL_TriggerHandler.HandlerInterface {

    Schema.SobjectType triggeredSobjectType;

    public MERC_AllocatedCapCalculator(Schema.SobjectType sobjectType) {
        this.triggeredSobjectType = sObjectType;
    }

    public Boolean isActive() {
        return true;
    }

    public void handle() {
        if (Trigger.isUpdate || Trigger.isUndelete) {
            execute(Trigger.new);
        } else if (Trigger.isDelete) {
            execute(Trigger.old);
        }
    }

    public void execute(List<Sobject> sobjects) {
        List<Invoice_MERC__c> invoices;
        if (this.triggeredSobjectType == Invoice_MERC__c.sObjectType) {
            invoices = (List<Invoice_MERC__c>)sobjects;
        } else if (this.triggeredSobjectType == Invoice_Line_Item_MERC__c.sObjectType) {
            Set<Id> invoiceIds = new Set<Id>();
            for (Sobject lineItem : sobjects) {
                invoiceIds.add((Id)lineItem.get('Invoice_MERC__c'));
            }
            invoices = [SELECT ID, Meeting_Participant_Account_Id_MERC__c FROM Invoice_MERC__c WHERE ID in :invoiceIds];
        } else if (this.triggeredSobjectType == Meeting_MERC__c.sObjectType) {
            List<Meeting_MERC__c> meetings = (List<Meeting_MERC__c>)sobjects;
            Set<Id> meetingIds = new Set<Id>();
            for (Meeting_MERC__c m : meetings) {
                if (
                    Trigger.oldMap.get(m.Id).get('Meeting_Status_MERC__c') != m.Meeting_Status_MERC__c ||
                    Trigger.oldMap.get(m.Id).get('End_Date_of_Event_MERC__c') != m.End_Date_of_Event_MERC__c ||
                    Trigger.oldMap.get(m.Id).get('Date_of_Event_MERC__c') != m.Date_of_Event_MERC__c ||
                    Trigger.oldMap.get(m.Id).get('MERC_Meeting_End_Date_Inactive__c') != m.MERC_Meeting_End_Date_Inactive__c ||
                    Trigger.oldMap.get(m.Id).get('MERC_Meeting_Complete_Canceled_Clsd_Date__c') != m.MERC_Meeting_Complete_Canceled_Clsd_Date__c
                ) {
                    meetingIds.add(m.Id);
                }
            }
            Set<Id> mpIds = new Set<Id>();
            Set<Id> invoiceIds = new Set<Id>();
            
            for (Meeting_Participant_MERC__c mp : [SELECT Id FROM Meeting_Participant_MERC__c WHERE Meeting_MERC__c in :meetingIds]) {
                    mpIds.add(mp.Id);
                }
            
            for (Invoice_MERC__c inv : [SELECT Id FROM Invoice_MERC__c WHERE Meeting_Participant_MERC__c in :mpIds]) {
                    invoiceIds.add(inv.Id);
                }
                      
            invoices = [SELECT ID, Meeting_Participant_Account_Id_MERC__c FROM Invoice_MERC__c WHERE ID in :invoiceIds];
        } else if (this.triggeredSobjectType == Meeting_Participant_MERC__c.sObjectType) {
            List<Meeting_Participant_MERC__c> mp = (List<Meeting_Participant_MERC__c>)sobjects;
            Set<Id> mpIds = new Set<Id>();
            for (Meeting_Participant_MERC__c m : mp) {
                /*if (
                    Trigger.oldMap.get(m.Id).get('Status_MERC__c') != m.Status_MERC__c ||
                    Trigger.oldMap.get(m.Id).get('RecordTypeID') != m.RecordTypeID ||
                    Trigger.oldMap.get(m.Id).get('Types_of_Service_MERC__c') != m.Types_of_Service_MERC__c                    
                )*/ 
                    mpIds.add(m.Id);
                }
            
            
            
            Set<Id> invoiceIds = new Set<Id>();
            
            for (Invoice_MERC__c inv : [SELECT Id FROM Invoice_MERC__c WHERE Meeting_Participant_MERC__c in :mpIds]) {
                    invoiceIds.add(inv.Id);
                }
            
            invoices = [SELECT ID, Meeting_Participant_Account_Id_MERC__c FROM Invoice_MERC__c WHERE ID in :invoiceIds];
        }


        if (invoices.size() == 0) return;

        Set<Id> meetingParticipantIds = new Set<Id>();
        
        Set<Id> accountIds = new Set<Id>();

        // To get the account Ids associated to invoices
        for (Invoice_MERC__c i : invoices)
            accountIds.add(i.Meeting_Participant_Account_Id_MERC__c);

        System.debug('>>>> '+accountIds);

        // Query to calculate Paid Invoices for Consulting Meetings till the meeting End date or Complete-Cancelled or Complete-closed.
        List<AggregateResult> Cons_Invoices_res = [SELECT
                                            Meeting_Participant_MERC__r.Account_MERC__c inv_acc,
                                            Sum(MERC_Consulting_Contracted_Amt_excl_VAT__c) lre0
                                                FROM Invoice_MERC__c
                                                    WHERE
                                                        Meeting_Participant_MERC__r.Account_MERC__c IN :accountIds AND
                                                        (Meeting_Participant_MERC__r.Meeting_MERC__r.Date_of_Event_MERC__c = THIS_YEAR OR
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_End_Date_Inactive__c = False) AND Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_Complete_Canceled_Clsd_Date__c = NULL AND
                                                        Submit_for_Payment_MERC__c = 'Yes' AND
                                                        Meeting_Participant_MERC__r.RecordType.DeveloperName IN('MERC_Consulting','MERC_Service_Provider') AND
                                                        Meeting_Participant_MERC__r.Status_MERC__c != 'Cancelled' AND
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.RecordType.DeveloperName = 'Ad_Hoc_Consulting' AND
                                                        RecordType.DeveloperName = 'Invoice_Locked_MERC' AND
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.Meeting_Status_MERC__c != 'Forecasted' AND          Meeting_Participant_MERC__r.Types_of_Service_MERC__c != 'Medical Research Consultant'  
                                                        GROUP BY Meeting_Participant_MERC__r.Account_MERC__c];
                                                            
                                                        
            System.debug('>>>> '+ Cons_Invoices_res);
            
            
        // Query to calculate Paid Invoices for Non-Consulting Meetings till the meeting End date or Complete-Cancelled or Complete-closed.
        List<AggregateResult>  Non_Cons_Invoices_res = [SELECT
                                            Meeting_Participant_MERC__r.Account_MERC__c inv_acc,
                                            Sum(MERC_Consulting_Contracted_Amt_excl_VAT__c) lre0
                                                FROM Invoice_MERC__c
                                                    WHERE
                                                        Meeting_Participant_MERC__r.Account_MERC__c IN :accountIds AND
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.RecordType.DeveloperName != 'Ad_Hoc_Consulting' AND
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.Date_of_Event_MERC__c = THIS_YEAR AND Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_Complete_Canceled_Clsd_Date__c = NULL AND
                                                        Submit_for_Payment_MERC__c = 'Yes' AND
                                                        Meeting_Participant_MERC__r.RecordType.DeveloperName IN('MERC_Consulting','MERC_Service_Provider') AND
                                                        Meeting_Participant_MERC__r.Status_MERC__c != 'Cancelled' AND                                                       
                                                        RecordType.DeveloperName = 'Invoice_Locked_MERC' AND Meeting_Participant_MERC__r.Meeting_MERC__r.Meeting_Status_MERC__c != 'Forecasted' AND Meeting_Participant_MERC__r.Types_of_Service_MERC__c != 'Medical Research Consultant' 
                                                            GROUP BY Meeting_Participant_MERC__r.Account_MERC__c];
        
        
        // Map to pair the result of calulated 'Paid Invoices for Consulting Meetings' with its associated 'Account Id'.
        Map<Id,AggregateResult> Cons_Invoices_res_Map = new Map<Id,AggregateResult>(); 

         for(AggregateResult rset: Cons_Invoices_res)
        { 
            if(rset.get('inv_acc')!= NULL){
                Cons_Invoices_res_Map.put((ID)rset.get('inv_acc'),rset);  
        
            }
        } 
        
        // Map to pair the result of calulated 'Paid Invoices for Non-Consulting Meetings' with its associated 'Account Id'.
        Map<Id,AggregateResult> Non_Cons_Invoices_res_Map = new Map<Id,AggregateResult>(); 

         for(AggregateResult rset: Non_Cons_Invoices_res)
        { 
            if(rset.get('inv_acc')!= NULL){
                Non_Cons_Invoices_res_Map.put((ID)rset.get('inv_acc'),rset);  
        
            }
        } 

            Set<Account> Cons_Invoices_res_accounts = new Set<Account>();
            for(ID accntID: accountIds)
            {
                /* To assign the calculated Paid Invoices for Consulting Meetings to 'MERC_Paid_Cap_for_Cons_Inv_Used_for_AC__c' field of a account associated to invoice  */
                if(Cons_Invoices_res_Map.containskey(accntID))
                {

                    for (AggregateResult res : Cons_Invoices_res){
                        Id masterRecId = (Id)res.get('inv_acc');
                        if (masterRecId == null) {
                            System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
                            continue;
                        }
                        Object aggregatedDetailVal = res.get('lre0');
                        Account a = new Account();
                        a.Id = masterRecId;
                        a.MERC_Paid_Cap_for_Cons_Inv_Used_for_AC__c = (Decimal)aggregatedDetailVal;
                        Cons_Invoices_res_accounts.add(a);
                    }
            
                }
                else
                {
                    Account acc = new Account();
                    acc.Id = accntID;
                    acc.MERC_Paid_Cap_for_Cons_Inv_Used_for_AC__c = 0;
                    Cons_Invoices_res_accounts.add(acc);
                }
        
            }
            
            
            List<Account> Cons_Invoices_accounts = new List<Account>();
            for(Account Cons_Invoices_acc : Cons_Invoices_res_accounts)
                Cons_Invoices_accounts.add(Cons_Invoices_acc);
             
            update Cons_Invoices_accounts;

            Set<Account> Non_Cons_Invoices_res_accounts = new Set<Account>();
            
            for(ID accntID: accountIds)
            {
                /* To assign the calculated Paid Invoices for Non-Consulting Meetings to 'MERC_Paid_Cap_for_NonCon_Inv_Used_for_AC__c' field of a account associated to invoice  */
                if(Non_Cons_Invoices_res_Map.containskey(accntID))
                {
                    for (AggregateResult res : Non_Cons_Invoices_res){
                        Id masterRecId = (Id)res.get('inv_acc');
                        if (masterRecId == null) {
                            System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
                            continue;
                        }
                        Object aggregatedDetailVal = res.get('lre0');
                
                        Account a = new Account();
                        a.Id = masterRecId;
                        a.MERC_Paid_Cap_for_NonCon_Inv_Used_for_AC__c =(Decimal)aggregatedDetailVal;
                        Non_Cons_Invoices_res_accounts.add(a);
                    }
            
                }
                else
                {
                    Account acc = new Account();
                    acc.Id = accntID;
                    acc.MERC_Paid_Cap_for_NonCon_Inv_Used_for_AC__c = 0;
                    Non_Cons_Invoices_res_accounts.add(acc);
                }
            }

            List<Account> Non_Cons_Invoices_accounts = new List<Account>();
            for(Account Non_Cons_Invoices_acc : Non_Cons_Invoices_res_accounts)
                Non_Cons_Invoices_accounts.add(Non_Cons_Invoices_acc);
             
            update Non_Cons_Invoices_accounts;
        
        
        /* ------------------- To make calculations related to Credit Note --------------------- */
                     
        
            // Query to calculate Paid Credit Note for Consulting Meetings till the meeting End date or Complete-Cancelled or Complete-closed.
            List<AggregateResult> Cons_CreditNote_res = [SELECT
                                            Meeting_Participant_MERC__r.Account_MERC__c inv_acc,
                                            Sum(MERC_Consulting_Contracted_Amt_excl_VAT__c) lre0
                                                FROM Invoice_MERC__c
                                                    WHERE
                                                        Meeting_Participant_MERC__r.Account_MERC__c IN :accountIds AND
                                                        (Meeting_Participant_MERC__r.Meeting_MERC__r.Date_of_Event_MERC__c = THIS_YEAR OR
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_End_Date_Inactive__c = False) AND  Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_Complete_Canceled_Clsd_Date__c = NULL AND
                                                        Submit_for_Payment_MERC__c = 'Yes' AND
                                                        Meeting_Participant_MERC__r.RecordType.DeveloperName IN('MERC_Consulting','MERC_Service_Provider') AND
                                                        Meeting_Participant_MERC__r.Status_MERC__c != 'Cancelled' AND
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.RecordType.DeveloperName = 'Ad_Hoc_Consulting' AND
                                                        RecordType.DeveloperName = 'Credit_Note_Locked_MERC' AND Meeting_Participant_MERC__r.Types_of_Service_MERC__c != 'Medical Research Consultant'   
                                                        GROUP BY Meeting_Participant_MERC__r.Account_MERC__c];
                                                            
                                                        
            System.debug('>>>> '+ Cons_CreditNote_res);

            // Query to calculate Paid Credit Note for Non-Consulting Meetings till the meeting End date or Complete-Cancelled or Complete-closed.
            List<AggregateResult> Non_Cons_CreditNote_res = [SELECT
                                            Meeting_Participant_MERC__r.Account_MERC__c inv_acc,
                                            Sum(MERC_Consulting_Contracted_Amt_excl_VAT__c) lre0
                                                FROM Invoice_MERC__c
                                                    WHERE
                                                        Meeting_Participant_MERC__r.Account_MERC__c IN :accountIds AND
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.RecordType.DeveloperName != 'Ad_Hoc_Consulting' AND
                                                        Meeting_Participant_MERC__r.Status_MERC__c != 'Cancelled' AND
                                                        Meeting_Participant_MERC__r.RecordType.DeveloperName IN('MERC_Consulting','MERC_Service_Provider') AND
                                                        Meeting_Participant_MERC__r.Meeting_MERC__r.Date_of_Event_MERC__c = THIS_YEAR AND Meeting_Participant_MERC__r.Meeting_MERC__r.MERC_Meeting_Complete_Canceled_Clsd_Date__c = NULL AND
                                                        Submit_for_Payment_MERC__c = 'Yes' AND 
                                                        RecordType.DeveloperName = 'Credit_Note_Locked_MERC' AND Meeting_Participant_MERC__r.Types_of_Service_MERC__c != 'Medical Research Consultant' 
                                                            GROUP BY Meeting_Participant_MERC__r.Account_MERC__c];
        
        
        // Map to pair the result of calulated 'Paid Credit Note for Consulting Meetings' with its associated 'Account Id'.
        Map<Id,AggregateResult> Cons_CreditNote_res_map = new Map<Id,AggregateResult>(); 

         for(AggregateResult rset: Cons_CreditNote_res)
        { 
            if(rset.get('inv_acc')!= NULL){
                Cons_CreditNote_res_map.put((ID)rset.get('inv_acc'),rset);  
        
            }
        } 
        
        // Map to pair the result of calulated 'Paid Credit Note for Non-Consulting Meetings' with its associated 'Account Id'.
        Map<Id,AggregateResult> Non_Cons_CreditNote_res_map = new Map<Id,AggregateResult>(); 

         for(AggregateResult rset: Non_Cons_CreditNote_res)
        { 
            if(rset.get('inv_acc')!= NULL){
                Non_Cons_CreditNote_res_map.put((ID)rset.get('inv_acc'),rset);  
        
            }
        } 

            Set<Account> Cons_CreditNote_res_accounts = new Set<Account>();
            for(ID accntID: accountIds)
            {
            
                /* To assign the calculated Paid Credit Note for Consulting Meetings to 'MERC_Paid_Cap_for_Cons_CN_Used_for_AC__c' field of a account associated to invoice  */
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
                        a.MERC_Paid_Cap_for_Cons_CN_Used_for_AC__c = (Decimal)aggregatedDetailVal;
                        Cons_CreditNote_res_accounts.add(a);
                    }
            
                }
                else
                {
                    Account acc = new Account();
                    acc.Id = accntID;
                    acc.MERC_Paid_Cap_for_Cons_CN_Used_for_AC__c = 0;
                    Cons_CreditNote_res_accounts.add(acc);
                }
        
            }
            List<Account> Cons_CN_accounts = new List<Account>();
            for(Account Cons_CN_acc : Cons_CreditNote_res_accounts)
                Cons_CN_accounts.add(Cons_CN_acc);

            update Cons_CN_accounts;
 
            Set<Account> Non_Cons_CreditNote_res_accounts = new Set<Account>();
            
            for(ID accntID: accountIds)
            {
            
                /* To assign the calculated Paid Credit Note for Non-Consulting Meetings to 'MERC_Paid_Cap_for_NonCons_CN_Used_for_AC__c' field of a account associated to invoice  */
                if(Non_Cons_CreditNote_res_map.containskey(accntID))
                {
                    for (AggregateResult res : Non_Cons_CreditNote_res){
                        Id masterRecId = (Id)res.get('inv_acc');
                        if (masterRecId == null) {
                            System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
                            continue;
                        }
                        Object aggregatedDetailVal = res.get('lre0');
                
                        Account a = new Account();
                        a.Id = masterRecId;
                        a.MERC_Paid_Cap_for_NonCons_CN_Used_for_AC__c =(Decimal)aggregatedDetailVal;
                        Non_Cons_CreditNote_res_accounts.add(a);
                    }
            
                }
                else
                {
                    Account acc = new Account();
                    acc.Id = accntID;
                    acc.MERC_Paid_Cap_for_NonCons_CN_Used_for_AC__c = 0;
                    Non_Cons_CreditNote_res_accounts.add(acc);
                }
            }

        List<Account> Non_Cons_CreditNote_accounts = new List<Account>();
            for(Account Non_Cons_CreditNote_acc : Non_Cons_CreditNote_res_accounts)
                Non_Cons_CreditNote_accounts.add(Non_Cons_CreditNote_acc);
             
            update Non_Cons_CreditNote_accounts;
            
            
    }
}