/****************************************************************************************************************************************** 
* Class Name   : MobileQRCodeExtension
* Description  : This is a class that will enable users to read + make updates via the QR code on a user story
*                 Users can modify the User Story via mobile phone but are required to enter a passcode before submission
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/

public with sharing class MobileQRCodeExtension{
    Public String str {get; set;}
    
    public MICO_User_Story__c req {get;set;}
    public String iCode {get;set;}
    public String iCodePass = Label.QR_Cards_Password;    
    
    
    public  MobileQRCodeExtension(ApexPages.StandardController controller) {
   
    req  = [select id,Name,Project__c, Development_Stage__c,Cancellation_Reason__c,Functional_Area__c,Sub_Process__c, As_A__c, I_Want_To__c, 
           So_that__c,Acceptance_Criteria__c,Compliance_Criteria__c,Priority__c, Privacy__c,Legal__c, 
           Story_Points__c, Story_Points_Other__c, Allocated_Sprint__c, Proposed_Sprint__c
           from MICO_User_Story__c  where id =: apexpages.currentpage().getparameters().get('id')]; system.debug(req);
    }
     
    
    
    public PageReference save(){
    try{
        if(iCode == iCodePass) {
            update req;
            }        
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter the code to make updates'));
            return null;
        }
    }
    catch(system.exception ex){
         ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getMessage().substringBetween(',',':') );
         ApexPages.addMessage(msg); 
         return null;         
        }
    return new PageReference ('/apex/Acknowledgement');
    }    
  }