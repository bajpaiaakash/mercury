/****************************************************************************************************************************************** 
 * Class Name   : PANG_RequestList
 * Description  : List page with filters for Request records
 * Created By   : Deloitte Consulting
 * 
 *****************************************************************************************************************************************/
Public with sharing class PANG_RequestList
{

    Public ApexPages.StandardSetController cRequestListCntlr
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
    Public Map < String, List < wFilterWrapper >> mRequestObjectStructure
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

    //Loading the constructor the page    
    Public PANG_RequestList()
    {
        pNoLimit = 20;
        // Initialisation 
        sField = 'Name';
        previousSField = 'Name';
        sOrder = 'ASC NULLS FIRST';
        mRequestObjectStructure = new Map < String, List < wFilterWrapper >> ();

        // Methods for call
        DescribeObjectWithDetails();
        Query(sField + ' ' + sOrder);
    }

    /* 
     * @Method Name                    :  getRequests
     * @Description                    :  Initialize cRequestListCntlr and return a list of records
     * @Return Type                    :  List of Requests 
     * @Parameters                     :  None
     */

    Public List < PANG_Request__c > getRequests()
    {
        return (List < PANG_Request__c > ) cRequestListCntlr.getRecords();
    }

    /* 
     * @Method Name                    :  DescribeObjectWithDetails
     * @Description                    :  Method to get and populate therapeutic area, request type, status and region picklist filters on UI
     * @Return Type                    :  void 
     * @Parameters                     :  None
     */

    Public Void DescribeObjectWithDetails()
    {
        List < wFilterWrapper > lPicklist = new List < wFilterWrapper > ();
        mCategoyCount = new Map < String, Integer > ();

        // Not using global describe which is taking longer time, hence hardcoding the field for describe
        for (Schema.Picklistentry oPicklistValues: PANG_Request__c.Therapeutic_Area_Primary__c.getDescribe().getPicklistValues())
        {
            lPicklist.add(new wFilterWrapper(oPicklistValues.Value, false));
            mCategoyCount.put(oPicklistValues.Label, 0);
        }
        mRequestObjectStructure.put('Therapeutic_Area_Primary__c', lPicklist);

        //Manually adding record type names to change the order of appearance on UI        
        lPicklist = new List < wFilterWrapper > ();
        lPicklist.add(new wFilterWrapper('Data Mart Project', false));
        lPicklist.add(new wFilterWrapper('EXPERT Review', false));
        lPicklist.add(new wFilterWrapper('EXPERT or ACT Consultation', false));
        lPicklist.add(new wFilterWrapper('EXPERT Exception', false));
        lPicklist.add(new wFilterWrapper('RWE Data Sourcing', false));
        lPicklist.add(new wFilterWrapper('RWE Partnership Exploration', false));
        lPicklist.add(new wFilterWrapper('RWE Strategic Consultation', false));
        mRequestObjectStructure.put('RecordTypeDevName', lPicklist);

        lPicklist = new List < wFilterWrapper > ();
        for (Schema.Picklistentry oPicklistValues: PANG_Request__c.Region__c.getDescribe().getPicklistValues())
        {
            lPicklist.add(new wFilterWrapper(oPicklistValues.Value, false));
            mCategoyCount.put(oPicklistValues.Label, 0);
        }
        mRequestObjectStructure.put('Region__c', lPicklist);

        lPicklist = new List < wFilterWrapper > ();
        for (Schema.Picklistentry oPicklistValues: PANG_Request__c.Request_Status__c.getDescribe().getPicklistValues())
        {
            if (oPicklistValues.Value != 'Deleted')
            {
                lPicklist.add(new wFilterWrapper(oPicklistValues.Value, false));
                mCategoyCount.put(oPicklistValues.Label, 0);
            }
        }
        mRequestObjectStructure.put('Request_Status__c', lPicklist);
    }

    /* 
     * @Method Name                    :  FrameClause
     * @Description                    :  This method constructs the query clause if check boxes are checked for filtering on UI 
     * @Return Type                    :  string 
     * @Parameters                     :  list of wFilterWrapper 
     */

    Public string FrameClause(List < wFilterWrapper > lWrapperForProcessing)
    {
        String sClause = '';
        for (wFilterWrapper oWrapper: lWrapperForProcessing)
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
     * @Description                    :  This method queries the data base and fetches the results
     * @Return Type                    :  void
     * @Parameters                     :  string
     */

    Public void Query(String sOrder)
    {
        String sRegionClause = '';
        String sTherapeuticAreaClause = '';
        String sStatusClause = '';
        String sRequestTypeClause = '';
        String sSearchClause = '';
        List < PANG_Request__c > lSearchWordProjects = new List < PANG_Request__c > ();

        sRegionClause = FrameClause(mRequestObjectStructure.get('Region__c'));
        if (sRegionClause != '')
        {
            sRegionClause = ' Region__c includes ' + sRegionClause;
        }

        sTherapeuticAreaClause = FrameClause(mRequestObjectStructure.get('Therapeutic_Area_Primary__c'));
        if (sTherapeuticAreaClause != '')
        {
            sTherapeuticAreaClause = ' Therapeutic_Area_Primary__c IN ' + sTherapeuticAreaClause;
        }

        sRequestTypeClause = FrameClause(mRequestObjectStructure.get('RecordTypeDevName'));
        if (sRequestTypeClause != '')
        {
            sRequestTypeClause = ' recordtype.name IN ' + sRequestTypeClause;
        }

        sStatusClause = FrameClause(mRequestObjectStructure.get('Request_Status__c'));
        if (sStatusClause != '')
        {
            sStatusClause = ' Request_Status__c IN ' + sStatusClause;
        }

        if (sSearchWord != null && sSearchWord.trim() != '')
        {
            sSearchClause = ' Id IN : lSearchWordProjects';
        }

        if (sSearchWord != null && sSearchWord.trim() != '')
        {
            List < List < sObject >> lDynamicSearchResult = search.query('FIND \'' + string.escapeSingleQuotes(sSearchWord) + '\' IN ALL FIELDS RETURNING PANG_Request__c  (id,Name,Region__c,Requestor__r.name,Therapeutic_Area_Primary__c,Proposed_Due_Date__c,Request_Status__c,RecordType.Name ' + CombineQuery('WHERE', new List < String >
            {
                sRegionClause, sTherapeuticAreaClause, sStatusClause, sRequestTypeClause
            }) + ')');
            lSearchWordProjects = lDynamicSearchResult[0];
            cRequestListCntlr = new ApexPages.StandardSetController(lDynamicSearchResult[0]);
        }
        else
        {
            cRequestListCntlr = new ApexPages.StandardSetController(Database.getQueryLocator(
                'SELECT a.Name,a.Region__c,a.Requestor__r.name,a.Therapeutic_Area_Primary__c,a.Proposed_Due_Date__c,a.Request_Status__c,a.RecordType.Name  FROM PANG_Request__c  a ' + CombineQuery('WHERE', new List < String >
                {
                    sRegionClause, sTherapeuticAreaClause, sStatusClause, sRequestTypeClause
                }) + ' ORDER BY ' + sOrder));
        }

        cRequestListCntlr.setPageSize(50);
        lPageNumbers = new List < Integer > ();
        dPageCount = 0;
        dPageCount = (decimal.valueof(cRequestListCntlr.getResultSize()) / decimal.valueof(cRequestListCntlr.getPageSize()));
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
        for (AggregateResult ar: database.query('SELECT count(Id),Therapeutic_Area_Primary__c FROM PANG_Request__c where Therapeutic_Area_Primary__c!=null ' + CombineQuery('AND', new List < String >
            {
                sRegionClause, sStatusClause, sSearchClause, sRequestTypeClause  
            }) + ' Group BY Therapeutic_Area_Primary__c'))
        {
            mCategoyCount.put((String) ar.get('Therapeutic_Area_Primary__c'), (Integer) ar.get('expr0'));
        }

        for (AggregateResult ar: database.query('SELECT count(Id),Request_Status__c FROM PANG_Request__c where Request_Status__c!=null ' + CombineQuery('AND', new List < String >
            {
                sRegionClause, sTherapeuticAreaClause, sSearchClause, sRequestTypeClause 
            }) + ' Group BY Request_Status__c'))
        {
            mCategoyCount.put((String) ar.get('Request_Status__c'), (Integer) ar.get('expr0'));
        }

        for (AggregateResult ar: database.query('SELECT count(Id),recordtype.name FROM PANG_Request__c where recordtype.name !=NULL ' + CombineQuery('AND', new List < String >
            {
                sRegionClause, sTherapeuticAreaClause, sSearchClause, sStatusClause
            }) + ' Group BY recordtype.name'))
        {
            mCategoyCount.put((String) ar.get('name'), (Integer) ar.get('expr0'));

        }
    }

    /* 
     * @Method Name                    :  sort
     * @Description                    :  This method sorts the results upon clicking sortable field names on results header on UI
     * @Return Type                    :  void
     * @Parameters                     :  None
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
     * @Method Name                    :  GoToPageNumber
     * @Description                    :  This method will take user to the results on that page upon clicking any page number on pagination panel
     * @Return Type                    :  void
     * @Parameters                     :  None
     */

    Public void GoToPageNumber()
    {
        cRequestListCntlr.setPagenumber(iPageNumber);
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
     * @Class Name                     :  wFilterWrapper 
     * @Description                    :  This is a wrapper class which holds the picklist value name and checkbox to filter out results on Requestlist Page
     */

    Public class wFilterWrapper
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
        public wFilterWrapper(String l, Boolean isC)
        {
            label = l;
            isSelected = isC;
        }
    }

}