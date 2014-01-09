<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_TravelItinerary_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-TravelItinerary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Mercury External ID-TravelItinerary</fullName>
        <actions>
            <name>External_ID_TravelItinerary_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Travel_Itinerary_MERC__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Populates External ID with OrdID and ID</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
