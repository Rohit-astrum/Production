/*
	11/25/14  DK  Added Utility Service relationship lookups to the SDI query (for PVWatts_ServiceClient)
	12/15/14  DK  Added Rate Code ID parameter to getUtilityServiceMonthlyProduction() to replace the old Property.RateCode lookup
	12/17/14  DK  Assume a Rate Code Tier 1 Cap of 100% if it's null
	02/25/15  DK  Write values to new Utility Service fields Before_First_Year_Avg_Price__c and Net_First_Year_Avg_Price__c
	06/28/15  RJ  CPQ-573
	07/21/15  DK  More CPQ-573. New overproduction and credit carry-over logic.
*/
public with sharing class UtilityPricingProcessor {

	private ID sysDesignID;
	private String method;
	private String errorLog;

	private static String[] months = new String[] {
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    };

    private static Double[] monthDays = new Double[] {
        31, 28.25, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    };

	public UtilityPricingProcessor(ID sdID, String method) {
		this.sysDesignID = sdID;	
		this.method = method;
		this.errorLog = '';
	}


	/*
	{Tier 1 (kWh/day) * Days in Month * Tier N Cap (% of Tier 1) + (Tier 1 (kWh/month) * Tier N Cap (% of Tier 1)}
	*/
	public Map<String,Decimal> getRateCodeTierCap(Utility_Service__c service, Utility_Company__c rateCode, String event)
	{
		System.debug('Inside getRateCodeTierCap for '+event);
		String rateTierT1Cap = '';
        String rateTierT2Cap = '';
        String rateTierT3Cap = '';
        String rateTierT4Cap = '';
        String rateTierT5Cap = '';


        Map<String,Decimal> monthlyTierMap = new Map<String,Decimal>();

		if(rateCode !=null && (rateCode.Baseline_Consumption_kWh_day__c != null || rateCode.Baseline_Consumption_kWh_month__c != null))
		{
			String[] dailyConsumption = null;
			String[] monthlyConsumption = null;
			Decimal cap = 0;
			Boolean isValidDailyData = false;
			Boolean isValidMonthlyData = false;
			Boolean isContinue = true;

			if(rateCode.Baseline_Consumption_kWh_day__c == 'NA' && rateCode.Baseline_Consumption_kWh_month__c == 'NA')
			{
				System.debug('Baseline Consumption Not Applicable for this Utility Rate Code');
        		service.put(event+'_Rate_Code_Tier_Cap__c','NA');	
			}
			else
			{
				// Get the Consumtption data into array - Assumption is Consumption data will be sperated by semicolon.
				if(rateCode.Baseline_Consumption_kWh_day__c != null && rateCode.Baseline_Consumption_kWh_day__c != 'NA' && rateCode.Baseline_Consumption_kWh_day__c != '')
				{
					dailyConsumption = rateCode.Baseline_Consumption_kWh_day__c.split(';');				
					if(dailyConsumption != null && dailyConsumption.size() != 12)
					{
						System.debug('Invalid DailyConsumption Data '+dailyConsumption);
					}
					else
					{
						isValidDailyData = true;
					}				
				}
				
				if(rateCode.Baseline_Consumption_kWh_month__c != null && rateCode.Baseline_Consumption_kWh_month__c != 'NA' && rateCode.Baseline_Consumption_kWh_month__c != '')
				{	
					monthlyConsumption = rateCode.Baseline_Consumption_kWh_month__c.split(';');
					if(monthlyConsumption != null && monthlyConsumption.size() != 12)
					{
						System.debug('Invalid monthlyConsumption Data '+monthlyConsumption);
					}
					else
					{
						isValidMonthlyData = true;
					}	
				}

				if(isValidDailyData || isValidMonthlyData)
				{
					for(integer i=0;i <= 11; i=i+1 )
					{	
						if(rateCode.Tier_1_Cap__c != null)
						{
							cap = 0;
							cap = cap + (isValidDailyData ? Double.valueOf(dailyConsumption[i]) * monthDays[i] * (rateCode.Tier_1_Cap__c/100) : 0 );
							cap = cap + (isValidMonthlyData ? Double.valueOf(monthlyConsumption[i]) * (rateCode.Tier_1_Cap__c/100) : 0 );									
							System.debug('T1-'+months[i]+' '+ cap.setScale(1));						
							monthlyTierMap.put('T1-'+months[i],  cap.setScale(1));		
							rateTierT1Cap = rateTierT1Cap + cap.setScale(1) + ';';					
						} else {
							//If it's null, assume a 100% cap
							cap = 0;
							cap = cap + (isValidDailyData ? Double.valueOf(dailyConsumption[i]) * monthDays[i] * 1 : 0 );
							cap = cap + (isValidMonthlyData ? Double.valueOf(monthlyConsumption[i]) * 1 : 0 );									
							System.debug('T1-'+months[i]+' '+ cap.setScale(1));						
							monthlyTierMap.put('T1-'+months[i],  cap.setScale(1));		
							rateTierT1Cap = rateTierT1Cap + cap.setScale(1) + ';';
						}

						if(rateCode.Tier_2_Cap__c != null)
						{
							cap = 0;
							cap = cap + (isValidDailyData ? Double.valueOf(dailyConsumption[i]) * monthDays[i] * (rateCode.Tier_2_Cap__c/100) : 0 );
							cap = cap + (isValidMonthlyData ? Double.valueOf(monthlyConsumption[i]) * (rateCode.Tier_2_Cap__c/100) : 0 );	
							System.debug('T2-'+months[i]+' '+cap.setScale(1));
							monthlyTierMap.put('T2-'+months[i], cap.setScale(1));	
							rateTierT2Cap = rateTierT2Cap + cap.setScale(1) + ';';
						}

						if(rateCode.Tier_3_Cap__c != null)
						{
							cap = 0;
							cap = cap + (isValidDailyData ? Double.valueOf(dailyConsumption[i]) * monthDays[i] * (rateCode.Tier_3_Cap__c/100) : 0 );
							cap = cap + (isValidMonthlyData ? Double.valueOf(monthlyConsumption[i]) * (rateCode.Tier_3_Cap__c/100) : 0 );	
							System.debug('T3-'+months[i]+' '+cap.setScale(1));
							monthlyTierMap.put('T3-'+months[i], cap.setScale(1));	
							rateTierT3Cap = rateTierT3Cap + cap.setScale(1) + ';';
						}

						if(rateCode.Tier_4_Cap__c != null)
						{
							cap = 0;
							cap = cap + (isValidDailyData ? Double.valueOf(dailyConsumption[i]) * monthDays[i] * (rateCode.Tier_4_Cap__c/100) : 0 );
							cap = cap + (isValidMonthlyData ? Double.valueOf(monthlyConsumption[i]) * (rateCode.Tier_4_Cap__c/100) : 0 );	
							System.debug('T4-'+months[i]+' '+cap.setScale(1));
							monthlyTierMap.put('T4-'+months[i], cap.setScale(1));	
							rateTierT4Cap = rateTierT4Cap + cap.setScale(1) + ';';
						}
						if(rateCode.Tier_5_Cap__c != null)
						{
							cap = 0;
							cap = cap + (isValidDailyData ? Double.valueOf(dailyConsumption[i]) * monthDays[i] * (rateCode.Tier_5_Cap__c/100) : 0 );
							cap = cap + (isValidMonthlyData ? Double.valueOf(monthlyConsumption[i]) * (rateCode.Tier_5_Cap__c/100) : 0 );	
							System.debug('T5-'+months[i]+' '+cap.setScale(1));
							monthlyTierMap.put('T5-'+months[i], cap.setScale(1));	
							rateTierT5Cap = rateTierT5Cap + cap.setScale(1) + ';';
						}
					}

					System.debug('monthlyTierMap '+monthlyTierMap);
					service.put(event+'_Rate_Code_Tier_Cap__c','T1:'+rateTierT1Cap+'\n'+'T2:'+rateTierT2Cap+'\n'+'T3:'+rateTierT3Cap+'\n'+'T4:'+rateTierT4Cap+'\n'+'T5:'+rateTierT5Cap);
				}
				else
				{
					String err = 'Invalid Baseline Consumption Data at Utility Rate Code';
					System.debug('Data Error : ' + err);
	        		service.put(event+'_Rate_Code_Tier_Cap__c','Data Error : ' + err);
	        		errorLog += err + '\n';
				}
			}			
        }   
        else
        {
        	String err = 'Baseline Consumption Data is not available at Utility Rate Code';
        	System.debug('Data Error : ' + err);
        	service.put(event+'_Rate_Code_Tier_Cap__c','Data Error : ' + err);
        	errorLog += err + '\n';	
        }

        return monthlyTierMap;
       
	}

	//If{Before Tier N Cap >= Total Forecasted Consumption, Total Forecasted Consumption – Before Tier N-1 Cap, Before Tier N Cap – Before Tier N-1 Cap}
	public Map<String,Decimal> getMonthlyTierConsuption(Utility_Service__c service, Utility_Company__c rateCode, Map<String,Decimal>  monthlyTierMap, String event)
	{
		System.debug('Inside getMonthlyTierConsuption for '+event);	
		String t1Cons = '';
        String t2Cons = '';
        String t3Cons = '';
        String t4Cons = '';
        String t5Cons = '';

        Map<String,Decimal> monthlyTierConsMap = new Map<String,Decimal>();

        if(monthlyTierMap.size() > 0 || service.get(event+'_Rate_Code_Tier_Cap__c') == 'NA' )
        {
        	for(integer i=0;i <= 11; i=i+1 )
			{
				double monthForecast = (Double) service.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c');
				System.debug(months[i]+' monthForecast '+monthForecast);
				Decimal t1cap = 0;
				Decimal t2cap = 0;
				Decimal t3cap = 0;
				Decimal t4cap = 0;
				Decimal t5cap = 0;
				Boolean isContinue = true;
				if(rateCode.Tier_1_Cap__c != null && monthlyTierMap.size() > 0)
				{
					t1cap = monthlyTierMap.get('T1-'+months[i]);
					//System.debug('T1-'+months[i]+' '+ Math.Round(cap));		
					if(t1cap >= monthForecast)
					{
						t1Cons = t1Cons+String.valueOf(monthForecast) + ';';	
						monthlyTierConsMap.put('T1-'+months[i],monthForecast);
						isContinue = false;
					}				
					else
					{							
						t1Cons = t1Cons+String.valueOf(t1cap) + ';';	
						monthlyTierConsMap.put('T1-'+months[i],t1cap);
					}
					System.debug(months[i]+' t1Cons '+t1Cons);
					
				}
				else
				{
					t1Cons = t1Cons+String.valueOf(monthForecast) + ';';	
					monthlyTierConsMap.put('T1-'+months[i],monthForecast);
					isContinue = false;	
				}

				if(rateCode.Tier_2_Cap__c != null)
				{
					if(isContinue)
					{
						t2cap = monthlyTierMap.get('T2-'+months[i]);
						//System.debug('T1-'+months[i]+' '+ Math.Round(cap));		
						if(t2cap >= monthForecast)
						{
							t2Cons = t2Cons+String.valueOf(monthForecast-t1cap) + ';';	
							monthlyTierConsMap.put('T2-'+months[i],monthForecast-t1cap);
							isContinue = false;
						}				
						else
						{							
							t2Cons = t2Cons+String.valueOf(t2cap-t1cap) + ';';	
							monthlyTierConsMap.put('T2-'+months[i],t2cap-t1cap);
						}
						System.debug(months[i]+' t2Cons '+ t2Cons);
					}
					else
					{
						t2Cons = t2Cons+String.valueOf(0) + ';';	
						monthlyTierConsMap.put('T2-'+months[i],0);	
					}
				}
				else
				{
					if(isContinue)
					{
						t2Cons = t2Cons+String.valueOf(monthForecast-t1cap) + ';';	
						monthlyTierConsMap.put('T2-'+months[i],monthForecast-t1cap);								
					}
					else
					{
						t2Cons = t2Cons+String.valueOf(0) + ';';	
						monthlyTierConsMap.put('T2-'+months[i],0);	
					}
					isContinue = false;	
				}

				if(rateCode.Tier_3_Cap__c != null )
				{
					if(isContinue)
					{
						t3cap = monthlyTierMap.get('T3-'+months[i]);
						//System.debug('T1-'+months[i]+' '+ Math.Round(cap));		
						if(t3cap >= monthForecast)
						{
							t3Cons = t3Cons+String.valueOf(monthForecast-t2cap) + ';';	
							monthlyTierConsMap.put('T3-'+months[i],monthForecast-t2cap);
							isContinue = false;
						}				
						else
						{							
							t3Cons = t3Cons+String.valueOf(t3cap-t2cap) + ';';	
							monthlyTierConsMap.put('T3-'+months[i],t3cap-t2cap);
						}
						System.debug(months[i]+' t3Cons '+t3Cons);
					}
					else
					{
						t3Cons = t3Cons+String.valueOf(0) + ';';	
						monthlyTierConsMap.put('T3-'+months[i],0);	
					}
				}
				else
				{
					if(isContinue)
					{
						t3Cons = t3Cons+String.valueOf(monthForecast-t2cap) + ';';	
						monthlyTierConsMap.put('T3-'+months[i],monthForecast-t2cap);	
					}							
					else
					{
						t3Cons = t3Cons+String.valueOf(0) + ';';	
						monthlyTierConsMap.put('T3-'+months[i],0);		
					}
					isContinue = false;	
				}

				if(rateCode.Tier_4_Cap__c != null )
				{
					if(isContinue)
					{
						t4cap = monthlyTierMap.get('T4-'+months[i]);
						//System.debug('T1-'+months[i]+' '+ Math.Round(cap));		
						if(t4cap >= monthForecast)
						{
							t4Cons = t4Cons+String.valueOf(monthForecast-t3cap) + ';';
							monthlyTierConsMap.put('T4-'+months[i],monthForecast-t3cap);	
							isContinue = false;
						}				
						else
						{							
							t4Cons = t4Cons+String.valueOf(t4cap-t3cap) + ';';	
							monthlyTierConsMap.put('T4-'+months[i],t4cap-t3cap);
						}
						System.debug(months[i]+' t4Cons '+t4Cons);
					}
					else
					{
						t4Cons = t4Cons+String.valueOf(0) + ';';	
						monthlyTierConsMap.put('T4-'+months[i],0);	
					}
				}
				else
				{
					if(isContinue)
					{
						t4Cons = t4Cons+String.valueOf(monthForecast-t3cap) + ';';
						monthlyTierConsMap.put('T4-'+months[i],monthForecast-t3cap);	
					}
					else
					{
						t4Cons = t4Cons+String.valueOf(0) + ';';	
						monthlyTierConsMap.put('T4-'+months[i],0);	
					}	
					isContinue = false;	
				}

				if(rateCode.Tier_5_Cap__c != null )
				{
					if(isContinue)
					{
						t5cap = monthlyTierMap.get('T5-'+months[i]);
						//System.debug('T1-'+months[i]+' '+ Math.Round(cap));		
						if(t5cap >= monthForecast)
						{
							t5Cons = t5Cons+String.valueOf(monthForecast-t4cap) + ';';
							monthlyTierConsMap.put('T5-'+months[i],monthForecast-t4cap);	
							isContinue = false;
						}				
						else
						{							
							t5Cons = t5Cons+String.valueOf(t5cap-t4cap) + ';';	
							monthlyTierConsMap.put('T5-'+months[i],t5cap-t4cap);
						}
						System.debug(months[i]+' t5Cons '+t5Cons);
					}
					else
					{
						t5Cons = t5Cons+String.valueOf(0) + ';';	
						monthlyTierConsMap.put('T5-'+months[i],0);	
					}
				}
				else
				{
					if(isContinue)
					{
						t5Cons = t5Cons+String.valueOf(monthForecast-t4cap) + ';';
						monthlyTierConsMap.put('T5-'+months[i],monthForecast-t4cap);	
					}
					else
					{
						t5Cons = t5Cons+String.valueOf(0) + ';';	
						monthlyTierConsMap.put('T5-'+months[i],0);	
					}	
					isContinue = false;	
				}
			}

        }
        service.put(event + '_Tier_1_Consumption_kWh__c',t1Cons);
        service.put(event + '_Tier_2_Consumption_kWh__c',t2Cons);
        service.put(event + '_Tier_3_Consumption_kWh__c',t3Cons);
        service.put(event + '_Tier_4_Consumption_kWh__c',t4Cons);
        service.put(event + '_Tier_5_Consumption_kWh__c',t5Cons);

        return monthlyTierConsMap;

	}

	//{(Consumption Profile where Weekday Schedule = Period P Rate Period) * % Weekdays + sum(Consumption Profile where Weekend Schedule = Period P Rate Period) * % Weekends}
	public Map<String,Decimal> getRatePeriodPercentageMap(Utility_Service__c service , Utility_Company__c rateCode, Map<String,Double>  monthWeekdayRatioMap, String event)
	{
        System.debug('Inside getRatePeriodPercentageMap for '+event);

        Map<String,double> hourlyMap = new Map<String,double>();
        List<Utility_Company__c> rateCodeList = new List<Utility_Company__c>();
        Map<String,Decimal> ratePeriodPercentageMap = new Map<String,Decimal>();
         
        Map<String,Double> period_1_Summary = new Map<String,Double>();
        Map<String,Double> period_2_Summary = new Map<String,Double>();
        Map<String,Double> period_3_Summary = new Map<String,Double>();
        Map<String,Double> period_4_Summary = new Map<String,Double>();
        Map<String,Double> period_5_Summary = new Map<String,Double>();

        String p1Percentage = '';
        String p2Percentage = '';
        String p3Percentage = '';
        String p4Percentage = '';
        String p5Percentage = '';

        String rateConsumationProfile = '';

    	if(service.Consumption_Profile__c == 'Average')
    	{
    		rateConsumationProfile = 	rateCode.Average_Consumption_Profile__c;
    	}
    	else if(service.Consumption_Profile__c == 'Mostly at Night')
    	{
    		rateConsumationProfile = 	rateCode.Night_Shifted_Consumption_Profile__c;	
    	}
    	else if(service.Consumption_Profile__c == 'Mostly at Night')
    	{
    		rateConsumationProfile = 	rateCode.Day_Shifted_Consumption_Profile__c;	
    	}
    	else
    	{
    		rateConsumationProfile = 	rateCode.Average_Consumption_Profile__c;	
    	}

    	if(rateConsumationProfile != null && rateConsumationProfile != 'NA' )
    	{
    		String[] consumptionProfile = rateConsumationProfile.split(';');

    		if(consumptionProfile != null && consumptionProfile.size() != 288)
			{
				String err = 'Invalid Consumption Profile Data at Rate Code';
				service.put(event+'_Rate_Period_Percent_Consumption__c','Data Error: ' + err);
				errorLog += err + '\n';
			}
			else
			{
	    		integer month = 0;        		
	    		integer hour = 1;
	    		for(integer i=0;i < consumptionProfile.size(); i=i+1 )
		        {                
		            hourlyMap.put(months[month]+'-'+hour ,Double.valueOf(consumptionProfile[i]) ); 
		            hour = hour+1; 
		            if(hour==25)
		            {
		                hour = 1;
		                month = month + 1;
		            }
		        }

		    	System.debug('hourlyMap '+hourlyMap);
		    	// get the Weekday Schedule Map		    	
		    	rateCodeList.add(rateCode);
		    	Map<String,String>  weekdayScheduleMap = PVWatts_ServiceClient.getWeekcheduleMap(rateCodeList , 'Weekday');
		    	// get the Weekend Schedule Map
		    	Map<String,String>  weekendScheduleMap = PVWatts_ServiceClient.getWeekcheduleMap(rateCodeList , 'Weekend');
		        
		       
		        // Populate Weekday and Weekend Summary
		        PVWatts_ServiceClient.populatePeriodSummary(hourlyMap,period_1_Summary,period_2_Summary,period_3_Summary,period_4_Summary,period_5_Summary, weekdayScheduleMap,'WD',null,null);
		        
		        PVWatts_ServiceClient.populatePeriodSummary(hourlyMap,period_1_Summary,period_2_Summary,period_3_Summary,period_4_Summary,period_5_Summary, weekendScheduleMap,'WE',null,null);
		        
		        
		        System.debug('period_1_Summary ** '+period_1_Summary.size());
		        System.debug('period_2_Summary ** '+period_2_Summary.size());
		        System.debug('period_3_Summary ** '+period_3_Summary.size());
		        System.debug('period_4_Summary ** '+period_4_Summary.size());
		        System.debug('period_5_Summary ** '+period_5_Summary.size());
		        System.debug('period_1_Summary.get(weekdayMonth) ** '+period_1_Summary.get(months[0]+'-WD'));
		        System.debug('period_1_Summary.get(weekendMonth) ** '+period_1_Summary.get(months[0]+'-WE'));

		       
		        // Apply Weekday ratio to Period Summary
		        double weekday_ratio = 1;
		       
		        for(integer i=0;i <= 11; i=i+1 )
		        {
		            weekday_ratio = monthWeekdayRatioMap.get(months[i]);
		            String weekdayMonth = months[i]+'-WD';
		            String weekendMonth = months[i]+'-WE';
		            if(period_1_Summary.size() > 0)
		            {
		                
		                if(period_1_Summary.get(weekdayMonth) != null)
		                {
		                    period_1_Summary.put(weekdayMonth,period_1_Summary.get(weekdayMonth) * weekday_ratio); 
		                }  
		                if(period_1_Summary.get(weekendMonth) != null)
		                {  
		                    period_1_Summary.put(weekendMonth, period_1_Summary.get(weekendMonth) * (1- weekday_ratio));
		                }    
		                Decimal consPercent = (period_1_Summary.get(weekdayMonth) != null ? period_1_Summary.get(weekdayMonth) : 0)
		                        + (period_1_Summary.get(weekendMonth) != null ? period_1_Summary.get(weekendMonth) : 0);

		                consPercent = consPercent.setScale(2);
		                ratePeriodPercentageMap.put('P1-'+months[i],consPercent );
		                p1Percentage = p1Percentage + String.valueOf(consPercent) + ';';
		            }
		            if(period_2_Summary.size() > 0)
		            {
		                if(period_2_Summary.get(weekdayMonth) != null)
		                {
		                    period_2_Summary.put(weekdayMonth,period_2_Summary.get(weekdayMonth) * weekday_ratio); 
		                }
		                if(period_2_Summary.get(weekendMonth) != null)
		                {    
		                    period_2_Summary.put(weekendMonth, period_2_Summary.get(weekendMonth) * (1- weekday_ratio));
		                }   
		                Decimal consPercent = (period_2_Summary.get(weekdayMonth) != null ? period_2_Summary.get(weekdayMonth) : 0)
		                        + (period_2_Summary.get(weekendMonth) != null ? period_2_Summary.get(weekendMonth) : 0);

		                consPercent = consPercent.setScale(2);
		                ratePeriodPercentageMap.put('P2-'+months[i],consPercent ); 
		                p2Percentage = p2Percentage + String.valueOf(consPercent) + ';';
		            }
		            if(period_3_Summary.size() > 0)
		            {
		                if(period_3_Summary.get(weekdayMonth) != null)
		                {
		                    period_3_Summary.put(weekdayMonth,period_3_Summary.get(weekdayMonth) * weekday_ratio); 
		                }
		                if(period_3_Summary.get(weekendMonth) != null)   
		                { 
		                    period_3_Summary.put(weekendMonth, period_3_Summary.get(weekendMonth) * (1- weekday_ratio));
		                }    
		                Decimal consPercent = (period_3_Summary.get(weekdayMonth) != null ? period_3_Summary.get(weekdayMonth) : 0)
		                        + (period_3_Summary.get(weekendMonth) != null ? period_3_Summary.get(weekendMonth) : 0);
		                
		                consPercent = consPercent.setScale(2);       
		                ratePeriodPercentageMap.put('P3-'+months[i],consPercent ); 
		                p3Percentage = p3Percentage + String.valueOf(consPercent) + ';';
		            }
		            if(period_4_Summary.size() > 0)
		            {
		                if(period_4_Summary.get(weekdayMonth) != null)
		                {
		                    period_4_Summary.put(weekdayMonth,period_4_Summary.get(weekdayMonth) * weekday_ratio); 
		                }
		                if(period_4_Summary.get(weekendMonth) != null)   
		                {
		                    period_4_Summary.put(weekendMonth, period_4_Summary.get(weekendMonth) * (1- weekday_ratio));
		                }  
		                
		                
		                Decimal consPercent = (period_4_Summary.get(weekdayMonth) != null ? period_4_Summary.get(weekdayMonth) : 0)
		                        + (period_4_Summary.get(weekendMonth) != null ? period_4_Summary.get(weekendMonth) : 0);

		                consPercent = consPercent.setScale(2);
		                ratePeriodPercentageMap.put('P4-'+months[i],consPercent );   
		                p4Percentage = p4Percentage + String.valueOf(consPercent) + ';';
		            }
		            if(period_5_Summary.size() > 0)
		            {
		                if(period_5_Summary.get(weekdayMonth) != null)
		                {
		                    period_5_Summary.put(weekdayMonth,period_5_Summary.get(weekdayMonth) * weekday_ratio); 
		                }
		                if(period_5_Summary.get(weekendMonth) != null)   
		                {
		                    period_5_Summary.put(weekendMonth, period_5_Summary.get(weekendMonth) * (1- weekday_ratio));
		                }    
		                
		                
		                Decimal consPercent = (period_5_Summary.get(weekdayMonth) != null ? period_5_Summary.get(weekdayMonth) : 0)
		                        + (period_5_Summary.get(weekendMonth) != null ? period_5_Summary.get(weekendMonth) : 0);

		                consPercent = consPercent.setScale(2);
		                ratePeriodPercentageMap.put('P5-'+months[i],consPercent );   
		                p5Percentage = p5Percentage + String.valueOf(consPercent) + ';';
		            }
		        }

		        service.put(event+'_Rate_Period_Percent_Consumption__c','P1:'+p1Percentage+'\n'+'P2:'+p2Percentage+'\n'+'P3:'+p3Percentage+'\n'+'P4:'+p4Percentage+'\n'+'P5:'+p5Percentage);
		    } 
		}
		else if (rateConsumationProfile != null && rateConsumationProfile == 'NA')
		{
			p1Percentage = '100;100;100;100;100;100;100;100;100;100;100;100;';
			for(Rate_Period__c rp : rateCode.Rate_Period__r )
        	{
				for(integer i=0;i <= 11; i=i+1 )
			    {			    	
			    	if(rp.Rate_Period__c == 1)
			    	{
			    		ratePeriodPercentageMap.put('P'+rp.Rate_Period__c+'-'+months[i],100); 			    		
			    	}
			    	else
			    	{
			    		ratePeriodPercentageMap.put('P'+rp.Rate_Period__c+'-'+months[i],0); 	
			    	}
			    }
			}
			service.put(event+'_Rate_Period_Percent_Consumption__c','P1:'+p1Percentage+'\n'+'P2:'+p2Percentage+'\n'+'P3:'+p3Percentage+'\n'+'P4:'+p4Percentage+'\n'+'P5:'+p5Percentage);
		}
		else 
		{
			String err = 'Consumption Profile Data Not Found at Rate Code';
			service.put(event+'_Rate_Period_Percent_Consumption__c','Data Error: ' + err);
			errorLog += err + '\n';
		}
        
        
        return ratePeriodPercentageMap;

	}

	//{Total Forecasted Consumption * Before Rate Period Percentage Consumption}
	public Map<String,Decimal> getRatePeriodConsumptionMap(Utility_Service__c service , Utility_Company__c rateCode, Map<String,Decimal> ratePeriodPercentMap, String event)
	{
        System.debug('Inside getRatePeriodConsumptionMap for '+event);

        Map<String,Decimal> ratePeriodConsumptionMap = new Map<String,Decimal>();         
        
        String p1Cons = '';
        String p2Cons = '';
        String p3Cons = '';
        String p4Cons = '';
        String p5Cons = '';
		
		for(Rate_Period__c rp : rateCode.Rate_Period__r )
    	{
			for(integer i=0;i <= 11; i=i+1 )
		    {
		    	double monthForecast = (Double) service.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c');
				System.debug(months[i]+' monthForecast '+monthForecast);
				Decimal percentCons = ratePeriodPercentMap.get('P'+rp.Rate_Period__c+'-'+months[i]);
				Decimal ratePeriodCons = 0;
				if(percentCons != null && monthForecast != null )
				{
					ratePeriodCons = monthForecast * (percentCons/ 100);
				}
				ratePeriodCons.setScale(1);
		    	ratePeriodConsumptionMap.put('P'+rp.Rate_Period__c+'-'+months[i],ratePeriodCons); 			    				    	

		    	if(rp.Rate_Period__c == 1)
		    	{
			    	p1Cons = p1Cons + String.valueOf(ratePeriodCons) + ';';	
		    	}
		    	if(rp.Rate_Period__c == 2)
		    	{
			    	p2Cons = p2Cons + String.valueOf(ratePeriodCons) + ';';	
		    	}
		    	if(rp.Rate_Period__c == 3)
		    	{
			    	p3Cons = p3Cons + String.valueOf(ratePeriodCons) + ';';	
		    	}
		    	if(rp.Rate_Period__c == 4)
		    	{
			    	p4Cons = p4Cons + String.valueOf(ratePeriodCons) + ';';	
		    	}
		    	if(rp.Rate_Period__c == 5)
		    	{
			    	p5Cons = p5Cons + String.valueOf(ratePeriodCons) + ';';	
		    	}

		    }
		}
		service.put(event+'_Rate_Period_Consumption__c','P1:'+p1Cons+'\n'+'P2:'+p2Cons+'\n'+'P3:'+p3Cons+'\n'+'P4:'+p4Cons+'\n'+'P5:'+p5Cons);
		
        return ratePeriodConsumptionMap;

	}

	//sum(1-P){Before Tier N Consumption * Rate Period Percentage of ConsumptionP, * Tier N RateP}
	public Map<String,Decimal> getRateCodeTierCost(Utility_Service__c service, Utility_Company__c rateCode,Map<String,double> monthlyTierConsMap,Map<String,Decimal> ratePeriodPercentageMap,String event, String method )
	{
		System.debug('Inside getRateCodeTierCost for '+event);
		String t1CostStr = '';
        String t2CostStr = '';
        String t3CostStr = '';
        String t4CostStr = '';
        String t5CostStr = '';

		Map<String,Double> monthlyTierCostMap = new Map<String,Decimal>();

        for(Rate_Period__c rp : rateCode.Rate_Period__r )
        {	        	
        	System.debug(rp.Rate_Period__c);
        	for(integer i=0;i <= 11; i=i+1 )
			{
				Decimal t1Consumtion  = monthlyTierConsMap.get('T1-'+months[i]);
				Decimal t2Consumtion  = monthlyTierConsMap.get('T2-'+months[i]);
				Decimal t3Consumtion  = monthlyTierConsMap.get('T3-'+months[i]);
				Decimal t4Consumtion  = monthlyTierConsMap.get('T4-'+months[i]);
				Decimal t5Consumtion  = monthlyTierConsMap.get('T5-'+months[i]);
				
				System.debug('t1Consumtion '+t1Consumtion + ' t2Consumtion' +t2Consumtion+ ' t3Consumtion' +t3Consumtion+ ' t4Consumtion' +t4Consumtion+ ' t5Consumtion' +t5Consumtion);
				
				Decimal t1cost = 0;
				Decimal t2cost = 0;
				Decimal t3cost = 0;
				Decimal t4cost = 0;
				Decimal t5cost = 0;

				double periodPercentConsuption = ratePeriodPercentageMap.get('P'+rp.Rate_Period__c+'-'+months[i]); 
				if(periodPercentConsuption != null)
				{
					periodPercentConsuption = (periodPercentConsuption / 100);
					System.debug('periodPercentConsuption '+periodPercentConsuption);
				}
	        	if(rp.Tier_1_Rate_kWh__c != null && t1Consumtion != null && periodPercentConsuption != null  )
				{
					t1cost = t1Consumtion * periodPercentConsuption * rp.Tier_1_Rate_kWh__c ;
					t1cost = t1cost.setScale(2);
					System.debug(months[i]+' t1cost '+t1cost);
					if(monthlyTierCostMap.get('T1-'+months[i]) != null)
					{
						monthlyTierCostMap.put('T1-'+months[i] , monthlyTierCostMap.get('T1-'+months[i])  + t1cost);
					}	
					else
					{
						monthlyTierCostMap.put('T1-'+months[i], t1cost );
					}	
				}

				if(rp.Tier_2_Rate_kWh__c != null && t2Consumtion != null && periodPercentConsuption != null  )
				{
					t2cost = t2Consumtion * periodPercentConsuption * rp.Tier_2_Rate_kWh__c ;
					t2cost = t2cost.setScale(2);
					System.debug(months[i]+' t2cost '+t2cost);
					if(monthlyTierCostMap.get('T2-'+months[i]) != null)
					{
						monthlyTierCostMap.put('T2-'+months[i] , monthlyTierCostMap.get('T2-'+months[i])  + t2cost);
					}	
					else
					{
						monthlyTierCostMap.put('T2-'+months[i], t2cost );
					}	
				}

				if(rp.Tier_3_Rate_kWh__c != null && t3Consumtion != null && periodPercentConsuption != null  )
				{
					t3cost = t3Consumtion * periodPercentConsuption * rp.Tier_3_Rate_kWh__c ;
					t3cost = t3cost.setScale(2);
					System.debug(months[i]+' t3cost '+t3cost);
					if(monthlyTierCostMap.get('T3-'+months[i]) != null)
					{
						monthlyTierCostMap.put('T3-'+months[i] , monthlyTierCostMap.get('T3-'+months[i])  + t3cost);
					}	
					else
					{
						monthlyTierCostMap.put('T3-'+months[i], t3cost );
					}	
				}

				if(rp.Tier_4_Rate_kWh__c != null && t4Consumtion != null && periodPercentConsuption != null  )
				{
					t4cost = t4Consumtion * periodPercentConsuption * rp.Tier_4_Rate_kWh__c ;
					t4cost = t4cost.setScale(2);
					System.debug(months[i]+' t4cost '+t4cost);
					if(monthlyTierCostMap.get('T4-'+months[i]) != null)
					{
						monthlyTierCostMap.put('T4-'+months[i] , monthlyTierCostMap.get('T4-'+months[i])  + t4cost);
					}	
					else
					{
						monthlyTierCostMap.put('T4-'+months[i], t4cost );
					}	
				}

				if(rp.Tier_5_Rate_kWh__c != null && t5Consumtion != null && periodPercentConsuption != null  )
				{
					t5cost = t5Consumtion * periodPercentConsuption * rp.Tier_5_Rate_kWh__c ;
					t5cost = t5cost.setScale(2);
					System.debug(months[i]+' t5cost '+t5cost);
					if(monthlyTierCostMap.get('T5-'+months[i]) != null)
					{
						monthlyTierCostMap.put('T5-'+months[i] , monthlyTierCostMap.get('T5-'+months[i])  + t5cost);
					}	
					else
					{
						monthlyTierCostMap.put('T5-'+months[i], t5cost );
					}	
				}

			}
        }

        for(integer i=0;i <= 11; i=i+1 )
		{	        	
        	if(monthlyTierCostMap.get('T1-'+months[i]) != null)
        	{
        		t1CostStr = t1CostStr + 	String.ValueOf(monthlyTierCostMap.get('T1-'+months[i])) + ';';
        	}
        	if(monthlyTierCostMap.get('T2-'+months[i]) != null)
        	{
        		t2CostStr = t2CostStr + 	String.ValueOf(monthlyTierCostMap.get('T2-'+months[i])) + ';';
        	}
        	if(monthlyTierCostMap.get('T3-'+months[i]) != null)
        	{
        		t3CostStr = t3CostStr + 	String.ValueOf(monthlyTierCostMap.get('T3-'+months[i])) + ';';
        	}
        	if(monthlyTierCostMap.get('T4-'+months[i]) != null)
        	{
        		t4CostStr = t4CostStr + 	String.ValueOf(monthlyTierCostMap.get('T4-'+months[i])) + ';';
        	}
        	if(monthlyTierCostMap.get('T5-'+months[i]) != null)
        	{
        		t5CostStr = t5CostStr + 	String.ValueOf(monthlyTierCostMap.get('T5-'+months[i])) + ';';
        	}
        	        	
        }

        if(event != 'Solar')
        {
	        service.put(event + method + '_Tier_1_Cost__c',t1CostStr);
	        service.put(event + method + '_Tier_2_Cost__c',t2CostStr);
	        service.put(event + method + '_Tier_3_Cost__c',t3CostStr);
	        service.put(event + method + '_Tier_4_Cost__c',t4CostStr);
	        service.put(event + method + '_Tier_5_Cost__c',t5CostStr);
	    }
	    else
	    {
	    	service.put(event + method + '_Tier_1_Value__c',t1CostStr);
	        service.put(event + method + '_Tier_2_Value__c',t2CostStr);
	        service.put(event + method + '_Tier_3_Value__c',t3CostStr);
	        service.put(event + method + '_Tier_4_Value__c',t4CostStr);
	        service.put(event + method + '_Tier_5_Value__c',t5CostStr);	
	    }    
        return monthlyTierCostMap;
	}

	
	public double getReliabilityCharge(Utility_Company__c rateCode, Decimal amps)
	{
		double charge = 0;
		if(amps != null)
		{
			if(amps <= 100)
			{
				charge = (rateCode.Service_Amp_Reliability_Charge_100A__c != null ? rateCode.Service_Amp_Reliability_Charge_100A__c :0) ;	
			}
			else if( amps > 100 && amps <= 200 )
			{
				charge = (rateCode.Service_Amp_Reliability_Charge_101_200A__c != null ?  rateCode.Service_Amp_Reliability_Charge_101_200A__c :0 );	
			}
			else if( amps > 200 && amps <= 400 )
			{
				charge = (rateCode.Service_Amp_Reliability_Charge_201_400A__c != null ? rateCode.Service_Amp_Reliability_Charge_201_400A__c : 0 );	
			}
			else if( amps > 400 )
			{
				charge = (rateCode.Service_Amp_Reliability_Charge_400A__c != null ? rateCode.Service_Amp_Reliability_Charge_400A__c : 0);	
			}
		}
		return charge;
	}

	//Before : {Daily Fixed Charge * Days in Month + Monthly Fixed Charge + Reliability ChargeR}
	//After : {Daily Fixed Charge * Days in Month + Monthly Fixed Charge}
	public Map<String,Double> getFixedCosts(Utility_Service__c service, Utility_Company__c rateCode , String event, String method)
	{
		System.debug('Inside getFixedCosts for '+event);
		double reliabilityCharge = 0;
		String fixedCostStr = '';
		Map<String,Double> monthlyFixedCostMap = new Map<String,Double>();
		double dailyFixedCharge = (rateCode.Daily_Fixed_Charge__c != null ? rateCode.Daily_Fixed_Charge__c : 0);
		double monthlyFixedCharge = (rateCode.Monthly_Fixed_Charge__c != null ? rateCode.Monthly_Fixed_Charge__c : 0);

		reliabilityCharge = getReliabilityCharge(rateCode , service.Amperage__c );		
        
        System.debug('reliabilityCharge '+ reliabilityCharge + 'dailyFixedCharge '+ dailyFixedCharge + ' monthlyFixedCharge '+monthlyFixedCharge);
        Decimal fixedCost =0;

        for(integer i=0;i <= 11; i=i+1 )
		{
			fixedCost = (dailyFixedCharge * monthDays[i] ) + monthlyFixedCharge + reliabilityCharge ;
			System.debug('* '+fixedCost);
			fixedCost = fixedCost.setScale(2);
			monthlyFixedCostMap.put(months[i],fixedCost);
			fixedCostStr = fixedCostStr + fixedCost + ';';									
		}      
		service.put(event + method + '_Fixed_Costs__c',fixedCostStr);
		return monthlyFixedCostMap;
	}

	//Max{sum(1-N)(Before Tier N Cost) – Electric Vehicle Discount * (Current Electricity Consumption Apr + Forecasted Additional Consumption Apr) 
	//	+ Before Fixed Costs, Minimum Daily Bill * Days in Month + Minimum Monthly Bill}
	//Max{sum(1-N)(After Method D Tier N Cost) – Electric Vehicle Discount * (Sum(1-N)After Tier N Consumption) 
	//	+ After Method D Fixed Costs, Minimum Daily Bill * Days in Month + Minimum Monthly Bill}
	public Map<String,double> getTotalBill(Utility_Service__c service , Utility_Company__c rateCode , Map<String,Double> monthlyTierCostMap,Map<String,Double> monthlyFixedCostMap ,Map<String,Double> monthlyVariableCostMap, String event)
	{
		System.debug('Inside getTotalBill for '+event);
		double electricVehicleDisc = (rateCode.Electric_Vehicle_Discount_kWh__c != null ? rateCode.Electric_Vehicle_Discount_kWh__c : 0);
        double minDailyBill = (rateCode.Daily_Minimum_Bill__c != null ? rateCode.Daily_Minimum_Bill__c : 0);
        double minMonthBill = (rateCode.Monthly_Minimum_Bill__c != null ? rateCode.Monthly_Minimum_Bill__c : 0);
        String monthlyBillStr = '';        

		Map<String,Double> monthlyTotalBillMap = new Map<String,Double>();

        for(integer i=0;i <= 11; i=i+1 )
		{
			double tierCost = 0;
			double fixedCost = 0;
			double calcMonthTotalBill = 0;
			double minMonthTotalBill = 0;
			Decimal monthTotalBill = 0;
			double monthForecast = 0;

			if(event != 'Solar')
			{
				tierCost = (monthlyTierCostMap.get('T1-'+months[i])	!= null ? monthlyTierCostMap.get('T1-'+months[i]) : 0);
				System.debug('Inside getTotalBill for T1-'+months[i] +' '+tierCost);
				tierCost = tierCost + (monthlyTierCostMap.get('T2-'+months[i])	!= null ? monthlyTierCostMap.get('T2-'+months[i]) : 0);
				System.debug('Inside getTotalBill for T1 + T2-'+months[i] +' '+tierCost);
				tierCost = tierCost + (monthlyTierCostMap.get('T3-'+months[i])	!= null ? monthlyTierCostMap.get('T3-'+months[i]) : 0);
				System.debug('Inside getTotalBill for T1 + T2 + T3-'+months[i] +' '+tierCost);
				tierCost = tierCost + (monthlyTierCostMap.get('T4-'+months[i])	!= null ? monthlyTierCostMap.get('T4-'+months[i]) : 0);
				tierCost = tierCost + (monthlyTierCostMap.get('T5-'+months[i])	!= null ? monthlyTierCostMap.get('T5-'+months[i]) : 0);
			}
			else
			{
				tierCost = monthlyVariableCostMap.get(months[i]);	
			}	
			monthForecast = (Double) service.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c');
			/*if(event == 'Before')
			{
				monthForecast = (Double) service.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c');
			}
			else
			{
				monthForecast = afterMonthlyConsMap.get(months[i]);	
				if(monthForecast < 0)
				{
					monthForecast = 0;
				}
			}
			*/

			if(monthlyFixedCostMap != null && monthlyFixedCostMap.get(months[i]) != null)
			{
				fixedCost = monthlyFixedCostMap.get(months[i]);
			}

			calcMonthTotalBill = tierCost - (electricVehicleDisc * monthForecast) + fixedCost;
			minMonthTotalBill = minDailyBill * monthDays[i] + minMonthBill;
			monthTotalBill = Math.max(calcMonthTotalBill,minMonthTotalBill);

			if(i == 3 && event == 'Solar' && tierCost < 0)
			{
				monthTotalBill = calcMonthTotalBill;
			}

			
			monthTotalBill = monthTotalBill.setScale(2);
			monthlyTotalBillMap.put(months[i], monthTotalBill);
			monthlyBillStr = monthlyBillStr + String.valueOf(monthTotalBill) + ';';	

		}

		if (event != 'Solar'){
			service.put(event + '_Total_Bill__c', monthlyBillStr);		//service.put(event + method + '_Total_Bill__c', monthlyBillStr); before "method" parameter was removed
		}// else {
		//	service.put(method + '_Net_Bill__c', monthlyBillStr);	//CPQ-573  DK  Moved this to getUtilityServiceMonthlyProduction()
		//}

		return monthlyTotalBillMap;
	}


	public String getUtilityServiceMonthlyProduction(ID utilRateCodeID){
		errorLog = '';	//reset
		Set<id> serviceIds = new Set<Id>();
		Set<id> rateCodeIds = new Set<Id>();
		Map<id,Map<String,double>> utilityProductionMap = new Map<id,Map<String,double>>();
		Map<id,Map<String,double>> utilityMonthlyProductionMap = new Map<id,Map<String,double>>();
		// Get the list of Utility Services in a given Systyem Design
		List<System_Design_Item__c> items = [Select System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c
                                            	   ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c
												   ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c
												   ,System_Design_Array__r.CB_Panel__r.Utility_Service__c
												   ,System_Design_Array__r.CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__c
												   ,System_Design_Array__r.CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c
												   ,Method_1_Period_1_Production_kWh__c,Method_1_Period_2_Production_kWh__c,Method_1_Period_3_Production_kWh__c
												   ,Method_1_Period_4_Production_kWh__c,Method_1_Period_5_Production_kWh__c,Method_1_Period_6_Production_kWh__c
												   ,Rated_Output_kW__c
											   From System_Design_Item__c Where RecordType.DeveloperName = 'Panel' AND Quantity__c > 0 
											    AND System_Design_Array__r.System_Design__c = :sysDesignID order by System_Design_Array__r.CB_Panel__r.Utility_Service__c];

		if(utilRateCodeID == null)
		{
			if(items != null && items.size() > 0)
			{
				utilRateCodeID= items[0].System_Design_Array__r.CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__c;					
			}
		}

		List<Rate_Period__c> periods = [Select Rate_period__c
                                         from Rate_Period__c 
                                        where Utility_Company__c = :utilRateCodeID 
                                     order by Rate_period__c];

        String fieldName = '';
        String monthFieldName = '';
        String periodFieldName = '';
        
		if(items != null && items.size() > 0)
		{
			for(System_Design_Item__c item : items)
			{
				serviceIds.add(item.System_Design_Array__r.CB_Panel__r.Utility_Service__c);

				rateCodeIds.add(item.System_Design_Array__r.CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__c);
				rateCodeIds.add(item.System_Design_Array__r.CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c);

				Utility_Service__c service = null;
				Map<String,double> productionMap;	
				Map<String,double> productionMonthMap;			
				System.debug('Service Id '+ item.System_Design_Array__r.CB_Panel__r.Utility_Service__c);
				
				if(utilityProductionMap.get(item.System_Design_Array__r.CB_Panel__r.Utility_Service__c) == null)
				{
					productionMap = new Map<String,double>();
					utilityProductionMap.put(item.System_Design_Array__r.CB_Panel__r.Utility_Service__c,productionMap);					
				}
				else
				{
					productionMap = utilityProductionMap.get(item.System_Design_Array__r.CB_Panel__r.Utility_Service__c );
				}

				if(utilityMonthlyProductionMap.get(item.System_Design_Array__r.CB_Panel__r.Utility_Service__c) == null)
				{
					productionMonthMap = new Map<String,double>();
					utilityMonthlyProductionMap.put(item.System_Design_Array__r.CB_Panel__r.Utility_Service__c,productionMonthMap);					
				}
				else
				{
					productionMonthMap = utilityMonthlyProductionMap.get(item.System_Design_Array__r.CB_Panel__r.Utility_Service__c );
				}

				for(Rate_Period__c rp : periods)
				{
					periodFieldName = method+'_Period_'+rp.Rate_period__c+'_Production_kWh__c';
					if(item.get(periodFieldName) != null)
					{
						String itemProduction = (String)item.get(periodFieldName);
						String[] itemProductions = itemProduction.split(';');
						System.debug(periodFieldName+' itemProductions '+ itemProductions);
						Decimal itemProd = 0;
						for(integer i=0;i <= 11; i=i+1 )
	        			{
							//fieldName = method + '_Period_'+period.Rate_period__c+'_'+months[i];
							fieldName = 'P'+rp.Rate_Period__c+'-'+months[i];
							monthFieldName = method +'_'+months[i];
							itemProd = Decimal.valueOf(itemProductions[i]).setScale(3);
							if(productionMap.get(fieldName) == null)
							{
								productionMap.put(fieldName, itemProd ); //Double.valueOf(itemProductions[i]));
							}
							else
							{
								productionMap.put(fieldName, productionMap.get(fieldName) +  itemProd ); //Double.valueOf(itemProductions[i]));	
							}

							if(productionMonthMap.get(monthFieldName) == null)
							{
								productionMonthMap.put(monthFieldName, itemProd ); //Double.valueOf(itemProductions[i]));
							}
							else
							{
								productionMonthMap.put(monthFieldName, productionMonthMap.get(monthFieldName) +  itemProd ); //Double.valueOf(itemProductions[i]));
							}
							System.debug(fieldName +'  '+ productionMap.get(fieldName));
							System.debug(monthFieldName +'  '+ productionMonthMap.get(monthFieldName));

						}
					}					
				}
			}
		}

		System.debug('utilityProductionMap '+utilityProductionMap);

		//Map<Id,Map<String,double>> beforeTierCap = new Map<Id,Map<String,double>>();
		//Map<Id,Map<String,double>> afterTierCap = new Map<Id,Map<String,double>>();

		Map<id,Utility_Service__c> servicesMap = new Map<id,Utility_Service__c>([Select Id, Utility_Rate_Code_Before_Solar__c, Utility_Rate_Code_After_Solar__c,Utility_Value_of_Solar_Tariff__c
												,Total_Forecasted_Consumption_kWh_Jan__c,Total_Forecasted_Consumption_kWh_Feb__c,Total_Forecasted_Consumption_kWh_Mar__c,Total_Forecasted_Consumption_kWh_Apr__c
												,Total_Forecasted_Consumption_kWh_May__c,Total_Forecasted_Consumption_kWh_Jun__c,Total_Forecasted_Consumption_kWh_Jul__c,Total_Forecasted_Consumption_kWh_Aug__c
												,Total_Forecasted_Consumption_kWh_Sep__c,Total_Forecasted_Consumption_kWh_Oct__c,Total_Forecasted_Consumption_kWh_Nov__c,Total_Forecasted_Consumption_kWh_Dec__c
												,Before_Tier_1_Consumption_kWh__c,Before_Tier_2_Consumption_kWh__c,Before_Tier_3_Consumption_kWh__c,Before_Tier_4_Consumption_kWh__c,Before_Tier_5_Consumption_kWh__c
												,Consumption_Profile__c,Utility_Company__c,Amperage__c,Utility_Company_Master__r.Solar_Compensation_Method__c 
												,Total_Forecasted_Consumption_kWh__c
											From Utility_Service__c 
										   Where id in :serviceIds]);
		
		Map<id,Utility_Company__c> rateCodeMap = new Map<id,Utility_Company__c>([Select Tier_1_Cap__c, Tier_2_Cap__c,Tier_3_Cap__c,Tier_4_Cap__c,Tier_5_Cap__c
																				   ,Baseline_Consumption_kWh_day__c,Baseline_Consumption_kWh_month__c
																				   ,Average_Consumption_Profile__c,Day_Shifted_Consumption_Profile__c,Night_Shifted_Consumption_Profile__c
																				   ,Weekday_Schedule__c,Weekend_Schedule__c,Over_Production_Credit__c
																				   ,Daily_Fixed_Charge__c,Monthly_Fixed_Charge__c
																				   ,Daily_Minimum_Bill__c,Monthly_Minimum_Bill__c
																				   ,Electric_Vehicle_Discount_kWh__c, Over_Production_Credit_Rate__c
																				   ,Service_Amp_Reliability_Charge_100A__c,Service_Amp_Reliability_Charge_101_200A__c
																				   ,Service_Amp_Reliability_Charge_201_400A__c,Service_Amp_Reliability_Charge_400A__c																					 
																				   ,(Select Rate_period__c ,Tier_1_Rate_kWh__c,Tier_2_Rate_kWh__c,Tier_3_Rate_kWh__c
																				   	       ,Tier_4_Rate_kWh__c,Tier_5_Rate_kWh__c
																				           ,period_type__c from Rate_Period__r order by Rate_period__c)
			 																	   From Utility_Company__c 
			 																	  Where Id in :rateCodeIds]);

		/*Lease_Fund__c[] termLoan = [SELECT Assumed_Utility_Rate_Annual_Escalator__c FROM Lease_Fund__c WHERE Name LIKE '%Hudson%' AND RecordType.DeveloperName = 'Term_Loan' 
									AND Available_Fund__c = true AND Active_Fund__c = true LIMIT 1];
		*/
		for(Utility_Service__c service : servicesMap.values())
		{
			try 
			{
				// Reset all the fields
				service.put('Before_Rate_Code_Tier_Cap__c' , '');
				service.put('After_Rate_Code_Tier_Cap__c' , '');

				service.put('Before_Rate_Period_Percent_Consumption__c', '');
				service.put('After_Rate_Period_Percent_Consumption__c', '');

				service.put('Before_Tier_1_Cost__c','');
		        service.put('Before_Tier_2_Cost__c','');
		        service.put('Before_Tier_3_Cost__c','');
		        service.put('Before_Tier_4_Cost__c','');
		        service.put('Before_Tier_5_Cost__c','');

		        service.put('After_Tier_1_Cost__c','');
		        service.put('After_Tier_2_Cost__c','');
		        service.put('After_Tier_3_Cost__c','');
		        service.put('After_Tier_4_Cost__c','');
		        service.put('After_Tier_5_Cost__c','');

		        service.put('Before_Tier_1_Consumption_kWh__c','');
		        service.put('Before_Tier_2_Consumption_kWh__c','');
		        service.put('Before_Tier_3_Consumption_kWh__c','');
		        service.put('Before_Tier_4_Consumption_kWh__c','');
		        service.put('Before_Tier_5_Consumption_kWh__c','');

		        service.put('After_Tier_1_Consumption_kWh__c','');
		        service.put('After_Tier_2_Consumption_kWh__c','');
		        service.put('After_Tier_3_Consumption_kWh__c','');
		        service.put('After_Tier_4_Consumption_kWh__c','');
		        service.put('After_Tier_5_Consumption_kWh__c','');

		        service.put('Before_Fixed_Costs__c','');
		        service.put('After_Fixed_Costs__c','');

		        service.put('Before_Total_Bill__c','');
		        service.put('After_Total_Bill__c','');

		        service.put(method + '_Avoided_Utility_Rate__c',null);

		        service.put('Net_Consumption__c', '');
				service.put(method + '_Positive_Consumption__c', '');
				service.put(method + '_Monthly_Production_Credit__c', '');
				service.put(method + '_Creditable_Consumption__c', '');
				service.put(method + '_Billable_Consumption__c', '');
				service.put(method + '_Net_Variable_Bill__c', '');
				service.put(method + '_Total_Variable_Bill__c', '');
			    service.put(method + '_Variable_Cost__c', '');
			    service.put(method + '_Monthly_Creditable_Amount__c', '');
			    service.put(method + '_Monthly_Bill_Credit__c', '');
			    service.put(method + '_Annual_Prod_Credit__c', 0);
				service.put(method + '_Net_Bill__c', 0);
				service.put(method + '_Net_Savings__c', 0);


				Map<String,Decimal> beforeMonthlyTierMap = new Map<String,Decimal>();
				Map<String,Decimal> afterMonthlyTierMap = new Map<String,Decimal>();
				Map<String,Decimal> solarMonthlyTierMap = new Map<String,Decimal>();

				Map<String,Decimal> beforeMonthlyTierConsMap = new Map<String,Decimal>();
				Map<String,Decimal> afterMonthlyTierConsMap = new Map<String,Decimal>();
				//Map<String,Decimal> solarMonthlyTierProdMap = new Map<String,Decimal>();

				Map<String,double> productionMonthMap = utilityMonthlyProductionMap.get(service.id);

				if(productionMonthMap != null && productionMonthMap.size() != 12)
				{
					service.put(method+'_Production_kWh__c','Monthly Production Data is not available. Please re-run the Site Quality Calculation.');	
					throw new customException('Monthly Production Data is not available. Please re-run the Site Quality Calculation.');
				}
				
				String monthProd = '';
				for(integer i=0;i <= 11; i=i+1 )
				{
					monthProd = monthProd + Decimal.valueOf(productionMonthMap.get(method+'_'+months[i])).setScale(3) + ';';
				}
				service.put(method+'_Production_kWh__c',monthProd);

				//Set Rate Codes
				Utility_Company__c beforeRateCode = rateCodeMap.get(service.Utility_Rate_Code_Before_Solar__c); 
				Utility_Company__c afterRateCode = rateCodeMap.get(service.Utility_Rate_Code_After_Solar__c); 
				Utility_Company__c solarRateCode = rateCodeMap.get(service.Utility_Value_of_Solar_Tariff__c);

				if (solarRateCode == null)
					solarRateCode = afterRateCode;
				
				if (beforeRateCode == null){
					service.put('Before_Rate_Code_Tier_Cap__c','Before  Rate Code are not defined for Utility Service.');	
					throw new customException('Before Rate Code are not defined for Utility Service.');
				}

				if (afterRateCode == null){
					service.put('After_Rate_Code_Tier_Cap__c','After  Rate Code are not defined for Utility Service.');	
					throw new customException('After Rate Code are not defined for Utility Service.');
				}

				//CPQ-573  DK  07/20/15
				Double[] method1productionMonths = new Double[]{};
				for (String str : monthProd.split(';', 0)){
					method1productionMonths.add(Double.valueOf(str));
				}
				String netConsumption = '';
				String positiveConsumption = '';
				String prodCredit = '';
				Double sumProdCredit = 0;
				Double sumCreditableConsumption = 0;
				String creditableConsumption = '';
				String billableConsumption = '';
				for (Integer i = 0; i <= 11; i = i+1){
					if (method1productionMonths.size() >= i){
						Double consumptionMinusProduction = (Double)service.get('Total_Forecasted_Consumption_kWh_' + months[i] + '__c') - method1productionMonths[i];
						netConsumption = netConsumption + String.valueOf(Decimal.valueOf(consumptionMinusProduction).setScale(2)) + ';';
						positiveConsumption = positiveConsumption + String.valueOf(Math.max(consumptionMinusProduction, 0)) + ';';
						prodCredit = prodCredit + String.valueOf(Math.min(consumptionMinusProduction, 0)) + ';';
						sumProdCredit += Math.min(consumptionMinusProduction, 0);
						if (sumProdCredit < 0){
							creditableConsumption = creditableConsumption + String.valueOf(Math.max(consumptionMinusProduction, 0)) + ';';
							sumCreditableConsumption += Math.max(consumptionMinusProduction, 0);
							billableConsumption = billableConsumption + String.valueOf(Math.max(Math.min(sumProdCredit + sumCreditableConsumption, Math.max(consumptionMinusProduction, 0)), 0)) + ';';
						} else {
							creditableConsumption = creditableConsumption + '0.0;';
							billableConsumption = billableConsumption + String.valueOf(Math.max(consumptionMinusProduction, 0)) + ';';
						}
					}
				}
				service.put('Net_Consumption__c', netConsumption);
				if (solarRateCode.Over_Production_Credit__c == 'kWH'){
					service.put(method + '_Positive_Consumption__c', positiveConsumption);
					service.put(method + '_Monthly_Production_Credit__c', prodCredit);
					service.put(method + '_Creditable_Consumption__c', creditableConsumption);
					service.put(method + '_Billable_Consumption__c', billableConsumption);
				}


				/*********************************************************************/
				// Get Before/After Tier N Cap

				beforeMonthlyTierMap = getRateCodeTierCap(service, beforeRateCode, 'Before');

				if(beforeMonthlyTierMap.isEmpty() && service.get('Before_Rate_Code_Tier_Cap__c') != 'NA')
				{
					throw new customException('Error while getting Before Monthly Tier Cap.');
				}

		        if(beforeRateCode == afterRateCode)     
		        {
		        	afterMonthlyTierMap = beforeMonthlyTierMap;
		        	service.put('After_Rate_Code_Tier_Cap__c', service.get('Before_Rate_Code_Tier_Cap__c'));	       	
		        }
		        else
		        {
		        	afterMonthlyTierMap = getRateCodeTierCap(service, afterRateCode, 'After');
		        }

		        if(afterMonthlyTierMap.isEmpty()  && service.get('After_Rate_Code_Tier_Cap__c') != 'NA')
				{
					throw new customException('Error while getting After Monthly Tier Cap.');
				}

				if(solarRateCode == afterRateCode)     
		        {
		        	solarMonthlyTierMap = afterMonthlyTierMap;
		        	service.put('Solar_Rate_Code_Tier_Cap__c', service.get('After_Rate_Code_Tier_Cap__c'));	       	
		        }
		        else if (solarRateCode == beforeRateCode)
		        {
		        	afterMonthlyTierMap = beforeMonthlyTierMap;
		        	service.put('Solar_Rate_Code_Tier_Cap__c', service.get('Before_Rate_Code_Tier_Cap__c'));	       	
		        }
		        else 
		        {
		        	solarMonthlyTierMap = getRateCodeTierCap(service, solarRateCode, 'Solar');
		        }


		        /*********************************************************************/
		        // Get Before and After Tier N Consumption 
		        beforeMonthlyTierConsMap = getMonthlyTierConsuption(service, beforeRateCode, beforeMonthlyTierMap, 'Before');

		        if(beforeRateCode == afterRateCode)     
		        {
		        	afterMonthlyTierConsMap = beforeMonthlyTierConsMap;
		        	service.put('After_Tier_1_Consumption_kWh__c',service.get('Before_Tier_1_Consumption_kWh__c'));
			        service.put('After_Tier_2_Consumption_kWh__c',service.get('Before_Tier_2_Consumption_kWh__c'));
			        service.put('After_Tier_3_Consumption_kWh__c',service.get('Before_Tier_3_Consumption_kWh__c'));
			        service.put('After_Tier_4_Consumption_kWh__c',service.get('Before_Tier_4_Consumption_kWh__c'));
			        service.put('After_Tier_5_Consumption_kWh__c',service.get('Before_Tier_5_Consumption_kWh__c'));	       	
		        }
		        else
		        {
		        	afterMonthlyTierConsMap = getMonthlyTierConsuption(service, afterRateCode,afterMonthlyTierMap, 'After');
		        }

		        
		        /***********************************************************************************/
		        // Get Solar Tier N Production 

		        String solarT1Prod = '';
		        String solarT2Prod = '';
		        String solarT3Prod = '';
		        String solarT4Prod = '';
		        String solarT5Prod = '';

		        Map<String,Decimal> solarMonthlyTierProdMap = new Map<String,Decimal>();
		       
		        if(solarMonthlyTierMap.size() > 0 || service.get('Solar_Rate_Code_Tier_Cap__c') == 'NA')
		        {
		        	
		        	for(integer i=0;i <= 11; i=i+1 )
					{
						//double monthForecast = (Double) service.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c');
						double monthProduction = productionMonthMap.get(method+'_'+months[i]);
						//System.debug(months[i]+' monthForecast '+monthForecast);
						System.debug(months[i]+' monthProduction '+monthProduction);
						Decimal t1cap = 0;
						Decimal t2cap = 0;
						Decimal t3cap = 0;
						Decimal t4cap = 0;
						Decimal t5cap = 0;
						
						Boolean isContinue = true;
						//double sign = Math.abs(monthForecast - monthProduction) / (monthForecast - monthProduction);
						if(solarRateCode.Tier_1_Cap__c != null && solarMonthlyTierMap.size() > 0)
						{
							t1cap = solarMonthlyTierMap.get('T1-'+months[i]);
							//System.debug('T1-'+months[i]+' '+ Math.Round(cap));		
							//if(t1cap >= Math.abs(monthForecast - monthProduction))
							if(t1cap >= monthProduction)
							{
								solarT1Prod = solarT1Prod+String.valueOf(monthProduction) + ';';	
								solarMonthlyTierProdMap.put('T1-'+months[i],monthProduction);
								isContinue = false;								
							}				
							else
							{							
								solarT1Prod = solarT1Prod+String.valueOf(t1cap) + ';';	
								solarMonthlyTierProdMap.put('T1-'+months[i],t1cap);								
							}
							System.debug(months[i]+' solarT1Prod '+solarT1Prod);							
						}
						else
						{
							solarT1Prod = solarT1Prod+String.valueOf(monthProduction) + ';';	
							solarMonthlyTierProdMap.put('T1-'+months[i],monthProduction);															
							isContinue = false;
						}

						if(solarRateCode.Tier_2_Cap__c != null)
						{
							if(isContinue)
							{
								t2cap = solarMonthlyTierMap.get('T2-'+months[i]);								
								if(t2cap >=  monthProduction)
								{
									solarT2Prod = solarT2Prod+String.valueOf(monthProduction - t1cap) + ';';	
									solarMonthlyTierProdMap.put('T2-'+months[i],monthProduction - t1cap);
									isContinue = false;									
								}				
								else
								{							
									solarT2Prod = solarT2Prod+String.valueOf((t2cap-t1cap)) + ';';	
									solarMonthlyTierProdMap.put('T2-'+months[i],(t2cap-t1cap));									
								}
								System.debug(months[i]+' solarT2Prod '+solarT2Prod);
							}
							else
							{
								solarT2Prod = solarT2Prod+String.valueOf(0) + ';';	
								solarMonthlyTierProdMap.put('T2-'+months[i],0);	
							}
						}
						else
						{
							if(isContinue)
							{
								solarT2Prod = solarT2Prod+String.valueOf(monthProduction - t1cap) + ';';	
								solarMonthlyTierProdMap.put('T2-'+months[i],monthProduction - t1cap);
							}
							else
							{
								solarT2Prod = solarT2Prod+String.valueOf(0) + ';';	
								solarMonthlyTierProdMap.put('T2-'+months[i],0);	
							}	
							isContinue = false;

						}

						if(solarRateCode.Tier_3_Cap__c != null )
						{
							if(isContinue)
							{
								t3cap = solarMonthlyTierMap.get('T3-'+months[i]);								
								if(t3cap >= monthProduction)
								{
									solarT3Prod = solarT3Prod+String.valueOf(monthProduction -t2cap) + ';';	
									solarMonthlyTierProdMap.put('T3-'+months[i],monthProduction -t2cap);
									isContinue = false;									
								}				
								else
								{							
									solarT3Prod = solarT3Prod+String.valueOf((t3cap-t2cap)) + ';';	
									solarMonthlyTierProdMap.put('T3-'+months[i],(t3cap-t2cap));									
								}
								System.debug(months[i]+' solarT3Prod '+solarT3Prod);
							}
							else
							{
								solarT3Prod = solarT3Prod+String.valueOf(0) + ';';	
								solarMonthlyTierProdMap.put('T3-'+months[i],0);	
							}
						}
						else
						{
							if(isContinue)
							{
								solarT3Prod = solarT3Prod+String.valueOf(monthProduction - t2cap) + ';';	
								solarMonthlyTierProdMap.put('T3-'+months[i], monthProduction - t2cap);	
							}
							else
							{
								solarT3Prod = solarT3Prod+String.valueOf(0) + ';';	
								solarMonthlyTierProdMap.put('T3-'+months[i],0);	
							}	
							isContinue = false;

						}

						if(solarRateCode.Tier_4_Cap__c != null )
						{
							if(isContinue)
							{
								t4cap = afterMonthlyTierMap.get('T4-'+months[i]);								
								if(t4cap >= monthProduction)
								{
									solarT4Prod = solarT4Prod+String.valueOf(monthProduction -t3cap) + ';';
									solarMonthlyTierProdMap.put('T4-'+months[i], monthProduction -t3cap);	
									isContinue = false;
									
								}				
								else
								{							
									solarT4Prod = solarT4Prod+String.valueOf( (t4cap-t3cap)) + ';';	
									solarMonthlyTierProdMap.put('T4-'+months[i],(t4cap-t3cap));
									
								}
								System.debug(months[i]+' solarT4Prod '+solarT4Prod);
							}
							else
							{
								solarT4Prod = solarT4Prod+String.valueOf(0) + ';';	
								solarMonthlyTierProdMap.put('T4-'+months[i],0);	
							}
						}
						else
						{
							if(isContinue)
							{
								solarT4Prod = solarT4Prod+String.valueOf( monthProduction - t3cap) + ';';	
								solarMonthlyTierProdMap.put('T4-'+months[i], monthProduction - t3cap);								
								
							}
							else
							{
								solarT4Prod = solarT4Prod+String.valueOf(0) + ';';	
								solarMonthlyTierProdMap.put('T4-'+months[i],0);	
							}	
							isContinue = false;

						}

						if(solarRateCode.Tier_5_Cap__c != null )
						{
							if(isContinue)
							{
								t5cap = afterMonthlyTierMap.get('T5-'+months[i]);									
								if(t5cap >= Math.abs(monthProduction))
								{
									solarT5Prod = solarT5Prod+String.valueOf( monthProduction -t4cap) + ';';
									solarMonthlyTierProdMap.put('T5-'+months[i], monthProduction -t4cap);	
									isContinue = false;									
								}				
								else
								{							
									solarT5Prod = solarT5Prod+String.valueOf( (t5cap-t4cap)) + ';';	
									solarMonthlyTierProdMap.put('T5-'+months[i], (t5cap-t4cap));									
								}
								System.debug(months[i]+' solarT5Prod '+solarT5Prod);
							}
							else
							{
								solarT5Prod = solarT5Prod+String.valueOf(0) + ';';	
								solarMonthlyTierProdMap.put('T5-'+months[i],0);	
							}
						}
						else
						{
							if(isContinue)
							{
								solarT5Prod = solarT5Prod+String.valueOf( monthProduction - t4cap) + ';';	
								solarMonthlyTierProdMap.put('T5-'+months[i], monthProduction - t4cap);	
							}
							else
							{
								solarT5Prod = solarT5Prod+String.valueOf(0) + ';';	
								solarMonthlyTierProdMap.put('T5-'+months[i],0);	
							}	
							isContinue = false;

						}
					}

		        }
		        service.put('Solar_'+method+'_Tier_1_Production_kWh__c',solarT1Prod);
		        service.put('Solar_'+method+'_Tier_2_Production_kWh__c',solarT2Prod);
		        service.put('Solar_'+method+'_Tier_3_Production_kWh__c',solarT3Prod);
		        service.put('Solar_'+method+'_Tier_4_Production_kWh__c',solarT4Prod);
		        service.put('Solar_'+method+'_Tier_5_Production_kWh__c',solarT5Prod);


		        /*************************************************************************************************/
		        // Get Before/After Rate Period Percentage Consumption
		        
		        Map<String,Double> monthWeekdayRatioMap = PVWatts_ServiceClient.getMonthWeekdayRatio();

		        Map<String,Decimal> beforeRatePeriodPercentageMap = getRatePeriodPercentageMap(service,beforeRateCode,monthWeekdayRatioMap,'Before');

		        if(beforeRatePeriodPercentageMap.isEmpty())
				{
					throw new customException('Error while getting Before Rate Period Pecentage.');
				}

		        Map<String,Decimal> afterRatePeriodPercentageMap;
		        if(beforeRateCode == afterRateCode)     
		        {
		        	afterRatePeriodPercentageMap = beforeRatePeriodPercentageMap;	
		        	service.put('After_Rate_Period_Percent_Consumption__c', service.get('Before_Rate_Period_Percent_Consumption__c'));
		        }
		        else
		        {
		        	afterRatePeriodPercentageMap = getRatePeriodPercentageMap(service,afterRateCode,monthWeekdayRatioMap,'After');
		        }

		        if(afterRatePeriodPercentageMap.isEmpty())
				{
					throw new customException('Error while getting After Rate Period Pecentage.');
				}
		        System.debug('afterRatePeriodPercentageMap '+ afterRatePeriodPercentageMap.size());

		        /********************************************************************************************************/

		        /*************************************************************************************************/
		        // Get Before/After Rate Period Consumption

		        Map<String,Decimal> beforeRatePeriodConsMap = getRatePeriodConsumptionMap(service,beforeRateCode,beforeRatePeriodPercentageMap,'Before');

		        if(beforeRatePeriodConsMap.isEmpty())
				{
					throw new customException('Error while getting Before Rate Period Consumption.');
				}

		        Map<String,Decimal> afterRatePeriodConsMap;
		        if(beforeRateCode == afterRateCode)     
		        {
		        	afterRatePeriodConsMap = beforeRatePeriodConsMap;	
		        	service.put('After_Rate_Period_Consumption__c', service.get('Before_Rate_Period_Consumption__c'));
		        }
		        else
		        {
		        	afterRatePeriodConsMap = getRatePeriodConsumptionMap(service,afterRateCode,afterRatePeriodPercentageMap,'After');
		        }

		        if(afterRatePeriodConsMap.isEmpty())
				{
					throw new customException('Error while getting After Rate Period Consumption.');
				}
		        System.debug('afterRatePeriodConsMap '+ afterRatePeriodConsMap.size());

		        /********************************************************************************************************/
		        /********************************************************************************************************/
		        // Get Solar Rate Period Production and Percentage
		        Map<String,double> solarRatePeriodProdMap = utilityProductionMap.get(service.id);
		        Map<String,Decimal> solarRatePeriodPercentageMap = new Map<String,Decimal>();
		        //String fieldName = '';
		        //String monthFieldName = '';

		        String p1Prod = '';
		        String p2Prod = '';
		        String p3Prod = '';
		        String p4Prod = '';
		        String p5Prod = '';

		        String p1Percentage = '';
		        String p2Percentage = '';
		        String p3Percentage = '';
		        String p4Percentage = '';
		        String p5Percentage = '';

		        Decimal periodProd = 0;
		        Decimal periodPercent = 0;
		        Decimal totalProd = 0;

		        for(Rate_Period__c rp : periods)
				{					
					for(integer i=0;i <= 11; i=i+1 )
        			{
						fieldName = 'P'+rp.Rate_Period__c+'-'+months[i];
						monthFieldName = method +'_'+months[i];

						periodProd = solarRatePeriodProdMap.get(fieldName);						
						totalProd = productionMonthMap.get(monthFieldName);

						System.debug(fieldName+' periodProd '+periodProd + ' totalProd ' + totalProd);
						periodPercent = (periodProd/totalProd) * 100;
						periodPercent = periodPercent.setScale(2);
						solarRatePeriodPercentageMap.put(fieldName,periodPercent);

						if(rp.Rate_Period__c == 1)
				    	{
					    	p1Prod = p1Prod + String.valueOf(periodProd) + ';';	
					    	p1Percentage = p1Percentage + String.valueOf(periodPercent) + ';';						    	
				    	}
				    	if(rp.Rate_Period__c == 2)
				    	{
					    	p2Prod = p2Prod + String.valueOf(periodProd) + ';';	
					    	p2Percentage = p2Percentage + String.valueOf(periodPercent) + ';';					    	
				    	}
				    	if(rp.Rate_Period__c == 3)
				    	{
					    	p3Prod = p3Prod + String.valueOf(periodProd) + ';';	
					    	p3Percentage = p3Percentage + String.valueOf(periodPercent) + ';';					    	
				    	}
				    	if(rp.Rate_Period__c == 4)
				    	{
					    	p4Prod = p4Prod + String.valueOf(periodProd) + ';';	
					    	p4Percentage = p4Percentage + String.valueOf(periodPercent) + ';';					    	
				    	}
				    	if(rp.Rate_Period__c == 5)
				    	{
					    	p5Prod = p5Prod + String.valueOf(periodProd) + ';';	
					    	p5Percentage = p5Percentage + String.valueOf(periodPercent) + ';';					    	
				    	}
						
					}
										
				}
		        
		        service.put('Solar_'+method+'_Rate_Period_Production__c','P1:'+p1Prod+'\n'+'P2:'+p2Prod+'\n'+'P3:'+p3Prod+'\n'+'P4:'+p4Prod+'\n'+'P5:'+p5Prod);
		        service.put('Solar_'+method+'_Rate_Period_Percent_Prod__c','P1:'+p1Percentage+'\n'+'P2:'+p2Percentage+'\n'+'P3:'+p3Percentage+'\n'+'P4:'+p4Percentage+'\n'+'P5:'+p5Percentage);


		        /********************************************************************************************************/ 
		        /********************************************************************************************************/
		        // Get Before/After Tier N Cost

		        Map<String,Double> beforeMonthlyTierCostMap = getRateCodeTierCost(service,beforeRateCode,beforeMonthlyTierConsMap,beforeRatePeriodPercentageMap,'Before', '' );
		        if(beforeMonthlyTierCostMap.isEmpty())
				{
					throw new customException('Error while getting Before Monthly Tier Cost.');
				}

				Map<String,Double> afterMonthlyTierCostMap;

				if(beforeRateCode == afterRateCode)     
		        {
		        	afterMonthlyTierCostMap = beforeMonthlyTierCostMap;	
		        	service.put('After_Tier_1_Cost__c',service.get('Before_Tier_1_Cost__c'));
			        service.put('After_Tier_2_Cost__c',service.get('Before_Tier_2_Cost__c'));
			        service.put('After_Tier_3_Cost__c',service.get('Before_Tier_3_Cost__c'));
			        service.put('After_Tier_4_Cost__c',service.get('Before_Tier_4_Cost__c'));
			        service.put('After_Tier_5_Cost__c',service.get('Before_Tier_5_Cost__c'));
		        	
		        }
		        else
		        {
		        	afterMonthlyTierCostMap = getRateCodeTierCost(service,afterRateCode,afterMonthlyTierConsMap,afterRatePeriodPercentageMap,'After', '');
		        }

		        if(afterMonthlyTierCostMap.isEmpty())
				{
					throw new customException('Error while getting After Monthly Tier Cost.');
				}

				/********************************************************************************************************/
		        // Get Solar Tier N Value
		        Map<String,Double> solarMonthlyTierValueMap = getRateCodeTierCost(service,solarRateCode,solarMonthlyTierProdMap,solarRatePeriodPercentageMap,'Solar', '_'+method );


		        /********************************************************************************************************/  
		        // Get Before/After Fixed Cost

		        Map<String,Double> beforeMonthlyFixedCostMap = getFixedCosts(service,beforeRateCode,'Before', '' );

		        Map<String,Double> afterMonthlyFixedCostMap;

		        if(beforeRateCode == afterRateCode)     
		        {
		        	afterMonthlyFixedCostMap = beforeMonthlyFixedCostMap;	
		        	service.put('After_Fixed_Costs__c',service.get('Before_Fixed_Costs__c'));		        	
		        }
		        else
		        {
		        	afterMonthlyFixedCostMap = getFixedCosts(service,afterRateCode,'After', '' );
		        }
		       
		        /********************************************************************************************************/  
		        // Get Before/After Total Bill 
		        
		        Map<String,double> beforeMonthlyTotalBillMap = getTotalBill(service , beforeRateCode , beforeMonthlyTierCostMap, beforeMonthlyFixedCostMap, null, 'Before');

		        Map<String,double> afterMonthlyTotalBillMap;

		        if(beforeRateCode == afterRateCode)     
		        {
		        	afterMonthlyTotalBillMap = beforeMonthlyTotalBillMap;			        	
		        	service.put('After_Total_Bill__c',service.get('Before_Total_Bill__c'));		        	
		        }
		        else
		        {
		        	afterMonthlyTotalBillMap = getTotalBill(service , afterRateCode , afterMonthlyTierCostMap, afterMonthlyFixedCostMap, null, 'After');
		        }

		        /********************************************************************************************************/  
		        // Get Net Tier N Consumption
				//If{After Tier N Cap >= ABS(Total Forecasted Consumption Month M – Method D Month M kWh), (ABS(Total Forecasted Consumption Month M – Method D Month M kWh) – After Tier N-1 Cap) 
					//* ABS(Total Forecasted Consumption Month M – Method D Month M kWh)/(Total Forecasted Consumption Month M – Method D Month M kWh)
				//, (After Tier N Cap – After Tier N-1 Cap) * ABS(Total Forecasted Consumption Month M – Method D Month M kWh)/(Total Forecasted Consumption Month M – Method D Month M kWh)}

				String netT1Cons = '';
				String netT2Cons = '';
				String netT3Cons = '';
				String netT4Cons = '';
				String netT5Cons = '';

				Map<String,Decimal> netMonthlyTierConsMap = new Map<String,Decimal>();
				Map<String,Decimal> netMonthlyConsMap = new Map<String,Decimal>();


				if(afterMonthlyTierMap.size() > 0 || service.get('After_Rate_Code_Tier_Cap__c') == 'NA')
				{
					Double[] billableConsumptionMonths = new Double[]{};
					for (String str : billableConsumption.split(';', 0)){		//Loop over values of service.get(method + '_Billable_Consumption__c')
				    	billableConsumptionMonths.add(Double.valueOf(str));
				    }

					for(integer i=0;i <= 11; i=i+1 )
						{
							double monthForecast = (Double) service.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c');
							double monthProduction = productionMonthMap.get(method+'_'+months[i]);
							//System.debug(months[i]+' monthForecast '+monthForecast);
							//System.debug(months[i]+' monthProduction '+monthProduction);
							Double netProdConsumption = monthForecast - monthProduction;
							if (solarRateCode.Over_Production_Credit__c == 'kWH')
								netProdConsumption = billableConsumptionMonths[i];
							Decimal t1cap = 0;
							Decimal t2cap = 0;
							Decimal t3cap = 0;
							Decimal t4cap = 0;
							Decimal t5cap = 0;

							Decimal t1Cons = 0;
							Decimal t2Cons = 0;
							Decimal t3Cons = 0;
							Decimal t4Cons = 0;
							Decimal t5Cons = 0;


							double totalMonthConsumption = 0;
							Boolean isContinue = true;
                            //double sign = 1;	//default value in case of "divide by zero" situation
                            //if (netProdConsumption != 0)
							//	sign = netProdConsumption / netProdConsumption;
							Double sign = netProdConsumption >= 0 ? 1 : -1;
							if(afterRateCode.Tier_1_Cap__c != null && afterMonthlyTierMap.size() > 0)
							{
								t1cap = afterMonthlyTierMap.get('T1-'+months[i]);
								//System.debug('T1-'+months[i]+' '+ Math.Round(cap));		
								if(t1cap >= Math.abs(netProdConsumption))
								{
									t1Cons = Decimal.valueOf(netProdConsumption).setScale(3);
									
									//netMonthlyTierConsMap.put('T1-'+months[i],t1Cons);
									isContinue = false;
									//totalMonthConsumption = totalMonthConsumption +  (monthForecast - monthProduction);

								}				
								else
								{							
									//netT1Cons = netT1Cons+String.valueOf(sign * t1cap) + ';';	
									t1Cons = (sign * t1cap).setScale(3);
									
									//totalMonthConsumption = totalMonthConsumption + (sign * t1cap);
								}
								totalMonthConsumption = totalMonthConsumption + t1Cons;
								netT1Cons = netT1Cons+String.valueOf(t1Cons) + ';';	
								netMonthlyTierConsMap.put('T1-'+months[i],t1Cons);
								System.debug(months[i]+' netT1Cons '+netT1Cons);							
							}
							else
							{
								t1Cons = Decimal.valueOf(netProdConsumption).setScale(3);
								netT1Cons = netT1Cons+String.valueOf(t1Cons) + ';';	
								netMonthlyTierConsMap.put('T1-'+months[i],t1Cons);
								//netT1Cons = netT1Cons+String.valueOf(monthForecast - monthProduction) + ';';	
								//netMonthlyTierConsMap.put('T1-'+months[i],monthForecast - monthProduction);								
								totalMonthConsumption = totalMonthConsumption + t1Cons;														
								isContinue = false;
							}

							if(afterRateCode.Tier_2_Cap__c != null)
							{
								if(isContinue)
								{
									t2cap = afterMonthlyTierMap.get('T2-'+months[i]);
									//System.debug('T1-'+months[i]+' '+ Math.Round(cap));		
									if(t2cap >=  Math.abs(netProdConsumption))
									{
										//netT2Cons = netT2Cons+String.valueOf(monthForecast - monthProduction - t1cap) + ';';	
										 //CPQ-573
										if(netProdConsumption <= 0)
										{
											t2Cons = (netProdConsumption + t1cap).setScale(3);	
										}
										else
										{
											t2Cons = (netProdConsumption - t1cap).setScale(3);	
										}
										

										//netMonthlyTierConsMap.put('T2-'+months[i],monthForecast - monthProduction - t1cap);
										isContinue = false;
										//totalMonthConsumption = totalMonthConsumption + t2Cons;
									}				
									else
									{							
										//netT2Cons = netT2Cons+String.valueOf(sign * (t2cap-t1cap)) + ';';	
										t2Cons = (sign * (t2cap-t1cap)).setScale(3);
										//netMonthlyTierConsMap.put('T2-'+months[i],sign * (t2cap-t1cap));
										//totalMonthConsumption = totalMonthConsumption + (sign * (t2cap-t1cap));
									}

									netT2Cons = netT2Cons+String.valueOf(t2Cons) + ';';	
								    netMonthlyTierConsMap.put('T2-'+months[i],t2Cons);
								    totalMonthConsumption = totalMonthConsumption + t2Cons;
									System.debug(months[i]+' netT2Cons '+netT2Cons);
								}
								else
								{
									netT2Cons = netT2Cons+String.valueOf(0) + ';';	
									netMonthlyTierConsMap.put('T2-'+months[i],0);	
								}
							}
							else
							{
								if(isContinue)
								{
									//CPQ-573
									if(netProdConsumption <= 0)
									{
										t2Cons = (netProdConsumption + t1cap).setScale(3);	
									}
									else
									{
										t2Cons = (netProdConsumption - t1cap).setScale(3);	
									}

									netT2Cons = netT2Cons+String.valueOf(t2Cons) + ';';	
								    netMonthlyTierConsMap.put('T2-'+months[i],t2Cons);
									//netT2Cons = netT2Cons+String.valueOf(monthForecast - monthProduction - t1cap) + ';';	
									//netMonthlyTierConsMap.put('T2-'+months[i],monthForecast - monthProduction - t1cap);								
									totalMonthConsumption = totalMonthConsumption + t2Cons;
								}
								else
								{
									netT2Cons = netT2Cons+String.valueOf(0) + ';';	
									netMonthlyTierConsMap.put('T2-'+months[i],0);	
								}	
								isContinue = false;

							}

							if(afterRateCode.Tier_3_Cap__c != null )
							{
								if(isContinue)
								{
									t3cap = afterMonthlyTierMap.get('T3-'+months[i]);
									//System.debug('T1-'+months[i]+' '+ Math.Round(cap));		
									if(t3cap >= Math.abs(netProdConsumption))
									{
										//CPQ-573
										if(netProdConsumption <= 0)
										{
											t3Cons = (netProdConsumption + t2cap).setScale(3);	
										}
										else
										{
											t3Cons = (netProdConsumption - t2cap).setScale(3);	
										}

										//netT3Cons = netT3Cons+String.valueOf(monthForecast - monthProduction -t2cap) + ';';	
										//netMonthlyTierConsMap.put('T3-'+months[i],monthForecast - monthProduction -t2cap);
										isContinue = false;
										//totalMonthConsumption = totalMonthConsumption + t3Cons;
									}				
									else
									{							
										t3Cons = (sign * (t3cap-t2cap)).setScale(3);
										//netT3Cons = netT3Cons+String.valueOf(sign * (t3cap-t2cap)) + ';';	
										//netMonthlyTierConsMap.put('T3-'+months[i],sign * (t3cap-t2cap));
										//totalMonthConsumption = totalMonthConsumption + (sign * (t3cap-t2cap));
									}

									netT3Cons = netT3Cons+String.valueOf(t3Cons) + ';';	
								    netMonthlyTierConsMap.put('T3-'+months[i],t3Cons);
								    totalMonthConsumption = totalMonthConsumption + t3Cons;
									System.debug(months[i]+' netT3Cons '+netT3Cons);
								}
								else
								{
									netT3Cons = netT3Cons+String.valueOf(0) + ';';	
									netMonthlyTierConsMap.put('T3-'+months[i],0);	
								}
							}
							else
							{
								if(isContinue)
								{
									//CPQ-573
									if(netProdConsumption <= 0)
									{
										t3Cons = (netProdConsumption + t2cap).setScale(3);	
									}
									else
									{
										t3Cons = (netProdConsumption - t2cap).setScale(3);	
									}

									netT3Cons = netT3Cons+String.valueOf(t3Cons) + ';';	
								    netMonthlyTierConsMap.put('T3-'+months[i],t3Cons);

									//netT3Cons = netT3Cons+String.valueOf(monthForecast - monthProduction - t2cap) + ';';	
									//netMonthlyTierConsMap.put('T3-'+months[i],monthForecast - monthProduction - t2cap);								
									totalMonthConsumption = totalMonthConsumption + t3Cons;
								}
								else
								{
									netT3Cons = netT3Cons+String.valueOf(0) + ';';	
									netMonthlyTierConsMap.put('T3-'+months[i],0);	
								}	
								isContinue = false;

							}

							if(afterRateCode.Tier_4_Cap__c != null )
							{
								if(isContinue)
								{
									t4cap = afterMonthlyTierMap.get('T4-'+months[i]);
									//System.debug('T1-'+months[i]+' '+ Math.Round(cap));		
									if(t4cap >= Math.abs(netProdConsumption))
									{
										//netT4Cons = netT4Cons+String.valueOf(monthForecast - monthProduction -t3cap) + ';';
										//CPQ-573
										if(netProdConsumption <= 0)
										{
											t4Cons = (netProdConsumption + t3cap).setScale(3);	
										}
										else
										{
											t4Cons = (netProdConsumption - t3cap).setScale(3);	
										}

										//netMonthlyTierConsMap.put('T4-'+months[i],monthForecast - monthProduction -t3cap);	
										isContinue = false;
										//totalMonthConsumption = totalMonthConsumption + t4Cons;
									}				
									else
									{							
										//netT4Cons = netT4Cons+String.valueOf(sign * (t4cap-t3cap)) + ';';	
										t4Cons = (sign * (t4cap-t3cap)).setScale(3);
										//netMonthlyTierConsMap.put('T4-'+months[i],sign * (t4cap-t3cap));
										//totalMonthConsumption = totalMonthConsumption + (sign * (t4cap-t3cap));
									}

									netT4Cons = netT4Cons+String.valueOf(t4Cons) + ';';	
								    netMonthlyTierConsMap.put('T4-'+months[i],t4Cons);
								    totalMonthConsumption = totalMonthConsumption + t4Cons;
									System.debug(months[i]+' netT4Cons '+netT4Cons);
								}
								else
								{
									netT4Cons = netT4Cons+String.valueOf(0) + ';';	
									netMonthlyTierConsMap.put('T4-'+months[i],0);	
								}
							}
							else
							{
								if(isContinue)
								{
									//netT4Cons = netT4Cons+String.valueOf(monthForecast - monthProduction - t3cap) + ';';	
									if(netProdConsumption <= 0)
									{
										t4Cons = (netProdConsumption + t3cap).setScale(3);	
									}
									else
									{
										t4Cons = (netProdConsumption - t3cap).setScale(3);	
									}

									netT4Cons = netT4Cons+String.valueOf(t4Cons) + ';';	
								    netMonthlyTierConsMap.put('T4-'+months[i],t4Cons);
							
									totalMonthConsumption = totalMonthConsumption + t4Cons;
								}
								else
								{
									netT4Cons = netT4Cons+String.valueOf(0) + ';';	
									netMonthlyTierConsMap.put('T4-'+months[i],0);	
								}	
								isContinue = false;

							}

							if(afterRateCode.Tier_5_Cap__c != null )
							{
								if(isContinue)
								{
									t5cap = afterMonthlyTierMap.get('T5-'+months[i]);
									//System.debug('T1-'+months[i]+' '+ Math.Round(cap));		
									if(t5cap >= Math.abs(netProdConsumption))
									{
										//netT5Cons = netT5Cons+String.valueOf(monthForecast - monthProduction -t4cap) + ';';
										if(netProdConsumption <= 0)
										{
											t5Cons = (netProdConsumption + t4cap).setScale(3);	
										}
										else
										{
											t5Cons = (netProdConsumption - t4cap).setScale(3);	
										}

										//netMonthlyTierConsMap.put('T5-'+months[i],monthForecast - monthProduction -t4cap);	
										isContinue = false;
										//totalMonthConsumption = totalMonthConsumption + t5Cons;
									}				
									else
									{							
										t5Cons = (sign * (t5cap-t4cap)).setScale(3);
										//netMonthlyTierConsMap.put('T5-'+months[i],sign * (t5cap-t4cap));
										//totalMonthConsumption = totalMonthConsumption + (sign * (t5cap-t4cap));
									}

									netT5Cons = netT5Cons+String.valueOf(t5Cons) + ';';	
								    netMonthlyTierConsMap.put('T5-'+months[i],t5Cons);
								    totalMonthConsumption = totalMonthConsumption + t5Cons;

									System.debug(months[i]+' netT5Cons '+netT5Cons);
								}
								else
								{
									netT5Cons = netT5Cons+String.valueOf(0) + ';';	
									netMonthlyTierConsMap.put('T5-'+months[i],0);	
								}
							}
							else
							{
								if(isContinue)
								{
									//netT5Cons = netT5Cons+String.valueOf(monthForecast - monthProduction - t4cap) + ';';	
									if(netProdConsumption <= 0)
									{
										t5Cons = (netProdConsumption + t4cap).setScale(3);	
									}
									else
									{
										t5Cons = (netProdConsumption - t4cap).setScale(3);	
									}

									netMonthlyTierConsMap.put('T5-'+months[i], netProdConsumption - t4cap);								
									totalMonthConsumption = totalMonthConsumption + t5Cons;
								}
								else
								{
									netT5Cons = netT5Cons+String.valueOf(0) + ';';	
									netMonthlyTierConsMap.put('T5-'+months[i],0);	
								}	
								isContinue = false;

							}

							netMonthlyConsMap.put(months[i],totalMonthConsumption);
						}

				}
				service.put('Net_'+method+'_Tier_Consumption__c','T1:'+netT1Cons+'\n'+'T2:'+netT2Cons+'\n'+'T3:'+netT3Cons+'\n'+'T4:'+netT4Cons+'\n'+'T5:'+netT5Cons);				


				/********************************************************************************************************/  
		        // Get Net Method D Rate Period Consumption
		        // After Rate Period ConsumptionP – Solar Method D Rate Period ProductionP
		        Map<String,Decimal> netRatePeriodConsMap = new Map<String,Decimal>();
		        String periodName = '';
		        String netP1Cons = '';
				String netP2Cons = '';
				String netP3Cons = '';
				String netP4Cons = '';
				String netP5Cons = '';
				Decimal netCons = 0;
		        if(afterRatePeriodConsMap != null && solarRatePeriodProdMap != null)
		        for(Rate_Period__c rp : periods)
				{					
					for(integer i=0;i <= 11; i=i+1 )
        			{
        				periodName = 'P'+rp.Rate_Period__c+'-'+months[i];
        				netCons = 0;
        				if(afterRatePeriodConsMap.get(periodName) != null && solarRatePeriodProdMap.get(periodName) != null)
						{
							double monthForecast = (Double) service.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c');
							double monthProduction = productionMonthMap.get(method+'_'+months[i]);
							
							if(monthForecast < monthProduction)	
							{
								Decimal percentCons = solarRatePeriodPercentageMap.get(periodName);

								netCons = (monthForecast - monthProduction) * (percentCons/ 100); 	
							}
							else
							{
								netCons = afterRatePeriodConsMap.get(periodName) - solarRatePeriodProdMap.get(periodName) ;							
							}

							netCons = netCons.setScale(3);
							netRatePeriodConsMap.put(periodName , netCons );	
							
							if(rp.Rate_Period__c == 1)
					    	{
						    	netP1Cons = netP1Cons + String.valueOf(netCons) + ';';							    	
					    	}
					    	if(rp.Rate_Period__c == 2)
					    	{
						    	netP2Cons = netP2Cons + String.valueOf(netCons) + ';';							    	
					    	}
					    	if(rp.Rate_Period__c == 3)
					    	{
						    	netP3Cons = netP3Cons + String.valueOf(netCons) + ';';							    	
					    	}
					    	if(rp.Rate_Period__c == 4)
					    	{
						    	netP4Cons = netP4Cons + String.valueOf(netCons) + ';';							    	
					    	}
					    	if(rp.Rate_Period__c == 5)
					    	{
						    	netP5Cons = netP5Cons + String.valueOf(netCons) + ';';							    	
					    	}
						}
        			}
        		}

        		service.put('Net_'+method+'_Rate_Period_Consumption__c','P1:'+netP1Cons+'\n'+'P2:'+netP2Cons+'\n'+'P3:'+netP3Cons+'\n'+'P4:'+netP4Cons+'\n'+'P5:'+netP5Cons);				


        		/********************************************************************************************************/  
		        // Get Net Tier N Cost
		        // If Utility.Solar Compensation Method = ‘VOST’ {After Tier N Cost – Solar Tier N Value}
		        // If Utility.Solar Compensation Method = ‘Net Metering’ 
		        //		Sum(1-P){sum(1-N)(After Tier N RateP * Net Method D Rate Period Consumption * (Net Tier N Consumption/(Total Forecasted Consumption – Method D Estimated Output)))}

		        Map<String,Decimal> netMonthlyTierCostMap = new Map<String,Decimal>();
		        Map<String,Decimal> netMonthlyCostMap = new Map<String,Decimal>();

		        String tierName = '';
		        String netT1Cost = '';
				String netT2Cost = '';
				String netT3Cost = '';
				String netT4Cost = '';
				String netT5Cost = '';
				Decimal netCost = 0;
				Decimal netTotalCost = 0;
				System.debug('Solar_Compensation_Method__c '+service.Utility_Company_Master__r.Solar_Compensation_Method__c);
		        if(service.Utility_Company_Master__r.Solar_Compensation_Method__c == 'VOST')
		        {
		        	if(afterMonthlyTierCostMap !=null && solarMonthlyTierValueMap != null)
		        	{
				        for(integer i=0;i <= 11; i=i+1 )
						{					
							netTotalCost = 0;
							for(integer t=1;t <= 5; t=t+1 )
		        			{
		        				tierName = 'T'+t+'-'+months[i];
		        				netCost = 0;
		        				System.debug(tierName+ ' afterMonthlyTier ' + afterMonthlyTierCostMap.get(tierName) + ' solarMonthlyTier  ' + solarMonthlyTierValueMap.get(tierName) );
		        				if(afterMonthlyTierCostMap.get(tierName) != null && solarMonthlyTierValueMap.get(tierName) != null)
								{
									netCost = afterMonthlyTierCostMap.get(tierName) - solarMonthlyTierValueMap.get(tierName) ;		
									netCost = netCost.setScale(2);		
									netTotalCost = netTotalCost + 	netCost;				
									netMonthlyTierCostMap.put(tierName , netCost );	
									
									if(t == 1)
							    	{
								    	netT1Cost = netT1Cost + String.valueOf(netCost) + ';';	
								    				    	
							    	}
							    	if(t == 2)
							    	{
								    	netT2Cost = netT2Cost + String.valueOf(netCost) + ';';								    							    	
							    	}
							    	if(t == 3)
							    	{
								    	netT3Cost = netT3Cost + String.valueOf(netCost) + ';';								    							    	
							    	}
							    	if(t == 4)
							    	{
								    	netT4Cost = netT4Cost + String.valueOf(netCost) + ';';								    								    	
							    	}
							    	if(t == 5)
							    	{
								    	netT5Cost = netT5Cost + String.valueOf(netCost) + ';';								    							    	
							    	}
								}							
		        			}
		        			netMonthlyCostMap.put(months[i],netTotalCost);
		        		}
		        	}
		        }
		        else // Net Metering 
		        {
		        	System.debug('Net Metering Calc ');
		        	if(netRatePeriodConsMap !=null && netMonthlyTierConsMap != null)
		        	{
				        for(integer i=0;i <= 11; i=i+1 )
						{					
							
	        				Decimal t1Consumtion  = netMonthlyTierConsMap.get('T1-'+months[i]);
							Decimal t2Consumtion  = netMonthlyTierConsMap.get('T2-'+months[i]);
							Decimal t3Consumtion  = netMonthlyTierConsMap.get('T3-'+months[i]);
							Decimal t4Consumtion  = netMonthlyTierConsMap.get('T4-'+months[i]);
							Decimal t5Consumtion  = netMonthlyTierConsMap.get('T5-'+months[i]);

							double monthForecast = (Double) service.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c');
							double monthProduction = productionMonthMap.get(method+'_'+months[i]);
							
							System.debug('t1Consumtion '+t1Consumtion + ' t2Consumtion' +t2Consumtion+ ' t3Consumtion' +t3Consumtion+ ' t4Consumtion' +t4Consumtion+ ' t5Consumtion' +t5Consumtion);
							System.debug('monthForecast ' + monthForecast + ' monthProduction ' + monthProduction );
							netTotalCost = 0;
							Decimal t1cost = 0;
							Decimal t2cost = 0;
							Decimal t3cost = 0;
							Decimal t4cost = 0;
							Decimal t5cost = 0;
	        				for(Rate_Period__c rp : afterRateCode.Rate_Period__r )
    						{
    							Decimal periodConsuption = netRatePeriodConsMap.get('P'+rp.Rate_Period__c+'-'+months[i]);     							
								System.debug('periodConsuption ' + periodConsuption + ' rp.Tier_1_Rate_kWh__c '+rp.Tier_1_Rate_kWh__c );
					        	if(rp.Tier_1_Rate_kWh__c != null && t1Consumtion != null && monthForecast != null  && monthProduction != null && periodConsuption != null )
								{
									t1cost = t1cost + (periodConsuption * rp.Tier_1_Rate_kWh__c * (t1Consumtion / (monthForecast-monthProduction)) );
									System.debug(months[i] + ' Rate ' +rp.Rate_Period__c + ' t1cost ' + t1cost );
									t1cost = t1cost.setScale(2);
									System.debug(months[i]+' t1cost '+t1cost);
									
									if(netMonthlyTierCostMap.get('T1-'+months[i]) != null)
									{
										netMonthlyTierCostMap.put('T1-'+months[i] , netMonthlyTierCostMap.get('T1-'+months[i])  + t1cost);
									}	
									else
									{
										netMonthlyTierCostMap.put('T1-'+months[i], t1cost );
									}	
								}

								if(rp.Tier_2_Rate_kWh__c != null && t2Consumtion != null && monthForecast != null  && monthProduction != null && periodConsuption != null )
								{
									t2cost = t2cost + (periodConsuption * rp.Tier_2_Rate_kWh__c * (t2Consumtion / (monthForecast-monthProduction)) );
									System.debug(months[i] + ' Rate ' +rp.Rate_Period__c + ' t2cost ' + t2cost );
									t2cost = t2cost.setScale(2);
									System.debug(months[i]+' t2cost '+t2cost);
									//netTotalCost = netTotalCost + t2cost; 
									if(netMonthlyTierCostMap.get('T2-'+months[i]) != null)
									{
										netMonthlyTierCostMap.put('T2-'+months[i] , netMonthlyTierCostMap.get('T2-'+months[i])  + t2cost);
									}	
									else
									{
										netMonthlyTierCostMap.put('T2-'+months[i], t2cost );
									}	
								}

								if(rp.Tier_3_Rate_kWh__c != null && t3Consumtion != null && monthForecast != null  && monthProduction != null && periodConsuption != null  )
								{
									t3cost = t3cost + ( periodConsuption * rp.Tier_3_Rate_kWh__c * (t3Consumtion / (monthForecast-monthProduction)) );
									t3cost = t3cost.setScale(2);
									System.debug(months[i]+' t3cost '+t3cost);
									//netTotalCost = netTotalCost + t3Cost; 
									if(netMonthlyTierCostMap.get('T3-'+months[i]) != null)
									{
										netMonthlyTierCostMap.put('T3-'+months[i] , netMonthlyTierCostMap.get('T3-'+months[i])  + t3cost);
									}	
									else
									{
										netMonthlyTierCostMap.put('T3-'+months[i], t3cost );
									}	
								}

								if(rp.Tier_4_Rate_kWh__c != null && t4Consumtion != null && monthForecast != null  && monthProduction != null && periodConsuption != null  )
								{
									t4cost = t4cost + (periodConsuption * rp.Tier_4_Rate_kWh__c * (t4Consumtion / (monthForecast-monthProduction)) );
									t4cost = t4cost.setScale(2);
									System.debug(months[i]+' t4cost '+t4cost);
									//netTotalCost = netTotalCost + t4Cost; 
									if(netMonthlyTierCostMap.get('T4-'+months[i]) != null)
									{
										netMonthlyTierCostMap.put('T4-'+months[i] , netMonthlyTierCostMap.get('T4-'+months[i])  + t4cost);
									}	
									else
									{
										netMonthlyTierCostMap.put('T4-'+months[i], t4cost );
									}	
								}

								if(rp.Tier_5_Rate_kWh__c != null && t5Consumtion != null && monthForecast != null  && monthProduction != null && periodConsuption != null )
								{
									t5cost = t5cost + (periodConsuption * rp.Tier_5_Rate_kWh__c * (t5Consumtion / (monthForecast-monthProduction))) ;
									t5cost = t5cost.setScale(2);
									System.debug(months[i]+' t5cost '+t5cost);
									//netTotalCost = netTotalCost + t5Cost; 
									if(netMonthlyTierCostMap.get('T5-'+months[i]) != null)
									{
										netMonthlyTierCostMap.put('T5-'+months[i] , netMonthlyTierCostMap.get('T5-'+months[i])  + t5cost);
									}	
									else
									{
										netMonthlyTierCostMap.put('T5-'+months[i], t5cost );
									}	
								}	

    						}	

    						netTotalCost =  t1Cost +t2Cost + t3cost + t4cost + t5cost; 
    						netT1Cost = netT1Cost + String.valueOf(t1Cost) + ';';	
    						netT2Cost = netT2Cost + String.valueOf(t2Cost) + ';';	
    						netT3Cost = netT3Cost + String.valueOf(t3Cost) + ';';	
    						netT4Cost = netT4Cost + String.valueOf(t4Cost) + ';';	
    						netT5Cost = netT5Cost + String.valueOf(t5Cost) + ';';		 

    						netMonthlyCostMap.put(months[i],netTotalCost);     

    						System.debug('netMonthlyCostMap '+ months[i] + ' '+netTotalCost);  			
		        			
		        		}
		        	}	

		        }

		        service.put('Net_'+method+'_Tier_Cost__c','T1:'+netT1Cost+'\n'+'T2:'+netT2Cost+'\n'+'T3:'+netT3Cost+'\n'+'T4:'+netT4Cost+'\n'+'T5:'+netT5Cost);

		        //CPQ-573  DK
		        String netVariableBill = '';
		        String totalVariableBillDollars = '';
		        String methodVariableCost = '';
		        Decimal sumMonthlyBillCredit = 0;
		        String monthlyCreditAmount = '';
		        Decimal sumCreditableAmount = 0;
		        //Double[] totalAccruedCredit = new Double[]{};
		        for (String month : netMonthlyCostMap.keySet()){
		        	Decimal tierSum = netMonthlyCostMap.get(month);
		        	netVariableBill = netVariableBill + String.valueOf(tierSum) + ';';
		        	methodVariableCost = methodVariableCost + String.valueOf(Math.max(tierSum, 0)) + ';';
		        	sumMonthlyBillCredit += Math.min(tierSum, 0);
		        	Double accruedCredit = sumMonthlyBillCredit;
		        	if (sumMonthlyBillCredit < 0){
		        		monthlyCreditAmount = monthlyCreditAmount + String.valueOf(Math.max(tierSum, 0)) + ';';
		        		sumCreditableAmount += Math.max(tierSum, 0);
		        		accruedCredit += Math.max(tierSum, 0);
		        		totalVariableBillDollars = totalVariableBillDollars + String.valueOf(Math.max(Math.min(sumMonthlyBillCredit + sumCreditableAmount, Math.max(tierSum, 0)), 0)) + ';';
		        	} else {
		        		monthlyCreditAmount = monthlyCreditAmount + '0.0;';
		        		totalVariableBillDollars = totalVariableBillDollars + String.valueOf(Math.max(tierSum, 0)) + ';';
		        	}
		        	//totalAccruedCredit.add(accruedCredit);
		        }
		        if (solarRateCode.Over_Production_Credit__c == 'Dollars'){
			        service.put(method + '_Net_Variable_Bill__c', netVariableBill);
			        service.put(method + '_Total_Variable_Bill__c', totalVariableBillDollars);
			        service.put(method + '_Variable_Cost__c', methodVariableCost);
			        service.put(method + '_Monthly_Creditable_Amount__c', monthlyCreditAmount);
			    } else if (solarRateCode.Over_Production_Credit__c == 'kWH'){
			    	service.put(method + '_Total_Variable_Bill__c', netVariableBill);
			    }
				
			    Double[] monthlyVariableBill = new Double[]{};
			    for (String str : String.valueOf(service.get(method + '_Total_Variable_Bill__c')).split(';', 0)){
                    monthlyVariableBill.add(Double.valueOf(str));
			    }
			    String fixedCharges = '';
				String totalBill = '';
				for (Integer i = 0; i < monthDays.size(); i++){
					Decimal monthlyFixedCharge = solarRateCode.Monthly_Fixed_Charge__c != null ? solarRateCode.Monthly_Fixed_Charge__c : 0;
					Decimal dailyFixedCharge = solarRateCode.Daily_Fixed_Charge__c != null ? solarRateCode.Daily_Fixed_Charge__c : 0;
					Decimal charge = monthlyFixedCharge + (dailyFixedCharge * monthDays[i]);
					fixedCharges = fixedCharges + String.valueOf(charge.setScale(3)) + ';';

					if (monthlyVariableBill.size() >= i /*&& totalAccruedCredit.size() >= i*/){
						Decimal monthlyMinBill = solarRateCode.Monthly_Minimum_Bill__c != null ? solarRateCode.Monthly_Minimum_Bill__c : 0;
						Decimal dailyMinBill = solarRateCode.Daily_Minimum_Bill__c != null ? solarRateCode.Daily_Minimum_Bill__c : 0;
						Decimal minBill = monthlyMinBill + (dailyMinBill * monthDays[i]);
						System.debug('monthlyVariableBill: ' + monthlyVariableBill[i] + ', fixedCharge: ' + charge.setScale(3) + ', minBill: ' + minBill);
						totalBill = totalBill + String.valueOf(Math.max(monthlyVariableBill[i] + charge.setScale(3), minBill).setScale(2)) + ';';
					}
				}
				service.put(method + '_Fixed_Charges__c', fixedCharges);
				service.put(method + '_Total_Bill__c', totalBill);

		        /********************************************************************************************************/
		        // Get Monthly Bill Credit
		        //If sum(1-N)(Net Tier N Cost) < 0
				//sum(1-N)(Net Tier N Cost)
				//Else 0
		        Map<String,Decimal> monthlyBillCreditMap = new Map<String,Decimal>();
		        Map<String,Decimal> monthlyCreditableAmtMap = new Map<String,Decimal>();
		        String monthlyBillCredit = '';
		        //String monthlyCreditAmt = '';
				if(netMonthlyCostMap != null)
				{
					for(integer i=0;i <= 11; i=i+1 )
	        		{
	        			Decimal billCredit = 0;
	        			Decimal creditableAmt = 0;
	        			if(netMonthlyCostMap.get(months[i]) != null)
	        			{
	        				if(netMonthlyCostMap.get(months[i]) < 0)
	        				{
		        				billCredit = netMonthlyCostMap.get(months[i]);
		        				creditableAmt = 0;
		        			}
		        			else
		        			{
		        				creditableAmt = netMonthlyCostMap.get(months[i]);
		        				billCredit = 0;	
		        			}
		        			monthlyBillCreditMap.put(months[i],billCredit);
		        			monthlyBillCredit = monthlyBillCredit + String.valueOf(billCredit)+';';

		        			monthlyCreditableAmtMap.put(months[i],creditableAmt);
		        			//monthlyCreditAmt = monthlyCreditAmt + String.valueOf(creditableAmt)+';';
	        			}	        			
	        		}	
				}
				if (solarRateCode.Over_Production_Credit__c == 'Dollars'){
					service.put(method+'_Monthly_Bill_Credit__c',monthlyBillCredit);
				}
				//service.put(method+'_Monthly_Creditable_Amount__c',monthlyCreditAmt);		Commented out on 7/20/15 for CPQ-573			

				
				/********************************************************************************************************/
		        // Get Monthly Credit Carry Forward
		        //If (Monthly Creditable AmountM + Monthly Bill CreditM + Monthly Credit Carry Forward(M-1)) < 0
				//(Monthly Creditable AmountM + Monthly Bill CreditM + Monthly Credit Carry Forward(M-1)) Else 0
				// For each month, beginning with May				
				Map<String,Decimal> monthlyCreditCarryForwardMap = new Map<String,Decimal>();
				String monthlyCreditCarryFwd = '';
				for(integer i=4;i <= 11; i=i+1 )
        		{
        			Decimal creditCarryFwd = 0; 
        			Decimal prevCarryFwd = (monthlyCreditCarryForwardMap.get(months[i-1]) != null ? monthlyCreditCarryForwardMap.get(months[i-1]) : 0) ;       			
        			if(monthlyBillCreditMap.get(months[i]) != null && monthlyCreditableAmtMap.get(months[i]) != null)
        			{
        				
        				creditCarryFwd = monthlyCreditableAmtMap.get(months[i]) + monthlyBillCreditMap.get(months[i]) + prevCarryFwd;
        				if(creditCarryFwd >= 0)
        				{
	        				creditCarryFwd = 0;
	        			}	        			
	        			monthlyCreditCarryForwardMap.put(months[i],creditCarryFwd);
	        			//monthlyCreditCarryFwd = monthlyCreditCarryFwd + String.valueOf(creditCarryFwd)+';';	        			
        			}	        			
        		}	
        		for(integer i=0;i <= 3; i=i+1 )
        		{
        			Decimal creditCarryFwd = 0;
        			integer j = i-1;
        			if(j < 0)
        			{
        				j = 11;
        			} 
        			Decimal prevCarryFwd = (monthlyCreditCarryForwardMap.get(months[j]) != null ? monthlyCreditCarryForwardMap.get(months[j]) : 0) ;       			
        			if(monthlyBillCreditMap.get(months[i]) != null && monthlyCreditableAmtMap.get(months[i]) != null)
        			{
        				
        				creditCarryFwd = monthlyCreditableAmtMap.get(months[i]) + monthlyBillCreditMap.get(months[i]) + prevCarryFwd;
        				if(creditCarryFwd >= 0)
        				{
	        				creditCarryFwd = 0;
	        			}	        			
	        			monthlyCreditCarryForwardMap.put(months[i],creditCarryFwd);
	        			//monthlyCreditCarryFwd = monthlyCreditCarryFwd + String.valueOf(creditCarryFwd)+';';	        			
        			}	        			
        		}	
        		for(integer i=0;i <= 11; i=i+1 )
	        	{
	        		if(monthlyCreditCarryForwardMap.get(months[i]) != null)
        			{
	        			monthlyCreditCarryFwd = monthlyCreditCarryFwd + String.valueOf(monthlyCreditCarryForwardMap.get(months[i]))+';';	        			
        			}		
	        	}

        		service.put(method+'_Monthly_Credit_Carry_Forward__c',monthlyCreditCarryFwd);	

        		/********************************************************************************************************/
		        // Monthly Variable Cost
				//max(Monthly Creditable Amount – Monthly Credit Carry Forward, 0)
				//For each month		
				Map<String,Decimal> monthlyVariableCostMap = new Map<String,Decimal>();
				
				String monthlyVariableCost = '';

				for(integer i=4;i <= 11; i=i+1 )
        		{
        			Decimal variableCost = 0;         			
        			Decimal creditCarryFwdAmt = 0;
        			if(monthlyCreditCarryForwardMap.get(months[i]) != null && monthlyCreditableAmtMap.get(months[i]) != null)
        			{
        				
        				
        				creditCarryFwdAmt = monthlyCreditCarryForwardMap.get(months[i]);
        				System.debug(i+' monthlyCreditCarryForwardMap.get(months[i]) '+monthlyCreditCarryForwardMap.get(months[i]));
        				System.debug(i+' monthlyCreditableAmtMap.get(months[i])  '+monthlyCreditableAmtMap.get(months[i]) );
        				if(monthlyCreditableAmtMap.get(months[i]) > 0)
        				{
        					if(creditCarryFwdAmt < 0)
        					{
        						variableCost = 0 ;	
        					}
        					else
        					{
        						System.debug(i+' monthlyCreditCarryForwardMap.get(months[i-1]) '+monthlyCreditCarryForwardMap.get(months[i-1]));
        						variableCost = monthlyCreditableAmtMap.get(months[i]) - Math.abs(monthlyCreditCarryForwardMap.get(months[i-1])) ;        	
        						System.debug(i+' variableCost '+variableCost);							
        					}        					
        				}
        				else
        				{
        					
        					variableCost = 0 ;

        				}
        				    					        			
	        			monthlyVariableCostMap.put(months[i],variableCost);
	        			//monthlyVariableCost = monthlyVariableCost + String.valueOf(variableCost)+';';	        			
        			}	        		

        		}

        		for(integer i=0;i <= 3; i=i+1 )
        		{
        			Decimal variableCost = 0;         			
        			Decimal creditCarryFwdAmt = 0;
        			System.debug(i+' monthlyCreditCarryForwardMap');
        			if(monthlyCreditCarryForwardMap.get(months[i]) != null && monthlyCreditableAmtMap.get(months[i]) != null)
        			{
        				System.debug(i+' monthlyCreditCarryForwardMap');	
        				
    					creditCarryFwdAmt = monthlyCreditCarryForwardMap.get(months[i]);
    					System.debug(i+' monthlyCreditCarryForwardMap creditCarryFwdAmt '+creditCarryFwdAmt);
        				if(monthlyCreditableAmtMap.get(months[i]) > 0)
        				{
        					System.debug(i+' monthlyCreditCarryForwardMap');
        					if(creditCarryFwdAmt < 0)
        					{
        						System.debug(i+' monthlyCreditCarryForwardMap.get(months[i]) '+monthlyCreditCarryForwardMap.get(months[i]));
        						if(i==3)
        						{
        							variableCost = monthlyCreditCarryForwardMap.get(months[i]);        								
        						}
        						else
        						{
        							variableCost = 0 ;	
        						}
        					}
        					else
        					{
        						//
        						if(i==0)
        						{
        							System.debug(i+' monthlyCreditCarryForwardMap.get(months[11]) '+monthlyCreditCarryForwardMap.get(months[11]));
        							variableCost = monthlyCreditableAmtMap.get(months[i]) - Math.abs( monthlyCreditCarryForwardMap.get(months[11])) ;  
        						}
        						else
        						{
        							System.debug(i+' monthlyCreditCarryForwardMap.get(months[i-1]) '+monthlyCreditCarryForwardMap.get(months[i-1]));
        							variableCost = monthlyCreditableAmtMap.get(months[i]) - Math.abs(monthlyCreditCarryForwardMap.get(months[i-1])) ;        								
        						}
        					}        					
        				}
        				else
        				{
        					if(i==3)
        					{
        						System.debug(i+' monthlyCreditCarryForwardMap.get(months[i]) '+monthlyCreditCarryForwardMap.get(months[i]));
        						variableCost = creditCarryFwdAmt ;	
                                
        					}
        					else
        					{
        						System.debug(i+' monthlyCreditCarryForwardMap.get(months[i]) '+monthlyCreditCarryForwardMap.get(months[i]));
        						variableCost = 0 ;
        					}       					

        				}
        									        			
	        			monthlyVariableCostMap.put(months[i],variableCost);
	        			//monthlyVariableCost = monthlyVariableCost + String.valueOf(variableCost)+';';	        			
        			}	          			
        		}	

        		for(integer i=0;i <= 11; i=i+1 )
	        	{
	        		if(monthlyVariableCostMap.get(months[i]) != null)
        			{
	        			monthlyVariableCost = monthlyVariableCost + String.valueOf(monthlyVariableCostMap.get(months[i]))+';';	        			
        			}		
	        	}
				
		        service.put(method+'_Monthly_Variable_Cost__c',monthlyVariableCost);	

		        /********************************************************************************************************/
		        // Method D Net Bill
				// max{Monthly Variable Cost – Electric Vehicle Discount * Total Forecasted Consumption Month M + After Fixed Costs, Minimum Daily Bill * Days in Month + Minimum Monthly Bill}
				//For each month			

				Map<String,Decimal> monthlyNetBillMap = getTotalBill(service, afterRateCode , afterMonthlyTierCostMap, afterMonthlyFixedCostMap, monthlyVariableCostMap, 'Solar');

		        /********************************************************************************************************/
		        //Method D Avoided Utility Rate
		        // sum(1-M)(sum(1-N)(Before Total Bill – Method D Net Bill)/Method D Projected Annual Output)
				
				double totalAnnualBeforeBill = 0;
				double totalAnnualAfterBill = 0;	//CPQ-573  DK
				double totalAnnualNetBill = 0;
				double totalAnnualProduction = 0;

				for(integer i=0;i <= 11; i=i+1 )
				{
					
					totalAnnualProduction = totalAnnualProduction + productionMonthMap.get(method+'_'+months[i]);
					System.debug(' months[i] ' +months[i] + ' '+productionMonthMap.get(method+'_'+months[i]));
					totalAnnualBeforeBill = totalAnnualBeforeBill + beforeMonthlyTotalBillMap.get(months[i]);
					totalAnnualAfterBill = totalAnnualAfterBill + afterMonthlyTotalBillMap.get(months[i]);
					totalAnnualNetBill = totalAnnualNetBill + monthlyNetBillMap.get(months[i]);
				}
				Double sumBeforeFixedCosts = 0;
				for (String str : String.valueOf(service.get('Before_Fixed_Costs__c')).split(';', 0)){
			    	sumBeforeFixedCosts += Double.valueOf(str);
			    }

				Decimal methodAvoidedUtilityRate = (totalAnnualBeforeBill - totalAnnualNetBill)/totalAnnualProduction;
				double totalConsumption = service.Total_Forecasted_Consumption_kWh__c;
				methodAvoidedUtilityRate = methodAvoidedUtilityRate.setScale(5);
				service.put(method  + '_Avoided_Utility_Rate__c', methodAvoidedUtilityRate);
				//service.put('Before_First_Year_Avg_Price__c', Decimal.valueOf(totalAnnualBeforeBill /totalConsumption ).setScale(5));		//Commented out by DK on 7/22/15
				service.put('Before_First_Year_Avg_Price__c', Decimal.valueOf((totalAnnualBeforeBill - sumBeforeFixedCosts) / totalConsumption).setScale(5));
				service.put('Net_First_Year_Avg_Price__c', Decimal.valueOf(totalAnnualNetBill / totalConsumption).setScale(5));
				System.debug(' totalAnnualNetBill '+totalAnnualNetBill + ' totalAnnualProduction '+totalAnnualProduction);
				service.put('First_Year_Remaining_Rate__c', Decimal.valueOf(totalAnnualNetBill / (totalConsumption -totalAnnualProduction )).setScale(5));
				service.put('Valid__c',true);

				//CPQ-573 continued
				Decimal annualProductionCredit = 0;
				if (solarRateCode.Over_Production_Credit__c == 'Dollars'){
					annualProductionCredit = Math.min(sumMonthlyBillCredit + sumCreditableAmount, 0);
				} else if (solarRateCode.Over_Production_Credit__c == 'kWH'){
					annualProductionCredit = Math.min(sumProdCredit + sumCreditableConsumption, 0) * (afterRateCode.Over_Production_Credit_Rate__c != null ? afterRateCode.Over_Production_Credit_Rate__c : 0);
				}
				service.put(method + '_Annual_Prod_Credit__c', annualProductionCredit);

				Double method1AnnualBill = 0;
			    for (String str : String.valueOf(service.get(method + '_Total_Bill__c')).split(';', 0)){
                    method1AnnualBill += (Double.valueOf(str));
			    }
				service.put(method + '_Net_Bill__c', method1AnnualBill + annualProductionCredit);
				service.put(method + '_Net_Savings__c', totalAnnualAfterBill - (method1AnnualBill + annualProductionCredit));
			}
			catch(Exception e)
			{
				System.debug('Custom Exception thrown to break the further processing ' + e.getStackTraceString());
				service.put('Valid__c',false);
			}	
		}
		update servicesMap.values();

		if (errorLog == '')
			errorLog = 'OK';
		return errorLog;
	}


	public class customException extends Exception{}
	
}