/**
 * Created by: Eric Montelibano (PwC)- 21/05/2015
 * Application: Quality in Design User Experience (QDUX)
 * 
 * Description: Controller class for the components within the QDUX_SearchPage. These VF components consists of the follwing:
 * QDUX_SearchBar, QDUX_SCVVResults, QDUX_SCRecommProc, QDUX_SCChatterGroup
 * The controller allows user to enter a search criteria and will search across Salesforce and external system like Veeva Vault Quality Docs and ETMF.
*/


public with sharing class QDUX_SearchPageResultController { 
    //constructor
    public QDUX_SearchPageResultController(){
        collabList = new List <CollaborationGroup>();
        appLinksList = new List <GLBL_Application_Link__c>();
        resultList = new List <searchResults>();
        system.debug('component??? ' +component);
        initialize = false;
    }
    
    //list of salesforce object 
    public Boolean initialize {get;set;}
    public List <CollaborationGroup> collabList {get;set;}
    public List <GLBL_Application_Link__c> appLinksList {get;set;}
    public string strSearch {get;set;} //string search variable to search salesforce and vault
    public string urlprefix {get;set;}
    public String component {get;set;}
    
    /**
	 * Initiatilize the page through an action function within the page. The method will call methods that can retrieve appropriate search results.
	 * @return void
	*/
    public void init(){
        collabList = new List <CollaborationGroup>();
        appLinksList = new List <GLBL_Application_Link__c>();
        resultList = new List <searchResults>();
        initialize = true;
        String searchParam = ApexPages.currentPage().getParameters().get('search');	
        system.debug('start init');
        system.debug('my component??? ' +component);
        
        //if component value is not null then call the search method
        if(component != null){
            strSearch = String.escapeSingleQuotes(searchParam);
            if(strSearch.length() > 1){
                search();
                system.debug('my size??? '+resultList.size());
            }	else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Search requires 2 or more Characters!'));
            }
        }
    }
    
    //Search Result wrapper to parse JSON result into Salesforce and VF Page.
    public List<searchResults> resultList {get;set;}
    public class searchResults {
        public Integer veevaId {get;set;}
        public string docName {get;set;}
        public string docDescription {get;set;}
        public string strAudience {get;set;}
        public list <string> country {get;set;}
        public datetime effectiveDate {get;set;}
        public datetime approvedDate {get;set;}
        public string status {get;set;}
        public string type {get;set;}
        public string subType {get;set;}
        public string classification {get;set;}
        public string document_number {get;set;}
        public datetime released_date {get;set;} 
		public string record_series_code {get;set;}
		
    }
    
    public class Data {
        public String name;
    }
    public class Document_impacted_audience1 {
        public List<Data> data;
    }
    
    
    //Sends a search methods to appropriate system
	 
    public pageReference search(){
        if(strSearch.length() > 1){
            system.debug('what is my strSearch' +strSearch);
            if(component == 'CollabGroup'){
                groupSearch();
            } else if (component == Label.QDUX_Quality_Docs_Label){
                vvSearchResults();
            } else if (component == Label.QDUX_ETMF_Label){
                vvSearchResults();
            }
            
            PageReference pr = Page.QDUX_SearchPage;
            pr.getParameters().put('search', +strSearch);
            pr.setRedirect(true);
            
            return pr;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Search requires 2 or more Characters!'));
            return null;
        } 
    }
    
    /**
	 * Get Application Links from Salesforce
	 * @return GLBL_Application_Link__c List
	*/
    public List<GLBL_Application_Link__c> getCommonProcedures(){
        system.debug('whats my str search  ====='+strSearch);
        List <GLBL_Application_Link__c> commProc = [Select Id, Name, Link_URL__c, Link_Name__c, Link_Description__c 
                                                    from GLBL_Application_Link__c where Active__c = true and RecordType.Name =: Label.QDUX_ProcessLinkRTLabel 
                                                    and Application_Code__c =: Label.QDUX_Application_Link_App_Code
                                                    limit 10];
        system.debug('what is my list size ' +commProc.size());
        return commProc;
    } 
    
    /**
	 * Search Chatter Groups based on the search criteria
	 * @return CollaborationGroup List
	*/
    public void groupSearch(){
        string collQuery = 'CollaborationGroup (id, informationtitle, fullphotourl, hasprivatefieldsaccess, informationbody, collaborationtype, lastfeedmodifieddate, ';
        collQuery += 'membercount, description, name)';
        String searchQuery =  'Find \'' +string.escapeSingleQuotes(strSearch) +'\' IN ALL FIELDS RETURNING ' +collQuery;
        
        system.debug('SEARCH QUERY???? ' +searchQuery);
        List<List <sObject>> searchList = search.query(searchQuery);
        system.debug('what is my list size ' +searchList.size());
        
        system.debug('what is my list size ' +searchList);
        collabList = ((List<CollaborationGroup>)searchList[0]);
        system.debug('collList ./...' +collabList);
    }
    
    /**
	 * Search Veeva Vault Quality Docs or ETMF dependent on the component Type. The method will call the UTILS class to call Vaults REST API to retrieve
	 * applicable docs. The response result will call QDUX_VVJSONSearchResultParser to parse the data that Salesforce can read. This will then store the information
	 * into the wrapper and will be displayed to the user in the visualforce page.
	 * @return searchResults List
	*/
    public void vvSearchResults(){
        QDUX_HTTPRestUtilsClass uc = new QDUX_HTTPRestUtilsClass();
        resultList = new List <searchResults>();
        
        String strDocQuery;
        String vaultHttps = 'https://';
        try {
            String strQD;
            if(component == Label.QDUX_Quality_Docs_Label){
                strQD = Label.QDUX_VaultQualityDocs_Prefix;
                strDocQuery = 'select id, name__v, title__v, type__v , subtype__v, status__v, classification__v, lifecycle__v, country__v, owning_department__v, approved_date__vs, document_number__v,  effective_date__v, '; 
                strDocQuery+= 'released_date__c, record_series_code__c, ';
                strDocQuery += '(select name__v from document_impacted_audience1__cr) ';
                strDocQuery += 'from documents ';
                strDocQuery += 'FIND ' +'\'' +strSearch +'\' ' ;    
            } else if (component == Label.QDUX_ETMF_Label){
                strQD = Label.QDUX_VaultETMF_Prefix;
                strDocQuery = 'select id, name__v, title__v, type__v , subtype__v, status__v, classification__v, lifecycle__v, country__v, document_number__v ';
                strDocQuery += 'from documents ';
                strDocQuery += 'FIND ' +'\'' +strSearch +'\' ' ;
            }
            system.debug('DOC QUERY?? ' +strDocQuery);
            system.debug('SEARCH USING COMPONENT ==== ' +strQD);
            
            String endpointURL = vaultHttps +strQD +label.QDUX_VV_BaseURL+label.QDUX_VV_Query_URL_Suffix +EncodingUtil.urlEncode(strDocQuery, 'UTF-8');
            urlprefix = vaultHttps +strQD +label.QDUX_VV_BaseURL + label.QDUX_VV_Doc_Link_URL;
            system.debug('???? END POINT????  ' +endpointURL);
            
            string strReplaceRes = uc.getJSON(endpointURL).replace('__cr', '').replace('__c', '').replace('__vs','').replace('__v','');
            QDUX_VVJSONSearchResultParser vp = (QDUX_VVJSONSearchResultParser)system.JSON.deserialize(strReplaceRes, QDUX_VVJSONSearchResultParser.class);
            system.debug('what is my VP ++++' +vp);
            
            if(vp.responseStatus == 'Success'){
            	for(QDUX_VVJSONSearchResultParser.Data e : vp.data){
                    searchResults s = new searchResults();
                    s.veevaId = e.id; 
                    s.docName = e.name; 
                    s.docDescription = e.title; 
                    s.country =e.country; 
                    s.effectiveDate = e.effective_date;
                    s.approvedDate = e.approved_date;
                    s.status = e.status;
                    s.type = e.type;
                    s.subType = e.subtype;
                    s.classification = e.classification;
                    s.document_number = e.document_number;
                    List <String> audience = new List <String>();
                                       
                    //run this code snippet for Quality Docs Component only. 
                    if(component ==Label.QDUX_Quality_Docs_Label){
                    	s.released_date = e.released_date; 
						s.record_series_code = string.valueof(e.record_series_code);
						system.debug('///// record series ' +e.record_series_code);
                        for(QDUX_VVJSONSearchResultParser.data x :e.document_impacted_audience1.data) {
                            audience.add(x.Name);
                        }
                        s.strAudience =  string.valueof(audience);
                    }
                    
                    resultList.add(s);
                    system.debug('what are my results ///// ' +resultList);
                    
                }
            } else {
                String errorMessage;
                String errorType;
                system.debug('vp errors ???? ' +vp.Errors);
                for(QDUX_VVJSONSearchResultParser.Errors e : vp.Errors){
                	system.debug('ERRORS????? ' +e); 
                    errorMessage = e.message;
                    errorType = e.type;
                }
                if(errorType != 'UNEXPECTED_ERROR' && errorType != 'INSUFFICIENT_ACCESS'){
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, 'Error Type: ' +errorType +'Message: ' +errorMessage));
                }
                
            } 
            
        } catch (system.CalloutException e){
            system.debug('my exception errror' +e);
            uc.createErrorMessage(e.getMessage(), e.getStackTraceString(), Label.QDUX_Callout_Failed_Message);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, ''+e));
            
        }
    }
}