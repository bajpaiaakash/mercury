trigger GLBL_Form_Team_Trigger on GLBL_Form_Team__c (after insert, before Delete, before Update, after Update, after Delete) {
    
	if(Trigger.isInsert){	
	    GLBL_Form_Team_TriggerHandler.insertFormShare(trigger.New);
	    GLBL_FormTemplateActionsWithoutSharing.followUnfollowTemplate(trigger.New,Trigger.old,Trigger.oldmap,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete);
	}
	else if(Trigger.isDelete && Trigger.isBefore){	    
    	GLBL_Form_Team_TriggerHandler.deleteFormShare(trigger.old);
	}
	else if(Trigger.isUpdate && Trigger.isAfter){
	    GLBL_FormTemplateActionsWithoutSharing.followUnfollowTemplate(trigger.New,Trigger.old,Trigger.oldmap,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete);
	}
	else if(Trigger.isDelete && Trigger.isAfter){		
	    GLBL_FormTemplateActionsWithoutSharing.followUnfollowTemplate(trigger.New,Trigger.old,Trigger.oldmap,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete);
	}
    

}