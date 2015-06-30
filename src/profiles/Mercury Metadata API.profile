<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <classAccesses>
        <apexClass>GLBL_GenericRelatedListController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_MeetingDateTimesController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_MeetingParticipantNewEditController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_MeetingTeamManagerController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_ParticipantTovStampHandler</apexClass>
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
    <custom>true</custom>
    <description>For a portal background task that queries the Salesforce Metadata API. SFDC requires the User accessing the Metadata API must have the &quot;Modify All Data&quot; Permission (only available with a full SF license) Created 03/28/2014 by KLorenti, Mavens Consulting</description>
    <fieldPermissions>
        <editable>true</editable>
        <field>Account.Contract_Signatory_MERC__c</field>
        <readable>true</readable>
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
        <field>Meeting_MERC__c.Initiate_Delegate_Management_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_MERC__c.Meeting_Scope_MERC__c</field>
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
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Email_to_Invite_HCP_to_Portal_MERC__c</field>
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
        <field>Meeting_Tasks_MERC__c.Completed_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Evaluate_Rules_MERC__c</field>
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
        <field>Meeting_Tasks_MERC__c.Meeting_Process_Logic_Key_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Open_Task_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Tasks_MERC__c.Task_Status_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Payee_MERC__c.SAP_Vendor_Validation_Required_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Payee_MERC__c.Tax_Id_MERC__c</field>
        <readable>false</readable>
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
        <editable>false</editable>
        <field>Preferences_and_Consent_GLBL__c.Efctv_Start_Dt_GLBL__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Travel_Itinerary_MERC__c.Proposal_Counter_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Travel_Itinerary_MERC__c.Status_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
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
        <layout>Meeting_Participant_MERC__c-MERC_Service Provider</layout>
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
    <loginHours>
        <fridayEnd>1440</fridayEnd>
        <fridayStart>0</fridayStart>
        <mondayEnd>1440</mondayEnd>
        <mondayStart>0</mondayStart>
        <saturdayEnd>1440</saturdayEnd>
        <saturdayStart>0</saturdayStart>
        <sundayEnd>1440</sundayEnd>
        <sundayStart>0</sundayStart>
        <thursdayEnd>1380</thursdayEnd>
        <thursdayStart>0</thursdayStart>
        <tuesdayEnd>1440</tuesdayEnd>
        <tuesdayStart>0</tuesdayStart>
        <wednesdayEnd>1440</wednesdayEnd>
        <wednesdayStart>0</wednesdayStart>
    </loginHours>
    <loginIpRanges>
        <endAddress>255.255.255.255</endAddress>
        <startAddress>0.0.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>23.23.255.255</endAddress>
        <startAddress>23.20.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>24.21.255.255</endAddress>
        <startAddress>24.21.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>50.17.255.255</endAddress>
        <startAddress>50.16.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>50.19.255.255</endAddress>
        <startAddress>50.19.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.87.255.255</endAddress>
        <startAddress>54.80.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.91.255.255</endAddress>
        <startAddress>54.88.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.92.255.255</endAddress>
        <startAddress>54.92.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.92.255.255</endAddress>
        <startAddress>54.92.128.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.159.255.255</endAddress>
        <startAddress>54.144.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.167.255.255</endAddress>
        <startAddress>54.160.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.173.255.255</endAddress>
        <startAddress>54.172.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.175.255.255</endAddress>
        <startAddress>54.174.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.197.255.255</endAddress>
        <startAddress>54.196.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.198.255.255</endAddress>
        <startAddress>54.198.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.205.255.255</endAddress>
        <startAddress>54.204.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.209.255.255</endAddress>
        <startAddress>54.208.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.211.255.255</endAddress>
        <startAddress>54.210.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.221.255.255</endAddress>
        <startAddress>54.221.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.225.255.255</endAddress>
        <startAddress>54.224.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.227.255.255</endAddress>
        <startAddress>54.226.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.235.255.255</endAddress>
        <startAddress>54.234.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.237.255.255</endAddress>
        <startAddress>54.236.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>54.243.255.255</endAddress>
        <startAddress>54.242.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>67.202.63.255</endAddress>
        <startAddress>67.202.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>67.233.255.255</endAddress>
        <startAddress>67.233.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>71.238.255.255</endAddress>
        <startAddress>71.238.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>72.44.63.255</endAddress>
        <startAddress>72.44.32.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>75.101.255.255</endAddress>
        <startAddress>75.101.128.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>107.23.255.255</endAddress>
        <startAddress>107.20.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>173.73.247.89</endAddress>
        <startAddress>173.73.247.89</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>174.129.255.255</endAddress>
        <startAddress>174.129.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>184.72.127.255</endAddress>
        <startAddress>184.72.64.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>184.72.255.255</endAddress>
        <startAddress>184.72.128.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>184.73.255.255</endAddress>
        <startAddress>184.73.0.0</startAddress>
    </loginIpRanges>
    <loginIpRanges>
        <endAddress>204.236.255.255</endAddress>
        <startAddress>204.236.192.0</startAddress>
    </loginIpRanges>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>true</modifyAllRecords>
        <object>Meeting_Process_MERC__c</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <pageAccesses>
        <apexPage>MERC_TravelProposals</apexPage>
        <enabled>false</enabled>
    </pageAccesses>
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
        <visible>false</visible>
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
        <recordType>Travel_Itinerary_MERC__c.MERC_Travel_Proposal</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <userLicense>Salesforce</userLicense>
    <userPermissions>
        <enabled>true</enabled>
        <name>AllowUniversalSearch</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AllowViewKnowledge</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ApiEnabled</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ApiUserOnly</name>
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
        <name>ConnectOrgToEnvironmentHub</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ConvertLeads</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateCustomizeDashboards</name>
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
        <name>CreateDashboardFolders</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateReportFolders</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>DeleteTopics</name>
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
        <name>EditMyDashboards</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditMyReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditOppLineItemUnitPrice</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditOwnQuota</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditPublicDocuments</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditPublicFilters</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditPublicTemplates</name>
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
        <name>ImportLeads</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ImportPersonal</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageCategories</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageContentPermissions</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageCssUsers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageDashbdsInPubFolders</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageNetworks</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageReportsInPubFolders</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageTerritories</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>MassInlineEdit</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>MergeTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ModifyAllData</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>OverrideForecasts</name>
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
        <name>SendSitRequests</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SolutionImport</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SubmitMacrosAllowed</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>TransferAnyEntity</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>TransferAnyLead</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>UseTeamReassignWizards</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewAllData</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewAllForecasts</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewHelpLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewMyTeamsDashboards</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewPublicDashboards</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewPublicReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewSetup</name>
    </userPermissions>
</Profile>
