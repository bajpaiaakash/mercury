/**
 * @author Joseph Ferraro
 *
 * Service which notifies the Real-Time Integration listener of deletes
 */

public with sharing class MERC_DeleteNotifyService implements GLBL_TriggerHandler.HandlerInterface {
	
	public void handle() {
		List<Sobject> sobjects = Trigger.old;
		String sobjectTypeAPIName = MERC_Util.getSobjectAPIName(sobjects.get(0));
		String serializedSobjects = Json.serialize(sobjects); 
		//we need to send primitives because execute method is @future
		MERC_DeleteNotifyService.execute(sobjectTypeAPIName, serializedSobjects);
	}

	@Future(callout=true)
	public static void execute(String sobjectType, String serializedSobjects) {
		DeleteNotification notification = new DeleteNotification(sobjectType, serializedSobjects);
		String jsonstring = Json.serialize(notification); 
		system.debug(jsonstring);

		HttpRequest r = new HttpRequest();
		r.setHeader('Content-type', 'text/json');
		r.setEndpoint('http://ec2-54-227-9-128.compute-1.amazonaws.com/rti-development/v1/genericDeleted');
		r.setMethod('POST');
		r.setBody(jsonstring);

		Http h = new Http();
		HttpResponse response = h.send(r);
		system.debug(response.getBody());
	}

	public class DeleteNotification {
		public String notificationId;
		public String sobjectTypeAPIName;
		public List<Sobject> records;
		public DeleteNotification(String sobjectType, String serializedSobjects) {
			this.notificationId = MERC_Util.generateRandomString(30);
			this.records = (List<Sobject>)JSON.deserialize(serializedSobjects, List<Sobject>.class); //we need to deserialize here to ensure "records" is not double encoded before we send to listener
			this.sobjectTypeAPIName = sobjectType;
		}
	}
}