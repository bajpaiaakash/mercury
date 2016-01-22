/*
    @author : Vijay Garg, Tata Consultancy Services
    @created : On 14-JAN-2016 for US-39525
    @description : If user change the HCP Contract status to Cancelled or Completed then there should be success message on HCP Contract
   
*/

public with sharing class MERC_HCPContractNewEditController extends GLBL_BaseEditController{ 

    Public Boolean hidePage {get; private set;}  //to display the page for success message or the standard detail page
    Public String message {get; private set;}
    
    public MERC_HCPContractNewEditController(ApexPages.StandardController controller) {
        super(controller, HCP_Contract_MERC__c.SobjectType);
    }

    //To Override the standard save function for HCP Contract
    public override PageReference save() { 
        try{
            HCP_Contract_MERC__c hcpContract = (HCP_Contract_MERC__c)this.mySobject;
            
            //Contract Status Selected by end user to be updated
            String contractRequestStatus = hcpContract.Contract_Request_Status_MERC__c;
            String docuSignEnvelopeId = hcpContract.Docusign_Envelope_Id_MERC__c;
                
            update this.mySobject;
            
            //Logic to display the success error message after contract status is changed to Cancelled or Completed                   
            if ( (contractRequestStatus == 'Contract cancelled' || contractRequestStatus == 'Completed') && docuSignEnvelopeId != null ){
                if ( contractRequestStatus == 'Contract cancelled' ) {
                    this.message = 'This contract has been successfully cancelled in Mercury and DocuSign.';
                } else if ( contractRequestStatus == 'Completed' ) {
                    this.message = 'This contract has been manually completed in Mercury and the contract in DocuSign successfully cancelled';
                }
                
                this.hidePage = true;
                return null; //To display the visualforce page after save
            }
        } catch(Exception e) {
            ApexPages.addMessages(e); //doesn't show ugly error text
            return null;
        }
        
        PageReference p = new PageReference('/'+this.mySobject.Id);
        return p;
    }
}