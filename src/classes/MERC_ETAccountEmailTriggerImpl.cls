public with sharing class MERC_ETAccountEmailTriggerImpl {

    private MERC_ETSubscriberFutureProcessor subFutureProcessor = new MERC_ETSubscriberFutureProcessor();

    public MERC_ETAccountEmailTriggerImpl() {}
    
    public void doAfterUpdate(List<Account> oldPersonAccounts, List<Account> newPersonAccounts, Map<Id, Account> oldPersonAccountsMap, Map<Id, Account> newPersonAccountsMap) {
        List<Id> acctIdsWithEmailUpdates = getAccountsWithChangedEmailAddresses(oldPersonAccountsMap, newPersonAccountsMap);
        
        if (acctIdsWithEmailUpdates.size() > 0) {
            subFutureProcessor.batchFutureEmailUpdates(acctIdsWithEmailUpdates);
        }
    }

    private List<Id> getAccountsWithChangedEmailAddresses(Map<Id, Account> oldAcctMap, Map<Id, Account> newAcctMap) {
        List<Id> personAccountsWithChangedEmailAddresses = new List<Id>();
        
        for (Id id : newAcctMap.keySet()) {
            if (newAcctMap.get(id).isPersonAccount && newAcctMap.get(id).PersonEmail != oldAcctMap.get(id).PersonEmail) {
                personAccountsWithChangedEmailAddresses.add(newAcctMap.get(id).PersonContactId);
            }
        }
        
        return personAccountsWithChangedEmailAddresses;
    }
}