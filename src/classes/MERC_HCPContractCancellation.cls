/**
 * @author Vijay Garg: Dated 14-JAN-2016 for US-39525
 *
 * Trigger handler that ensures DocuSign envelope Cancellation after HCP Contract status chagned to Cancelled or Completed
 */
public with sharing class MERC_HCPContractCancellation implements GLBL_TriggerHandler.HandlerInterface {
    
    public Boolean isActive() {
        return true;
    }

    public void handle() {
        if (Trigger.isUpdate ) {
            execute(Trigger.new);
        }
    }
    
    public void execute(List<SObject> sobjects) {
        String contractRequestStatus;
        String docuSignEnvelopeIdOld;
       
        ID UserId = userinfo.getProfileId();

        List<Profile> profileList = [Select Name from Profile where Id =: UserId ]; //Profile for User Performing DML Operation on HCP Contract

        for( HCP_Contract_MERC__c hcpContract: (List<HCP_Contract_MERC__c>)sobjects){
            //We have to void the DocuSign Envelope for old envelop id in case we click on 'Request Signature' button
            HCP_Contract_MERC__c oldHCPContract = (HCP_Contract_MERC__c)Trigger.oldMap.get(hcpContract.id);
            
            try{
                contractRequestStatus = hcpContract.Contract_Request_Status_MERC__c;
                docuSignEnvelopeIdOld = oldHCPContract.Docusign_Envelope_Id_MERC__c;
              
                if (( contractRequestStatus == 'Contract Cancelled' || ( contractRequestStatus == 'Completed' && profileList[0].Name != 'Mercury Integration Docusign - Platform')) && docuSignEnvelopeIdOld != null ) {
                    MERC_DocusignService.voidEnvelope(docuSignEnvelopeIdOld, contractRequestStatus);
                }
            }catch(Exception e){
                hcpContract.addError('There was a problem while voiding HCP Contract in Docusign'); //DocuSign Error message to be displayed
            }
        }
    }
}