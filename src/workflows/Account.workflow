<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
<<<<<<< HEAD
    <alerts>
        <fullName>Expiring_Auth_to_CST_Manager_CUST</fullName>
        <ccEmails>sean@mavensconsulting.com,</ccEmails>
        <ccEmails>sam@mavensconsulting.com</ccEmails>
        <description>Expiring Auth to CST Manager</description>
        <protected>false</protected>
        <recipients>
            <field>CST_Email_Stamp_CUST__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Search_Tool_CUST/Expire_Notification</template>
    </alerts>
    <alerts>
        <fullName>MERC_Notify_CMS_Cork_and_Create_Case</fullName>
        <ccEmails>cmseurope@lilly.com</ccEmails>
        <description>MERC_Notify CMS Cork and Create Case</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/MERC_HCP_Email_Address_Change</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_CST_User_CUST</fullName>
        <description>Email requests awaiting to CST User</description>
        <protected>false</protected>
        <recipients>
            <field>CST_Email_Stamp_CUST__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Search_Tool_CUST/AccessRequestsAwaitingApproval</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_Manager_CUST</fullName>
        <description>Send email to Manager</description>
        <protected>false</protected>
        <recipients>
            <field>CST_Email_Stamp_CUST__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Search_Tool_CUST/AccessRequestsAwaitingApproval</template>
    </alerts>
    <alerts>
        <fullName>User_Request_Status_Change_CUST</fullName>
        <description>User Request Status Change</description>
        <protected>false</protected>
        <recipients>
            <field>CST_Email_Stamp_CUST__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Search_Tool_CUST/Access_Request_Status_Change_CUST</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Email_Address_MERC</fullName>
        <description>Clears Email.  Non HCP Anonymise process.</description>
        <field>PersonEmail</field>
        <name>Clear Email Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Email_Flag_CUST</fullName>
        <field>Flag_CST_Email_CUST__c</field>
        <name>Clear Email Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Emergency_Contact_Name_MERC</fullName>
        <description>Clears Emergency Contact Name.  Non HCP Anonymise process.</description>
        <field>Emergency_Contact_Name_MERC__c</field>
        <name>Clear Emergency Contact Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Emergency_Contact_Phone_MERC</fullName>
        <description>Clears Emergency Contact Phone.  Non HCP Anonymise process.</description>
        <field>Emergency_Contact_Phone_Number_MERC__c</field>
        <name>Clear Emergency Contact Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Fax_Phone_Number</fullName>
        <description>Clears Fax Phone Number. Non HCP Anonymise process.</description>
        <field>Fax</field>
        <name>Clear Fax Phone Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Manager_Expire_Email_Flag_CUST</fullName>
        <description>Clear the manager email flag for records that are under review.</description>
        <field>Flag_CST_Expire_Email_CUST__c</field>
        <name>Clear Manager Expire Email Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Mobile_Number_MERC</fullName>
        <description>Clears Mobile Phone. Non HCP Anonymise process.</description>
        <field>PersonMobilePhone</field>
        <name>Clear Mobile Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_User_Email_Flag</fullName>
        <description>Clear the Customer Search Tool User email flag.</description>
        <field>Flag_CST_User_Email_CUST__c</field>
        <name>Clear User Email Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Work_Phone_MERC</fullName>
        <description>Clears Work Phone.  Non HCP Anonymise process.</description>
        <field>Phone</field>
        <name>Clear Work Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Email</fullName>
        <field>CST_Email_Stamp_CUST__c</field>
        <formula>PersonEmail</formula>
        <name>Copy Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Email_CUST</fullName>
        <description>Copies the Person Account email to the Custom email field for the CST notification.</description>
        <field>CST_Email_Stamp_CUST__c</field>
        <formula>PersonEmail</formula>
        <name>Copy Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Criteria_1_Met_MERC</fullName>
        <description>Tier 1 Criteria is met if the HCP meets or exceed a score of 5 for both Tier 2 and Tier 1 Criteria.</description>
        <field>Tier_1_Criteria_Met_MERC__c</field>
        <formula>IF( 
AND( 
Tier_1_Score_MERC__c &gt;= 5, 
Tier_2_Score_MERC__c &gt;= 5, 
Tier_3_Criteria_Met_MERC__c = &quot;Yes&quot; 
),&quot;Yes&quot;, &quot;No&quot; 
)</formula>
        <name>Criteria 1 Met</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Criteria_2_Met_MERC</fullName>
        <description>Tier 2 Criteria are met if the HCP meets or exceeds a score of 5 based on Tier 2 categories.</description>
        <field>Tier_2_Criteria_Met_MERC__c</field>
        <formula>IF(AND( 
Tier_2_Score_MERC__c &gt;= 5, 
Tier_3_Criteria_Met_MERC__c = &quot;Yes&quot; 
),&quot;Yes&quot;, &quot;No&quot;)</formula>
        <name>Criteria 2 Met</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Criteria_3_Met_MERC</fullName>
        <description>By default every HCP is a Tier 3 if they go through the Tiering process. Set this value to Yes.</description>
        <field>Tier_3_Criteria_Met_MERC__c</field>
        <formula>&quot;Yes&quot;</formula>
        <name>Criteria 3 Met</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Stamp_CAP_Usage_Note_MERC</fullName>
        <description>Date Stamps the CAP Usage note to ensure it&apos;s relevant. Oliver Dunford 9th Nov 2013.</description>
        <field>CAP_Usage_Note_MERC__c</field>
        <formula>TEXT(TODAY()) &amp; &quot;: &quot; &amp;  CAP_Usage_Note_MERC__c &amp;  BR()</formula>
        <name>Date Stamp CAP Usage Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Stamp_HCP_Contract_Limitations</fullName>
        <description>Date stamps important information captured for the HCP. This should be date stamped for each post and passed via integration to Veeva. 

Created 02/17/2014 by KLorenti, Mavens Consulting</description>
        <field>Contract_Limitations_on_Use_MERC__c</field>
        <formula>TEXT(TODAY())&amp; &quot;: &quot; &amp;  Contract_Limitations_on_Use_MERC__c  &amp;BR()</formula>
        <name>Date Stamp HCP Contract Limitations</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Stamp_HCP_Exec_Smmry_MERC</fullName>
        <description>Date stamps important information captured for the HCP. This should be date stamped for each post and passed via integration to Veeva.

Created by John A Adams 12/18/2013</description>
        <field>Exec_Smmry_Note_MERC__c</field>
        <formula>TEXT(TODAY())&amp; &quot;: &quot; &amp;  Exec_Smmry_Note_MERC__c &amp;BR()</formula>
        <name>Date Stamp HCP Executive Summary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>External_ID_Account_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_HCP_Info_Pack_Received_Date</fullName>
        <description>MERC - &quot;HCP Info Pack Received Date&quot; field is populated with date on which &quot;HCP Info Pack Status&quot; is set to Submitted.</description>
        <field>HCP_Info_Pack_Received_Date_MERC__c</field>
        <formula>Today()</formula>
        <name>HCP Info Pack Received Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_CV_Review_State_MERC</fullName>
        <description>Each re-tier of a HCP requires a new validation of the CV.</description>
        <field>Tier_1_HCP_CV_Checked_MERC__c</field>
        <name>Reset CV Review State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Initiate_Tiering_MERC</fullName>
        <description>Once the processing is complete, reset the Initiate Tiering checkbox.</description>
        <field>Initiate_Tiering_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Reset Initiate Tiering</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Calculate_Open_Meeting_Fees_MERC</fullName>
        <description>Set Calculate Open Meeting Fees checkbox to FALSE after each record update.</description>
        <field>Calculate_Open_Meeting_Fees_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Set Calculate Open Meeting Fees</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_FMV_Tier_Exists_as_FALSE_MERC</fullName>
        <description>Set FMV Tier Exists to False is the Service Provider Tier is NULL.</description>
        <field>FMV_Tier_Exists_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Set FMV Tier Exists as FALSE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_FMV_Tier_Exists_to_TRUE_MERC</fullName>
        <description>Sets FMV Tier Exists to true based on most recent update where Service Provider Tier &lt;&gt; Blank.  Oliver Dunford 17th Feb 2014.</description>
        <field>FMV_Tier_Exists_MERC__c</field>
        <literalValue>1</literalValue>
        <name>Set FMV Tier Exists to TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_HCP_Country_of_Residence_Field</fullName>
        <description>Set HCP Country of Residence on Designated Individuals</description>
        <field>HCP_Country_of_Residence_MERC__c</field>
        <formula>TEXT(HCP_Designated_Individuals_MERC__r.Country_of_Residence_GLBL__c)</formula>
        <name>Set HCP Country of Residence Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_HCP_on_Cntry_of_Residence_MERC</fullName>
        <description>Set HCP Country of Residence on Contracting Parties</description>
        <field>HCP_Country_of_Residence_MERC__c</field>
        <formula>Text( HCP_Contracting_Party_MERC__r.Country_of_Residence_GLBL__c)</formula>
        <name>Set HCP on Cntry of Residence_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Service_Provider_Tier_1_MERC</fullName>
        <description>Sets Service Provider to Tier 1.  Once CV has been verified.  Oliver Dunford Jan 15th 2014.</description>
        <field>Service_Provider_Tier_MERC__c</field>
        <formula>IF(ISPICKVAL(Tier_1_HCP_CV_Checked_MERC__c, &quot;Confirmed HCP is Tier 1&quot;), 1, 

IF(ISPICKVAL(Tier_1_HCP_CV_Checked_MERC__c, &quot;HCP is NOT Tier 1&quot;), 2, NULL))</formula>
        <name>Set Service Provider Tier 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
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
    <fieldUpdates>
        <fullName>Stamp_User_Email_CUST</fullName>
        <description>Stamp the Account&apos;s Person Email to this field so it can be used in the workflow email alert.</description>
        <field>CST_Email_Stamp_CUST__c</field>
        <formula>PersonEmail</formula>
        <name>Stamp User Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Initiate_Tiering_Tier_1_MERC</fullName>
        <description>Unchecks the Initiate Tiering post execution of workflow.  Oliver Dunford 15th Jan 2014.</description>
        <field>Initiate_Tiering_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Initiate Tiering Tier 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CV_Tier_1_Check_MERC</fullName>
        <field>Tier_1_HCP_CV_Checked_MERC__c</field>
        <literalValue>Confirmed HCP is Tier 1</literalValue>
        <name>Update CV Tier 1 Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Calculate_Open_Fees_MERC</fullName>
        <description>Updates the Calculate Open Meeting Fees checkbox to ensure it&apos;s only set once. Oliver Dunford 9th Nov 2013.</description>
        <field>Calculate_Open_Meeting_Fees_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Update Calculate Open Fees</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
    <fieldUpdates>
        <fullName>Update_Tier_1_Criteria_Met_MERC</fullName>
        <description>Update the Tier 1 Criteria met if all Tier 3 criteria are met and 5 out of 8 Tier 1 criteria are met. Oliver Dunford 14th Jan 2014.</description>
        <field>Tier_1_Criteria_Met_MERC__c</field>
        <formula>IF(

AND( 

Tier_1_Score_MERC__c &gt;= 5, 

Tier_3_Criteria_Met_MERC__c = &quot;Yes&quot; 

),&quot;Yes&quot;, &quot;No&quot;

)</formula>
        <name>Update Tier 1 Criteria Met</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Tier_1_Score_MERC</fullName>
        <description>Updates Tier 1 score based on FMV rules. Oliver Dunford 14th Jan 2014.</description>
        <field>Tier_1_Score_MERC__c</field>
        <formula>IF(((TEXT(Practicing_for_MERC__c) = &quot;11-20 Years&quot;) || (TEXT(Practicing_for_MERC__c) = &quot;20+ Years&quot;)), 1, 0) + 
IF((TEXT(National_Inter_Leadership_Role_MERC__c ) = &quot;Yes&quot;), 1, 0) + 
IF(TEXT(Journal_Articles_MERC__c) = &quot;5+&quot;, 1,0) + 
IF(TEXT(Reviewer_or_Editor_MERC__c) = &quot;Yes&quot;, 1, 0) + 
IF(TEXT(Associate_or_Full_Professor_MERC__c) = &quot;Yes&quot;, 1, 0) + 
IF(TEXT( Clinical_Trial_PI_MERC__c ) = &quot;Yes - 2 or more&quot;, 1, 0) + 
IF(TEXT(Advisory_Board_Experience_MERC__c) = &quot;Yes&quot;, 1, 0) + 
IF(TEXT(Multiple_Specialties_MERC__c) = &quot;Yes&quot;, 1, 0)</formula>
        <name>Update Tier 1 Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Tier_2_Criteria_Met_MERC</fullName>
        <description>Updates the Criteria Met field if the Tier score is &gt;= 5. Oliver Dunford 14th Jan 2014.</description>
        <field>Tier_2_Criteria_Met_MERC__c</field>
        <formula>IF(AND(

Tier_2_Score_MERC__c &gt;= 5,

Tier_3_Criteria_Met_MERC__c = &quot;Yes&quot;

),&quot;Yes&quot;, &quot;No&quot;)</formula>
        <name>Update Tier 2 Criteria Met</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Tier_2_Score_MERC</fullName>
        <description>Updates Tier 2 Score based on FMV rule Criteria. Oliver Dunford 13th Jan 2014.</description>
        <field>Tier_2_Score_MERC__c</field>
        <formula>IF((TEXT(Practicing_for_MERC__c) = &quot;&lt;5 Years&quot;) || (ISBLANK(TEXT(Practicing_for_MERC__c))), 0, 1) + 
IF((TEXT(Regional_Leadership_Role_MERC__c ) = &quot;Yes&quot;) || (TEXT(National_Inter_Leadership_Role_MERC__c ) = &quot;Yes&quot;) || (TEXT(Hospital_Leadership_Role_MERC__c ) = &quot;Yes&quot;), 1, 0) + 
IF((TEXT(Journal_Articles_MERC__c) &lt;&gt; &quot;0-2&quot; &amp;&amp; !ISBLANK(TEXT(Journal_Articles_MERC__c))), 1,0) + 
IF( TEXT(Reviewer_or_Editor_MERC__c) = &quot;Yes&quot;, 1, 0) + 
IF((TEXT( Instructor_Assistant_Clinical_Prof_MERC__c ) = &quot;Yes&quot;) || (TEXT( Associate_or_Full_Professor_MERC__c ) = &quot;Yes&quot;), 1, 0) + 
IF((TEXT( Participated_in_Clinical_Trials_MERC__c ) = &quot;Yes&quot;) || (TEXT( Clinical_Trial_PI_MERC__c ) &lt;&gt; &quot;No&quot;) &amp;&amp; (!ISBLANK(TEXT( Clinical_Trial_PI_MERC__c ))), 1, 0) + 
IF(TEXT(Advisory_Board_Experience_MERC__c) = &quot;Yes&quot;, 1, 0) + 
IF(INCLUDES( Academic_Qualifications_MERC__c , &quot;MD Specialist&quot;), 1, 0)</formula>
        <name>Update Tier 2 Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Tier_3_Criteria_Met_MERC</fullName>
        <description>Update Tier 3 Criteria met based on Results. Oliver Dunford 13th Jan 2014.</description>
        <field>Tier_3_Criteria_Met_MERC__c</field>
        <formula>&quot;Yes&quot;</formula>
        <name>Update Tier 3 Criteria Met</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>RTI_Account_Updated</fullName>
        <apiVersion>29.0</apiVersion>
        <endpointUrl>https://gso1integration.xh1.lilly.com/rti/v1/genericUpdated</endpointUrl>
        <fields>CAP_Usage_Note_MERC__c</fields>
        <fields>Communication_Preference_MERC__c</fields>
        <fields>Contract_Limitations_on_Use_MERC__c</fields>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>Cust_Id_GLBL__c</fields>
        <fields>Employment_Specification_MERC__c</fields>
        <fields>FMV_Tier_Exists_MERC__c</fields>
        <fields>Has_MSA_Contract_MERC__c</fields>
        <fields>Id</fields>
        <fields>Institutional_Notif_Info_Exists_MERC__c</fields>
        <fields>IsPersonAccount</fields>
        <fields>LastModifiedById</fields>
        <fields>LastModifiedDate</fields>
        <fields>RTI_Transaction_ID_MERC__c</fields>
        <fields>RecordTypeId</fields>
        <fields>Service_Provider_MERC__c</fields>
        <fields>Transparency_Reporting_Opt_Out_MERC__c</fields>
        <fields>Utilised_CAP_MERC__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>mercuryintegration.veeva@gso1.lly</integrationUser>
        <name>RTI - Account Updated</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>CUST_Expire Manager Email</fullName>
        <actions>
            <name>Copy_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Flag_CST_Expire_Email_CUST__c</field>
            <operation>startsWith</operation>
            <value>MANAGER</value>
        </criteriaItems>
        <description>When a User Settings record is changed from &apos;New Request&apos; to &apos;Pending&apos; , The account field &apos;Flag CST Email&apos; is updated and then an email is sent to the manager : CUST : Created on 12/5/2013 by Sam Rosen, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Expiring_Auth_to_CST_Manager_CUST</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Clear_Manager_Expire_Email_Flag_CUST</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CUST_Manager Email</fullName>
        <actions>
            <name>Copy_Email_CUST</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Flag_CST_Email_CUST__c</field>
            <operation>startsWith</operation>
            <value>MANAGER</value>
        </criteriaItems>
        <description>When a User Settings record is changed from &apos;New Request&apos; to &apos;Pending&apos; , The account field &apos;Flag CST Email&apos; is updated so an email can be sent to the manager : CUST : Created on 12/5/2013 by Sam Rosen, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_email_to_Manager_CUST</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Clear_Email_Flag_CUST</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CUST_User Email</fullName>
        <actions>
            <name>User_Request_Status_Change_CUST</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_User_Email_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Stamp_User_Email_CUST</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Flag_CST_User_Email_CUST__c</field>
            <operation>startsWith</operation>
            <value>USER</value>
        </criteriaItems>
        <description>When a User Settings record status is changed, other than from &quot;New Request&quot;,  the account field &apos;Flag CST Email&apos; is updated so an email can be sent to the user : CUST : Created on 12/5/2013 by Sam Rosen, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Clear Calculate Open Meeting Fees</fullName>
        <actions>
            <name>Set_Calculate_Open_Meeting_Fees_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Calculate Open Meeting Fees checkbox after each record update : MERC : Created on 12/5/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Date Stamp CAP Usage Note</fullName>
        <actions>
            <name>Date_Stamp_CAP_Usage_Note_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to date stamp CAP usage note so that it you can judge if it&apos;s relevant or not : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>AND (NOT ISBLANK( CAP_Usage_Note_MERC__c ),  ISCHANGED(CAP_Usage_Note_MERC__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Date Stamp HCP Contract Limitations on Use</fullName>
        <actions>
            <name>Date_Stamp_HCP_Contract_Limitations</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to date stamp important information captured for the HCP. This should be date stamped for each post and passed via integration to Veeva : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>AND (NOT ISBLANK(  Contract_Limitations_on_Use_MERC__c  ), ISCHANGED( Contract_Limitations_on_Use_MERC__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Date Stamp HCP Executive Summary</fullName>
        <actions>
            <name>Date_Stamp_HCP_Exec_Smmry_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to date stamp important information captured for the HCP. This should be date stamped for each post and passed via integration to Veeva  : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>AND (NOT ISBLANK( Exec_Smmry_Note_MERC__c ), ISCHANGED( Exec_Smmry_Note_MERC__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_External ID-Account</fullName>
        <actions>
            <name>External_ID_Account_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_HCP_Info_Pack_Received_Date</fullName>
        <actions>
            <name>MERC_HCP_Info_Pack_Received_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.HCP_Info_Package_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>MERC - Populates &quot;HCP Received Date&quot; field with date on which &quot;HCP Info Pack Status&quot; is set to &quot;Submitted.&quot;  Created by Mike Cashman, Mavens Consulting on 3/3/15.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Non HCP Anonymise Record</fullName>
        <actions>
            <name>Clear_Email_Address_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Emergency_Contact_Name_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Emergency_Contact_Phone_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Fax_Phone_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Mobile_Number_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Work_Phone_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Anonymise_Record_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Clears down information about the Non HCP post the closure of the meeting that they attended.  This workflow clears down the Account object only : MERC : Created on 05/08/2014 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
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
    <rules>
        <fullName>MERC_Set FMV Tier Exists as FALSE</fullName>
        <actions>
            <name>Set_FMV_Tier_Exists_as_FALSE_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the FMV Tier Exists field to False should a Tier be Null post updates : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>(ISNEW() &amp;&amp;  ISBLANK(Service_Provider_Tier_MERC__c ))   ||   (ISCHANGED(Service_Provider_Tier_MERC__c ) &amp;&amp; ISBLANK(Service_Provider_Tier_MERC__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Set FMV Tier Exists as TRUE</fullName>
        <actions>
            <name>Set_FMV_Tier_Exists_to_TRUE_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the FMV Tier Exists field to True should a Tier be assigned to the HCP post Initiation of Tiering : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>(ISNEW() &amp;&amp;  !ISBLANK(Service_Provider_Tier_MERC__c ))   ||   (ISCHANGED(Service_Provider_Tier_MERC__c ) &amp;&amp; !ISBLANK(Service_Provider_Tier_MERC__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Stamp Country of Residence</fullName>
        <actions>
            <name>Set_HCP_Country_of_Residence_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Designated Individual,Contracting Party</value>
        </criteriaItems>
        <description>Stamps the HCP&apos;s Country of Residence onto their Corresponding Designated Individuals so that they can be included in the same Territory as the HCP : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
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
        <fullName>MERC_Tier Step 2%3A Manage CV Check if Tier 1</fullName>
        <actions>
            <name>Set_Service_Provider_Tier_1_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Once a HCP&apos;s CV has been verified, set the Service Provider Tier to 1. If their CV is not acceptable they&apos;re set to Tier 2 : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Tier_1_HCP_CV_Checked_MERC__c) &amp;&amp;   (  ISPICKVAL(Tier_1_HCP_CV_Checked_MERC__c, &quot;Confirmed HCP is Tier 1&quot;) ||   ISPICKVAL(Tier_1_HCP_CV_Checked_MERC__c, &quot;HCP is NOT Tier 1&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
=======
>>>>>>> develop_april_release
    <rules>
        <fullName>RTI - Account Updated</fullName>
        <actions>
            <name>RTI_Account_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>(NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;))) &amp;&amp; (
(NOT(ISNEW()) &amp;&amp; NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)) &amp;&amp; NOT(CONTAINS(LastModifiedBy.Username,&apos;gso1.informatica@&apos;))) 
|| (NOT(ISNEW()) 
&amp;&amp; ISCHANGED(Transparency_Reporting_Opt_Out_MERC__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
