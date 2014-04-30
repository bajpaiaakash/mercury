/**
* @author Kyle Thornton
*
* Represents a single Merge History record and the related lists associated to the accounts in the merge history.
* This class will gather up all of the related lists that can be merged (configured on the Account_Merge_Related_Lists_MERC__c
* custom setting) and display the records for the winning and losing account side by side. Losing account related list
* records can then be selected and reparented over to the winning record.
*/
public class MERC_MergedAccountApex {

    private Account winningAccount = new Account();
    private Id      losingAccountId;
    private List<RelatedListGroup> relatedLists;
    private static Map<String, Account_Merge_Related_Lists_MERC__c> relatedListSettings = Account_Merge_Related_Lists_MERC__c.getAll();

    public MERC_MergedAccountApex(Id winnerId, Id loserId)
    {
        losingAccountId = loserId;

        /*----- Build the query string for the winning account from the field set -----*/
        Set<String> acctFieldSet = new Set<String>{'Id'};
        for(Schema.FieldSetMember fsm : Schema.SObjectType.Account.fieldSets.Merge_Account_Page_Main_List.getFields())
        {
            acctFieldSet.add(fsm.getFieldPath());
        }
        String soqlQuery = 'SELECT ';
        for (String s : acctFieldSet)
        {
            soqlQuery += s + ', ';
        }
        /*----- remove the last comma -----*/
        soqlQuery = soqlQuery.left(soqlQuery.length() - 2);
        soqlQuery += ' FROM Account WHERE Id = \'' + winnerId +'\' LIMIT 1';

        System.debug(soqlQuery);

        /*----- Use the query string to get the winning and losing account -----*/
        if (String.isNotBlank(winnerId))
        {
            try
            {
                winningAccount = database.query(soqlQuery);
            }
            catch (System.QueryException ex)
            {
                System.debug('\n\n\nQuery Exception: ' + ex + '\n\n\n');
                throw new MERC_Exception('An error has occurred querying for the account information.');
            }
        }
    }

    public List<RelatedListGroup> getAllRelatedLists()
    {
        if (relatedLists == null)
        {
            relatedLists = new List<RelatedListGroup>();

            List<String> objectsForSchema = new List<String>();
            for (Account_Merge_Related_Lists_MERC__c rl : relatedListSettings.values())
            {
                objectsForSchema.add(rl.Name);
            }
            List<Schema.DescribeSObjectResult> descResults = Schema.describeSObjects(objectsForSchema);

            for(Schema.DescribeSObjectResult dr : descResults)
            {
                Account_Merge_Related_Lists_MERC__c settings = relatedListSettings.get(dr.getName());
                RelatedListGroup thisRL = new RelatedListGroup( settings
                                                              , dr.getLabel()
                                                              , dr.getName()
                                                              , winningAccount.Id
                                                              , losingAccountId
                                                              , dr.fieldSets.getMap().get(settings.Winning_Acct_Related_List_Field_Set_MERC__c).getFields()
                                                              , dr.fieldSets.getMap().get(settings.Losing_Acct_Related_List_Field_Set_MERC__c).getFields()
                );

                relatedLists.add(thisRL);
            }
        }
        return relatedLists;
    }

    public class RelatedListGroup
    {
        public List<Schema.FieldSetMember> winningFields    { get; private set; }
        public List<Schema.FieldSetMember> losingFields     { get; private set; }
        public String                      sObjectLabel     { get; private set; }
        public Account_Merge_Related_Lists_MERC__c settings { get; private set; }

        private String winningListSoql;
        private String losingListSoql;
        private String sObjectName;
        private String winningAccountId;
        private String losingAccountId;


        public RelatedListGroup( Account_Merge_Related_Lists_MERC__c settings
                               , String label
                               , String name
                               , String winningAccountId
                               , String losingAccountId
                               , List<Schema.FieldSetMember> winningFields
                               , List<Schema.FieldSetMember> losingFields)
        {
            this.settings         = settings;
            this.sObjectLabel     = label;
            this.sObjectName      = name;
            this.winningAccountId = winningAccountId;
            this.losingAccountId  = losingAccountId;
            this.winningFields    = winningFields;
            this.losingFields     = losingFields;

            winningListSoql = createListSoql( winningFields, winningAccountId );
            losingListSoql  = createListSoql( losingFields,  losingAccountId );
        }

        private String createListSoql(List<Schema.FieldSetMember> fields, Id accountId)
        {
            return MERC_MergedAccountApex.buildSoqlString(fields, sObjectName, settings.Parent_Account_Field_MERC__c, accountId);
        }

        public List<SelectableSObject> winningList
        {
            get
            {
                if (winningList == null)
                {
                    winningList = queryAndWrapSObjects( winningListSoql );
                }
                return winningList;
            }
            private set;
        }

        public List<SelectableSObject> losingList
        {
            get
            {
                if (losingList == null)
                {
                    losingList = queryAndWrapSObjects( losingListSoql );
                }
                return losingList;
            }
            private set;
        }

        private List<SelectableSObject> queryAndWrapSObjects(String query)
        {
            List<SelectableSObject> results = new List<SelectableSObject>();
            for (SObject so : Database.query(query))
            {
                results.add(new SelectableSObject(so));
            }
            return results;
        }

        public void mergeSelectedRecords()
        {
            List<SObject> objectsToUpdate              = new List<SObject>();
            List<SelectableSObject> nonSelectedObjects = new List<SelectableSObject>();

            for (SelectableSObject so : losingList)
            {
                if (so.selected)
                {
                    /*----- reparent to the winning record parent id -----*/
                    so.detail.put(settings.Parent_Account_Field_MERC__c, winningAccountId);
                    objectsToUpdate.add(so.detail);
                }
                else
                {
                    nonSelectedObjects.add(so);
                }
            }

            try
            {
                update objectsToUpdate;
                /*----- update the losing list to only the non-reparented items -----*/
                losingList = nonSelectedObjects;
            }
            catch(System.DMLException ex)
            {
                ApexPages.addMessages(ex);
            }
        }

    }

    public class SelectableSObject
    {
        public SObject detail   { get; private set; }
        public Boolean selected { get; set; }

        public SelectableSObject(SObject theObject)
        {
            detail   = theObject;
            selected = false;
        }
    }

    private static String buildSoqlString(List<Schema.FieldSetMember> fields, String objectName, String parentField, String parentId)
    {
        String soql = 'SELECT Id';
        for (Schema.FieldSetMember field : fields)
        {
            if (field.getFieldPath() != 'Id')
            {
                soql += ', ' + field.getFieldPath();
            }
        }
        soql += ' FROM ' + objectName + ' WHERE ' + parentField + '=\'' + parentId+ '\'';
        System.debug('\n\n\nBuilt SOQL String is:\n' + soql +'\n\n\n');
        return soql;
    }
}