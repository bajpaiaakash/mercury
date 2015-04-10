<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Transparency_reporting_last_modify</fullName>
        <description>To capture last modify date when Transparency Reporting consent has been modified.</description>
        <field>Transparency_Reporting_last_update_MERC__c</field>
        <formula>PRIORVALUE(  Transparency_Reporting_current_time_MERC__c  )</formula>
        <name>MERC_Transparency_reporting_last_modify</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Transparency_reporting_modify_date</fullName>
        <description>To capture current time stamp when Transparency Reporting consent  has been modified.</description>
        <field>Transparency_Reporting_current_time_MERC__c</field>
        <formula>NOW()</formula>
        <name>MERC_Transparency_reporting_modify_date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Service_Provider_Tier_MERC</fullName>
        <description>Sets the Tier based upon scoring output. This will only ever be a Tier 2 or 3 as Tier 1 HCPs need CV&apos;s checking.</description>
        <field>Service_Provider_Tier_MERC__c</field>
        <formula>IF(AND( 
Tier_2_Score_MERC__c &gt;= 5, 
Tier_1_Score_MERC__c &lt; 5 
),2, 
IF(AND( 
Tier_2_Score_MERC__c &lt; 5, 
Tier_1_Score_MERC__c &lt; 5 
),3, null))</formula>
        <name>Set Service Provider Tier</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <actions>
            <name>MERC_Transparency_reporting_modify_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To capture the last date of modification of field Transparency Reporting Consent  on Account object.</description>
        <formula>OR(
     ISNEW(),
     AND(
          NOT(ISNEW()),
          ISCHANGED( Transparency_Reporting_Opt_Out_MERC__c )
     )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
