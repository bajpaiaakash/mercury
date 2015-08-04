/*
*@ Class Name                                                    : GLBL_ActionsOnSharingRecords
*@ Description                                                   : Handler Class for handling operations like transfer sharing records when owner of a record changes
*@ CreatedBy                                                     : Jayalakshmi Mohanan Pillai
*@ CreatedOn                                                     : 10-16-2014
*@ Modification Log                                              :                                      
*/

public with sharing class GLBL_ActionsOnSharingRecords {

   // Class Variable
   public static list<GLBL_Form_Template__share> formTempShareList ;
   public list<SObject> SObjList = new list<SObject>();
   
   /* 
          * @Method Name                    :  OnAfterUpdate 
          * @Description                    :  Method invoked after update event 
          * @Return Type                    :  void
          * @Param                          :  list of Sobjects for trigger.new and
                                               Map of id and Sobject for  trigger.oldMap
                                            
   */ 
   public void OnAfterUpdate(List<SObject> newRecs, Map<Id,SObject> oldRecs){  
      if(formTempShareList!=NULL && formTempShareList.size() != 0 ){
            insertShareRecords(formTempShareList);
            
      }
   }

   /* 
          * @Method Name                    :  OnBeforeUpdate 
          * @Description                    :  Method invoked before update event 
          * @Return Type                    :  void
          * @Param                          :  list of Sobjects for trigger.new and
                                               Map of id and Sobject for  trigger.oldMap
                                            
   */ 
   public void OnBeforeUpdate(List<SObject> newRecs, Map<Id,SObject> oldRecs){
      
      system.debug('**** Sharing Records Before Update');
      
      // check for only those records whose owners have changed
      for(Sobject sobj : newRecs){
          if(sobj.get('OwnerID') != OldRecs.get(sobj.id).get('OwnerId')){
              SObjList.add(sobj);
          }       
      }
      
      // Invoke Transfer operation for sharing records to new owner
      if(SobjList.size() != 0){
           transferSharingRecords(SObjList,'GLBL_Form_Template');
      }
      
   }  
   
    
   /* 
          * @Method Name                    :  transferSharingRecords
          * @Description                    :  This Method will called from the trigger on various objects which 
                                               might require transfer of all the manaul sharing records when the owner 
                                               of record changes
          * @Return Type                    :  void
          * @Param                          :  list of Sobjects for which share records have to be created and
                                               String containing the API name of Object 
                                            
   */  
   public void transferSharingRecords(list<SObject> sObjRecs,string objType){
     
     formTempShareList = new  list<GLBL_Form_Template__share>();    
     list<GLBL_Form_Template__c> formTempList = new list<GLBL_Form_Template__c>();
     system.debug('**** Sharing Records transferSharingRecords_FormTemplate' );
     
     //Type casting based on Object API name
     if(objType == 'GLBL_Form_Template'){
         for(SObject sobj : sObjRecs){
            formTempList.add((GLBL_Form_Template__c)sobj);
         }
     }
     
     // Create new share records by looping over the form templates whose owner have changed 
     if(formTempList.size() != 0){
         for(GLBL_Form_Template__share formTempShare: [SELECT id,parentId,accesslevel,rowcause,UserOrGroupId 
                                                     FROM GLBL_Form_Template__share
                                                     WHERE parentId IN : formTempList 
                                                     AND rowcause='manual' ]){           
                
                //creating new share records 
                GLBL_Form_Template__share shareRec = new GLBL_Form_Template__share(UserOrGroupId = formTempShare.UserOrGroupId, 
                                        accesslevel=formTempShare.accesslevel, 
                                        rowcause=formTempShare.rowcause,
                                        parentId=formTempShare.parentId); 
                formTempShareList.add(shareRec); 
                system.debug('Original ShareRecords' + shareRec);                   
         }// end of for loop    
         
      
     }
                         
   }
    
   
   /* 
          * @Method Name                    :  insertShareRecords
          * @Description                    :  This Method will called from the trigger on various objects which 
                                               might require transfer of all the manaul sharing records when the owner 
                                               of record changes
          * @Return Type                    :  void
          * @Param                          :  list of Sobjects for which share records have to be created 
                                            
   */   
   public void insertShareRecords(list<SObject> SObjRecs){
        
      system.debug('**** Sharing Records insertShareRecords' );
        
      //insert the transferred records
      try{      
          insert SObjRecs;
          system.debug('Transferred/Insert share Records' + SObjRecs);
      }catch(DMLException exp){
          system.debug('Exception occured during the insert of sharing records for new owner' + exp);
          GLBL_Error_Log__c errLog = new GLBL_Error_Log__c(Error_Datetime__c= DateTime.Now(),
                                                                     Error_Message__c= exp.getMessage(),
                                                                     Running_User__c = UserInfo.getUserId() ,
                                                                     Stack_Trace__c = exp.getStackTraceString());   
          insert errlog;
    
     }          
    
   }
}