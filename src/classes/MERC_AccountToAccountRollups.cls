/*
    MERC_AccountToAccountRollups
    @author : Kyle Thornton, Mavens Consulting
    @created : 13 Jul 2015
    @description : This class will take a list of Accounts and calculate rollups for
                   Designated Individuals and Contracting parties
                   This class implements the Queueable interface which allows other queueable
                   jobs to be called.
    @modified by :
    @modified date :

*/
public with sharing class MERC_AccountToAccountRollups implements Queueable{

	Set<Id> accountIds;

	public MERC_AccountToAccountRollups(Set<Id> theAccountIds) {
		accountIds = theAccountIds;
	}

	public void execute(QueueableContext context) {
		List<Account> accounts;
		accounts = [SELECT Id,
						   Designated_Individual_Counter_MERC__c,
						   Contracting_Parties_Counter_MERC__c,
						   (SELECT Id FROM Designated_Individuals__r),
						   (SELECT Id FROM HCPs_Contracting_Party__r)
		              FROM Account
		             WHERE Id IN :accountIds];

		for (Account account : accounts) {
			//Designated Individual Count
			account.Designated_Individual_Counter_MERC__c = account.Designated_Individuals__r.size();

			//Contracting Parties Count
			account.Contracting_Parties_Counter_MERC__c = account.HCPs_Contracting_Party__r.size();
		}

		//No need to trigger anything so turn off all triggers
	    MERC_TriggerHandlerStateManager.deactivateAll();
	    update accounts;
	}
}