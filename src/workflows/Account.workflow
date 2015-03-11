<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>RTI - Account Updated</fullName>
        <actions>
            <name>RTI_Account_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>(NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;))) &amp;&amp; (
(NOT(ISNEW()) &amp;&amp; NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)) &amp;&amp; NOT(CONTAINS(LastModifiedBy.Username,&apos;gso1.informatica@&apos;))) 
|| (NOT(ISNEW()) 
&amp;&amp; ISCHANGED(Transparency_Reporting_Opt_Out_MERC__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
