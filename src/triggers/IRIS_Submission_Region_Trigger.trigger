trigger IRIS_Submission_Region_Trigger on IRIS_Submission_Region__c (after delete, after update) {
    if(IRIS_Submission_Region_Trigger_Helper.hasTakenCareOf != true){
        IRIS_Submission_Country_Trigger_Helper.hasTakenCareOf = true;
        if(Trigger.isAfter && Trigger.isUpdate){
            new IRIS_Submission_Region_Trigger_Helper().updateRegionTextField(Trigger.new , Trigger.oldMap);
        }
        if(Trigger.isAfter && Trigger.isDelete){
            new IRIS_Submission_Region_Trigger_Helper().removeRegionTextField(Trigger.old);
        }
    }
}