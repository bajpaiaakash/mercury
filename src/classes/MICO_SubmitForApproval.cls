global class MICO_SubmitForApproval
{
    webservice static void SendEmailMethod(Id localId)
    {
        MICO_User_Story__c micoUserStoryObj = [select Submitter__c, approval_status__c from MICO_User_Story__c where id = : localid];
        micoUserStoryObj.approval_status__c = 'Pending Approval';
        micoUserStoryObj.Submitter__c = UserInfo.getUserId();
        try
        {
            update micoUserStoryObj;
        }
        catch (Exception e)
        {
            System.debug('Exception ' + e);
        }
        System.debug('Submitter' + micoUserStoryObj.Submitter__c);
    }
    
    webservice static void SendEmailMethodTestScript(Id localId)
    {
    
        MICO_Test_Templates__c micoTestTemplateObj=[Select Submitter__c,Approval_Status__c from MICO_Test_Templates__c Where id=:localId];
        micoTestTemplateObj.Approval_Status__c='Pending Approval';
        micoTestTemplateObj.Submitter__c=UserInfo.getUserId();
        try{
            update micoTestTemplateObj;
        }
        catch(Exception e){
             System.debug('Exception ' + e);
        }
    }
    webservice static void SendEmailMethodTestExcecution(Id localId)
    {
    
        MICO_Test__c micoTestTemplateObj=[Select Approval_Status__c from MICO_Test__c Where id=:localId];
        micoTestTemplateObj.Approval_Status__c='Pending Approval';
        micoTestTemplateObj.Submitter__c=UserInfo.getUserId();
        try{
            update micoTestTemplateObj;
        }
        catch(Exception e){
             System.debug('Exception ' + e);
        }
    }
}