<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_MeetingParticipant_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-MeetingParticipant</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Participant_Type_MERC</fullName>
        <description>Populates the Participant Type field in the Meeting Participant based on value in Account</description>
        <field>Participant_Type_MERC__c</field>
        <formula>Account_MERC__r.RecordType.Name</formula>
        <name>Populate Participant Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Confirm_Final_Fee_to_Pending</fullName>
        <description>Update Confirm Final Fee back to Pending Confirmation if the Proposed Final Fee is edited.</description>
        <field>Confirm_Final_Fee_MERC__c</field>
        <literalValue>Pending Confirmation</literalValue>
        <name>Update Confirm Final Fee to Pending_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Confirm_Final_Fee_to_Pending_MERC</fullName>
        <description>Update Confirm Final Fee to Pending Confirmation if Proposed Fee is changed.</description>
        <field>Confirm_Final_Fee_MERC__c</field>
        <literalValue>Pending Confirmation</literalValue>
        <name>Update Confirm Final Fee to Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Exception_Approval_MERC</fullName>
        <description>If the Proposed Final Fee is less than the Maximium Fee then this field update will set the Exception Approval to &quot;Not Required&quot;</description>
        <field>Higher_Fee_Approval__c</field>
        <literalValue>Not Required</literalValue>
        <name>Update Exception Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Final_Fee_MERC</fullName>
        <description>Stamps the Final Fee with the Proposed Fee. Oliver Dunford 6th Nov 2013.</description>
        <field>Final_Fee_MERC__c</field>
        <formula>Proposed_Final_Fee_MERC__c</formula>
        <name>Update Final Fee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Final_Fee_to_Zero_MERC</fullName>
        <description>If the Confirm Final Fee &lt;&gt; Confirmed, reset Final Fee amount back to zero.  Created 11/21/2013 by KLorenti</description>
        <field>Final_Fee_MERC__c</field>
        <name>Update Final Fee to Zero_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Higher_Fee_Approval_MERC</fullName>
        <description>Update Higher Fee Approval (Exception Approval) to Required if the Proposed Final Fee &gt; Maximum Fee</description>
        <field>Higher_Fee_Approval__c</field>
        <literalValue>Required</literalValue>
        <name>Update_Higher_Fee_Approval_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Include_in_CAP_Rollup_MERC</fullName>
        <description>When Type of Service is &quot;Medical Research Consultant&quot;, set the &quot;Include_in_Cap_Rollup&quot; checkbox to False.</description>
        <field>Include_CAP_Roll_Up_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Update Include in CAP Rollup_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Maximum_Fee_to_zero_MERC</fullName>
        <description>When Payment Required is &quot;No&quot;, update Maximum Rate to zero.</description>
        <field>Maximum_Rate_MERC__c</field>
        <formula>0</formula>
        <name>Update Maximum Fee to zero_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Meeting_Participant_Search_MERC</fullName>
        <description>Updates the meeting participant search with a searchable string. Oliver Dunford 6th Nov 2013.</description>
        <field>Participant_Search_MERC__c</field>
        <formula>Account_MERC__r.FirstName &amp; &quot; &quot; &amp;  Account_MERC__r.LastName &amp; &quot; - &quot; &amp; Meeting_MERC__r.Name</formula>
        <name>Update Meeting Participant Search</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Minimum_Fee_to_zero_MERC</fullName>
        <description>Update Minimum Fee to Zero if No payment required</description>
        <field>Minimum_Rate_MERC__c</field>
        <formula>0</formula>
        <name>Update Minimum Fee to zero_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_to_Individual_Sponsor</fullName>
        <description>Update Record Type to Individual Sponsorship if Sponsorship Type is Individual Sponsorship</description>
        <field>RecordTypeId</field>
        <lookupValue>Individual_Sponsorship</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type to Individual Sponsor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Service_Provider_MERC</fullName>
        <description>Update Service Provider flag when Account is used as a Service Provider on a meeting.</description>
        <field>Service_Provider_MERC__c</field>
        <literalValue>1</literalValue>
        <name>Update Service Provider_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unique_Participant_MERC</fullName>
        <description>Updates the force unique participant with the Account Id and Meeting Id. Oliver Dunford 4th November.</description>
        <field>Force_Unique_Participant_MERC__c</field>
        <formula>Account_MERC__c  &amp; &quot; - &quot; &amp; Meeting_MERC__c</formula>
        <name>Update Unique Participant</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Flag Account as Service Provider_MERC</fullName>
        <actions>
            <name>Update_Service_Provider_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Service Provider</value>
        </criteriaItems>
        <description>When Account is used as Service Provider, update Service Provider flag on HCP Profile.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Include_Cap_Rollup_MERC</fullName>
        <actions>
            <name>Update_Include_in_CAP_Rollup_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.Types_of_Service_MERC__c</field>
            <operation>equals</operation>
            <value>Medical Research Consultant</value>
        </criteriaItems>
        <description>If the Type of Service is Medical Research, Set &quot;Include In Cap Rollup&quot; checkbox to &quot;false&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Mercury External ID-MeetingParticipant</fullName>
        <actions>
            <name>External_ID_MeetingParticipant_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>No Payment Required_MERC</fullName>
        <actions>
            <name>Update_Maximum_Fee_to_zero_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Minimum_Fee_to_zero_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.Payment_Required_MERC__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <description>If Payment Required is &quot;No&quot;, update Minimum and Maximum Fee to zero</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Over Maximum Fee_MERC</fullName>
        <actions>
            <name>Update_Confirm_Final_Fee_to_Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Higher_Fee_Approval_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Proposed Final Fee is over the Maximum Fee set the Exception Approval = Required</description>
        <formula>ISCHANGED (Proposed_Final_Fee_MERC__c ) &amp;&amp;  Proposed_Final_Fee_MERC__c &gt; Maximum_Fee_MERC__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Participant Type MERC</fullName>
        <actions>
            <name>Populate_Participant_Type_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>HCP,Non-HCP,Employee</value>
        </criteriaItems>
        <description>Records participant type when record is created or edited</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Un-Confirm Final Fee_MERC</fullName>
        <actions>
            <name>Update_Final_Fee_to_Zero_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.Confirm_Final_Fee_MERC__c</field>
            <operation>notEqual</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <description>If the Confirm Final Fee &lt;&gt; Confirmed, reset Final Fee amount back to zero. Created 11/21/2013 by KLorenti</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Under Maximum Fee_Merc</fullName>
        <actions>
            <name>Update_Confirm_Final_Fee_to_Pending_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Exception_Approval_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Proposed Final Fee is lass than the Maximum Fee then set the Exception Approval to &quot;Not Required&quot;. Created 11/21/2013 by KLorenti</description>
        <formula>ISCHANGED (Proposed_Final_Fee_MERC__c ) &amp;&amp;  Proposed_Final_Fee_MERC__c &lt; Maximum_Fee_MERC__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Final Fee_MERC</fullName>
        <actions>
            <name>Update_Final_Fee_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Final Fee once confirmed with the HCP or Affiliate.</description>
        <formula>AND (ISCHANGED( Confirm_Final_Fee_MERC__c ) ,  ISPICKVAL(Confirm_Final_Fee_MERC__c, &quot;Confirmed&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Meeting Participant Search_MERC</fullName>
        <actions>
            <name>Update_Meeting_Participant_Search_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the meeting participant search field with a searchable string. Oliver Dunford 6th Nov 2013.</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Unique Meeting Participant_MERC</fullName>
        <actions>
            <name>Update_Unique_Participant_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Unique Participant text field to enforce Participant Uniqueness for a Meeting.</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
