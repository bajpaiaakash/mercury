<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_HCP_Contract_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-HCP Contract</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contract_Search_MERC</fullName>
        <description>Updates contract search field with account name and payee. Oliver Dunford 5th Nov 2013.</description>
        <field>Contract_Search_MERC__c</field>
        <formula>Account_MERC__r.FirstName &amp; &quot; &quot; &amp;  Account_MERC__r.LastName &amp; &quot; - &quot; &amp; Payee_MERC__r.Name</formula>
        <name>Update Contract Search</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contract_Sent_Date</fullName>
        <description>Update the Contract Sent Date when HCP Contract is sent for Signature</description>
        <field>Contract_Sent_Date_Time_MERC__c</field>
        <formula>now()</formula>
        <name>Update Contract Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contract_Signature_Date</fullName>
        <description>Updated Datetime when HCP contract signature is received.</description>
        <field>Contract_Signed_Date_Time_MERC__c</field>
        <formula>now()</formula>
        <name>Update Contract Signature Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Contract Sent for Signatrure</fullName>
        <actions>
            <name>Update_Contract_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Stamps datetime when contract is sent for signature : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Contract_Request_Status_MERC__c) &amp;&amp; TEXT(Contract_Request_Status_MERC__c) = &quot;Sent&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Contract Signed by HCP</fullName>
        <actions>
            <name>Update_Contract_Signature_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Stamps datetime when contract is signed by HCP : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Contract_Request_Status_MERC__c) &amp;&amp; TEXT(Contract_Request_Status_MERC__c) = &quot;Completed&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_External ID-HCP Contract</fullName>
        <actions>
            <name>External_ID_HCP_Contract_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>HCP_Contract_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Meeting Contract Search</fullName>
        <actions>
            <name>Update_Contract_Search_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Contract Search Field to ensure searching is efficient : MERC : Created on 11/10/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
