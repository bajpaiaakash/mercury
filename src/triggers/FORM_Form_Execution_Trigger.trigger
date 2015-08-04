trigger FORM_Form_Execution_Trigger on GLBL_Form_Execution__c (after insert) {
    
    if(Trigger.isInsert){	
        GLBL_Form_Execution_TriggerHandler.insertFormExecutionShare( trigger.New );
    }
}