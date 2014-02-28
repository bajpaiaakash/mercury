/** 
* @author Sean Harrison 
* 
* This class is currently called from a trigger on the CST_User_Log_CUST__c obj but may be used
* with any Sobject. On insert or update an object is checked for changes to a field containing 
* a Lilly Global Employee Id. This id is then used to lookup a corresponding Account record 
* and used to populate a desired lookup.
*
*/
public with sharing class GLBL_GlobalIdAccountLookup implements GLBL_TriggerHandler.HandlerInterface {

    private String globalIdFieldName;
    private String employeeLKFieldName;
    private Boolean throwException;

   /**
    * Constructor that sets the Global Id and the target lookup field as well as a Boolean
    * determining if, when an GUIDs is invalid, whether the logic will fail silently (with
    * debug message) or throw an exception.
    * 
    * @param guidField	the api name of the field containing the Global Id. E.g. GUID__c
    * @param empField 	the api name of the Account lookup field to populate as a result
    *					of this logic.
    * @param throwEx 	set to true to cause an exception to be thrown when the processed
    *					Global Id is invalid
    */
    public GLBL_GlobalIdAccountLookup(String guidField, String empField, Boolean throwEx) {
        this.globalIdFieldName = guidField;
        this.employeeLKFieldName = empField;
        this.throwException = throwEx;
    }

   /**
    * Constructor that sets the Global Id and the target lookup field. This instantiation 
    * will fail silently with a debug message when an invalid GUID is encountered.
    * 
    * @param guidField	the api name of the field containing the Global Id. E.g. GUID__c
    * @param empField 	the api name of the Account lookup field to populate as a result
    *					of this logic.
    */
    public GLBL_GlobalIdAccountLookup(String guidField, String empField) {
    	this(guidField,empField,false);
    }

    // Sets the handler to respond to both inserts and updates with same execute method
    public void handle() {
        if (Trigger.isInsert || Trigger.isUpdate ) {
            execute(Trigger.new);
        }
    }

   /**
	* On insert or update an object is checked for changes to a field containing 
	* a Lilly Global Employee Id. These qualifying objects are passed to 
	* findAndPopulateLookup() for processing
	*
	* @param sobjects	the List of objects upon which this trigger should operate.
	*/
    private void execute(List<Sobject> sobjects) 
    {
        List<Sobject> sobjsToProcess = new List<Sobject>();
        for (Sobject obj : sobjects) {
            if (Trigger.isInsert) {
                if (obj.get(globalIdFieldName) != null) {
                    sobjsToProcess.add(obj);
                }
            } else if (Trigger.isUpdate) {
                if ((String)Trigger.oldMap.get((Id) obj.get('Id')).get(globalIdFieldName) != obj.get(globalIdFieldName))
                {
                    sobjsToProcess.add(obj);
                }
            }
        }

        findAndPopulateLookup(sobjsToProcess);
    }

   /**
	* Taking a List of Sobjects which contain a Global Id field. This id is then used 
	* to lookup a corresponding Account record and populate a desired lookup.
	*
	* @param sobjects	the List of objects to process.
	*/
    public void findAndPopulateLookup(List<Sobject> sobjsToProcess)
    {
    	Set<String> globalIdsToProcess = new Set<String>();
    	for (Sobject obj : sobjsToProcess) {
    		globalIdsToProcess.add((String) obj.get(globalIdFieldName));
    	}

        Map<String, Id> globalIdsToAccountId = new Map<String, Id>();
        for (Account a : [select Id, Prsnl_Nbr_GLBL__c from Account where Prsnl_Nbr_GLBL__c in :globalIdsToProcess]) 
        {
            globalIdsToAccountId.put(a.Prsnl_Nbr_GLBL__c,a.Id);
        }

        for (Sobject obj : sobjsToProcess) 
        {
            if (obj.get(globalIdFieldName) != null && globalIdsToAccountId.containsKey((String) obj.get(globalIdFieldName)))
            {
                obj.put(employeeLKFieldName, globalIdsToAccountId.get((String) obj.get(globalIdFieldName)));
            } else {
                if (throwException) throw new GLBL_GlobalIdAccountLookupException('Invalid Global Id: '+obj.get(globalIdFieldName));
                System.debug(System.LoggingLevel.ERROR, 'Invalid Global Id: '+obj.get(globalIdFieldName));
            }        
        }
    }

    // Used if throwException is set to true
    public class GLBL_GlobalIdAccountLookupException extends Exception {}

}