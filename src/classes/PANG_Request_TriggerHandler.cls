/****************************************************************************************************************************************** 
* Class Name   : PANG_RWEFinalDeliverablesList 
* Description  : Class to get the List of Contents associated to a Request Record
* Created By   : Deloitte Consulting
* 
*****************************************************************************************************************************************/
Public with sharing class PANG_Request_TriggerHandler {


    /* 
    * @Method Name                    :  insertRequestMoleculesFromStudy
    * @Description                    :  Method to Insert Request Molecules from Study
    * @Return Type                    :  void
    * @Parameters                     :  lRequests
    */     
    Public static void insertRequestMoleculesFromStudy(list < PANG_Request__c > lRequests) {

        //Adding all study IDs to a set
        set < id > sStudyIDs = New set < id > ();

        for (PANG_Request__c oReq: lRequests) {
            if (oReq.Related_Project__c != NULL) {
                sStudyIDs.add(oReq.Related_Project__c);
            }
        }

        //Declaring a map of Study to its associated Molecules
        Map < id, list < PANG_RWE_Study_Molecule__c >> lMapOfStudyAndItsMolecules = new Map < id, list < PANG_RWE_Study_Molecule__c >> ();

        //Adding all the molecules assocaited to studies to a list    
        List < PANG_RWE_Study_Molecule__c > lMolecules = [SELECT RWE_Molecule__c, Project__c, Therapeutic_Area_Primary__c from PANG_RWE_Study_Molecule__c Where Project__c in : sStudyIDs];

        //Constructing the Map of Study to its associated Molecules
        If(lMolecules.size() > 0) {
            for (PANG_RWE_Study_Molecule__c oMol: lMolecules) {
                List < PANG_RWE_Study_Molecule__c > tempMolList = new List < PANG_RWE_Study_Molecule__c > ();
                if (lMapOfStudyAndItsMolecules.get(oMol.Project__c) != NULL) {
                    tempMolList = lMapOfStudyAndItsMolecules.get(oMol.Project__c);
                    tempMolList.add(oMol);
                } else {
                    tempMolList.add(oMol);
                }
                lMapOfStudyAndItsMolecules.put(oMol.Project__c, tempMolList);
            }
        }

        //Declaring a list of request molecules to be inserted     
        list < PANG_RWE_Request_Molecule__c > lRequestMolecules = new list < PANG_RWE_Request_Molecule__c > ();

        //looping over requests that are inserted and adding request molecules 
        for (PANG_Request__c oReq: lRequests) {           
              lRequestMolecules = new list < PANG_RWE_Request_Molecule__c > ();   
              if (oReq.Related_Project__c != NULL && lMapOfStudyAndItsMolecules.containskey(oReq.Related_Project__c) && lMapOfStudyAndItsMolecules.get(oReq.Related_Project__c)!=null) {
                PANG_Project__c oProj = [Select Id, Therapeutic_Area_Primary__c from PANG_Project__c where Id =: oReq.Related_Project__c LIMIT 1];
                system.debug('###'+oProj.Therapeutic_Area_Primary__c+'888'+oReq.Therapeutic_Area_Primary__c);
                if(oReq.Therapeutic_Area_Primary__c == oProj.Therapeutic_Area_Primary__c){
                list < PANG_RWE_Study_Molecule__c > lMolOnStudy = new list < PANG_RWE_Study_Molecule__c > ();
                lMolOnStudy = lMapOfStudyAndItsMolecules.get(oReq.Related_Project__c);
                If(lMolOnStudy.size() > 0) {
                    for (PANG_RWE_Study_Molecule__c oMolecule: lMolOnStudy) {
                        PANG_RWE_Request_Molecule__c oReqMol = new PANG_RWE_Request_Molecule__c();
                        oReqMol.RWE_Molecule__c = oMolecule.RWE_Molecule__c;
                        oReqMol.RWE_Request__c = oReq.id;
                        oReqMol.Therapeutic_Area_Primary__c = oMolecule.Therapeutic_Area_Primary__c;
                        lRequestMolecules.add(oReqMol);
                    }
                }
            }
        
    }
    }
            //Inserting the request molecules
        If(lRequestMolecules.size() > 0){
           insert lRequestMolecules;
        }
     
    }
    
     /* 
    * @Method Name                    :  UpdateRequestRegion
    * @Description                    :  Method to Insert Region from Study
    * @Return Type                    :  void
    * @Parameters                     :  lRequest
    */   
    Public static void UpdateRequestRegion(List<PANG_Request__c> lRequest){
        Set<Id> sStudyIds = new Set<Id>();
        Map<Id,Recordtype> mRequestRecordTypes = New Map<Id,Recordtype>([SELECT DeveloperName, Id, SobjectType FROM RecordType where SobjectType  ='PANG_Request__c']);
        for(PANG_Request__c oRequest : lRequest){
            if(oRequest.Related_Project__c!=null)
                sStudyIds.add(oRequest.Related_Project__c);
        }    
        
        Map<Id,PANG_Project__c> mStudyDetails = new Map<Id,PANG_Project__c>([SELECT Id, Region__c FROM PANG_Project__c where Id in : sStudyIds]);

        
        for(PANG_Request__c oRequest : lRequest){
            if(oRequest.Related_Project__c!=null && mRequestRecordTypes.containskey(oRequest.recordtypeId) && 
                    mStudyDetails!=null && mStudyDetails.containskey(oRequest.Related_Project__c) && mStudyDetails.get(oRequest.Related_Project__c).region__c!=null
                         && (mRequestRecordTypes.get(oRequest.recordtypeId).developername == 'EXPERT_Review' ||
                        mRequestRecordTypes.get(oRequest.recordtypeId).developername == 'EXPERT_or_ACT_Consultation' ||
                        mRequestRecordTypes.get(oRequest.recordtypeId).developername == 'Datamart_Scientific_Consultation' ||
                        mRequestRecordTypes.get(oRequest.recordtypeId).developername == 'RWE_Strategic_Consultation' ||
                        mRequestRecordTypes.get(oRequest.recordtypeId).developername == 'Data_Sourcing') ){
                oRequest.region__c = mStudyDetails.get(oRequest.Related_Project__c).region__c;
               }        
        }
    }
}