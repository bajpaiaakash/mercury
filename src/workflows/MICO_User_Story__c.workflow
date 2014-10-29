<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MICO_User_Story_Passed_Send_Email</fullName>
        <ccEmails>prgrover@deloitte.co.uk; smatharu@deloitte.co.uk; stmills@deloitte.co.uk</ccEmails>
        <description>User Story Passed - Send Email</description>
        <protected>false</protected>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Tracker_Templates/User_Story_Passed_HTM</template>
    </alerts>
    <fieldUpdates>
        <fullName>MICO_User_Story_Passed_Set_Close_Date</fullName>
        <description>Close Date = Today</description>
        <field>Close_Date__c</field>
        <formula>today()</formula>
        <name>User Story Passed - Set Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MICO_User_Story_Release_Comp_Unchec</fullName>
        <field>Release_Completeness__c</field>
        <literalValue>0</literalValue>
        <name>User Story Release Completeness - Unchec</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MICO_User_Story_Release_Completeness</fullName>
        <field>Release_Completeness__c</field>
        <literalValue>1</literalValue>
        <name>User Story Release Completeness</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MICO_User Story Passed</fullName>
        <actions>
            <name>MICO_User_Story_Passed_Send_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>MICO_User_Story_Passed_Set_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When a User Story is set to status &apos;Done&apos;, send an email and update the close date field</description>
        <formula>ISCHANGED( Development_Stage__c ) &amp;&amp; ISPICKVAL(Development_Stage__c , &quot;5.9. Done&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MICO_User Story Release Completeness</fullName>
        <actions>
            <name>MICO_User_Story_Release_Completeness</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>MICO_User_Story__c.Release_Steps_Automated__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_User_Story__c.Release_Steps_Manual__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_User_Story__c.Version__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_User_Story__c.Validation_steps__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Verify the release completeness</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MICO_User Story Release Completeness - Uncheck</fullName>
        <actions>
            <name>MICO_User_Story_Release_Comp_Unchec</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4</booleanFilter>
        <criteriaItems>
            <field>MICO_User_Story__c.Release_Steps_Automated__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_User_Story__c.Release_Steps_Manual__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_User_Story__c.Version__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>MICO_User_Story__c.Validation_steps__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Verify the release completeness</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
