/****************************************************************************************************************************************** 
* Class Name   : PANG_CreateDataAssetController
* Description  : Class to Create a Data Asset from the UI Page
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
Public with sharing class PANG_CreateDataAssetController{
    public Boolean isSaved{get; set;}
    Public PANG_Data_asset__c oDataAsset{get; set;}    
    
    //Individually declaring 3 attachments rather than list beacuse this will resolve the issue of upolading documents with name more than 80 characters    
    public Transient  Blob attachmentBody1 {get; set;} 
    public String attachmentName1 {get; set;}
    public Transient  Blob attachmentBody2 {get; set;} 
    public String attachmentName2 {get; set;}
    public Transient  Blob attachmentBody3 {get; set;} 
    public String attachmentName3 {get; set;}
    
    //Loading the constructor the page
    Public PANG_CreateDataAssetController(apexpages.standardcontroller stdCon){
        isSaved = true;
        oDataAsset = new PANG_Data_asset__c();
        
    }
    
    /* 
* @Method Name                    :  saveApplicant
* @Description                    :  This Method Saves the Data Asset Form from the UI
* @Return Type                    :  void
* @Parameters                     :  None
*/     
    Public void saveApplicant(){
        try{
            oDataAsset.Asset_Status__c='Proposed';
            insert oDataAsset;
            
            //Uploading the documents 
            list<Attachment> lAttachments = new list<Attachment>();
            if(attachmentBody1!=null && attachmentName1!=NULL){
                lAttachments.add(new attachment(name =attachmentName1,body=attachmentBody1,parentID =oDataAsset.id));
            }
            if(attachmentBody2!=null && attachmentName2!=NULL){
                lAttachments.add(new attachment(name =attachmentName2,body=attachmentBody2,parentID =oDataAsset.id));
            }
            if(attachmentBody3!=null && attachmentName3!=NULL){
                lAttachments.add(new attachment(name =attachmentName3,body=attachmentBody3,parentID =oDataAsset.id));
            }
            if(lAttachments.size()>0){
                database.insert(lAttachments,false);
            }   
            
            isSaved = false;
            String err = ' click <a href="/apex/PANG_Homepage">here</a> to return to the Pangaea home page.';
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.CONFIRM,'Your Data Asset has been successfully submitted. Thank You. Please'+err );
            ApexPages.addmessage(msg);
            
        }catch(exception e){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getmessage()));
                           }
    }
}