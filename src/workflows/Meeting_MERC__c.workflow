<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_email_of_Non_Compliant_Meeting</fullName>
        <ccEmails>jadams@mavensconsulting.com</ccEmails>
        <ccEmails>oliver@mavensconsulting.com</ccEmails>
        <ccEmails>katy@mavensconsulting.com</ccEmails>
        <description>Notification email of Non Compliant Meeting</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Mercury_Email_Templates_MERC/Non_Compliant_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Meeting_Owner_when_Meeting_Status_is_changed_from_Forecasted_to_Cancelled</fullName>
        <description>Notify Meeting Owner when Meeting Status is changed from Forecasted to Cancelled</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Mercury_Email_Templates_MERC/Cancelled_Meeting</template>
    </alerts>
    <alerts>
        <fullName>Two_week_compliance_notification_to_Meeting_Owner</fullName>
        <ccEmails>oliver@mavensconsulting.com</ccEmails>
        <ccEmails>katy@mavensconsulting.com</ccEmails>
        <description>Two week compliance notification to Meeting Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Mercury_Email_Templates_MERC/Two_week_Compliance_Notification_to_Owner</template>
    </alerts>
    <alerts>
        <fullName>Two_week_compliance_notification_to_Meeting_Owner_MERC</fullName>
        <ccEmails>oliver@mavensconsulting.com</ccEmails>
        <ccEmails>katy@mavensconsulting.com</ccEmails>
        <description>Two week compliance notification to Meeting Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Owner_Email_MERC__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
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
        <fullName>Set_Queue_Owner_Australia_New_Zealand</fullName>
        <description>Set Queue Owner - Australia/New Zealand</description>
        <field>OwnerId</field>
        <lookupValue>France_Hub</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set Queue Owner - Australia/New Zealand</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Queue_Owner_France_Hub</fullName>
        <field>OwnerId</field>
        <lookupValue>France_Hub</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set Queue Owner - France Hub</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Queue_Owner_Germany_Hub</fullName>
        <description>Sets Queue Owner to Germany Hub</description>
        <field>OwnerId</field>
        <lookupValue>Germany_Hub</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set Queue Owner - Germany Hub</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Queue_Owner_Italy_Hub</fullName>
        <description>Set Queue Owner to Italy Hub</description>
        <field>OwnerId</field>
        <lookupValue>Italy_Hub</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set Queue Owner - Italy Hub</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Queue_Owner_Russia</fullName>
        <description>Sets Queue Owner to Russia</description>
        <field>OwnerId</field>
        <lookupValue>Russia</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set Queue Owner - Russia</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Queue_Owner_Spain_Hub</fullName>
        <description>Set Queue Owner - Spain Hub</description>
        <field>OwnerId</field>
        <lookupValue>Spain_Hub</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set Queue Owner - Spain Hub</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Queue_Owner_Turkey</fullName>
        <description>Sets Queue Owner to Turkey</description>
        <field>OwnerId</field>
        <lookupValue>Turkey</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set Queue Owner - Turkey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Queue_Owner_UK_Hub</fullName>
        <description>Set Queue based on Country of Meeting</description>
        <field>OwnerId</field>
        <lookupValue>UK_Hub</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set Queue Owner - UK Hub</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Queue_Owner_Ukraine</fullName>
        <description>Set Queue Owner to Ukraine</description>
        <field>OwnerId</field>
        <lookupValue>Ukraine</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set Queue Owner - Ukraine</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
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
        <endpointUrl>http://ec2-54-227-9-128.compute-1.amazonaws.com/rti-development/v1/genericUpdated</endpointUrl>
        <fields>Accommodation_Information_MERC__c</fields>
        <fields>Activities_MERC__c</fields>
        <fields>Agenda_Status_MERC__c</fields>
        <fields>Alignment_Internal_Id_GLBL__c</fields>
        <fields>Amount_to_be_Paid_MERC__c</fields>
        <fields>Approve_Sponsorship_MERC__c</fields>
        <fields>Approved_MERC__c</fields>
        <fields>Budget_is_Final_MERC__c</fields>
        <fields>Business_Unit_MERC__c</fields>
        <fields>CME_Accredited_MERC__c</fields>
        <fields>City_of_Meeting_MERC__c</fields>
        <fields>Compliant_MERC__c</fields>
        <fields>Confirm_Meeting_Cancellation_MERC__c</fields>
        <fields>Confirm_Meeting_Date_Change_MERC__c</fields>
        <fields>Confirmed_Attendees_MERC__c</fields>
        <fields>Content_Approval_Needed_MERC__c</fields>
        <fields>Content_Creator_MERC__c</fields>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>CurrencyIsoCode</fields>
        <fields>Date_of_Event_MERC__c</fields>
        <fields>Date_to_Send_Invitations_MERC__c</fields>
        <fields>Disable_Portal_Registration_MERC__c</fields>
        <fields>Employee_Travel_MERC__c</fields>
        <fields>Employees_Attended_MERC__c</fields>
        <fields>End_Date_Meeting_Time_Zone_MERC__c</fields>
        <fields>End_Date_Year_MERC__c</fields>
        <fields>End_Date_of_Event_MERC__c</fields>
        <fields>End_Time_In_Meeting_Time_Zone_MERC__c</fields>
        <fields>End_Time_of_Meeting_MERC__c</fields>
        <fields>Event_Country_MERC__c</fields>
        <fields>Event_Id_MERC__c</fields>
        <fields>Event_Occurred_MERC__c</fields>
        <fields>Event_Website_MERC__c</fields>
        <fields>Event_Website_Needed_MERC__c</fields>
        <fields>Expenses_MERC__c</fields>
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
        <fields>Logistics_Information_MERC__c</fields>
        <fields>MCP_work_MERC__c</fields>
        <fields>Make_Payment_To_MERC__c</fields>
        <fields>Materials_to_be_Shipped_MERC__c</fields>
        <fields>Meeting_Auto_Nmber_MERC__c</fields>
        <fields>Meeting_Cancellation_Date_MERC__c</fields>
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
        <fields>Mercury_External_Id_MERC__c</fields>
        <fields>Name</fields>
        <fields>No_Shows_MERC__c</fields>
        <fields>Non_HCPs_Attended_MERC__c</fields>
        <fields>Number_of_Break_Out_Rooms_MERC__c</fields>
        <fields>Number_of_Conference_Rooms_MERC__c</fields>
        <fields>Number_of_Expected_Deletgates_MERC__c</fields>
        <fields>Number_of_Expected_Employees_MERC__c</fields>
        <fields>Number_of_Expected_Non_HCP_MERC__c</fields>
        <fields>Number_of_Expected_Speakers_MERC__c</fields>
        <fields>Number_of_Hotel_Rooms_MERC__c</fields>
        <fields>Number_of_Restaurants_MERC__c</fields>
        <fields>On_Site_Support_Required_MERC__c</fields>
        <fields>OwnerId</fields>
        <fields>Parent_Meeting_External_MERC__c</fields>
        <fields>Parent_Meeting_MERC__c</fields>
        <fields>Participants_Attended_MERC__c</fields>
        <fields>Planned_Attendees_MERC__c</fields>
        <fields>Planned_Budget_MERC__c</fields>
        <fields>Preferred_Location_MERC__c</fields>
        <fields>Preferred_Venue_Addr_1_MERC__c</fields>
        <fields>Preferred_Venue_Addr_2_MERC__c</fields>
        <fields>Preferred_Venue_MERC__c</fields>
        <fields>Preferred_Venue_Postal_Code_MERC__c</fields>
        <fields>RTI_Transaction_ID_MERC__c</fields>
        <fields>Ready_for_Sourcing_MERC__c</fields>
        <fields>RecordTypeId</fields>
        <fields>Rep_Cost_Center_MERC__c</fields>
        <fields>Responses_Due_Date_MERC__c</fields>
        <fields>Restauraunt_Information_MERC__c</fields>
        <fields>Sales_Rep_MERC__c</fields>
        <fields>Send_Save_the_Date_MERC__c</fields>
        <fields>Shipping_Address_for_Invitations_MERC__c</fields>
        <fields>Source_MERC__c</fields>
        <fields>Speaker_MERC__c</fields>
        <fields>Sponsorship_Category_MERC__c</fields>
        <fields>Sponsorship_Eligibility_Crit_Met_MERC__c</fields>
        <fields>Sponsorship_Type_MERC__c</fields>
        <fields>Sponsorship_WO_Lilly_Assistance_MERC__c</fields>
        <fields>Sponsorship_W_Lilly_Assistance_MERC__c</fields>
        <fields>Start_Date_Meeting_Time_Zone_MERC__c</fields>
        <fields>Start_Time_In_Meeting_Time_Zone__c</fields>
        <fields>Start_Time_of_Meeting_MERC__c</fields>
        <fields>Submit_for_Contracting_MERC__c</fields>
        <fields>SystemModstamp</fields>
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
        <fields>Virtual_Meeting_MERC__c</fields>
        <fields>of_Sponsored_Individuals_MERC__c</fields>
        <fields>of_Sponsorship_Group_MERC__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>lorentikaty@gso1.lly</integrationUser>
        <name>RTI - Meeting Updated</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Active_MERC</fullName>
        <actions>
            <name>Update_Rec_Type_Ready_for_Sourcing_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
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
        <description>When Meeting Status is changed to Active, updated Record Type to Active</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear Meeting Cancellation Date_MERC</fullName>
        <actions>
            <name>Clear_Meeting_Cancellation_Date_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Meeting is changed from Cancelled to another status, update the Meeting Cancellation Date to blank. Created 12/19/2013 by KLorenti, Mavens Consulting</description>
        <formula>ISCHANGED(Meeting_Status_MERC__c)&amp;&amp; !ISPICKVAL(Meeting_Status_MERC__c,&quot;Complete - Cancelled&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear_Confirm_Meeting_Cancellation_Checkbox_MERC</fullName>
        <actions>
            <name>Update_Confirm_Cancellation_Change_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Confirm Meeting Cancellation checkbox after each record update. Created 11/19/2013 by KLorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear_Confirm_Meeting_Date_Change_Checkbox_MERC</fullName>
        <actions>
            <name>Update_Meeting_Date_Change_Check_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Confirm Meeting Date Change checkbox after each record update. Created 10/24/2013 by KLorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Complete_MERC</fullName>
        <actions>
            <name>Update_Record_Type_to_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Meeting_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Complete - Closed</value>
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
        <description>When Meeting Status is changed to Complete - Closed updated Record Type to Complete - Closed</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Forecast Meeting_MERC</fullName>
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
        <description>When Meeting Status is changed to Forecasted, updated Record Type to Forecasted</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Mercury External ID-Meeting_MERC</fullName>
        <actions>
            <name>External_ID_Meeting_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Non Compliant Notification_MERC</fullName>
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
        <description>Notification of Non Compliant Meeting sent to Meeting Owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Meeting Owner of Cancelled Meeting_MERC</fullName>
        <actions>
            <name>Notify_Meeting_Owner_when_Meeting_Status_is_changed_from_Forecasted_to_Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Meeting Owner when Meeting Status changes from Forecasted to Cancelled.</description>
        <formula>ISPICKVAL(PRIORVALUE(Meeting_Status_MERC__c),&quot;Forecasted&quot;) &amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Complete - Cancelled&quot;) &amp;&amp; ISCHANGED(Meeting_Status_MERC__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RTI - Meeting Updated</fullName>
        <actions>
            <name>RTI_Meeting_Updated_MERC</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISCHANGED( RTI_Transaction_ID_MERC__c )),NOT( Source_MERC__c  = &apos;Internal&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Register Meeting_MERC</fullName>
        <actions>
            <name>Updated_Record_Type_to_Registered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
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
        <description>When Meeting Status is changed to Registered, updated Record Type to Registered</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Meeting Cancellation Date_MERC</fullName>
        <actions>
            <name>Set_Meeting_Cancellation_Date_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Meeting is Cancelled, update the Meeting Cancellation Date. Created 12/19/2013 by KLorenti, Mavens Consulting</description>
        <formula>ISCHANGED(Meeting_Status_MERC__c)&amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Complete - Cancelled&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Queue Owner - France Hub</fullName>
        <actions>
            <name>Set_Queue_Owner_France_Hub</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Queue Owner - France Hub</description>
        <formula>(ISPICKVAL(Event_Country_MERC__c,&apos;FR&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;NL&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;BE&apos;))&amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Registered&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Queue Owner - Germany Hub</fullName>
        <actions>
            <name>Set_Queue_Owner_Germany_Hub</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Queue Owner - Germany Hub</description>
        <formula>(ISPICKVAL(Event_Country_MERC__c,&apos;DE&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;AT&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;CH&apos;))&amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Registered&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Queue Owner - Italy Hub</fullName>
        <actions>
            <name>Set_Queue_Owner_Italy_Hub</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Queue Owner - Italy Hub</description>
        <formula>(ISPICKVAL(Event_Country_MERC__c,&apos;IT&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;RO&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;BG&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;HR&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;RS&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;SI&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;CY&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;MT&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;CA&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;HU&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;PL&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;SK&apos;))&amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Registered&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Queue Owner - Russia</fullName>
        <actions>
            <name>Set_Queue_Owner_Russia</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Queue Owner - Russia</description>
        <formula>ISPICKVAL(Event_Country_MERC__c,&apos;RU&apos;)&amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Registered&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Queue Owner - Spain Hub</fullName>
        <actions>
            <name>Set_Queue_Owner_Spain_Hub</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Queue Owner - Spain Hub</description>
        <formula>(ISPICKVAL(Event_Country_MERC__c,&apos;ES&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;PT&apos;))&amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Registered&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Queue Owner - Turkey</fullName>
        <actions>
            <name>Set_Queue_Owner_Turkey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Queue Owner - Turkey</description>
        <formula>ISPICKVAL(Event_Country_MERC__c,&apos;TR&apos;)&amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Registered&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Queue Owner - UK Hub</fullName>
        <actions>
            <name>Set_Queue_Owner_UK_Hub</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Queue Owner - UK Hub</description>
        <formula>(ISPICKVAL(Event_Country_MERC__c,&apos;GB&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;IE&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;SE&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;NO&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;DK&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;FI&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;LV&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;LT&apos;)|| ISPICKVAL(Event_Country_MERC__c,&apos;EE&apos;))&amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Registered&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Queue Owner - Ukraine</fullName>
        <actions>
            <name>Set_Queue_Owner_Ukraine</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Queue Owner - Ukraine</description>
        <formula>ISPICKVAL(Event_Country_MERC__c,&apos;UA&apos;)&amp;&amp; ISPICKVAL(Meeting_Status_MERC__c,&quot;Registered&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Two Week Compliance Notification_MERC</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Meeting_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Registered,Active</value>
        </criteriaItems>
        <description>Notify Meeting Owner two weeks after meeting creation to remind them to ensure all compliance information has been populated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Two_week_compliance_notification_to_Meeting_Owner</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Meeting_MERC__c.CreatedDate</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Event Id_MERC</fullName>
        <actions>
            <name>Update_Event_Id_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Event Id based on Meeting Details and the Meeting Auto Numbber field.  Creates a human readable Id for AODS and other downstream systems that  need it.</description>
        <formula>ISCHANGED( RTI_Transaction_ID_MERC__c ) == False</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Meeting Formatted Name_MERC</fullName>
        <actions>
            <name>Update_Formatted_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow will update the Formatted Name field on the Meeting to allow for searching for a Meeting based on a defined naming convention.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Meeting Start and End Date_MERC</fullName>
        <actions>
            <name>Update_Meeting_End_Dt_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Meeting_Start_Dt_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Meeting Start Date and End Date when the Meeting Start Time and End Times are populated</description>
        <formula>ISNEW() || (ISCHANGED( Start_Time_In_Meeting_Time_Zone__c) || 
ISCHANGED( End_Time_In_Meeting_Time_Zone_MERC__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Updated Owner AODS Fields</fullName>
        <actions>
            <name>Update_Master_Owner_Id_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Master_Worker_Country_Cd_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Master Owner Id and Country Code for AODS interface.  Oliver Dunford 12th Feb 2014.</description>
        <formula>ISNEW() || ISCHANGED( Sales_Rep_MERC__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
