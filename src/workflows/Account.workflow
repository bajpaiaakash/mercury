<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Date_Stamp_CAP_Usage_Note_MERC</fullName>
        <description>Date Stamps the CAP Usage note to ensure it&apos;s relevant. Oliver Dunford 9th Nov 2013.</description>
        <field>CAP_Usage_Note_MERC__c</field>
        <formula>TEXT(TODAY()) &amp; &quot;: &quot; &amp;  CAP_Usage_Note_MERC__c &amp;  BR()</formula>
        <name>Date Stamp CAP Usage Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>External_ID_Account_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Calculate_Open_Fees_MERC</fullName>
        <description>Updates the Calculate Open Meeting Fees checkbox to ensure it&apos;s only set once. Oliver Dunford 9th Nov 2013.</description>
        <field>Calculate_Open_Meeting_Fees_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Update Calculate Open Fees</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Date Stamp CAP Usage Note_MERC</fullName>
        <actions>
            <name>Date_Stamp_CAP_Usage_Note_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to date stamp CAP usage note so that it you can judge if it&apos;s relevant or not.</description>
        <formula>AND (NOT ISBLANK( CAP_Usage_Note_MERC__c ),  ISCHANGED(CAP_Usage_Note_MERC__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Mercury External ID-Account</fullName>
        <actions>
            <name>External_ID_Account_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Calculate Open Fees_MERC</fullName>
        <actions>
            <name>Update_Calculate_Open_Fees_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Calculate_Open_Meeting_Fees_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Resets the Calculate Open Fees checkbox once it&apos;s been set.  It should only be triggered once.  Oliver Dunford 9th Nov 2013.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
