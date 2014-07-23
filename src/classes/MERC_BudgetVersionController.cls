/**
 * @author Joseph Ferraro
 *
 * Controller for Budget versioning functionality
 * -Handles activation/finalisation of budgets
 */
public with sharing class MERC_BudgetVersionController {

	private final Budget_MERC__c budget;
    private final ApexPages.StandardController controller;

    public MERC_BudgetVersionController(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String>{
                'Id', 'Name', 'Version_Number_MERC__c', 'Master_Budget_MERC__c', 'Previous_Budget_Revision_MERC__c', 'Meeting_MERC__c'
            });
        }
        this.budget = (Budget_MERC__c)stdController.getRecord();
        this.controller = stdController;
    }

    public PageReference newVersion() {
        //disable validation rules on budget edits
        MERC_Util.disableBudgetEditValidation();

        //clone budget and line items
        Set<Id> budgetIds = new Set<Id>{budget.Id};
        String serializedData = GLBL_SobjectDataLoader.serialize(budgetIds,
            new GLBL_SobjectDataLoader.SerializeConfig().
                followMaster(Budget_MERC__c.Meeting_MERC__c). //this tells the serializer to set the new budget with the existing meeting id
                followChild(Budget_Line_Item_MERC__c.Master_Budget_Line_Item_MERC__c).  // Serialize any related Budget Lines
                followChild(Budget_Line_Item_MERC__c.Budget_MERC__c));  // Serialize any related Budget Lines
        Set<Id> resultIds = GLBL_SobjectDataLoader.deserialize(serializedData, new BudgetCloneCallback());
        List<Id> resultIdList = new List<Id>();
        resultIdList.addAll(resultIds);

        //get newly created budget (new version), set fields
        Budget_MERC__c newBudget = [Select ID, Master_Budget_MERC__c From Budget_MERC__c WHERE ID = :resultIdList.get(0)];
        if (budget.Master_Budget_MERC__c == null)
            newBudget.Master_Budget_MERC__c = budget.Id;
        else
            newBudget.Master_Budget_MERC__c = budget.Master_Budget_MERC__c;
        newBudget.Previous_Budget_Revision_MERC__c = budget.Id;
        newBudget.RecordTypeId = [Select ID From RecordType Where SobjectType = 'Budget_MERC__c' AND DeveloperName = 'MERC_Budget_Draft'].ID;
        newBudget.Status_MERC__c = 'Draft';
        if (budget.Version_Number_MERC__c == null)
            budget.Version_Number_MERC__c = 1;
        newBudget.Version_Number_MERC__c = budget.Version_Number_MERC__c + 1;
        //newBudget.Meeting_MERC__c = budget.Meeting_MERC__c; //we don't set this here anymore bc budget is now detail of meeting, which means it's set in the clone process
        update newBudget;

        //enable validation rules on budget edits
        MERC_Util.enableBudgetEditValidation();

        return new PageReference('/'+newBudget.Id);
    }

    public PageReference activate() {
        //disable validation rules on budget edits
        MERC_Util.disableBudgetEditValidation();

        //set this budget to active, flip the record type
        budget.Status_MERC__c = 'Active';
        budget.RecordTypeId = [Select ID From RecordType Where SobjectType = 'Budget_MERC__c' AND DeveloperName = 'MERC_Budget_Active'].ID;
        update budget;

        //archive old budgets
        if (budget.Previous_Budget_Revision_MERC__c != null) {
            Budget_MERC__c previousBudgetRev = [Select ID, Status_MERC__c FROM Budget_MERC__c WHERE ID = :budget.Previous_Budget_Revision_MERC__c];
            if (previousBudgetRev.Status_MERC__c != 'Archived') {
                previousBudgetRev.Status_MERC__c = 'Archived';
                previousBudgetRev.RecordTypeId = [Select ID From RecordType Where SobjectType = 'Budget_MERC__c' AND DeveloperName = 'MERC_Budget_Archived'].ID;
            }
            update previousBudgetRev;
        }

        //enable validation rules on budget edits
        MERC_Util.enableBudgetEditValidation();

        return controller.view();
    }

    public PageReference finalize() {
        try {
            this.budget.RecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'MERC_Budget_Final' AND SobjectType = 'Budget_Merc__c'].ID;
            this.budget.Status_MERC__c = 'Final';
            update this.budget;
        } catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        return this.controller.view();
    }

    //clone callback to set budget line item versioning fields
    public class BudgetCloneCallback implements GLBL_SobjectDataLoader.IDeserializeCallback {
        public void cloneMapHandler(Map<ID, Sobject> cloneMap) {
            for (Id recordId : cloneMap.keySet()) {
                String objectAPIName = recordId.getSObjectType().getDescribe().getName();
                if (objectAPIName == 'Budget_Line_Item_MERC__c') {
                    Sobject newObject = cloneMap.get(recordId);
                    if (newObject.get('Master_Budget_Line_Item_MERC__c') == null)
                        newObject.put('Master_Budget_Line_Item_MERC__c', recordId);
                    else
                        newObject.put('Master_Budget_Line_Item_MERC__c', newObject.get('Master_Budget_Line_Item_MERC__c'));
                    newObject.put('Previous_Budget_Line_Item_Version_MERC__c', recordId);
                    if (newObject.get('Version_Number_MERC__c') == null)
                        newObject.put('Version_Number_MERC__c', 1);
                    newObject.put('Version_Number_MERC__c', (Double)newObject.get('Version_Number_MERC__c')+1);
                }
            }
        }

        //unused
        public void unresolvedReferences(Schema.SObjectType foo, LIST<GLBL_SobjectDataLoader.UnresolvedReferences> bar) { }
    }

}