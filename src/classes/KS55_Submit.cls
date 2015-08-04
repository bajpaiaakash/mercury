/****************************************************************************************************************************************** 
 * Class Name   : KS55_Submit
 * Description  : This controller is called when user clicks on Submit for Approval button.
 * Created By   : Deloitte Consulting
 *
 *****************************************************************************************************************************************/
public with sharing class KS55_Submit {

    Private final KS55_Contact_Request__c oCurrentContactRequest;

    public KS55_Submit(ApexPages.StandardController stdController) {
        this.oCurrentContactRequest = (KS55_Contact_Request__c) stdController.getRecord();
    }

    /*
     * This method is called on Page load. It checks the mandatory fields required before
     * submitting the contact for approval , and displays the validation error on the page.
     * It will redirect the user back to the contact request page.
     * @return Pagereference
     */
    public pagereference SubmitForApproval() {

        try {

            List < Attachment > attLst = [Select Id from Attachment where ParentId = : oCurrentContactRequest.Account_Name__c];
            if (oCurrentContactRequest.Account_Name__r.Signed_Documentation_In_Place__c == 'Yes') {
                if (attLst.size() == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.KS55_Account_Request_Attachment_Error + ' <a href=/p/attach/NoteAttach?pid=' + oCurrentContactRequest.Account_Name__c + '&retURL=' + oCurrentContactRequest.Id + '&parentname=' + oCurrentContactRequest.Account_Name__r.name + '>Click here to Attach</a>'));
                }
                if (oCurrentContactRequest.Account_Name__r.Documentation_Date_Expire__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.KS55_Date_Expired_Error));
                }

                if (oCurrentContactRequest.Account_Name__r.Documentation_Date_Signed__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.KS55_Documentation_Signed_Field));
                }
            }
            if ((oCurrentContactRequest.Status__c != 'Open') && (oCurrentContactRequest.Status__c != 'Rejected')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.KS55_Contact_Status_Error));
            }

            if (!ApexPages.hasMessages()) {
                oCurrentContactRequest.System_Using_Custom_Approval__c = true;
                Database.Saveresult saveResultVar = Database.update(oCurrentContactRequest);

                //Initiate contact request approval process
                Approval.ProcessSubmitRequest oApproval = new Approval.ProcessSubmitRequest();
                oApproval.setObjectId(oCurrentContactRequest.Id);
                Approval.process(oApproval);
                return new pagereference('/' + oCurrentContactRequest.Id);
            } else
                return null;

        } catch (exception e) {
            if (e.GetMessage().contains('ALREADY_IN_PROCESS')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'This request has already been submitted. '));
            } else {
                ApexPages.addMessages(e);
            }
            return null;
        }
    }


}