trigger IRIS_Submission_Trigger on IRIS_Submission__c (before update) {
    IRIS_Submission_TriggerHandler.AssignAssessor(Trigger.new, Trigger.oldMap);
}