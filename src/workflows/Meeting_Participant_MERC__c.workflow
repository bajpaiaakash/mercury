<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Set_Final_Fee_Confirmed_Date</fullName>
        <description>Sets the final fee confirmed date once the Final Fee is Confirmed.  It will update for every instance of confirmation : MERC : Created on 20/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Final_Fee_Confirmed_Date_MERC__c</field>
        <formula>Today()</formula>
        <name>MERC Set Final Fee Confirmed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC Final Fee Date</fullName>
        <actions>
            <name>MERC_Set_Final_Fee_Confirmed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Stamps the date that the Final Fee was confirmed : MERC : Created on 20/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>(ISNEW() &amp;&amp;  TEXT(Confirm_Final_Fee_MERC__c) = &apos;Confirmed&apos;) || (ISCHANGED(Confirm_Final_Fee_MERC__c) &amp;&amp; TEXT(Confirm_Final_Fee_MERC__c) = &apos;Confirmed&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
