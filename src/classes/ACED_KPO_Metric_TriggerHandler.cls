/* Class Name  : Test_ACED_KPO_Metric_TriggerHandler
* Description  : Test Class for ACED_KPO_Metric_TriggerHandler
* Created By   : Mrudula 
* Created Date : 9/22/2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

public class ACED_KPO_Metric_TriggerHandler{

    public static void createProgramMOTRec(List<ACED_KPO_Metric__c> lNewKPO_Metrics){
        
         set<Id> sProgramIds=new Set<Id>();
         map<string,Id> mExistingProgramMOTKPOMetrics=new map<string,Id>();
         String strExistingProgramMOTs='';
        // map<id,String> mExistingProgramMOTs=new map<id,String>();
         List<ACED_Program_MOT__c> lProgramMOTsTobeInserted=new List<ACED_Program_MOT__c>();
        
         for(ACED_KPO_Metric__c newMetric:[select Asset_Activity__c,Asset_Activity__r.Program__c,KPO__c,KPO__r.MOT__c from ACED_KPO_Metric__c 
                                          where id in:lNewKPO_Metrics]){
              
             sProgramIds.add(newMetric.Asset_Activity__r.Program__c);  
         }
         
         for(ACED_Program_MOT__c existingProgramMOTwithCurrentProgram:[select Program__c,MOT__c from ACED_Program_MOT__c where Program__c in :sProgramIds]){
         
         //creating a map with "Program+Mot" combination as key as this would be unique from the  existing records   
              mExistingProgramMOTKPOMetrics.put(existingProgramMOTwithCurrentProgram.Program__c+'-'+existingProgramMOTwithCurrentProgram.MOT__c,existingProgramMOTwithCurrentProgram.id);
         }
         
         for(ACED_KPO_Metric__c newMetric:[select Asset_Activity__c,Asset_Activity__r.Program__c,KPO__c,KPO__r.MOT__c from ACED_KPO_Metric__c 
                                          where id in:lNewKPO_Metrics]){
             //If the key is not present that means combination not exist then creating the records   
             if(!mExistingProgramMOTKPOMetrics.containskey(newMetric.Asset_Activity__r.Program__c+'-'+newMetric.KPO__r.MOT__c)){                          
                 ACED_Program_MOT__c newPMOT=new ACED_Program_MOT__c(Program__c=newMetric.Asset_Activity__r.Program__c,MOT__c=newMetric.KPO__r.MOT__c);
                 lProgramMOTsTobeInserted.add(newPMOT);
             }
             
         }
         if(!lProgramMOTsTobeInserted.isempty()){
                          
                 Database.SaveResult[] lInsertResults = Database.insert(lProgramMOTsTobeInserted, false); 
                 
                 for(Integer i=0;i<lInsertResults.size();i++){
                     if (!lInsertResults.get(i).isSuccess()){
                        // DML operation failed
                       // Database.Error error = lInsertResults.get(i).getErrors().get(0); 
                        lProgramMOTsTobeInserted.get(i).adderror(label.ACED_ErrorMessage);//failed record from the list
                       // ACED_Utility.createErrorRecord(error.getMessage(),error.getMessage(),userInfo.getName()); 
                        }  }
         }
             
    }
    
}