/* Class Name  : ACED_Delivery_Actual_Line_TriggFunctions
* Description  : Class to update delivery actuals
* Created By   : Anil Shivaraj
* Created Date : 8/25/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/


Public class ACED_Delivery_Actual_Line_TriggFunctions{

Public static void UpdateDeliveryActualWithPrimaryAttributes(List<ACED_Delivery_Actual_Line__c> lDeliveryActualLines){
    List<ACED_Delivery_Actuals__c> lDeliveryActual = new List<ACED_Delivery_Actuals__c>();
    Set<Id> sDuplicateCheck = new Set<Id>();
    for(ACED_Delivery_Actual_Line__c sDeliveryLines : lDeliveryActualLines){
        if(sDeliveryLines.Actual__c == sDeliveryLines.Attribute__c && !sDuplicateCheck.contains(sDeliveryLines.Delivery_Actuals__c)){
            lDeliveryActual.add(new ACED_Delivery_Actuals__c( id = sDeliveryLines.Delivery_Actuals__c,Value__c=sDeliveryLines.Value__c)); 
            sDuplicateCheck.add(sDeliveryLines.Delivery_Actuals__c);               
        }
    }
    
    Update lDeliveryActual;

}

}