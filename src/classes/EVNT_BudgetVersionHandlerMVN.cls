public with sharing class EVNT_BudgetVersionHandlerMVN implements TriggersMVN.HandlerInterface {
	public EVNT_BudgetVersionHandlerMVN() {
		
	}

	public void handle() {
		if (Trigger.isAfter) {
			execute(Trigger.old);
		}
	}

	public void execute(list<Sobject> sobjects) {
		List<Budget_EVNT__c> budgets = (List<Budget_EVNT__c>)sobjects;
	}
}