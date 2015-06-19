<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Clear_Consent_Effective_Date_Capture</fullName>
        <description>Clear Consent Effective Date Capture</description>
        <field>Efctv_Start_Dt_Cap_GLBL__c</field>
        <name>Clear Consent Effective Date Capture</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Effective_Date_CMS</fullName>
        <description>Clears Effective End Date for CMS entered information</description>
        <field>Efctv_Start_Dt_CMS_MERC__c</field>
        <name>Clear Effective Date (CMS)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Effective_Date_CMS</fullName>
        <description>Copy Effective Date (CMS) field to Effective Date (Capture) field</description>
        <field>Efctv_Start_Dt_Cap_GLBL__c</field>
        <formula>Efctv_Start_Dt_CMS_MERC__c</formula>
        <name>Copy Effective Date (CMS)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Clear Consent Effective Date Capture</fullName>
        <actions>
            <name>Clear_Consent_Effective_Date_Capture</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clears Down Capture fields if they match ODS fields : MERC : Created on 21/08/2014 by Oliver Dunford, Mavens Consulting</description>
        <formula>Efctv_Start_Dt_Cap_GLBL__c = Efctv_Start_Dt_GLBL__c &amp;&amp; !ISBLANK(Efctv_Start_Dt_GLBL__c) &amp;&amp; $Profile.Name = &apos;Mercury Integration ODS - Platform&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Clear Down CMS Fields</fullName>
        <actions>
            <name>Clear_Channel_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Communication_Channel_Code_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Document_Id_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Effective_Date_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_End_Date_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Source_Name_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Status_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear down CMS fields if the Creator or Editor if the record is the API Profile : MERC : Created on 12/5/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>$Profile.Name = &apos;Mercury Metadata API&apos; ||  $Profile.Name = &apos;Mercury Portal API - Platform&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Copy CMS Fields to Capture Fields</fullName>
        <actions>
            <name>Copy_Channel_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Communication_Channel_Code_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Consent_Source_Name_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Document_Id_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Effective_Date_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_End_Date_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Status_Code_CMS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copies the Values entered into the CMS Fields and inserts them to the Capture Fields: MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <formula>($Profile.Name  = &apos;GSO Basic User_Salesforce&apos; || $Profile.Name  = &apos;GSO Basic User_Platform&apos; || $Profile.Name  = &apos;System Administrator&apos;)    &amp;&amp;    ISNEW()     ||    (  TEXT(Cmnctn_Chnl_Cd_CMS_MERC__c)  = &apos;D022&apos;    &amp;&amp;    (  ISCHANGED(Cmnctn_Chnl_Desc_CMS_MERC__c)  ||   ISCHANGED(Cmnctn_Chnl_Cd_CMS_MERC__c)  ||  ISCHANGED(Cnsnt_Sts_Desc_CMS_MERC__c)   )    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
