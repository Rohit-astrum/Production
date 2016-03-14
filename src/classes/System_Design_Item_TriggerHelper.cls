/* FILE: System_Design_Item_TriggerHelper.cls
 * AUTHOR: Pavitra Burla
 * DATE: June 25, 2015
 * PURPOSE: Helper for Trigger System_Design_Item_Trigger.
 * MODIFICATION HISTORY 
 */
public class System_Design_Item_TriggerHelper {
    
    public static String getActualProduction(String currentProduction,Double newQty,Double oldQty){
        List<String> productions = currentProduction.split(';');
        String ActualProduction = '';
        for(String prod: productions){
        	if(oldQty > 0)
        	{
            	ActualProduction += ((Decimal.valueOf(prod)/oldQty) * newQty).setScale(3) + ';';
            	System.debug('**((Double.valueOf(prod)/oldQty) * newQty).intValue()**' + (Double.valueOf(prod)/oldQty).intValue() + '*' + newQty);
            }
        }
        return ActualProduction;        
    }
}