/**
 * @author Kyle Thornton
 *
 * Trigger handler which fires on before delete of an invoice that prevents deletion of locked invoices or credt notes.
 *
 */

public with sharing class MERC_LockedInvoiceDeleteHandler implements GLBL_TriggerHandler.HandlerInterface
{

	public Boolean isActive()
	{
		return MERC_TriggerHandlerStateManager.isActive(MERC_LockedInvoiceDeleteHandler.class);
	}

	public void handle() {
		//get the ids of the locked record types from the invoice object
		Set<Id> lockedRecordTypeIds = new Set<Id>();
		for (RecordType rt : [SELECT Id FROM RecordType WHERE SObjectType='Invoice_MERC__c' AND DeveloperName LIKE '%Locked_MERC%'] )
		{
			lockedRecordTypeIds.add(rt.Id);
		}

		for (Invoice_MERC__c invoice : (List<Invoice_MERC__c>)Trigger.old) {
			if (lockedRecordTypeIds.contains(invoice.RecordTypeId))
			{
				invoice.addError(Label.Error_Can_t_Delete_Locked_Invoice);
			}
		}
	}
}