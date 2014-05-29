@isTest
private class GLBL_NewButtonPrepopControllerTest
{
	static User testUser;
	static PageReference pageRef = Page.GLBL_NewButtonPrepopulator;

    static
    {
		System.runAs(new User(Id=UserInfo.getUserId()))
		{
			testUser = MERC_TestFactory.insertTestUsers(1, null).get(0);
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='Mercury_Customer_Meeting_Services_Edit' limit 1];
			insert new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=testUser.id);
			update new User(id=testUser.Id, UserRoleId=[SELECT Id FROM UserRole WHERE Name='Global' limit 1].id);
		}
	}

	@isTest static void test_no_record_type_selection()
	{
		System.runAs(testUser)
		{
			pageRef.getParameters().put('cObj', 'Budget_Line_Item_MERC__c');
			pageRef.getParameters().put('cObjURL', '%252Fapex%252FMERC_BudgetLineItemNewEdit%253FretURL%253D%25252Fservlet%25252Fservlet.Integration%25253Flid%25253D00b11000000Hry5%252526eid%25253Da0l11000001QR1Z%252526ic%25253D1%252526retURL%25253D%2525252Fa0l11000001QR1Z%252526wrapMassAction%25253D1%252526scontrolCaching%25253D1%2526sfdc.override%253D1');
			pageRef.getParameters().put('cf_Budget_MERC__c', 'BDGT-000465');
			pageRef.getParameters().put('cf_Budget_MERC__c_lkid', 'a0l11000001QR1Z');
			pageRef.getParameters().put('cObjParent', 'Budget_MERC__c');
			pageRef.getParameters().put('cObjParentId', 'a0l11000001QR1Z');

			system.debug(pageRef);
			Test.setCurrentPage(pageRef);
			Test.startTest();
			GLBL_NewButtonPrepopController controller = new GLBL_NewButtonPrepopController();
			PageReference p = controller.redirect();
			Test.stopTest();

			System.assert(p.getUrl().contains('CF00N11000000PFpR=BDGT-000465'), p.getUrl()); //id comes from the conditional in the getCFIds so we know it will be that id.
			System.assert(p.getUrl().contains('retURL=%2Fa0l11000001QR1Z'), p.getUrl());
			System.assert(!p.getUrl().contains('save_new_url='), p.getUrl());
		}
	}

	@isTest static void test_has_record_type_selection()
	{
		System.runAs(testUser)
		{
			pageRef.getParameters().put('cObj', 'Budget_Line_Item_MERC__c');
			//slap a recordtypeselect in this url to trigger the check
			pageRef.getParameters().put('cObjURL', 'recordtypeselect%252Fapex%252FMERC_BudgetLineItemNewEdit%253FretURL%253D%25252Fservlet%25252Fservlet.Integration%25253Flid%25253D00b11000000Hry5%252526eid%25253Da0l11000001QR1Z%252526ic%25253D1%252526retURL%25253D%2525252Fa0l11000001QR1Z%252526wrapMassAction%25253D1%252526scontrolCaching%25253D1%2526sfdc.override%253D1');
			pageRef.getParameters().put('cf_Budget_MERC__c', 'BDGT-000465');
			pageRef.getParameters().put('cf_Budget_MERC__c_lkid', 'a0l11000001QR1Z');
			pageRef.getParameters().put('cObjParent', 'Budget_MERC__c');
			pageRef.getParameters().put('cObjParentId', 'a0l11000001QR1Z');

			system.debug(pageRef);
			Test.setCurrentPage(pageRef);
			Test.startTest();
			GLBL_NewButtonPrepopController controller = new GLBL_NewButtonPrepopController();
			PageReference p = controller.redirect();
			Test.stopTest();

			//equals sign will be url encoded
			System.assert(p.getUrl().contains('CF00N11000000PFpR%3DBDGT-000465'), p.getUrl()); //id comes from the conditional in the getCFIds so we know it will be that id.
			System.assert(p.getUrl().contains('retURL%3D%2Fa0l11000001QR1Z'), p.getUrl());
			System.assert(p.getUrl().contains('save_new_url='), p.getUrl());
		}
	}
}