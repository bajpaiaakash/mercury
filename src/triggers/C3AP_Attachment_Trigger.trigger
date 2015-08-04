/*************************************************************************\
    @ Author        : Abhinav Gadepalli
    @ Date          : 14-Jan-2015
    @ Test Class    : 
    @ Description   : This trigger on Attachment will be used to prevent the deletion of Attachment 
                      from Contract Request object if the user does not have appropriate delete
                      permission on the parent record
****************************************************************************/
trigger C3AP_Attachment_Trigger on Attachment (before delete, before update) {
	if(trigger.isBefore){
		if(trigger.isDelete){
			C3AP_AttachmentTriggerHandler.validateAttachmentDeletionContractRequest(trigger.old);
		}
		if(trigger.isUpdate){
			C3AP_AttachmentTriggerHandler.validateAttachmentDeletionContractRequest(trigger.new);
		}
	}
}