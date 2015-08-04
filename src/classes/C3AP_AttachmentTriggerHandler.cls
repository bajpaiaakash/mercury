/*************************************************************************\
    @ Author        : Abhinav Gadepalli
    @ Date          : 14-Jan-2015
    @ Test Class    : 
    @ Description   : This trigger handler for C3AP_Attachment_Trigger contains the method to prevent the deletion of Attachment 
                      from Contract Request object if the user does not have appropriate delete
                      permission on the parent record
****************************************************************************/
public with sharing class C3AP_AttachmentTriggerHandler {
	
	public static void validateAttachmentDeletionContractRequest(List<Attachment> triggerList){
		for(Attachment attach : triggerList){
			if (attach.ParentId.getSobjectType() == C3AP_Contract_Request__c.SobjectType) {
				attach.addError(System.Label.C3AP_Insufficient_Delete_Privilege);
			}
		}
	}
	
}