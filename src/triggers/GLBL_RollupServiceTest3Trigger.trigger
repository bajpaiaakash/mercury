/**
* NOTE: DO NOT PACKAGE THIS TRIGGER
**/

/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger GLBL_RollupServiceTest3Trigger on Account
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    if(GLBL_TestContext.AccountTestTriggerEnabled)
        GLBL_RollupService.triggerHandler();
}