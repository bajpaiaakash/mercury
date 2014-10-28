/****************************************************************************************************************************************** 
* Class Name   : CreateBugLink
* Description  : Creates the link betweens bugs  
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/

trigger MICO_Related_Defect on MICO_Related_Bug__c (after insert, before update) {

    List<MICO_Related_Bug__c> ActionIds = new List<MICO_Related_Bug__c>();
    SET<String> AlreadyExist = new SET<String>(); //concat of inverse relationship
    SET<String> Ids1 = new SET<String>();
    SET<Id> Ids2 = new SET<Id>();
    Map<String, MICO_Related_Bug__c> inverse = new Map<String, MICO_Related_Bug__c>();
    
    for(MICO_Related_Bug__c a: trigger.new){
        
        //test1
        Ids2.add(a.Related_Bug__c);
        
        MICO_Related_Bug__c abc = new MICO_Related_Bug__c(Related_Bug__c = a.Bug__c, Bug__c = a.Related_Bug__c);
        //test2-test1
        
        string concatkey = a.Bug__c+'-'+a.Related_Bug__c;
        inverse.put(concatkey, abc);
        
    }//where = test1
    for(MICO_Related_Bug__c x : [select id, Related_Bug__c, Bug__c from MICO_Related_Bug__c where Bug__c in :Ids2]){  
        if(inverse.containsKey(x.Related_Bug__c+'-'+x.Bug__c)){
            inverse.remove(x.Related_Bug__c+'-'+x.Bug__c);
        }
    }
    ActionIds = inverse.values();
    if(!ActionIds.isEmpty()){
        insert ActionIds;
    }
    
}