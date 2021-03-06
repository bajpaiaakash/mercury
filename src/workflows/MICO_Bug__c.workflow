<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MICO_Defect_Release_Completeness</fullName>
        <field>Release_Completeness__c</field>
        <literalValue>1</literalValue>
        <name>Defect Release Completeness</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MICO_Defect_Release_Completeness_Uncheck</fullName>
        <field>Release_Completeness__c</field>
        <literalValue>0</literalValue>
        <name>Defect Release Completeness - Uncheck</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MICO_increment_reopened_count</fullName>
        <description>Increment the Reopened count field</description>
        <field>Reopened_Count__c</field>
        <formula>Reopened_Count__c + 1</formula>
        <name>MICO increment reopened count</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MICO increment reopened count</fullName>
        <actions>
            <name>MICO_increment_reopened_count</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Increments the Reopened Count field each time a defect gets re-opened</description>
        <formula>AND(   OR(     ISPICKVAL(Status__c, &apos;Raised&apos;),     ISPICKVAL(Status__c, &apos;Ready for Development&apos;),     ISPICKVAL(Status__c, &apos;In Development&apos;)   ),   OR(     ISPICKVAL(PRIORVALUE(Status__c), &apos;Ready for Testing&apos;),     ISPICKVAL(PRIORVALUE(Status__c), &apos;Ready for Test Release&apos;),     ISPICKVAL(PRIORVALUE(Status__c), &apos;In Test&apos;),     ISPICKVAL(PRIORVALUE(Status__c), &apos;Closed - Complete&apos;),     ISPICKVAL(PRIORVALUE(Status__c), &apos;Ready for Release&apos;)   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MICO_Defect Release Completeness</fullName>
        <actions>
            <name>MICO_Defect_Release_Completeness</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>MICO_Bug__c.Release_Steps_Automated__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_Bug__c.Release_Comment__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_Bug__c.Fix_in_Environment__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_Bug__c.Version__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_Bug__c.Validation_Steps__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Verify the release completeness</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MICO_Defect Release Completeness - Uncheck</fullName>
        <actions>
            <name>MICO_Defect_Release_Completeness_Uncheck</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5</booleanFilter>
        <criteriaItems>
            <field>MICO_Bug__c.Release_Steps_Automated__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_Bug__c.Release_Comment__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_Bug__c.Fix_in_Environment__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_Bug__c.Version__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_Bug__c.Validation_Steps__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Verify the release completeness</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
