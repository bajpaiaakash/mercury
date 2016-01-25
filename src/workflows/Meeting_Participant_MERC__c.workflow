<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>MERC_Participant_Potential_ToV</fullName>
        <actions>
            <name>MERC_Participant_Potential_ToV</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Checks the criteria specifically on the Meeting Participant record to flag the Potential ToV should it be needed.  Hotel/Air Needed, Individual Sponsorship : MERC : Created on 03/11/2015 by Oliver Dunford</description>
        <formula>(ISNEW() &amp;&amp; ((TEXT(Hotel_Required_MERC__c) = &quot;YES&quot;) ||  (TEXT(Air_Travel_Required_MERC__c) = &quot;YES&quot;) ||  (RecordType.DeveloperName = &quot;MERC_Individual_Sponsorship&quot;))) || (
(ISCHANGED(Hotel_Required_MERC__c) &amp;&amp; (TEXT(Hotel_Required_MERC__c) = &quot;YES&quot;) ||  (ISCHANGED(Air_Travel_Required_MERC__c) &amp;&amp; TEXT(Air_Travel_Required_MERC__c) = &quot;YES&quot;) || (ISCHANGED(RecordTypeId) &amp;&amp; RecordType.DeveloperName = &quot;MERC_Individual_Sponsorship&quot;))
) &amp;&amp;  TEXT(Potential_ToV_MERC__c) &lt;&gt; &quot;Yes&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
