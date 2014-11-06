<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Team_Member_Notification_MERC</fullName>
        <description>Send Team Member Notification</description>
        <protected>false</protected>
        <recipients>
            <field>User_MERC__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>gso_noreply@lilly.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Mercury_Email_Templates_MERC/New_Team_Member_Notification_MERC</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Primary_Meeting_Owner_MERC</fullName>
        <description>Clears Primary Meeting Owner field if Team Member changes roles</description>
        <field>Prmry_Mtng_Ownr_Nm_MERC__c</field>
        <name>Clear Primary Meeting Owner _MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_existing_PMO</fullName>
        <description>Clear the current Primary Meeting Owner if owner changes</description>
        <field>Prmry_Mtng_Ownr_Nm_MERC__c</field>
        <name>Clear existing PMO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clears_Meeting_Owner_Email_MERC</fullName>
        <description>Clears Primary Meeting Owner email field if Team Member changes roles.</description>
        <field>Meeting_Owner_Email_MERC__c</field>
        <name>Clears Meeting Owner Email MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>External_ID_Team_Member_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Team Member</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MPC_Team_Stamp_MERC</fullName>
        <description>Updates MPC Team Stamp when MPC is added to a meeting. Used for SLA reporting. Created 04/14/2014 by KLorenti, Mavens Consulitng</description>
        <field>MPC_Date_Time_MERC__c</field>
        <formula>now()</formula>
        <name>MPC Team Stamp_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Primary_Meeting_Owner_Email_MERC</fullName>
        <description>Update Primary Meeting Owner email on Meeting</description>
        <field>Meeting_Owner_Email_MERC__c</field>
        <formula>User_MERC__r.Email</formula>
        <name>Set Primary Meeting Owner Email_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Prmry_Mtng_Ownr_MERC</fullName>
        <description>Stamps in the Primary Meeting Owner Name into Meeting. Created by John A Adams 2/27/2014</description>
        <field>Prmry_Mtng_Ownr_Nm_MERC__c</field>
        <formula>IF(

ISPICKVAL(Role_MERC__c, &quot;Primary Meeting Owner&quot;),

(User_MERC__r.FirstName  &amp;&apos; &apos;&amp; User_MERC__r.LastName),&quot;&quot;

)</formula>
        <name>Set Prmry  Mtng Ownr_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_AODS_Master_Owner_Id_Field_MERC</fullName>
        <description>Updates Master Owner Id field with the Mercury Primary Meeting Owner. Oliver Dunford 12th Feb 2014.</description>
        <field>Mercury_Owner_Master_Id_MERC__c</field>
        <formula>User_MERC__r.Prsnl_Nbr_GLBL__c</formula>
        <name>Update AODS Master Owner Id Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Master_Worker_Country_Code_MERC</fullName>
        <description>Updates the AODS Worker Country Code on the Meeting. Oliver Dunford. 12th Feb 2014.</description>
        <field>Mercury_Worker_Country_Code_MERC__c</field>
        <formula>TEXT(User_MERC__r.Country_of_Residence_MERC__c)</formula>
        <name>Update Master Worker Country Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Team_Member_Countries_MERC</fullName>
        <description>Updates the Meeting Associated Countries based on the addition of the Customer Facing Users.  Created on 06/24/2014 by Oliver Dunford, Mavens Consulting.</description>
        <field>Associated_Countries_MERC__c</field>
        <formula>Meeting_MERC__r.Associated_Countries_MERC__c + &quot;,&quot; + TEXT(Account_MERC__r.Country_of_Residence_GLBL__c)</formula>
        <name>Update Team Member Countries</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <outboundMessages>
        <fullName>RTI_Team_Member_Updated</fullName>
        <apiVersion>29.0</apiVersion>
        <endpointUrl>https://gso1integration.xh1.lilly.com/rti/v1/genericUpdated</endpointUrl>
        <fields>Access_MERC__c</fields>
        <fields>Account_External_MERC__c</fields>
        <fields>Account_MERC__c</fields>
        <fields>Attendee_Invite_Limit_MERC__c</fields>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>CurrencyIsoCode</fields>
        <fields>Id</fields>
        <fields>IsDeleted</fields>
        <fields>LastModifiedById</fields>
        <fields>LastModifiedDate</fields>
        <fields>Meeting_External_MERC__c</fields>
        <fields>Meeting_MERC__c</fields>
        <fields>Mercury_External_Id_MERC__c</fields>
        <fields>Name</fields>
        <fields>RecordTypeId</fields>
        <fields>Role_MERC__c</fields>
        <fields>Sales_Rep_Country_Code_MERC__c</fields>
        <fields>SystemModstamp</fields>
        <fields>User_MERC__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>mercuryintegration.veeva@gso1.lly</integrationUser>
        <name>RTI - Team Member Updated</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>MERC_Clears Primary Meeting Owner</fullName>
        <actions>
            <name>Clear_Primary_Meeting_Owner_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clears_Meeting_Owner_Email_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clears values in Meeting Primary Meeting owner fields if Team Member is  edited and role changes : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>AND(  NOT(ISNEW() ),  ISPICKVAL(PRIORVALUE(Role_MERC__c), &quot;Primary Meeting Owner&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_External ID-Team Member</fullName>
        <actions>
            <name>External_ID_Team_Member_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Team_Member_MERC__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Mercury Users,Non-Mercury Users</value>
        </criteriaItems>
        <criteriaItems>
            <field>Team_Member_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record with format Orid_ID : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_MPC Team Stamp</fullName>
        <actions>
            <name>MPC_Team_Stamp_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Team_Member_MERC__c.Role_MERC__c</field>
            <operation>equals</operation>
            <value>Meeting Planning Company</value>
        </criteriaItems>
        <criteriaItems>
            <field>Meeting_MERC__c.MPC_Date_Time_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Indicates when a role is added to a meeting : MERC : Created on 02/05/2014 by Katy Lorenti, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_New Team Member Notification</fullName>
        <actions>
            <name>Send_Team_Member_Notification_MERC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Ensures each new Team Member is notified that they have been added to the meeting team : MERC : Created on 02/05/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Set Primary Meeting Owner Email</fullName>
        <actions>
            <name>Set_Primary_Meeting_Owner_Email_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Prmry_Mtng_Ownr_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Primary Meeting Owner name and email address on Meeting object : MERC : Created on 04/03/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISPICKVAL(Role_MERC__c,&quot;Primary Meeting Owner&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Associated Countries</fullName>
        <actions>
            <name>Update_Team_Member_Countries_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the associated Countries field on the Meeting to ensure that the Team Members and the meeting end up in the correct Veeva Org : MERC : Created on 11/05/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>RecordType.DeveloperName = &quot;External_User_MERC&quot; &amp;&amp;  CONTAINS( Meeting_MERC__r.Associated_Countries_MERC__c, TEXT(Account_MERC__r.Country_of_Residence_GLBL__c )) = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RTI - Team Member Updated</fullName>
        <actions>
            <name>RTI_Team_Member_Updated</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>NOT(CONTAINS(LastModifiedBy.Username,&apos;mercuryintegration.veeva@&apos;)) &amp;&amp;  (Account_MERC__r.Prsnl_Nbr_GLBL__c) != &apos;&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
