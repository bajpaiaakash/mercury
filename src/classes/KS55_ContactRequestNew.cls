/****************************************************************************************************************************************** 
 * Class Name   : KS55_ContactRequestNew
 * Description  : This controller is used for Creating the contact request by Overriding the New page.
 * Created By   : Deloitte Consulting
 *
 *****************************************************************************************************************************************/
public with sharing class KS55_ContactRequestNew {

    public KS55_Contact_Request__c contReq {
        set;
        get;
    }
    public ApexPages.StandardController controller {
        set;
        get;
    }
    public String accountId {
        set;
        get;
    }
    public String retUrl {
        set;
        get;
    }
    public Boolean isFromAccRelList {
        get;
        set;
    }
    public Boolean isVisible {
        get;
        set;
    }

    /**
     * @param Standard controller
     * This method takes the value of Account Request ID and Business Unit from the URL and
     * populates the value on the page.
     * @return void
     **/
    public KS55_ContactRequestNew(ApexPages.StandardController controller) {

        if (!test.isrunningtest()) {
            controller.addFields(new list < String > {
                'Account_Name__c', 'Contact_To_Have_Access_Tool__c', 'Submitted_TF__c'
            });
        }
        
        contReq = (KS55_Contact_Request__c) controller.getrecord();
        list<KS55_Contact_Request__c> lCurrentRec = [Select Createdbyid, id from KS55_Contact_Request__c where id = : contReq.id];
        controller = this.controller;
        contReq.Business_Units__c = contReq.Account_Name__r.Business_Unit__c;
        //Declaring Boolean Variable to check the editability of Contact request records if Non-Owner User is editing it
        isVisible = True;
        Set < String > sPsets = new Set < String > ();
        Set < String > sPsetNames = new Set < String > ();
        //Querying for Logged in User Permission set Assignments
        List < PermissionSetAssignment > lPerSetAssignmentIDs = [SELECT PermissionSetId from PermissionSetAssignment WHERE assigneeId = : userinfo.getUserID()];
        if(lPerSetAssignmentIDs.size()>0){
        //Adding permission set IDs to a set of strings
        for (PermissionSetAssignment oPsetAsign: lPerSetAssignmentIDs) {
            sPsets.add(oPsetAsign.PermissionSetId);
        }

        //Querying for Logged in User Permission set
        list < PermissionSet > lPerSets = [SELECT Name from PermissionSet WHERE id in : sPsets];
        if(lPerSets.size()>0){
        //Adding permission set Names to a set of strings
        for (PermissionSet oPset: lPerSets) {
            sPsetNames.add(oPset.Name);
        }
        //Setting the boolean variable to false in case the One requestor user is trying to edit other users contact request record
        if (sPsetNames.size() > 0 && sPsetNames.contains('KS55_Requestor') && !(sPsetNames.contains('KS55_Approver') || sPsetNames.contains('KS55_EKS_Operations') || sPsetNames.contains('KS55_App_Admin'))) {
         if(lCurrentRec.size()>0){
            if (userinfo.getUserID() != lCurrentRec[0].Createdbyid) {
                isVisible = False;
                Apexpages.addmessage(new apexpages.message(apexpages.severity.error, label.KS55_Unauthorised_Edit));
            }
          }
        }
       }
      }



        //Condition to check if the record is being deleted
        if (ApexPages.currentPage().getParameters().get('delID') == NULL) {


            //Logic to change Account name field to readonly if user is creating record from Account request related list
            if (contReq.id == NULL && contReq.Account_Name__c != NULL) {
                isFromAccRelList = true;
            }


            if (ApexPages.currentPage().getparameters().get('Id') == null) {
                List < KS55_Account_Request__c > accountLst = [Select Business_Unit__c from KS55_Account_Request__c where Id = : contReq.Account_Name__c];
                if (accountLst.size() > 0) {
                    contReq.Business_Units__c = accountLst[0].Business_Unit__c;
                }
            } else {
                If(contReq.Status__c == KS55_Utility.ContactStatusComplete) {
                    Apexpages.addmessage(new apexpages.message(apexpages.severity.error, label.KS55_Completed_Request_Error));
                }

                If(contReq.Submitted_TF__c == TRUE)

                {
                    Apexpages.addmessage(new apexpages.message(apexpages.severity.error, label.KS55_Submitted_Request_Error));
                }
            }
        }
    }


    /*
     * This method is called when user clicks on Save and new button. It checks the mandatory values for Account Name,
     * Contact Name, Contact Role, Contact Tool, Contact Email Address and displays the validation error on the page.
     * After save , it will redirect the user to same page.
     * @return Pagereference
     */
    public PageReference saveandnew() //Save and New Button
        {
            Pagereference pr = Page.KS55_ContactRequestNew;
            pr.setredirect(true);

            //  After Save, navigate to the default new page:
            return pr;
        }

    /*
     * This method is called when the user changes the Account Request Name.
     * @return void
     */
    public void SelectAccount() {

        contReq.Business_Units__c = null;
        contreq.status__c = 'open';
        contReq.Contact_To_Have_Access_Tool__c = '';
        List < KS55_Account_Request__c > accountLst = [Select Business_Unit__c from KS55_Account_Request__c where Id = : contReq.Account_Name__c];
        if (accountLst.size() > 0) {
            contReq.Business_Units__c = accountLst[0].Business_Unit__c;
        }
    }

    /*
     * This method is called when the user clicks on Cancel button on the page.
     * @return void
     */
    public PageReference cancel() {
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        if (retUrl != null) {
            Pagereference pr = new Pagereference(retUrl);
            pr.setRedirect(true);
            return pr;
        } else return null;
    }

    /*
     * This method is to display error message if user is trying to delete submitted contact request.
     * @return void
     */
    public pageReference validateDelete() {
        String r = KS55_Contact_Request__c.sObjectType.getDescribe().getKeyPrefix();

        if (ApexPages.currentPage().getParameters().get('delID') != NULL) {
            if (contReq.Submitted_TF__c == TRUE) {

                Apexpages.Addmessage(new Apexpages.message(Apexpages.Severity.Error, Label.KS55_Delete_ContReq_Error));

            } else {
                delete contReq;
                Pagereference pr = new Pagereference('/' + r);
                pr.setRedirect(true);
                return pr;
            }

        }
        return null;
    }


}