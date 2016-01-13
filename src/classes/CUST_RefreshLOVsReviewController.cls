/**
 * CUST_RefreshLOVsReviewController
 * Created By: Mavens Consulting
 * Description: This is the controller for the CUST_RefreshLOVsReview page. The CUST_RefreshLOVsReview page is a utility that allows a System Admin to review and apply these collected values to the active LoVs in the related App Settings record.
 */
public with sharing class CUST_RefreshLOVsReviewController {

    CUST_RefreshLOVsUtil              util;
    public Boolean                    error {get{if (error==null){return false;}else{return error;}} private set;}
    public Boolean                    success {get{if (success==null){return false;}else{return success;}} private set;}
    public String                     redirectLink {get; private set;}
    public CST_App_Menu_Pool_GLBL__c  pool {get; private set;}
    public CST_App_Settings_CUST__c   settings {get; private set;}
    public String                     fieldsToRefresh {get; set;}


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
                error = true;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No App Settings record found.'));
            error = true;

        }

        util = new CUST_RefreshLOVsUtil();
    }

    public PageReference applySelectedLOVs() {
        if (fieldsToRefresh==null || fieldsToRefresh=='') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No fields selected for refresh.'));
            return null;
        }
        
        CST_App_Menu_Pool_GLBL__c poolToUpdate = new CST_App_Menu_Pool_GLBL__c();
        String message = 'The following fields were updated successfully: ';
        try {
            for (String field : fieldsToRefresh.split(',')) {
                poolToUpdate.put(field,pool.get(field));
                settings.put(util.poolToSettingsFieldMap.get(field),pool.get(field));
                message += util.poolToSettingsFieldMap.get(field)+', ';
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                'Unable to refresh fields on App Settings record. '+e.getMessage()));
            return null;
        }
        poolToUpdate.Id = pool.Id;
        poolToUpdate.App_Settings_CUST__c = pool.App_Settings_CUST__c;
        update poolToUpdate;
        update settings;

        success = true;
        PageReference pageRef = new PageReference('/'+settings.Id);
        redirectLink = pageRef.getUrl();
        message = message.removeEnd(', ')+'<div><a href="'+redirectLink+'">Review updated App Settings record.</a></div>';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));

        return null;
    }
}