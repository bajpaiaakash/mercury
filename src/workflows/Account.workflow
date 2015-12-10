<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>RTI - Account Updated</fullName>
        <actions>
            <name>RTI_Account_Update_ICRT</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNEW()) &amp;&amp; (NOT(CONTAINS(LastModifiedBy.Username,&apos;mvibatch.integration@&apos;))) &amp;&amp;  NOT(ISBLANK(Cust_Id_GLBL__c)) &amp;&amp; (ISCHANGED(Academic_Qualifications_MERC__c) ||
ISCHANGED(CAP_Usage_Note_MERC__c) ||
ISCHANGED(Communication_Preference_MERC__c) ||
ISCHANGED(Contract_Limitations_on_Use_MERC__c) ||
ISCHANGED(Employment_Specification_MERC__c) ||
ISCHANGED(FMV_Tier_Exists_MERC__c) ||
ISCHANGED(Has_MSA_Contract_MERC__c) ||
ISCHANGED(Service_Provider_Tier_MERC__c) ||
ISCHANGED(Cust_Id_GLBL__c) ||
ISCHANGED(Institutional_Notif_Info_Exists_MERC__c) ||
ISCHANGED(MSA_Contract_Expiration_MERC__c) ||
ISCHANGED(RTI_Transaction_ID_MERC__c) ||
ISCHANGED(Service_Provider_MERC__c) ||
ISCHANGED(Reserved_CAP_MERC__c)||
ISCHANGED(Allocated_CAP_MERC__c )||
ISCHANGED(Speaking_Paid_CAP_MERC__c )||
ISCHANGED(Consulting_Project_Paid_CAP_MERC__c )||
ISCHANGED(Annual_CAP_Limit_MERC__c)||
ISCHANGED(Transparency_Reporting_Opt_Out_MERC__c)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
