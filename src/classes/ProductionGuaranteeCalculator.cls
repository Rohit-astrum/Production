/* FILE: ProductionGuaranteeCalculator.cls
 * AUTHOR: Tino Mattheou
 * DATE: October 2, 2012
 * PURPOSE: Calculates astrum estimate and production guarantees based on PVWatts, 
 *          total system size, generation start date, and snow derate 
 * MODIFICATION HISTORY
 *
 */

public class ProductionGuaranteeCalculator {
	
	public static final Date PRODUCTION_GUARANTEE_START = Date.newInstance(2011,7,1);
	public static final Double PRODUCTION_GUARANTEE_PCT = 0.95; //95%
	public static final Double GUARANTEE_ANNUAL_DERATE_PCT = .005; //0.5%
	
	//jan-dec and total
	private static String[] fieldNames = new String[] {
		'January__c', 'February__c', 'March__c', 'April__c', 'May__c', 'June__c',
		'July__c', 'August__c', 'September__c', 'October__c', 'November__c', 'December__c'
	};
	
	//snow de-rate normal distribution Dec - Mar (15%, 35%, 35%, 15% = 100%)
	private static Double[] snowRatio = new Double[] { .35, .35, .15, 0, 0, 0, 0, 0, 0, 0, 0, .15 };

	public static List<ProductionGuarantee> getProductionGuarantee(PVWatts_Production_Estimates__c pvw, Decimal systemSizekW, Decimal annualProjectedkWh, Date generationStart, Decimal snowDerate) {
		
		List<ProductionGuarantee> result = new List<ProductionGuarantee>();
		
		//snow derate input is in kWh/yr/kW of system size
		Double snowDeratekWh_per_Year = 0;
		if (snowDerate != null) {
			snowDeratekWh_per_Year = systemSizekW * snowDerate;
		}
		
		//add back the snow derate and distribute based on pvWatts (already pulled out of the projected amount)
		Double annualWithoutSnowDerate = annualProjectedkWh + snowDerate;

		Decimal pvwRatio = annualWithoutSnowDerate / pvw.Annual_Total__c;
		Decimal[] guaranteeBaseline = new Decimal[12];

		//baseline year   		
		for (Integer i = 0; i < 12; i++) {
			guaranteeBaseline[i] = (Decimal)pvw.get(fieldNames[i]) * pvwRatio - snowDeratekWh_per_Year * snowRatio[i];
		}

		Integer guaranteeStartYear = generationStart.year() + 1;
		if (generationStart.month() == 1 && generationStart.day() == 1) {
			guaranteeStartYear = generationStart.year();
		}
		//production guarantees start with the first full year after install
		Date startOfMonth = generationStart.toStartOfMonth();
		Date startOfThisMonth = Date.today().toStartOfMonth();
		Double derateMultiplier = 1 - GUARANTEE_ANNUAL_DERATE_PCT;
	
		while (startOfMonth < startOfThisMonth) {
			Double yearsDiff = Math.max(startOfMonth.year() - guaranteeStartYear, 0);
			Integer monthIndex = startOfMonth.month() - 1;
			ProductionGuarantee pg = new ProductionGuarantee();
			pg.startOfMonth = startOfMonth;
			pg.estimate_kWh = guaranteeBaseline[monthIndex] * Math.pow(derateMultiplier, yearsDiff);
			if (generationStart >= PRODUCTION_GUARANTEE_START && startOfMonth.year() >= guaranteeStartYear) {
				pg.guarantee_kWh = pg.estimate_kWh * PRODUCTION_GUARANTEE_PCT;
			}
			result.add(pg);
			startOfMonth = startOfMonth.addMonths(1);
		}
		
		return result;			
		
	}

	public class ProductionGuarantee {
		public Date startOfMonth;
		public Double guarantee_kWh;
		public Double estimate_kWh;
	}

}