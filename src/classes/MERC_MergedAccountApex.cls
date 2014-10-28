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
    @TestVisible private String    losingAccountId;
    private List<RelatedListGroup> relatedLists;
    private static Map<String, Account_Merge_Related_Lists_MERC__c> relatedListSettings = Account_Merge_Related_Lists_MERC__c.getAll();

    public MERC_MergedAccountApex(String winnerId, String loserId)
    {
        losingAccountId = loserId;

        /*----- Build the query string for the winning account from the field set -----*/
        Set<String> acctFieldSet = new Set<String>{'Id', 'Name', 'Cust_Id_GLBL__c'};
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
        soqlQuery += ' FROM Account WHERE Cust_Id_GLBL__c = \'' + winnerId +'\' LIMIT 1';

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

            /*----- Loop over the custom settings to determine the Describes we need to perform-----*/
            Set<String> objectsForSchemaSet = new Set<String>();
            Map<String, List<Account_Merge_Related_Lists_MERC__c>> objectToRelatedListsMap =  new Map<String, List<Account_Merge_Related_Lists_MERC__c>>();
            Map<Decimal, List<Account_Merge_Related_Lists_MERC__c>> relatedListsOrder = new Map<Decimal, List<Account_Merge_Related_Lists_MERC__c>>();

            for (Account_Merge_Related_Lists_MERC__c rl : relatedListSettings.values())
            {
                objectsForSchemaSet.add(rl.Related_Object_API_Name__c);
                /*----- Add the related list name to a map of order to name for future sorting -----*/
                if (relatedListsOrder.containsKey(rl.Order_MERC__c))
                {
                    relatedListsOrder.get(rl.Order_MERC__c).add(rl);
                }
                else
                {
                    relatedListsOrder.put(rl.Order_MERC__c, new List<Account_Merge_Related_Lists_MERC__c>{ rl });
                }

                /*----- add the custom settings to a map of Object name to list of settings.  -----*/
                if (objectToRelatedListsMap.containsKey(rl.Related_Object_API_Name__c))
                {
                    objectToRelatedListsMap.get(rl.Related_Object_API_Name__c).add(rl);
                }
                else
                {
                    objectToRelatedListsMap.put(rl.Related_Object_API_Name__c, new List<Account_Merge_Related_Lists_MERC__c>{rl});
                }
            }

            /*----- get the order values into a list and sort them -----*/
            List<Decimal> orderValues = new List<Decimal>();
            orderValues.addAll(relatedListsOrder.keySet());
            orderValues.sort();

            List<Account_Merge_Related_Lists_MERC__c> sortedRelatedLists = new List<Account_Merge_Related_Lists_MERC__c>();
            for (Decimal order : orderValues)
            {
                sortedRelatedLists.addAll(relatedListsOrder.get(order));
            }

            /*----- get the describe objects need and add them to a map from object api name to describe -----*/
            List<String> objectsForSchemaList = new List<String>();
            objectsForSchemaList.addAll(objectsForSchemaSet);

            /*----- get a list of describe objects -----*/
            Map<String, Schema.DescribeSObjectResult> descResults = new Map<String, Schema.DescribeSObjectResult>();
            for (Schema.DescribeSObjectResult dso : Schema.describeSObjects(objectsForSchemaList))
            {
                descResults.put(dso.getName(), dso);
            }

            /*----- loop over the sorted related lists and create the RelatedListGroup objects for each one -----*/
            for (Account_Merge_Related_Lists_MERC__c settings : sortedRelatedLists)
            {
                if (descResults.containsKey(settings.Related_Object_API_Name__c))
                {
                    Schema.DescribeSObjectResult dr = descResults.get(settings.Related_Object_API_Name__c);
                    RelatedListGroup thisRL = new RelatedListGroup( settings
                                                                  , dr.getLabel()
                                                                  , dr.getName()
                                                                  , winningAccount.Cust_Id_GLBL__c
                                                                  , losingAccountId
                                                                  , dr.fieldSets.getMap().get(settings.Winning_Acct_Related_List_Field_Set_MERC__c).getFields()
                                                                  , dr.fieldSets.getMap().get(settings.Losing_Acct_Related_List_Field_Set_MERC__c).getFields()
                    );
                    relatedLists.add(thisRL);
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
        public String                              sObjectClass  { get; private set; }
        public Account_Merge_Related_Lists_MERC__c settings      { get; private set; }

        private String sObjectName;
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
            this.sObjectClass     = settings.Name.replaceAll(' ','-');
            this.winningAccountId = winningAccountId;
            this.losingAccountId  = losingAccountId;
            this.winningFields    = winningFields;
            this.losingFields     = losingFields;

            winningListSoql = createListSoql( winningFields, winningAccountId, losingAccountId, false );
            losingListSoql  = createListSoql( losingFields,  winningAccountId, losingAccountId, true );
        }

        private String createListSoql(List<Schema.FieldSetMember> fields, String winningAccountId, String losingAccountId, Boolean isWinningSoql)
        {
            return MERC_MergedAccountApex.buildSoqlString(fields, sObjectName, settings.Path_to_Cust_Id_MERC__c, winningAccountId, losingAccountId, isWinningSoql);
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

        /*----- loop over the losing list, clear out the Prior_Parent_Id_GLBL__c so that the account
                is no longer associated with the losing record. -----*/
        public void mergeSelectedRecords()
        {
            List<SObject> objectsToUpdate = new List<SObject>();

            for (SelectableSObject so : losingList)
            {
                if (so.selected)
                {
                    /*----- reparent to the winning record parent id -----*/
                    so.detail.put('Prior_Parent_Id_GLBL__c', '');
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

    private static String buildSoqlString(List<Schema.FieldSetMember> fields, String objectName, String parentField, String parentId, String losingId, Boolean isWinningSoql)
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
        soql += ' AND Prior_Parent_Id_GLBL__c' + (isWinningSoql ? '=' : '!=') + '\'' + losingId + '\'';
        System.debug('\n\n\nBuilt SOQL String is:\n' + soql +'\n\n\n');
        return soql;
    }
}