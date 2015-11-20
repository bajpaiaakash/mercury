@isTest
private class MERC_TriggerHandlerStateManagerTest {

	@isTest static void test_method_one() {
		MERC_TriggerHandlerStateManager.deactivate(MERC_HcpCapLimitCalculator.class);
		System.assert(!MERC_TriggerHandlerStateManager.isActive(MERC_HcpCapLimitCalculator.class));
		MERC_TriggerHandlerStateManager.activate(MERC_HcpCapLimitCalculator.class);
		System.assert(MERC_TriggerHandlerStateManager.isActive(MERC_HcpCapLimitCalculator.class));

		MERC_TriggerHandlerStateManager.deactivateAll();
		System.assert(!MERC_TriggerHandlerStateManager.isActive(MERC_HcpCapLimitCalculator.class));
		MERC_TriggerHandlerStateManager.activateAll();
		System.assert(MERC_TriggerHandlerStateManager.isActive(MERC_HcpCapLimitCalculator.class));

		//should be null in the typeToIsActive
		System.assert(MERC_TriggerHandlerStateManager.isActive(MERC_HotelAllocationCalculator.class));

		MERC_TriggerHandlerStateManager.typeToIsActive = null;
		System.assert(MERC_TriggerHandlerStateManager.isActive(MERC_HcpCapLimitCalculator.class));
	}
}