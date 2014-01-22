public with sharing class MERC_InvoiceXmlController {
	
	public Invoice_MERC__c invoice { get; private set; }
	public Date now { get{return Date.today();}}

	public MERC_InvoiceXmlController(ApexPages.StandardController controller) {
		List<String> fieldNames = new List<String>();
		fieldNames.add('Purpose_of_Payment_MERC__c');
		fieldNames.add('Customer_Id_MERC__c');
		fieldNames.add('Meeting_MERC__c');
		if (!Test.isRunningTest()) controller.addFields(fieldNames);
		this.invoice = (Invoice_MERC__c)controller.getRecord();
	}

	public List<InvoiceLineWrapper> invoiceLines {
		get {
			if (invoiceLines == null) {
				invoiceLines = new List<InvoiceLineWrapper>();
				Integer i = 1;
				for (Invoice_Line_Item_MERC__c lineItem : [Select 
						Name, 
						Quantity_MERC__c,
						Unit_Price_MERC__c,
						Amount_MERC__c,
						Description_MERC__c,
						VAT_Rate_MERC__c,
						Tax_Amount_MERC__c,
						Cost_Element_MERC__c,
						Invoice_Cost_Center_MERC__c FROM Invoice_Line_Item_MERC__c WHERE Invoice_MERC__c = :this.invoice.Id]) {
					invoiceLines.add(new InvoiceLineWrapper(lineItem, i));
					i++;
				}	
			}
			return invoiceLines; 
		}
		private set;
	}

	public class InvoiceLineWrapper {
		public Integer position { get; private set; }
		public Invoice_Line_Item_MERC__c lineItem { get; private set; }
		public InvoiceLineWrapper(Invoice_Line_Item_MERC__c li, Integer p) {
			this.lineItem = li;
			this.position = p;
		}
	}
	
	public String cdataLines { 
		get {
			if (cdataLines == null) {
				String purpose = (invoice.Purpose_of_Payment_MERC__c != null) ? invoice.Purpose_of_Payment_MERC__c : '';
				String custId = (invoice.Customer_Id_MERC__c != null) ? invoice.Customer_Id_MERC__c : '';
				String meeting = (invoice.Meeting_MERC__c != null) ? invoice.Meeting_MERC__c : '';
				
				cdataLines = '<![CDATA[ <Sideinfo>' +
				'<SINFOINPUTTYPE>ZD_MERCURY</SINFOINPUTTYPE>' +
				'<SINFOPAYMENT>'+purpose.escapeXml()+'</SINFOPAYMENT>' +
				'<SINFOCUSTID>'+custId.escapeXml()+'</SINFOCUSTID>' +
				'<SINFOTRANSACTID>'+invoice.Id+'</SINFOTRANSACTID>' +
				'<SINFOMEETID>'+meeting.escapeXml()+'</SINFOMEETID>' +
				'</Sideinfo> ]]>';
				
			}
			return cdataLines;
		}
		private set;
	}
}