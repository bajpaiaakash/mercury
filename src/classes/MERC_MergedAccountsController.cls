/**
* @author Kyle Thornton
*
* This is the controller for MergedAccounts.page. This controller makes use of the MERC_MergedAccountsApex.cls
* to display the related lists for a Merge_History_GLBL__c record (represented by the winning account info as the
* losing account info will have already been wiped by the integration) when it is selected. This will allow a user
* to select the items from the losing records related lists that should be reparented and move them over to the
* winning record. The user can then mark then entire record as complete when they are done.
*/
public with sharing class MERC_MergedAccountsController {

    public String                          activeAccountId  { get; set; }
    public String                          completedMergeId { get; set; }
    public ApexPages.StandardSetController ssc              { get; set; }
    public MERC_MergedAccountApex          mergeObject      { get; set; }

    private String                         baseAcctSoqlQuery;
    private Map<String, Merge_History_GLBL__c> mergeHistoryByWinningAccount;


    public MERC_MergedAccountsController() {
        /*----- initialize the standard set contorller -----*/
        initializeSetController();

        /*----- set up the base query for the accounts so we don't need to build this in getAccounts
                every time a navigation button is clicked -----*/
        Schema.FieldSet acctFieldSet = Schema.SObjectType.Account.fieldsets.Merge_Account_Page_Main_List;
        baseAcctSoqlQuery = 'SELECT Id, Cust_Id_GLBL__c';
        for (Schema.FieldSetMember fsm : acctFieldSet.getFields())
        {
            if (fsm.getFieldPath() != 'Id' && fsm.getFieldPath() != 'Cust_Id_GLBL__c')
                baseAcctSoqlQuery += ', ' + fsm.getFieldPath();
        }
        baseAcctSoqlQuery += ' FROM Account WHERE Cust_Id_GLBL__c IN (';
    }

    private void initializeSetController()
    {
        mergeHistoryByWinningAccount = new Map<String, Merge_History_GLBL__c>();
        for (Merge_History_GLBL__c mh : [SELECT Id
                                              , Winning_Id_GLBL__c
                                              , Original_Account_ID_GLBL__c
                                              , Merge_Processed_MERC__c
                                              , Merge_Marked_Complete_MERC__c
                                          FROM Merge_History_GLBL__c
                                          WHERE Merge_Processed_MERC__c = false
                                          AND Merge_Marked_Complete_MERC__c = false
                                          LIMIT 300])
        {
            mergeHistoryByWinningAccount.put(mh.Winning_Id_GLBL__c, mh);
        }
        ssc = new ApexPages.StandardSetController(mergeHistoryByWinningAccount.values());
        updatePageSize(10);
    }

    public void updatePageSize(Integer pageSize)
    {
        ssc.setPageSize(pageSize);
    }

    /*----- return the accounts based on the current record set in the set controller ------*/
    public List<Account> getAccounts()
    {
        if (ssc.getRecords().isEmpty())
        {
            return new List<Account>();
        }
        String soqlQuery =  baseAcctSoqlQuery;
        Boolean afterFirst = false;
        for (SObject mh : ssc.getRecords())
        {
            /*----- If either lookup is null it will cause errors later, also can't merge if we don't
                    have two objects to merge so pointless to grab it anyway -----*/
            if (mh.get('Winning_Id_GLBL__c') != null && mh.get('Original_Account_ID_GLBL__c') != null)
            {
                soqlQuery += afterFirst ? ',' : '';
                soqlQuery += '\'' + mh.get('Winning_Id_GLBL__c') + '\'';
                afterFirst = true;
            }
        }
        soqlQuery += ')';

        return Database.query(soqlQuery);
    }

    /*----- based on activeAccountId get the related mergehistory record and create a MERC_MergedAccountApex object -----*/
    public void updateMergeObject()
    {
        if (mergeHistoryByWinningAccount.containsKey(activeAccountId))
        {
            Merge_History_GLBL__c activeMH = mergeHistoryByWinningAccount.get(activeAccountId);
            mergeObject = new MERC_MergedAccountApex(activeMH.Winning_Id_GLBL__c, activeMH.Original_Account_ID_GLBL__c);
        }
        else
        {
            mergeObject = null;
        }
    }

    /*----- use the id stored in completeMergeId to get the correct merge history record. use that record to create a new
            MERC_MergedAccountApex record and call the destoryLosingRecords() method. This will delete all objects still
            related to the losing account.
            set the merge history record to processed. get the current page number, reinitialize the standard set controller
            and then set the page back to that number.
            if any error occurs roll everything back and pass the messge onto the page -----*/
    public void markMergeObjectComplete()
    {
        System.Savepoint sp = Database.setSavePoint();
        try
        {
            if (mergeHistoryByWinningAccount.containsKey(completedMergeId))
            {
                Merge_History_GLBL__c activeMH = mergeHistoryByWinningAccount.get(completedMergeId);
                activeMH.Merge_Marked_Complete_MERC__c = true;
                update activeMH;

// remove after debugging
            //p('starting delete');
            //MERC_MergedAccountApex deleteObject = 
            //    new MERC_MergedAccountApex(activeMH.Winning_Id_GLBL__c, activeMH.Original_Account_ID_GLBL__c);

            //----- delete all child records associated with the losing account -----
            //deleteObject.destroyLosingRecords();

            ///*----- set the merge history object to processed -----*/
            //activeMH.Merge_Processed_MERC__c = true;
            //p('completed process of '+activeMH);
// end remove



                /*----- clear the mergeObject so there is no confusion which account related lists belong to
                        after clicking a "completed" button for a row in the account table -----*/
                mergeObject = null;

                /*----- reinitialize the set controller to make sure the item marked as complete is
                        removed and make sure the same page is shown -----*/
                Integer currentPageNumber = ssc.getPageNumber();
                initializeSetController();
                ssc.setPageNumber(currentPageNumber);
            }
            else
            {
                throw new MERC_Exception('Unable to process this row. Please contact an administrator.');
            }
        }
        catch (Exception ex)
        {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
        }
    }
        static void p(String m) {
            System.debug('\n\n\nYYZ - '+m+'\n\n\n\n');
        }
}