@isTest
private class GLBL_LRAbacusTest {
	
	private static Decimal total = 0;
	private static Decimal min = 0;
	private static Decimal max = 0;
	private static Decimal avg = 0;
	private static Integer numNulls = 0;

	private static final String fieldName = 'Count_Dietary_Preferences_MERC__c';

	private static List<Account> generateList(Integer size, Boolean includeNulls){
		List<Account> accounts = new List<Account>();

		for(Integer i = 0, j = size; i < j; i++){
			Account acc = new Account();
			if(includeNulls && i > 0 && Math.random() > 0.8){
				acc.Count_Dietary_Preferences_MERC__c = null;
				numNulls++;
			} else {
				Decimal value = Math.random()*100;

				if(i == 0){
					min = value;
					max = value;
				} else {
					min = value < min ? value : min;
					max = value > max ? value : max; 
				}

				acc.Count_Dietary_Preferences_MERC__c = value;
				total += value;
			}
			accounts.add(acc);
		}

		avg = total/(size - numNulls);

		return accounts;
	}

	@isTest 
	static void testSumNoNulls() {
		List<Account> accounts = generateList(20, false);
		
		Map<String, GLBL_LREngine.RollupOperation> fields2Operations = new Map<String, GLBL_LREngine.RollupOperation>();
		fields2Operations.put(fieldName, GLBL_LREngine.RollupOperation.Sum);

		Map<String, Decimal> calculatedValues = GLBL_LRAbacus.calculate(accounts, fields2Operations);

		System.assertEquals(total, calculatedValues.get(fieldName), 'Incorrect sum returned');
	}

	@isTest 
	static void testSumWithNulls() {
		List<Account> accounts = generateList(20, true);
		
		Map<String, GLBL_LREngine.RollupOperation> fields2Operations = new Map<String, GLBL_LREngine.RollupOperation>();
		fields2Operations.put(fieldName, GLBL_LREngine.RollupOperation.Sum);

		Map<String, Decimal> calculatedValues = GLBL_LRAbacus.calculate(accounts, fields2Operations);

		System.assertEquals(total, calculatedValues.get(fieldName), 'Incorrect sum returned');
	}

	@isTest 
	static void testAverageNoNulls() {
		List<Account> accounts = generateList(20, false);
		
		Map<String, GLBL_LREngine.RollupOperation> fields2Operations = new Map<String, GLBL_LREngine.RollupOperation>();
		fields2Operations.put(fieldName, GLBL_LREngine.RollupOperation.Avg);

		Map<String, Decimal> calculatedValues = GLBL_LRAbacus.calculate(accounts, fields2Operations);

		System.assertEquals(avg, calculatedValues.get(fieldName), 'Incorrect average returned');
	}

	@isTest 
	static void testAverageWithNulls() {
		List<Account> accounts = generateList(20, true);
		
		Map<String, GLBL_LREngine.RollupOperation> fields2Operations = new Map<String, GLBL_LREngine.RollupOperation>();
		fields2Operations.put(fieldName, GLBL_LREngine.RollupOperation.Avg);

		Map<String, Decimal> calculatedValues = GLBL_LRAbacus.calculate(accounts, fields2Operations);

		System.assertEquals(avg, calculatedValues.get(fieldName), 'Incorrect average returned');
	}

	@isTest 
	static void testMinNoNulls() {
		List<Account> accounts = generateList(20, false);
		
		Map<String, GLBL_LREngine.RollupOperation> fields2Operations = new Map<String, GLBL_LREngine.RollupOperation>();
		fields2Operations.put(fieldName, GLBL_LREngine.RollupOperation.Min);

		Map<String, Decimal> calculatedValues = GLBL_LRAbacus.calculate(accounts, fields2Operations);

		System.assertEquals(min, calculatedValues.get(fieldName), 'Incorrect min returned');
	}

	@isTest 
	static void testMinWithNulls() {
		List<Account> accounts = generateList(20, true);
		
		Map<String, GLBL_LREngine.RollupOperation> fields2Operations = new Map<String, GLBL_LREngine.RollupOperation>();
		fields2Operations.put(fieldName, GLBL_LREngine.RollupOperation.Min);

		Map<String, Decimal> calculatedValues = GLBL_LRAbacus.calculate(accounts, fields2Operations);

		System.assertEquals(min, calculatedValues.get(fieldName), 'Incorrect min returned');
	}

	@isTest 
	static void testMaxNoNulls() {
		List<Account> accounts = generateList(20, false);
		
		Map<String, GLBL_LREngine.RollupOperation> fields2Operations = new Map<String, GLBL_LREngine.RollupOperation>();
		fields2Operations.put(fieldName, GLBL_LREngine.RollupOperation.Max);

		Map<String, Decimal> calculatedValues = GLBL_LRAbacus.calculate(accounts, fields2Operations);

		System.assertEquals(max, calculatedValues.get(fieldName), 'Incorrect max returned');
	}

	@isTest 
	static void testMaxWithNulls() {
		List<Account> accounts = generateList(20, true);
		
		Map<String, GLBL_LREngine.RollupOperation> fields2Operations = new Map<String, GLBL_LREngine.RollupOperation>();
		fields2Operations.put(fieldName, GLBL_LREngine.RollupOperation.Max);

		Map<String, Decimal> calculatedValues = GLBL_LRAbacus.calculate(accounts, fields2Operations);

		System.assertEquals(max, calculatedValues.get(fieldName), 'Incorrect max returned');
	}

	@isTest 
	static void testCountNoNulls() {
		List<Account> accounts = generateList(20, false);
		
		Map<String, GLBL_LREngine.RollupOperation> fields2Operations = new Map<String, GLBL_LREngine.RollupOperation>();
		fields2Operations.put(fieldName, GLBL_LREngine.RollupOperation.Count);

		Map<String, Decimal> calculatedValues = GLBL_LRAbacus.calculate(accounts, fields2Operations);

		System.assertEquals(20, calculatedValues.get(fieldName), 'Incorrect count returned');
	}

	@isTest 
	static void testCountWithNulls() {
		List<Account> accounts = generateList(20, true);
		
		Map<String, GLBL_LREngine.RollupOperation> fields2Operations = new Map<String, GLBL_LREngine.RollupOperation>();
		fields2Operations.put(fieldName, GLBL_LREngine.RollupOperation.Count);

		Map<String, Decimal> calculatedValues = GLBL_LRAbacus.calculate(accounts, fields2Operations);

		System.assertEquals(20 - numNulls, calculatedValues.get(fieldName), 'Incorrect count returned');
	}
}