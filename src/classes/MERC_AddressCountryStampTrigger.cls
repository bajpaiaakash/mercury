/**
 * @author David Helmer
 *
 * Responsible for stamping the Country on related Accounts when the Country changes or the address is inserted for addresses
 * of record type Other
 */


public with sharing class MERC_AddressCountryStampTrigger implements GLBL_TriggerHandler.HandlerInterface {    
    public Boolean isActive() {
        return MERC_TriggerHandlerStateManager.isActive(MERC_AddressCountryStampTrigger.class);
    }

    public void handle() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Map<Id,String> countriesToAccounts = getCountriesToAccounts(Trigger.new);
            stampCountriesOnAccounts(countriesToAccounts);
        }
    }

    Map<Id,String> getCountriesToAccounts(List<Sobject> sobjects){
        Id masteredAddressRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Address_GLBL__c' AND DeveloperName = 'Mastered_Address' LIMIT 1].Id;
        List<Address_GLBL__c> addresses = (List<Address_GLBL__c>)sobjects;
        Map<Id,String> countriesToAccounts = new Map<Id, String>();
        for(Address_GLBL__c address : addresses){
            if(address.RecordTypeId != masteredAddressRecordTypeId
                && address.Priority_Rank_Nbr_GLBL__c == 1){
                if (Trigger.isInsert){
                    countriesToAccounts.put(address.Account_GLBL__c, address.Adrs_Cntry_Cd_GLBL__c);
                } else if (Trigger.isUpdate && (String)Trigger.oldMap.get(address.Id).get('Adrs_Cntry_Cd_GLBL__c') != address.Adrs_Cntry_Cd_GLBL__c){
                    countriesToAccounts.put(address.Account_GLBL__c, address.Adrs_Cntry_Cd_GLBL__c);
                }
            }            
        }
        return countriesToAccounts;
    }

    void stampCountriesOnAccounts(Map<Id, String> countriesToAccounts) {
        Map<Id, Account> accountMap = new Map<Id,Account>([SELECT Id, Primary_Address_Country_GLBL__c FROM Account WHERE Id IN :countriesToAccounts.keySet()]);
        List<Account> accountsToUpdate = new List<Account>();
        for(Id accountId : countriesToAccounts.keySet()){
            if(accountMap.containsKey(accountId)){
                Account accountToUpdate = accountMap.get(accountId);
                accountToUpdate.Primary_Address_Country_GLBL__c = countriesToAccounts.get(accountId);
                accountsToUpdate.add(accountToUpdate);
            }
        }
        update accountsToUpdate;
    }
}