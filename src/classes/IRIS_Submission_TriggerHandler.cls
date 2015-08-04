/*
*  Classname : Iriss_Submission_Trigger_Helper
*   Created By: Deloitte USI    
*   Created Date: 21-Feb-2014
*   Description: This class is used by trigger Iriss_Submission_AssignApprover to populate COE Assessor when the assessor
                 assigns the submission to himself/herself.
*   Version : 0.1 
*   Change Log
*   Version     Description                         Updated By
*    
*/

public class IRIS_Submission_TriggerHandler
{
    /* 
     * Method name : AssignAssessor
     * Description : This method is used to update the COE Assessor field when the Submission record is accepted 
     *                  and then change the status to in progress.
     * Param - lstSubmission: list of Submissions, oldSubMap: old map of id's and Submissions.
     * Returns :  void
    */
    public static void AssignAssessor(List<IRIS_Submission__c> lstSubmission, Map<Id, IRIS_Submission__c> oldSubMap)
    {
        String newOwnerId;
        String oldOwnerId;
        for(IRIS_Submission__c oSubmission : lstSubmission)
        {
            if(oSubmission.COE_Assessor__c == null)
            {
                newOwnerId = oSubmission.OwnerId;
                oldOwnerId = oldSubMap.get(oSubmission.id).ownerId;
                // update the COE Assessor and the status only when the record is accepted i.e the owner is changed from a queue to COE Assessor
                if(newOwnerId.startsWith('005') && newOwnerId != oldOwnerId)
                {
                    oSubmission.COE_Assessor__c = newOwnerId;
                    oSubmission.Status__c = IRIS_Constants.SUBMISSION_STATUS_IN_PROGRESS;
                }
            }
        }
    }

}