/**
* NOTE: DO NOT PACKAGE THIS TRIGGER
**/

/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger GLBL_RollupServiceTestTrigger on Opportunity
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	if(GLBL_TestContext.OpportunityTestTriggerEnabled)
    	GLBL_RollupService.triggerHandler();
}