/**
 * MERC_MeetingProcess Trigger
 * Author: Kyle Thornton, Mavens Consulting
 * Created Date: 22 Jun 2015
 * Description : This trigger calls the MERC_MeetingProcessLogicHandler class which performs an evalutation of rules on the Meeting_Process_Logic_MERC__c object.
*/

trigger MERC_MeetingProcess on Meeting_Process_MERC__c (before insert, before update, after insert, after update, after delete, after undelete) {
	new GLBL_TriggerHandler()
		.bind(GLBL_TriggerHandler.Evt.afterinsert, new MERC_MeetingProcessLogicHandler(Meeting_Process_MERC__c.SobjectType))
        .manage();
}