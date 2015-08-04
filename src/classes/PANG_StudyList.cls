/****************************************************************************************************************************************** 
* Class Name   : PANG_StudyList 
* Description  : Class to get the List of Study records
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
Public with sharing class PANG_StudyList 
{

    Public ApexPages.StandardSetController cProjectListCntlr 
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
    Public Map < String, List < wStudyObject >> mStudyObjectStructure 
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
     * @Method Name                    :  getStudies
     * @Description                    :  Initialize cProjectListCntlr and return a list of records
     * @Return Type                    :  list of Study records
     * @Parameters                     :  None
     */
    Public List < PANG_Project__c > getStudies() {
        return (List < PANG_Project__c > ) cProjectListCntlr.getRecords();
    }

    //Loading the Constructor for the Study List page     
    Public PANG_StudyList() 
    {
            pNoLimit = 20;
            // Initialisation 
            sField = 'Name';
            previousSField = 'Name';
            sOrder = 'ASC NULLS FIRST';
            mStudyObjectStructure = new Map < String, List < wStudyObject >> ();

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
        List < wStudyObject > lPicklist = new List < wStudyObject > ();
        mCategoyCount = new Map < String, Integer > ();

        // Not using global describe which is taking longer time, hence hardcoding the field for describe
        for (Schema.Picklistentry oPicklistValues: PANG_Project__c.Therapeutic_Area_Primary__c.getDescribe().getPicklistValues()) 
        {
            lPicklist.add(new wStudyObject(oPicklistValues.Value, false));
            mCategoyCount.put(oPicklistValues.Label, 0);
        }
        mStudyObjectStructure.put('Therapeutic_Area_Primary__c', lPicklist);

        lPicklist = new List < wStudyObject > ();
        for (Schema.Picklistentry oPicklistValues: PANG_Project__c.Region__c.getDescribe().getPicklistValues()) 
        {
            lPicklist.add(new wStudyObject(oPicklistValues.Value, false));
            mCategoyCount.put(oPicklistValues.Label, 0);
        }
        mStudyObjectStructure.put('Region__c', lPicklist);

        lPicklist = new List < wStudyObject > ();
        for (Schema.Picklistentry oPicklistValues: PANG_Project__c.Project_Status__c.getDescribe().getPicklistValues()) 
        {
            lPicklist.add(new wStudyObject(oPicklistValues.Value, false));
            mCategoyCount.put(oPicklistValues.Label, 0);
        }
        mStudyObjectStructure.put('Project_Status__c', lPicklist);

    }

    /* 
    * @Method Name                    :  FrameClause
    * @Description                    :  This method constructs the query clause if check boxes are checked on UI 
    * @Return Type                    :  string
    * @Parameters                     :  List of wStudyObject
    */
    Public string FrameClause(List < wStudyObject > lWrapperForProcessing) 
    {
        String sClause = '';

        for (wStudyObject oWrapper: lWrapperForProcessing)
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
        String sTherapeuticAreaClause = '';
        String sStatusClause = '';
        String sSearchClause = '';
        List < PANG_Project__c > lSearchWordProjects = new List < PANG_Project__c > ();

        sRegionClause = FrameClause(mStudyObjectStructure.get('Region__c'));
        if (sRegionClause != '') 
        {
            sRegionClause = ' Region__c includes ' + sRegionClause;
        }

        sTherapeuticAreaClause = FrameClause(mStudyObjectStructure.get('Therapeutic_Area_Primary__c'));
        if (sTherapeuticAreaClause != '') 
        {
            sTherapeuticAreaClause = ' Therapeutic_Area_Primary__c IN ' + sTherapeuticAreaClause;
        }

        sStatusClause = FrameClause(mStudyObjectStructure.get('Project_Status__c'));
        if (sStatusClause != '') 
        {
            sStatusClause = ' Project_Status__c IN ' + sStatusClause;
        }

        if (sSearchWord != null && sSearchWord.trim() != '') 
        {
            sSearchClause = ' Id IN : lSearchWordProjects';
        }

        if (sSearchWord != null && sSearchWord.trim() != '') 
        {
            List < List < sObject >> lDynamicSearchResult = search.query('FIND \'' + String.escapeSingleQuotes(sSearchWord) + '\' IN ALL FIELDS RETURNING PANG_Project__c (Id,Name,TPO__c,Functional_Area__c, Project_ID__c, Project_Lead_Owner__r.name,Project_Status__c, Region__c, Therapeutic_Area_Primary__c,TPO_Activity__c ' + CombineQuery('WHERE', new List < String > {
                sRegionClause, sTherapeuticAreaClause, sStatusClause
            }) + ')');
            lSearchWordProjects = lDynamicSearchResult[0];
            cProjectListCntlr = new ApexPages.StandardSetController(lDynamicSearchResult[0]);
        } 
        else 
        {
            cProjectListCntlr = new ApexPages.StandardSetController(Database.getQueryLocator(
                'SELECT Name,Project_ID__c,TPO__c,Project_Lead_Owner__r.name,Region__c,TPO_Activity__c,Functional_Area__c,Project_Status__c FROM PANG_Project__c ' + CombineQuery('WHERE', new List < String > {
                    sRegionClause, sTherapeuticAreaClause, sStatusClause
                }) + ' ORDER BY ' + sOrder));
        }

        cProjectListCntlr.setPageSize(50);
        lPageNumbers = new List < Integer > ();
        dPageCount = 0;
        dPageCount = (decimal.valueof(cProjectListCntlr.getResultSize()) / decimal.valueof(cProjectListCntlr.getPageSize()));
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
        for (AggregateResult ar: database.query('SELECT count(Id),Therapeutic_Area_Primary__c FROM PANG_Project__c where Therapeutic_Area_Primary__c!=null ' + CombineQuery('AND', new List < String > 
            {
                sRegionClause, sStatusClause, sSearchClause
            }) + ' Group BY Therapeutic_Area_Primary__c')) 
            {
            mCategoyCount.put((String) ar.get('Therapeutic_Area_Primary__c'), (Integer) ar.get('expr0'));
            }

        for (AggregateResult ar: database.query('SELECT count(Id),Project_Status__c FROM PANG_Project__c where Project_Status__c!=null ' + CombineQuery('AND', new List < String > 
            {
                sRegionClause, sTherapeuticAreaClause, sSearchClause
            }) + ' Group BY Project_Status__c')) 
            {
            mCategoyCount.put((String) ar.get('Project_Status__c'), (Integer) ar.get('expr0'));
            }

        for (AggregateResult ar: database.query('SELECT count(Id),TPO_Activity__c FROM PANG_Project__c where TPO_Activity__c!=null ' + CombineQuery('AND', new List < String > 
            {
                sRegionClause, sTherapeuticAreaClause, sStatusClause, sSearchClause
            }) + ' Group BY TPO_Activity__c')) 
            {
            mCategoyCount.put((String) ar.get('TPO_Activity__c'), (Integer) ar.get('expr0'));
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
        cProjectListCntlr.setPagenumber(iPageNumber);
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
     * Class name   : wStudyObject
     * Description  : This is a wrapper class which holds the picklist value name and checkbox to filter out results on Studylist Page
     */

    Public class wStudyObject 
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
        public wStudyObject(String l, Boolean isC) 
        {
            label = l;
            isSelected = isC;
        }
    }
}