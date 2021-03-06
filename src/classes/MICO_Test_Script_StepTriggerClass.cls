public with sharing class MICO_Test_Script_StepTriggerClass {
    
    public static void updateSequenceNumberOnInsert(list<MICO_Test_Template_Steps__c> newList) {
        try{
            set<Id> testScriptId = new Set<Id>();
            
            //Get all the Test Script IDs from the Test Script Steps being inserted
            for(MICO_Test_Template_Steps__c testStep : newList){
                testScriptId.add(testStep.Test_Script__c);
            }
            
            //Get all the Test Scripts along with their Test Script Steps
            list<MICO_Test_Templates__c> testScriptList = new list<MICO_Test_Templates__c>([SELECT Id, (SELECT Id FROM MICO_Test_Script_Steps__r) FROM MICO_Test_Templates__c WHERE Id IN :testScriptId]);
            
            //Create a map of Test Script to # of Test Script Steps
            map<Id,Integer> testScriptStepNumberMap = new map<Id,Integer>();
            for(MICO_Test_Templates__c testScript : testScriptList){
                if(testScript.MICO_Test_Script_Steps__r != null){
                    testScriptStepNumberMap.put(testScript.Id,testScript.MICO_Test_Script_Steps__r.size());
                }
                else{
                    testScriptStepNumberMap.put(testScript.Id,0);
                }
            }
            
            //Go through the Test Script Steps again to assign them the latest step #
            for(MICO_Test_Template_Steps__c testStep : newList){
                if(!testScriptStepNumberMap.isEmpty() && testScriptStepNumberMap.containsKey(testStep.Test_Script__c)){
                    Integer i = testScriptStepNumberMap.get(testStep.Test_Script__c);
                    i = i + 1;
                    testStep.Test_Script_Step_Number__c = i;
                    testScriptStepNumberMap.put(testStep.Test_Script__c,i);
                }
                else{
                    testStep.Test_Script_Step_Number__c = 1;
                    testScriptStepNumberMap.put(testStep.Test_Script__c,1);
                }
            }
        }catch(Exception ex){System.debug('>>> Error in MICO_Test_Script_StepTriggerClass\'s updateSequenceNumberOnInsert method. Erorr is :: ' + ex.getMessage());}
    }
    
    
    public static void updateSequenceNumberOnDelete(list<MICO_Test_Template_Steps__c> oldList) {
        try{
            set<Id> testScriptId = new Set<Id>();
            
            //Get all the Test Script IDs from the Test Script Steps being inserted
            for(MICO_Test_Template_Steps__c testStep : oldList){
                testScriptId.add(testStep.Test_Script__c);
            }
            
            //Get all the Test Scripts along with their Test Script Steps
            list<MICO_Test_Templates__c> testScriptList = new list<MICO_Test_Templates__c>([SELECT Id, (SELECT Id, Test_Script_Step_Number__c FROM MICO_Test_Script_Steps__r ORDER BY Test_Script_Step_Number__c) FROM MICO_Test_Templates__c WHERE Id IN :testScriptId]);
            
            //Create a map of Test Script to Test Script Steps
            map<Id,list<MICO_Test_Template_Steps__c>> testScriptToStepsMap = new map<Id,list<MICO_Test_Template_Steps__c>>();
            for(MICO_Test_Templates__c testScript : testScriptList){
                if(testScript.MICO_Test_Script_Steps__r != null){
                    testScriptToStepsMap.put(testScript.Id,testScript.MICO_Test_Script_Steps__r);
                }
                else{
                    list<MICO_Test_Template_Steps__c> tempList = new list<MICO_Test_Template_Steps__c>();
                    testScriptToStepsMap.put(testScript.Id,tempList);
                }
            }
            
            //Now iterate over Deleted steps to rearrange the Step # for remaining steps
            list<MICO_Test_Template_Steps__c> stepsToBeUpdated = new list<MICO_Test_Template_Steps__c>();
            for(MICO_Test_Template_Steps__c testStep : oldList){
                if(!testScriptToStepsMap.isEmpty() && testScriptToStepsMap.containsKey(testStep.Test_Script__c)){
                    for(MICO_Test_Template_Steps__c tempStep : testScriptToStepsMap.get(testStep.Test_Script__c)){
                        if(testStep.Test_Script_Step_Number__c < tempStep.Test_Script_Step_Number__c ){
                            tempStep.Test_Script_Step_Number__c = tempStep.Test_Script_Step_Number__c - 1;
                            stepsToBeUpdated.add(tempStep);
                        }
                    }
                }
            }
            
            //UPDATE the step numbers on the remaining Test Script Steps
            if(stepsToBeUpdated.size() > 0)
                update stepsToBeUpdated;
        }catch(Exception ex){System.debug('>>> Error in MICO_Test_Script_StepTriggerClass\'s updateSequenceNumberOnDelete method. Erorr is :: ' + ex.getMessage());}      
    }
}