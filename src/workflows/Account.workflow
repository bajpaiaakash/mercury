<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Transparency_reporting_last_modify</fullName>
        <description>To capture last modify date when Transparency Reporting consent has been modified.</description>
        <field>Transparency_Reporting_last_updated_MERC__c</field>
        <formula>NOW()</formula>
        <name>MERC_Transparency_reporting_last_modify</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Service_Provider_Tier_MERC</fullName>
        <description>Updates the Service Provider Tier for Tier 2 and 3 HCP&apos;s. Cannot auto-update Tier 1&apos;s. Oliver Dunford 14th Jan 2014.</description>
        <field>Service_Provider_Tier_MERC__c</field>
        <formula>IF(AND( 

Tier_2_Score_MERC__c  &gt;= 5,

Tier_1_Score_MERC__c  &lt;= 5 

),2,

IF(AND( 

Tier_2_Score_MERC__c  &lt;= 5,

Tier_1_Score_MERC__c  &lt;= 5 

),3, null))</formula>
        <name>Update Service Provider Tier</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Tier Step 1%3A Update Tier Scores</fullName>
        <actions>
            <name>Criteria_1_Met_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Criteria_2_Met_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Criteria_3_Met_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_CV_Review_State_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Initiate_Tiering_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Service_Provider_Tier_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Tier_1_Score_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Tier_2_Score_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Initiate_Tiering_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates Tier Criteria based on Scoring : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Transparency_reporting_last_modify_date_captured</fullName>
        <actions>
            <name>MERC_Transparency_reporting_last_modify</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To capture the last date of modification of field Transparency Reporting Consent  on Account object.</description>
        <formula>NOT(ISNEW()) &amp;&amp; ISCHANGED(Transparency_Reporting_Opt_Out_MERC__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
