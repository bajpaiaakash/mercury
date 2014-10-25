public class MICO_DesignTriggerClass { 
  
	/*
	 * Creates custom Design history, as we can't do history tracking on rich text fields.
	 */
	public static void createNewDesignHistoryRecord(Map<Id,MICO_Design__c> mapDesign) {
    
		List<MICO_Design_History__c> lstDesignHistoryRecords = new List<MICO_Design_History__c>();
    
		for (Id DesignId : mapDesign.keySet()) {
		  MICO_Design_History__c newDesignHistoryRecord = new MICO_Design_History__c();
		  newDesignHistoryRecord.Design__c = mapDesign.get(DesignId).Id;
		  newDesignHistoryRecord.Design_Overview__c = mapDesign.get(DesignId).Overview__c;
		  newDesignHistoryRecord.Fields__c = mapDesign.get(DesignId).Fields__c;
		  newDesignHistoryRecord.Data_Model__c = mapDesign.get(DesignId).Data_Model__c;
		  newDesignHistoryRecord.Objects__c = mapDesign.get(DesignId).Objects__c;
		  newDesignHistoryRecord.Apex_Classes__c = mapDesign.get(DesignId).Apex_Classes__c;
		  newDesignHistoryRecord.Apex_Trigger__c = mapDesign.get(DesignId).Apex_Trigger__c;
		  newDesignHistoryRecord.Approver__c = mapDesign.get(DesignId).MICO_Approver__c;
		  newDesignHistoryRecord.Approval_Date__c = mapDesign.get(DesignId).MICO_Approval_Date__c;
		  newDesignHistoryRecord.Other_Components__c = mapDesign.get(DesignId).Other_Components__c;
		  lstDesignHistoryRecords.add(newDesignHistoryRecord);
		}   
    
		if (!lstDesignHistoryRecords.isEmpty()) {
		  insert lstDesignHistoryRecords;
		}
	}
  
	/*
	 * Stamps the approval date on the Design history records
	 */
	public static void updateApprovalDate(Map<Id,MICO_Design__c> mapApproval, DateTime approvalDate) {
     
		//get the latest Design History records to stamp the approval date    
		//Assign Approval date from approved design record to the design history record
		 
		// get all related history records
		List<MICO_Design_History__c> lstDesignHistoryApprovalRecords = [SELECT Id, Approval_Date__c, CreatedDate, Design__c
		 																FROM MICO_Design_History__c 
		 																WHERE Design__c IN :mapApproval.keySet() 
		 																ORDER BY Design__c, CreatedDate ASC];
		
		// get the latest history for each design
		Map<Id, MICO_Design_History__c> latestDesignHistories = new Map<Id, MICO_Design_History__c>();
		for (MICO_Design_History__c historyRecord : lstDesignHistoryApprovalRecords) {
			latestDesignHistories.put(historyRecord.Design__c, historyRecord);
		}
		
		// set the new datestamp
		for (MICO_Design_History__c historyRecord : latestDesignHistories.values()) {
			historyRecord.Approval_Date__c = approvalDate;
		}
	
		update latestDesignHistories.values();
	}
  
}