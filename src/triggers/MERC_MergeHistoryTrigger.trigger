/**
  * @author Paul Battisson, Mavens Consulting
  *
  * This trigger is used to process the new records to mark those where there are no child records
  * being reparented as complete and processed.
  */
trigger MERC_MergeHistoryTrigger on Merge_History_GLBL__c (before insert) {
	new GLBL_TriggerHandler().bind(GLBL_TriggerHandler.Evt.beforeinsert, new MERC_MergeHistoryStampTriggerHandler()).manage();
}