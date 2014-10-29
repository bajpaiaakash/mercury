<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MICO_Sprint_Calculate_Working_Days</fullName>
        <field>Number_Working_Days_in_Sprint__c</field>
        <formula>IF(AND((5 - (CASE(MOD( Start_Date__c - DATE(1900, 1, 6), 7), 0, 0, 1, 5, 2, 5, 3, 4, 4, 3, 5, 2, 6, 1, 0)) &lt; (CASE(MOD( End_Date__c - DATE(1900, 1, 6), 7), 0, 0, 1, 0, 2, 1, 3, 2, 4, 3, 5, 4, 6, 5, 0)) ), 
((( End_Date__c - Start_Date__c ) + 1) &lt; 7)), 
((CASE(MOD( End_Date__c - DATE(1900, 1, 6), 7), 0, 0, 1, 0, 2, 1, 3, 2, 4, 3, 5, 4, 6, 5, 0)) - (5 - (CASE(MOD( Start_Date__c - DATE(1900, 1, 6), 7), 0, 0, 1, 5, 2, 5, 3, 4, 4, 3, 5, 2, 6, 1, 0)))), 
(((FLOOR((( End_Date__c - Start_Date__c ) - (CASE(MOD( Start_Date__c - DATE(1900, 1, 6), 7), 0, 0, 1, 6, 2, 5, 3, 4, 4, 3, 5, 2, 6, 1, 0))) / 7)) * 5) + 
(CASE(MOD( Start_Date__c - DATE(1900, 1, 6), 7), 0, 0, 1, 5, 2, 5, 3, 4, 4, 3, 5, 2, 6, 1, 0)) + 
(CASE(MOD( End_Date__c - DATE(1900, 1, 6), 7), 0, 0, 1, 0, 2, 1, 3, 2, 4, 3, 5, 4, 6, 5, 0))))</formula>
        <name>Sprint Calculate Working Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MICO_Sprint Calculate Working Days</fullName>
        <actions>
            <name>MICO_Sprint_Calculate_Working_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Based on start date and end date, calculate the number of working days in a sprint</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
