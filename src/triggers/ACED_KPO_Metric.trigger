/*****************************************************************************************
    Name           : ACED_KPO_Metric
    Description    : This is the trigger on KPO Metric object to associate MOT on parent KPO object to Program Object 
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description     
---------------------------------------------------------------------------
Mrudula Konnoju       11/09/2014          Created
---------------------------------------------------------------------------
History Log:

******************************************************************************************/

trigger ACED_KPO_Metric on ACED_KPO_Metric__c (after insert,after update) {
            
     //Calling the trigger method for after insert and after update of KPO metric object to associate MOT on parent KPO object to Program Object
     ACED_KPO_Metric_TriggerHandler.createProgramMOTRec(trigger.new);   

}