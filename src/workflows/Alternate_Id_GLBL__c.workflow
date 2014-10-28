<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_Alternate_ID_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Alternate ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Global_ID</fullName>
        <description>Stamps Customer ID from Account</description>
        <field>Account_Global_Id_GLBL__c</field>
        <formula>Account_GLBL__r.Cust_Id_GLBL__c</formula>
        <name>Stamp Global ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_External ID-Alternate ID</fullName>
        <actions>
            <name>External_ID_Alternate_ID_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Alternate_Id_GLBL__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record: MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Set Account Global ID</fullName>
        <actions>
            <name>Stamp_Global_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Account Global Id on Alternate ID when record is created or when Account lookup changes : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISNEW() || ISCHANGED( Account_GLBL__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
