<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Advisory_Board_Notification</fullName>
        <description>Notify Meeting Owner about an Advisory Board Meeting need for approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/Approval_Required_MERC</template>
    </alerts>
    <alerts>
        <fullName>Meeting_Status_Changed</fullName>
        <description>Notify Meeting Owner when Meeting Status is changed from Forecasted to Cancelled</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/Cancelled_Meeting_MERC</template>
    </alerts>
    <alerts>
        <fullName>Notification_email_of_Non_Compliant_Meeting</fullName>
        <description>Notification email of Non Compliant Meeting</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/Non_Compliant_Notification_MERC</template>
    </alerts>
    <alerts>
        <fullName>Scientific_Exchange_Approval_Request</fullName>
        <description>Scientific Exchange Approval Request</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/Scientific_Exchange_Request_for_Approval_MERC</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_Manager</fullName>
        <description>Send email to Manager</description>
        <protected>false</protected>
        <recipients>
            <recipient>o&apos;brien_abby@gso1.lly</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ContactFollowUpSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>Two_week_compliance_notification_to_Meeting_Owner</fullName>
        <description>Two week compliance notification to Meeting Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/Two_week_Compliance_Notification_to_Owner</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Meeting_Cancellation_Date_MERC</fullName>
        <description>If Meeting is changed from Cancelled to another status, update the Meeting Cancellation Date to blank. Created 12/19/2013 by KLorenti, Mavens Consulting</description>
        <field>Meeting_Cancellation_Date_MERC__c</field>
        <name>Clear Meeting Cancellation Date_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>External_ID_Meeting_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Meeting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lock_Meeting_MERC</fullName>
        <description>Meeting is set to Locked once the status changes to Complete - Closed.</description>
        <field>Lock_Meeting_MERC__c</field>
        <literalValue>1</literalValue>
        <name>Lock Meeting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Update_Confirm_Web_Service_Change</fullName>
        <description>Sets confirm on web service to false once chnges have been applied by CMS Cork : MERC : Created on 22/07/2014 by Oliver Dunford, Mavens Consulting</description>
        <field>Confirm_Web_Service_Change_MERC__c</field>
        <literalValue>0</literalValue>
        <name>MERC_Update_Confirm_Web_Service_Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Send_Meeting_Team</fullName>
        <description>If Meeting Canceled = True then sets the field Send Meeting Team Cancelation to True - else False</description>
        <field>Send_Meeting_Team_Cancelled_Email_MERC__c</field>
        <formula>IF(ISPICKVAL(Meeting_Status_MERC__c,&quot;Complete - Cancelled&quot;),&quot;TRUE&quot;,&quot;FALSE&quot;)</formula>
        <name>Send Meeting Team</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Meeting_Cancellation_Date_MERC</fullName>
        <description>Updates Meeting Cancellation Date with the Date the Meeting is Cancelled. Created 12/19/2013 by KLorenti, Mavens Consulting</description>
        <field>Meeting_Cancellation_Date_MERC__c</field>
        <formula>Today()</formula>
        <name>Set Meeting Cancellation Date_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Initiate_Venue_Sourcing_Date_Time</fullName>
        <description>Stamps when &quot;Initiate Sourcing&quot; is checked to initiate venue sourcing.</description>
        <field>Initiate_Venue_Sourcing_Date_Time_MERC__c</field>
        <formula>now()</formula>
        <name>Stamp Initiate Venue Sourcing Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Associated_Countries_MERC</fullName>
        <description>Updates associated Countries based on new records or changes. Oliver Dunford 14th April 2014.</description>
        <field>Associated_Countries_MERC__c</field>
        <formula>IF( ISBLANK( Associated_Countries_MERC__c ) , 

	TEXT(Event_Country_MERC__c), 

		IF(CONTAINS(Associated_Countries_MERC__c, TEXT(Event_Country_MERC__c)), 

			Associated_Countries_MERC__c, Associated_Countries_MERC__c + &quot;,&quot; + TEXT(Event_Country_MERC__c)

	)

)</formula>
        <name>Update Associated Countries_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Budget_Final_Date_Time_MERC</fullName>
        <description>Stamps Date/Time that Budget becomes final.</description>
        <field>Budget_Final_Date_Time_MERC__c</field>
        <formula>now()</formula>
        <name>Update Budget Final Date/Time_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Confirm_Cancellation_Change_Check</fullName>
        <description>Updates the &quot;Confirm Meeting Cancellation&quot; checkbox to False. Created 11/19/2013 by KLorenti, Mavens Consulting</description>
        <field>Confirm_Meeting_Cancellation_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Update Confirm Cancellation Change Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Confirm_ToV_Change_MERC</fullName>
        <description>Update &quot;Confirm ToV Change&quot; checkbox to FALSE after each record update. Created 10/06/2014 by ODunford, Mavens Consulting</description>
        <field>Confirm_ToV_Reporting_Change_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Update Confirm ToV Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Confirmation_of_Complete_Inv_MERC</fullName>
        <description>Updates Confirmation of Complete Invoice Date/time. Used for SLA reporting. Created 04/09/2014 by KLorenti, Mavens Consulting</description>
        <field>Confirmation_Comp_Invoice_Dt_Tm_MERC__c</field>
        <formula>now()</formula>
        <name>Update Confirmation of Complete Inv_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Event_Id_MERC</fullName>
        <description>Updated the Event Id Meeting AutoNumberCountryCodeYY. Oliver Dunford 7th Jan 2014.</description>
        <field>Event_Id_MERC__c</field>
        <formula>Meeting_Auto_Nmber_MERC__c &amp; TEXT(Event_Country_MERC__c) &amp;  RIGHT(TEXT(YEAR(Today())),2)</formula>
        <name>Update Event Id_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Formatted_Name</fullName>
        <description>Update Formatted Name field based certain meeting attributes</description>
        <field>Formatted_Name_MERC__c</field>
        <formula>Text(Event_Country_MERC__c) &amp;

&quot;-&quot;&amp;  

TEXT(YEAR(DATEVALUE(Start_Time_of_Meeting_MERC__c))) &amp; Text(MONTH(DATEVALUE(Start_Time_of_Meeting_MERC__c ))) &amp; TEXT(DAY(DATEVALUE(Start_Time_of_Meeting_MERC__c ))) &amp;

&quot;-&quot; &amp; 

Meeting_Type_Abbreviation_MERC__c &amp; 

&quot;-&quot; &amp; 

Name</formula>
        <name>Update Formatted Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Master_Owner_Id_MERC</fullName>
        <description>Updates Master Owner Id from Account for Reps profile of User record for Mercury Meeting Owner.  Oliver Dunford 12th Feb 2014.</description>
        <field>Owner_Master_Id_MERC__c</field>
        <formula>IF(ISBLANK( Sales_Rep_MERC__c ),  Owner:User.Prsnl_Nbr_GLBL__c ,  Sales_Rep_MERC__r.Prsnl_Nbr_GLBL__c )</formula>
        <name>Update Master Owner Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Master_Worker_Country_Cd_MERC</fullName>
        <description>Updates Owner Master Country Code for AODS Interface.  Oliver Dunford 12th feb 2014.</description>
        <field>Work_Cntry_Cd_GLBL__c</field>
        <formula>IF(ISBLANK( Sales_Rep_MERC__c ),   TEXT(Owner:User.Country_of_Residence_MERC__c)  ,  TEXT(Sales_Rep_MERC__r.Country_of_Residence_GLBL__c)  )</formula>
        <name>Update Master Worker Country Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Meeting_Date_Change_Check_MERC</fullName>
        <description>Clear the &quot;Confirm Meeting Date Change&quot; Checkbox after record is updated.</description>
        <field>Confirm_Meeting_Date_Change_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Update Confirm Meeting Date Change Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Meeting_End_Date</fullName>
        <description>Update Meeting End Date with Meeting End Time</description>
        <field>End_Date_of_Event_MERC__c</field>
        <formula>End_Time_of_Meeting_MERC__c</formula>
        <name>Update Meeting End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Meeting_End_Dt_MERC</fullName>
        <description>Update Meeting End Date when Meeting End Time is changed</description>
        <field>End_Date_of_Event_MERC__c</field>
        <formula>End_Time_of_Meeting_MERC__c</formula>
        <name>Update Meeting End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Meeting_Start_Date</fullName>
        <description>Update Meeting Start Date with Meeting Start Time</description>
        <field>End_Date_Meeting_Time_Zone_MERC__c</field>
        <formula>Start_Time_In_Meeting_Time_Zone__c</formula>
        <name>Update Meeting Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Meeting_Start_Date_MERC</fullName>
        <description>Update Meeting Start Date when Meeting Start Time is changed</description>
        <field>Date_of_Event_MERC__c</field>
        <formula>DATEVALUE(End_Time_In_Meeting_Time_Zone_MERC__c)</formula>
        <name>Update Meeting Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Meeting_Start_Dt_MERC</fullName>
        <description>Update Meeting Start Date with Meeting Start Time</description>
        <field>Date_of_Event_MERC__c</field>
        <formula>Start_Time_of_Meeting_MERC__c</formula>
        <name>Update Meeting Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Participant_ToV_Final_Date_MERC</fullName>
        <description>Updates &quot;Participant ToV Final Date&quot; when &quot;Participant ToV Final&quot; is changed to &quot;Yes&quot;. Used for SLA Reporting.</description>
        <field>Participant_ToV_Final_Date_Time_MERC__c</field>
        <formula>now()</formula>
        <name>Update Participant ToV Final Date_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Participant_ToV_Update_Dt_MERC</fullName>
        <description>Update Participant ToV Update Date when Participant ToV Final is set to Yes.</description>
        <field>Participant_ToV_Updated_Date_MERC__c</field>
        <formula>Now()</formula>
        <name>Update Participant ToV Update Date_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Rec_Type_Ready_for_Sourcing_MERC</fullName>
        <description>When Meeting Status is updated to Active update Record type to Active.</description>
        <field>RecordTypeId</field>
        <lookupValue>Meeting_Active</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Rec Type Planned_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_to_Completed</fullName>
        <description>When Status of Meeting is changed to Completed, updated the Record type to completed.</description>
        <field>RecordTypeId</field>
        <lookupValue>Completed</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type to Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_to_Forecasted</fullName>
        <description>When Meeting Status is changed to Forecasted, updated Meeting Record type to Forecasted</description>
        <field>RecordTypeId</field>
        <lookupValue>Forecasted</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type to Forecasted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sourced_Venue_Address_City_MERC</fullName>
        <description>Update Source Venue Address City when Sourced Venue is changed.</description>
        <field>Sourced_Venue_City_Hist_MERC__c</field>
        <formula>Venue_MERC__r.Primary_Addr_City_GLBL__c</formula>
        <name>Update Sourced Venue Address City_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sourced_Venue_Address_Cntry_MERC</fullName>
        <description>Update Source Venue Address Country when Sourced Venue is changed.</description>
        <field>Sourced_Venue_Country_Hist_MERC__c</field>
        <formula>Venue_MERC__r.Primary_Address_Country_GLBL__c</formula>
        <name>Update Sourced Venue Address Cntry_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sourced_Venue_Address_Line_1_MERC</fullName>
        <description>Update Source Venue Address Line 1 when Sourced Venue is changed.</description>
        <field>Sourced_Venue_Addr_1_Hist_MERC__c</field>
        <formula>Venue_MERC__r.Primary_Addr_Line1_GLBL__c</formula>
        <name>Update Sourced Venue Address Line 1_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sourced_Venue_Address_Line_2_MERC</fullName>
        <description>Update Source Venue Address Line 2 when Sourced Venue is changed.</description>
        <field>Sourced_Venue_Addr_2_Hist_MERC__c</field>
        <formula>Venue_MERC__r.Primary_Addr_Line2_GLBL__c</formula>
        <name>Update Sourced Venue Address Line 2_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sourced_Venue_Name_MERC</fullName>
        <description>Update Source Venue Name when Sourced Venue is changed.</description>
        <field>Sourced_Venue_Name_Hist_MERC__c</field>
        <formula>Venue_MERC__r.Name</formula>
        <name>Update Sourced Venue Name_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sourced_Venue_Postal_Code_MERC</fullName>
        <description>Update Source Venue Address Postal Code when Sourced Venue is changed.</description>
        <field>Sourced_Venue_Postal_Code_Hist_MERC__c</field>
        <formula>Venue_MERC__r.Primary_Pstl_Cd_Extnsn_GLBL__c</formula>
        <name>Update Sourced Venue Postal Code_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Venue_Source_Date_Time</fullName>
        <description>Stamps Venue Sourcing Date/Time when Source Venue is selected.</description>
        <field>Venue_Sourced_Date_Time_MERC__c</field>
        <formula>now()</formula>
        <name>Update Venue Source Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Updated_Record_Type_to_Registered</fullName>
        <description>When Meeting Status is changed to Registered, update meeting Record Type to Registered</description>
        <field>RecordTypeId</field>
        <lookupValue>Registered</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Updated Record Type to Registered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Updated_Record_Type_to_Submitted_MERC</fullName>
        <description>When Meeting Status is changed to Planned, the Meeting record type is updated to Planned</description>
        <field>RecordTypeId</field>
        <lookupValue>Meeting_Active</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Updated Record Type to Submitted _MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <outboundMessages>
        <fullName>RTI_Meeting_Updated_MERC</fullName>
        <apiVersion>29.0</apiVersion>
        <endpointUrl>https://mercuryintegrationQA.lilly.com/rti/v1/genericUpdated</endpointUrl>
        <fields>Accommodation_Information_MERC__c</fields>
        <fields>Address_Contact_Information_MERC__c</fields>
        <fields>Agenda_Status_MERC__c</fields>
        <fields>Alignment_Internal_Id_GLBL__c</fields>
        <fields>Amount_to_be_Paid_MERC__c</fields>
        <fields>Approve_Sponsorship_MERC__c</fields>
        <fields>Approved_MERC__c</fields>
        <fields>Associated_Countries_MERC__c</fields>
        <fields>Budget_Final_Date_Time_MERC__c</fields>
        <fields>Budget_is_Final_MERC__c</fields>
        <fields>Business_Unit_MERC__c</fields>
        <fields>CME_Accredited_MERC__c</fields>
        <fields>City_of_Meeting_MERC__c</fields>
        <fields>Comments_MERC__c</fields>
        <fields>Compliance_Met_Initiate_Sourcing_MERC__c</fields>
        <fields>Compliance_Met_Invoices_MERC__c</fields>
        <fields>Compliance_Met_Meeting_Closure_MERC__c</fields>
        <fields>Compliance_Met_Meeting_Errors_MERC__c</fields>
        <fields>Compliance_Met_ToV_Finalized_MERC__c</fields>
        <fields>Compliance_Met_Venue_Sourcing_MER__c</fields>
        <fields>Compliant_MERC__c</fields>
        <fields>Confirm_Meeting_Cancellation_MERC__c</fields>
        <fields>Confirm_Meeting_Date_Change_MERC__c</fields>
        <fields>Confirm_ToV_Reporting_Change_MERC__c</fields>
        <fields>Confirmation_Comp_Invoice_Dt_Tm_MERC__c</fields>
        <fields>Confirmed_Attendees_MERC__c</fields>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>CurrencyIsoCode</fields>
        <fields>Customer_Facing_End_Time_MERC__c</fields>
        <fields>Customer_Facing_Meeting_Organiser_MERC__c</fields>
        <fields>Customer_Facing_Start_Time_MERC__c</fields>
        <fields>Date_of_Event_MERC__c</fields>
        <fields>Date_to_Send_Invitations_MERC__c</fields>
        <fields>Days_Until_Meeting_MERC__c</fields>
        <fields>Days_Until_Venue_Contracted_MERC__c</fields>
        <fields>Days_from_End_Date_to_ToV_Reported_MERC__c</fields>
        <fields>Days_from_MPC_to_Initiate_Sourcing_MERC__c</fields>
        <fields>Disable_Portal_Registration_MERC__c</fields>
        <fields>Employee_Accommodation_Covered_By_MERC__c</fields>
        <fields>Employee_Travel_MERC__c</fields>
        <fields>Employees_Attended_MERC__c</fields>
        <fields>End_Date_Meeting_Time_Zone_MERC__c</fields>
        <fields>End_Date_Year_MERC__c</fields>
        <fields>End_Date_of_Event_MERC__c</fields>
        <fields>End_Date_of_Meeting_plus_60_Days_MERC__c</fields>
        <fields>End_Time_In_Meeting_Time_Zone_MERC__c</fields>
        <fields>End_Time_of_Meeting_MERC__c</fields>
        <fields>Event_Country_MERC__c</fields>
        <fields>Event_Id_MERC__c</fields>
        <fields>Event_Occurred_MERC__c</fields>
        <fields>Event_Website_MERC__c</fields>
        <fields>Event_Website_Needed_MERC__c</fields>
        <fields>Exclude_from_Open_Meeting_Fee_Calc_MERC__c</fields>
        <fields>Expenses_MERC__c</fields>
        <fields>Expose_on_Portal_MERC__c</fields>
        <fields>External_Delegates_MERC__c</fields>
        <fields>Food_and_Beverage_Requirements_MERC__c</fields>
        <fields>Forecasting_Information_MERC__c</fields>
        <fields>Formatted_Name_MERC__c</fields>
        <fields>Functional_Area_MERC__c</fields>
        <fields>Group_Sponsorship_Meeting_MERC__c</fields>
        <fields>HCO_MERC__c</fields>
        <fields>HCO_Sponsorship_MERC__c</fields>
        <fields>HCP_Eligibile_for_Sponsorship_MERC__c</fields>
        <fields>HCPs_Attended_MERC__c</fields>
        <fields>Hospitality_Desk_Required_MERC__c</fields>
        <fields>Hours_for_Education_MERC__c</fields>
        <fields>Id</fields>
        <fields>Immediate_Source_MERC__c</fields>
        <fields>Independent_Meeting_Organiser_MERC__c</fields>
        <fields>Individual_Sponsorship_Meeting_MERC__c</fields>
        <fields>Initiate_Venue_Sourcing_Date_Time_MERC__c</fields>
        <fields>Interaction_Type_MERC__c</fields>
        <fields>Internal_Delegates_MERC__c</fields>
        <fields>Invitation_Template_MERC__c</fields>
        <fields>Invitee_List_Status_MERC__c</fields>
        <fields>Inviting_Delegates_MERC__c</fields>
        <fields>Inviting_Delegates_Other_MERC__c</fields>
        <fields>Invoicing_Completed_MERC__c</fields>
        <fields>IsDeleted</fields>
        <fields>Justification_for_Venue_MERC__c</fields>
        <fields>LastModifiedById</fields>
        <fields>LastModifiedDate</fields>
        <fields>Lock_Meeting_MERC__c</fields>
        <fields>Logistics_Information_MERC__c</fields>
        <fields>MCP_work_MERC__c</fields>
        <fields>MPC_Date_Time_MERC__c</fields>
        <fields>Make_Payment_To_MERC__c</fields>
        <fields>Materials_to_be_Shipped_MERC__c</fields>
        <fields>Meeting_Auto_Nmber_MERC__c</fields>
        <fields>Meeting_Cancellation_Date_MERC__c</fields>
        <fields>Meeting_Errors_MERC__c</fields>
        <fields>Meeting_Objectives_MERC__c</fields>
        <fields>Meeting_Organiser_Type_MERC__c</fields>
        <fields>Meeting_Owner_Email_MERC__c</fields>
        <fields>Meeting_Owner_MERC__c</fields>
        <fields>Meeting_Owner_Sales_Rep_MERC__c</fields>
        <fields>Meeting_Room_Setup_MERC__c</fields>
        <fields>Meeting_Scope_MERC__c</fields>
        <fields>Meeting_Status_MERC__c</fields>
        <fields>Meeting_Sub_Type_MERC__c</fields>
        <fields>Meeting_Time_Zone_MERC__c</fields>
        <fields>Meeting_Type_Abbreviation_MERC__c</fields>
        <fields>Mercury_External_Id_MERC__c</fields>
        <fields>Mercury_Owner_Master_Id_MERC__c</fields>
        <fields>Mercury_Worker_Country_Code_MERC__c</fields>
        <fields>Name</fields>
        <fields>No_Shows_MERC__c</fields>
        <fields>Non_HCPs_Attended_MERC__c</fields>
        <fields>Number_of_Break_Out_Rooms_MERC__c</fields>
        <fields>Number_of_Conference_Rooms_MERC__c</fields>
        <fields>Number_of_Draft_Budgets_MERC__c</fields>
        <fields>Number_of_Expected_Deletgates_MERC__c</fields>
        <fields>Number_of_Expected_Employees_MERC__c</fields>
        <fields>Number_of_Expected_Non_HCP_MERC__c</fields>
        <fields>Number_of_Expected_Speakers_MERC__c</fields>
        <fields>Number_of_Hotel_Rooms_MERC__c</fields>
        <fields>Number_of_Restaurants_MERC__c</fields>
        <fields>On_Site_Support_Required_MERC__c</fields>
        <fields>OwnerId</fields>
        <fields>Owner_Master_Id_MERC__c</fields>
        <fields>PO_Number_MERC__c</fields>
        <fields>Parent_Meeting_Event_Id_MERC__c</fields>
        <fields>Parent_Meeting_External_MERC__c</fields>
        <fields>Parent_Meeting_MERC__c</fields>
        <fields>Participant_CoPay_Updated_Date_MERC__c</fields>
        <fields>Participant_ToV_Final_Date_Time_MERC__c</fields>
        <fields>Participant_ToV_Final_MERC__c</fields>
        <fields>Participant_ToV_Updated_Date_MERC__c</fields>
        <fields>Participants_Attended_MERC__c</fields>
        <fields>Planned_Attendees_MERC__c</fields>
        <fields>Planned_Budget_MERC__c</fields>
        <fields>Preferred_Location_MERC__c</fields>
        <fields>Preferred_Venue_Addr_1_MERC__c</fields>
        <fields>Preferred_Venue_Addr_2_MERC__c</fields>
        <fields>Preferred_Venue_MERC__c</fields>
        <fields>Preferred_Venue_Postal_Code_MERC__c</fields>
        <fields>Prmry_Mtng_Ownr_Nm_MERC__c</fields>
        <fields>RTI_Transaction_ID_MERC__c</fields>
        <fields>Ready_for_Sourcing_MERC__c</fields>
        <fields>RecordTypeId</fields>
        <fields>Rep_Cost_Center_MERC__c</fields>
        <fields>Responses_Due_Date_MERC__c</fields>
        <fields>Restauraunt_Information_MERC__c</fields>
        <fields>Sales_Rep_MERC__c</fields>
        <fields>Send_Meeting_Team_Cancelled_Email_MERC__c</fields>
        <fields>Send_Save_the_Date_MERC__c</fields>
        <fields>Shipping_Address_for_Invitations_MERC__c</fields>
        <fields>Source_MERC__c</fields>
        <fields>Sourced_Venue_Addr1_MERC__c</fields>
        <fields>Sourced_Venue_Addr_1_Hist_MERC__c</fields>
        <fields>Sourced_Venue_Addr_2_Hist_MERC__c</fields>
        <fields>Sourced_Venue_Addr_2_MERC__c</fields>
        <fields>Sourced_Venue_City_Hist_MERC__c</fields>
        <fields>Sourced_Venue_City_MERC__c</fields>
        <fields>Sourced_Venue_Country_Hist_MERC__c</fields>
        <fields>Sourced_Venue_Country_MERC__c</fields>
        <fields>Sourced_Venue_Name_Hist_MERC__c</fields>
        <fields>Sourced_Venue_Name_MERC__c</fields>
        <fields>Sourced_Venue_Postal_Code_Hist_MERC__c</fields>
        <fields>Sourced_Venue_Postal_Code_MERC__c</fields>
        <fields>Speaker_MERC__c</fields>
        <fields>Sponsorship_Category_MERC__c</fields>
        <fields>Sponsorship_Eligibility_Crit_Met_MERC__c</fields>
        <fields>Sponsorship_Processed_MERC__c</fields>
        <fields>Sponsorship_Type_MERC__c</fields>
        <fields>Sponsorship_WO_Lilly_Assistance_MERC__c</fields>
        <fields>Sponsorship_W_Lilly_Assistance_MERC__c</fields>
        <fields>Start_Date_Meeting_Time_Zone_MERC__c</fields>
        <fields>Start_Time_In_Meeting_Time_Zone__c</fields>
        <fields>Start_Time_of_Meeting_MERC__c</fields>
        <fields>SystemModstamp</fields>
        <fields>Target_Audience_List_MERC__c</fields>
        <fields>Target_Audience_MERC__c</fields>
        <fields>Technical_Requirements_MERC__c</fields>
        <fields>Territory_Description_GLBL__c</fields>
        <fields>Territory_Id_GLBL__c</fields>
        <fields>Therapeutic_Area_MERC__c</fields>
        <fields>Time_for_Restaurant_Booking_MERC__c</fields>
        <fields>Transfers_MERC__c</fields>
        <fields>Travel_Information_MERC__c</fields>
        <fields>Type_MERC__c</fields>
        <fields>Venue_MERC__c</fields>
        <fields>Venue_Sourced_Date_Time_MERC__c</fields>
        <fields>Virtual_Meeting_MERC__c</fields>
        <fields>Work_Cntry_Cd_GLBL__c</fields>
        <fields>of_Days_Until_Invoice_Reviewed_MERC__c</fields>
        <fields>of_Sponsored_Individuals_MERC__c</fields>
        <fields>of_Sponsorship_Group_MERC__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>mercuryintegration.veeva@gso1.lly</integrationUser>
        <name>RTI - Meeting Updated</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>MERC_Active</fullName>
        <actions>
            <name>Update_Rec_Type_Ready_for_Sourcing_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Meeting_MERC__c.Meeting_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Independent Meeting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Consulting Project</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Meeting Program</value>
        </criteriaItems>
        <description>When Meeting Status is changed to Active, updated Record Type to Active : MERC : Created on 12/5/2013 by Katy Lorenti, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Advisory Meeting Notification</fullName>
        <actions>
            <name>Advisory_Board_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Interaction_Type_MERC__c</field>
            <operation>equals</operation>
            <value>Ad-hoc Advising</value>
        </criteriaItems>
        <description>Notify Meeting Owner when an Advisory Board Meeting with meeting details that can be forwarded to the appropriate approver : MERC : Created on 12/5/2013 by Katy Lorenti, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Clear Confirm ToV Change</fullName>
        <actions>
            <name>Update_Confirm_ToV_Change_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clears out the &quot;Confirm ToV Change&quot; checkbox after each record update : MERC : Created on 12/5/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>Confirm_ToV_Reporting_Change_MERC__c  = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Clear Meeting Cancellation Date</fullName>
        <actions>
            <name>Clear_Meeting_Cancellation_Date_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Meeting is changed from Cancelled to another status, update the Meeting Cancellation Date to blank : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Meeting_Status_MERC__c)&amp;&amp; !ISPICKVAL(Meeting_Status_MERC__c,&quot;Complete - Cancelled&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Clear_Confirm_Meeting_Cancellation_Checkbox</fullName>
        <actions>
            <name>Update_Confirm_Cancellation_Change_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Confirm Meeting Cancellation checkbox after each record update : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>Confirm_Meeting_Cancellation_MERC__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Clear_Confirm_Meeting_Date_Change_Checkbox</fullName>
        <actions>
            <name>Update_Meeting_Date_Change_Check_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Confirm Meeting Date Change checkbox after each record update : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>Confirm_Meeting_Date_Change_MERC__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Complete</fullName>
        <actions>
            <name>Update_Record_Type_to_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Address_City_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Address_Cntry_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Address_Line_1_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Address_Line_2_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Name_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sourced_Venue_Postal_Code_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Meeting Status is changed to Complete updated Record Type to Complete : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Meeting_Status_MERC__c) &amp;&amp; TEXT(Meeting_Status_MERC__c)  = &quot;Complete&quot; &amp;&amp;  RecordType.DeveloperName &lt;&gt; &quot;Independent_Sponsorship&quot; &amp;&amp;  RecordType.DeveloperName &lt;&gt; &quot;Ad_Hoc_Consulting&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Date Stamp Initiate Venue Sourcing</fullName>
        <actions>
            <name>Stamp_Initiate_Venue_Sourcing_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Ready_for_Sourcing_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Stamps when &quot;Initiate Sourcing&quot; has been checked. Used for SLA Reporting  : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_External ID-Meeting</fullName>
        <actions>
            <name>External_ID_Meeting_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Forecast Meeting</fullName>
        <actions>
            <name>Update_Record_Type_to_Forecasted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Meeting_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Forecasted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Independent Meeting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Consulting Project</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Meeting Program</value>
        </criteriaItems>
        <description>When Meeting Status is changed to Forecasted, updated Record Type to Forecasted : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Lock Meeting</fullName>
        <actions>
            <name>Lock_Meeting_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Lock Meeting value when a meeting changes to status Status = Complete - Closed  : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Meeting_Status_MERC__c)&amp;&amp; (ISPICKVAL(Meeting_Status_MERC__c, &quot;Complete - Closed&quot;) || ISPICKVAL(Meeting_Status_MERC__c, &quot;Complete - Cancelled&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Meeting Cancelled Status</fullName>
        <actions>
            <name>Send_Meeting_Team</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the field: Meeting.Send_Meeting_Team_Cancelled_Email_MERC__c to True when the Meeting Status is set to &quot;Complete - Cancelled&quot;.</description>
        <formula>ISCHANGED(Meeting_Status_MERC__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Non Compliant Notification</fullName>
        <actions>
            <name>Notification_email_of_Non_Compliant_Meeting</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Compliant_MERC__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>Notification of Non Compliant Meeting sent to Meeting Owner : MERC : Created on 02/05/2014 by Katy Lorenti, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Notify Meeting Owner of Cancelled Meeting</fullName>
        <actions>
            <name>Meeting_Status_Changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Meeting Owner when Meeting Status changes from Forecasted to Cancelled  : MERC : Created on 11/12/2013 by John Adams, Mavens Consulting</description>
        <formula>ISPICKVAL(PRIORVALUE(Meeting_Status_MERC__c),&quot;Forecasted&quot;) &amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Complete - Cancelled&quot;) &amp;&amp; ISCHANGED(Meeting_Status_MERC__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Register Meeting</fullName>
        <actions>
            <name>Updated_Record_Type_to_Registered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Meeting_MERC__c.Meeting_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Registered</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Independent Meeting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Consulting Project</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Meeting Program</value>
        </criteriaItems>
        <description>When Meeting Status is changed to Registered, updated Record Type to Registered : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Scientific Exchange Request for Approval</fullName>
        <actions>
            <name>Scientific_Exchange_Approval_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Type_MERC__c</field>
            <operation>equals</operation>
            <value>Scientific Exchange</value>
        </criteriaItems>
        <description>Triggers email to the Medical Director requesting approval to hold a Scientific Exchange meeting : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Set Meeting Cancellation Date</fullName>
        <actions>
            <name>Set_Meeting_Cancellation_Date_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Meeting is Cancelled, update the Meeting Cancellation Date : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISCHANGED(Meeting_Status_MERC__c)&amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Complete - Cancelled&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Stamp Sourced Venue Date%2FTime</fullName>
        <actions>
            <name>Update_Venue_Source_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Sourced_Venue_Name_MERC__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Stamps when Sourced Venue is selected on Meeting. Used for SLA Reporting : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Two Week Compliance Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Meeting_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Forecasted,Registered,Active,Complete</value>
        </criteriaItems>
        <description>Notify Meeting Owner two weeks before meeting end date to ensure all compliance information has been populated : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Two_week_compliance_notification_to_Meeting_Owner</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Meeting_MERC__c.End_Date_of_Event_MERC__c</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MERC_Update Associated Country</fullName>
        <actions>
            <name>Update_Associated_Countries_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Associated Countries field, this should be updated to ensure the meeting is sent to the correct Veeva Org&apos;s based on the meeting : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISNEW() || ISCHANGED( Event_Country_MERC__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Budget Final Date%2FTime</fullName>
        <actions>
            <name>Update_Budget_Final_Date_Time_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Budget Final Date/Time when Budget becomes final. Used for SLA Reporting : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Budget_is_Final_MERC__c) &amp;&amp;  ISPICKVAL(Budget_is_Final_MERC__c,&quot;Yes&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Confirmation of Complete Inv</fullName>
        <actions>
            <name>Update_Confirmation_of_Complete_Inv_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Conformation of Complete Invoice Date/Time when &quot;Yes&quot; is selected. Used for SLA Reporting : MERC : Created on 04/01/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISCHANGED(Invoicing_Completed_MERC__c ) &amp;&amp;  ISPICKVAL(Invoicing_Completed_MERC__c,&quot;Yes&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Event Id</fullName>
        <actions>
            <name>Update_Event_Id_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Event Id based on Meeting Details and the Meeting Auto Number field.  Creates a human readable Id for AODS and other downstream systems that  need it  : MERC : Created on 10/01/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>Source_MERC__c &lt;&gt; &apos;Veeva&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Meeting Formatted Name</fullName>
        <actions>
            <name>Update_Formatted_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow will update the Formatted Name field on the Meeting to allow for searching for a Meeting based on a defined naming convention : MERC : Created on 11/01/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Meeting Start and End Date</fullName>
        <actions>
            <name>Update_Meeting_End_Dt_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Meeting_Start_Dt_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Meeting Start Date and End Date when the Meeting Start Time and End Times are populated : MERC : Created on 01/15/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>(    ISNEW() ||     (      ISCHANGED( Start_Time_In_Meeting_Time_Zone__c) ||       ISCHANGED( End_Time_In_Meeting_Time_Zone_MERC__c )    )  )  &amp;&amp;  !CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Participant ToV Final Date</fullName>
        <actions>
            <name>Update_Participant_ToV_Final_Date_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Participant_ToV_Update_Dt_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Participant ToV Final Date/Time field and Participant ToV Final Update Date when Participant ToV is set to Final : MERC : Created on 04/01/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISCHANGED(Participant_ToV_Final_MERC__c) &amp;&amp;  ISPICKVAL(Participant_ToV_Final_MERC__c,&quot;Yes&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update_Confirm_Web_Service_Change</fullName>
        <actions>
            <name>MERC_Update_Confirm_Web_Service_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Confirm_Web_Service_Change_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sets the Confirm Web Service Change field to false once a set of changes has been confirmed by CMS Cork, fututre changes should also trigger the validation rule : MERC : Created on 22/07/2014 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Updated Owner AODS Fields</fullName>
        <actions>
            <name>Update_Master_Owner_Id_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Master_Worker_Country_Cd_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Master Owner Id and Country Code for AODS interface  : MERC : Created on 01/10/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISNEW() || ISCHANGED( Sales_Rep_MERC__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RTI - Meeting Updated</fullName>
        <actions>
            <name>RTI_Meeting_Updated_MERC</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)),NOT( TEXT(Type_MERC__c) = &apos;Internal&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
