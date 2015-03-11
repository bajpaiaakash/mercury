<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>RTI - Meeting Product Updated</fullName>
        <actions>
            <name>RTI_Meeting_Product_Updated_MERC</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>(NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;))) &amp;&amp; (NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
