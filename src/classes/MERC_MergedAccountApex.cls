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
    @TestVisible private Id      losingAccountId;
    private List<RelatedListGroup> relatedLists;
    private static Map<String, Account_Merge_Related_Lists_MERC__c> relatedListSettings = Account_Merge_Related_Lists_MERC__c.getAll();

    public MERC_MergedAccountApex(Id winnerId, Id loserId)
    {
        losingAccountId = loserId;

        /*----- Build the query string for the winning account from the field set -----*/
        Set<String> acctFieldSet = new Set<String>{'Id', 'Name'};
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

    public Account getAccount()
    {
        return winningAccount;
    }

    public List<RelatedListGroup> getAllRelatedLists()
    {
        if (relatedLists == null)
        {
            relatedLists = new List<RelatedListGroup>();

            /*----- Loop over the custom settings to determine the Describes we need to perform and
                    add the custom settings to a map of Object name to list of settings. -----*/
            Set<String> objectsForSchemaSet = new Set<String>();
            Map<String, List<Account_Merge_Related_Lists_MERC__c>> objectToRelatedListsMap =  new Map<String, List<Account_Merge_Related_Lists_MERC__c>>();
            for (Account_Merge_Related_Lists_MERC__c rl : relatedListSettings.values())
            {
                objectsForSchemaSet.add(rl.Related_Object_API_Name__c);
                if (objectToRelatedListsMap.containsKey(rl.Related_Object_API_Name__c))
                {
                    objectToRelatedListsMap.get(rl.Related_Object_API_Name__c).add(rl);
                }
                else
                {
                    objectToRelatedListsMap.put(rl.Related_Object_API_Name__c, new List<Account_Merge_Related_Lists_MERC__c>{rl});
                }
            }
            List<String> objectsForSchemaList = new List<String>();
            objectsForSchemaList.addAll(objectsForSchemaSet);

            /*----- get a list of describe objects -----*/
            List<Schema.DescribeSObjectResult> descResults = Schema.describeSObjects(objectsForSchemaList);

            /*----- loop over the describe objects and create the RelatedListGroup objects for each one -----*/
            for(Schema.DescribeSObjectResult dr : descResults)
            {
                if (objectToRelatedListsMap.containsKey(dr.getName()))
                {
                    for (Account_Merge_Related_Lists_MERC__c settings : objectToRelatedListsMap.get(dr.getName()))
                    {
                        System.debug(settings.Winning_Acct_Related_List_Field_Set_MERC__c);
                        System.debug(dr.fieldSets.getMap().get(settings.Winning_Acct_Related_List_Field_Set_MERC__c));
                        System.debug(dr.fieldSets.getMap().get(settings.Winning_Acct_Related_List_Field_Set_MERC__c).getFields());
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
            }
        }
        return relatedLists;
    }

    /*----- when a losing record is marked complete we can destroy all of the data that is not needed -----*/
    public void destroyLosingRecords()
    {
        /*----- loop over each of the related list groups and unwrap each sObject
                from the losingList and add it to a list of sObjects -----*/
        List<SObject> sObjectsToDelete = new List<SObject>();
        for (RelatedListGroup rl : getAllRelatedLists())
        {
            for (SelectableSObject so : rl.losingList)
            {
                sObjectsToDelete.add(so.detail);
            }
        }
        try
        {
            delete sObjectsToDelete;
            /*----- once the objects are successfully deleted, clear each losing list -----*/
            for (RelatedListGroup rl : getAllRelatedLists())
            {
                rl.losingList = null;
            }
        }
        catch (System.Exception ex)
        {
            System.debug('\n\n\nException: ' + ex + '\n\n\n');
            ApexPages.addMessages(ex);
        }


    }

    public class RelatedListGroup
    {
        public List<Schema.FieldSetMember>         winningFields { get; private set; }
        public List<Schema.FieldSetMember>         losingFields  { get; private set; }
        public String                              sObjectLabel  { get; private set; }
        public String                              sObjectName   { get; private set; }
        public Account_Merge_Related_Lists_MERC__c settings      { get; private set; }

        private String winningListSoql;
        private String losingListSoql;
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

        /*----- lazy load the winning and losing lists as singletons.
                This allows us to refresh each list by setting it to null -----*/
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

        /*----- query for sObject using the passed in soql query string and wrap the results in a SelectableSObject -----*/
        private List<SelectableSObject> queryAndWrapSObjects(String query)
        {
            List<SelectableSObject> results = new List<SelectableSObject>();
            for (SObject so : Database.query(query))
            {
                results.add(new SelectableSObject(so));
            }
            return results;
        }

        /*----- loop over the winning records and add the selected items to a list.
               delete that list and null the winningList to force a refresh -----*/
        public void deleteSelectedWinningRecords()
        {
            List<SObject> objectsToDelete = new List<SObject>();
            for (SelectableSObject so : winningList)
            {
                if (so.selected)
                {
                    objectsToDelete.add(so.detail);
                }
            }
            try
            {
                delete objectsToDelete;
                /*----- force a refresh of the winning list -----*/
                winningList = null;
            }
            catch(System.Exception ex)
            {
                ApexPages.addMessages(ex);
            }
        }

        /*----- loop over the losing list, set the parent account to be the winning account
                and then update that list. null out the winning and losing lists to force a refresh -----*/
        public void mergeSelectedRecords()
        {
            List<SObject> objectsToUpdate = new List<SObject>();

            for (SelectableSObject so : losingList)
            {
                if (so.selected)
                {
                    /*----- reparent to the winning record parent id -----*/
                    so.detail.put(settings.Parent_Account_Field_MERC__c, winningAccountId);
                    objectsToUpdate.add(so.detail);
                }
            }

            try
            {
                update objectsToUpdate;
                /*----- force a refresh of the lists -----*/
                winningList = null;
                losingList = null;

            }
            catch(System.Exception ex)
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