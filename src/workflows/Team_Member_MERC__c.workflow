<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Team_Member_Notification_MERC</fullName>
        <ccEmails>oliver@mavensconsulting.com</ccEmails>
        <description>Send Team Member Notification</description>
        <protected>false</protected>
        <recipients>
            <field>User_MERC__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Mercury_Email_Templates_MERC/New_Team_Member_Notification_MERC</template>
    </alerts>
    <fieldUpdates>
        <fullName>External_ID_Team_Member_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Team Member</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Mercury External ID-Team Member</fullName>
        <actions>
            <name>External_ID_Team_Member_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Team_Member_MERC__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Mercury Users,Non-Mercury Users</value>
        </criteriaItems>
        <description>Populates the external id upon creation of a record with format Orid_ID</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Team Member Notification_MERC</fullName>
        <actions>
            <name>Send_Team_Member_Notification_MERC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Ensures each new Team Member is notified that they have been added to the meeting team.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
