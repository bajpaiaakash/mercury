/*
*@ Trigger Name                                                  : FORM_FormTemplate_trigger
*@ Description                                                   : Trigger on Form Template , Works on event update(before & after)
*@ CreatedBy                                                     : Jayalakshmi Mohanan Pillai
*@ CreatedOn                                                     : 10-16-2014
*@ Modification Log                                              :                                      
*/
trigger FORM_FormTemplate_trigger on GLBL_Form_Template__c (after update, before update) {
    
    GLBL_ActionsOnSharingRecords handler = new GLBL_ActionsOnSharingRecords();
    
    // On Before Event
    if(Trigger.isBefore){
    	if(Trigger.isUpdate){ // On Before Update
    		handler.OnBeforeUpdate(Trigger.new,Trigger.oldMap);
    	}
    }
    
    //On After Event
    if(Trigger.isAfter){ 
    	if(Trigger.isUpdate){ // On After Update
    		handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    	}
    }

}