<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_sent_to_Approver_to_approve_Test_Execution_record</fullName>
        <description>Email Alert sent to Approver to approve Test Execution record</description>
        <protected>false</protected>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MICO_Templates/MICO_Test_Execution_Approval_Request</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_sent_to_approver_when_approval_request_in_test_execution_is_recalled</fullName>
        <description>Email Alert sent to approver when approval request in test execution is recalled</description>
        <protected>false</protected>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MICO_Templates/MICO_Test_Execution_Recall_Request</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status_to_Open_when_Recalled</fullName>
        <description>MICO: The &quot;Approval Status&quot; field should be set to &quot;Open&quot; when the Test Execution record is recalled from an Approval</description>
        <field>Approval_Status__c</field>
        <literalValue>Open</literalValue>
        <name>Approval Status to Open when Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pending_Approval_Test_Execution</fullName>
        <description>Update the Approval Status field on the Test Execution record to Pending Approval</description>
        <field>Approval_Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Pending Approval Test Execution</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Date_Test_Execution</fullName>
        <description>Update the Approval Date field on the Test Execution record</description>
        <field>Approval_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Approval Date Test Execution</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_Test_Execution</fullName>
        <description>Update the Approval Status field on the Test Execution record</description>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Approval Status Test Execution</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_to_Rejected_Test_Exec</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Approval to Rejected Test Exec</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Recall_Flag_on_Test_Execution</fullName>
        <field>Recall_Flag__c</field>
        <literalValue>0</literalValue>
        <name>Update Recall Flag on Test Execution</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MICO Test Execution Recall Approval Notification</fullName>
        <actions>
            <name>Email_Alert_sent_to_approver_when_approval_request_in_test_execution_is_recalled</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Recall_Flag_on_Test_Execution</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IF( AND( Text(PriorValue(Approval_Status__c))=&quot;Pending Approval&quot;, Text(Approval_Status__c)=&quot;Open&quot;, Recall_Flag__c ),true,false )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MICO Test Execution Send Approval Notification</fullName>
        <actions>
            <name>Email_Alert_sent_to_Approver_to_approve_Test_Execution_record</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MICO_Test__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Pending Approval</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
