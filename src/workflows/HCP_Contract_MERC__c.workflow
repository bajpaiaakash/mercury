<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Update_Contract_Received_Date</fullName>
        <description>When Contract Request Status = Completed, Contract Received Date is set to today&apos;s date</description>
        <field>Contract_Received_Date_MERC__c</field>
        <formula>Today()</formula>
        <name>MERC_Update_Contract_Received_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Set_Contract_Received_Date</fullName>
        <actions>
            <name>MERC_Update_Contract_Received_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Contract Request Status = Completed, Contract Received Date is set to today&apos;s date : MERC : Created on 17/08/2015 by Jyoti Gaur, TCS.</description>
        <formula>ISCHANGED(Contract_Request_Status_MERC__c) &amp;&amp; TEXT(Contract_Request_Status_MERC__c) = &quot;Completed&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
