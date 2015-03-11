<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>RTI - Pref and Consent Updated</fullName>
        <actions>
            <name>RTI_Pref_and_Consent_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Sends records information to Veeva orgs</description>
        <formula>(NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;))) &amp;&amp; (
(NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)) &amp;&amp;
 NOT(CONTAINS(LastModifiedBy.Username,&apos;gso1.informatica@&apos;)) 
&amp;&amp; RecordType.DeveloperName = &quot;Consent_EVNT_MVN&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
