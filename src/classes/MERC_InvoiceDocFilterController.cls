public without sharing class MERC_InvoiceDocFilterController {

	public MERC_InvoiceDocFilterController() {
	}

	public PageReference redirect() {
		PageReference pageRef;
		try {
			MERC_InvoiceDocFilterController.deleteOldDocsInContent(new List<Id>{Apexpages.currentPage().getParameters().get('eid')}, Apexpages.currentPage().getParameters().get('type'));

			pageRef = new PageReference(Apexpages.currentPage().getParameters().get('loopurl'));
			pageRef.getParameters().putAll(Apexpages.currentPage().getParameters());
			pageRef.setRedirect(true);
			return pageRef;
		} catch (Exception e) {
			ApexPages.addMessages(e);			
		}
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.valueOf(Apexpages.currentPage().getParameters())));
		return null;
	}

	public void deleteOldInvoiceContent() {
        Id currRecId = (Id)ApexPages.currentPage().getParameters().get('id');
        if (ApexPages.currentPage().getParameters().containsKey('tif') && ApexPages.currentPage().getParameters().get('tif') == '1') {
            deleteOldDocsInContent(new List<Id>{currRecId},'TIFF');
        }
        if (ApexPages.currentPage().getParameters().containsKey('pdf') && ApexPages.currentPage().getParameters().get('pdf') == '1') {
            deleteOldDocsInContent(new List<Id>{currRecId},'PDF');
        }        
    }

	/*
	 * To be called by MERC_NewContentController or any process that initiates the generation of
	 * an Invoice PDF, TIF, or XML file. Informatica on Demand cannot support multiple PDF content on a single Invoice record
	 * so this method deletes older PDFs (or the filetype designated), with the presumption that they are out-dated.
	 *
	 * This method is not a fail-safe as the running user may not have access to the Content documents. 
	 * Placed in this class to isolate and take advantage of "without sharing" context.
	 */
	public static void deleteOldDocsInContent(List<Id> recordIds, String fileType) {
		fileType = fileType.toUpperCase();

        Set<Id> contentDocumentIds = new Set<Id>();
        Set<Id> contentVerIds = new set<Id>();
        for (ContentVersion cv : [SELECT Id, ContentDocumentId From ContentVersion WHERE Invoice_MERC__c in :recordIds AND FileType = :fileType AND Document_Type_MERC__c = 'Invoices']) {
            contentDocumentIds.add(cv.ContentDocumentId);
            contentVerIds.add(cv.Id);
        }
        try {
        	List<ContentDocument> cds = [SELECT ID, OwnerId FROM ContentDocument WHERE Id in :contentDocumentIds];
        	for (ContentDocument cd : cds) {
        		cd.OwnerId = UserInfo.getUserId();
        	}
        	// update cds;
        	delete [SELECT ID FROM ContentDocument WHERE Id in :contentDocumentIds];
        } catch (DmlException e) {
        	System.debug(LoggingLevel.INFO, 'Unable to delete Content Documents. Does this user have permission to this library? err:'+e);
        } catch (Exception e) {
        	System.debug('err:'+e);
        }
	}
}