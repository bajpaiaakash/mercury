/****************************************************************************************************************************************** 
 * Class Name   : PANG_DataAssetList 
 * Description  : Class to display the List of Data Asset records
 * Created By   : Deloitte Consulting
 * 
 *****************************************************************************************************************************************/
Public with sharing class PANG_DataAssetList
{

    Public ApexPages.StandardSetController cDataAssetListCntlr
    {
        get;
        set;
    }
    Public string sField
    {
        get;
        set;
    }
    Public string sSearchWord
    {
        get;
        set;
    }
    Public string sOrder
    {
        get;
        set;
    }
    Public Map < String, Integer > mCategoyCount
    {
        get;
        set;
    }
    Public List < SelectOption > oDataAssetOptions
    {
        get;
        set;
    }
    Public string sOwnerType
    {
        get;
        set;
    }
    Public List < Integer > lPageNumbers
    {
        get;
        private set;
    }
    Public Integer iPageNumber
    {
        get;
        set;
    }
    Public Map < String, List < wDataAssetObject >> mDataAssetObjectStructure
    {
        get;
        set;
    }
    public Integer pNoLimit
    {
        get;
        set;
    }
    public Decimal dPageCount
    {
        get;
        set;
    }
    public string previousSField
    {
        get;
        set;
    }

    /* 
     * @Method Name                    :  getDataAssets
     * @Description                    :  Initialize cDataAssetListCntlr and return a list of records
     * @Return Type                    :  list of data asset records
     * @Parameters                     :  None
     */
    Public List < PANG_Data_Asset__c > getDataAssets()
    {
        return (List < PANG_Data_Asset__c > ) cDataAssetListCntlr.getRecords();
    }

    //Loading the constructor the page
    Public PANG_DataAssetList()
    {
        pNoLimit = 20;
        // Initialisation 
        sField = 'Name';
        previousSField = 'Name';
        sOrder = 'ASC NULLS FIRST';
        mDataAssetObjectStructure = new Map < String, List < wDataAssetObject >> ();

        // Methods for call
        DescribeObjectWithDetails();
        Query(sField + ' ' + sOrder);

    }

    /* 
     * @Method Name                    :  DescribeObjectWithDetails
     * @Description                    :  This method populates the filtering fields on the UI page 
     * @Return Type                    :  void
     * @Parameters                     :  None
     */
    Public Void DescribeObjectWithDetails()
    {
        List < wDataAssetObject > lPicklist = new List < wDataAssetObject > ();
        mCategoyCount = new Map < String, Integer > ();

        // Not using global describe which is taking longer time, hence hardcoding the field for describe
        for (Schema.Picklistentry oPicklistValues: PANG_Data_Asset__c.Relevant_Therapeutic_Area__c.getDescribe().getPicklistValues())
        {
            lPicklist.add(new wDataAssetObject(oPicklistValues.Value, false));
            mCategoyCount.put(oPicklistValues.Label, 0);
        }
        mDataAssetObjectStructure.put('Relevant_Therapeutic_Area__c', lPicklist);

        lPicklist = new List < wDataAssetObject > ();
        for (Schema.Picklistentry oPicklistValues: PANG_Data_Asset__c.Region__c.getDescribe().getPicklistValues())
        {
            lPicklist.add(new wDataAssetObject(oPicklistValues.Value, false));
            mCategoyCount.put(oPicklistValues.Label, 0);
        }
        mDataAssetObjectStructure.put('Region__c', lPicklist);

        lPicklist = new List < wDataAssetObject > ();
        for (Schema.Picklistentry oPicklistValues: PANG_Data_Asset__c.Type_of_Database__c.getDescribe().getPicklistValues())
        {
            lPicklist.add(new wDataAssetObject(oPicklistValues.Value, false));
            mCategoyCount.put(oPicklistValues.Label, 0);
        }
        mDataAssetObjectStructure.put('Type_of_Database__c', lPicklist);

        lPicklist = new List < wDataAssetObject > ();
        for (Schema.Picklistentry oPicklistValues: PANG_Data_Asset__c.Access_Method__c.getDescribe().getPicklistValues())
        {
            lPicklist.add(new wDataAssetObject(oPicklistValues.Value, false));
            mCategoyCount.put(oPicklistValues.Label, 0);
        }
        mDataAssetObjectStructure.put('Access_Method__c', lPicklist);

    }

    /* 
     * @Method Name                    :  FrameClause
     * @Description                    :  This method constructs the query clause if check boxes are checked on UI 
     * @Return Type                    :  string
     * @Parameters                     :  List of wDataAssetObject  
     */
    Public string FrameClause(List < wDataAssetObject > lWrapperForProcessing)
    {
        String sClause = '';

        for (wDataAssetObject oWrapper: lWrapperForProcessing)
        {
            if (oWrapper.isSelected)
            {
                sClause += '\'' + oWrapper.label + '\',';
            }
        }
        if (sClause != '')
        {
            sClause = '(' + sClause.removeend(',') + ')';
        }
        return sClause;
    }

    /* 
     * @Method Name                    :  CombineQuery
     * @Description                    :  This method combines all query clauses generated in FrameClause() method 
     * @Return Type                    :  string
     * @Parameters                     :  string and list of strings
     */
    public String CombineQuery(String sPrefix, List < String > sClauses)
    {
        List < String > sCombineClause = new List < String > ();
        for (String sClause: sClauses)
        {
            if (sClause != null && sClause != '')
                sCombineClause.add(sClause);
        }
        if (sCombineClause.size() > 0)
            return ' ' + sPrefix + ' ' + string.join(sCombineClause, ' AND ');
        return '';
    }

    /* 
     * @Method Name                    :  Query
     * @Description                    :  This method queries the data base and displays the results on UI 
     * @Return Type                    :  void
     * @Parameters                     :  String sOrder
     */
    Public void Query(String sOrder)
    {
        String sRegionClause = '';
        String sAccessMethodClause = '';
        String sTherapeuticAreaClause = '';
        String sTypeofDatabaseClause = '';
        String sRelationshipTypeClause = '';
        String sSearchClause = '';
        List < PANG_Data_Asset__c > lSearchWordProjects = new List < PANG_Data_Asset__c > ();

        sRegionClause = FrameClause(mDataAssetObjectStructure.get('Region__c'));
        if (sRegionClause != '')
        {
            sRegionClause = ' Region__c includes ' + sRegionClause;
        }

        sAccessMethodClause = FrameClause(mDataAssetObjectStructure.get('Access_Method__c'));
        if (sAccessMethodClause != '')
        {
            sAccessMethodClause = ' Access_Method__c IN ' + sAccessMethodClause;
        }

        sTherapeuticAreaClause = FrameClause(mDataAssetObjectStructure.get('Relevant_Therapeutic_Area__c'));
        if (sTherapeuticAreaClause != '')
        {
            sTherapeuticAreaClause = ' Relevant_Therapeutic_Area__c IN ' + sTherapeuticAreaClause;
        }

        sTypeofDatabaseClause = FrameClause(mDataAssetObjectStructure.get('Type_of_Database__c'));
        if (sTypeofDatabaseClause != '')
        {
            sTypeofDatabaseClause = ' Type_of_Database__c IN ' + sTypeofDatabaseClause;
        }

        If(sOwnerType != null && sOwnerType != '')
        {
            sRelationshipTypeClause = ' Relationship_Type__c  IN (\'' + string.escapeSingleQuotes(sOwnerType) + '\')';
        }

        if (sSearchWord != null && sSearchWord.trim() != '')
        {
            sSearchClause = ' Id IN : lSearchWordProjects';
        }

        if (sSearchWord != null && sSearchWord.trim() != '')
        {

            List < List < sObject >> lDynamicSearchResult = search.query('FIND \'' + string.escapeSingleQuotes(sSearchWord) + '\' IN ALL FIELDS RETURNING PANG_Data_Asset__c (Id,Name,Region__c,Access_Method__c,Relevant_Therapeutic_Area__c,Asset_Status__c,Type_of_Database__c ' + CombineQuery('WHERE', new List < String >
            {
                sRegionClause, sAccessMethodClause, sTherapeuticAreaClause, sTypeofDatabaseClause, sRelationshipTypeClause
            }) + ')');
            lSearchWordProjects = lDynamicSearchResult[0];
            cDataAssetListCntlr = new ApexPages.StandardSetController(lDynamicSearchResult[0]);
        }
        else
        {
            cDataAssetListCntlr = new ApexPages.StandardSetController(Database.getQueryLocator(
                'SELECT Name,Region__c,Access_Method__c,Relevant_Therapeutic_Area__c,Asset_Status__c,Type_of_Database__c FROM PANG_Data_Asset__c ' + CombineQuery('WHERE', new List < String >
                {
                    sRegionClause, sAccessMethodClause, sTherapeuticAreaClause, sTypeofDatabaseClause, sRelationshipTypeClause
                }) + ' ORDER BY ' + sOrder));
        }


        cDataAssetListCntlr.setPageSize(50);
        lPageNumbers = new List < Integer > ();
        dPageCount = 0;
        dPageCount = (decimal.valueof(cDataAssetListCntlr.getResultSize()) / decimal.valueof(cDataAssetListCntlr.getPageSize()));
        dPageCount = dPageCount.round(System.RoundingMode.UP);

        for (Integer i = 1; i <= dPageCount; i++)
        {
            lPageNumbers.add(i);
            if (lPageNumbers.size() == pNoLimit)
                break;
        }

        for (String mCount: mCategoyCount.keyset())
        {
            mCategoyCount.put(mCount, 0);
        }
        for (AggregateResult ar: database.query('SELECT count(Id),Relevant_Therapeutic_Area__c FROM PANG_Data_Asset__c where Relevant_Therapeutic_Area__c!=null ' + CombineQuery('AND', new List < String >
            {
                sRegionClause, sAccessMethodClause, sTypeofDatabaseClause, sRelationshipTypeClause, sSearchClause
            }) + ' Group BY Relevant_Therapeutic_Area__c'))
        {
            mCategoyCount.put((String) ar.get('Relevant_Therapeutic_Area__c'), (Integer) ar.get('expr0'));
        }

        for (AggregateResult ar: database.query('SELECT count(Id),Type_of_Database__c FROM PANG_Data_Asset__c where Type_of_Database__c!=null ' + CombineQuery('AND', new List < String >
            {
                sRegionClause, sAccessMethodClause, sTherapeuticAreaClause, sRelationshipTypeClause, sSearchClause
            }) + ' Group BY Type_of_Database__c'))
        {
            mCategoyCount.put((String) ar.get('Type_of_Database__c'), (Integer) ar.get('expr0'));
        }

        for (AggregateResult ar: database.query('SELECT count(Id),Access_Method__c FROM PANG_Data_Asset__c where Access_Method__c!=null ' + CombineQuery('AND', new List < String >
            {
                sRegionClause, sTherapeuticAreaClause, sTypeofDatabaseClause, sRelationshipTypeClause, sSearchClause
            }) + ' Group BY Access_Method__c'))
        {
            mCategoyCount.put((String) ar.get('Access_Method__c'), (Integer) ar.get('expr0'));
        }

        //Initialise dropdown of OwnerType
        oDataAssetOptions = new List < SelectOption > ();
        oDataAssetOptions.add(new SelectOption('', 'All Owner Types'));
        for (AggregateResult ar: database.query('SELECT count(Id),Relationship_Type__c FROM PANG_Data_Asset__c where Relationship_Type__c!=null ' + CombineQuery('AND', new List < String >
            {
                sRegionClause, sAccessMethodClause, sTherapeuticAreaClause, sTypeofDatabaseClause, sSearchClause
            }) + ' Group BY Relationship_Type__c '))
        {
            oDataAssetOptions.add(new SelectOption((String) ar.get('Relationship_Type__c'), (String) ar.get('Relationship_Type__c')));
        }
    }

    /*
     * Method name  : sort
     * Description  : Sorting of the results displayed by clicking on the column link
     * Return Type  : void
     * @Parameters  : None
     */

    Public void sort()
    {

        if (sField == previousSField)
        {
            if (sOrder.contains('ASC'))
            {
                sOrder = sOrder.replace('ASC', 'DESC');
                sOrder = sOrder.replace('FIRST', 'LAST');
            }
            else
            {
                sorder = sorder.replace('DESC', 'ASC');
                sOrder = sOrder.replace('LAST', 'FIRST');
            }
        }
        else
        {
            sOrder = 'ASC NULLS FIRST';
            previoussField = sField;
        }

        Query(sField + ' ' + sOrder);
    }

    /* 
     * @Method Name                    :  FetchDataForCriteria
     * @Description                    :  This method is called upon anny action on UI to query the data base
     * @Return Type                    :  void
     * @Parameters                     :  None
     */
    public void FetchDataForCriteria()
    {
        Query(sField + ' ' + sOrder);
    }

    /*
     * Method name  : GoToPageNumber
     * Description  : This method takes the user to results of that particular page on upon clicking any number on pagination panel on UI
     * Return Type  : void
     * @Parameters  : None
     */
    Public void GoToPageNumber()
    {
        cDataAssetListCntlr.setPagenumber(iPageNumber);
    }

    /* 
     * @Method Name                    :  NextPageSeries
     * @Description                    :  This method takes the user to next set of pages on pagination panel on UI
     * @Return Type                    :  void
     * @Parameters                     :  None
     */
    Public void NextPageSeries()
    {

        Integer currentLimit = lPageNumbers[lPageNumbers.size() - 1];
        lPageNumbers = new List < Integer > ();
        for (Integer i = 1; i <= pNoLimit; i++)
        {
            if (currentLimit + i <= dPageCount)
            {
                lPageNumbers.add(currentLimit + i);
            }
        }
    }

    /* 
     * @Method Name                    :  PreviousPageSeries
     * @Description                    :  This method takes the user to previous set of pages on pagination panel on UI
     * @Return Type                    :  void
     * @Parameters                     :  None
     */
    Public void PreviousPageSeries()
    {

        Integer currentLimit = lPageNumbers[0] - pNoLimit - 1;

        lPageNumbers = new List < Integer > ();
        for (Integer i = 1; i <= pNoLimit; i++)
        {
            lPageNumbers.add(currentLimit + i);
        }
    }

    /*
     * Class name   : wDataAssetObject
     * Description  : This is a wrapper class which holds the picklist value name and checkbox to filter out results on Data Asset list Page
     */

    Public class wDataAssetObject
    {
        Public Boolean isSelected
        {
            get;
            set;
        }
        Public string label
        {
            get;
            set;
        }
        public wDataAssetObject(String l, Boolean isC)
        {
            label = l;
            isSelected = isC;
        }
    }

}