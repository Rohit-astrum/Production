/*

**/
public class AutoCompleteV2_Con {

    public String labelFieldVar{ get; set; }

    public String bcity = 'BillingCity';
    public String bstate = 'BillingState';

    public String valueFieldVar{ get; set; }
    public String sObjVal{get;set;}
    public Integer randomJsIden{get;set;}
    public Object cacheField{get;private set;} 
    
    private Object targetFieldVar;
    
    public AutoCompleteV2_Con(){
        randomJsIden = getRandomNumber(1000000);
        sObjVal='Account';
        labelFieldVar='Name';
        valueFieldVar='Id';
    }
    
    /*Dummy setter Method*/
    public void setCacheField(Object cacheField){}
    
    public void setTargetFieldVar(Object targetFieldVar){
        
        if(targetFieldVar != this.targetFieldVar){
            cacheField = getCacheFieldValue(targetFieldVar);
            this.targetFieldVar = targetFieldVar;
           
        }
        
    }
    
    public Object getTargetFieldVar(){
        return targetFieldVar;
    }
    
    private Object getCacheFieldValue(Object targetFieldVar){
        Object retVal = targetFieldVar;
        if(targetFieldVar!=null){
            for(sObject sObj : Database.query('SELECT '+valueFieldVar+','+labelFieldVar+', BillingCity, BillingState FROM '+sObjVal+' WHERE '+valueFieldVar+' =:targetFieldVar')){
                retVal = sObj.get(labelFieldVar);
                if(sObj.get(bcity) != null && sObj.get(bstate) != null )
                    retVal = retval +'('+ sObj.get(bcity) + ','+ sObj.get(bstate) + ')';
                break;
            }
        }
        
        return retVal;
    }

    
    /*
    *Random number generator to change the js function name if multiple components us
    ***/
    private Integer getRandomNumber(Integer size){
        Double d = Math.random() * size;
        return d.intValue();
    }
    
    /*
    *This method queries data according to the passed parameters
    ***/
    @RemoteAction
    public static List<Map<String,String>> getData(String sObjVal,String labelFieldVar,String valueFieldVar,String whereClauseVar,String param){      
        List<Map<String,String>> responses = new List<Map<String,String>>();
        String bcity = 'BillingCity';
        String bstate = 'BillingState';
        String label = '';
        param = String.escapeSingleQuotes(param);
        for( Sobject sObj : Database.query('SELECT '+valueFieldVar+','+labelFieldVar+' , BillingCity, BillingState FROM '+sObjVal+' WHERE '+labelFieldVar+' LIKE \'%'+param+'%\''+(String.isNotBlank(whereClauseVar) ? ' AND '+whereClauseVar : ''))){
            label = String.valueOf(sObj.get(labelFieldVar));
            if(sObj.get(bcity) != null && sObj.get(bstate) != null )
                label = label +'('+ String.valueOf(sObj.get(bcity)) + ','+ String.valueOf(sObj.get(bstate)) + ')';

            responses.add(new Map<String,String>{
            	'id' => String.valueOf(sObj.get(valueFieldVar)),
            	'text' => label
            });
        }
        return responses;
    }  
}