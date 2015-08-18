/*
* CreateCaseRedirectControllerMVN
* Created By: Roman Lerman
* Created Date: Jan 1, 2013
* Description: This class creates a new interaction whenever the "New" button is clicked on the Case list view
*/
public with sharing class CreateCaseRedirectControllerMVN {
    public Case newCase { get; set; }
    public String accountId { get; set; }

    public CreateCaseRedirectControllerMVN (ApexPages.StandardController controller) {
        Case c = (Case)controller.getRecord();
        if(ApexPages.currentPage().getParameters().get('def_account_id') != null)
            accountId = ApexPages.currentPage().getParameters().get('def_account_id');
    }

    public void getRedirect () {
        Id recTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName='MERC_Mercury_Cases' limit 1].Id;
        newCase = new Case(RecordTypeId=recTypeId);
        if(accountId != null){
           newCase.AccountId = accountId;
           newCase.ContactId = [select PersonContactId from Account where Id = :accountId].PersonContactId;
        }
        try{
            insert newCase;
        }catch(Exception e){
            ApexPages.addMessages(e);
        }
    }
}