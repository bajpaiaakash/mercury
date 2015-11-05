<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>RTI_Pref_and_Consent_Update_ICRT</fullName>
        <apiVersion>35.0</apiVersion>
        <description>Sends selected fields to Veeva orgs for update</description>
        <endpointUrl>https://ps1w2-obm.rt.informaticacloud.com/active-bpel/services/REST/SalesforceNotificationRESTPort?processName=prcs_GSO_MVI_MTV_CNSNT_upsrt</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>icrtmercuryintegration.veeva@gso1.lly</integrationUser>
        <name>RTI - Pref and Consent Update ICRT</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>RTI - Pref and Consent Updated</fullName>
        <actions>
            <name>RTI_Pref_and_Consent_Update_ICRT</name>
            <type>OutboundMessage</type>
        </actions>
        <actions>
            <name>RTI_Pref_and_Consent_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Sends records information to Veeva orgs</description>
        <formula>(NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;))) &amp;&amp; ( (NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)) &amp;&amp;  NOT(CONTAINS(LastModifiedBy.Username,&apos;gso1.informatica@&apos;))  &amp;&amp; RecordType.DeveloperName = &quot;Consent_EVNT_MVN&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
