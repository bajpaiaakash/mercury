<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <applicationVisibilities>
        <application>Mercury</application>
        <default>false</default>
        <visible>true</visible>
    </applicationVisibilities>
    <custom>true</custom>
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
        <field>Meeting_Participant_MERC__c.Contact_Details_Fax_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Meeting_Participant_MERC__c.Contact_Details_Mobile_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Meeting_Participant_MERC__c.Contact_Details_Work_Phone_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Evaluate_Rules_MERC__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_Process_MERC__c.Max_Completed_Date_MERC__c</field>
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
        <field>Meeting_Tasks_MERC__c.Task_Status_MERC__c</field>
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
    <loginIpRanges>
        <endAddress>255.255.255.255</endAddress>
        <startAddress>0.0.0.0</startAddress>
    </loginIpRanges>
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
    <userLicense>Salesforce Platform</userLicense>
    <userPermissions>
        <enabled>true</enabled>
        <name>AllowUniversalSearch</name>
    </userPermissions>
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
