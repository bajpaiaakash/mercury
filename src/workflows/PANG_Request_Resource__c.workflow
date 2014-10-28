<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PANG_EA_AddedResource</fullName>
        <description>PANG_EA_AddedResource</description>
        <protected>false</protected>
        <recipients>
            <field>Resource__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PANG_Email_Templates/PANG_ET_Resource_Added</template>
    </alerts>
    <rules>
        <fullName>PANG_32_WF_ReqRes_New</fullName>
        <actions>
            <name>PANG_EA_AddedResource</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PANG_Request__c.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Each Resource added to a request will receive alert/notification of request &amp; role assignment</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
