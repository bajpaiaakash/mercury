/* 
 * @author Sean Harrison 
 * 
 * For Invoice data integration with SAP, this class provides the a controller extension
 * for MERC_InvoiceAFIXML.page. Together these two components create an XML document 
 * representative of the data in an Invoice record and confirming to AFI's specifications.
 * The page itself is called from an @future method in MERC_InvoiceXmlWriter.class
 */
public with sharing class MERC_InvoiceXmlController {
    
    public Invoice_MERC__c invoice { get; private set; }
    public String now { get{return Datetime.now().format('dd.MM.yyyy');}}
    public String invoiceDate { get { if (invoiceDate == null) return Datetime.now().format('dd.MM.yyyy'); else return invoiceDate; } set; }
    public String filePrefix {
        get {
            Mercury_Settings_MERC__c settings = Mercury_Settings_MERC__c.getOrgDefaults();
            if (settings.Id != null) {
                if (settings.Invoice_File_Prefix_MERC__c != null) return settings.Invoice_File_Prefix_MERC__c;
            }
            return '';
        }
    }

    /*
     * Setup controller and its variables
     */
    public MERC_InvoiceXmlController(ApexPages.StandardController controller) {
        List<String> fieldNames = new List<String>();
        fieldNames.add('Purpose_of_Payment_MERC__c');
        fieldNames.add('Customer_Id_MERC__c');
        fieldNames.add('Meeting_MERC__c');
        fieldNames.add('Invoice_Date_MERC__c');
        fieldNames.add('Mercury_Transaction_Id_MERC__c');
        if (!Test.isRunningTest()) controller.addFields(fieldNames);
        this.invoice = (Invoice_MERC__c)controller.getRecord();
        
        Datetime dt = Datetime.newInstance(invoice.Invoice_Date_MERC__c, Time.newInstance(1,1,1,1));
        this.invoiceDate = dt.format('dd.MM.yyyy');
    }

    /*
     *  Property for VF page to get individual line item data
     */
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
                        VAT_Code_MERC__c,
                        Tax_Amount_MERC__c,
                        Cost_Element_SAP_Code_MERC__c,
                        Invoice_Cost_Center_MERC__c,
                        Internal_Order_Number_MERC__c FROM Invoice_Line_Item_MERC__c WHERE Invoice_MERC__c = :this.invoice.Id]) {
                    invoiceLines.add(new InvoiceLineWrapper(lineItem, i));
                    i++;
                }   
            }
            return invoiceLines; 
        }
        private set;
    }

    /*
     * Inner class for individual line item data
     */
    public class InvoiceLineWrapper {
        public Integer position { get; private set; }
        public Invoice_Line_Item_MERC__c lineItem { get; private set; }
        public String SAPCostElement {
            get {
                if (SAPCostElement == null) {
                    String codeFromMercury = this.lineItem.Cost_Element_SAP_Code_MERC__c;
                    SAPCostElement = codeFromMercury.trim().leftPad(10).replaceAll(' ','0');
                }
                return SAPCostElement;
            }
            private set;
         }
        public InvoiceLineWrapper(Invoice_Line_Item_MERC__c li, Integer p) {
            this.lineItem = li;
            this.position = p;
        }
    }
    
    /*
     * CDATA wasn't getting handled correctly by the VF XML generator so we'll just provide as a big string
     */
    public String cdataLines { 
        get {
            if (cdataLines == null) {
                String purpose = (invoice.Purpose_of_Payment_MERC__c != null) ? invoice.Purpose_of_Payment_MERC__c : '';
                String custId = (invoice.Customer_Id_MERC__c != null) ? invoice.Customer_Id_MERC__c : '';
                String meeting = (invoice.Meeting_MERC__c != null) ? invoice.Meeting_MERC__c : '';
                String snippedIDforSAP = (invoice.Mercury_Transaction_Id_MERC__c != null) ? invoice.Mercury_Transaction_Id_MERC__c.left(15) : invoice.Id;
              
                cdataLines = '<![CDATA[ <Sideinfo>' +
                '<SINFOINPUTTYPE>ZD_MERCURY</SINFOINPUTTYPE>' +
                '<SINFOPAYMENT>*'+purpose.escapeXml()+'</SINFOPAYMENT>' +
                '<SINFOCUSTID>'+custId.escapeXml()+'</SINFOCUSTID>' +
                '<SINFOTRANSACTID>'+snippedIDforSAP.left(15)+'</SINFOTRANSACTID>' +
                '<SINFOMEETID>'+meeting.escapeXml()+'</SINFOMEETID>' +
                '</Sideinfo> ]]>';
                
            }
            return cdataLines;
        }
        private set;
    }

    /*
     * A tif is optional. If it is in content, reflect the file data in the XML...
     */
    public String scannedTifSection { 
        get {
            if (scannedTifSection == null) {
                // See if TIF file is attached
                List<ContentVersion> tifObj = [SELECT ContentDocumentId From ContentVersion WHERE Invoice_MERC__c = :invoice.Id AND FileType = 'TIFF' LIMIT 1];
                if (tifObj != null && !tifObj.isEmpty()) {
                    // write out XML                
                    scannedTifSection = '<ArchiveFile><ID /><EXTID>'+invoice.Mercury_Transaction_Id_MERC__c+'</EXTID><SYSTEM_ID />'+
                    '<SYSTEM_NAME /><STATUS /><ARCID /><SAPID /><FILENAME>'+filePrefix+invoice.Mercury_Transaction_Id_MERC__c+'.TIF</FILENAME>'+
                    '<DOKTYP>TIF</DOKTYP></ArchiveFile>';
                }
            }
            return scannedTifSection;
        }
        private set;
    }   
}