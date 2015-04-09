<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Non_HCP_participant_approval</fullName>
        <description>A Non-HCP participant has been created for a meeting and email requesting Managerial Approval will be sent.</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/Non_HCP_Approval_MERC</template>
    </alerts>
    <alerts>
        <fullName>Notifies_Meeting_Owner_of_Final_Fee</fullName>
        <description>Notifies Meeting Owner of Final Fee</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/Final_Fee_Calculation_Email</template>
    </alerts>
    <alerts>
        <fullName>Notify_Meeting_Owner_when_Tiering_is_Complete</fullName>
        <description>Notify Meeting Owner when Tiering is Complete</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/Tier_Calculation_Complete</template>
    </alerts>
    <alerts>
        <fullName>Notify_the_Primary_Meeting_Owner_of_Signed_Contract</fullName>
        <description>Notify the Primary Meeting Owner of Signed Contract</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/Contract_Signed_MERC</template>
    </alerts>
    <alerts>
        <fullName>Reminder_Service_Not_Rendered</fullName>
        <description>Reminder - Service Not Rendered</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/Reminder_Services_Not_Rendered</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Confirm_Partial_Payment_Amt_MERC</fullName>
        <description>Set the Confirm Partial Payment Amount checkbox to False. Created 12/18/2013 by KLorenti, Mavens Consulting</description>
        <field>Confirm_Partial_Payment_Amount_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Clear Confirm Partial Payment Amt_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Confirm_ToV_Reporting_Change_MERC</fullName>
        <description>Set Confirm ToV Reporting Change checkbox to FALSE after each record update.</description>
        <field>Confirm_ToV_Reporting_Change_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Clear Confirm ToV Reporting Change_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
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
        <fullName>MERC_Maximum_Fee_last_modify</fullName>
        <description>To capture last modify date when Maximum Fee has been modified.</description>
        <field>Maximum_Fee_last_updated_MERC__c</field>
        <formula>PRIORVALUE( Maximum_Fee_current_time_updated_MERC__c )</formula>
        <name>MERC_Maximum_Fee_last_modify</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Maximum_Fee_modify_date</fullName>
        <description>To capture current time stamp when maximum fee has been modified.</description>
        <field>Maximum_Fee_current_time_updated_MERC__c</field>
        <formula>NOW()</formula>
        <name>MERC_Maximum_Fee_modify_date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Set_Services_Rendered_Date</fullName>
        <description>Sets the Services Rendered Date to today when Services Rendered is set to Yes</description>
        <field>Date_Services_Rendered_set_to_Yes_MERC__c</field>
        <formula>Today()</formula>
        <name>MERC_Set_Services_Rendered_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Participant_Type_MERC</fullName>
        <description>Populates the Participant Type field in the Meeting Participant based on value in Account</description>
        <field>Participant_Typ_MERC__c</field>
        <formula>Account_MERC__r.RecordType.Name</formula>
        <name>Populate Participant Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Final_Fee_MERC</fullName>
        <description>Remove Final Fee</description>
        <field>Final_Fee_MERC__c</field>
        <name>Remove Final Fee_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Air_Travel_No_Longer_Required_MERC</fullName>
        <description>Update &quot;Air Travel No Longer Required&quot; to &quot;None&quot;</description>
        <field>Air_Travel_No_Longer_Required_MERC__c</field>
        <name>Reset Air Travel No Longer Required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Travel_by_Air_MERC</fullName>
        <description>Update &quot;Travel by Air&quot; to &quot;None&quot;</description>
        <field>Travel_by_Air_MERC__c</field>
        <name>Reset Travel by Air</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Round_Prep_Time_to_Nearest_Half_Hour</fullName>
        <description>Mercury Release 2 Update to round to nearest 15minutes rather than 30mins.</description>
        <field>Preparation_Time_Hrs_MERC__c</field>
        <formula>(ROUND(Preparation_Time_Hrs_MERC__c * 4,0)) / 4</formula>
        <name>Round Prep Time to Nearest Half Hour</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rounds_Event_Time_to_Nearest_Half_Hour</fullName>
        <description>Mercury Release 2 Update to Rounds Event Time to nearest 15 minutes, rather than 30mins.</description>
        <field>Event_Time_Hrs_MERC__c</field>
        <formula>(ROUND(Event_Time_Hrs_MERC__c * 4,0)) / 4</formula>
        <name>Rounds Event Time to Nearest Half Hour</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_CoPay_Updated_DateTime_MERC</fullName>
        <description>Sets the CoPay Updates Date/Time field to NOW().  Indicating that CoPay has been updated so that AODS can pull the information. Oliver Dunford 11th Feb 2014.</description>
        <field>Participant_CoPay_Updated_Date_MERC__c</field>
        <formula>NOW()</formula>
        <name>Set CoPay Updated DateTime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Meeting_Owner_Email_MERC</fullName>
        <field>Meeting_Owner_Email_MERC__c</field>
        <formula>Meeting_MERC__r.Meeting_Owner_Email_MERC__c</formula>
        <name>Set Meeting Owner Email_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Participant_ToV_Update_Date_MERC</fullName>
        <description>Updates Participant ToV Update Date on Meeting when ToV corrections are made to trigger update/resend to AODS.</description>
        <field>Participant_ToV_Updated_Date_MERC__c</field>
        <formula>Now()</formula>
        <name>Set Participant ToV Update Date_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Purpose_of_Payment_to_Expenses_MERC</fullName>
        <description>Sets Purpose of Payment picklist to &quot;Expenses&quot;</description>
        <field>Purpose_of_Payment_MERC__c</field>
        <literalValue>Expenses</literalValue>
        <name>Set Purpose of Payment to Expenses_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
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
        <fullName>Update_Final_Fee_Zero_MERC</fullName>
        <description>Update Final Fee to Zero if no payment is required.</description>
        <field>Final_Fee_MERC__c</field>
        <formula>0</formula>
        <name>Update_Final_Fee_Zero</name>
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
        <fullName>Update_Final_Fee_with_Partial_Pymt_MERC</fullName>
        <description>Update Final Fee with the Partial Payment Amount.  Used by HCP Care only. Created 12/18/2013 by KLorenti, Mavens Consulting</description>
        <field>Final_Fee_MERC__c</field>
        <formula>Partial_Payment_Amount_MERC__c</formula>
        <name>Update Final Fee with Partial Payment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <fullName>Update_Maximum_Fee_MERC</fullName>
        <description>Updates Maximum Fee based on Maximum Hourly Rate multiplied by Total Hours of Service, Includes Travel Adjustment.</description>
        <field>Maximum_Fee_MERC__c</field>
        <formula>Round((Maximum_Rate_MERC__c * Total_Hours_of_Service_MERC__c) * (Travel_Adjustment_Percentage_MERC__c + 1),2)</formula>
        <name>Update Maximum Fee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <fullName>Update_Minimum_Fee_MERC</fullName>
        <description>Updates the Minimum Fee based on the Minimum Hourly Rate multiplied by the Total Hours of Service incorporating Travel Adjustment.</description>
        <field>Minimum_Fee_MERC__c</field>
        <formula>Round((Minimum_Rate_MERC__c * Total_Hours_of_Service_MERC__c) * ( Travel_Adjustment_Percentage_MERC__c + 1),2)</formula>
        <name>Update Minimum Fee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <fullName>Update_Participant_Countries_MERC</fullName>
        <description>Updates the Meeting Associated Countries field if the Meeting Country of existing Associated Countries are different from that of the HCPs Associated Countries.  Oliver Dunford 14th April 2014.</description>
        <field>Associated_Countries_MERC__c</field>
        <formula>Meeting_MERC__r.Associated_Countries_MERC__c + &quot;,&quot; + TEXT(Account_MERC__r.Country_of_Residence_GLBL__c)</formula>
        <name>Update Participant Countries</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Participant_Status_Change_MERC</fullName>
        <description>Updates Participant Status Change Post ToV to TRUE</description>
        <field>Status_Change_Post_ToV_Final_MERC__c</field>
        <literalValue>1</literalValue>
        <name>Update Participant Status Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Participant_ToV_Date_MERC</fullName>
        <description>Updates the Participant ToV Updated Date/Time with the current time to indicate a ToV Change.  Oliver Dunford 11th Feb 2014.</description>
        <field>Participant_ToV_Updated_Date_MERC__c</field>
        <formula>NOW()</formula>
        <name>Update Participant ToV Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Participant_ToV_Update_Date_MERC</fullName>
        <description>Update Participant ToV Update Date with Current Date/Time</description>
        <field>Participant_ToV_Updated_Date_MERC__c</field>
        <formula>Now()</formula>
        <name>Update Participant ToV Update Date_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Payment_Required_for_Svcs_MERC</fullName>
        <description>If Payment is not required, update to &quot;No&quot;. Created 12/13/2013 by KLorenti, Mavens Consulting</description>
        <field>Payment_Required_for_Meeting_MERC__c</field>
        <literalValue>No</literalValue>
        <name>Update Payment Required for Services</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <fullName>Update_Total_Hours_of_Service_MERC</fullName>
        <description>Calculates the Total Hours of Service based on Event Time + Preparation Time.</description>
        <field>Total_Hours_of_Service_MERC__c</field>
        <formula>IF(ISBLANK(Preparation_Time_Hrs_MERC__c), 0, Preparation_Time_Hrs_MERC__c) + IF(ISBLANK(Event_Time_Hrs_MERC__c), 0, Event_Time_Hrs_MERC__c)</formula>
        <name>Update Total Hours of Service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Travel_Adjustment_Amount</fullName>
        <description>Update when Final Fee is confirmed</description>
        <field>Travel_Adjustment_Amount_MERC__c</field>
        <formula>Proposed_Final_Fee_MERC__c *  Travel_Adjustment_Percentage_MERC__c</formula>
        <name>Update Travel Adjustment Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unique_Participant_MERC</fullName>
        <description>Updates the force unique participant with the Account Id and Meeting Id. Oliver Dunford 4th November.</description>
        <field>Force_Unique_Participant_MERC__c</field>
        <formula>CASESAFEID(Account_MERC__c)  &amp; &quot; - &quot; &amp; CASESAFEID(Meeting_MERC__c)</formula>
        <name>Update Unique Participant</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>RTI_Meeting_Participant_Updated</fullName>
        <apiVersion>29.0</apiVersion>
        <endpointUrl>https://gso1integration.xh1.lilly.com/rti/v1/genericUpdated</endpointUrl>
        <fields>Account_External_MERC__c</fields>
        <fields>Account_MERC__c</fields>
        <fields>Active_on_Web_Service_MERC__c</fields>
        <fields>Air_Travel_Required_MERC__c</fields>
        <fields>Amount_to_be_Paid_MERC__c</fields>
        <fields>Associated_Countries_MERC__c</fields>
        <fields>Confirm_Final_Fee_MERC__c</fields>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>Description_of_Service_MERC__c</fields>
        <fields>Email_to_Invite_HCP_to_Portal_MERC__c</fields>
        <fields>Event_Time_Hrs_MERC__c</fields>
        <fields>Final_Fee_MERC__c</fields>
        <fields>Has_Signed_Contract_MERC__c</fields>
        <fields>Hotel_Required_MERC__c</fields>
        <fields>Id</fields>
        <fields>Items_to_be_Sponsored_MERC__c</fields>
        <fields>Justification_MERC__c</fields>
        <fields>LastModifiedById</fields>
        <fields>LastModifiedDate</fields>
        <fields>Maximum_Fee_MERC__c</fields>
        <fields>Meeting_External_MERC__c</fields>
        <fields>Mercury_External_Id_MERC__c</fields>
        <fields>Minimum_Fee_MERC__c</fields>
        <fields>Name</fields>
        <fields>Preparation_Time_Hrs_MERC__c</fields>
        <fields>Proposed_Final_Fee_MERC__c</fields>
        <fields>RTI_Transaction_ID_MERC__c</fields>
        <fields>RecordTypeId</fields>
        <fields>Record_Type_MERC__c</fields>
        <fields>Record_Type_Name_MERC__c</fields>
        <fields>Sales_Rep_MERC__c</fields>
        <fields>Services_Rendered_MERC__c</fields>
        <fields>Source_MERC__c</fields>
        <fields>Status_MERC__c</fields>
        <fields>Topic_Area_MERC__c</fields>
        <fields>Total_Hours_of_Service_MERC__c</fields>
        <fields>Travel_Time_Hrs_MERC__c</fields>
        <fields>Trtry_Cd_MERC__c</fields>
        <fields>Trtry_Desc_MERC__c</fields>
        <fields>Type_of_Contract_MERC__c</fields>
        <fields>Types_of_Service_MERC__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>mercuryintegration.veeva@gso1.lly</integrationUser>
        <name>RTI - Meeting Participant Updated</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>MERC_Calculate Min%2FMax Fee and Total Hrs of Service</fullName>
        <actions>
            <name>Update_Maximum_Fee_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Minimum_Fee_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Total_Hours_of_Service_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Calculates the Minimum Fee, Maximum Fee and Total Hours of Service for records based upon Minimum and Maximum Hourly Rates  : MERC : Created on 12/5/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISNEW() ||   (     ISCHANGED( Event_Time_Hrs_MERC__c ) ||      ISCHANGED( Travel_Time_Hrs_MERC__c ) ||     ISCHANGED( Preparation_Time_Hrs_MERC__c ) ||    ISCHANGED( Minimum_Rate_MERC__c ) ||    ISCHANGED( Maximum_Rate_MERC__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Clear Confirm ToV Change</fullName>
        <actions>
            <name>Clear_Confirm_ToV_Reporting_Change_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Confirm ToV Reporting Change checkbox after each record update : MERC : Created on 12/5/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>Confirm_ToV_Reporting_Change_MERC__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_External ID-MeetingParticipant</fullName>
        <actions>
            <name>External_ID_MeetingParticipant_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Final Fee Rejected</fullName>
        <active>true</active>
        <description>Notify the Meeting Owner when the Final Fee has been rejected due to surpassing the maximum fee threshold : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Higher_Fee_Approval__c) &amp;&amp; ISPICKVAL(Higher_Fee_Approval__c,&quot;Rejected&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Flag Account as Service Provider</fullName>
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
        <description>When Account is used as Service Provider, update Service Provider flag on HCP Profile  : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Include_Cap_Rollup</fullName>
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
        <description>If the Type of Service is Medical Research, Set &quot;Include In Cap Rollup&quot; checkbox to &quot;false&quot;  : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Is Payment Required</fullName>
        <actions>
            <name>Update_Payment_Required_for_Svcs_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Payment_Required_MERC__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <description>If Payment is not required, update to &quot;No&quot;  : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Maximum_Fee_last_modify_date_captured</fullName>
        <actions>
            <name>MERC_Maximum_Fee_last_modify</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MERC_Maximum_Fee_modify_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To capture the last date of modification of field Maximum Fee on Meeting Participant object.</description>
        <formula>OR(
     ISNEW(),
     AND(
          NOT(ISNEW()),
          ISCHANGED( Maximum_Fee_MERC__c )
     )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Non-HCP Approval</fullName>
        <actions>
            <name>Non_HCP_participant_approval</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Non-HCP</value>
        </criteriaItems>
        <description>When a participant is created who is NOT a HCP, an automated email should be triggered to the Meeting Manager who should approve the Participant before they can be utilised for meetings : MERC : Created on 11/12/2013 by John Adams, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Notify Meeting Owner Tiering Complete</fullName>
        <actions>
            <name>Notify_Meeting_Owner_when_Tiering_is_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies Meeting Owner when Tiering has been completed and the Proposed Fee may be entered : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>Service_Provider_Tier_MERC__c &gt; 0 &amp;&amp; ISCHANGED(Maximum_Rate_MERC__c) &amp;&amp; Maximum_Rate_MERC__c &gt; 0 &amp;&amp; ISCHANGED(Minimum_Rate_MERC__c) &amp;&amp; Minimum_Rate_MERC__c &gt; 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
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
( !ISNEW() &amp;&amp; (ISBLANK(PRIORVALUE(Maximum_Fee_MERC__c)) || PRIORVALUE(Maximum_Fee_MERC__c) = 0)) &amp;&amp; (!ISBLANK(Maximum_Fee_MERC__c) &amp;&amp; Maximum_Fee_MERC__c &lt;&gt;0) &amp;&amp; (ISBLANK(PRIORVALUE(Minimum_Fee_MERC__c)) || PRIORVALUE(Minimum_Fee_MERC__c) = 0) &amp;&amp; !ISBLANK(Minimum_Fee_MERC__c) &amp;&amp; ISPICKVAL(Confirm_Final_Fee_MERC__c,&apos;Pending Confirmation&apos;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Notify the Primary Meeting Owner of Signed Contract</fullName>
        <actions>
            <name>Notify_the_Primary_Meeting_Owner_of_Signed_Contract</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies the Primary Meeting Owner of a Signed Contract : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>(ISCHANGED(Number_of_Completed_Contracts_MERC__c) &amp;&amp; Number_of_Completed_Contracts_MERC__c = 1)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Over Maximum Fee</fullName>
        <actions>
            <name>Update_Confirm_Final_Fee_to_Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Higher_Fee_Approval_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Proposed Final Fee is over the Maximum Fee set the Exception Approval = Required  : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISCHANGED (Proposed_Final_Fee_MERC__c ) &amp;&amp;  Proposed_Final_Fee_MERC__c &gt; Maximum_Fee_MERC__c &amp;&amp;(NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Override Final Fee for Partial Payment</fullName>
        <actions>
            <name>Update_Final_Fee_with_Partial_Pymt_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If HCP is due a Partial Payment, set the Final Fee to the Partial Payment amount  : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISCHANGED(Partial_Payment_Amount_MERC__c) &amp;&amp; Partial_Payment_Amount_MERC__c &gt; 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Participant Type</fullName>
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
        <description>Records participant type when record is created or edited : MERC : Created on 01/26/2013 by Katy Lorenti, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Reminder - Services Not Rendered</fullName>
        <active>true</active>
        <description>Notifies Primary Meeting Owner and Customer Facing User, if applicable, to let them know that the Services Rendered is not equal to Yes and it has been 5 days past the end of the meeting : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>(ISPICKVAL(Services_Rendered_MERC__c,&apos;No&apos; ) ||   ISPICKVAL(Services_Rendered_MERC__c,&apos;&apos; ))  &amp;&amp; RecordType.Name  = &apos;Service Provider&apos;  &amp;&amp; ISPICKVAL(Status_MERC__c, &apos;Cancelled&apos;) = FALSE  &amp;&amp; ISPICKVAL(Status_MERC__c, &apos;Declined&apos;) = FALSE  &amp;&amp; ISPICKVAL(Meeting_MERC__r.Meeting_Status_MERC__c, &apos;Complete - Cancelled&apos;) = FALSE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_Service_Not_Rendered</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Meeting_Participant_MERC__c.Meeting_End_Date_MERC__c</offsetFromField>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MERC_Remove Final Fee if Partial Payment is Zero</fullName>
        <actions>
            <name>Remove_Final_Fee_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Remove Final Fee if Partial Payment is set to zero : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISCHANGED(Partial_Payment_Amount_MERC__c) &amp;&amp; Partial_Payment_Amount_MERC__c = 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Reset Air Travel</fullName>
        <actions>
            <name>Reset_Air_Travel_No_Longer_Required_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Travel_by_Air_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the &quot;Air Travel Required&quot; field is changed from Yes to No, the &quot;Air Travel No Longer Required&quot; and &quot;Travel by Air&quot; fields should be set to None. This is to make sure the correct options are displayed on the Web Service.</description>
        <formula>ISCHANGED(Air_Travel_Required_MERC__c) &amp;&amp;  TEXT(Air_Travel_Required_MERC__c) = &quot;No&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Round to Nearest Half Hour</fullName>
        <actions>
            <name>Round_Prep_Time_to_Nearest_Half_Hour</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Rounds_Event_Time_to_Nearest_Half_Hour</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Round Preparation Time and Event Time to nearest 15 minutes, changed in Mercury Release 2 from 30 minute rounding : MERC : Created on 21/07/2014 by Oliver Dunford, Mavens Consulting</description>
        <formula>(Preparation_Time_Hrs_MERC__c - FLOOR(Preparation_Time_Hrs_MERC__c) &lt;&gt; 0.25 &amp;&amp;  Preparation_Time_Hrs_MERC__c - FLOOR(Preparation_Time_Hrs_MERC__c) &lt;&gt; 0.50 &amp;&amp;  Preparation_Time_Hrs_MERC__c - FLOOR(Preparation_Time_Hrs_MERC__c) &lt;&gt; 0.75 &amp;&amp;  Preparation_Time_Hrs_MERC__c - FLOOR(Preparation_Time_Hrs_MERC__c) &lt;&gt; 0.00)  ||  (Event_Time_Hrs_MERC__c - FLOOR(Event_Time_Hrs_MERC__c ) &lt;&gt; 0.25 &amp;&amp;  Event_Time_Hrs_MERC__c - FLOOR(Event_Time_Hrs_MERC__c ) &lt;&gt; 0.50 &amp;&amp;  Event_Time_Hrs_MERC__c - FLOOR(Event_Time_Hrs_MERC__c ) &lt;&gt; 0.75 &amp;&amp;  Event_Time_Hrs_MERC__c - FLOOR(Event_Time_Hrs_MERC__c ) &lt;&gt; 0.00)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Set Meeting Owner Email</fullName>
        <actions>
            <name>Set_Meeting_Owner_Email_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the Meeting Owner email address on each meeting participant record when changed on the Meeting : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>NOT ISBLANK( Meeting_MERC__r.Meeting_Owner_Email_MERC__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Set Purpose of Payment to Expenses</fullName>
        <actions>
            <name>Set_Purpose_of_Payment_to_Expenses_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Delegate</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Individual Sponsorship</value>
        </criteriaItems>
        <description>Sets Purpose of Payment to Expenses if Meeting Participant is of Type Delegate or Individual Sponsorship : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Set_Services_Rendered_Date</fullName>
        <actions>
            <name>MERC_Set_Services_Rendered_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the Date that the Services Rendered field was set to Yes.  This is used for SLA reporting : MERC : Created on 26/02/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Services_Rendered_MERC__c ) &amp;&amp; TEXT(Services_Rendered_MERC__c) = &quot;Yes&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Trigger CoPay AODS Update</fullName>
        <actions>
            <name>Set_CoPay_Updated_DateTime_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This fires when any of the CoPay fields on the Meeting Participant are changed or updated.  This will ensure that any changes are picked up by AODS : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>(ISBLANK(PRIORVALUE(CoPay_Flight_Rail_MERC__c)) &amp;&amp; !ISBLANK(CoPay_Flight_Rail_MERC__c))        || ISCHANGED(CoPay_Flight_Rail_MERC__c) ||    (ISBLANK(PRIORVALUE( CoPay_Food_Beverage_MERC__c )) &amp;&amp; !ISBLANK( CoPay_Food_Beverage_MERC__c ))       || ISCHANGED( CoPay_Food_Beverage_MERC__c ) ||    (ISBLANK(PRIORVALUE(CoPay_Ground_Transport_MERC__c)) &amp;&amp; !ISBLANK(CoPay_Ground_Transport_MERC__c))     || ISCHANGED(CoPay_Ground_Transport_MERC__c) ||    (ISBLANK(PRIORVALUE(CoPay_Hotel_MERC__c )) &amp;&amp; !ISBLANK(CoPay_Hotel_MERC__c ))    || ISCHANGED(CoPay_Hotel_MERC__c ) ||    (ISBLANK(PRIORVALUE(CoPay_Registration_MERC__c)) &amp;&amp; !ISBLANK(CoPay_Registration_MERC__c))      || ISCHANGED(CoPay_Registration_MERC__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Trigger ToV AODS Update</fullName>
        <actions>
            <name>Update_Participant_ToV_Date_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Triggers to set the Participant ToV Update date/time when the Meeting Participants ToV values change, indicating that this information should be pulled into AODS : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>(    ISNEW()    || ISCHANGED(Total_Food_Beverage_ToV_MERC__c)     || ISCHANGED( Total_Ground_Transporation_ToV_MERC__c )     || ISCHANGED(Total_Hotel_ToV_MERC__c)     || ISCHANGED(Total_Registration_ToV_MERC__c)   )  &amp;&amp;  TEXT(Meeting_MERC__r.Participant_ToV_Final_MERC__c) = &quot;Yes&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Un-Confirm Final Fee</fullName>
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
        <description>If the Confirm Final Fee &lt;&gt; Confirmed, reset Final Fee amount back to zero : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Under Maximum Fee</fullName>
        <actions>
            <name>Update_Confirm_Final_Fee_to_Pending_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Exception_Approval_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Proposed Final Fee is lass than the Maximum Fee then set the Exception Approval to &quot;Not Required&quot; : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED (Proposed_Final_Fee_MERC__c ) &amp;&amp;  Proposed_Final_Fee_MERC__c &lt; Maximum_Fee_MERC__c &amp;&amp;(NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Associated Countries</fullName>
        <actions>
            <name>Update_Participant_Countries_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Associated Countries field on the Meeting when the HCPs Country of Residence differs from that of the Meeting.  This may then need to be sent to another Veeva Org : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>NOT(CONTAINS( Meeting_MERC__r.Associated_Countries_MERC__c,  TEXT(Account_MERC__r.Country_of_Residence_GLBL__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Final Fee</fullName>
        <actions>
            <name>Update_Final_Fee_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Travel_Adjustment_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Final Fee once confirmed with the HCP or Affiliate  : MERC : Created on 12/03/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>AND (ISCHANGED( Confirm_Final_Fee_MERC__c ) ,  ISPICKVAL(Confirm_Final_Fee_MERC__c, &quot;Confirmed&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Final Fee to Zero</fullName>
        <actions>
            <name>Update_Final_Fee_Zero_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.Payment_Required_for_Meeting_MERC__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.Confirm_Final_Fee_MERC__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <description>Update Final Fee to Zero if Fee is confirmed and Payment Required is changed to No : MERC : Created on 12/03/2013 by Katy Lorenti, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Meeting Participant Search</fullName>
        <actions>
            <name>Update_Meeting_Participant_Search_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the meeting participant search field with a searchable string : MERC : Created on 11/05/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Participant ToV Update Date</fullName>
        <actions>
            <name>Set_Participant_ToV_Update_Date_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.Confirm_ToV_Reporting_Change_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update Participant ToV Update Date on Meeting when ToV values are changed on Meeting participant  : MERC : Created on 01/10/2014 by Katy Lorenti, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Status Change Post ToV Final</fullName>
        <actions>
            <name>Update_Participant_Status_Change_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Status Change Post ToV Final Field if Participant Status changes to No Show post sending data to AODS  : MERC : Created on 03/10/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISCHANGED( Status_MERC__c ) &amp;&amp; ISPICKVAL(Status_MERC__c,&quot;No Show&quot;) &amp;&amp; ISPICKVAL(Meeting_MERC__r.Participant_ToV_Final_MERC__c, &quot;Yes&quot;) &amp;&amp;  Status_Change_Post_ToV_Final_MERC__c = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Unique Meeting Participant</fullName>
        <actions>
            <name>Update_Unique_Participant_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Unique Participant text field to enforce Participant Uniqueness for a Meeting  : MERC : Created on 01/10/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RTI - Meeting Participant  Updated</fullName>
        <actions>
            <name>RTI_Meeting_Participant_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>(NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;))) &amp;&amp; ( (NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)) || ISCHANGED( Maximum_Fee_MERC__c ) || (NOT(ISBLANK(Maximum_Fee_MERC__c))  &amp;&amp; ISNEW()))  &amp;&amp; NOT(ISBLANK( Account_External_MERC__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
