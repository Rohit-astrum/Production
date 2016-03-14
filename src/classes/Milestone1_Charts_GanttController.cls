public with sharing class Milestone1_Charts_GanttController {

    public String mytarget {get; set;}
    public String objectType {get;set;}
    public String startDateFieldName {get;set;}
    public String endDateFieldName {get;set;}
    public String idFieldName {get;set;}
    public String fullViewURL {get;set;}
 
    private String nameFieldName;
    private String completedFieldName;
    private String filterFieldName;
    private String sortFieldName;
    
    private List<Sobject> sobjectList;
    private static final String REGEXP_QUOTES    = '(?<!\\\\)"';
    
    public static final String COLOR_COMPLETE = '#F2F2F2';
    public static final String COLOR_LATE = '#DD2634';
    public static final String COLOR_FUTURE = '#57B6DD';
    public static final String COLOR_CURRENT = '#60B031';
    
    public String getProjectGanttJson() {
        
        String ret;
        initFieldNames();
        retrieveData();
        ret = toJSon();
        
        return ret;
    }
    
    /*
    * 	Initialize the variables depending on the object type possible values: 
    * 	Milestone1_Milestone__c and Milestone1_Task__c
    */
    private void initFieldNames(){
    	if(mytarget != null){
    		if(mytarget.startsWith(Schema.SObjectType.Milestone1_Project__c.getKeyPrefix())){
	    		startDateFieldName = 'Kickoff__c';
	    		endDateFieldName = 'Deadline__c';
	    		nameFieldName = 'NameClean__c';
	    		filterFieldName = 'Project__c';
	    		objectType = 'Milestone1_Milestone__c';
	    		sortFieldName = 'Kickoff__c';
	    	}else if(mytarget.startsWith(Schema.SObjectType.Milestone1_Milestone__c.getKeyPrefix())){
	    		startDateFieldName = 'Start_Date__c';
	    		endDateFieldName = 'Due_Date__c';
	    		nameFieldName = 'Name';
	    		filterFieldName = 'Project_Milestone__c';
	    		objectType = 'Milestone1_Task__c';
	    		sortFieldName = 'Start_Date__c';
	    	}
	    	idFieldName = 'Id';
	    	completedFieldName = 'Complete__c';	
    	}
    }
    
    /*
    * 	Retrieve the data doing a dynamic query by object type.
    */
    private void retrieveData(){
    	String query = 'Select '+idFieldName+','+startDateFieldName+','+endDateFieldName+','+nameFieldName+','+completedFieldName+
    				   ' from '+objectType+ ' where '+filterFieldName+'=\''+mytarget+'\' order by '+sortFieldName+' asc';
    	sobjectList = Database.query(query);
    }
    
    /**
    *	Generate the output in json format to be rendered in the jquery gantt.
    */
    private String toJSon(){
    	
    	String ret = 'var ganttData' +mytarget + ' = [{id: 1, name: "", series: [';
    	Boolean addComma=false,completed;
    	Date startDate,endDate;
    	String name,id;
        for (Sobject current : sobjectList){ 
            
            if(current.get(startDateFieldName) == null){
            	startDate = Date.today();
            }else{
            	startDate = Date.valueOf(current.get(startDateFieldName));
            }
            if(current.get(endDateFieldName) == null){
            	endDate = startDate;
            }else{
            	endDate = Date.valueOf(current.get(endDateFieldName));
            }
            completed = Boolean.valueOf(current.get(completedFieldName));
            name = escapeDoubleQuotes(String.valueOf(current.get(nameFieldName)));
            id = String.valueOf(current.get(idFieldName));
            if (addComma) { ret += ','; }
            
            String color=COLOR_CURRENT;
            
            if (completed) {
                color=COLOR_COMPLETE;
            } else if (endDate < Date.today()) {
                color=COLOR_LATE;
            } else if (startDate > Date.today()) {
                color=COLOR_FUTURE;
            }
            
            ret += 	'{'+
            		'id:"'+id+'",'+ 
            		'name: "'+name+'",'+
            		'start: new Date(' +startDate.year() +',' + (startDate.month()-1) +',' + startDate.day() +'),'+
             		'end: new Date(' +endDate.year() +',' + (endDate.month()-1) + ',' + endDate.day() +'), ' +
                	'color: "' + color + '"'+
                	'}';
                	
            addComma=true;
            
        }
        
        ret+=']}];';
        return ret;   	
    }
    
    private String escapeDoubleQuotes(String word){
    	return word.replaceAll(REGEXP_QUOTES,'\\\\"');
    }
    
    static testMethod void TestProjectJson() {
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        Milestone1_Milestone__c m1 = Milestone1_Test_Utility.sampleMilestone(p1);
        insert m1;
        
        Milestone1_Charts_GanttController cls = new Milestone1_Charts_GanttController();
        cls.mytarget = p1.id;

        String ret = cls.getProjectGanttJson();
        
        System.assert(ret.indexOf('ganttData') > -1);
        System.assert(ret.indexOf(m1.Name) > -1);            
        
        Milestone1_Milestone__c m2 = Milestone1_Test_Utility.sampleMilestone(p1);
        m2.Deadline__c = Date.today()-1;
        insert m2;    
        
        Milestone1_Milestone__c m3 = Milestone1_Test_Utility.sampleMilestone(p1);
        m3.Kickoff__c = Date.today()+1;
        insert m3;            
    
        ret = cls.getProjectGanttJson();
        
        System.assert(ret.indexOf(COLOR_LATE) > -1);
        System.assert(ret.indexOf(COLOR_FUTURE) > -1);
                
    }
    
    static testMethod void TestMilestoneJson() {
    	Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        
      	Milestone1_Milestone__c m2 = Milestone1_Test_Utility.sampleMilestone(p1);
        m2.Deadline__c = Date.today()-1;
        insert m2;   
    	
    	Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(m2.Id);
        insert t1;
        
        Milestone1_Charts_GanttController cls = new Milestone1_Charts_GanttController();
        cls.mytarget = m2.Id;
        String ret = cls.getProjectGanttJson();
        
        System.debug(LoggingLevel.Info, '12345:' + ret);
        
       // System.assert(ret.indexOf(COLOR_FUTURE) > -1);
    }
}