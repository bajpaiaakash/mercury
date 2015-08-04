/* Class Name  : ACED_CreateProducts
* Description  : Class for creating brand indications from given GSO indication table 
* Created By   : Anil Shivaraj
* Created Date : 
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

Public with sharing class ACED_CreateProducts{


Public string sProductSearch{get;set;}
Public List<ACED_Brand_Indications__c> lBrandIndication {get;set;}
Public List<ACED_Brand_Indications__c> lCurrentBrandIndications {get;set;}
Public string oSelectedBrandIndicationName{get;set;}
Public string oSelectedBrandIndicationGroupId{get;set;}
Public ACED_Brand_Indications__c oCreateBrandIndication{get;set;}
private ACED_Brand_Indications__c oBrandIndications;

    public ACED_CreateProducts(ApexPages.StandardController stdController) {
        this.oBrandIndications= (ACED_Brand_Indications__c )stdController.getRecord();
        lBrandIndication = new List<ACED_Brand_Indications__c>();
        oCreateBrandIndication = new ACED_Brand_Indications__c();
    }
        
    Public void SearchProductcatalog(){
       if(sProductSearch!=null && sProductSearch!='' && sProductSearch.trim()!='' ){
            lBrandIndication = new List<ACED_Brand_Indications__c>();
            lCurrentBrandIndications = new List<ACED_Brand_Indications__c>();
            for (AggregateResult ar : [Select PRODUCT_GROUP_ID_GLBL__C GroupId,Name pName  from Product_Group_GLBL__c where name Like : '%'+sProductSearch+'%' group by PRODUCT_GROUP_ID_GLBL__C,Name limit 10000]) { 
                System.debug('GroupIdGroupIdGroupId: ' + ar.get('GroupId')); 
                System.debug('textField: ' + ar.get('pName'));
                ACED_Brand_Indications__c oBrandIndication = new ACED_Brand_Indications__c();
                oBrandIndication.Name = (String)ar.get('pName');
                oBrandIndication.PRODUCT_GROUP_ID_GLBL__C = (String)ar.get('GroupId');
                lBrandIndication.add(oBrandIndication);
            }
            
            List<List<SObject>> lSoslSearch = [FIND 'map*' IN ALL FIELDS RETURNING ACED_Brand_Indications__c (Name,PRODUCT_GROUP_ID_GLBL__c,Brand__c,Id)];
            List<ACED_Brand_Indications__c> lCurrentBrandIndications = ((List<ACED_Brand_Indications__c>)lSoslSearch[0]);
       }
    }
    
    Public pagereference CreateProductButton(){
        try{
            oCreateBrandIndication.PRODUCT_GROUP_ID_GLBL__c = oSelectedBrandIndicationGroupId;
            oCreateBrandIndication.GSO_Product_Group_Name__c = oSelectedBrandIndicationName;
            Insert oCreateBrandIndication;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Product saved successfully'));
            return new pagereference('/'+oCreateBrandIndication.Id);
        }catch(exception e){
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    Public void ClearGSOLink(){
            oSelectedBrandIndicationGroupId = null;
            oSelectedBrandIndicationName = null;
    }

}