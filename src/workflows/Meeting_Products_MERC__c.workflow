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
    <fieldUpdates>
        <fullName>Populate_My_Setup_Product_External_ID</fullName>
        <field>My_Setup_Product_External_ID_MERC__c</field>
        <formula>&apos;0000000MERC_&apos; &amp; TEXT(Meeting_MERC__r.Event_Country_MERC__c) &amp; &apos;_&apos; &amp;  Product_MERC__r.Product_Group_Id_GLBL__c  &amp; &apos;_&apos; &amp; Indication_MERC__r.Indctn_Id_GLBL__c</formula>
        <name>Populate My Setup Product External ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>RTI_Meeting_Product_Updated_MERC</fullName>
        <apiVersion>29.0</apiVersion>
        <endpointUrl>https://gso1integration.xh1.lilly.com/rti/v1/genericUpdated</endpointUrl>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>CurrencyIsoCode</fields>
        <fields>Detail_Sequence_MERC__c</fields>
        <fields>Id</fields>
        <fields>Indication_Description_MERC__c</fields>
        <fields>Indication_External_MERC__c</fields>
        <fields>Indication_Id_MERC__c</fields>
        <fields>Indication_MERC__c</fields>
        <fields>IsDeleted</fields>
        <fields>LastModifiedById</fields>
        <fields>LastModifiedDate</fields>
        <fields>Meeting_Event_Id_MERC__c</fields>
        <fields>Meeting_External_MERC__c</fields>
        <fields>Meeting_MERC__c</fields>
        <fields>Mercury_External_Id_MERC__c</fields>
        <fields>My_Setup_Product_External_ID_MERC__c</fields>
        <fields>Name</fields>
        <fields>Product_External_ID_MERC__c</fields>
        <fields>Product_Group_Id_MERC__c</fields>
        <fields>Product_MERC__c</fields>
        <fields>Product_Name_MERC__c</fields>
        <fields>Product_vod_External_ID_MERC__c</fields>
        <fields>SystemModstamp</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>mercuryintegration.veeva@gso1.lly</integrationUser>
        <name>RTI - Meeting Product Updated</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>MERC_External ID-MeetingProduct</fullName>
        <actions>
            <name>External_ID_MeetingProduct_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Products_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RTI - Meeting Product Updated</fullName>
        <actions>
            <name>RTI_Meeting_Product_Updated_MERC</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RTI - My Setup Product External ID</fullName>
        <actions>
            <name>Populate_My_Setup_Product_External_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Products_MERC__c.My_Setup_Product_External_ID_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
