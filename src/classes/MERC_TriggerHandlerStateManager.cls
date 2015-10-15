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
    'CUST_RecordTypeIdLookup',
    'CUST_UserSettingStatusUpdate',
    'GLBL_AccountMergeStampTrigger',
    'GLBL_GlobalIdAccountLookup',
    'MERC_AccountDesignatedIndividualsCounter',
    'MERC_AccountPreferenceRollupManager',
    'MERC_AddressCountryStampTrigger',
    'MERC_AnonymiseNonHCPDataHandler',
    'MERC_CancelDelegateMgmtProcesses',
    'MERC_ConsultingProjectCapCalculator',
    'MERC_ContentVersionHandler',
    'MERC_DeleteNotifyService',
    'MERC_DocusignRecipientStatusHandler',
    'MERC_HandleDocusignAttachmentInsert',
    'MERC_HcpCapActualsCalculator',
    'MERC_HcpCapLimitCalculator',
    'MERC_HCPContractRollupManager',
    'MERC_HotelAllocationCalculator',
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
    'MERC_MergeHistoryStampTriggerHandler',
    'MERC_MergeHistoryStampTriggerHandler',
    'MERC_MVIMeetingTimeZoneHandler',
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