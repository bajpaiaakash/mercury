<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_of_Cirrus_Assessment_form_completion</fullName>
        <description>Notification of Cirrus Assessment form completion</description>
        <protected>false</protected>
        <recipients>
            <recipient>LPAD_Othr_Form_Completion_Recipients</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Launchpad_templates/LPAD_Form_Completion_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_LPAD_Assessment_completion_for_score_A</fullName>
        <description>Notification of LPAD Assessment  completion for score A</description>
        <protected>false</protected>
        <recipients>
            <field>Form_Executor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Launchpad_templates/LPAD_Assessment_Completion_Notification_for_Score_A</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_LPAD_Assessment_completion_for_score_B</fullName>
        <description>Notification of LPAD Assessment  completion for score B</description>
        <protected>false</protected>
        <recipients>
            <field>Form_Executor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Launchpad_templates/LPAD_Assessment_Completion_Notification_for_Score_B</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_LPAD_Assessment_completion_for_score_C</fullName>
        <description>Notification of LPAD Assessment completion for score C</description>
        <protected>false</protected>
        <recipients>
            <field>Form_Executor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Launchpad_templates/LPAD_Assessment_Completion_Notification_for_Score_C</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_LPAD_Assessment_completion_for_score_D</fullName>
        <description>Notification of LPAD Assessment  completion for score D</description>
        <protected>false</protected>
        <recipients>
            <field>Form_Executor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Launchpad_templates/LPAD_Assessment_Completion_Notification_for_Score_D</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_LPAD_Assessment_completion_for_score_E</fullName>
        <description>Notification of LPAD Assessment  completion for score E</description>
        <protected>false</protected>
        <recipients>
            <field>Form_Executor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Launchpad_templates/LPAD_Assessment_Completion_Notification_for_Score_E</template>
    </alerts>
    <rules>
        <fullName>LPAD Form Completion Notification</fullName>
        <actions>
            <name>Notification_of_Cirrus_Assessment_form_completion</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>GLBL_Form_Execution__c.Execution_Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>GLBL_Form_Execution__c.Type__c</field>
            <operation>equals</operation>
            <value>Launchpad Assessment</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LPAD form Assessment completion with Score A</fullName>
        <actions>
            <name>Notification_of_LPAD_Assessment_completion_for_score_A</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Evaluate the rule when the Assessment is completed by a user with highest aggregate Score A</description>
        <formula>(ISPICKVAL(Execution_Status__c,&apos;Complete&apos;) &amp;&amp; ISPICKVAL(Type__c,&apos;Launchpad Assessment&apos;))&amp;&amp; (Aggregate_Score_A__c &gt;= Aggregate_Score_B__c)  &amp;&amp;(Aggregate_Score_A__c &gt;= Aggregate_Score_C__c )  &amp;&amp; (Aggregate_Score_A__c &gt;= Aggregate_Score_D__c)  &amp;&amp; (Aggregate_Score_A__c &gt;= Aggregate_Score_E__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LPAD form Assessment completion with Score B</fullName>
        <actions>
            <name>Notification_of_LPAD_Assessment_completion_for_score_B</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Evaluate the rule when the Assessment is completed by a user with highest aggregate Score B</description>
        <formula>(ISPICKVAL(Execution_Status__c,&apos;Complete&apos;) &amp;&amp; ISPICKVAL(Type__c,&apos;Launchpad Assessment&apos;))&amp;&amp;  (Aggregate_Score_B__c &gt; Aggregate_Score_A__c ) &amp;&amp;  (Aggregate_Score_B__c&gt;= Aggregate_Score_C__c ) &amp;&amp;  (Aggregate_Score_B__c&gt;= Aggregate_Score_D__c) &amp;&amp;  (Aggregate_Score_B__c&gt;= Aggregate_Score_E__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LPAD form Assessment completion with Score C</fullName>
        <actions>
            <name>Notification_of_LPAD_Assessment_completion_for_score_C</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Evaluate the rule when the Assessment is completed by a user with highest aggregate Score C</description>
        <formula>(ISPICKVAL(Execution_Status__c,&apos;Complete&apos;) &amp;&amp; ISPICKVAL(Type__c,&apos;Launchpad Assessment&apos;))&amp;&amp;  (Aggregate_Score_C__c &gt; Aggregate_Score_A__c) &amp;&amp;  (Aggregate_Score_C__c &gt; Aggregate_Score_B__c) &amp;&amp;   (Aggregate_Score_C__c &gt;= Aggregate_Score_D__c) &amp;&amp;  (Aggregate_Score_C__c &gt;= Aggregate_Score_E__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LPAD form Assessment completion with Score D</fullName>
        <actions>
            <name>Notification_of_LPAD_Assessment_completion_for_score_D</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Evaluate the rule when the Assessment is completed by a user with highest aggregate Score D</description>
        <formula>(ISPICKVAL(Execution_Status__c,&apos;Complete&apos;) &amp;&amp; ISPICKVAL(Type__c,&apos;Launchpad Assessment&apos;))&amp;&amp;  (Aggregate_Score_D__c &gt; Aggregate_Score_A__c) &amp;&amp;(Aggregate_Score_D__c &gt;Aggregate_Score_B__c ) &amp;&amp;  (Aggregate_Score_D__c &gt; Aggregate_Score_C__c) &amp;&amp;  (Aggregate_Score_D__c&gt;= Aggregate_Score_E__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LPAD form Assessment completion with Score E</fullName>
        <actions>
            <name>Notification_of_LPAD_Assessment_completion_for_score_E</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Evaluate the rule when the Assessment is completed by a user with highest aggregate Score E</description>
        <formula>(ISPICKVAL(Execution_Status__c,&apos;Complete&apos;) &amp;&amp; ISPICKVAL(Type__c,&apos;Launchpad Assessment&apos;))&amp;&amp;  (Aggregate_Score_E__c &gt; Aggregate_Score_A__c) &amp;&amp;(Aggregate_Score_E__c &gt; Aggregate_Score_B__c ) &amp;&amp;  (Aggregate_Score_E__c &gt; Aggregate_Score_C__c) &amp;&amp;  (Aggregate_Score_E__c &gt; Aggregate_Score_D__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
