/*************************************************************************\
    @ Author        : Nitish Kumar
    @ Date          : 22-Aug-2014
    @ Test Class    : 
    @ Description   : This trigger on Attachment will be used to stop the deletion of Attachment 
                      if the Test Script has been appproved.
****************************************************************************/
trigger MICO_AttachmentTrigger on Attachment(before delete) {

    //local variables
    set < Id > setTestScriptStep = new set < Id > ();
    map < Id, Attachment > mapTestScriptStep = new map < Id, Attachment > ();

    set < Id > setTestExecution = new set < Id > ();
    map < Id, Attachment > mapTestExecution = new map < Id, Attachment > ();

    set < Id > setTestExecutionStep = new set < Id > ();
    map < Id, Attachment > mapTestExecutionStep = new map < Id, Attachment > ();

    for (Attachment att: trigger.old) {
        //Check if uploaded attachment is related to Test Script Step Attachment  
        if (att.ParentId.getSobjectType() == MICO_Test_Template_Steps__c.SobjectType) {
            setTestScriptStep.add(att.ParentId);
            mapTestScriptStep.put(att.ParentId, att);
        }

        //Check if uploaded attachment is related to Test Execution Attachment  
        if (att.ParentId.getSobjectType() == MICO_Test__c.SobjectType) {
            setTestExecution.add(att.ParentId);
            mapTestExecution.put(att.ParentId, att);
        }

        //Check if uploaded attachment is related to Test Execution Step Attachment  
        if (att.ParentId.getSobjectType() == MICO_Test_Steps__c.SobjectType) {
            setTestExecutionStep.add(att.ParentId);
            mapTestExecutionStep.put(att.ParentId, att);
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            // Call the utility function

            //checking the set size
            if (setTestScriptStep.size() > 0)
                MICO_AttachmentTriggerUtility.checkAttachmentonTSStep(setTestScriptStep, mapTestScriptStep);

            //checking the set size
            if (setTestExecution.size() > 0)
                MICO_AttachmentTriggerUtility.checkAttachmentonTExecution(setTestExecution, mapTestExecution);

            //checking the set size
            if (setTestExecutionStep.size() > 0)
                MICO_AttachmentTriggerUtility.checkAttachmentonTExecutionStep(setTestExecutionStep, mapTestExecutionStep);

        }
    }
}