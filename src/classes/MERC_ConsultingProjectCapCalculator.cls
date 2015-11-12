/**
* @author Joseph Ferraro
*
* Trigger handler that calculates Consulting_Project_Paid_CAP_MERC__c on Account based on an Account's participation in Consulting projects for the year
*/

public with sharing class MERC_ConsultingProjectCapCalculator implements GLBL_TriggerHandler.HandlerInterface {

    Schema.SobjectType triggeredSobjectType;

    public MERC_ConsultingProjectCapCalculator(Schema.SobjectType sobjectType) {
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

    void execute(List<Sobject> sobjects) {
        List<Invoice_MERC__c> invoices;
        if (this.triggeredSobjectType == Invoice_MERC__c.sObjectType) {
            invoices = (List<Invoice_MERC__c>)sobjects;
        } else if (this.triggeredSobjectType == Invoice_Line_Item_MERC__c.sObjectType) {
            Set<Id> invoiceIds = new Set<Id>();
            for (Sobject lineItem : sobjects) {
                invoiceIds.add((Id)lineItem.get('Invoice_MERC__c'));
            }
            invoices = [SELECT ID, Meeting_Participant_Account_Id_MERC__c FROM Invoice_MERC__c WHERE ID in :invoiceIds];
        }

        if (invoices.size() == 0) return;

        Set<Id> meetingParticipantIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for (Invoice_MERC__c i : invoices)
            accountIds.add(i.Meeting_Participant_Account_Id_MERC__c);

        System.debug('>>>> '+accountIds);

        List<AggregateResult> results = [SELECT
                                            Meeting_Participant_MERC__r.Account_MERC__c inv_acc,
                                            Sum(Consulting_Project_Amount_excl_VAT_MERC__c) lre0
                                                FROM Invoice_MERC__c
                                                    WHERE
                                                        Meeting_Participant_MERC__r.Account_MERC__c IN :accountIds AND
                                                        Invoice_Date_MERC__c = THIS_YEAR AND
                                                        Submit_for_Payment_MERC__c = 'Yes' AND 
                                                        RecordType.DeveloperName != 'Invoice_Invalid_MERC'  /* Added by Namrata Aggarwal on 11/04/2015 for R14 Defect */
                                                            GROUP BY Meeting_Participant_MERC__r.Account_MERC__c];

        System.debug('>>>> '+results);

         Map<Id,AggregateResult> accResMap = new Map<Id,AggregateResult>(); 

         for(AggregateResult rset: results)
        { 
    if(rset.get('inv_acc')!= NULL){
        accResMap.put((ID)rset.get('inv_acc'),rset);  
        //accResMap.put(rset.Meeting_Participant_MERC__r.Account_MERC__c,rset); 
    }
         } 


            List<Account> accounts = new List<Account>();
            for(ID accntID: accountIds)
            {
            if(accResMap.containskey(accntID))
            {

            for (AggregateResult res : results){
                System.debug('========== '+res);
                Id masterRecId = (Id)res.get('inv_acc');
                if (masterRecId == null) {
                    System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
                    continue;
                }
                Object aggregatedDetailVal = res.get('lre0');
                Account a = new Account();
                a.Id = masterRecId;
                a.Consulting_Project_Paid_CAP_MERC__c = (Decimal)aggregatedDetailVal;
                accounts.add(a);
            }
        }
        else
        {
                Account acc = new Account();
                acc.Id = accntID;
                acc.Consulting_Project_Paid_CAP_MERC__c = 0;
                accounts.add(acc);
        }
        }

        update accounts;
    }
}