<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Expiring_Auth_to_CST_Manager_CUST</fullName>
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
</Workflow>
