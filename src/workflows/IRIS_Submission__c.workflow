<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>IRIS_Document_submission_Email_Alert_Iriss</fullName>
        <description>IRIS_Document submission Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Document_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Document_Submitter__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>ads_admin@lists.lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Document_Submission_Email_Template_Iriss</template>
    </alerts>
    <alerts>
        <fullName>IRIS_Notify_the_assessor_queue_Iriss</fullName>
        <description>IRIS_notify the assessor queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>ads_admin@lists.lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/IRIS_Queue_notification_iriss</template>
    </alerts>
    <fieldUpdates>
        <fullName>IRIS_Assisgn_to_Compliance_Messaging_Que</fullName>
        <description>Updates the owner Id to the Compliance Messaging queue id.</description>
        <field>OwnerId</field>
        <lookupValue>IRIS_Compliance_Msg_Materials_Assessor</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IRIS_Assisgn to Compliance Messaging Que</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IRIS_Assisgn_to_Global_Policies_Queue</fullName>
        <description>Updates the owner Id to the Global Policies queue id.</description>
        <field>OwnerId</field>
        <lookupValue>IRIS_Local_EnC_Procedures_Assessor</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IRIS_Assisgn to Global Policies Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IRIS_Assisgn_to_HR_Investigations_Queue</fullName>
        <description>Updates the owner Id to the HR Investigations queue id.</description>
        <field>OwnerId</field>
        <lookupValue>IRIS_HR_Investigations_Assessor</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IRIS_Assisgn to HR Investigations Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IRIS_Date_Field_Update_Iriss</fullName>
        <description>Auto populate the field to today date when the document is approved.</description>
        <field>Effective_Date__c</field>
        <formula>IF(ISNULL(Effective_Date__c) , TODAY(), Effective_Date__c)</formula>
        <name>IRIS_Effective Date Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IRIS_Erase_Periodic_review_date_Iriss</fullName>
        <description>Erases the periodic review date field when record is rejected</description>
        <field>Periodic_Review_Date__c</field>
        <name>IRIS_Erase Periodic review date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IRIS_Periodic_Review_Date_Field_Update</fullName>
        <description>Auto populate Periodic Review Date field to two years from the date of approval</description>
        <field>Periodic_Review_Date__c</field>
        <formula>DATE(YEAR(Effective_Date__c) + 2,month(Effective_Date__c ),day(Effective_Date__c))</formula>
        <name>IRIS_Periodic Review Date Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IRIS_Status_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>IRIS_Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IRIS_Submission_Status_to_Pending</fullName>
        <description>update the status field of Iriss Submisson object to &apos;Pending decedionl&apos;</description>
        <field>Status__c</field>
        <literalValue>Pending decision</literalValue>
        <name>IRIS_Submission Status to Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IRIS_Assign to Compliance Messaging queue</fullName>
        <actions>
            <name>IRIS_Document_submission_Email_Alert_Iriss</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IRIS_Notify_the_assessor_queue_Iriss</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IRIS_Assisgn_to_Compliance_Messaging_Que</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IRIS_Submission__c.COE_Category__c</field>
            <operation>equals</operation>
            <value>Compliance Messaging Materials</value>
        </criteriaItems>
        <criteriaItems>
            <field>IRIS_Submission__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>Assigns the submission of category Compliance Messaging to the Complaince Messages queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IRIS_Assign to Global Policies queue</fullName>
        <actions>
            <name>IRIS_Document_submission_Email_Alert_Iriss</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IRIS_Notify_the_assessor_queue_Iriss</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IRIS_Assisgn_to_Global_Policies_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IRIS_Submission__c.COE_Category__c</field>
            <operation>equals</operation>
            <value>Local E&amp;C Procedures</value>
        </criteriaItems>
        <criteriaItems>
            <field>IRIS_Submission__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>Assigns the submission of category Global Policies to the Global Policies queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IRIS_Assign to HR Investigations queue</fullName>
        <actions>
            <name>IRIS_Document_submission_Email_Alert_Iriss</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IRIS_Notify_the_assessor_queue_Iriss</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IRIS_Assisgn_to_HR_Investigations_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IRIS_Submission__c.COE_Category__c</field>
            <operation>equals</operation>
            <value>HR Investigations</value>
        </criteriaItems>
        <criteriaItems>
            <field>IRIS_Submission__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>Assigns the submission of category HR Investigations to the HR Investigations queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IRIS_Periodic Review Date Field Update</fullName>
        <actions>
            <name>IRIS_Periodic_Review_Date_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update a field when status is Approved.</description>
        <formula>ISCHANGED( Effective_Date__c ) &amp;&amp; NOT( ISCHANGED( Periodic_Review_Date__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
