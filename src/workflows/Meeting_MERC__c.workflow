<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>MERC_Complete</fullName>
        <actions>
            <name>Update_Record_Type_to_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Address_City_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Address_Cntry_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Address_Line_1_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Address_Line_2_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Name_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Postal_Code_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Meeting Status is changed to Complete updated Record Type to Complete : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Meeting_Status_MERC__c) &amp;&amp; TEXT(Meeting_Status_MERC__c)  = &quot;Complete&quot; &amp;&amp;  RecordType.DeveloperName &lt;&gt; &quot;Independent_Sponsorship&quot; &amp;&amp;  RecordType.DeveloperName &lt;&gt; &quot;Ad_Hoc_Consulting&quot; &amp;&amp; RecordType.DeveloperName &lt;&gt; &quot;Meeting_Program&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
