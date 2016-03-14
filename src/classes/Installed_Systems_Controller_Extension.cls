//07/12/2012 TCM - commenting out code - unused and not covered by any tests
public class Installed_Systems_Controller_Extension {


    List<Installed_System__c> listInstSys;
    List<ProdWrapper> objProdWrap = new List<ProdWrapper>();
    public ProdWrapper prodSummary{get;set;}
    /* all year changes */
    string[] strMonthArray = new String[]{'','January','February','March','April','May','June','July','August','September','October','November','December'};
    string[] strShortMonth = new String[]{'','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
    Date objDate = Date.today();
    /* all year changes */
    
    
    
     public Installed_Systems_Controller_Extension(ApexPages.StandardController contoller){
     	
     }
/* TCM
         prodSummary = new ProdWrapper();
         Installed_System__c objInstSys = (Installed_System__c )contoller.getRecord();
         
         listInstSys = [Select Installation_Year__c,Production_Year_Starting_Month__c,January_Solar_Access__c, February_Solar_Access__c, March_Solar_Access__c, 
                                   April_Solar_Access__c, May_Solar_Access__c, June_Solar_Access__c, 
                                   July_Solar_Access__c, August_Solar_Access__c, September_Solar_Access__c, 
                                   October_Solar_Access__c, November_Solar_Access__c, December_Solar_Access__c, 
                                   January_Daily_Peak_Sun_Hours__c, February_Daily_Peak_Sun_Hours__c, 
                                   March_Daily_Peak_Sun_Hours__c, April_Daily_Peak_Sun_Hours__c, 
                                   May_Daily_Peak_Sun_Hours__c, June_Daily_Peak_Sun_Hours__c, 
                                   July_Daily_Peak_Sun_Hours__c, August_Daily_Peak_Sun_Hours__c, 
                                   September_Daily_Peak_Sun_Hours__c, October_Daily_Peak_Sun_Hours__c, 
                                   November_Daily_Peak_Sun_Hours__c, December_Daily_Peak_Sun_Hours__c, 
                                   January_Monthly_Peak_Sun_Hours__c, February_Monthly_Peak_Sun_Hours__c, 
                                   March_Monthly_Peak_Sun_Hours__c, April_Monthly_Peak_Sun_Hours__c, 
                                   May_Monthly_Peak_Sun_Hours__c, June_Monthly_Peak_Sun_Hours__c, 
                                   July_Monthly_Peak_Sun_Hours__c, August_Monthly_Peak_Sun_Hours__c, 
                                   September_Monthly_Peak_Sun_Hours__c, October_Monthly_Peak_Sun_Hours__c,
                                   November_Monthly_Peak_Sun_Hours__c, December_Monthly_Peak_Sun_Hours__c, 
                                   January_Percent_Yearly_Sun_Hours__c, February_Percent_Yearly_Sun_Hours__c, 
                                   March_Percent_Yearly_Sun_Hours__c, April_Percent_Yearly_Sun_Hours__c, 
                                   May_Percent_Yearly_Sun_Hours__c, June_Percent_Yearly_Sun_Hours__c, 
                                   July_Percent_Yearly_Sun_Hours__c, August_Percent_Yearly_Sun_Hours__c, 
                                   September_Percent_Yearly_Sun_Hours__c, October_Percent_Yearly_Sun_Hours__c, 
                                   November_Percent_Yearly_Sun_Hours__c, December_Percent_Yearly_Sun_Hours__c, 
                                   Projected_January_Production_kWh__c, Projected_February_Production_kWh__c, 
                                   Projected_March_Production_kWh__c, Projected_April_Production_kWh__c, 
                                   Projected_May_Production_kWh__c, Projected_June_Production_kWh__c, 
                                   Projected_July_Production_kWh__c, Projected_August_Production_kWh__c, 
                                   Projected_September_Production_kWh__c, Projected_October_Production_kWh__c, 
                                   Projected_November_Production_kWh__c, Projected_December_Production_kWh__c,
                                   (Select Name,January_Production_Guarantee_kWh__c, February_Production_Guarantee_kWh__c, 
                                   March_Production_Guarantee_kWh__c, April_Production_Guarantee_kWh__c, 
                                   May_Production_Guarantee_kWh__c, June_Production_Guarantee_kWh__c, 
                                   July_Production_Guarantee_kWh__c, August_Production_Guarantee_kWh__c, 
                                   September_Production_Guarantee_kWh__c, October_Production_Guarantee_kWh__c, 
                                   November_Production_Guarantee_kWh__c, December_Production_Guarantee_kWh__c,
                                   January_Actual_Production_kWh__c, February_Actual_Production_kWh__c, 
                                   March_Actual_Production_kWh__c, April_Actual_Production_kWh__c, 
                                   May_Actual_Production_kWh__c, June_Actual_Production_kWh__c, July_Actual_Production_kWh__c, 
                                   August_Actual_Production_kWh__c, September_Actual_Production_kWh__c, 
                                   October_Actual_Production_kWh__c, November_Actual_Production_kWh__c, 
                                   December_Actual_Production_kWh__c,January_Projected_SRECs__c, February_Projected_SRECs__c, 
                                   March_Projected_SRECs__c, April_Projected_SRECs__c, May_Projected_SRECs__c, 
                                   June_Projected_SRECs__c, July_Projected_SRECs__c, August_Projected_SRECs__c, 
                                   September_Projected_SRECs__c, October_Projected_SRECs__c, November_Projected_SRECs__c, 
                                   December_Projected_SRECs__c,January_SRECs_Generated__c, February_SRECs_Generated__c, 
                                   March_SRECs_Generated__c, April_SRECs_Generated__c, May_SRECs_Generated__c, 
                                   June_SRECs_Generated__c, July_SRECs_Generated__c, August_SRECs_Generated__c, 
                                   September_SRECs_Generated__c, October_SRECs_Generated__c, November_SRECs_Generated__c, 
                                   December_SRECs_Generated__c, Annual_Production_Guarantee__c,Year__c from Annual_Production__r order by Year__c Desc),
                                   (Select Name, CreatedDate, LastModifiedDate, Installed_System__c, Panel_Manufacturer__c, 
                                   Panel_Type__c, Panel_Output_W__c, Panel_Serial_Number__c, Inverter_Type__c, 
                                   Inverter_Serial_Number__c From Installed_Panels__r)                              
                                   
                                   from Installed_System__c where id = :objInstSys.Id];

     }
*/
 
     public string getSysGrntURL() {
     	return null;
     }
/* TCM
             // variables start 
             string strGrntValues = '';
             string strActlValues = '';
             string montharray = '';
             string yeararray = '';
             string strresult = '';
             integer startmonth =0;
             integer endmonth =0;
             integer yearcount = 0;
             integer graphmax = 0;
             integer graphmin = 0;
             // variables end
           
             for(Installed_System__c item : listInstSys){
                 if(item .Annual_Production__r != null && item .Annual_Production__r.size() > 0){
                     for(Annual_Production__c objannl : item.Annual_Production__r ){
                         strresult = '';
                         if(objannl.Year__c != null && item.Installation_Year__c != null) {
                            
                             if((objannl.Year__c - item.Installation_Year__c) >0  && objannl.Year__c == objdate.year()) {
                                 
                                 endmonth = (objdate.Month()) - 1;
                                 startmonth = 1;
                                 strresult = calcGrntActlProd(endmonth ,startmonth,objannl);
                                
                             }
                             else if((objannl.Year__c - item.Installation_Year__c) >0) {
                                  endmonth = 12;
                                  startmonth = 1;
                                  strresult = calcGrntActlProd(endmonth ,startmonth,objannl);                             
                             }
                             else if((objannl.Year__c - item.Installation_Year__c) == 0){
                                  endmonth = 12;
                                  startmonth = Integer.valueOf(item.Production_Year_Starting_Month__c);
                                  strresult = calcGrntActlProd(endmonth ,startmonth,objannl);                             
                             }
                             
                             string[] strarray = strresult.split(';');
                             
                             if(strarray.size()>2){
                                 strGrntValues += strarray[0];
                                 strActlValues += strarray[1];  
                                 montharray += strarray[2]; 
                                 if(montharray.length() > 0){
                                     yeararray += '|'+ objannl.Year__c;  
                                     yearcount += 1;
                                 }                                 
                             }

                            
                         }
                         
                        
                     }     
                   
                 }
             }
             
             if(strGrntValues.length()>0){
                 strGrntValues = strGrntValues.substring(0,strGrntValues.length() - 1);
             }
             
             if(strActlValues.length()>0){
                 strActlValues = strActlValues.substring(0,strActlValues.length() - 1);
             }
             
             
             if(yearcount > 0)
             integer position = integer.valueOf((1000/yearcount)/2);
             
              graphmax = calcMax(strGrntValues,strActlValues);      
              if(graphmax <= 10)
                  graphmax = 10;           
              graphmin = integer.valueOf(graphmax/10);

             String chartURL = 'http://chart.apis.google.com/chart?chs=1000x300'
             + '&chtt=Guaranteed+vs+Actual+Production' 
             + '&chts=000000,12,c'
             + '&amp;chxt=x,y,x' 
             + '&chxp = 32,100,415,745'
             + '&amp;chxl=0:' + montharray + '|2:' + yeararray  
             + '&amp;chxr=1,0,'+ graphmax +',' + graphmin             // 0,0,'+ monthcount + ',1 , 1,0,25000,2500'        
             + '&amp;cht=lc'                
             + '&chd=t:' + strGrntValues + '|' + strActlValues
             + '&chds=0,'+ graphmax 
             + '&chco=009DDC,61AF3F'            
             + '&chdl=Guaranteed%20Production|Actual%20Production';
             return(chartURL);
         }
         
        private string calcGrntActlProd(integer endmonth, integer startmonth, Annual_Production__c objAP){
         
             string strgrntvalues = '';
             string stractlvalues = '';
             string strmonth = '';
             string comma = ',';
             string listspr = ';';
             string result ='';
             string valuesep = '|';
             for(Integer count = endmonth; count >= startmonth ; count--){
                 if(objAP.get(strMonthArray[count]+'_Production_Guarantee_kWh__c') != null)   
                      strgrntvalues += objAP.get(strMonthArray[count]+'_Production_Guarantee_kWh__c') + comma;               
                 else
                      strgrntvalues += 0 + comma;
                 if(objAP.get(strMonthArray[count]+ '_Actual_Production_kWh__c') != null)    
                      stractlvalues += objAP.get(strMonthArray[count]+ '_Actual_Production_kWh__c') + comma;
                 else
                      stractlvalues += 0 + comma;
                 
                 strmonth += valuesep + strShortMonth[count];          
           }
          result = strgrntvalues + listspr + stractlvalues + listspr + strmonth; 
          return result;
       }
*/        
   
    public string getSRECChartURL(){
    	return null;
    }
/* TCM
          // variables start
          string strProjValues = '';
          string strActlValues = '';
          string montharray = '';
          string yeararray = '';
          string strresult = '';
          integer startmonth =0;
          integer endmonth =0;
          integer yearcount = 0;
          integer graphmax = 0;
          integer graphmin = 0;
          // variables end 
       
         for(Installed_System__c item : listInstSys){
             if(item .Annual_Production__r != null && item .Annual_Production__r.size() > 0){
             
                 for(Annual_Production__c objannl : item.Annual_Production__r ){
                 
                         strresult = '';
                         if(objannl.Year__c != null && item.Installation_Year__c != null) {
                                if((objannl.Year__c - item.Installation_Year__c) >0  && objannl.Year__c == objdate.year()) {
                                     endmonth = (objdate.Month()) - 1;
                                     startmonth = 1;
                                     strresult = calcSRECs(endmonth ,startmonth,objannl);
                                    
                                 }
                                 else if((objannl.Year__c - item.Installation_Year__c) >0) {
                                      endmonth = 12;
                                      startmonth = 1;
                                      strresult = calcSRECs(endmonth ,startmonth,objannl);                             
                                 }
                                 else if((objannl.Year__c - item.Installation_Year__c) == 0){
                                      endmonth = 12;
                                      startmonth = Integer.valueOf(item.Production_Year_Starting_Month__c);
                                      strresult = calcSRECs(endmonth ,startmonth,objannl);                             
                                 }
                                 
                                 string[] strarray = strresult.split(';');
                                 
                                 if(strarray.size() > 2){
                                     strProjValues += strarray[0];
                                     strActlValues += strarray[1];  
                                     montharray += strarray[2]; 
                                     if(montharray.length() > 0){
                                         yeararray += '|'+ objannl.Year__c;  
                                         yearcount += 1;
                                     }                                 
                                 }
                   } 
                 }     
               
             }
         }
         
         if(strProjValues.length() > 0)
             strProjValues = strProjValues.substring(0,strProjValues.length() - 1);
             
         if(strActlValues.length()>0)
             strActlValues = strActlValues.substring(0,strActlValues.length()-1);
                 
         if(yearcount > 0)
             integer position = integer.valueOf((1000/yearcount)/2);
             
          graphmax = calcMax(strProjValues ,strActlValues);      
          if(graphmax <= 10)
                  graphmax = 10;           
          graphmin = integer.valueOf(graphmax/10);    
       
         String chartURL = 'http://chart.apis.google.com/chart?chs=1000x300'
         + '&amp;chtt=Expected+vs+Actual+SRECs'
         + '&amp;chts=000000,12,c' 
         + '&amp;chxt=x,y,x'
         + '&amp;cht=lc'  
         + '&amp;chxr=1,0,'+ graphmax +',' + graphmin                                               //10000,1000'                         
         + '&amp;chxl=0:' + montharray + '|2:' + yeararray 
         + '&amp;chma=10,10,50,10|80,20';         
         chartURL += '&chd=t:' + strProjValues + '|' + strActlValues ;
         chartURL += '&chds=0,' + graphmax;                                                                       //10000';
         chartURL += '&chco=009DDC,61AF3F';
         chartURL += '&chdl=Expected%20SRECs|Actual%20SRECs';

         return(chartURL);
   }
   
         
         
         private string calcSRECs(integer endmonth, integer startmonth, Annual_Production__c objAP){
         
             string strprojvalues = '';
             string stractlvalues = '';
             string strmonth = '';
             string comma = ',';
             string listspr = ';';
             string result ='';
             string valuesep = '|';
             
             for(Integer count = endmonth; count >= startmonth ; count--){
                 if(objAP.get(strMonthArray[count]+'_Projected_SRECs__c') != null)   
                      strprojvalues += objAP.get(strMonthArray[count]+'_Projected_SRECs__c') + comma;               
                 else
                      strprojvalues += 0 + comma;
                      
                 if(objAP.get(strMonthArray[count]+ '_SRECs_Generated__c') != null)    
                      stractlvalues += objAP.get(strMonthArray[count]+ '_SRECs_Generated__c') + comma;
                 else
                      stractlvalues += 0 + comma;
                 
                 strmonth += valuesep + strShortMonth[count];          
           }
           
          result = strprojvalues + listspr + stractlvalues + listspr + strmonth; 
          return result;
       }  
*/         
   
	public List<ProdWrapper> getProductionHistory() {
		return null;
	} 
/* TCM      
       List<Annual_Production__c> listAnnlProd = new List<Annual_Production__c>();
       Date objdate = Date.today();
       string prodyear = 'Production Year';
       integer count = 1;
       integer previouscount = 1;
       Map<string,Double> prodhistory = new Map<string,Double>();
       List<ProdWrapper> listwrapper = new List<ProdWrapper>();
       Double ftrgrnt = 0;
       
       for(Installed_System__c item : listInstSys){
            
            integer prodstartmonth =0;
            integer month = 0 ;
            
            if(item.Production_Year_Starting_Month__c != null)
                prodstartmonth = integer.valueOf(item.Production_Year_Starting_Month__c);               
            if(item.Annual_Production__r != null && item .Annual_Production__r.size() > 0){
               listAnnlProd = item.Annual_Production__r;      
            }         
          
            for(Annual_Production__c objannl : listAnnlProd){
                     
                if(objannl.Year__c !=null && item.Installation_Year__c != null){
                     integer year = integer.valueOf(objannl.Year__c);
                     if(((objannl.Year__c - item.Installation_Year__c) > 0) && (objannl.Year__c == objdate.year())) {
                         System.debug('%%%%%%%%%%%%% first sec');
                         //month = (objdate.Month() - 1); 
                         month = 2;
                         if(month < prodstartmonth) {
                             //listwrapper.addAll(calcProdHistory((prodstartmonth - 1),1,objannl,year)); 
                               listwrapper.addAll(calcProdHistory((month),1,objannl,year)); 
                         }
                         else if(month >= prodstartmonth) {
                             listwrapper.addAll(calcProdHistory(12,prodstartmonth,objannl,year ));
                             ftrgrnt = calcFutureGrnt(1,(prodstartmonth - 1), (integer.valueOf(objannl.Year__c) + 1), integer.valueOf(item.Installation_Year__c));
                             addRecordToList(listwrapper,ftrgrnt);
                             listwrapper.clear();
                             
                             listwrapper.addAll(calcProdHistory(prodstartmonth -1,1,objannl,year )); 
                         }
                            
                     }
                     
                     else if((objannl.Year__c - item.Installation_Year__c) > 0) {
                         System.debug('%%%%%%%%%%%%% second sec');
                         if(listwrapper.isEmpty()) {
                             ftrgrnt = calcFutureGrnt(1,prodstartmonth - 1,integer.valueOf(objannl.Year__c) + 1,integer.valueOf(item.Installation_Year__c));
                         }
                         else {
                             ftrgrnt = 0;
                         }                          
                         listwrapper.addAll(calcProdHistory(12,prodstartmonth,objannl,year));                         
                         addRecordToList(listwrapper,ftrgrnt);
                         listwrapper.clear();
                         
                         listwrapper.addAll(calcProdHistory((prodstartmonth - 1),1,objannl,year)); 
                     }
                     
                     else if((objannl.Year__c - item.Installation_Year__c) == 0) {
                         System.debug('%%%%%%%%%%%%% third sec' );
                         if(listwrapper.isEmpty()) {
                             ftrgrnt = calcFutureGrnt(1,(prodstartmonth - 1),(integer.valueOf(objannl.Year__c) + 1),integer.valueOf(item.Installation_Year__c));
                         }
                         else {
                             ftrgrnt = 0;
                         }                    
                         listwrapper.addAll(calcProdHistory(12,prodstartmonth,objannl,year));
                         addRecordToList(listwrapper,ftrgrnt);
                         listwrapper.clear();
                        
                     }           
                }                          
           } 
       }
         
       // calc summary table perf percentage    
       if(prodSummary.monthgrnt == 0)
           prodSummary.monthprodperf = 0;
       else 
           prodSummary.monthprodperf = ((prodSummary.monthactl/prodSummary.monthgrnt)*100 -100);
       // calc summary table perf percentage    
                         
       return  objProdWrap; 
   }  
   
   
   private void addRecordToList(List<ProdWrapper> listwrapper,Decimal ftrgrnt){
   
       Double totalgrnt = 0;
       Double totalmonthprojsrec = 0;
       Double totalmonthactlsrec = 0;
       Double totalmonthsrecdiff = 0; 
       Double totalmonthgrnt = 0;
       Double totalmonthactl = 0;
       Double totalproddiff = 0;
       
       for(ProdWrapper ele : listwrapper) {           
           totalgrnt = totalgrnt + ele.annlgrnt;    
       }
       totalgrnt += ftrgrnt;
       
       for(ProdWrapper ele : listwrapper) {
           ele.annlgrnt = totalgrnt;  
           objProdWrap.add(ele);
           
           // summary row changes 
           totalmonthprojsrec += ele.monthprojsrec;
           totalmonthactlsrec += ele.monthactlsrec;
           totalmonthsrecdiff += ele.monthsrecdiff;
           totalmonthgrnt += ele.monthgrnt;
           totalmonthactl += ele.monthactl; 
           totalproddiff += ele.monthproddiff;
       } 
       
       prodSummary.monthprojsrec += totalmonthprojsrec;
       prodSummary.monthactlsrec += totalmonthactlsrec;
       prodSummary.monthsrecdiff += totalmonthsrecdiff;
       prodSummary.monthgrnt += totalmonthgrnt;
       prodSummary.monthactl += totalmonthactl;
       prodSummary.monthproddiff += totalproddiff;
            // summary row changes
   }
                
   private Double calcFutureGrnt(integer startmonth,integer endmonth,integer apyear,integer installyear){
       Double totalgrnt = 0;
       for(integer count = startmonth; count <= endmonth; count ++){
       
       totalgrnt  +=  (Double)listInstSys[0].get('Projected_' + strMonthArray[count] + '_Production_kWh__c')* (0.95) * (getProjGrntFactor(getMnthFactor(1, apyear, installyear, endmonth)));
       
       }
       return totalgrnt;
   }
*/   
   
   public List<ProdWrapper> calcProdHistory(integer endmonth, integer startmonth, Annual_Production__c objAP , integer prodyear) {
   		return null;
   }
/* TCM   
       Decimal proddiff = 0;
       Decimal proddiffperc = 0;
       Decimal srecdiff =0;
       integer month;       
                                  
       Decimal annl_prod_grnt = 0;
       Decimal monthprodgrnt = 0;
       Decimal monthactlprod = 0;
       Decimal monthprojsrec = 0;
       Decimal monthsrecgen = 0;
       
       List<ProdWrapper> listwrapper = new List<ProdWrapper>();
   
       for(Integer count = endmonth; count >= startmonth ; count--){
           if(objAP.get(strMonthArray[count]+'_Actual_Production_kWh__c') != null)
               monthactlprod = (Double)objAP.get(strMonthArray[count]+'_Actual_Production_kWh__c');
               
           if(objAP.get(strMonthArray[count]+'_Production_Guarantee_kWh__c') != null)
               monthprodgrnt = (Double)objAP.get(strMonthArray[count]+'_Production_Guarantee_kWh__c');
               
           if(objAP.get(strMonthArray[count]+'_SRECs_Generated__c') != null)    
               monthsrecgen = (Double)objAP.get(strMonthArray[count]+'_SRECs_Generated__c');
             
           if(objAP.get(strMonthArray[count]+'_Projected_SRECs__c') != null)   
               monthprojsrec = (Double)objAP.get(strMonthArray[count]+'_Projected_SRECs__c');
                                          
           proddiff = monthactlprod  - monthprodgrnt;
           if (monthprodgrnt==0) {proddiffperc = 0;}
           else{proddiffperc = ((monthactlprod/monthprodgrnt)*100 -100);}                                     
           srecdiff = monthsrecgen - monthprojsrec ;
           
           annl_prod_grnt = monthprodgrnt;
            
           listwrapper.add(new ProdWrapper(String.valueOf(prodyear),strMonthArray[count],annl_prod_grnt, monthprodgrnt, monthactlprod ,proddiff ,proddiffperc ,monthprojsrec ,monthsrecgen, srecdiff ));
         
      }
   
      return listwrapper;
   
   }

*/
   
      // scaling chnages 
      public Integer calcMax(string strfirstset, string strsecondset){
      	return 0;
      }
/* TCM
        Double maxval = 0;
        List<String> listpoints =  strfirstset.split(',');
        for(string tempstr : listpoints) {
        if(Double.valueOf(tempstr) > maxval)
            maxval = Double.valueOf(tempstr);        
        } 
        
        listpoints = strsecondset.split(',');
        for(string tempstr : listpoints) {
            if(Double.valueOf(tempstr) > maxval)
            maxval = Double.valueOf(tempstr);
        
        }     
        
                 
        return(integer.valueOf(maxval) + 10);
    }
      //scaling chnages 
*/        

/* TCM    
  //method for getting month factor
   private Integer getMnthFactor(Integer Month, Integer prodyear, Integer installYear, Decimal prodYearStrMonth){
       integer factor;
       if(Month < Integer.ValueOf(prodYearStrMonth)){
          factor = prodyear - (installYear + 1);
       }
       else {
            factor = prodyear - installYear;       
       }
       factor = factor - 1;     
       return factor;
   }   
        
       // method for getting projected guarantee factor  
   private Double getProjGrntFactor(Integer mnthFactor){
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
          for(Integer count = 1; count < Math.Abs(mnthFactor); count++){   // loop moves 1 less than mnthFactor
              grntfact *= 0.995;
          }
          projGrntFactor = 1/grntfact;
      }
     else if(mnthFactor == 0) { 
         projGrntFactor = 1;
     
     }
      return projGrntFactor;
   }   
   
*/   
   
   public class ProdWrapper {
       public String year{get;private set;}
       public string month{get;private set;}
       public Decimal annlgrnt{get;private set;}
       public Decimal monthgrnt{get;private set;}
       public Decimal monthactl{get;private set;}
       public Decimal monthproddiff{get;private set;}
       public Decimal monthprodperf{get;private set;}
       public Decimal monthprojsrec{get;private set;}
       public Decimal monthactlsrec{get;private set;}
       public Decimal monthsrecdiff{get;private set;}
       
/* TCM
       public ProdWrapper(){
           annlgrnt = 0;    
           monthgrnt = 0;
           monthactl = 0;
           monthproddiff = 0 ;
           monthprodperf = 0;
           monthprojsrec = 0;
           monthactlsrec = 0;
           monthsrecdiff = 0;
       }
       
       public ProdWrapper(String prodyear,string prodmonth,Decimal annlprodgrnt,Decimal strmonthgrnt, Decimal strmonthactl, Decimal strmonthproddiff, Decimal strmonthprodperf, Decimal strmonthprojsrec, Decimal strmonthactlsrec, Decimal strmonthsrecdiff){
           year = prodyear;
           month = prodmonth;
           annlgrnt = annlprodgrnt.setscale(1);
           monthgrnt = strmonthgrnt.setscale(1);
           monthactl = strmonthactl.setscale(1);
           monthproddiff = strmonthproddiff.setscale(1);
           monthprodperf = strmonthprodperf.setscale(1);
           monthprojsrec = strmonthprojsrec.setscale(1);
           monthactlsrec = strmonthactlsrec.setscale(1);
           monthsrecdiff = strmonthsrecdiff.setscale(1);           
       }
*/       
   
   }

}