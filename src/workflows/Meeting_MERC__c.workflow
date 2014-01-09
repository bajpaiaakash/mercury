<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Meeting_Owner_when_Meeting_Status_is_changed_from_Forecasted_to_Cancelled</fullName>
        <ccEmails>katy@mavensconsulting.com</ccEmails>
        <description>Notify Meeting Owner when Meeting Status is changed from Forecasted to Cancelled</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Cancelled_Meeting</template>
    </alerts>
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
        <fullName>Update_Formatted_Name</fullName>
        <description>Update Formatted Name field based certain meeting attributes</description>
        <field>Formatted_Name_MERC__c</field>
        <formula>Text(Event_Country_MERC__c) &amp;&quot;-&quot;&amp;  TEXT(YEAR(Date_of_Event_MERC__c))&amp; Text(MONTH(Date_of_Event_MERC__c)) &amp; TEXT(DAY(Date_of_Event_MERC__c)) &amp; &quot; - &quot; &amp;  Name</formula>
        <name>Update Formatted Name</name>
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
        <fullName>Update_Rec_Type_Ready_for_Sourcing_MERC</fullName>
        <description>When Meeting Status is updated to Ready for Sourcing, update Record type to Ready for Sourcing.</description>
        <field>RecordTypeId</field>
        <lookupValue>Ready_for_Sourcing</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Rec Type Ready for Sourcing_MERC</name>
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
        <description>When Meeting Status is changed to Submitted for Contracting, the Meeting record type is updated to Submitted for Contracting</description>
        <field>RecordTypeId</field>
        <lookupValue>Submitted_for_Contracting</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Updated Record Type to Submitted _MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <outboundMessages>
        <fullName>RTI_Meeting_Updated</fullName>
        <apiVersion>29.0</apiVersion>
        <endpointUrl>http://ec2-54-227-9-128.compute-1.amazonaws.com/rti-development/v1/genericUpdated</endpointUrl>
        <fields>Accommodation_Information_MERC__c</fields>
        <fields>Activities_MERC__c</fields>
        <fields>Agenda_Status_MERC__c</fields>
        <fields>Alignment_Internal_Id_GLBL__c</fields>
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
        <fields>End_Time_In_User_Time_Zone__c</fields>
        <fields>End_Time_of_Meeting_MERC__c</fields>
        <fields>Event_Country_MERC__c</fields>
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
        <fields>HCP_Care_Assistance_MERC__c</fields>
        <fields>HCP_Eligibile_for_Sponsorship_MERC__c</fields>
        <fields>HCPs_Attended_MERC__c</fields>
        <fields>Hospitality_Desk_Required_MERC__c</fields>
        <fields>Hours_for_Education_MERC__c</fields>
        <fields>Id</fields>
        <fields>Individual_Sponsorship_Meeting_MERC__c</fields>
        <fields>Interaction_Type_MERC__c</fields>
        <fields>Internal_Delegates_MERC__c</fields>
        <fields>Invitation_Template_MERC__c</fields>
        <fields>Invitee_List_Status_MERC__c</fields>
        <fields>Inviting_Delegates_MERC__c</fields>
        <fields>Inviting_Delegates_Other_MERC__c</fields>
        <fields>Invoicing_Completed_MERC__c</fields>
        <fields>IsDeleted</fields>
        <fields>LastModifiedById</fields>
        <fields>LastModifiedDate</fields>
        <fields>LastReferencedDate</fields>
        <fields>LastViewedDate</fields>
        <fields>Logistics_Information_MERC__c</fields>
        <fields>Materials_to_be_Shipped_MERC__c</fields>
        <fields>Meeting_Objectives_MERC__c</fields>
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
        <fields>Parent_Meeting_MERC__c</fields>
        <fields>Participants_Attended_MERC__c</fields>
        <fields>Payment_For_MERC__c</fields>
        <fields>Payment_To_MERC__c</fields>
        <fields>Planned_Attendees_MERC__c</fields>
        <fields>Planned_Budget_MERC__c</fields>
        <fields>Preferred_Location_MERC__c</fields>
        <fields>Preferred_Venue_MERC__c</fields>
        <fields>RecordTypeId</fields>
        <fields>Responses_Due_Date_MERC__c</fields>
        <fields>Restauraunt_Information_MERC__c</fields>
        <fields>RowID__c</fields>
        <fields>Sales_Rep_MERC__c</fields>
        <fields>Send_Save_the_Date_MERC__c</fields>
        <fields>Shipping_Address_for_Invitations_MERC__c</fields>
        <fields>Speaker_MERC__c</fields>
        <fields>Sponsorship_Category_MERC__c</fields>
        <fields>Sponsorship_Type_MERC__c</fields>
        <fields>Sponsorship_WO_Lilly_Assistance_MERC__c</fields>
        <fields>Sponsorship_W_Lilly_Assistance_MERC__c</fields>
        <fields>Start_Date_Meeting_Time_Zone_MERC__c</fields>
        <fields>Start_Time_In_Meeting_Time_Zone__c</fields>
        <fields>Start_Time_User_Time_Zone_MERC__c</fields>
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
        <fields>Venue_Preferred_Location_MERC__c</fields>
        <fields>Virtual_Meeting_MERC__c</fields>
        <fields>Work_Cntry_Cd_GLBL__c</fields>
        <fields>of_Sponsored_Individuals_MERC__c</fields>
        <fields>of_Sponsorship_Group_MERC__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>helmer@gso1.lly</integrationUser>
        <name>RTI - Meeting Updated</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
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
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Independent Sponsorship</value>
        </criteriaItems>
        <description>When Meeting Status is changed to Complete updated Record Type to Complete</description>
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
            <value>Independent Sponsorship</value>
        </criteriaItems>
        <description>When Meeting Status is changed to Forecasted, updated Record Type to Forecasted</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Mercury External ID-Meeting</fullName>
        <actions>
            <name>External_ID_Meeting_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify Meeting Owner of Cancelled Meeting_MERC</fullName>
        <actions>
            <name>Notify_Meeting_Owner_when_Meeting_Status_is_changed_from_Forecasted_to_Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Meeting Owner when Meeting Status changes from Forecasted to Cancelled.</description>
        <formula>ISPICKVAL(PRIORVALUE(Meeting_Status_MERC__c),&quot;Forecasted&quot;) &amp;&amp;
ISPICKVAL(Meeting_Status_MERC__c,&quot;Cancelled&quot;) &amp;&amp;
ISCHANGED(Meeting_Status_MERC__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RTI - Meeting Updated</fullName>
        <actions>
            <name>RTI_Meeting_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>1==1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Ready_for_Sourcing_MERC</fullName>
        <actions>
            <name>Update_Rec_Type_Ready_for_Sourcing_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Meeting_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Ready for Sourcing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Independent Sponsorship</value>
        </criteriaItems>
        <description>When Meeting Status is changed to Ready for Sourcing, updated Record Type to Ready for Sourcing</description>
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
            <value>Independent Sponsorship</value>
        </criteriaItems>
        <description>When Meeting Status is changed to Registered, updated Record Type to Registered</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Submitted_for_Contracting_MERC</fullName>
        <actions>
            <name>Updated_Record_Type_to_Submitted_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Meeting_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Submitted for Contracting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Independent Sponsorship</value>
        </criteriaItems>
        <description>When Meeting Status is changed to Submitted for Contracting, updated Record Type to Submitted for Contracting</description>
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
</Workflow>
