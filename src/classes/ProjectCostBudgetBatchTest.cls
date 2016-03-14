/* FILE: ProjectCostBudgetBatchTest.cls
 * AUTHOR: Pavitra Burla
 * DATE: Aug 27, 2015
 * PURPOSE: Test class for ProjectCostBudgetBatch.
 * MODIFICATION HISTORY
 */
@isTest(SeeAllData=true)
public class ProjectCostBudgetBatchTest {
    static testmethod void projectcostprocess(){
        String startDate = '2015-01-08T00:00:00Z';
        String endDate = '2015-08-28T00:00:00Z' ;
        String[] emailTostr = new List<String>{'pavitra.burla@directenergysolar.com'};
        
        ProjectCostBudgetBatch processProjBudgetbatch = new ProjectCostBudgetBatch(startDate,endDate,emailTostr);
        Id batchId = Database.executeBatch(processProjBudgetbatch, 1);
    }

}