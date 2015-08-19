<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>RTI_Account_Update_ICRT</fullName>
        <apiVersion>34.0</apiVersion>
        <endpointUrl>https://ps1w2-obm.rt.informaticacloud.com/active-bpel/services/REST/SalesforceNotificationRESTPort?processName=prcs_GSO_MVI_MTV_ACC_upd</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>icrtmercuryintegration.veeva@gso1.lly</integrationUser>
        <name>RTI - Account Update ICRT</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>RTI - Account Updated</fullName>
        <actions>
            <name>RTI_Account_Update_ICRT</name>
            <type>OutboundMessage</type>
        </actions>
        <actions>
            <name>RTI_Account_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>(NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;))) &amp;&amp; ( (NOT(ISNEW()) &amp;&amp; NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)) &amp;&amp; NOT(CONTAINS(LastModifiedBy.Username,&apos;gso1.informatica@&apos;)))  || (NOT(ISNEW())  &amp;&amp; ISCHANGED(Transparency_Reporting_Opt_Out_MERC__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
