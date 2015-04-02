public with sharing class MERC_ETSubscriberFutureProcessor {

    public static boolean SkipSubscriberUpdates = false;
        
    public MERC_ETSubscriberFutureProcessor() {}
    
    public void batchFutureEmailUpdates(List<Id> personContactIds)
    {
        if (SkipSubscriberUpdates)
            return;

        List<Id> personContactIdBatch = new List<Id>();
        Integer batchSize = 25;
        
        // batch up update callouts to avoid future method governor/callout limits
        for (Integer i = 1; i <= personContactIds.size(); i += 1) {
            personContactIdBatch.add(personContactIds.get(i - 1));
            
            if (math.mod(i, batchSize) == 0 || i == personContactIds.size()) {
                System.Debug('Deploying batch...');
                handleSubscriberUpdate(personContactIdBatch);
                personContactIdBatch = new List<Id>();
            }
        }
    }
    
    @future (callout=true)
    static void handleSubscriberUpdate(List<Id> personContactIds)
    {
        MERC_ETSubscriberProcessor subProcessor = new MERC_ETSubscriberProcessor();
        
        // use PersonContactId instead of normal Account id since that's what ET uses for the subscriber key
        Map<Id, Account> acctMap = new Map<Id, Account>();
        for (Account acct : [SELECT Id, PersonEmail, Update_Subscriber_Error_ET_MERC__c, RecordTypeId, Cust_Id_GLBL__c, Prsnl_Nbr_GLBL__c, PersonContactId
                             FROM Account WHERE PersonContactId IN :personContactIds]) {
            acctMap.put(acct.PersonContactId, acct);
        }
        
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType]);
        
        // retrieve subs        
        List<MERC_ETSubscriber> subs = subProcessor.RetrieveSubscribers(personContactIds);
        
        if (subs == null || subs.size() == 0) {
            return;
        }
        
        List<Account> acctsToUpdate = new List<Account>();
        for (MERC_ETSubscriber sub : subs) {
            Account tempAcct = acctMap.get(sub.subscriberKey);
            
            // update retrieved data
            sub.EmailAddress = tempAcct.PersonEmail;
            
            if (recordTypeMap.get(tempAcct.RecordTypeId).Name == 'HCP') {
                sub.LLYSubscriberKey = tempAcct.Cust_Id_GLBL__c;
                sub.SubscriberType = 'HCP';
            } else if (recordTypeMap.get(tempAcct.RecordTypeId).Name == 'Employee') {
                sub.LLYSubscriberKey = tempAcct.Prsnl_Nbr_GLBL__c;
                sub.SubscriberType = 'Employee';
            } else if (recordTypeMap.get(tempAcct.RecordTypeId).Name == 'Designated Individual') {
                sub.LLYSubscriberKey = '-1';
                sub.SubscriberType = 'Business Contact';
            } else {
                sub.LLYSubscriberKey = '-1';
                sub.SubscriberType = 'Business Contact';
            }
            
            if (sub.LLYSubscriberKey == null || sub.LLYSubscriberKey == '') {
                sub.LLYSubscriberKey = '-1';
            }
            
            // update sub
            tempAcct.Update_Subscriber_Error_ET_MERC__c = subProcessor.UpdateSubscriberEmail(sub);
            acctsToUpdate.add(tempAcct);
        }
        
        update acctsToUpdate;
    }
}