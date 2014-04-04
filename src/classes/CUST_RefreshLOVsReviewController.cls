public with sharing class CUST_RefreshLOVsReviewController {

    CUST_RefreshLOVsUtil              util;
    public CST_App_Menu_Pool_GLBL__c  pool {get; private set;}
    public CST_App_Settings_CUST__c   settings {get; private set;}
    public String                     fieldsToRefresh { get; set; }

    public CUST_RefreshLOVsReviewController(ApexPages.StandardController controller) {

        CST_App_Menu_Pool_GLBL__c record = (CST_App_Menu_Pool_GLBL__c) controller.getRecord();

        if (record.Id != null) {
            // get all fields in the pool record for VF page
            MERC_Util.SelectAll allSelector = new MERC_Util.SelectAll(CST_App_Menu_Pool_GLBL__c.sObjectType, record.Id);
            pool = Database.query(allSelector.SOQL);

            // get all fields in the related App Settings record
            try 
            {
                settings = [SELECT Id FROM CST_App_Settings_CUST__c WHERE Id = :pool.App_Settings_CUST__c];
                allSelector = new MERC_Util.SelectAll(CST_App_Settings_CUST__c.sObjectType, settings.Id);
                settings = Database.query(allSelector.SOQL);
            } catch (QueryException qe) {
                System.debug(LoggingLevel.ERROR, 'When getting app settings records: '+qe.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to retrieve App Settings record.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No App Settings record found.'));
        }

        util = new CUST_RefreshLOVsUtil();
    }

    public PageReference applySelectedLOVs() {
        if (fieldsToRefresh==null || fieldsToRefresh=='') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No fields selected for refresh.'));
            return null;
        }
        
        CST_App_Menu_Pool_GLBL__c  poolToUpdate = new CST_App_Menu_Pool_GLBL__c();
        for (String field : fieldsToRefresh.split(',')) {
            poolToUpdate.put(field,pool.get(field));
        }
        poolToUpdate.Id = pool.Id;
        poolToUpdate.App_Settings_CUST__c = pool.App_Settings_CUST__c;
        update poolToUpdate;

        // now apply to AppSettings

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'fieldsToRefresh:'+fieldsToRefresh+' '+pool));
        return null;
    }
}