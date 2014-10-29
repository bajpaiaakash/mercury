/*
*@ Class Name                                                    : GLBL_AttachmentSuccessStory_Extension
*@ Description                                                   : Class for attaching Icon Image/ Image on GSO_Content record of type Success story
*@ CreatedBy                                                     : Jayalakshmi Mohanan Pillai
*@ CreatedOn                                                     : 08-22-2014
*@ Modification Log                                              :                                      
*/

public with sharing class GLBL_AttachmentSuccessStory_Controller{
  
    // Class level Variable declaration
    private GLBL_GSO_Content__c gsoContent;
    private String attachType;
    private Id attachParentId;    
    private List<Attachment> attachmentlist;
    
    public Static Final String TYPE_ICONIMG = 'IconImage';
    public Static Final String TYPE_DETAILIMG = 'DetailImage';
    public Static Final String TYPE_PROCESSSTEPIMG = 'ProcessStepImage';
    
    // Constructor  
    public GLBL_AttachmentSuccessStory_Controller() {        
    
    }
    
    /* 
          * @Method Name                    :  typePopulation
          * @Description                    :  This Method will called from the saveContent method to perform
                                               population of IconImage or DetailImage URLs of the attachment
          * @Return Type                    :  void
          * @Param                          :  none
                                            
    */
    public void typePopulation() {          
        if(ApexPages.currentPage().getParameters().containsKey('id')){
                string  attachId = ApexPages.currentPage().getParameters().get('id');   
                attachParentId = attachId.substring(0,15);              
                attachType = attachId.substring(15,attachId.length());                          
        }   
        
        system.debug('ApexPages.currentPage().getURL()' + ApexPages.currentPage().getURL());
        if (attachParentId != NULL) {
        	 
            try {   
                gsoContent = [	SELECT id,Icon_Image_URL__c,Detail_Image_URL__c, Process_Step_Image_URL__c
								FROM GLBL_GSO_Content__c
                				WHERE id=: attachParentId];
                				
                attachmentList=[SELECT id 
                				FROM attachment 
                				WHERE parentid=:attachParentId 
                				ORDER BY CreatedDate DESC 
                				LIMIT 1];
                
                string pUrl =  string.valueof(URL.getSalesforceBaseUrl());
                string[] splitBaseURL = pUrl.split('=',2);
                
                if(attachmentList.size() > 0 ){                             
                    if(attachType == TYPE_ICONIMG){ 
                        gsoContent.Icon_Image_URL__c = splitBaseURL[1].substring(0,splitBaseURL[1].length()-1)+'/servlet/servlet.FileDownload?file='+attachmentList[0].id;          
                        system.debug('gsoContent.Icon_Image_URL__c ' + gsoContent.Icon_Image_URL__c);  
                    }
                    else if(attachType == TYPE_DETAILIMG){                  
                        gsoContent.Detail_Image_URL__c = splitBaseURL[1].substring(0,splitBaseURL[1].length()-1)+'/servlet/servlet.FileDownload?file='+attachmentList[0].id; 
                        system.debug('gsoContent.Detail_Image_URL__c ' + gsoContent.Detail_Image_URL__c);    
                    }
                    else if(attachType == TYPE_PROCESSSTEPIMG){
                    	gsoContent.Process_Step_Image_URL__c = splitBaseURL[1].substring(0,splitBaseURL[1].length()-1)+'/servlet/servlet.FileDownload?file='+attachmentList[0].id; 
                        system.debug('gsoContent.Detail_Image_URL__c ' + gsoContent.Process_Step_Image_URL__c); 
                    }
                }
            }
            catch(QueryException E) {
                    system.debug('Exception occurred during query of attachment and its parent GSO Content' + e);
                    GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                                     Error_Message__c= e.getMessage(),
                                                                     Running_User__c = UserInfo.getUserId() ,
                                                                     Stack_Trace__c = e.getStackTraceString()); 
                    insert errlog;                  
            }
                    
                 
        }   
        
        if(gsoContent != NULL){
            try { 
                    update gsoContent;
            }
            catch(DMLException e) {
                    System.debug('Exception occurred during insert of update of GSO Content record for Image Urls' + e);
                    GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                                     Error_Message__c= e.getMessage(),
                                                                     Running_User__c = UserInfo.getUserId() ,
                                                                     Stack_Trace__c = e.getStackTraceString()); 
                    insert errlog;  
            }
      
        }   
    }
    
    
    /* 
          * @Method Name                    :  savecontent
          * @Description                    :  This Method will is invoked by page action parameter on click of button
                                               on GSO content page Layout
          * @Return Type                    :  void
          * @Param                          :  pagereference to the GSOContent detail page on which the buttons were clicked
                                            
    */
    public pagereference saveContent(){
        typePopulation();               
                
        PageReference contPage = new PageReference('/' + attachParentId);
        contPage.setRedirect(true);
        return contPage;
    }
                
    

}