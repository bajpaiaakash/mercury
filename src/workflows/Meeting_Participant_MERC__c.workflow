<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>RTI_Meeting_Participant_Update_ICRT</fullName>
        <apiVersion>34.0</apiVersion>
        <endpointUrl>https://ps1w2-obm.rt.informaticacloud.com/active-bpel/services/REST/SalesforceNotificationRESTPort?processName=prcs_GSO_MVI_MTV_MTG_PRTCPNT_upsrt</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>icrtmercuryintegration.veeva@gso1.lly</integrationUser>
        <name>RTI - Meeting Participant Update ICRT</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>RTI - Meeting Participant Updated</fullName>
        <actions>
            <name>RTI_Meeting_Participant_Update_ICRT</name>
            <type>OutboundMessage</type>
        </actions>
        <actions>
            <name>RTI_Meeting_Participant_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>(NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;))) &amp;&amp; ( (NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)) || ISCHANGED( Maximum_Fee_MERC__c ) || (NOT(ISBLANK(Maximum_Fee_MERC__c))  &amp;&amp; ISNEW()))  &amp;&amp; NOT(ISBLANK( Account_External_MERC__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
