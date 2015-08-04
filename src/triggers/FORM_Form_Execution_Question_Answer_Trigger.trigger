trigger FORM_Form_Execution_Question_Answer_Trigger on GLBL_Form_Execution_Question_Answer__c (before insert, before update) {
	
	if (trigger.isBefore) {
		if (trigger.isInsert || trigger.isUpdate) {
			GLBL_Form_Execution_QA_TriggerHandler.scoreAnswers(trigger.new);
		}
	}
}