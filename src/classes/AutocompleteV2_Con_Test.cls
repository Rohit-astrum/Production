/*

*/
@isTest
private class AutocompleteV2_Con_Test{
    static testMethod void test_AutocompleteV2_Con(){
        //create some test account
        List<Account> accountList = new List<Account>();
        for(Integer i =0 ; i < 200 ; i++){
            accountList.add(new Account(Name='Test'+i));
        }
        //insert test records
        insert accountList;
        Test.startTest();
            System.assertEquals(accountList.size(),AutoCompleteV2_Con.getData('Account','Name','Id','','T').size());
            System.assertEquals(1, AutoCompleteV2_Con.getData('Account','Name','Id','','Test111').size());
            System.assertEquals(0, AutoCompleteV2_Con.getData('Account','Name','Id','','xxxxxxx').size());
            AutoCompleteV2_Con controller = new AutoCompleteV2_Con ();
            controller.setTargetFieldVar(accountList[0].Id);
            System.assertEquals(accountList[0].Id,controller.getTargetFieldVar());
            controller.setCacheField(null);
        Test.stopTest();
        
    }
}