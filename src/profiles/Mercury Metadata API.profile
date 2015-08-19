<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <classAccesses>
        <apexClass>MERC_AccountDesignatedIndividualsCounter</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_AccountPreferenceRollupManager</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_AccountPreferenceRollupManagerTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_AccountRollups</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_AccountToAccountRollups</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_AnonymiseNonHCPDataHandlerTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_ConsultingProjectCapCalculatorTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_DailyAttendanceController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_DailyAttendanceControllerStressTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_DailyAttendanceControllerTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_HCPContractRollupManager</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_HcpCapActualsCalculator</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_HcpCapActualsCalculatorTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_HcpCapYearlyCalculationJob</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_HcpCapYearlyCalculationJobTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_MeetingParticipantRollups</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_MeetingParticipantStressTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_RegistrationResponsesController</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_TOVCalculator</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_TOVCalculatorTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_TOVNonAggregateCalculatorTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_TOVRoundingTest</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_TestFactory</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <custom>true</custom>
    <description>For a portal background task that queries the Salesforce Metadata API. SFDC requires the User accessing the Metadata API must have the &quot;Modify All Data&quot; Permission (only available with a full SF license) Created 03/28/2014 by KLorenti, Mavens Consulting</description>
    <fieldPermissions>
        <editable>true</editable>
        <field>Account.Heroku_Connect_External_Id_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Account.NIF_Number_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Invoice_MERC__c.Invoice_Received_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_MERC__c.CFT_Meeting_Instructions_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_MERC__c.Local_CMS_Review_Completed_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.CFT_Logistics_Comments_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Contract_Already_Exists_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Existing_Contract_Info_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Participant_MERC__c.Invoice_Received_Date_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Registration_Question_MERC__c.Consulting_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Registration_Question_MERC__c.Delegate_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Registration_Question_MERC__c.Individual_Sponsorship_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Registration_Question_MERC__c.Service_Provider_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Response_MERC__c.Answer_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Response_MERC__c.Meeting_Participant_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Response_MERC__c.Mercury_External_Id_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Response_MERC__c.Response_Text_MERC__c</field>
        <readable>true</readable>
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
        <layout>Meeting_MERC__c-MERC_Consulting_Project</layout>
        <recordType>Meeting_MERC__c.Ad_Hoc_Consulting</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Meeting_MERC__c-MERC_Forecasted_Meeting</layout>
        <recordType>Meeting_MERC__c.Forecasted</recordType>
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
        <layout>PersonAccount-GLBL_HCP Account</layout>
        <recordType>PersonAccount.Contracting_Party_GLBL</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>PersonAccount-GLBL_HCP Account</layout>
        <recordType>PersonAccount.HCP_GLBL</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Registration_Question_MERC__c-MERC_Question_Layout</layout>
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
        <endAddress>76.115.136.255</endAddress>
        <startAddress>76.115.136.0</startAddress>
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
    <pageAccesses>
        <apexPage>MERC_DailyAttendance</apexPage>
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
