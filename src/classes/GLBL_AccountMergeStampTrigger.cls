public with sharing class GLBL_AccountMergeStampTrigger implements GLBL_TriggerHandler.HandlerInterface
{
	public Boolean isActive() {
		return MERC_TriggerHandlerStateManager.isActive(GLBL_AccountMergeStampTrigger.class);
	}

	public void handle() {

	}
}