<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Service_Provider_Tier_MERC</fullName>
        <description>Sets the Tier based upon scoring output. This will only ever be a Tier 2 or 3 as Tier 1 HCPs need CV&apos;s checking.</description>
        <field>Service_Provider_Tier_MERC__c</field>
        <formula>IF(AND( 
Tier_2_Score_MERC__c &gt; 5, 
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
        <fullName>MERC_Notification of HCP Email Address Change</fullName>
        <actions>
            <name>MERC_Notify_CMS_Cork_and_Create_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends the CMS Cork Europe an email when an HCP email address is changed.  Not for mastered email addresses : MERC : Created on 16/09/2014 by Oliver Dunford, Mavens Consulting</description>
        <formula>RecordType.DeveloperName = &quot;HCP_GLBL&quot;  &amp;&amp; !CONTAINS($User.Username, &quot;unittest&quot;)  &amp;&amp;  !CONTAINS( FirstName , &quot;unittest&quot;)  &amp;&amp; (( !ISBLANK(PRIORVALUE(PersonEmail)) &amp;&amp; ISCHANGED(PersonEmail)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
