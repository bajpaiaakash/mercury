<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Clear_Retry_Date_MERC</fullName>
        <field>Retry_Date__c</field>
        <name>Clear Retry Date_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Send_Email_TRUE_MERC</fullName>
        <field>Send_Email__c</field>
        <literalValue>1</literalValue>
        <name>Set Send Email = TRUE_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Meeting Email Send Retry Email</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Email_Send_MERC__c.Retry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clear_Retry_Date_MERC</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Set_Send_Email_TRUE_MERC</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Meeting_Email_Send_MERC__c.Retry_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MERC_Meeting Email Send Scheduled Email</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Email_Send_MERC__c.Scheduled_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Send_Email_TRUE_MERC</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Meeting_Email_Send_MERC__c.Scheduled_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
