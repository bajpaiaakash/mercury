global class MERC_HcpCapYearlyCalculationScheduler implements Schedulable {
	
	//To schedule run the following:
	// MERC_HcpCapYearlyCalculationScheduler m = new MERC_HcpCapYearlyCalculationScheduler();
	// String sch = '0 0 8 1 1 ? *';
	// String jobID = system.schedule('Yearly CAP Calculation Job', sch, m);

	global void execute(SchedulableContext sc) {
		MERC_HcpCapYearlyCalculationJob b = new MERC_HcpCapYearlyCalculationJob();
		database.executebatch(b);
	}
}