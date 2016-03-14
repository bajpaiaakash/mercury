/*
*   MERC_AccountEmailUpdateHandler
*   Created By:     David Helmer
*   Created Date:   February 25th 2016
*   Description:    Handles changes to Account emails
*/
public with sharing class MERC_AccountEmailUpdateHandler implements GLBL_TriggerHandler.HandlerInterface {
    
	public Boolean isActive(){
        return MERC_TriggerHandlerStateManager.isActive(MERC_AccountEmailUpdateHandler.class);
    }

    public void handle(){
        List<Id> accountIds = getPersonAccountIdsWhereEmailAddressChanged();
        MERC_MarketingCloudService.batchUpdateSubscribersWithContacts(accountIds);
    }

    private List<Id> getPersonAccountIdsWhereEmailAddressChanged(){
        Map<Id, Account> oldPersonAccountsMap = (Map<Id, Account>)Trigger.oldMap;
        Map<Id, Account> newPersonAccountsMap = (Map<Id, Account>)Trigger.newMap;
        List<Id> personAccountIds = new List<Id>();

        for(Id accountId : newPersonAccountsMap.keySet()){
            Account oldAccount = oldPersonAccountsMap.get(accountId);
            Account newAccount = newPersonAccountsMap.get(accountId);

            if(isPersonAccountAndEmailChanged(oldAccount, newAccount)){
                personAccountIds.add(newAccount.PersonContactId);
            }
        }

        return personAccountIds;
    }

    private Boolean isPersonAccountAndEmailChanged(Account oldAccount, Account newAccount){
        return newAccount.isPersonAccount 
                && (oldAccount.PersonEmail != newAccount.PersonEmail);
    }
}