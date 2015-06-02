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
        <fullName>MERC_Update_Contract_Follow_Up_Date</fullName>
        <description>When Contract Status = Sent, Follow Up Date is set to Today + 7 Days.  To be used in SLA Reporting/ CMS Dashboard.</description>
        <field>Contract_Follow_Up_Date_MERC__c</field>
        <formula>IF(ISBLANK( Contract_Sent_Date_MERC__c ), Today() + 7, Contract_Sent_Date_MERC__c + 7)</formula>
        <name>MERC Update Contract Follow Up Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Update_Contract_Sent_Date</fullName>
        <description>Updates the Contract Sent Date based upon the Status of the Contract being set to &apos;Sent&apos;.  This is automatic for DocuSign or manual for paper based processes when the Status is updated to Sent : MERC : Created on 25/02/2015 by Oliver Dunford, Mavens</description>
        <field>Contract_Sent_Date_MERC__c</field>
        <formula>IF(ISBLANK( Contract_Sent_Date_MERC__c ), Today(), Contract_Sent_Date_MERC__c)</formula>
        <name>MERC Update Contract Sent Date</name>
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
        <fullName>MERC Set Contract Dates</fullName>
        <actions>
            <name>MERC_Update_Contract_Follow_Up_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MERC_Update_Contract_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Contract Request Status = Sent, HCP Contract Follow up date is set to Today + 7 Days (to be used in SLA Reporting).  Contract Sent Date is set to today&apos;s date : MERC : Created on 25/02/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Contract_Request_Status_MERC__c) &amp;&amp; TEXT(Contract_Request_Status_MERC__c) = &quot;Sent&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
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
        <formula>ISCHANGED(Contract_Request_Status_MERC__c) &amp;&amp; TEXT(Contract_Request_Status_MERC__c) = &quot;Completed&quot; &amp;&amp; ISNULL(  Contract_Signed_Date_Time_MERC__c )</formula>
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
