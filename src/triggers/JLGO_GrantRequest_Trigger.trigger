trigger JLGO_GrantRequest_Trigger on JLGO_GrantRequest__c (before insert, before update,after update) {

    JLGO_GrantRequest_TriggerHandler handler = new JLGO_GrantRequest_TriggerHandler();


    if (Trigger.isInsert && Trigger.isBefore) {
        handler.OnBeforeInsert(Trigger.New);	
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        handler.OnBeforeUpdate(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isAfter){	
        handler.OnAfterUpdate(Trigger.newMap,Trigger.oldMap);
    }
}