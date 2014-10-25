/****************************************************************************************************************************************** 
* Class Name   : createTestsForTester
* Description  : Creates Tests for Tester based on template  
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/

trigger MICO_createTestsForTester on MICO_Tester__c (after insert) {
    List<MICO_Test__c> Tst = new List<MICO_Test__c>();
    List<MICO_Test_Templates__c> Templates = new List<MICO_Test_Templates__c>();
    Set<Id> TempDetails = new Set<Id>();
    Map<Id, List<MICO_Test_Steps__c>> TempSteps = new Map<Id, List<MICO_Test_Steps__c>>();
    Map<id, MICO_Test_Templates__c> template2story = new map<id,MICO_Test_Templates__c>();
    
    for(MICO_tester__c t : trigger.new){
        TempDetails.add(t.Test_Template__c);
    }
    
    for(MICO_Test_Templates__c t : [select id, user_story__c, User_Story__r.Project__c, user_story__r.Allocated_Sprint__c from MICO_Test_Templates__c where id in :TempDetails]){

        template2story.put(t.id, t);
    
    }
    
    
    
for(MICO_Tester__c t : trigger.new){
    
    
    Tst.add(new MICO_Test__c(
    Template__c =t.Test_Template__c,
    user_story__c = template2story.get(t.Test_Template__c).user_story__c,
    project__c = template2story.get(t.Test_Template__c).user_story__r.Project__c,
    sprint__c = template2story.get(t.Test_Template__c).user_story__r.Allocated_Sprint__c,
    //OwnerId=t.User__c, 
    Status__c = 'Not Started',
    Test_Phase__c = t.Test_Phase__c,
    Assigned_To__c = t.User__c));
    
}

id ParId = null;
List<MICO_Test_Steps__c> toMap = new List<MICO_Test_Steps__c>();
List<MICO_Test_Steps__c> toMap2 = new List<MICO_Test_Steps__c>();
for(MICO_Test_Template_Steps__c ts : [select id, Name, Test_Script__c from MICO_Test_Template_Steps__c where Test_Script__c in :TempDetails]){
    
    if((ParId ==  ts.Test_Script__c) || (ParId == null)){
        toMap.add(new MICO_Test_Steps__c(Template_Step__c=ts.id, Name = ts.name));
    }else{
        TempSteps.put(ParId, new List<MICO_Test_Steps__c>(toMap.deepClone()));
        toMap.clear();
        toMap.add(new MICO_Test_Steps__c(Template_Step__c=ts.id, Name = ts.name));
    }
    
    ParId = ts.Test_Script__c;
    
    
}
system.debug(toMap);
system.debug(ParId);
TempSteps.put(ParId, new List<MICO_Test_Steps__c>(toMap.deepClone()));
system.debug(TempSteps);
toMap.clear();

insert tst;

for(MICO_Test__c ab : tst){
    String st = ab.Template__c;
    system.debug(TempSteps.get(st));
    if(TempSteps.containsKey(st)){
    list<MICO_Test_Steps__c> zy = TempSteps.get(st);
    for(MICO_Test_Steps__c x : zy){
        tomap2.add(new MICO_Test_Steps__c(
        Test__c = ab.Id,
        Name=x.Name,
        Template_Step__c = x.Template_Step__c
        
        ));
    }
    system.debug(zy);
    }
}
system.debug(toMap2);
insert toMap2;




}