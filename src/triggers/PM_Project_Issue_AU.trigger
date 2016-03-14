trigger PM_Project_Issue_AU on PM_Project_Issue__c (after update) {
  list<PM_Project_Issue_History__c> changes = new List<PM_Project_Issue_History__c>(); 

  for(PM_Project_Issue__c o : trigger.new)
  {
    if(o.Bin__C == 'Electrical Review' && o.Status__C != trigger.oldMap.get(o.Id).Status__c)
    {
      PM_Project_Issue_History__c  fh = new PM_Project_Issue_History__c();
      fh.PM_Project__c = o.PM_Project__c;
      fh.PM_Project_Issue__c = o.Id;
      fh.Status_Old_Value__c = Trigger.oldMap.get(o.Id).Status__C;
      fh.Status_New_Value__c = o.Status__C;
      changes.add(fh);
    }
  }
  insert changes;
}