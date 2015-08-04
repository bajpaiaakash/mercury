/****************************************************************************************************************************************** 
 * Class Name   : KS55_Contact_Request_TriggerHandler
 * Description  : This class is used for approver and operations on contact request based on account request hub and business unit.
 * Created By   : Deloitte Consulting
 *
 *****************************************************************************************************************************************/
public with sharing class KS55_Contact_Request_TriggerHandler {

    public static void assignApprovalSettings(List < KS55_Contact_Request__c > lConRequest) {

        map < string, KS55_Approval_Setting__c > mAppMaptoSettings = new map < string, KS55_Approval_Setting__c > ();

        for (KS55_Approval_Setting__c oAppSet: [Select id, Hub__c, Business_Unit__c, Approver__c, Operations__c from KS55_Approval_Setting__c where Approver__c != NULL AND Operations__c != NULL]) {
            if (oAppSet.Hub__c != NULL && oAppSet.Business_Unit__c != NULL) {
                mAppMaptoSettings.put(oAppSet.Hub__c + '-' + oAppSet.Business_Unit__c, oAppSet);
            }
        }


        if (lConRequest.size() > 0) {
            for (KS55_Contact_Request__c oConReq: lConRequest) {
                if (mAppMaptoSettings.containsKey(oConReq.Hub__c + '-' + oConReq.Business_Units__c) && mAppMaptoSettings.get(oConReq.Hub__c + '-' + oConReq.Business_Units__c) != null) {
                    oConReq.Approver__c = mAppMaptoSettings.get(oConReq.Hub__c + '-' + oConReq.Business_Units__c).Approver__c;
                    oConReq.Operations__c = mAppMaptoSettings.get(oConReq.Hub__c + '-' + oConReq.Business_Units__c).Operations__c;
                }
            }
        }
    }
}