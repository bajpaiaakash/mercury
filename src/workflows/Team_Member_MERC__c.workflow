<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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
        <formula>AND( ISPICKVAL(PRIORVALUE(Role_MERC__c), &quot;Primary Meeting Owner&quot;), ISCHANGED(Role_MERC__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
