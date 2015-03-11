<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>RTI - Team Member Updated</fullName>
        <actions>
            <name>RTI_Team_Member_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>(NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;))) &amp;&amp; (
NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)) &amp;&amp;  (Account_MERC__r.Prsnl_Nbr_GLBL__c) != &apos;&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
