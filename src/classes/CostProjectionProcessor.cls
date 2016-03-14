/* FILE: CostProjectionProcessor.cls
 * AUTHOR: Pavitra Burla
 * DATE: June 11, 2015
 * PURPOSE: Calculate cost projections for Material, Labor and Overhead costs.
 * MODIFICATION HISTORY
 * 07/22/2015 PB - FPO PhaseII Changes in labor rate calculation
 * 08/12/2015 PB - FPO PhaseIII Enhancement to Material and Labor projection
 */
public class CostProjectionProcessor {

	//FPO-3 PB - This function is no longer used
/*
	public static Double getMatlCostProjection(SCRB_SalesOrder__c salesOrder){

		//Division
		Id div = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c;
		System.debug(loggingLevel.ERROR,'**Division:' + div);

		//System Design Items
		String sysdesId = (salesOrder.System_Design_Quote__r.System_Design__c !=null)?((String)salesOrder.System_Design_Quote__r.System_Design__c).substring(0,15):'';
		System.debug(loggingLevel.ERROR,'**System Dessign:' + salesorder.System_Design_Quote__r.System_Design__c);
		List<System_Design_Item__c> sysdesItems = new List<System_Design_Item__c>();
		sysdesItems = [SELECT Quantity__c, System_Design_Product__c
						, System_Design_Product__r.Engineering_Item_Master__c 
						FROM System_Design_Item__c 
						WHERE System_Design__c =:sysdesId];
		
		//Engineering Items
		Set<Id> engItemsSet = new Set<Id>();
		for(System_Design_Item__c item: sysdesItems){
		    engItemsSet.add(item.System_Design_Product__r.Engineering_Item_Master__c);
		    System.debug(logginglevel.ERROR,item.System_Design_Product__r.Engineering_Item_Master__c);
		}

		//Engineering Items Costs
		List<rstk__peitem__c> engItems = new List<rstk__peitem__c>();
		engItems = [SELECT Id, name, (SELECT Id, rstk__icitem_icitemcst__r.rstk__icitemcst_lstactucstmtl__c 
										FROM rstk__icitems__r 
										WHERE rstk__icitem_div__c =:div) 
		            FROM rstk__peitem__c 
		            WHERE Id IN:engItemsSet];
		System.debug(loggingLevel.ERROR,'**EngItems size:' + engItems.size());
		Map<Id,Double> itemCostMap = new Map<Id,Double>();
		for(rstk__peitem__c item: engItems){
		    itemCostMap.put(item.Id, item.rstk__icitems__r[0].rstk__icitem_icitemcst__r.rstk__icitemcst_lstactucstmtl__c);
		    System.debug(loggingLevel.ERROR,'**Item costs:' + item.Id + '**cost:' + item.rstk__icitems__r[0].rstk__icitem_icitemcst__r.rstk__icitemcst_lstactucstmtl__c);
		}

		//Total Cost
		Double totalMatlCost = 0;
		for(System_Design_Item__c item: sysdesItems){
		    if(itemCostMap.containsKey(item.System_Design_Product__r.Engineering_Item_Master__c)){
		        totalMatlCost += itemCostMap.get(item.System_Design_Product__r.Engineering_Item_Master__c) * item.Quantity__c ;        
		    }    
		}
		System.debug(loggingLevel.ERROR,'Total Material cost:' + totalMatlCost);
		
		return totalMatlCost;

	}
*/
	public static Double getLaborCostProjection(SCRB_SalesOrder__c salesOrder){

		Double totLaborCost = 0;
		String homeOffice = '';
		Double electricianAvgHourlyRate = 0;
		Double installerAvgHourlyRate = 0;
		Double installerBudgetHrs = 0;
		Double electricianBudgetHrs = 0;
		String offDiv = '';
		Double laborCostMultiplier = 1; 

		//Get Install Project from SO
		List<Install_Project__c> instlProjs = new List<Install_Project__c>();  
		instlProjs = [SELECT Installer_Bonus_Budget_Hours__c, Electrician_Bonus_Budget_Hours__c
						, Sales_Order__r.Property__r.Astrum_Office_New__c
						,Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__c 
                     FROM Install_Project__c 
                     WHERE Sales_Order__c = :salesOrder.Id];

     	if(instlProjs.size() > 0){
     		Install_Project__c instlProj = instlProjs[0];
     		homeOffice = instlProj.Sales_Order__r.Property__r.Astrum_Office_New__c;
     		offDiv = instlProj.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__c;
     		System.debug(loggingLevel.ERROR,'**homeOffice:' + homeOffice);
     		
     		installerBudgetHrs = (instlProj.Installer_Bonus_Budget_Hours__c != null && instlProj.Installer_Bonus_Budget_Hours__c>0)?instlProj.Installer_Bonus_Budget_Hours__c:0;
			electricianBudgetHrs = (instlProj.Electrician_Bonus_Budget_Hours__c != null && instlProj.Electrician_Bonus_Budget_Hours__c>0)?instlProj.Electrician_Bonus_Budget_Hours__c:0;

			//Get Avg hourly rate for Electricians in the offLoc
			AggregateResult[] result = [SELECT Avg(Hourly_Rate__c) AvghrlyRate 
										FROM Employee__c 
										WHERE Status__c != 'Inactive' 
										AND Home_Office_Location__c =:homeOffice 
										AND Hourly_Rate__c > 0   
										AND Job_Title__c IN('Electrician', 'Lead Electrician')];

			if(result.size() > 0 && result[0].get('AvghrlyRate')!=null){
				electricianAvgHourlyRate = (Double) result[0].get('AvghrlyRate');
			}else{
				//if no eligible employees found with the offLoc, query based on div and Main Site
				result = [SELECT Avg(Hourly_Rate__c) AvghrlyRate 
							FROM Employee__c 
							WHERE Status__c != 'Inactive'
							AND Hourly_Rate__c > 0
							AND Home_Office_Location__r.Rootstock_Division__c =:offDiv
							AND Home_Office_Location__r.Main_Site__c = true    
							AND Job_Title__c IN('Electrician', 'Lead Electrician')];

				if(result.size() > 0 && result[0].get('AvghrlyRate')!=null){
					electricianAvgHourlyRate = (Double) result[0].get('AvghrlyRate');
				}else{
					//if no eligible employees found, query based on div
					result = [SELECT Avg(Hourly_Rate__c) AvghrlyRate 
							FROM Employee__c 
							WHERE Status__c != 'Inactive'
							AND Hourly_Rate__c > 0
							AND Home_Office_Location__r.Rootstock_Division__c =:offDiv
							AND Job_Title__c IN('Electrician', 'Lead Electrician')];

					if(result.size() > 0 && result[0].get('AvghrlyRate')!=null){
						electricianAvgHourlyRate = (Double) result[0].get('AvghrlyRate');
					}else{
						//if no eligible employees found, query all eligible employees in all offfLocs
						result = [SELECT Avg(Hourly_Rate__c) AvghrlyRate 
									FROM Employee__c 
									WHERE Status__c != 'Inactive'
									AND Hourly_Rate__c > 0   
									AND Job_Title__c IN('Electrician', 'Lead Electrician')];

					}
				}
				electricianAvgHourlyRate = (Double) result[0].get('AvghrlyRate');
			}
			
			//Get Avg hourly rate for Installers in the offLoc
			result = [SELECT Avg(Hourly_Rate__c) AvghrlyRate 
										FROM Employee__c 
										WHERE Status__c != 'Inactive' 
										AND Home_Office_Location__c =:homeOffice 
										AND Hourly_Rate__c > 0   
										AND Job_Title__c IN('Solar Installer', 'Lead Installer')];

			if(result.size() > 0 && result[0].get('AvghrlyRate')!=null){
				installerAvgHourlyRate  = (Double) result[0].get('AvghrlyRate');
			}else{
				//if no eligible employees found with the offLoc, query based on div and Main Site
				result = [SELECT Avg(Hourly_Rate__c) AvghrlyRate 
							FROM Employee__c 
							WHERE Status__c != 'Inactive'
							AND Hourly_Rate__c > 0
							AND Home_Office_Location__r.Rootstock_Division__c =:offDiv
							AND Home_Office_Location__r.Main_Site__c = true    
							AND Job_Title__c IN('Solar Installer', 'Lead Installer')];

				if(result.size() > 0 && result[0].get('AvghrlyRate')!=null){
					installerAvgHourlyRate  = (Double) result[0].get('AvghrlyRate');
				}else{
					//if no eligible employees found, query based on div
					result = [SELECT Avg(Hourly_Rate__c) AvghrlyRate 
							FROM Employee__c 
							WHERE Status__c != 'Inactive'
							AND Hourly_Rate__c > 0
							AND Home_Office_Location__r.Rootstock_Division__c =:offDiv
							AND Job_Title__c IN('Solar Installer', 'Lead Installer')];

					if(result.size() > 0 && result[0].get('AvghrlyRate')!=null){
						installerAvgHourlyRate  = (Double) result[0].get('AvghrlyRate');
					}else{
						//if no eligible employees found, query all eligible employees in all offfLocs
						result = [SELECT Avg(Hourly_Rate__c) AvghrlyRate 
									FROM Employee__c 
									WHERE Status__c != 'Inactive'
									AND Hourly_Rate__c > 0   
									AND Job_Title__c IN('Solar Installer', 'Lead Installer')];

					}
				}
				installerAvgHourlyRate = (Double) result[0].get('AvghrlyRate');
			}			
			
			//Calculate total labor cost
			totLaborCost = (installerBudgetHrs * installerAvgHourlyRate) + (electricianBudgetHrs * electricianAvgHourlyRate);
			System.debug(loggingLevel.ERROR,'**InstallerBudgetHrs * installerAvgHourlyRate:' + installerBudgetHrs + '*' + installerAvgHourlyRate);
			System.debug(loggingLevel.ERROR,'**ElectricianBudgetHrs * electricianAvgHourlyRate:' + electricianBudgetHrs + '*' + electricianAvgHourlyRate);
			System.debug(loggingLevel.ERROR,'**TotLaborCost:' + totLaborCost);
			System.debug(loggingLevel.ERROR,'**homeOffice:' + homeOffice);

     	}

     	if(Cost_Multiplier_Setting__c.getOrgDefaults().Labor_Cost_Multiplier__c !=null){
     		laborCostMultiplier = Cost_Multiplier_Setting__c.getOrgDefaults().Labor_Cost_Multiplier__c;
     	}
     	
     	totLaborCost = totLaborCost * laborCostMultiplier;
		
		return totLaborCost;
	}

	public static Double getOverheadProjection(SCRB_SalesOrder__c salesOrder){
		
		String propState = salesOrder.Property__r.Property_State__c;
		String county = salesOrder.Property__r.Property_County__c;
		String qasCounty = salesOrder.Property__r.QAS_Property_County__c;
		Double permitCost = 0;
		Double gasCost = 0;
		Double totOverheadCost = 0;

		System.debug(loggingLevel.ERROR,'**propState' + propState + ' ' + '**county:' + county + ' ' + '**qasCounty:' + qasCounty );

		//Get Permit Cost
		if(propState != null 
		   && (propState == 'DC' 
		       || county != null 
		       || qasCounty != null)){
		           
           String crit = '(State_Abbreviation__c = \'' + String.escapeSingleQuotes(propState) + '\'';
           if (propState != 'DC') {
               crit += ' AND Name LIKE \'' + String.escapeSingleQuotes(qasCounty != null ? qasCounty : SalesRegionHelper.removeState(county)) + '%\'';
           }
           crit += ')';    
           String query = 'SELECT Id, Name, Permit_Cost__c FROM County__c ';
           query+= ' WHERE ' + crit + ' limit 1';
           List<County__c> results = new List<County__c>();
           results = database.query(query);
           if(results.size() > 0 && results[0].Permit_Cost__c != null && results[0].Permit_Cost__c > 0){
           	permitCost = results[0].Permit_Cost__c;
           }
                      
       }
		System.debug(loggingLevel.ERROR,'**Permit cost :' + permitCost);
		
		
		/*FPO-3 Commented the cost dependency on gas cost/*Get Gas Cost
		List<Install_Project__c> instlProjs = new List<Install_Project__c>();
		instlProjs = [SELECT Installer_Bonus_Budget_Hours__c, Electrician_Bonus_Budget_Hours__c
						, Drive_Time_Office_To_Site__c, Electrician_Drive_Time_To_Site__c 
	                     FROM Install_Project__c 
	                     WHERE Sales_Order__c = :salesOrder.Id LIMIT 1];

     	
     	if(instlProjs.size() > 0){
     		Install_Project__c instlProj = instlProjs[0];

     		//Get Gas cost
	     	gasCost = GasSettings__c.getOrgDefaults().Coefficient__c * ( 
			//((instlProj.Installer_Bonus_Budget_Hours__c * instlProj.Drive_Time_Office_To_Site__c) + (instlProj.Electrician_Bonus_Budget_Hours__c * instlProj.Electrician_Drive_Time_To_Site__c)) / (instlProj.Installer_Bonus_Budget_Hours__c + instlProj.Electrician_Bonus_Budget_Hours__c) 
			(instlProj.Installer_Bonus_Budget_Hours__c/(instlProj.Installer_Bonus_Budget_Hours__c + instlProj.Electrician_Bonus_Budget_Hours__c)) * instlProj.Drive_Time_Office_To_Site__c 
				+ (instlProj.Electrician_Bonus_Budget_Hours__c/ (instlProj.Installer_Bonus_Budget_Hours__c + instlProj.Electrician_Bonus_Budget_Hours__c))  * instlProj.Electrician_Drive_Time_To_Site__c
			
			);
     	}
     	System.debug(loggingLevel.ERROR,'**Gas cost :' + gasCost);
		totOverheadCost = permitCost + gasCost;*/
		totOverheadCost = permitCost;
		return totOverheadCost;

	}

	public static void updateRtskCstProjections(Id salesOrderId){

		SCRB_SalesOrder__c salesOrder = [SELECT Property__r.Astrum_Office_New__r.Rootstock_Division__c, Job_Id__c
                                 ,System_Design_Quote__r.System_Design__c, Property__r.Property_State__c
                                 , Property__r.Property_County__c, Property__r.QAS_Property_County__c
                                 , Amount__c  
                                 FROM SCRB_SalesOrder__c 
                                 WHERE Id=:salesOrderId];
     	//FPO-3 PB
     	PM_Project__c pmproj;
     	try{
     		pmproj = [SELECT Id, Name FROM PM_Project__c WHERE Sales_Order__c =:salesOrder.Id ORDER BY CreatedDate DESC LIMIT 1];
 		}catch(QueryException qe){return;}     	

     	List<rstk__pjproj__c> projMasters = new List<rstk__pjproj__c>(); 
		
		projMasters = [SELECT Id, (SELECT Id 
	                        FROM rstk__pjprojcsts__r)
	                     FROM rstk__pjproj__c 
	                     WHERE rstk__pjproj_div__c =:salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c 
	                     AND rstk__pjproj_proj__c = :salesOrder.Job_Id__c];
		
		if(projMasters.size() >0){
			rstk__pjproj__c projMaster = projMasters[0];
			rstk__pjprojcst__c projCst = projMaster.rstk__pjprojcsts__r[0];
			projCst.rstk__pjprojcst_baclab__c = CostProjectionProcessor.getLaborCostProjection(salesOrder);
		    //FPO-3 PB
		    //projCst.rstk__pjprojcst_bacmtl__c = CostProjectionProcessor.getMatlCostProjection(salesOrder);
		    //projCst.rstk__pjprojcst_bacmtl__c = CostProjectionProcessor.getMatlCostProjection(salesOrder,pmproj);
		    projCst.rstk__pjprojcst_bacmtl__c = CostProjectionProcessor.getMatlCostProjection(salesOrder,pmproj,true);
		    
		    projCst.rstk__pjprojcst_bacmodc__c= CostProjectionProcessor.getOverheadProjection(salesOrder);

		    //FPO-3 PB
		    projCst.rstk__pjprojcst_budprodrevenue__c = salesOrder.Amount__c;
		    update projCst;
			System.debug(loggingLevel.ERROR,'**projCst.rstk__pjprojcst_baclab__c:' + projCst.rstk__pjprojcst_baclab__c);
			System.debug(loggingLevel.ERROR,'**projCst.rstk__pjprojcst_bacmtl__c:' + projCst.rstk__pjprojcst_bacmtl__c);
			System.debug(loggingLevel.ERROR,'**projCst.rstk__pjprojcst_bacmodc__c:' + projCst.rstk__pjprojcst_bacmodc__c);
		}

	}

	public static Double getMatlCostProjection(SCRB_SalesOrder__c salesOrder, PM_Project__c pmproj, Boolean generateProjCostRecord){

		
		Double totCostWithMultiplier = 0;

		//Division
		Id div = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c;
		System.debug(loggingLevel.ERROR,'**Division:' + div);

		//System Design Items
		String sysdesId = (salesOrder.System_Design_Quote__r.System_Design__c !=null)?((String)salesOrder.System_Design_Quote__r.System_Design__c).substring(0,15):'';
		if(String.isBlank(sysdesId)){
			return totCostWithMultiplier;
		}
		System.debug(loggingLevel.ERROR,'**System Dessign:' + salesorder.System_Design_Quote__r.System_Design__c);
		List<System_Design_Item__c> sysdesItems = new List<System_Design_Item__c>();
		AggregateResult[] results = [SELECT SUM(Quantity__c) Qty,System_Design_Product__r.Engineering_Item_Master__c engItem 
						FROM System_Design_Item__c 
						WHERE System_Design__c =:sysdesId
                      	GROUP BY System_Design_Product__r.Engineering_Item_Master__c ];
		
		//Engineering Items
		Set<Id> engItemsSet = new Set<Id>();
		Map<Id,Integer> engItemQtyMap = new Map<Id,Integer>();
		for(AggregateResult result: results){
		    engItemsSet.add((Id)result.get('engItem'));
            engItemQtyMap.put((Id)result.get('engItem'),Integer.valueOf((Decimal)result.get('Qty')));
		    System.debug(logginglevel.ERROR,result.get('engItem'));
		}
		
		Set<Id> engItemsWithBOM = new Set<Id>();
		Map<Id,Integer> engItemCompMap = new Map<Id,Integer>();

		//Check if engitem has BOM
		List<rstk__pebom__c> boms = [SELECT rstk__pebom_compitem__c, rstk__pebom_item__c, rstk__pebom_qtyper__c 
         								FROM rstk__pebom__c 
                                     	WHERE rstk__pebom_item__c IN:engItemQtyMap.keySet()];
        if(boms!= null){
            for(rstk__pebom__c bom: boms){
                engItemsWithBOM.add(bom.rstk__pebom_item__c);
                engItemCompMap.put(bom.rstk__pebom_compitem__c,Integer.valueOf(bom.rstk__pebom_qtyper__c) * (engItemQtyMap.get(bom.rstk__pebom_item__c)));
                System.debug(loggingLevel.ERROR,'**comp ITEMS:' + bom.rstk__pebom_compitem__c);
            }            
        }else{
            System.debug(loggingLevel.ERROR,'**comp ITEMS:none');
        }

		//Remove engitems that have bom
        for(Id item:engItemsWithBOM){
            engItemQtyMap.remove(item);            
        }
		
		//Final map of all items
		engItemQtyMap.putAll(engItemCompMap);

        for(Id item:engItemQtyMap.keySet()){
            System.debug(loggingLevel.ERROR,'**FINAL ITEMS:' + item + ' qty:' + engItemQtyMap.get(item));
        }
	
		//Engineering Items Costs
		List<rstk__peitem__c> engItems = new List<rstk__peitem__c>();
		engItems = [SELECT Id, name, (SELECT Id, rstk__icitem_icitemcst__r.rstk__icitemcst_lstactucstmtl__c 
										FROM rstk__icitems__r 
										WHERE rstk__icitem_div__c =:div) 
		            FROM rstk__peitem__c 
		            WHERE Id IN:engItemQtyMap.keySet()];
		System.debug(loggingLevel.ERROR,'**EngItems size:' + engItems.size());

		Map<Id,String> itemNameMap = new Map<Id,String>();
		Map<Id,Double> itemCostMap = new Map<Id,Double>();
		Set<Id> invItemsWithZeroCost = new Set<Id>();
		Set<Id> engItemsWithoutInv = new Set<Id>();
		Set<Id> engItemsWithZeroCost = new Set<Id>();
		Double itemCost = 0;
		for(rstk__peitem__c item: engItems){
            itemCost = 0;
            if(item.rstk__icitems__r.size()>0){
                itemCost = item.rstk__icitems__r[0].rstk__icitem_icitemcst__r.rstk__icitemcst_lstactucstmtl__c;
                if(itemCost == 0){
                    invItemsWithZeroCost.add(item.rstk__icitems__r[0].Id);                    
                }
                
            }else{
                engItemsWithoutInv.add(item.Id);                 
            }
            if(itemCost == 0){
                engItemsWithZeroCost.add(item.Id);
            }
            itemCostMap.put(item.Id, itemCost);
            itemNameMap.put(item.Id,item.Name);
            
		}

	 
        //debug
        if(engItemsWithZeroCost.size()>0){
            for(Id item:engItemsWithZeroCost){                
            	System.debug(loggingLevel.ERROR,'**EngItem with zero costs:' + item);                
            }
        }

		if(invItemsWithZeroCost.size()>0){
            for(Id item:invItemsWithZeroCost){                
            	System.debug(loggingLevel.ERROR,'**InvItem with zero costs:' + item);                
            }
        }
		
        for(Id item:itemCostMap.keySet()){
            System.debug(loggingLevel.ERROR,'**EngItem :' + item + ' ' + '****Cost:' + itemCostMap.get(item));
            
        }
            
        //End of debug
            
       
		//for items with zero cost get cost from PO
        if(invItemsWithZeroCost.size()>0){
            List<rstk__poline__c> polines =[SELECT rstk__poline_unitprice__c, createdDate, rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__c
            								,rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__r.Name
	                                        FROM rstk__poline__c 
	                                        WHERE rstk__poline_item__r.rstk__poitem_item__c IN:invItemsWithZeroCost
	                                        ORDER BY rstk__poline_item__r.rstk__poitem_item__c,createdDate DESC];
            Id invItem;
            
            if(polines!= null){
                for(rstk__poline__c poline: polines){
                    if(poline.rstk__poline_item__r.rstk__poitem_item__c == invItem){
                        continue;
                    }
                    invItem = poline.rstk__poline_item__r.rstk__poitem_item__c;
                    itemCostMap.put(poline.rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__c, poline.rstk__poline_unitprice__c);
                    itemNameMap.put(poline.rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__c,poline.rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__r.Name);
                    engItemsWithZeroCost.remove(poline.rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__c);
                }            
            }
        }

		//if there are items that have zero cost and no po, search for all PO's in the Enginnering Item Master
        if(engItemsWithZeroCost.size()>0){
            Id engItem;
            List<rstk__poline__c> allpolines =[SELECT rstk__poline_unitprice__c, createdDate,rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__c
            									,rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__r.name 
	                                            FROM rstk__poline__c 
	                                            WHERE rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__c IN:engItemsWithZeroCost
	                                            ORDER BY rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__c,createdDate DESC];
            if(allpolines!= null){
                for(rstk__poline__c poline: allpolines){
                    if(poline.rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__c == engItem){
                        continue;
                    }
                    engItem = poline.rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__c;
                    itemCostMap.put(poline.rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__c, poline.rstk__poline_unitprice__c);
                    itemNameMap.put(poline.rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__c,poline.rstk__poline_item__r.rstk__poitem_item__r.rstk__icitem_item__r.name);                
                }            
            }
        }		
		
		//total cost
		Double totCost = 0;
		Double materialCostMultiplier = 1;
		if(Cost_Multiplier_Setting__c.getOrgDefaults().Material_Cost_Multiplier__c!=null){
			materialCostMultiplier = Cost_Multiplier_Setting__c.getOrgDefaults().Material_Cost_Multiplier__c;
		}
		Double extractedCost = 0;

		List<Project_Cost__c> projCosts = [SELECT Id, Engineering_Item_Master__c 
											FROM Project_Cost__c 
											WHERE PM_Project__c = :pmproj.Id 
											AND Engineering_Item_Master__c IN:itemCostMap.keySet()];

		Map<Id,Project_Cost__c> engItemsWithProjCost = new Map<Id,Project_Cost__c>();
		List<Project_Cost__c> projCostsToUpsert = new List<Project_Cost__c>();
		if(projCosts!= null){
			for(Project_Cost__c projCost:projCosts){
				engItemsWithProjCost.put(projCost.Engineering_Item_Master__c,projCost);
			}
		}
		
		Id projCostId;
        for(Id item:itemCostMap.keySet()){
            extractedCost = itemCostMap.get(item) * engItemQtyMap.get(item);
            totCost+= extractedCost;
            if(engItemsWithProjCost.containsKey(item)){
            	projCostId = engItemsWithProjCost.get(item).Id;
            }
            projCostsToUpsert.add(
                new Project_Cost__c(
                	Id = projCostId
                	, Name = pmproj.Name + '(' + itemNameMap.get(item) + ')'
                	, PM_Project__c=pmproj.Id 
                    , Engineering_Item_Master__c=item
                    , Qty__c= engItemQtyMap.get(item)
                    , Extracted_Cost__c = extractedCost
                    , Projected_Cost__c= extractedCost * materialCostMultiplier));
            projCostId = null;
        }
        if(generateProjCostRecord){
        	upsert projCostsToUpsert;
        }
        
		totCostWithMultiplier = totCost * materialCostMultiplier;
		System.debug(loggingLevel.ERROR, '***totCost' + totCost);
		System.debug(loggingLevel.ERROR, '***totCostWithMultiplier' + totCostWithMultiplier);
		
		return totCostWithMultiplier;

	}

}