public with sharing class MERC_MergedAccountsController {

    public Id activeAccountId { get; set; }
    public ApexPages.StandardSetController ssc { get; set; }
    public MERC_MergedAccountApex mergeObject { get; set; }

    private String                         baseAcctSoqlQuery;
    private Map<Id, Merge_History_GLBL__c> mergeHistoryByWinningAccount;

    public MERC_MergedAccountsController() {
        mergeHistoryByWinningAccount = new Map<Id, Merge_History_GLBL__c>();
        for (Merge_History_GLBL__c mh : [SELECT Id
                                              , Winning_Id_GLBL__c
                                              , Original_Account_ID_GLBL__c
                                              , Merge_Processed_MERC__c
                                          FROM Merge_History_GLBL__c
                                          WHERE Merge_Processed_MERC__c = false])
        {
            mergeHistoryByWinningAccount.put(mh.Winning_Id_GLBL__c, mh);
        }
        ssc = new ApexPages.StandardSetController(mergeHistoryByWinningAccount.values());
        //ssc.setPageSize(1);

        /*----- set up the base query for the accounts so we don't need to build this in getAccounts
                every time a navigation button is clicked -----*/
        Schema.FieldSet acctFieldSet = Schema.SObjectType.Account.fieldsets.Merge_Account_Page_Main_List;
        baseAcctSoqlQuery = 'SELECT Id';
        for (Schema.FieldSetMember fsm : acctFieldSet.getFields())
        {
            if (fsm.getFieldPath() != 'Id')
                baseAcctSoqlQuery += ', ' + fsm.getFieldPath();
        }
        baseAcctSoqlQuery += ' FROM Account WHERE Id IN (';
    }

    /*----- return the accounts based on the current record set in the set controller ------*/
    public List<SelectableAccount> getAccounts()
    {
        if (ssc.getRecords().isEmpty())
        {
            return new List<SelectableAccount>();
        }
        String soqlQuery =  baseAcctSoqlQuery;
        Boolean afterFirst = false;
        for (SObject mh : ssc.getRecords())
        {
            soqlQuery += afterFirst ? ',' : '';
            soqlQuery += '\'' + mh.get('Winning_Id_GLBL__c') + '\'';
            afterFirst = true;
        }
        soqlQuery += ')';

        List<SelectableAccount> wrappedAccts = new List<SelectableAccount>();
        for (Account acct : Database.query(soqlQuery))
        {
            wrappedAccts.add(new SelectableAccount(acct));
        }
        return wrappedAccts;
    }

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

    public class SelectableAccount
    {
        public Account detail   { get; private set; }
        public Boolean selected { get; set; }

        public SelectableAccount(Account acct)
        {
            detail = acct;
            selected = false;
        }
    }
}