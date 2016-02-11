<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Final_Fee_to_Zero_MERC</fullName>
        <description>If the Confirm Final Fee &lt;&gt; Confirmed OR Proposed Fee is changed, reset Final Fee amount back to zero.  Created 11/21/2013 by KLorenti. Modified 2/10/2016 by Vijay Garg.</description>
        <field>Final_Fee_MERC__c</field>
        <name>Update Final Fee to Zero_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Over Maximum Fee</fullName>
        <actions>
            <name>Update_Confirm_Final_Fee_to_Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Final_Fee_to_Zero_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Higher_Fee_Approval_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Proposed Final Fee is over the Maximum Fee set the Exception Approval = Required  : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISCHANGED (Proposed_Final_Fee_MERC__c ) &amp;&amp;  Proposed_Final_Fee_MERC__c &gt; Maximum_Fee_MERC__c &amp;&amp;(NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Under Maximum Fee</fullName>
        <actions>
            <name>Update_Confirm_Final_Fee_to_Pending_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Exception_Approval_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Final_Fee_to_Zero_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Proposed Final Fee is less than the Maximum Fee then set the Exception Approval to &quot;Not Required&quot; : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED (Proposed_Final_Fee_MERC__c ) &amp;&amp;  Proposed_Final_Fee_MERC__c &lt;= Maximum_Fee_MERC__c &amp;&amp;(NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
