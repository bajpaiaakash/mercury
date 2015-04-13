<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
<fieldUpdates>
        <fullName>MERC_Maximum_Fee_last_modify</fullName>
        <description>To capture last modify date when Maximum Fee has been modified.</description>
        <field>Maximum_Fee_last_updated_MERC__c</field>
        <formula>NOW()</formula>
        <name>MERC_Maximum_Fee_last_modify</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
	<rules>
<fullName>MERC_Notify Meeting Owner of Final Fee</fullName>
<actions>
<name>Notifies_Meeting_Owner_of_Final_Fee</name>
<type>Alert</type>
</actions>
<active>true</active>
<description>Notifies Meeting Owner when Final Fee is &apos;Pending Confirmation&apos; and Min/Max value chagned from blank or &apos;0&apos; to greater than &apos;0&apos; : MERC : Created on 11/12/2013 by John Adams, Mavens Consulting, Modified on 04/09/2015 by Mercury Support TCS Team</description>
<formula>OR(
(ISNEW()&amp;&amp; Maximum_Fee_MERC__c &lt;&gt; 0 &amp;&amp; !ISBLANK(Maximum_Fee_MERC__c) &amp;&amp; !ISBLANK(Minimum_Fee_MERC__c) &amp;&amp; ISPICKVAL(Confirm_Final_Fee_MERC__c,&apos;Pending Confirmation&apos;) 
)
,
( !ISNEW() &amp;&amp; (ISBLANK(PRIORVALUE(Maximum_Fee_MERC__c)) || PRIORVALUE(Maximum_Fee_MERC__c) = 0)) &amp;&amp; (!ISBLANK(Maximum_Fee_MERC__c) &amp;&amp; Maximum_Fee_MERC__c &lt;&gt;0) &amp;&amp; (ISBLANK(PRIORVALUE(Minimum_Fee_MERC__c)) || PRIORVALUE(Minimum_Fee_MERC__c) = 0) &amp;&amp; !ISBLANK(Minimum_Fee_MERC__c) &amp;&amp; ISPICKVAL(Confirm_Final_Fee_MERC__c,&apos;Pending Confirmation&apos;) )</formula>
<triggerType>onAllChanges</triggerType>
</rules>
<rules>
        <fullName>MERC_Maximum_Fee_last_modify_date_captured</fullName>
        <actions>
            <name>MERC_Maximum_Fee_last_modify</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To capture the last date of modification of field Maximum Fee on Meeting Participant object.</description>
        <formula>ISCHANGED( Maximum_Fee_MERC__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
	</Workflow>