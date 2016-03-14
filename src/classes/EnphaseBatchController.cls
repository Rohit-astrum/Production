public class EnphaseBatchController {
	
	private Integer lastProcessed = -1;

	public List<ProcessStatus> statuses { get; private set; }
	public Boolean completed { get; private set; }
	public Boolean paused { get; private set; }

	public String startTime { get; private set; }
	public String completeTime { get; private set; }
	public Integer total { get; private set; }
	public Integer processed { get; private set; }
	public Integer errors { get; private set; }
	
	public EnphaseBatchController() {
		completed = false;
		paused = false;
		loadSystems();
	}
	
	private void loadSystems() {
		
		statuses = new List<ProcessStatus>();
		
		List<Installed_System__c> systems = 
			[SELECT Id, Enphase_ID__c, PJM_Id__c, Generation_Start_Date__c,
				Quoted_System_Design__r.System_Design__r.Total_System_Size_kW__c,
				Quoted_System_Design__r.System_Design__r.Total_Projected_Annual_Output_kWh_y__c,
				Property__r.Snow_De_Rate_kWh_y_kW__c
			FROM Installed_System__c
			WHERE Enphase_ID__c <> NULL
			AND Id NOT IN 
				(SELECT Installed_System__c 
				FROM Enphase_Pull_Log__c 
				WHERE Batch_Date__c = THIS_MONTH)];
				
		for (Installed_System__c sys : systems) {
			ProcessStatus ps = new ProcessStatus();
			ps.sys = sys;
			ps.processed = false;
			ps.status = 'Pending';
			statuses.add(ps);
		}
		
		total = statuses.size();
		if (total == 0) {
			completed = true;
		}
		processed = 0;
		errors = 0;
		
	}

	public PageReference updateState() {
		
		if (lastProcessed < statuses.size() - 1) {
			ProcessStatus ps = statuses[++lastProcessed];
			ps.Status = processSystem(ps.sys);
			ps.processed = true;
			ps.processedTime = System.now();
			processed++;
			if (startTime == null) {
				startTime = ps.processDateTime;
			}
			if (ps.Status != 'Success') {
				errors++;
			}
			if (lastProcessed == statuses.size() - 1) {
				completed = true;
				completeTime = ps.processDateTime;
			}	 
		}
		
		return null;
	}
	
	public PageReference pause() {
		paused = true;
		return null;
	}
	
	public PageReference resume() {
		paused = false;
		return null;
	}
	
	public String processSystem(Installed_System__c sys) {
		
		Date thisMonthStart = System.today().toStartOfMonth();
		Date lastMonthStart = thisMonthStart.addMonths(-1);
		List<Monthly_Production__c> productionToUpdate = new List<Monthly_Production__c>();

		//get the currently monthly production		
		List<Monthly_Production__c> monthlyProduction = 
			[SELECT Id, Installed_System__c, Start_of_Month__c, Enphase_kWh__c, Production_Guarantee__c, Astrum_Estimated__c
			FROM Monthly_Production__c
			WHERE Installed_System__c = :sys.Id];
		
		Map<Date, Monthly_Production__c> productionMap = new Map<Date, Monthly_Production__c>(); 

		//put into installed system, date map
		for (Monthly_Production__c mp : monthlyProduction) {
			productionMap.put(mp.Start_of_Month__c.toStartOfMonth(), mp); 
		}

		EnphaseAPI api = new EnphaseAPI();
		List<Enphase_Pull_Log__c> pullLogs = new List<Enphase_Pull_Log__c>();
		Integer recordNumber = 0;

		try {
				
			//get lifetime production by month from Enphase
			List<EnphaseAPI.EnphaseProduction> production = api.energy_lifetime_monthly(Integer.valueOf(sys.Enphase_ID__c));
			
			if (production.isEmpty()) {
				return 'No Production Data';
			}
			
			//calculate production estimates / guarantees
			List<PVWatts_Production_Estimates__c> pvw = 
				[SELECT January__c, February__c, March__c, April__c, May__c, June__c,
				July__c, August__c, September__c, October__c, November__c, December__c, Annual_Total__c
				FROM PVWatts_Production_Estimates__c
				WHERE Installed_System__c = :sys.Id
				ORDER BY LastModifiedDate DESC 
				LIMIT 1];

			Map<Date, ProductionGuaranteeCalculator.ProductionGuarantee> guaranteeMap 
				= new Map<Date, ProductionGuaranteeCalculator.ProductionGuarantee>();

			if (!pvw.isEmpty()) {
				List<ProductionGuaranteeCalculator.ProductionGuarantee> guar 
					= ProductionGuaranteeCalculator.getProductionGuarantee (
						pvw[0],
						sys.Quoted_System_Design__r.System_Design__r.Total_System_Size_kW__c,
						sys.Quoted_System_Design__r.System_Design__r.Total_Projected_Annual_Output_kWh_y__c,
						sys.Generation_Start_Date__c,
						sys.Property__r.Snow_De_Rate_kWh_y_kW__c
					);

				for (ProductionGuaranteeCalculator.ProductionGuarantee g : guar) {
					guaranteeMap.put(g.startOfMonth, g);
				}
			}
			
			Enphase_Pull_Log__c accum = new Enphase_Pull_Log__c();
			
			for (EnphaseAPI.EnphaseProduction prod : production) {
				Integer year = prod.productionDate.year();
				if (accum.Start_of_Year__c == null) {
					accum.Start_of_Year__c = Date.newInstance(year, 1, 1);
					accum.Installed_System__c = sys.Id;
					accum.Batch_Date__c = System.today();
				} else if (year != accum.Start_of_Year__c.year()) {
					pullLogs.add(accum);
					accum = new Enphase_Pull_Log__c();
				}
				Integer month = prod.productionDate.month();
				if (month == 1) {
					accum.Jan_Prod__c = prod.wattHours;
				} else if (month == 2) {
					accum.Feb_Prod__c = prod.wattHours;
				} else if (month == 3) {
					accum.Mar_Prod__c = prod.wattHours;
				} else if (month == 4) {
					accum.Apr_Prod__c = prod.wattHours;
				} else if (month == 5) {
					accum.May_Prod__c = prod.wattHours;
				} else if (month == 6) {
					accum.Jun_Prod__c = prod.wattHours;
				} else if (month == 7) {
					accum.Jul_Prod__c = prod.wattHours;
				} else if (month == 8) {
					accum.Aug_Prod__c = prod.wattHours;
				} else if (month == 9) {
					accum.Sep_Prod__c = prod.wattHours;
				} else if (month == 10) {
					accum.Oct_Prod__c = prod.wattHours;
				} else if (month == 11) {
					accum.Nov_Prod__c = prod.wattHours;
				} else if (month == 12) {
					accum.Dec_Prod__c = prod.wattHours;
				}
					
				//update monthly production, if not this month
				if (prod.productionDate.date() < thisMonthStart) {
					Monthly_Production__c mp = productionMap.get(prod.productionDate.date().toStartOfMonth()); 
					if (mp == null) {
						mp = new Monthly_Production__c (
							Installed_System__c = sys.Id,
							Start_of_Month__c = prod.productionDate.date().toStartOfMonth()
						);
						productionMap.put(prod.productionDate.date(), mp);
					} 
					
					Boolean changed = false;
					
					if (mp.Enphase_kWh__c != prod.kilowattHours) {
						mp.Enphase_kWh__c = prod.kilowattHours;
						changed = true;
					}
					
					ProductionGuaranteeCalculator.ProductionGuarantee pg 
						= guaranteeMap.get(mp.Start_of_Month__c.toStartOfMonth());

					if (pg != null) {
					
						if (mp.Production_Guarantee__c != pg.guarantee_kWh) {
							mp.Production_Guarantee__c = pg.guarantee_kWh;
							changed = true;
						}
	
						if (mp.Astrum_Estimated__c != pg.estimate_kWh) {
							mp.Astrum_Estimated__c = pg.estimate_kWh;
							changed = true;
						}
					
					}
					
					if (changed == true) {
						productionToUpdate.add(mp);
					}
					
				}
				
			}
				
			if (accum.Start_of_Year__c != null) {
				pullLogs.add(accum);
			}
				
		} catch (Exception e) {
			return e.getMessage() + ' \n' + e.getStackTraceString();
		}
			
		if (!pullLogs.isEmpty()) {
			insert pullLogs;
		}

		if (!productionToUpdate.isEmpty()) {
			upsert productionToUpdate;
		}
		
		return 'Success';		
		
	}
	
	public class ProcessStatus {
		public Installed_System__c sys { get; set; }
		public Boolean processed { get; set; }
		public DateTime processedTime;
		public String processDateTime { get { return processedTime != null ? processedTime.format('h:mm:ss a') : null; } } 
		public String status { get; set; }
	}

}