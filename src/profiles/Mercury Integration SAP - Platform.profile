<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <applicationVisibilities>
        <application>Mercury</application>
        <default>true</default>
        <visible>true</visible>
    </applicationVisibilities>
    <classAccesses>
        <apexClass>GLBL_BaseEditControllerTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GLBL_GenericRelatedListController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_BudgetVersionController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_BudgetVersionControllerTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_CancelDelegateMgmtProcesses</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_ContentVersionHandlerTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_MeetingDateTimesController</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_MeetingParticipantNewEditController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_MeetingProcessLogicHandler</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_MeetingTaskEditorController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_MeetingTeamManagerController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_NewContentControllerTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_ParticipantTovStampHandler</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_TestFactory</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_TimeZoneUtility</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_TravelProposalsController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_TravelProposalsControllerTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_TriggerHandlerStateManager</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <custom>true</custom>
    <description>This profile controls permissions for the integration account utilized by Informatica On Demand &amp; the Invoice-to-SAP integration</description>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.Contract_Signatory_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.Contracting_Party_Change_Reviewed_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.Contracting_Party_Review_Required_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.DI_Validation_Required_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.Designated_Indiv_Validation_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Budget_MERC__c.Total_Budget_Line_items__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_MERC__c.Evaluate_Meeting_Process_Logic_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_MERC__c.Initiate_Delegate_Management_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Meeting_MERC__c.Meeting_Scope_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Meeting_MERC__c.Meeting_Time_Zone_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Account_Name_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Contact_Details_Fax_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Contact_Details_Mobile_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Contact_Details_Work_Phone_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Current_Task_Due_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Current_Task_Name_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Meeting_Participant_MERC__c.Email_to_Invite_HCP_to_Portal_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Evaluate_Meeting_Process_Logic_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Meeting_Process_Logic_Key_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Create_New_Process_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Create_New_Task_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Description_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.First_Travel_Proposal_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Initiate_Delegate_Management_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Meeting_Participant_Key_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Meeting_Participant_Status_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Meeting_Process_Key_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Meeting_Task_Key_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Meeting_Task_Status_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.New_Due_Date_Direction_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.New_Process_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.New_Task_Due_Date_Days_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.New_Task_Due_Date_Relative_to_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.New_Task_Name_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.New_Task_Status_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Process_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Travel_Proposal_Key_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Travel_Proposal_Status_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Update_Existing_Task_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Update_Task_Completed_Date_To_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Update_Task_Due_Date_To_Today_Plus_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Update_Task_Name_To_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Update_Task_Status_From_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Update_Task_Status_To_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_Logic_MERC__c.Veeva_Meeting_Participant_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.HCP_Country_of_Residence_Stamped_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Max_Completed_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Max_Non_Followup_Completed_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Meeting_Process_Logic_Key_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Meeting_Start_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Min_Completed_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Number_of_Cancelled_Tasks_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Number_of_Completed_Tasks_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Number_of_Follow_Up_Tasks_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Number_of_Incomplete_Unresponsive__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Number_of_Tasks_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Number_of_Unresponsive_Tasks_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Process_End_Date__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Process_Start_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Process_Status_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Process_Type_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Unique_MP_Process_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Comments_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Completed_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Due_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Evaluate_Rules_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.HCP_Country_of_Residence_Stamped_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Is_Follow_Up__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Meeting_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Meeting_Participant_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Meeting_Process_Logic_Key_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Mercury_External_Id_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Open_Task_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Process_Type_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Task_Status_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Payee_MERC__c.SAP_Vendor_Last_Validated_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Payee_MERC__c.SAP_Vendor_Validation_Required_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Payee_MERC__c.Tax_Id_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Preferences_and_Consent_GLBL__c.Efctv_Start_Dt_CMS_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Preferences_and_Consent_GLBL__c.Efctv_Start_Dt_Cap_GLBL__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Preferences_and_Consent_GLBL__c.Efctv_Start_Dt_GLBL__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Travel_Itinerary_MERC__c.Evaluate_Meeting_Process_Logic_MERC_c__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Travel_Itinerary_MERC__c.Meeting_Process_Logic_Key_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Travel_Itinerary_MERC__c.Ordering_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Travel_Itinerary_MERC__c.Proposal_Counter_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Travel_Itinerary_MERC__c.Segment_Begin_Timezone_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Travel_Itinerary_MERC__c.Segment_End_Timezone_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Travel_Itinerary_MERC__c.Status_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <layoutAssignments>
        <layout>Budget_MERC__c-MERC_Budget_Active</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Budget_MERC__c-MERC_Budget_Active</layout>
        <recordType>Budget_MERC__c.MERC_Budget_Active</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Budget_MERC__c-MERC_Budget_Archived</layout>
        <recordType>Budget_MERC__c.MERC_Budget_Archived</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Budget_MERC__c-MERC_Budget_Draft</layout>
        <recordType>Budget_MERC__c.MERC_Budget_Draft</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Budget_MERC__c-MERC_Budget_Final</layout>
        <recordType>Budget_MERC__c.MERC_Budget_Final</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_MERC__c-MERC_Active</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_MERC__c-MERC_Active</layout>
        <recordType>Meeting_MERC__c.Meeting_Active</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_MERC__c-MERC_Completed</layout>
        <recordType>Meeting_MERC__c.Completed</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_MERC__c-MERC_Independent_Sponsorship</layout>
        <recordType>Meeting_MERC__c.Independent_Sponsorship</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_MERC__c-MERC_Registered_Meeting</layout>
        <recordType>Meeting_MERC__c.Registered</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Participant_MERC__c-MERC_Consulting</layout>
        <recordType>Meeting_Participant_MERC__c.Consulting</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Participant_MERC__c-MERC_Delegate</layout>
        <recordType>Meeting_Participant_MERC__c.Delegate_MERC</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Participant_MERC__c-MERC_Individual Sponsorship</layout>
        <recordType>Meeting_Participant_MERC__c.Individual_Sponsorship</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Participant_MERC__c-MERC_Service Provider</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Participant_MERC__c-MERC_Service Provider</layout>
        <recordType>Meeting_Participant_MERC__c.Service_Provider_MERC</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Process_Logic_MERC__c-MERC_Meeting_Participant</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Process_Logic_MERC__c-MERC_Meeting_Participant</layout>
        <recordType>Meeting_Process_Logic_MERC__c.MERC_Meeting_Participant</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Process_Logic_MERC__c-MERC_Meeting_Process</layout>
        <recordType>Meeting_Process_Logic_MERC__c.MERC_Meeting_Process</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Process_Logic_MERC__c-MERC_Meeting_Task</layout>
        <recordType>Meeting_Process_Logic_MERC__c.MERC_Meeting_Task</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Process_Logic_MERC__c-MERC_Travel_Proposal</layout>
        <recordType>Meeting_Process_Logic_MERC__c.MERC_Travel_Proposal</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Process_MERC__c-MERC_Meeting_Process</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_Tasks_MERC__c-MERC_Meeting Task Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Payee_MERC__c-MERC_Payee</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>PersonAccount-MERC_Designated Individual</layout>
        <recordType>PersonAccount.Designated_Individual_GLBL</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Preferences_and_Consent_GLBL__c-GLBL_Consent</layout>
    </layoutAssignments>
    <pageAccesses>
        <apexPage>MERC_ActivateBudget</apexPage>
        <enabled>false</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>MERC_FinalizeBudgetConfirm</apexPage>
        <enabled>false</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>MERC_MeetingTaskEditor</apexPage>
        <enabled>false</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>MERC_TravelProposals</apexPage>
        <enabled>false</enabled>
    </pageAccesses>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Budget_MERC__c.MERC_Budget_Active</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Budget_MERC__c.MERC_Budget_Archived</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>true</default>
        <recordType>Budget_MERC__c.MERC_Budget_Draft</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Budget_MERC__c.MERC_Budget_Final</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_MERC__c.Ad_Hoc_Consulting</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_MERC__c.Completed</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>true</default>
        <recordType>Meeting_MERC__c.Forecasted</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_MERC__c.Independent_Sponsorship</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_MERC__c.Meeting_Active</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_MERC__c.Meeting_Program</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_MERC__c.Registered</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_Participant_MERC__c.Consulting</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_Participant_MERC__c.Delegate_MERC</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_Participant_MERC__c.Individual_Sponsorship</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>true</default>
        <recordType>Meeting_Participant_MERC__c.Service_Provider_MERC</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_Process_Logic_MERC__c.MERC_Meeting_Participant</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_Process_Logic_MERC__c.MERC_Meeting_Process</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_Process_Logic_MERC__c.MERC_Meeting_Task</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Meeting_Process_Logic_MERC__c.MERC_Travel_Proposal</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Travel_Itinerary_MERC__c.Air_MERC</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Travel_Itinerary_MERC__c.Bus</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Travel_Itinerary_MERC__c.Car_MERC</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Travel_Itinerary_MERC__c.Hotel_MERC</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Travel_Itinerary_MERC__c.MERC_Travel_Proposal</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>true</default>
        <recordType>Travel_Itinerary_MERC__c.Rail_MERC</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <userLicense>Salesforce Platform</userLicense>
    <userPermissions>
        <enabled>true</enabled>
        <name>ApiEnabled</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AssignTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterFileLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterInternalUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterInviteExternalUsers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterOwnGroups</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateCustomizeFilters</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateCustomizeReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CustomMobileAppsAccess</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>DistributeFromPersWksp</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditEvent</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditTask</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EmailMass</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EmailSingle</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EnableNotifications</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ExportReport</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageContentPermissions</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>MassInlineEdit</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>PasswordNeverExpires</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>RunReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewHelpLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewSetup</name>
    </userPermissions>
</Profile>
