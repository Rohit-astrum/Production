public class SalesOrderCancellationEmailController {
    public SalesOrderWrapper salesOrderInfo;
    public String salesorderId{get{return salesorderId;}set;}
    public SalesOrderWrapper getSalesOrderInfo(){
        List<SCRB_SalesOrder__c> salesorders =  [SELECT Name, AccountId__r.Name, Canceled_Comments__c FROM SCRB_SalesOrder__c WHERE Id =: salesorderId];
        List<PM_Project__c> pmprojects = new List<PM_Project__c>();
        pmprojects = [SELECT Id, Name FROM PM_Project__c WHERE Sales_Order__c = :salesorderId];
        if((!salesorders.isEmpty())){
            salesOrderInfo = new SalesOrderWrapper(salesorders[0],null);
        }
        if(!pmprojects.isEmpty()){
            salesOrderInfo.projectName = pmprojects[0].Name;
        }
        return salesOrderInfo;        
    }
    
    public class SalesOrderWrapper{
        
        private SCRB_SalesOrder__c salesOrder;
        
        public SalesOrderWrapper(SCRB_SalesOrder__c salesOrder, String projectName){
            this.salesOrder = salesOrder;
            this.projectName = projectName;
        }
        
        public String salesOrderNumber{get{return salesOrder.Name;}}
        public String accountName{get{return salesOrder.AccountId__r.Name;}}
        public String projectName{get;set;}
        public String comments{get{return salesOrder.Canceled_Comments__c;}}        
        
    }
}