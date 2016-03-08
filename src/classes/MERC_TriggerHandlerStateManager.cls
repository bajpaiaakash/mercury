/**
* MERC_TriggerHandlerStateManager
* Created By: Mavens Consulting 
* Description: Used to activate and deactivate triggers.
*/
public with sharing class MERC_TriggerHandlerStateManager {

  // Maps of all handlers and their status.
  public static Map<Type,Boolean> typeToIsActive = new Map<Type,Boolean>();

  /**
  * Passing handler into this will activate it in the typeToIsActive handler mapping.
  * @param Type myType - The handler that is being marked as active.
  */
  public static void activate(Type myType) {
    typeToIsActive.put(myType, true);
  }

  /**
  * Passing handler into this will deactivate it in the typeToIsActive handler mapping.
  * @param Type myType - The handler that is being marked as inactive.
  */
  public static void deactivate(Type myType) {
    typeToIsActive.put(myType, false);
  }

  /**
  * Check if handler is active.
  * @param Type myType - The handler that is being marked as inactive.
  * @return Booelan - Whether the handler is active.
  */
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

  /**
  * Loops through all handlers listed in the static handlers variable and sets all to active.
  */
  public static void activateAll() {
    for (String s : handlers) {
      Type myType = Type.forName(s);
      activate(myType);
    }
  }

  /**
  * Loops through all handlers listed in the static handlers variable and sets all to inactive.
  */
  public static void deactivateAll() {
    for (String s : handlers) {
      Type myType = Type.forName(s);
      deactivate(myType);
    }
  }

  // List of all handlers. Cannot create a list of types, so it is represented as strings.
  static List<String> handlers = new List<String> {
    'CUST_RecordTypeIdLookup',
    'CUST_UserSettingStatusUpdate',
    'GLBL_AccountMergeStampTrigger',
    'GLBL_GlobalIdAccountLookup',
    'MERC_AccountDesignatedIndividualsCounter',
    'MERC_AccountPreferenceRollupManager',
    'MERC_AddressCountryStampTrigger',
    'MERC_AllocatedCapCalculator',
    'MERC_AnonymiseNonHCPDataHandler',
    'MERC_CancelDelegateMgmtProcesses',
    'MERC_ContentVersionHandler',
    'MERC_DeleteNotifyService',
    'MERC_DocusignRecipientStatusHandler',
    'MERC_HandleDocusignAttachmentInsert',
    'MERC_HcpCapActualsCalculator',
    'MERC_HcpCapLimitCalculator',
    'MERC_HCPContractRollupManager',
    'MERC_HotelAllocationCalculator',
    'MERC_HotelPrepopulateHandler',
    'MERC_ItineraryParticipantUpdateTrigger',
    'MERC_InvoiceCurrencyTriggerHandler',
    'MERC_InvoiceLineItemRollupStamp',
    'MERC_InvoiceXmlWriter',
    'MERC_LockedInvoiceDeleteHandler',
    'MERC_LockedRecordHandler',
    'MERC_LookupRollupTriggerHandler',
    'MERC_MeetingCancellationHandler',
    'MERC_MeetingContentStampHandler',
    'MERC_MeetingCurrencyUpdateHandler',
    'MERC_MeetingParticipantCurrencyConvert',
    'MERC_MeetingParticipantTovValidation',
    'MERC_MeetingProcessLogicHandler',
    'MERC_MeetingTOVFinalValidation',    // added by Vijay Garg for US-40195 on 19 Jan 2016
    'MERC_MergeHistoryStampTriggerHandler',
    'MERC_MergeHistoryStampTriggerHandler',
    'MERC_MVIMeetingTimeZoneHandler',
    'MERC_PaidCapCalculator',
    'MERC_ParticipantFMVCalculator',
    'MERC_ParticipantStatusCalculator',
    'MERC_ParticipantTovStampHandler',
    'MERC_ParticipantTriggerHandler',
    'MERC_PrefConsentMappingHandler',
    'MERC_PrimaryAffiliation',    // added by Jyoti Gaur for US-37487 on 13 Oct
    'MERC_PrimaryMeetingOwnerHandler',
    'MERC_TeamMemberDeletePMO',
    'MERC_TeamMemberShareHandler',
    'MERC_TimestampHandler',
    'MERC_TOVCalculator'
  };
}