<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_MeetingProduct_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-MeetingProduct</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>RTI_Meeting_Product_Updated</fullName>
        <apiVersion>29.0</apiVersion>
        <endpointUrl>http://ec2-54-227-9-128.compute-1.amazonaws.com/rti-development/v1/genericUpdated</endpointUrl>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>CurrencyIsoCode</fields>
        <fields>Detail_Sequence_MERC__c</fields>
        <fields>Id</fields>
        <fields>IsDeleted</fields>
        <fields>LastModifiedById</fields>
        <fields>LastModifiedDate</fields>
        <fields>Meeting_MERC__c</fields>
        <fields>Mercury_External_Id_MERC__c</fields>
        <fields>Name</fields>
        <fields>Product_Group_Id_MERC__c</fields>
        <fields>Product_MERC__c</fields>
        <fields>SystemModstamp</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>helmer@gso1.lly</integrationUser>
        <name>RTI - Meeting Product Updated</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Mercury External ID-MeetingProduct</fullName>
        <actions>
            <name>External_ID_MeetingProduct_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Products_MERC__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RTI - Meeting Product Updated</fullName>
        <actions>
            <name>RTI_Meeting_Product_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>1==1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
