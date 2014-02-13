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
        <fullName>Set_Has_MSA_to_No</fullName>
        <field>Has_MSA_MERC__c</field>
        <literalValue>No</literalValue>
        <name>Set Has MSA to No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Has_MSA_to_No_if_Expired</fullName>
        <description>Set &quot;Has MSA&quot; To No contract expires.</description>
        <field>Has_MSA_MERC__c</field>
        <literalValue>No</literalValue>
        <name>Set Has MSA to No if Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account_MERC__c</targetObject>
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
        <fullName>Update_HAS_MSA_if_Expired</fullName>
        <description>Sets &quot;Has MSA&quot; to No when contract expires</description>
        <field>Has_MSA_MERC__c</field>
        <literalValue>No</literalValue>
        <name>Update HAS MSA if Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_HAS_MSA_to_NO_if_Expired</fullName>
        <field>Has_MSA_MERC__c</field>
        <literalValue>No</literalValue>
        <name>Update HAS MSA to NO if Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Has_MSA</fullName>
        <description>Update &quot;Has MSA&quot; to Yes</description>
        <field>Has_MSA_MERC__c</field>
        <literalValue>Yes</literalValue>
        <name>Update Has MSA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MSA_Expiration_Date</fullName>
        <description>Update MSA Expiration Date from HCP Contract when contract is signed.</description>
        <field>MSA_Expiration_Date_MERC__c</field>
        <formula>MSA_End_Date_MERC__c</formula>
        <name>Update MSA Expiration Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account_MERC__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Expired_MSA</fullName>
        <active>true</active>
        <description>If MSA Contract expires, set Has MSA to No.</description>
        <formula>MSA_End_Date_MERC__c =  Account_MERC__r.MSA_Expiration_Date_MERC__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_HAS_MSA_to_NO_if_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>HCP_Contract_MERC__c.MSA_End_Date_MERC__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Mercury External ID-HCP Contract_MERC</fullName>
        <actions>
            <name>External_ID_HCP_Contract_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>HCP_Contract_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Pull Country of Residence onto Contract_MERC</fullName>
        <active>false</active>
        <formula>TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Country with Country of Residence_MERC</fullName>
        <active>false</active>
        <description>Sets Contract with HCP&apos;s Country of Residence when created. Created 01/16/2014 by KLorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update MSA Info on Account_MERC</fullName>
        <actions>
            <name>Update_Has_MSA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_MSA_Expiration_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update MSA Expiration Date on HCP Account Profile.  Created 02/10/2014 by KLorenti, Mavens Consulting</description>
        <formula>ISPICKVAL(Contract_Request_Status_MERC__c,&quot;Contract Signed&quot;) &amp;&amp;  RecordType.Name = &quot;Master Service Agreement&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Meeting Contract Search_MERC</fullName>
        <actions>
            <name>Update_Contract_Search_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Contract Search Field to ensure searching is efficient. Oliver Dunford 5th Nov 2013.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
