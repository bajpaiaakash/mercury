/**
 * @author Joseph Ferraro
 *
 * Docusign inserts executed version(s) of the contracts to attachment via DocusignConnect service (bc they dont support content). 
 * this apex class copies that attachment to content and deletes the attachment
 */


public with sharing class MERC_HandleDocusignAttachmentInsert implements GLBL_TriggerHandler.HandlerInterface {
	
	public Boolean isActive() {
	    return true;
	}

	public void handle() {
		if (Trigger.isInsert && Trigger.isAfter && Trigger.new.size() == 1) {
			String hcpContractPrefix = Schema.SObjectType.HCP_Contract_MERC__c.getKeyPrefix();
			Attachment thisObj = (Attachment) Trigger.new.get(0);
			String parentId = thisObj.ParentId;
			if (parentId.startsWith(hcpContractPrefix)) {
				execute(Trigger.new.get(0).Id);
			}
	   	}
	}
	

	@future
	public static void execute(String attachmentId) {        
		Attachment a = [SELECT Id, Name, ParentId, Body FROM Attachment WHERE Id = :attachmentId];
		String hcpContractPrefix = Schema.SObjectType.HCP_Contract_MERC__c.getKeyPrefix();
		List<ContentVersion> cvs = new List<ContentVersion>();
		
		String parentId = a.ParentId;
		if (parentId.startsWith(hcpContractPrefix)) {
			Id workspaceId = [SELECT FirstPublishLocationId FROM ContentVersion WHERE HCP_Contract_MERC__c = :parentId Limit 1].FirstPublishLocationId;		
			ContentVersion c = new ContentVersion();
			c.HCP_Contract_MERC__c = parentId;
			c.Title = a.Name;
			c.FirstPublishLocationId = workspaceId;
			c.PathOnClient = a.Name;
			c.VersionData = a.Body;
			insert c;
			delete a;
		}
	}
}