<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>ETBackupWorkflow</fullName>
        <active>true</active>
        <criteriaItems>
            <field>et4ae5__SendDefinition__c.et4ae5__BackupWorkflow__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>et4ae5__UnpopulateBackupWorkflow</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>et4ae5__SendDefinition__c.et4ae5__BackupWorkflow__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ETScheduledSend</fullName>
        <active>true</active>
        <criteriaItems>
            <field>et4ae5__SendDefinition__c.et4ae5__Scheduled_Date_Time__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>et4ae5__DelayedSend</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>et4ae5__SendDefinition__c.et4ae5__Scheduled_Date_Time__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
