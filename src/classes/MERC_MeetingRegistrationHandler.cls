/*
*   MERC_MeetingRegistrationHandler
*   Authors: David Helmer
*/
public class MERC_MeetingRegistrationHandler implements GLBL_TriggerHandler.HandlerInterface {
    public Boolean isActive(){
        return MERC_TriggerHandlerStateManager.isActive(MERC_MeetingRegistrationHandler.class);
    }

    public void handle(){

    }
}