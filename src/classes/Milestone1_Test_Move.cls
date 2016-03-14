//TCM 08/23/2012 add start/stop test (too many soql queries)
@isTest(SeeAllData=true)
private class Milestone1_Test_Move { 

    static testMethod void testMilestoneMove() {

        final Integer NUMBER_OF_MILESTONES = 5;
        final Integer NUMBER_OF_TASKS = 20;
        final Integer NUMBER_OF_TIMES = 50;
        final Integer NUMBER_OF_EXPENSES = 50;
                       
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create two projects

        List<Milestone1_Project__c> projs = new list<Milestone1_Project__c>();

        Milestone1_Project__c proj = new Milestone1_Project__c();
        proj.Name = 'proj' + ''+ Datetime.now().getTime();
        SCRB_SalesOrder__c order = Milestone1_Test_Utility.CreateTestOrder();
        proj.Sales_Order__c = order.Id;
        projs.add(proj);
        
        Milestone1_Project__c proj2 = new Milestone1_Project__c();
        proj.Name = 'proj2' + ''+ Datetime.now().getTime();
        projs.add(proj2);
        //insert proj;
        insert projs;
        
        
        //create a couple of top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        System.debug('Before ms1');
        topMilestones.add(ms1);
        System.debug('After ms1 --> ' + ms1 );
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        System.debug('Before ms2');
        topMilestones.add(ms2);
        System.debug('After ms2 --> ' + ms2 );
        insert topMilestones;
        
        //create a few sub-milestones underneath ms1 and ms2
        List<Milestone1_Milestone__c> subMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms3 = Milestone1_Test_Utility.sampleMilestone(null, ms1.Id, 'ms3');
        System.debug('Before ms3');
        subMilestones.add(ms3);
        System.debug('After ms3 --> ' + ms3 );
        Milestone1_Milestone__c ms4 = Milestone1_Test_Utility.sampleMilestone(null, ms2.Id, 'ms4');
        System.debug('Before ms4');
        subMilestones.add(ms4);
        System.debug('After ms4 --> ' + ms4 );
        Milestone1_Milestone__c ms5 = Milestone1_Test_Utility.sampleMilestone(null, ms2.Id, 'ms5');
        System.debug('Before ms5');
        subMilestones.add(ms5);
        System.debug('After ms5 --> ' + ms5 );
        insert subMilestones;
        
        //collect all milestones that will be moved
        List<Milestone1_Milestone__c> milestonesToMove = new List<Milestone1_Milestone__c>();
        milestonesToMove.add(ms2);
        milestonesToMove.add(ms3);
        
        //create move page controller and call move action
        ApexPages.StandardSetController stc = new ApexPages.StandardSetController(milestonesToMove);
        stc.setSelected(milestonesToMove);
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        System.debug('Cont --> ' + cont );
        cont.dummyMS.Project__c = proj2.Id;
        System.debug('Project2 Id --> ' + proj2.Id );
        TriggerUtility.isMilestoneUpdate = true;
        
        Test.startTest();
        
        cont.moveMilestones();
        
        Test.stopTest();
        
        List<Milestone1_Milestone__c> milestones2 = [SELECT Id,
                                                            Name
                                                     FROM Milestone1_Milestone__c
                                                     WHERE Project__c = :proj2.Id
                                                    ];
        System.debug('milestones2 --> ' + milestones2 );
        System.debug('milestones2 --> ' + milestones2 );
        
        System.assertEquals(4, milestones2.size());
        
        milestones2[0].Project__c = proj.Id;
        Boolean errorOccured = false;
        try{
            update milestones2[0];
        } catch (DMLException e){
            errorOccured = true;
            //System.debug('err --> ' + e );
        
        } finally {
            System.debug('errorOccured --> ' + errorOccured );
            //System.assert(errorOccured);
        }
    }
    
    static testMethod void testMilestoneMoveDetail() {
        final Integer NUMBER_OF_MILESTONES = 1;
        final Integer NUMBER_OF_TASKS = 20;
        final Integer NUMBER_OF_TIMES = 50;
        final Integer NUMBER_OF_EXPENSES = 50;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        /*//create two projects
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        Milestone1_Project__c proj2 = Milestone1_Test_Utility.sampleProject('proj2');
        insert proj;
        insert proj2;
        */
        List<Milestone1_Project__c> projs = new list<Milestone1_Project__c>();

        Milestone1_Project__c proj = new Milestone1_Project__c();
        proj.Name = 'proj' + ''+ Datetime.now().getTime();
        SCRB_SalesOrder__c order = Milestone1_Test_Utility.CreateTestOrder();
        proj.Sales_Order__c = order.Id;
        projs.add(proj);
        
        Milestone1_Project__c proj2 = new Milestone1_Project__c();
        proj.Name = 'proj2' + ''+ Datetime.now().getTime();
        projs.add(proj2);
        //insert proj;
        insert projs;
        
        
        //create a couple of top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        topMilestones.add(ms1);
        insert topMilestones;
             
        //create move page controller and call move action
        ApexPages.StandardController stc = new ApexPages.StandardController(ms1);
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        cont.dummyMS.Project__c = proj2.Id;
        cont.moveMilestones();
        
        List<Milestone1_Milestone__c> milestones2 = [SELECT Id,
                                                            Name
                                                     FROM Milestone1_Milestone__c
                                                     WHERE Project__c = :proj2.Id
                                                    ];
        
        System.assertEquals(1, milestones2.size());
        
        milestones2[0].Project__c = proj.Id;
        Boolean errorOccured = false;
        try{
            update milestones2[0];
        } catch (DMLException e){
            errorOccured = true;
        } finally {
            System.assert(errorOccured);
        }
    }
    
    static testMethod void testTaskMoveFromList() {
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a couple of milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        milestones.add(ms1);
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        milestones.add(ms2);
        insert milestones;

        //create a couple of tasks
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        tasks.add(task1);
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        tasks.add(task2);
        insert tasks;
        
        Test.startTest();

        //create a time record for task1
        Milestone1_Time__c time1 = Milestone1_Test_Utility.sampleTime(task1.Id);
        insert time1;
        
        List<Milestone1_Task__c> tasksToMove = new List<Milestone1_Task__c>();
        tasksToMove.add(task1);
        
        //create move page controller and ensure that task1 can't be moved
        ApexPages.StandardSetController stc = new ApexPages.StandardSetController(tasksToMove);
        stc.setSelected(tasksToMove);
        Milestone1_Move_Task_Extension cont = new Milestone1_Move_Task_Extension(stc);
        System.assert(cont.hasChildren);
        
        tasksToMove.clear();
        tasksToMove.add(task2);
        
        //create a log record for task2
        Milestone1_Log__c log = new Milestone1_Log__c();
        log.Project__c = proj.Id;
        log.Project_Task__c = task2.Id;
        insert log;
        
        //recreate move page controller and call move action
        stc = new ApexPages.StandardSetController(tasksToMove);
        stc.setSelected(tasksToMove);
        cont = new Milestone1_Move_Task_Extension(stc);
        cont.dummyTask.Project_Milestone__c = ms2.Id;
        cont.moveTasks();
        
        //load clone back and make sure it exists
        List<Milestone1_Task__c> tasks2 = [SELECT Id,
                                                  Name
                                           FROM Milestone1_Task__c
                                           WHERE Project_Milestone__c = :ms2.Id
                                          ];
        
        System.assertEquals(1, tasks2.size());
        
        //load log back and make sure it points to clone,not original
        log = [SELECT Id FROM Milestone1_Log__c WHERE Project_Task__c = :tasks2[0].Id];
        System.assertNotEquals(null, log);
        
        Test.stopTest();
    }
    
    static testMethod void testTaskMove() {
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a couple of milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        milestones.add(ms1);
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        milestones.add(ms2);
        insert milestones;

        //create a couple of tasks
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        insert task1;
        
        Test.startTest();

        //create a time record for task1
        Milestone1_Time__c time1 = Milestone1_Test_Utility.sampleTime(task1.Id);
        insert time1;
        
        //create move page controller and ensure that task1 can't be moved
        ApexPages.StandardController stc = new ApexPages.StandardController(task1);
        Milestone1_Move_Task_Extension cont = new Milestone1_Move_Task_Extension(stc);
        System.assert(cont.hasChildren);
        
        //create a log record for task2
        Milestone1_Log__c log = new Milestone1_Log__c();
        log.Project__c = proj.Id;
        log.Project_Task__c = task1.Id;
        insert log;
        
        //recreate move page controller and call move action
        stc = new ApexPages.StandardController(task1);
        cont = new Milestone1_Move_Task_Extension(stc);
        cont.dummyTask.Project_Milestone__c = ms2.Id;
        cont.moveTasks();
        
        //load clone back and make sure it exists
        List<Milestone1_Task__c> tasks2 = [SELECT Id,
                                                  Name
                                           FROM Milestone1_Task__c
                                           WHERE Project_Milestone__c = :ms2.Id
                                          ];
        
        System.assertEquals(1, tasks2.size());
        
        //load log back and make sure it points to clone,not original
        log = [SELECT Id FROM Milestone1_Log__c WHERE Project_Task__c = :tasks2[0].Id];
        System.assertNotEquals(null, log);

        Test.stopTest();
        
    }
 
    static testmethod void testHighTopLevelMilestoneMove(){
        if (Milestone1_Test_Utility.performExtensiveTests() != true){
            System.debug('Skipped extensive Tests');
            return;
        }
        final Integer NUMBER_OF_MILESTONES = 400;

        Set<Id> srcMilestoneSet = new Set<Id>();
        Set<Id> dstMilestoneSet = new Set<Id>();

        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        // Create projects
        List<Milestone1_Project__c> pList = new List<Milestone1_Project__c>();
        pList.add( Milestone1_Test_Utility.sampleProject('Src Project') ); 
        pList.add( Milestone1_Test_Utility.sampleProject('Dst Project') ); 

        insert pList;
        
        // Create top-level milestones
        Milestone1_Project__c         srcProject = pList.get(0); 
        Milestone1_Project__c         dstProject = pList.get(1);
        List<Milestone1_Milestone__c> topList    = new List<Milestone1_Milestone__c>();

        for(Integer i = 0; i < NUMBER_OF_MILESTONES; i++){
            topList.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, null, 'Top Milestone' + i) );
        }
        
        try{
            insert topList;
            srcMilestoneSet.addAll( extractMilestoneIds(topList) ); 
        }
        catch(Exception e){
            system.assert(false, e.getMessage());
        }
        
        // Create one second level milestones on each top-level milestones
        List<Milestone1_Milestone__c> sndList = new List<Milestone1_Milestone__c>();

        for(Integer j = 0; j < NUMBER_OF_MILESTONES; j++){
            sndList.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, topList.get(j).Id, 'Milestone' + j) );
        }
        
        try{
            insert sndList;
        }
        catch(Exception e){
            system.assert(false, e.getMessage());
        }
        
        // Collect milestones and call move action
        ApexPages.StandardSetController stc = new ApexPages.StandardSetController(topList);
        stc.setSelected( topList );
        
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        cont.dummyMS.Project__c = dstProject.Id;
        
        Test.startTest();
        cont.moveMilestones();
        Test.stopTest();
        
        srcMilestoneSet.addAll( extractMilestoneIds(topList) );
        srcMilestoneSet.addAll( extractMilestoneIds(sndList) );
        dstMilestoneSet.addAll( extractMilestoneIds([SELECT Id FROM Milestone1_Milestone__c WHERE Project__c = :dstProject.Id]) );
        
        // Check if milestones were moved
        system.assert( srcMilestoneSet.containsAll(dstMilestoneSet) );
        system.assert( dstMilestoneSet.containsAll(srcMilestoneSet) );
    }
    
    static testmethod void testHighSecondLevelMilestoneMove(){
        if (Milestone1_Test_Utility.performExtensiveTests() != true){
            System.debug('Skipped extensive Tests');
            return;
        }
        final Integer NUMBER_OF_TOPLEVEL_MILESTONES    = 200;
        final Integer NUMBER_OF_SECONDLEVEL_MILESTONES = 110;

        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        Set<Id> srcMilestoneSet = new Set<Id>();
        Set<Id> dstMilestoneSet = new Set<Id>();

        // Create projects
        List<Milestone1_Project__c> pList = new List<Milestone1_Project__c>();
        pList.add( Milestone1_Test_Utility.sampleProject('Src Project') ); 
        pList.add( Milestone1_Test_Utility.sampleProject('Dst Project') ); 

        insert pList;
        
        // Create top-level milestones
        Milestone1_Project__c         srcProject = pList.get(0); 
        Milestone1_Project__c         dstProject = pList.get(1);
        List<Milestone1_Milestone__c> topList    = new List<Milestone1_Milestone__c>();

        for(Integer i = 0; i < NUMBER_OF_TOPLEVEL_MILESTONES; i++){
            topList.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, null, 'Top Milestone' + i) );
        }
        
        try{
            insert topList;
            srcMilestoneSet.addAll( extractMilestoneIds(topList) ); 
        }
        catch(Exception e){
            system.assert(false, e.getMessage());
        }
        
        // Create second level milestones on the first two top-level milestones
        List<Milestone1_Milestone__c> mList     = new List<Milestone1_Milestone__c>();
        List<Milestone1_Milestone__c> tmpList   = new List<Milestone1_Milestone__c>();
        List<Id>            milestonesWithTasks = new List<Id>();

        for(Integer j = 0; j < 2; j++){
            for(Integer k = 0; k < NUMBER_OF_SECONDLEVEL_MILESTONES; k++){
                tmpList.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, topList.get(j).Id, 'Milestone' + j) );
            }   

            try{
                insert tmpList;
                mList.addAll( tmpList );
                srcMilestoneSet.addAll( extractMilestoneIds(tmpList) ); 
                tmpList.clear();
            }
            catch(Exception e){
                system.assert(false, e.getMessage());
            }
        }
        
        
        // Create tasks in second level
        List<Milestone1_Task__c> tskList = new List<Milestone1_Task__c>();
        for(Integer l = 0; l < 2; l++){
            for(Integer m = 0; m < 2; m++){
                for(Integer n = 0; n < 35; n++){
                    tskList.add( Milestone1_Test_Utility.sampleTask( mList.get(l).Id ) );
                }

                try{
                    insert tskList;
                    tskList.clear();
                }
                catch(Exception e){
                    system.assert(false, e.getMessage());
                }
            }
            
            milestonesWithTasks.add( mList.get(l).Id );
        }
        
        // Collect milestones and call move action
        ApexPages.StandardSetController stc = new ApexPages.StandardSetController(topList);
        stc.setSelected(new List<Milestone1_Milestone__c>{ topList.get(0), topList.get(1)});
        
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        cont.dummyMS.Project__c = dstProject.Id;
        
        cont.moveMilestones();
        
        dstMilestoneSet.addAll( extractMilestoneIds([SELECT Id FROM Milestone1_Milestone__c WHERE Project__c = :dstProject.Id]) );
        
        // Check if milestones were moved
        system.assert( srcMilestoneSet.containsAll(dstMilestoneSet) );
        
        
        // Check if tasks were moved
        Integer dstTaskCount = [SELECT count() FROM Milestone1_Task__c WHERE Project_Milestone__c IN :milestonesWithTasks]; 
        system.assertEquals( 2 * 2 * 35, dstTaskCount );
    }

    static testMethod void testHighTaskMove(){
        if (Milestone1_Test_Utility.performExtensiveTests() != true){
            System.debug('Skipped extensive Tests');
            return;
        }
        Set<Id> srcMilestoneSet = new Set<Id>();
        Set<Id> dstMilestoneSet = new Set<Id>();

        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        // Create projects
        List<Milestone1_Project__c> pList = new List<Milestone1_Project__c>();
        pList.add( Milestone1_Test_Utility.sampleProject('Src Project') ); 
        pList.add( Milestone1_Test_Utility.sampleProject('Dst Project') ); 

        insert pList;
        
        // Create one top level milestone
        Milestone1_Project__c   srcProject   = pList.get(0); 
        Milestone1_Project__c   dstProject   = pList.get(1);
        Milestone1_Milestone__c srcTopMilestone = Milestone1_Test_Utility.sampleMilestone(srcProject.Id, null, 'Src Top Milestone');
        Milestone1_Milestone__c dstTopMilestone = Milestone1_Test_Utility.sampleMilestone(dstProject.Id, null, 'Dst Top Milestone');
 
        insert new List<Milestone1_Milestone__c>{ srcTopMilestone, dstTopMilestone};

        // Create two sub-milestones
        List<Milestone1_Milestone__c> subMilestones = new List<Milestone1_Milestone__c>();
        subMilestones.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, srcTopMilestone.Id, 'Second Milestone - 1') );
        subMilestones.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, srcTopMilestone.Id, 'Second Milestone - 2') );

        insert subMilestones;
        
        // Add tasks to each submilestone
        Milestone1_Task__c currentTask;
        List<Milestone1_Task__c>    tskList  = new List<Milestone1_Task__c>();
        List<Milestone1_Task__c>    allTasks = new List<Milestone1_Task__c>();
        
        for(Integer i = 0; i < subMilestones.size(); i++){
            for(Integer j = 0; j < 2; j++){
                for(Integer k = 0; k < 55; k++){
                    tskList.add( Milestone1_Test_Utility.sampleTask(subMilestones.get(i).Id) );
                }

                try{
                    insert tskList;
                }
                catch(Exception e){
                    system.assert(false, e.getMessage());
                }
                
                allTasks.addAll( tskList );
                tskList.clear();
            }
        }

            
        // Collect milestones and call move action
        ApexPages.StandardSetController stc = new ApexPages.StandardSetController(allTasks);
        stc.setSelected(allTasks);

        Milestone1_Move_Task_Extension cont = new Milestone1_Move_Task_Extension(stc);
        cont.dummyTask.Project_Milestone__c = dstTopMilestone.Id;

        cont.moveTasks();

        // Check if tasks were moved
        Integer srcTaskCount = [SELECT count() FROM Milestone1_Task__c WHERE Project_Milestone__c = :srcTopMilestone.Id]; 
        system.assertEquals( 0, srcTaskCount );

        Integer dstTaskCount = [SELECT count() FROM Milestone1_Task__c WHERE Project_Milestone__c = :dstTopMilestone.Id]; 
        system.assertEquals( 2 * 2 * 55, dstTaskCount );
    }
    
    static testmethod void testSimpleCloneAndMove() {
        
      Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
      // Project
      Milestone1_Project__c m = Milestone1_Test_Utility.sampleProjectActive('taskCloneTest');
      insert m;

      // Milestones
      Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(m);
      insert ms1;
      Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(m);
      insert ms2;

      Test.startTest();

      // Tasks
      Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(ms1);
      insert task1;
      
      System.assert(task1.Due_Date__c            != null);
      System.assert(task1.Start_Date__c          != null);
      System.assert(task1.Estimated_Expense__c   != null);
      System.assert(task1.Estimated_Hours__c     != null);
      System.assert(task1.Priority__c            != null);
      System.assert(task1.Class__c               != null);
      System.assert(task1.Blocked__c             != null);
      System.assert(task1.Last_Email_Received__c != null);

      // Validate basic clone
      Milestone1_Task__c cloneOfTask1 = task1.clone(false, false);
      System.assert(cloneOfTask1.Due_Date__c            == task1.Due_Date__c);
      System.assert(cloneOfTask1.Start_Date__c          == task1.Start_Date__c);
      System.assert(cloneOfTask1.Estimated_Expense__c   == task1.Estimated_Expense__c);
      System.assert(cloneOfTask1.Estimated_Hours__c     == task1.Estimated_Hours__c);
      System.assert(cloneOfTask1.Priority__c            == task1.Priority__c);
      System.assert(cloneOfTask1.Class__c               == task1.Class__c);
      System.assert(cloneOfTask1.Blocked__c             == task1.Blocked__c);
      System.assert(cloneOfTask1.Blocked_Reason__c      == task1.Blocked_Reason__c);
      System.assert(cloneOfTask1.Last_Email_Received__c == task1.Last_Email_Received__c);
      
      // Move
      ApexPages.StandardController   stc  = new ApexPages.StandardController(task1);
      Milestone1_Move_Task_Extension cont = new Milestone1_Move_Task_Extension(stc);
      cont.dummyTask.Project_Milestone__c = ms2.Id;
      cont.moveTasks();

      // Validate Move
      List<Milestone1_Task__c> tasks_moved = [SELECT Id,
                                                     Name,
                                                     Due_Date__c,
                                                     Start_Date__c,
                                                     Estimated_Expense__c,
                                                     Estimated_Hours__c,
                                                     Priority__c,
                                                     Class__c,
                                                     Blocked__c,
                                                     Blocked_Reason__c,
                                                     Last_Email_Received__c
                                                 FROM Milestone1_Task__c
                                                 WHERE Project_Milestone__c = :ms2.Id 
                                                      AND Name = :task1.Name];

        Test.stopTest();

//      System.assertEquals(1, tasks_moved.size());

//      System.assert(task1.Due_Date__c            == tasks_moved.get(0).Due_Date__c);
//      System.assert(task1.Start_Date__c          == tasks_moved.get(0).Start_Date__c);
//      System.assert(task1.Estimated_Expense__c   == tasks_moved.get(0).Estimated_Expense__c);
//      System.assert(task1.Estimated_Hours__c     == tasks_moved.get(0).Estimated_Hours__c);
//      System.assert(task1.Priority__c            == tasks_moved.get(0).Priority__c);
//      System.assert(task1.Class__c               == tasks_moved.get(0).Class__c);
//      System.assert(task1.Blocked__c             == tasks_moved.get(0).Blocked__c);
//      System.assert(task1.Blocked_Reason__c      == tasks_moved.get(0).Blocked_Reason__c);
//      System.assert(task1.Last_Email_Received__c == tasks_moved.get(0).Last_Email_Received__c);
    }
    
    /**
    * Extract the ids from a milestone list
    *
    * @param src Milestone list
    * @return Set of milestone ids
    */    

    static Set<Id> extractMilestoneIds(List<Milestone1_Milestone__c> src){
        Set<Id> res = new Set<Id>();
        
        for(Milestone1_Milestone__c m : src){ 
            res.add( m.Id ); 
        }
        
        return res;
    }
    

}