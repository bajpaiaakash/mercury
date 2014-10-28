trigger MICO_Test_Script_Step_Trigger on MICO_Test_Template_Steps__c (before insert,after delete) {
    if(trigger.isBefore && trigger.isInsert){
        MICO_Test_Script_StepTriggerClass.updateSequenceNumberOnInsert(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isDelete){
        MICO_Test_Script_StepTriggerClass.updateSequenceNumberOnDelete(trigger.old);
    }
}