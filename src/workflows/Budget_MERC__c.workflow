<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_Budget_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Budget</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Budget_is_Final_MERC</fullName>
        <description>Update &quot;Budget is Final&quot; on Meeting to Yes when the Budget becomes final. Created 12/10/2013 by KLorenti, Mavens Consultng</description>
        <field>Budget_is_Final_MERC__c</field>
        <literalValue>Yes</literalValue>
        <name>Update Budget is Final_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Budget is Final_MERC</fullName>
        <actions>
            <name>Update_Budget_is_Final_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Budget_MERC__c.Status_MERC__c</field>
            <operation>equals</operation>
            <value>Final</value>
        </criteriaItems>
        <criteriaItems>
            <field>Budget_MERC__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Final</value>
        </criteriaItems>
        <description>When Budget is Final, updated &quot;Budget is Final&quot; on meeting to Yes. Created 12/10/2013 by KLorenti, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Mercury External ID-Budget_MERC</fullName>
        <actions>
            <name>External_ID_Budget_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Budget_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
