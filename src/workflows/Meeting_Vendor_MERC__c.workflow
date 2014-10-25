<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Clear_Confirm_ToV_Change_MERC</fullName>
        <description>Clear the Confirm ToV Change checkbox after each record update.</description>
        <field>Confirm_ToV_Reporting_Change_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Clear Confirm ToV Change_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>External_ID_MeetingVendor_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-MeetingVendor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Vendor_Search_MERC</fullName>
        <description>Updates the Vendor Search field to ensure the record is searchable.</description>
        <field>Vendor_Search_MERC__c</field>
        <formula>Account_MERC__r.Name &amp; &quot; - &quot; &amp;  Meeting_MERC__r.Name</formula>
        <name>Update Vendor Search</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Clear Confirm ToV Change</fullName>
        <actions>
            <name>Clear_Confirm_ToV_Change_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Confirm ToV Change checkbox after each record update : MERC : Created on 12/5/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>Confirm_ToV_Reporting_Change_MERC__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_External ID-MeetingVendor</fullName>
        <actions>
            <name>External_ID_MeetingVendor_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Vendor_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Meeting Vendor Search</fullName>
        <actions>
            <name>Update_Vendor_Search_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Vendor Search field to ensure Meeting Vendors are searchable : MERC : Created on 04/01/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
