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
    <fieldUpdates>
        <fullName>Update_Start_Date_from_Check_in_MERC</fullName>
        <description>Updates Start Date field on Travel Itinerary Record when Record type = Accommodation. Created 11/09/2013 by KLorenti, Mavens Consulting</description>
        <field>Start_Date_MERC__c</field>
        <formula>Check_in_Date_MERC__c</formula>
        <name>Update Start Date from Check-in Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Start_Date_from_Departure_MERC</fullName>
        <description>Will update the Start Date field with the Departure date if Travel Itinerary Record type is Flight.</description>
        <field>Start_Date_MERC__c</field>
        <formula>DATEVALUE(Departure_Date_Time_MERC__c)</formula>
        <name>Update Start Date from Departure Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Start_Date_from_Ground_MERC</fullName>
        <description>Updates Start Date with Departure Date when record type = Ground Transportation. Created 11/9/2013</description>
        <field>Start_Date_MERC__c</field>
        <formula>DATEVALUE(Departure_Date_Time_MERC__c)</formula>
        <name>Update Start Date from Ground_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
