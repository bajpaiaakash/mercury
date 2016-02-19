<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <classAccesses>
        <apexClass>MERC_AccountRollups</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_AllocatedCapCalculator</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_HcpCapActualsCalculator</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_InvoiceLineItemRollupStamp</apexClass>
        <enabled>false</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_PaidCapCalculator</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>MERC_TriggerHandlerStateManager</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <custom>true</custom>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Allocated_CAP__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Allocated_Fee_for_6_months__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Allocated_Fee_for_Current_Year__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Allocated_Fee_for_Next_Yr_Cons_Only__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Paid_CAP__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Paid_CN_after_meeting_end_date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Paid_Cap_for_Cons_CN_Used_for_AC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Paid_Cap_for_Cons_Inv_Used_for_AC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Paid_Cap_for_NonCon_Inv_Used_for_AC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Paid_Cap_for_NonCons_CN_Used_for_AC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Paid_Credit_Note_for_Cons_meeting__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Paid_Credit_Note_for_Non_Cons_mtng__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Paid_Invoice_after_meeting_end_date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Paid_Invoices_for_Cons_meeting__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Account.MERC_Paid_Invoices_for_Non_Cons_meeting__c</field>
        <readable>true</readable>
    </fieldPermissions>
	<fieldPermissions>
        <editable>false</editable>
        <field>Account.Remaining_CAP_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
	<fieldPermissions>
        <editable>false</editable>
        <field>Account.Utilised_CAP_MERC__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Invoice_Line_Item_MERC__c.MERC_Consulting_Contracted_Amount_Rollup__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Invoice_MERC__c.MERC_Consulting_Contracted_Amt_excl_VAT__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_MERC__c.MERC_Meeting_Complete_Canceled_Clsd_Date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_MERC__c.MERC_Meeting_End_Date_Inactive__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Meeting_MERC__c.MERC_Meeting_End_date_plus_6_months__c</field>
        <readable>true</readable>
    </fieldPermissions>
	<fieldPermissions>
        <editable>false</editable>
        <field>Meeting_MERC__c.MERC_Meeting_out_of_six_months__c</field>
        <readable>true</readable>
    </fieldPermissions>
   
</Profile>
