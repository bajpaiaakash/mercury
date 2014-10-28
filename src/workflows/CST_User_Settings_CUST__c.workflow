<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_status_to_Expired_CUST</fullName>
        <description>Sets the status from pending to expired</description>
        <field>Access_Status_CUST__c</field>
        <literalValue>Expired</literalValue>
        <name>Set status to Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Manager_CUST</fullName>
        <description>Update the User&apos;s Manager</description>
        <field>Manager_Global_ID_CUST__c</field>
        <formula>CST_User_CUST__r.CST_Approver_ID_GLBL__c</formula>
        <name>Update Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>User_Settings_Will_Expire_CUST</fullName>
        <description>Set the User Settings to will expire based on the audit date.</description>
        <field>Access_Status_CUST__c</field>
        <literalValue>Under Review</literalValue>
        <name>User Settings Will Expire</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CUST_User Settings Under Review</fullName>
        <actions>
            <name>Update_Manager_CUST</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>User_Settings_Will_Expire_CUST</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CST_User_Settings_CUST__c.Audit_Date_CUST__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>Update the manager of any record under review : CUST : Created on 12/5/2013 by Sam Rosen, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CUST_User_Pending_Auto_Expire</fullName>
        <active>true</active>
        <criteriaItems>
            <field>CST_User_Settings_CUST__c.Access_Status_CUST__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>This workflow auto expires a pending CST User Setting record after 2 weeks : CUST : Created on 12/5/2013 by Sam Rosen, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_status_to_Expired_CUST</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
