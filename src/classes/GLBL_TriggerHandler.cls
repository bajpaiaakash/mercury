/**
 * @author Joseph Ferraro
 *
 * Generic handler for Trigger actions, example:
 *
 *   trigger MyTriggerName on MyObjectName (before insert, before update, after update) {
 *       new GLBL_TriggerHandler()
 *           .bind(GLBL_TriggerHandler.Evt.beforeinsert, new ClassThatImplementsGLBL_TriggerHandler.HandlerInterface())
 *           .bind(GLBL_TriggerHandler.Evt.beforeupdate, new ClassThatImplementsGLBL_TriggerHandler.HandlerInterface())
 *           .manage();
 *   }
 *
 */

public class GLBL_TriggerHandler 
{
    /**
     *   Enum representing each of before/after CRUD events on Sobjects
     */
    public enum Evt 
    {
        afterdelete, afterinsert, afterundelete,
        afterupdate, beforedelete, beforeinsert, beforeupdate   
    }

    /*
     *   Simplistic handler to implement on any of the event. It doesn't require or enforces any pattern except the
     *   method name to be "handle()".
     */
    public interface HandlerInterface
    {
        Boolean isActive(); //added to allow developers to toggle handlers on/off, especially useful for unit testing to avoid governor limits
        void handle();
    } 

    //public virtual class BaseHandler implements HandlerInterface
    //{
    //    void handle();
    //    virtual Boolean isActive() {
    //        return true;
    //    }
    //}

    // Internal mapping of handlers
    map<String, list<HandlerInterface>> eventHandlerMapping = new map<String, list<HandlerInterface>>();

    /**
     *   Core API to bind handlers with events
     */
    public GLBL_TriggerHandler bind(Evt event, HandlerInterface eh)
    {
        list<HandlerInterface> handlers = eventHandlerMapping.get(event.name());
        if (handlers == null) 
        {
            handlers = new list<HandlerInterface>();
            eventHandlerMapping.put(event.name(), handlers);
        }
        handlers.add(eh);
        return this;
    }

    /**
     *   Invokes correct handlers as per the context of trigger and available registered handlers
     */
    public void manage()
    {
        Evt ev = null;
        if(trigger.isInsert && trigger.isBefore)
        {
            ev = Evt.beforeinsert;
        }
        else if(trigger.isInsert && trigger.isAfter)
        {
            ev = Evt.afterinsert;
        }
        else if(trigger.isUpdate && trigger.isBefore)
        {
            ev = Evt.beforeupdate;
        }
        else if(trigger.isUpdate && trigger.isAfter)
        {
            ev = Evt.afterupdate;
        }
        else if(trigger.isDelete && trigger.isBefore)
        {
            ev = Evt.beforedelete;
        }
        else if(trigger.isDelete && trigger.isAfter)
        {
            ev = Evt.afterdelete;
        }
        else if(trigger.isundelete)
        {
            ev = Evt.afterundelete;             
        }
        
        list<HandlerInterface> handlers = eventHandlerMapping.get(ev.name());
        
        if (handlers != null && ! handlers.isEmpty()) 
        {
            for (HandlerInterface h : handlers) 
            {
                if (h.isActive())
                    h.handle();
            }
        }
    }
}