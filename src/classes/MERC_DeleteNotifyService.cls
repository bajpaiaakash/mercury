/**
 * @author Joseph Ferraro
 *
 * Service which notifies the Real-Time Integration listener of deletes.
 * Updated: SHH
 */

public with sharing class MERC_DeleteNotifyService implements GLBL_TriggerHandler.HandlerInterface {

	public static Boolean skipCallout = false;

	public Boolean isActive() {
	    return MERC_TriggerHandlerStateManager.isActive(MERC_DeleteNotifyService.class);
	}

	public void handle() {
		List<Sobject> sobjects = Trigger.old;
		String sobjectTypeAPIName = MERC_Util.getSobjectAPIName(sobjects.get(0));
		String serializedSobjects = Json.serialize(sobjects);
		String sessionId = UserInfo.getSessionId();
		//we need to send primitives because execute method is @future
		if (!MERC_DeleteNotifyService.skipCallout)
			MERC_DeleteNotifyService.execute(sobjectTypeAPIName, serializedSobjects, sessionId);
	}

	@Future(callout=true)
	public static void execute(String sobjectType, String serializedSobjects, String sessionId) {
		//as of 29.0, Apex does not like Test.setMock when used with callouts in triggers via @future
		//we will test notifyRTI separately
		if (!Test.isRunningTest()) {
			sendDeletesToRTI(sobjectType, serializedSobjects, sessionId);
		}
	}

	public static void sendDeletesToRTI(String sobjectType, String serializedSobjects, String sessionId) {
		DeleteNotification notification = new DeleteNotification(sobjectType, serializedSobjects, sessionId);
		String jsonstring = Json.serialize(notification);
		system.debug(jsonstring);

		Mercury_Settings_MERC__c settings = Mercury_Settings_MERC__c.getOrgDefaults();
		HttpRequest r = new HttpRequest();
		r.setHeader('Content-type', 'text/json');
		r.setEndpoint(settings.MVI_Service_Endpoint_MERC__c);
		r.setMethod('POST');
		r.setBody(jsonstring);

		Http h = new Http();
		HttpResponse response = h.send(r);
		system.debug(response.getBody());
	}

	public class DeleteNotification {
		String notificationId;
		String orgId;
		String sessionId;
		String sobjectTypeAPIName;
		String instanceUrl;
		List<Sobject> records;
		public DeleteNotification(String sobjectType, String serializedSobjects, String sessionId) {
			this.notificationId = MERC_Util.generateRandomString(30);
			this.records = (List<Sobject>)JSON.deserialize(serializedSobjects, List<Sobject>.class); //we need to deserialize here to ensure "records" is not double encoded before we send to listener
			this.sobjectTypeAPIName = sobjectType;
			this.orgId = UserInfo.getOrganizationId();
			this.sessionId = sessionId;
			this.instanceUrl = 'https://' + System.URL.getSalesforceBaseURL().getHost();
		}
	}
}