/*************************************************************************\
    @ Author        : Deloitte Digital
    @ Date          : 1-Sep-2014
    @ Test Class    : 
    @ Description   : This trigger is created on Project object. This trigger is used to recreate the
                      sharing records
****************************************************************************/

trigger MICO_TriggerProjectRecords on MICO_Project__c (before update,after update) {

   MICO_opProjectRecords opRec_Obj=new MICO_opProjectRecords();
   List<MICO_Project__share>  queriedProjctRecords=new List<MICO_Project__share>();
   
  
        if(Trigger.isUpdate && Trigger.isBefore )
        {
             if(Trigger.New[0].ownerId!=Trigger.Old[0].ownerId)
             {
               queriedProjctRecords=[select id,parentId,accesslevel,rowcause,UserOrGroupId from MICO_Project__share where parentId =:Trigger.New[0].id and rowcause='manual' and UserOrGroupId !=: Trigger.New[0].ownerId ];
                   if(queriedProjctRecords.size()>0)
                   {
                         //sending the queried result to MICO_opProjectRecords class to store in a global list.
                      opRec_Obj.setProjectRecords(queriedProjctRecords);
                   }
             }
             else
             {
               //do nothing
             } 
        }
        if(Trigger.isUpdate && Trigger.isAfter )
        {
         
            //calling insertProjectRecords() method after update to insert the queried result in class MICO_opProjectRecords
           opRec_Obj.insertProjectRecords();
           
        }
}