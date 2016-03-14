public class CancelSalesOrderController {

     public SCRB_SalesOrder__c order {get; private set;}
   
     public class NotSubmittedException extends Exception {}
     public class OrderFailedException extends Exception {}

      //Contstructor: Corresponds with Page Load 
      public CancelSalesOrderController() {
               
          
           try{
               Id id = ApexPages.currentPage().getParameters().get('id');
             
        
               order = (id == null) ? new SCRB_SalesOrder__c() : 
               [SELECT Name, StatusCode__c, Failed__c FROM SCRB_SalesOrder__c WHERE id = :id];
            
            } catch (Exception e){

                 ApexPages.addMessages(e);
           }           

        
        
    }
    
     //saves order and child orders
    public PageReference OK() {
                                        
                   try 
                   {
                   
                   if (!(order.StatusCode__c=='Submitted' || order.StatusCode__c=='Sales Submitted')){
                        throw (new NotSubmittedException('Unable to cancel sales order: Only \'Submitted\' orders may be cancelled'));
                        }           
                        if (order.Failed__c){
                          throw (new OrderFailedException('Unable to cancel sales order: \'Failed\' sales orders may not be cancelled'));
                        }

                   
                       //update order status to Cancel Pending
                        order.StatusCode__c='Cancel Pending';
                        update order;    
                   }catch(System.exception e) 
                   {
                       ApexPages.addMessages(e);
                       return null;
                   }         
                             
                   //  After Save, navigate to the default view page:  
                    return (new PageReference('/a01/o'));

               }
 
    //Returns the user back to the opportunities page this was launched from
    public PageReference cancel(){
         return (new ApexPages.StandardController(order)).view();
    }

             
  }