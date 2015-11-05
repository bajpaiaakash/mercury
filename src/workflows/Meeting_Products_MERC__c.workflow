<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>RTI_Meeting_Product_Update_ICRT</fullName>
        <apiVersion>35.0</apiVersion>
        <endpointUrl>https://ps1w2-obm.rt.informaticacloud.com/active-bpel/services/REST/SalesforceNotificationRESTPort?processName=prcs_GSO_MVI_MTV_MTG_PROD_upsrt</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>icrtmercuryintegration.veeva@gso1.lly</integrationUser>
        <name>RTI - Meeting Product Update_ICRT</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>RTI_Meeting_SetupProd_Update_ICRT</fullName>
        <apiVersion>35.0</apiVersion>
        <endpointUrl>https://ps1w2-obm.rt.informaticacloud.com/active-bpel/services/REST/SalesforceNotificationRESTPort?processName=prcs_GSO_MVI_MTV_MTG_SETUPPROD_upsrt</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>icrtmercuryintegration.veeva@gso1.lly</integrationUser>
        <name>RTI – Meeting  SetupProd Update ICRT</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>RTI - Meeting Product Updated</fullName>
        <actions>
            <name>RTI_Meeting_Product_Update_ICRT</name>
            <type>OutboundMessage</type>
        </actions>
        <actions>
            <name>RTI_Meeting_Product_Updated_MERC</name>
            <type>OutboundMessage</type>
        </actions>
        <actions>
            <name>RTI_Meeting_SetupProd_Update_ICRT</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>(NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;))) &amp;&amp; (NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
