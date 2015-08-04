/****************************************************************************************************************************************** 
* Class Name   : PANG_Communities
* Description  : Class for Communities
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
public with sharing class PANG_Communities{    
    public Account a {get; set;}
    //Loading the Contructor
    public PANG_Communities(ApexPages.StandardController stdController) {
        User u = [SELECT AccountID from USER where id=:userinfo.getuserID()];
        a = [SELECT RWE_Logo_URL__c, RWE_Partner_Welcome_Description__c, RWE_Logo__c
             FROM Account 
             WHERE id=:u.AccountID ];      
    }

}