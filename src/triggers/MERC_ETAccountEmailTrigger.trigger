trigger MERC_ETAccountEmailTrigger on Account (after update) {

    MERC_ETAccountEmailTriggerImpl impl = new MERC_ETAccountEmailTriggerImpl();
    
    if (trigger.isAfter) {
        if (trigger.isUpdate) {
            impl.doAfterUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
        }
    }
}