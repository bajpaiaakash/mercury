<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>MERC_Notify the Primary Meeting Owner of Signed Contract</fullName>
        <actions>
            <name>Notify_the_Primary_Meeting_Owner_of_Signed_Contract</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies the Primary Meeting Owner of a Signed Contract : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>(ISCHANGED(Number_of_Completed_Contracts_MERC__c) &amp;&amp; Number_of_Completed_Contracts_MERC__c = 1)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
