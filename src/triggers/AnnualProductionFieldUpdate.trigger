/***********************************************
    Trigger: AnnualProductionFieldUpdate 
    Author:  Astrum Solar
    Usage:   This trigger is used to calculate the values of 
             monthly production guarantee, monthly SRECs carryover
             and monthly projected SRECs.
    Date:    01/04/2012
***********************************************/

trigger AnnualProductionFieldUpdate on Annual_Production__c (after insert, after update) {
   
   if(!Test.isRunningTest()){
       if(!Util.runOnce())
           return;
   }
   
   String ERROR_MSG_1 = 'Production Year Starting Month cannot be null';
   String ERROR_MSG_2 = 'Insatllation Year cannot be null';
   
   /* set for parent installed system id */
   Set<String> installId = new Set<String>();
   
   Map<Id, Annual_Production__c> apMap = new  Map<Id, Annual_Production__c>();
    
   for(Annual_Production__c ap :trigger.new) {
       installId.add(ap.Installed_System__c);
   }
    
   Map<Id, Installed_System__c> objInstSysMap = new Map<Id, Installed_System__c>([
                                     Select Production_Year_Starting_Month__c, 
                                     Installation_Year__c, 
                                     Projected_January_Production_kWh__c,
                                     Projected_February_Production_kWh__c, 
                                     Projected_March_Production_kWh__c,
                                     Projected_April_Production_kWh__c,
                                     Projected_May_Production_kWh__c,
                                     Projected_June_Production_kWh__c,
                                     Projected_July_Production_kWh__c,
                                     Projected_August_Production_kWh__c,
                                     Projected_September_Production_kWh__c,
                                     Projected_October_Production_kWh__c,
                                     Projected_November_Production_kWh__c,
                                     Projected_December_Production_kWh__c 
                                     from Installed_System__c 
                                     where Id = :installId]);
    
   
       List<Annual_Production__c> listAP = [Select Installed_System__c,Year__c, Previous_December_SREC_Carryover__c, January_Production_Guarantee_kWh__c, February_Production_Guarantee_kWh__c,     //Annual_Production_To_Date_kWh__c
                                           March_Production_Guarantee_kWh__c, April_Production_Guarantee_kWh__c, 
                                           May_Production_Guarantee_kWh__c, June_Production_Guarantee_kWh__c, 
                                           July_Production_Guarantee_kWh__c, August_Production_Guarantee_kWh__c, 
                                           September_Production_Guarantee_kWh__c, October_Production_Guarantee_kWh__c, 
                                           November_Production_Guarantee_kWh__c, December_Production_Guarantee_kWh__c,January_Projected_SRECs__c, February_Projected_SRECs__c, 
                                           March_Projected_SRECs__c, April_Projected_SRECs__c, May_Projected_SRECs__c, 
                                           June_Projected_SRECs__c, July_Projected_SRECs__c, August_Projected_SRECs__c, 
                                           September_Projected_SRECs__c, October_Projected_SRECs__c, November_Projected_SRECs__c, 
                                           December_Projected_SRECs__c, January_SRECs_Carryover__c,February_SRECs_Carryover__c,
                                           March_SRECs_Carryover__c, April_SRECs_Carryover__c, May_SRECs_Carryover__c,
                                           June_SRECs_Carryover__c, July_SRECs_Carryover__c, August_SRECs_Carryover__c, 
                                           September_SRECs_Carryover__c, October_SRECs_Carryover__c, November_SRECs_Carryover__c,
                                           December_SRECs_Carryover__c from Annual_Production__c where id in :trigger.newMap.keySet()];            
   
    
    
   for(Annual_Production__c objAP :listAP) {
        
        Installed_System__c objInstSys = new Installed_System__c();
        
        if(objInstSysMap != null && objInstSysMap.containsKey(objAP.Installed_System__c)) {
            objInstSys = objInstSysMap.get(objAP.Installed_System__c);
        }
        
        /* variable for Install System Production Year Starting Month */
        Decimal prodYearStrMonth; 
        
        /* variable for Install System Installation Year */ 
        Integer installYear;   
        
        /* variable for Annual Production Year */ 
        Integer prodyear;
        
        if(objInstSys.Installation_Year__c != null){
            installYear = Integer.ValueOf(objInstSys.Installation_Year__c); 
        }
        else {
            objAP.AddError(ERROR_MSG_2);
        }
        
        if(objInstSys.Production_Year_Starting_Month__c != null){
            prodYearStrMonth = objInstSys.Production_Year_Starting_Month__c; 
        }
        else {
            objAP.addError(ERROR_MSG_1);
        }
        
        if(objAP.Year__c != null && validYear(installYear, objAP.Year__c)){       
            prodyear = Integer.ValueOf(objAP.Year__c);
             
            /* calc data for january production grnt, srec_carryover, projected srec */
            if(objInstSys.Projected_January_Production_kWh__c != null) { 
                if(validateMonthDetail(1, prodyear, installYear, prodYearStrMonth) == true) {     
                    Decimal janProProd = objInstSys.Projected_January_Production_kWh__c;                    
                    Double comCalc = ((janProProd/ 1000) +  calcPreDecSrecCarryOver(objInstSys.id,(prodYear - 1)));             // objAP.Previous_December_SREC_Carryover__c
                                
                    objAP.January_Production_Guarantee_kWh__c =  janProProd * 0.95 * getProjGrntFactor(getMnthFactor(1, prodyear, installYear, prodYearStrMonth));          
                    objAP.January_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.January_Projected_SRECs__c = Math.Floor(comCalc);
                }
                else {
                    objAP.January_Production_Guarantee_kWh__c = 0;          
                    objAP.January_SRECs_Carryover__c = 0;
                    objAP.January_Projected_SRECs__c = 0;                
                }
            }   
            
            if(objInstSys.Projected_February_Production_kWh__c != null) { 
                if(validateMonthDetail(2, prodyear, installYear, prodYearStrMonth) == true) {        
                    Decimal febProProd = objInstSys.Projected_February_Production_kWh__c; 
                    Double comCalc = ((febProProd/ 1000) + objAP.January_SRECs_Carryover__c);             
                   
                    objAP.February_Production_Guarantee_kWh__c = febProProd * 0.95 * getProjGrntFactor(getMnthFactor(2, prodyear, installYear, prodYearStrMonth));             
                    objAP.February_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.February_Projected_SRECs__c = Math.Floor(comCalc);
                }
                else {
                    objAP.February_Production_Guarantee_kWh__c = 0;
                    objAP.February_SRECs_Carryover__c = 0;
                    objAP.February_Projected_SRECs__c = 0;                
                }
            }
            
            if(objInstSys.Projected_March_Production_kWh__c != null) {  
                if(validateMonthDetail(3, prodyear, installYear, prodYearStrMonth) == true) {       
                    Decimal marProProd = objInstSys.Projected_March_Production_kWh__c; 
                    Double comCalc = ((marProProd/1000) + ObjAP.February_SRECs_Carryover__c);   
                    
                    objAP.March_Production_Guarantee_kWh__c = marProProd * 0.95 * getProjGrntFactor(getMnthFactor(3, prodyear, installYear, prodYearStrMonth));            
                    objAP.March_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.March_Projected_SRECs__c = Math.Floor(comCalc);
                }
                else {
                    objAP.March_Production_Guarantee_kWh__c = 0;
                    objAP.March_SRECs_Carryover__c = 0;
                    objAP.March_Projected_SRECs__c = 0;                
                }
            } 
            
            if(objInstSys.Projected_April_Production_kWh__c != null) { 
                if(validateMonthDetail(4, prodyear, installYear, prodYearStrMonth) == true) {    
                    Decimal aprProProd = objInstSys.Projected_April_Production_kWh__c;            
                    Double comCalc = ((aprProProd/ 1000) + objAP.March_SRECs_Carryover__c);
                        
                    objAP.April_Production_Guarantee_kWh__c = aprProProd * 0.95 * getProjGrntFactor(getMnthFactor(4, prodyear, installYear, prodYearStrMonth));
                    objAP.April_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.April_Projected_SRECs__c = Math.Floor(comCalc);
                }
                else {
                    objAP.April_Production_Guarantee_kWh__c = 0;
                    objAP.April_SRECs_Carryover__c = 0;
                    objAP.April_Projected_SRECs__c = 0;                
                }
            }  
            
            if(objInstSys.Projected_May_Production_kWh__c != null) { 
                if(validateMonthDetail(5, prodyear, installYear, prodYearStrMonth) == true) {          
                    Decimal mayProProd = objInstSys.Projected_May_Production_kWh__c; 
                    Double comCalc = ((mayProProd/ 1000) + objAP.April_SRECs_Carryover__c);
                    
                    objAP.May_Production_Guarantee_kWh__c = mayProProd * 0.95 * getProjGrntFactor(getMnthFactor(5, prodyear, installYear, prodYearStrMonth));            
                    objAP.May_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.May_Projected_SRECs__c = Math.Floor(comCalc);
                }
                else {
                    objAP.May_Production_Guarantee_kWh__c = 0;
                    objAP.May_SRECs_Carryover__c = 0;
                    objAP.May_Projected_SRECs__c = 0;                
                }
            }    
            
            if(objInstSys .Projected_June_Production_kWh__c != null) {
                if(validateMonthDetail(6, prodyear, installYear, prodYearStrMonth) == true) {          
                    Decimal junProProd = objInstSys.Projected_June_Production_kWh__c;
                    Double comCalc = ((junProProd/ 1000) + objAP.May_SRECs_Carryover__c); 
                    
                    objAP.June_Production_Guarantee_kWh__c = junProProd * 0.95 * getProjGrntFactor(getMnthFactor(6, prodyear, installYear, prodYearStrMonth));            
                    objAP.June_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.June_Projected_SRECs__c = Math.Floor(comCalc);
                }
                else {
                    objAP.June_Production_Guarantee_kWh__c = 0;
                    objAP.June_SRECs_Carryover__c = 0;
                    objAP.June_Projected_SRECs__c = 0;                
                }
            } 
            
            if(objInstSys.Projected_July_Production_kWh__c != null) { 
                if(validateMonthDetail(7, prodyear, installYear, prodYearStrMonth) == true) {         
                    Decimal julProProd = objInstSys.Projected_July_Production_kWh__c;
                    Double comCalc = ((julProProd/ 1000) + objAP.June_SRECs_Carryover__c); 
                  
                    objAP.July_Production_Guarantee_kWh__c = julProProd * 0.95 * getProjGrntFactor(getMnthFactor(7, prodyear, installYear, prodYearStrMonth));
                    objAP.July_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.July_Projected_SRECs__c = Math.Floor(comCalc); 
                }
                else {
                    objAP.July_Production_Guarantee_kWh__c = 0;
                    objAP.July_SRECs_Carryover__c = 0;
                    objAP.July_Projected_SRECs__c = 0;
                }
            }  
            
            if(objInstSys.Projected_August_Production_kWh__c != null) {   
                if(validateMonthDetail(8, prodyear, installYear, prodYearStrMonth) == true) {    
                    Decimal augProProd = objInstSys.Projected_August_Production_kWh__c;            
                    Double comCalc = ((augProProd/ 1000) + objAP.July_SRECs_Carryover__c);              
                   
                    objAP.August_Production_Guarantee_kWh__c = augProProd * 0.95 * getProjGrntFactor(getMnthFactor(8, prodyear, installYear, prodYearStrMonth));            
                    objAP.August_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.August_Projected_SRECs__c = Math.Floor(comCalc);
                }
                else {
                    objAP.August_Production_Guarantee_kWh__c = 0;            
                    objAP.August_SRECs_Carryover__c = 0;
                    objAP.August_Projected_SRECs__c = 0;                
                }
            }      
            
            if(objInstSys.Projected_September_Production_kWh__c != null) { 
                if(validateMonthDetail(9, prodyear, installYear, prodYearStrMonth) == true) {       
                    Decimal sepProProd = objInstSys.Projected_September_Production_kWh__c;            
                    Double comCalc = ((sepProProd/ 1000) + objAP.August_SRECs_Carryover__c); 
                     
                    objAP.September_Production_Guarantee_kWh__c = sepProProd * 0.95 * getProjGrntFactor(getMnthFactor(9, prodyear, installYear, prodYearStrMonth));               
                    objAP.September_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.September_Projected_SRECs__c = Math.Floor(comCalc);
                }
                else {
                    objAP.September_Production_Guarantee_kWh__c = 0;
                    objAP.September_SRECs_Carryover__c = 0;
                    objAP.September_Projected_SRECs__c = 0;                }
            }      
            
            if(objInstSys.Projected_October_Production_kWh__c != null) {
                if(validateMonthDetail(10, prodyear, installYear, prodYearStrMonth) == true) {        
                    Decimal octProProd = objInstSys.Projected_October_Production_kWh__c; 
                    Double comCalc = ((octProProd/ 1000) + objAP.September_SRECs_Carryover__c ); 
                    
                    objAP.October_Production_Guarantee_kWh__c = octProProd * 0.95 * getProjGrntFactor(getMnthFactor(10, prodyear, installYear, prodYearStrMonth));            
                    objAP.October_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.October_Projected_SRECs__c = Math.Floor(comCalc);
                }
                else {
                    objAP.October_Production_Guarantee_kWh__c = 0;
                    objAP.October_SRECs_Carryover__c = 0;
                    objAP.October_Projected_SRECs__c = 0;
                }
            }      
            
            if(objInstSys.Projected_November_Production_kWh__c != null) { 
                if(validateMonthDetail(11, prodyear, installYear, prodYearStrMonth) == true) {       
                    Decimal novProProd = objInstSys.Projected_November_Production_kWh__c;            
                    Double comCalc = ((novProProd/ 1000) + objAP.October_SRECs_Carryover__c); 
                       
                    objAP.November_Production_Guarantee_kWh__c =  novProProd * 0.95 * getProjGrntFactor(getMnthFactor(11, prodyear, installYear, prodYearStrMonth));            
                    objAP.November_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.November_Projected_SRECs__c = Math.Floor(comCalc);
                }
                else {
                    objAP.November_Production_Guarantee_kWh__c = 0;
                    objAP.November_SRECs_Carryover__c = 0;
                    objAP.November_Projected_SRECs__c = 0;
                }
            }      
            
            
            if(objInstSys.Projected_December_Production_kWh__c != null) { 
                if(validateMonthDetail(12, prodyear, installYear, prodYearStrMonth) == true) {       
                    Decimal decProProd = objInstSys.Projected_December_Production_kWh__c;             
                    Double comCalc = ((decProProd/ 1000) + objAP.November_SRECs_Carryover__c );
                     
                    objAP.December_Production_Guarantee_kWh__c = decProProd * 0.95 * getProjGrntFactor(getMnthFactor(12, prodyear, installYear, prodYearStrMonth));            
                    objAP.December_SRECs_Carryover__c = (comCalc - Math.Floor(comCalc));
                    objAP.December_Projected_SRECs__c = Math.Floor(comCalc);
                }
                else {
                    objAP.December_Production_Guarantee_kWh__c = 0;
                    objAP.December_SRECs_Carryover__c = 0;
                    objAP.December_Projected_SRECs__c = 0;
                }
            }             
       }
              /* if( objAP.Annual_Production_Guarantee_To_Date_kWh__c != 0){
                   objAP.Annual_Guarantee_vs_Actual_Prod_To_Date__c =  (((objAP.Annual_Production_To_Date_kWh__c / objAP.Annual_Production_Guarantee_To_Date_kWh__c ))*100) ;                   
               }*/
               
               //apMap.put(objAP.id,objAP);
   }
   
   try{
       update listAP ;
   }catch(Exception e){}
   
   /* method for validating Anuual Production year */
   private Boolean validYear(Integer compyear, Decimal valyear) {
       Boolean status = true; 
       if((String.ValueOf(Integer.ValueOf(valyear)).length() != 4) || (compyear > Integer.ValueOf(valyear))) {
           status = false;    
       }       
       return status;   
   }
   
   /* method for getting month factor */
   private Integer getMnthFactor(Integer Month, Integer prodyear, Integer installYear, Decimal prodYearStrMonth){
       integer factor;
       if(Month < integer.valueOf(prodYearStrMonth)){
          factor = prodyear - installYear - 1;
       }
       else {
            factor = prodyear - installYear;       
       }
       factor = factor - 1;     
       return factor;
   } 
   
   
   
   /* method for getting projected guarantee factor */ 
   private Double getProjGrntFactor(integer mnthFactor){
      Double projGrntFactor = 0.0;
      if(mnthFactor > 0) {         
          Double grntfact = 0.995;
          for(Integer count = 1; count < mnthFactor; count++){   // loop moves 1 less than mnthFactor
              grntfact *= 0.995;
          }
          projGrntFactor = grntfact;
      }
      
      else if(mnthFactor < 0) {         
          Double grntfact = 0.995;
          for(integer count = 1; count < Math.Abs(mnthFactor); count++){   // loop moves 1 less than mnthFactor
              grntfact *= 0.995;
          }
          projGrntFactor = 1/grntfact;
      }
     else if(mnthFactor == 0) { 
         projGrntFactor = 1;
     
     }
      return projGrntFactor;
   }
   
   
   /* validate annual production month and year to calc values */
   private Boolean validateMonthDetail(Integer Month, Integer prodyear, Integer installYear, Decimal prodYearStrMonth){
       Boolean calstatus = false;
       if(prodyear == installYear){
           if(Month >= integer.valueOf(prodYearStrMonth))
               calstatus = true;    
       }
       else if(prodyear > installYear){
           calstatus = true;
       }
       return calstatus;    
   }
   
   /* calc previous year december srec carryover */
   private Double calcPreDecSrecCarryOver(Id sysid,integer predecyear){
       Double pred_dec_srec_carryover = 0.0;
       List<Installed_System__c> listsys = [select id, (select December_SRECs_Carryover__c From Annual_Production__r where Year__c = :predecyear limit 1) from Installed_System__c where id = :sysid];
       if(listsys != null && listsys.size() > 0) {
       
           if(listsys[0].Annual_Production__r != null && listsys[0].Annual_Production__r.size() > 0) {
               Annual_Production__c tempAP = listsys[0].Annual_Production__r[0];
               
               if(tempAP.December_SRECs_Carryover__c != null)
                   pred_dec_srec_carryover = tempAP.December_SRECs_Carryover__c;
           } 
       } 
       return pred_dec_srec_carryover;  
   }
     
}