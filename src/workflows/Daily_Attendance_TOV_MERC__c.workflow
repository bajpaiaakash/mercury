<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Clear_Confirm_ToV_Change_MERC</fullName>
        <description>Clears the confirm ToV change checkbox after each record update</description>
        <field>Confirm_ToV_Reporting_Change_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Clear Confirm ToV Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_TOV_External_Id</fullName>
        <description>Sets TOV External Id to Meeting Participant + Meeting Day to enforce uniqueness.</description>
        <field>External_ID_MERC__c</field>
        <formula>CASESAFEID(Meeting_Participant_MERC__c) &amp; &apos;_&apos; &amp; CASESAFEID(Meeting_Day_MERC__c)</formula>
        <name>Set TOV External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Day_Status_Change_ToV_Final_MERC</fullName>
        <description>Updates the Status Change Post AODS Send checkbox to indicate that a record was sent as Attended and now it&apos;s no show.  Oliver Dunford 18th June 2014.</description>
        <field>Status_Change_Post_ToV_Final_MERC__c</field>
        <literalValue>1</literalValue>
        <name>Update Day Status Change Post ToV Final</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Clear Confirm ToV Change</fullName>
        <actions>
            <name>Clear_Confirm_ToV_Change_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Confirm ToV Change checkbox after each record update : MERC : Created on 12/5/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Set TOV External Id</fullName>
        <actions>
            <name>Set_TOV_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Day_MERC__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Enforces uniqueness on TOV per participant per day : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Status Change Post ToV Sent</fullName>
        <actions>
            <name>Update_Day_Status_Change_ToV_Final_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Checks if a Participant Status has changed for a Daily Attendance &amp; ToV record post sending ToV to AODS : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED( Status_MERC__c ) &amp;&amp; ISPICKVAL(Status_MERC__c,&quot;No Show&quot;) &amp;&amp; ISPICKVAL( Meeting_Participant_MERC__r.Meeting_MERC__r.Participant_ToV_Final_MERC__c, &quot;Yes&quot;) &amp;&amp;  Status_Change_Post_ToV_Final_MERC__c  = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
