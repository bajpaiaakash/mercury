<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>RTI - Meeting Updated</fullName>
        <actions>
            <name>RTI_Meeting_Updated_MERC</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;)),NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)),NOT( TEXT(Type_MERC__c) = &apos;Internal&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
