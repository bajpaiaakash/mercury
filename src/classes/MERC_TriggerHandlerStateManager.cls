public with sharing class MERC_TriggerHandlerStateManager {

	public static Map<Type,Boolean> typeToIsActive = new Map<Type,Boolean>();

	public static void activate(Type myType) {
		typeToIsActive.put(myType, true);
	}

	public static void deactivate(Type myType) {
		typeToIsActive.put(myType, false);
	}

	public static Boolean isActive(Type myType) {
		try {
			if (typeToIsActive.get(myType) == null) {
				return true;
			} else {
				return typeToIsActive.get(myType);
			}
		} catch (Exception e) {
			return true;
		}
	}

	public static void activateAll() {
		for (String s : handlers) {
			Type myType = Type.forName(s);
			activate(myType);
		}
	}

	public static void deactivateAll() {
		for (String s : handlers) {
			Type myType = Type.forName(s);
			deactivate(myType);
		}
	}

	//we cant seem to create a list of types, so the string representations will have to do
	static List<String> handlers = new List<String> {
		'MERC_HcpCapLimitCalculator',
		'MERC_AccountDesignatedIndividualsCounter',
		'MERC_LockedRecordHandler',
		'MERC_TimestampHandler',
		'MERC_HcpCapActualsCalculator',
		'MERC_DeleteNotifyService',
		'MERC_MeetingCancellationHandler',
		'MERC_PrimaryMeetingOwnerHandler',
		'MERC_AnonymiseNonHCPDataHandler',
		'MERC_ParticipantTriggerHandler',
		'MERC_ParticipantFMVCalculator',
		'MERC_TOVCalculator',
		'MERC_MeetingCurrencyUpdateHandler',
		'MERC_MergeHistoryStampTriggerHandler'
	};
}