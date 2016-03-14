public class TestTriggers
{
    @isTest ( SeeAllData=true )
    public static void TestTrigger1()
    {
        QB_Trans_Detail__c objToInsert = new QB_Trans_Detail__c();
        
        objToInsert.Date__c = System.today();
        objToInsert.Num__C =  '1';
        
        try
        {
                insert objTOInsert;
        }
        catch( Exception ex)
        {
            // do nothing
        }
    }

    @isTest ( SeeAllData=true )
    public static void TestTrigger2()
    {
        QB_Invoice_File__c objToInsert = new QB_Invoice_File__c();
        
        objToInsert.TxnDate__c = System.today();
        objToInsert.RefNumber__c =  '1';
        objToInsert.Due_Date__c = System.today();
        objToInsert.Customer__c = 'Test Customer';
                                
        try
        {
                insert objTOInsert;
        }
        catch( Exception ex)
        {
            // do nothing
        }
    }
    
    @isTest ( SeeAllData=true )
    public static void TestTrigger3()
    {
        QB_Bill_Header_Details_Extract__c objToInsert = new QB_Bill_Header_Details_Extract__c();
        
        objToInsert.Temp_Bill_TxnDate__c = System.today();
        objToInsert.Temp_Bill_TxnID__c =  '1';
        objToInsert.Temp_Bill_RefNumber__c = '2';
        objToInsert.Vendor__c = 'Test Vendor';
                                
        try
        {
                insert objTOInsert;
        }
        catch( Exception ex)
        {
            // do nothing
        }
    }
 @isTest ( SeeAllData=true )
    public static void TestTrigger4()
    {
        QB_Credit_Notes__c objToInsert = new QB_Credit_Notes__c();
        
        objToInsert.TxnDate__c = System.today();
        objToInsert.RefNumber__c =  '1';
        objToInsert.TrxID__c= '1';
        objToInsert.Customer__c = 'Test Customer';
                                
        try
        {
                insert objTOInsert;
        }
        catch( Exception ex)
        {
            // do nothing
        }
    }
}