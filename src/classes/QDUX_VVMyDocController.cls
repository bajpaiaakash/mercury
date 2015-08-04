/**
 * Created by: Eric Montelibano (PwC)- 21/05/2015
 * Application: Quality in Design User Experience (QDUX)
 * 
 * Description: Controller class for the components for QDUX_VVMyDocs
 * The controller will retrieve either documents from the following Library My Documents, Recent Documents, and Favorites from external systems
 *
*/
public without sharing class QDUX_VVMyDocController {
    //constructor
    public QDUX_VVMyDocController(){
        myDocuments = new List<DocWrapper>();
    }
    public Boolean init {get;set;}
    
    //HTTP Variables
    public String vaultHttps = 'https://';
    public string nameFilter = ApexPages.currentPage().getParameters().get('Library');
    public string filter {get;set;}
    public string urlprefix {get;set;}
    
    public String vaultName{get;set;}//{get;set;}
    public integer intValue {get;set;}
    
    //method that will be called during an action from the VF page. This will trigger an HTTP call to retrive documents
    //from external system
    public void initialize(){
        myDocuments = new List <DocWrapper>();
        doc();
        intValue = myDocuments.size();
        system.debug('int int ' +intValue);
    }
    //Wrappers for the DocWapper 
    public List<DocWrapper> DocWrapperList {get; set;}
    public class DocWrapper {
        public string docName {get;set;}
        public string doctype {get;set;}
        public Date createdDate {get;set;}
        public string docNumber {get;set;}
        public string subType {get;set;}
        public string docId {get;set;}
        List <string> prod {get;set;}
    }
    public List<DocWrapper> myDocuments {get;set;}
    //retrieve appropraite library documents from Vault. Options are My Library, Recent Documents, Favorite.
    public void doc(){
        QDUX_HTTPRestUtilsClass uc = new QDUX_HTTPRestUtilsClass();
        myDocuments = new List <DocWrapper>();
        try {
            //set endoint to Vault
            string strQD;
            system.debug('name filte???? ' +nameFilter);
            if(vaultName == Label.QDUX_Quality_Docs_Label){
            	strQD = Label.QDUX_VaultQualityDocs_Prefix;   
            } else if (vaultName == Label.QDUX_ETMF_Label){
                strQD = Label.QDUX_VaultETMF_Prefix;
            }
            
            urlprefix = vaultHttps +strQD +label.QDUX_VV_BaseURL + label.QDUX_VV_Doc_Link_URL;
            system.debug('vault name??? ' +vaultName);
            string finalEndpoint= vaultHttps +strQD +label.QDUX_VV_BaseURL +Label.QDUX_VV_Named_Filter_URL +EncodingUtil.urlEncode(nameFilter, 'UTF-8') ;
            system.debug('endpoint??/ ' +string.valueOf(vaultHttps +strQD +label.QDUX_VV_BaseURL +Label.QDUX_VV_Named_Filter_URL +EncodingUtil.urlEncode(nameFilter, 'UTF-8') ));
            
            string strResponse = uc.getJSON(finalEndpoint).replace('__c','').replace('__vs','').replace('__v', '');
            system.debug('RESPONSE BODY ' +strResponse);
            
            QDUX_VVMyDocResponse md = (QDUX_VVMyDocResponse)system.JSON.deserialize(strResponse, QDUX_VVMyDocResponse.class);
            system.debug('WHAT IS MY vvMYDoc deserialized   ====>' +md);
            
            //if statement for the Successful response
            system.debug('where am i???');
            if(md.responseStatus == 'SUCCESS'){ 
                for(QDUX_VVMyDocResponse.Documents e : md.Documents){
                    DocWrapper d = new DocWrapper();
                    d.docName = e.document.Name;
                    system.debug('DOCNAME/////' +d.docName);
                    d.doctype = e.document.type;
                    d.createdDate = date.valueOf(e.document.document_creation_date);
                    d.docNumber = e.document.document_number;
                    d.subType = e.document.subtype;
                    d.docId = String.valueof(e.document.id); 
                    d.prod = e.document.product;
                    myDocuments.add(d);
                    system.debug('WHAT IS MY WRAPPER LIST INFO '+DocWrapperList);
                }
	            
	            if(myDocuments.size() < 1){
			        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'No available documents found in ' +VaultName));
			    }
			            
            } else { //throw error message if unsuccessful or failure
            	String errorMessage;
            	String errorType;
            	for(QDUX_VVMyDocResponse.Errors e : md.Errors){
                    
            		errorMessage = e.message;
            		errorType = e.Type;
            	}
            	if(errorType != 'UNEXPECTED_ERROR'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, 'Error Type: ' +errorType +'<br/> Message: ' +errorMessage));
                }
            } 
                 
        }catch(System.CalloutException e){
            system.debug('my exception errror' +e);
            uc.createErrorMessage(e.getMessage(), e.getStackTraceString(), Label.QDUX_Callout_Failed_Message);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, ''+e));
        }
        
    }
  
}