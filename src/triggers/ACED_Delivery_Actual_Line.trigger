/*****************************************************************************************
    Name           : ACED_Delivery_Actual_Line
    Description    : This is the trigger on Delivery actual line object to update delivery actuals with primary attribute values 
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Goutham Ramireddy     09/09/2014          Created
---------------------------------------------------------------------------
History Log:

******************************************************************************************/

trigger ACED_Delivery_Actual_Line on ACED_Delivery_Actual_Line__c (after Update,after insert) {
    //Calling the method for after insert and after update of delivery actual line to update delivery actuals with primary attribute values
    ACED_Delivery_Actual_Line_TriggFunctions.UpdateDeliveryActualWithPrimaryAttributes(trigger.new);
}