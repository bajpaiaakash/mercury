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
		Integer MAX_ATTEMPTS = 3;

        Integer attempts = MAX_ATTEMPTS;
        //query for accounts, may need to retry attempt if records are locked by another asynchronous process
        while (attempts > 0) {
          	try {
            	attempts--;
              	accounts = [SELECT Id,
								   Designated_Individual_Counter_MERC__c,
								   Contracting_Parties_Counter_MERC__c,
								   (SELECT Id FROM Designated_Individuals__r),
								   (SELECT Id FROM HCPs_Contracting_Party__r)
				              FROM Account
				             WHERE Id IN :accountIds
				             FOR UPDATE];
              	attempts = 0; //successfully queried record, exit loop
          	} catch (System.QueryException qEx) {
            	if (!qEx.getMessage().contains('Record Currently Unavailable') || attempts == 0) {
                	attempts = 0;  // exit on any other exception
              		throw qEx;  // throw exception after MAX_ATTEMPTS attempts
            	}
          	}
        }

		for (Account account : accounts) {
			//Designated Individual Count
			account.Designated_Individual_Counter_MERC__c = account.Designated_Individuals__r.size();

			//Contracting Parties Count
			account.Contracting_Parties_Counter_MERC__c = account.HCPs_Contracting_Party__r.size();
		}

		//No need to trigger anything so turn off all triggers
	    MERC_TriggerHandlerStateManager.deactivateAll();

	    //update accounts, may need to retry attempt if records are locked by another asynchronous process
	    attempts = MAX_ATTEMPTS;
	    while(attempts > 0) {
          	try {
            	attempts--;
            	update accounts;
            	attempts = 0;
          	} catch (System.DmlException dmlEx) {
                if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW') || attempts == 0) {
                    attempts = 0;  // exit on any other exception
              		throw dmlEx;  // throw exception after MAX_ATTEMPTS
            	}
           	} // end of catch
        } // end of while retry loop
	}
}