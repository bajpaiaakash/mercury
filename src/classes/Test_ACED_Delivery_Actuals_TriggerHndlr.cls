@isTest(SeeAllData=false)
public class Test_ACED_Delivery_Actuals_TriggerHndlr{

    static testMethod void createDeliveryActuals() {    
       User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');            
       System.runAs(runAsUser) {
           Test.startTest(); 
               List<ACED_Delivery_Actuals__c> lineActuals = new List<ACED_Delivery_Actuals__c>();   
               List<ACED_Deliveries__c> ldelActs = ACED_DataFactory.createDeliveries(100);
               Set<Id> delActualIds = new Set<Id>(); 
               for(ACED_Deliveries__c del : ldelActs){
                ACED_Delivery_Actuals__c DelAct = New ACED_Delivery_Actuals__c();
                DelAct.Delivery__c=del.Id;       
                lineActuals.add(DelAct);
               }
               for(ACED_Deliveries__c delActLine : ldelActs){
                    delActualIds.add(delActLine.Id);
               } 
               insert lineActuals;
               List<ACED_Delivery_Actuals__c> insertedLineActuals = [Select Id,Delivery__r.Activity__r.Assets__c, Month__c, Delivery__r.Activity__r.program__r.Year__c from ACED_Delivery_Actuals__c];
               ACED_Delivery_Actuals_TriggerHandler.UpsertAggregatedAssetActuals(insertedLineActuals);
               delete [Select id from ACED_Delivery_Actuals__c where id in : delActualIds];            
               //Assert deletion successful
               system.assert([Select id from ACED_Delivery_Actuals__c where id in : delActualIds].size()==0); 
           Test.stopTest();   
        }  
    }
    
    static testMethod void deleteDeliveryActuals() {    
       User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');            
       System.runAs(runAsUser) {
           Test.startTest(); 
               List<ACED_Delivery_Actual_Line__c> ldelActs = ACED_DataFactory.createDeliveryActualLines(100); 
               ACED_Asset_Actual__c AssetAct = New ACED_Asset_Actual__c();        
               AssetAct.Asset__c= [Select Id from ACED_Asset__c LIMIT 1].Id;
               AssetAct.Month__c='March'; 
               AssetAct.Value__c=10;
               AssetAct.Year__c = string.valueof(system.now().year());
               insert AssetAct;
               
               Set<Id> delActualIds = new Set<Id>(); 
               for(ACED_Delivery_Actual_Line__c delActLine : ldelActs){
                    delActualIds.add(delActLine.Delivery_Actuals__c);
               } 
               ACED_Delivery_Actuals_TriggerHandler.DeleteAssetActualsonAsset([Select  Id,value__c,Delivery__r.Activity__r.Assets__c, Month__c, Delivery__r.Activity__r.program__r.Year__c from ACED_Delivery_Actuals__c]);
               delete [Select id from ACED_Delivery_Actuals__c where id in : delActualIds];            
               //Assert deletion successful
               system.assert([Select id from ACED_Delivery_Actuals__c where id in : delActualIds].size()==0); 
           Test.stopTest();   
        }  
    }
    
}