<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Clear_Confirm_ToV_Reporting_Change_MERC</fullName>
        <description>Set Confirm ToV Reporting Change checkbox to FALSE after each record update.</description>
        <field>Confirm_ToV_Reporting_Change_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Clear Confirm ToV Reporting Change_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
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
        <fullName>Update_Unique_id_on_Travel</fullName>
        <description>Updates Force Unique Travel Itinerary field on Travel Itinerary to prevent duplicate hotel entries for same date range.</description>
        <field>Force_Unique_Travel_Itinerary_MERC__c</field>
        <formula>Combined_ID_MERC__c</formula>
        <name>Update Unique id on Travel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Clear Confirm ToV Change</fullName>
        <actions>
            <name>Clear_Confirm_ToV_Reporting_Change_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Confirm ToV Reporting Change checkbox after each record update : MERC : Created on 01/08/2014 by KLorenti, Mavens Consulting</description>
        <formula>Confirm_ToV_Reporting_Change_MERC__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_External ID-TravelItinerary</fullName>
        <actions>
            <name>External_ID_TravelItinerary_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Travel_Itinerary_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates External ID with OrdID and ID : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Stamp Unique ID on Travel Itinerary</fullName>
        <actions>
            <name>Update_Unique_id_on_Travel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Stamps Combined ID composite key into Force Unique Travel Itinerary field to prevent duplicate Hotel Travel itineraries to be created for same date range : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
