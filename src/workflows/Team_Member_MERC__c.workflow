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
    <outboundMessages>
        <fullName>RTI_Team_Member_Updated</fullName>
        <apiVersion>29.0</apiVersion>
        <endpointUrl>http://ec2-54-227-9-128.compute-1.amazonaws.com/rti-development/v1/genericUpdated</endpointUrl>
        <fields>Access_MERC__c</fields>
        <fields>Account_External_MERC__c</fields>
        <fields>Account_MERC__c</fields>
        <fields>Attendee_Invite_Limit_MERC__c</fields>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>CurrencyIsoCode</fields>
        <fields>Id</fields>
        <fields>IsDeleted</fields>
        <fields>LastModifiedById</fields>
        <fields>LastModifiedDate</fields>
        <fields>LastReferencedDate</fields>
        <fields>LastViewedDate</fields>
        <fields>Meeting_External_MERC__c</fields>
        <fields>Meeting_MERC__c</fields>
        <fields>Mercury_External_Id_MERC__c</fields>
        <fields>Name</fields>
        <fields>OwnerId</fields>
        <fields>RecordTypeId</fields>
        <fields>Role_MERC__c</fields>
        <fields>Sales_Rep_Country_Code_MERC__c</fields>
        <fields>SystemModstamp</fields>
        <fields>User_MERC__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>helmer@gso1.lly</integrationUser>
        <name>RTI - Team Member Updated</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Mercury External ID-Team Member_MERC</fullName>
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
        <criteriaItems>
            <field>Team_Member_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record with format Orid_ID</description>
        <triggerType>onAllChanges</triggerType>
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
    <rules>
        <fullName>RTI - Team Member Updated</fullName>
        <actions>
            <name>RTI_Team_Member_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISCHANGED( RTI_Transaction_ID_MERC__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
