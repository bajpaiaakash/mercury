/* Class containing the methods to simulate the actual behaviour of an attach file action of salesforce 
   as we need validation while attaching the file to check its dimension*/

public with sharing class GLBL_AttachmentHandler {
    
    // Parent Id of attachment  : record to which attachment would be made  
    public ID attParentID = null;        
    
    // Name of the parent record ( form template record name to be displayed on attachment page as section header)  
    public String attParentName {get;set;}
    // API Name of the field to which the attachment URL would be updated
    public String attParentUrlField;
    // API Name of Attachment parent object
    public String attParentAPIName ;
    // Switch to display the file attached & size block
    public Boolean showUploadDetails {get;set;}    
    // Form template to update the logo URL to be used by execution
    public SObject parentObj;
    // Custom Settings Record corresponding to URL passed
    public GLBL_AttachmentImageSettings__c attSettings {get;set;}
    // New Attachment Object
    public Attachment newAttach = new Attachment();
    public String fileName {get;set;}
    public String fileSize {get;set;}
    
    public String retURL {get;set;}
    
    //Constructor
    public GLBL_AttachmentHandler() {
    	
    	System.debug('### ATTACHMENT URL:' + ApexPages.currentPage().getUrl());
		System.debug('### ATTACHMENT PARAMS:' + ApexPages.currentPage().getParameters());
      
        attParentID = System.currentPageReference().getParameters().get('ParentID'); 
        if(ApexPages.currentPage().getParameters().containsKey('Parentname'))    { 
        	attParentName = System.currentPageReference().getParameters().get('Parentname'); // parent object record Name field to display as header on attachment page      
        }     	
        
        attParentAPIName = System.currentPagereference().getParameters().get('ParentType'); // Parent Object API name fetched from URL
        attParentUrlField = System.currentPagereference().getParameters().get('ParentURLField'); // Parent Object Field Name which would store the logo URL
        
        if(ApexPages.currentPage().getParameters().containsKey('retURL')){
        	retURL = System.currentPagereference().getParameters().get('retURL');
        }
        showUploadDetails = false;      
                
        String SOQLQuery = 'SELECT {0} FROM {1} WHERE id =: attParentID ';
        attSettings = getAttsettings();            
        
        if(attSettings != null) {                                     
	        if(attSettings.Object_API_Name__c != '' && attSettings.Field_API_Name__c != NULL && attSettings.Field_API_Name__c != ''  && attParentID != NULL){
	            String formatQuery = String.format(SOQLQuery,new String[]{attSettings.Field_API_Name__c, attSettings.Object_API_Name__c}) ;
	            system.debug('format query String' + formatQuery);                                        
	            parentObj = Database.query(formatquery);                                        
	        }                                        
        } 
        else if(attParentUrlField != null && attParentAPIName != null && attParentID != NULL ) {
        	String formatQuery = String.format(SOQLQuery,new String[]{attParentUrlField, attParentAPIName}) ;
            system.debug('format query String' + formatQuery);                                        
            parentObj = Database.query(formatquery);         	
        }
    }                                       
    
   
    public GLBL_AttachmentImageSettings__c getAttSettings(){
        GLBL_AttachmentImageSettings__c attSettings = new GLBL_AttachmentImageSettings__c();	
        List<GLBL_AttachmentImageSettings__c> attachmentSettingsLst = GLBL_AttachmentImageSettings__c.getall().values();
        if(attachmentSettingsLst.size() != 0 && attachmentSettingsLst != NULL){
       	    for(GLBL_AttachmentImageSettings__c settingItr : attachmentSettingsLst){
       		    if(settingItr.Object_API_Name__c == attParentAPIName && settingItr.Field_API_Name__c == attParentUrlField){
       		 	    attSettings = settingItr;
       		 	    break;    		 
       		    }       		 
       	    }     
       	    return attSettings;  	      	  
        }
        return null; 
    }
    
    // Method referred when button 'Done' is clicked on page : redirects the user to parent records page
    public PageReference cancel() {  
    system.debug('System.currentPageReference' + System.currentPageReference().getParameters());
       if(System.currentPageReference().getParameters().get('retURL') != Null && System.currentPageReference().getParameters().get('isdtp') == 'p1'){
       	  // Indicates the application logged in SF1, thus URL stripped of execution id , thus need to add it by SOQL
       	  Id executionId = [SELECT id, name, Form_Execution__c 
       	                    FROM GLBL_Form_Execution_Question_Answer__c
       	                    WHERE id =: System.currentPageReference().getParameters().get('ParentId')][0].Form_Execution__c;
       	  return new PageReference(System.currentPageReference().getParameters().get('retURL')+'?id='+ executionId);                  
       }	
       else if(System.currentPageReference().getParameters().get('retURL') != Null){
       	   return new PageReference(System.currentPageReference().getParameters().get('retURL'));
       }	    
       else {
       	   String salesforceHome = URL.getSalesforceBaseUrl().toExternalForm();      
           return new PageReference(salesforceHome + '/' +attParentID);   
       }       
            
    }
   
   
    /**
    * Set parent id for Attachment instance
    *@param String
    */
    public void setAttParentID (String parentId) {
        this.attParentID = parentId;
    }
  
    /**
    *@return String
    */
    public String getAttParentID () {
        return this.attParentID;
    }
   
      
    
  
    /**
    *@param Attachment
    */
    public void setNewAttach (Attachment newAttach) {
        this.newAttach = newAttach;
    }
  
    /**
    *@return Attachment
    */
    public Attachment getNewAttach () {
        return newAttach;
    }
      
    /**
    * Save new image
    *@return PageReference
    */
    public PageReference saveNewImage () {             
                      
        PageReference pageRef = ApexPages.currentPage();       // current page
        string pUrl =  string.valueof(URL.getSalesforceBaseUrl());
        string[] splitBaseURL = pUrl.split('=',2);
          
        if((newAttach.name != null || newAttach.name != '') && (this.attParentID != null || this.attParentID != '')) {
                                                          
             newAttach.ParentId = this.attParentID; // assign parent id                    
             newAttach.IsPrivate = false; 
             try {  
             	    // insert attachment irrespective of customsetting exists or URL containing the parent object details for updating URL field                  
                    insert newAttach; 
                    system.debug('====attSettings'+attSettings + '=====attParentUrlField' + attParentUrlField + '====attParentAPIName' + attParentAPIName +'====parentObj' + parentObj );
                    //checking custom settings has atleast record giving details like object and field to be updated
                    if(attSettings != null && parentObj != null) {  
	                    if(attSettings.Object_API_Name__c != '' && attSettings.Field_API_Name__c != ''){                                  
	                         // update URL field on Form Template
	                         parentObj.put(attSettings.Field_API_Name__c, splitBaseURL[1].substring(0,splitBaseURL[1].length()-1)+'/servlet/servlet.FileDownload?file='+newAttach.id); 
	                         system.debug('parentObj.Logo_Image__c ++++ in Sutom Setting block' + parentObj.get(attSettings.Field_API_Name__c));
	                         update  parentObj;
	                    }
                    } //if no custom setting atleast URL should fetch the details like object and field to be updated
                    else if(attParentUrlField != null && attParentAPIName != null && parentObj != null){  
                    	 // update URL field on Form Template
                         parentObj.put(attParentUrlField, splitBaseURL[1].substring(0,splitBaseURL[1].length()-1)+'/servlet/servlet.FileDownload?file='+newAttach.id); 
                         system.debug('parentObj.Logo_Image__c ++++ in URL block' + parentObj.get(attParentUrlField));
                         update  parentObj;
                    }
                        
                    pageRef.setRedirect(false);
                    fileName = newAttach.name;
                    fileSize = getHumanReadableByteCount(newAttach.BodyLength);
                    //newAttach = new Attachment();
                    showUploadDetails = True;
                    return pageRef;
             } catch(Exception e){
                     System.debug('Exception occurred during insert of update formtemplate or insert of attachment for Image Urls' + e);
                     GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                                 Error_Message__c= e.getMessage(),
                                                                 Running_User__c = UserInfo.getUserId() ,
                                                                 Stack_Trace__c = e.getStackTraceString()); 
                  	 insert errlog;  
                  	 return null;
                 }
             finally{
             	 newAttach= null;
             	 return null;  
             }    
                 
                    
          }
          
          return null;
         
   }

    public String getHumanReadableByteCount(Integer bytes) {
        Integer unit = 1000;
        if (bytes < unit) return bytes + 'B';
        Integer exp = (Integer) (Math.log(bytes) / Math.log(unit));
        String pre = 'KMGTPE'.substring(exp-1, exp);
        String[] fillers = new String[]{ String.valueOf((bytes / Math.pow(unit, exp)).round()), pre};
        return String.format('{0} {1}B', fillers);
    }


}