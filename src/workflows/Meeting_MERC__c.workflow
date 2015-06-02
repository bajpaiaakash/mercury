<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Audit_Start_Date_stamped_MERC</fullName>
        <description>Audit Start Date is automatically stamped when ToV Audit Status value is set to in-process</description>
        <field>Audit_Start_Date_MERC__c</field>
        <formula>NOW()</formula>
        <name>Audit Start Date stamp with Audit Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Audit_end_Date_stamping_MERC</fullName>
        <description>Audit End Date is automatically stamped when ToV Audit Status value is set to Completed</description>
        <field>Audit_End_Date_MERC__c</field>
        <formula>NOW()</formula>
        <name>Audit End Date stamp with Audit Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Audit_end_date_field_should_be_blank</fullName>
        <description>Audit End Date field will be blank when TOV audit status changed from Completed to Inprocess.</description>
        <field>Audit_End_Date_MERC__c</field>
        <name>Audit end date field should be blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Audit_End_Date</fullName>
        <description>Reset Audit end date field related to audit information on meetings.</description>
        <field>Audit_End_Date_MERC__c</field>
        <name>Reset Audit End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Audit_Start_Date</fullName>
        <description>Reset Audit Start date field related to Audit information.</description>
        <field>Audit_Start_Date_MERC__c</field>
        <name>Reset Audit Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_TOV_Audit_Status</fullName>
        <description>Reset TOV Audit Status fieldrelated to Audit information.</description>
        <field>ToV_Audit_Status_MERC__c</field>
        <name>Reset TOV Audit Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Audit status changed as Completed</fullName>
        <actions>
            <name>Audit_end_Date_stamping_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.ToV_Audit_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.Subject_to_ToV_Audit_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Audit End Date is automatically stamped when &apos;ToV Audit Status&apos; value is set to Completed</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Audit status changed as InProcess</fullName>
        <actions>
            <name>Audit_Start_Date_stamped_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Audit_end_date_field_should_be_blank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.ToV_Audit_Status_MERC__c</field>
            <operation>equals</operation>
            <value>In Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.Subject_to_ToV_Audit_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Audit Start Date is automatically stamped when &apos;ToV Audit Status&apos; value is set to in-process.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Reset audit fields</fullName>
        <actions>
            <name>Reset_Audit_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Audit_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_TOV_Audit_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Audit related fields will be automatically reset if Subject to TOV Audit is unchecked.</description>
        <formula>((PRIORVALUE( Subject_to_ToV_Audit_MERC__c ) == True)  &amp;&amp;  (Subject_to_ToV_Audit_MERC__c == False)) || ISPICKVAL(ToV_Audit_Status_MERC__c,&apos;&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
