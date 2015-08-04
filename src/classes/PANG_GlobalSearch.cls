/****************************************************************************************************************************************** 
* Class Name   : PANG_GlobalSearch
* Description  : Class for Global Search on the UI
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
Public with sharing class PANG_GlobalSearch {

    public Boolean isStudies {
        get;
        set;
    }
    public Boolean isDataAssets {
        get;
        set;
    }
    public Boolean isPartnerships {
        get;
        set;
    }
    public Boolean isRequests {
        get;
        set;
    }
    public string sLocalSearch {
        get;
        set;
    }
    public Map < string, Boolean > mTimeFrameFilter {
        get;
        set;
    }


    Public List < PANG_Project__c > lProjects {
        get;
        set;
    }
    Public List < PANG_Request__c > lPartnerShips {
        get;
        set;
    }
    Public List < PANG_Request__c > lRequests {
        get;
        set;
    }
    Public List < PANG_Data_Asset__c > lDataAsset {
        get;
        set;
    }

    public map < string, string > mURLparams = new map < string, string > ();
    public Map < String, Integer > mCategoyCount;
    Public Map < String, List < wStudyObject >> mStudyObjectStructure {
        get;
        set;
    }


    //Constructor of the Page
    Public PANG_GlobalSearch() {
        mURLparams = ApexPages.currentPage().getParameters();
        mStudyObjectStructure = new Map < String, List < wStudyObject >> ();

        //Populating picklist filters
        mStudyObjectStructure.put('TherapeuticArea', populateTherapeuticArea());
        mStudyObjectStructure.put('Region__c', populateRegion());
        mTimeFrameFilter = populateTimeFrame();

        //setting the boolean attributes to choose objects for search
        If(mURLparams.containsKey('Studies')) {
            isStudies = true;
        } else {
            isStudies = false;
        }
        If(mURLparams.containsKey('DataAssets')) {
            isDataAssets = true;
        } else {
            isDataAssets = false;
        }
        If(mURLparams.containsKey('Partnerships')) {
            isPartnerships = true;
        } else {
            isPartnerships = false;
        }
        If(mURLparams.containsKey('Requests')) {
            isRequests = true;
        } else {
            isRequests = false;
        }

        Query();
    }

    /* 
    * @Method Name                    :  populateTherapeuticArea
    * @Description                    :  Method to populate therapeutic area picklist filter
    * @Return Type                    :  List
    * @Parameters                     :  None
    */  
    Public list < wStudyObject > populateTherapeuticArea() {

        List < wStudyObject > lPicklist = new List < wStudyObject > ();
        //Hardcoding the values as the API name is different for therapeutic area on different objects      
        lPicklist.add(new wStudyObject('Cardiovascular', false));
        lPicklist.add(new wStudyObject('Alzheimer’s & NDD', false));
        lPicklist.add(new wStudyObject('Autoimmune', false));
        lPicklist.add(new wStudyObject('Bone, Muscle, Joint', false));
        lPicklist.add(new wStudyObject('Urology and Men’s Health', false));
        lPicklist.add(new wStudyObject('Diabetes', false));
        lPicklist.add(new wStudyObject('Oncology', false));

        return lPicklist;
    }

    /* 
    * @Method Name                    :  populateRegion
    * @Description                    :  Method to populate Region picklist filter
    * @Return Type                    :  List
    * @Parameters                     :  None
    
    */  
    Public list < wStudyObject > populateRegion() {

        List < wStudyObject > lPicklist = new List < wStudyObject > ();
        for (Schema.Picklistentry oPicklistValues: PANG_Request__c.Region__c.getDescribe().getPicklistValues()) {
            lPicklist.add(new wStudyObject(oPicklistValues.Value, false));
        }

        return lPicklist;
    }


    /* 
    * @Method Name                    :  populateTimeFrame
    * @Description                    :  Method to populate Time Frame picklist filter
    * @Return Type                    :  Map
    * @Parameters                     :  None
    */  
    Public Map < string, Boolean > populateTimeFrame() {

        Map < string, Boolean > mTimeFrame = new Map < string, Boolean > ();

        mTimeFrame.put('This Year', false);
        mTimeFrame.put('This Quarter', false);
        mTimeFrame.put('This Month', false);
        mTimeFrame.put('This Week', false);
        mTimeFrame.put('Previous Years', false);

        return mTimeFrame;
    }

     /* 
    * @Method Name                    :  FrameClause
    * @Description                    :  Creating query parameters for checkboxes selected
    * @Return Type                    :  string
    * @Parameters                     :  lWrapperForProcessing
    */  
    Public string FrameClause(List < wStudyObject > lWrapperForProcessing) {
        String sClause = '';
        for (wStudyObject oWrapper: lWrapperForProcessing) {
            if (oWrapper.isSelected) {
                sClause += '\'' + oWrapper.label + '\',';
            }
        }
        if (sClause != '') {
            sClause = '(' + sClause.removeend(',') + ')';
        }
        return sClause;
    }

     /* 
    * @Method Name                    :  TimeClause
    * @Description                    :  Creating query parameters for checkboxes selected
    * @Return Type                    :  string
    * @Parameters                     :  mFilter
    */  
    Public string TimeClause(Map < string, Boolean > mFilter) {
        String sClause = '';
        if (mFilter.get('Previous Years') && (mFilter.get('This Week') == False) && (mFilter.get('This Quarter') == False) && (mFilter.get('This Year') == False) && (mFilter.get('This Month') == False)) {
            sClause = 'LAST_N_YEARS:100';
            return '(' + sClause + ')';
        }

        if (mFilter.get('Previous Years') && (mFilter.get('This Week') || mFilter.get('This Quarter') || mFilter.get('This Year') || mFilter.get('This Month'))) {
            sClause = 'LAST_N_YEARS:100,';
            if (mFilter.get('This Year')) {
                sClause += 'THIS_YEAR';
                return '(' + sClause + ')';
            }
            if (mFilter.get('This Quarter')) {
                sClause += 'THIS_QUARTER';
                return '(' + sClause + ')';
            }
            if (mFilter.get('This Month')) {
                sClause += 'THIS_MONTH';
                return '(' + sClause + ')';
            }
            if (mFilter.get('This Week')) {
                sClause += 'THIS_WEEK';
                return '(' + sClause + ')';
            }
        }

        if ((mFilter.get('Previous Years') == false) && ((mFilter.get('This Week') == true) || (mFilter.get('This Quarter') == true) || (mFilter.get('This Year') == False) || (mFilter.get('This Month') == False))) {
            sClause = '';
            if (mFilter.get('This Year')) {
                sClause += 'THIS_YEAR';
                return '(' + sClause + ')';
            }
            if (mFilter.get('This Quarter')) {
                sClause += 'THIS_QUARTER';
                return '(' + sClause + ')';
            }
            if (mFilter.get('This Month')) {
                sClause += 'THIS_MONTH';
                return '(' + sClause + ')';
            }
            if (mFilter.get('This Week')) {
                sClause += 'THIS_WEEK';
                return '(' + sClause + ')';
            }
        }

        return NULL;

    }

    /* 
    * @Method Name                    :  CombineQuery
    * @Description                    :  Method to combine all query parameters
    * @Return Type                    :  string
    * @Parameters                     :  sPrefix,sClauses
    */
    public String CombineQuery(String sPrefix, List < String > sClauses) {
        List < String > sCombineClause = new List < String > ();
        for (String sClause: sClauses) {
            if (sClause != null && sClause != '')
                sCombineClause.add(sClause);
        }
        if (sCombineClause.size() > 0)
            return ' ' + sPrefix + ' ' + string.join(sCombineClause, ' AND ');
        return '';
    }

    //Query constructor method
     /* 
    * @Method Name                    :  Query
    * @Description                    :  Query constructor method
    * @Return Type                    :  void
    * @Parameters                     :  None
    */
    Public void Query() {

            lProjects = new List < PANG_Project__c > ();
            lPartnerShips = new List < PANG_Request__c > ();
            lRequests = new List < PANG_Request__c > ();
            lDataAsset = new List < PANG_Data_Asset__c > ();

            String sDynamicQuery;

            String sSearchWord = mURLparams.get('searchWord');

            String sDataAstTherapeuticAreaClause = '';
            String sReqStudyTherapeuticAreaClause = '';
            String sRegionClause = '';
            String sTimeFrameClause = '';
            String sSearchClause = '';

            sRegionClause = FrameClause(mStudyObjectStructure.get('Region__c'));
            if (sRegionClause != '') {
                sRegionClause = ' Region__c INCLUDES ' + sRegionClause;
            }

            sDataAstTherapeuticAreaClause = FrameClause(mStudyObjectStructure.get('TherapeuticArea'));
            if (sDataAstTherapeuticAreaClause != '') {
                sDataAstTherapeuticAreaClause = ' Relevant_Therapeutic_Area__c IN ' + sDataAstTherapeuticAreaClause;
            }

            sReqStudyTherapeuticAreaClause = FrameClause(mStudyObjectStructure.get('TherapeuticArea'));
            if (sReqStudyTherapeuticAreaClause != '') {
                sReqStudyTherapeuticAreaClause = ' Therapeutic_Area_Primary__c IN ' + sReqStudyTherapeuticAreaClause;
            }


            sTimeFrameClause = TimeClause(mTimeFrameFilter);
            if (sTimeFrameClause != '' && sTimeFrameClause != NULL) {
                sTimeFrameClause = ' LastModifiedDate IN ' + sTimeFrameClause;
            }

            //SOSL query to return the filtered records
            if (sSearchWord != null && sSearchWord.trim() != '') {

                if (sLocalSearch != null && sLocalSearch.trim() != '') {
                    sDynamicQuery = 'FIND {' + string.escapeSingleQuotes(sSearchWord) + ' AND ' + string.escapeSingleQuotes(sLocalSearch) + '} IN ALL FIELDS RETURNING ';

                } else {
                    sDynamicQuery = 'FIND \'' + string.escapeSingleQuotes(sSearchWord) + '\' IN ALL FIELDS RETURNING ';
                }
                sDynamicQuery += 'PANG_Project__c  (id,Name,Project_ID__c,Project_Lead_Owner__r.name,Project_Status__c,TPO__c,Functional_Area__c ' + CombineQuery('WHERE', new List < String > {
                    sReqStudyTherapeuticAreaClause, sRegionClause, sTimeFrameClause
                }) + '),';
                sDynamicQuery += 'PANG_Request__c (id,Name,Type_of_Partner__c ,Partnership_Status__c,Requestor__r.name,recordtype.name,Request_Status__c,Proposed_Due_Date__c' + CombineQuery('WHERE', new List < String > {
                    sReqStudyTherapeuticAreaClause, sRegionClause, sTimeFrameClause
                }) + '),';
                sDynamicQuery += 'PANG_Data_Asset__c (id,Name,Relevant_Therapeutic_Area__c,Region__c,Type_of_Database__c,Access_Method__c,Asset_Status__c' + CombineQuery('WHERE', new List < String > {
                    sDataAstTherapeuticAreaClause, sRegionClause, sTimeFrameClause
                }) + '),';

                sDynamicQuery = sDynamicQuery.removeEnd(',');

                List < List < sObject >> lDynamicSearchResult = search.query(sDynamicQuery);

                //If no object is selected then below logic will select all objects
                If((isDataAssets == false && isStudies == false && isPartnerships == false && isRequests == false) || (isDataAssets && isStudies && isPartnerships && isRequests)) {

                    lProjects = lDynamicSearchResult[0];
                    lDataAsset = lDynamicSearchResult[2];
                    lRequests = lDynamicSearchResult[1];
                    if (lRequests.size() > 0) {
                        for (PANG_Request__c oReq: [SELECT region__c, Partnership_Sponsor__c, Partnership_Status__c, Type_of_Partner__c, name, recordtype.developername from PANG_Request__c where id IN: lRequests]) {
                            if (oReq.recordtype.developername == 'RWE_Partnership_Exploration') {
                                lPartnerShips.add(oReq);
                            }
                        }
                    }
                } else {
                    If(isStudies) {
                        lProjects = lDynamicSearchResult[0];
                    }
                    If(isDataAssets) {
                        lDataAsset = lDynamicSearchResult[2];
                    }
                    If(isPartnerships) {
                        list < PANG_Request__c > lPartReqs = lDynamicSearchResult[1];
                        if (lPartReqs.size() > 0) {
                            for (PANG_Request__c oReq: [SELECT region__c, Partnership_Sponsor__c, Partnership_Status__c, Type_of_Partner__c, name, recordtype.developername from PANG_Request__c where id IN: lPartReqs]) {
                                if (oReq.recordtype.developername == 'RWE_Partnership_Exploration') {
                                    lPartnerShips.add(oReq);
                                }
                            }
                        }
                    }
                    If(isRequests) {
                        lRequests = lDynamicSearchResult[1];
                    }
                }
            }
        }
        /*
         * Class name   : wStudyObject
         * Description  : This is a wrapper class which holds the picklist value name and checkbox to filter out results on Global Search Page
         */

    Public class wStudyObject {
        Public Boolean isSelected {
            get;
            set;
        }
        Public string label {
            get;
            set;
        }
        public wStudyObject(String l, Boolean isC) {
            label = l;
            isSelected = isC;
        }
    }

}