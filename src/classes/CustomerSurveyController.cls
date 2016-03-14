/* FILE: CustomerSurveyController.cls
 * AUTHOR: Rohit Jain
 * DATE: Oct 14, 2013
 * PURPOSE: Controller for Customer Survey
 * MODIFICATION HISTORY
 * 
 */
 
public class CustomerSurveyController{
      Customer_Survey__c survey ;
      public Boolean surveyCompleted {get; private set;}  
      public String ReceipientName{get; set;}     
      public String ReceipientEmail{get; set;}  
      
      public CustomerSurveyController () {
          String md5Code = ApexPages.currentPage().getParameters().get('Id'); 
          survey = [Select  Id,Name,Billing_Helpfullness__c,Consultant_Appearance__c,Consultant_Clarity__c,Consultant_Followup__c,
                            Consultant_Honesty__c,Consultant_Knowledge__c,Consultant_Responsiveness__c,Contact__c,
                            Ease_of_Payment__c,Electrician_Appearance__c,Electrician_Clarity__c,Electrician_Courtesy__c,
                            Electrician_Promptness__c,Electrician_Site_Cleanliness__c,Electrician_Workmanship__c,
                            Exceptional_Employee__c,Favorite_Experience__c,Financing_Coordination__c,HOA_Coordination__c,
                            Improvement_Comments__c,Install_Promptness__c,Install_Appearance__c,Install_Clarity__c,Install_Courtesy__c,
                            Install_Site_Cleanliness__c,Install_Workmanship__c,Least_Favorite_Experience__c,
                            Likelihood_of_Recommendation__c,Overall_Experience__c,PL_Appearance__c,PL_Clarity__c,
                            PL_Commitments__c,PL_Concern_for_Needs__c,PL_Courtesy__c,PL_Knowledge__c,PM_Project__c,
                            Process_Effectiveness__c,Process_Install_Speed__c,Process_Paperwork_Ease__c,
                            Process_Timeliness__c,Process_Usefulness__c,Process_Utility_Ease__c,Recommendation_Reason__c,
                            Sales_Proposal_Accuracy__c,Sales_Proposal_Completeness__c,Sales_Proposal_Timeliness__c,
                            Solar_System_Appearance__c,Solar_System_Design__c,Survey_Completed__c,Survey_Completed_By__c,
                            Survey_Completed_by_Email__c,Survey_Date_Completed__c,Survey_Date_Sent__c,Survey_URL__c,
                            Future_Reference_Agreement__c,Survey_Sent_To__c,Survey_Sent_To_Email__c
                      FROM Customer_Survey__c Where md5Code__c = :md5Code ];
                                         
          surveyCompleted = survey.Survey_Completed__c;  
          ReceipientName = survey.Survey_Sent_To__c;   
          ReceipientEmail = survey.Survey_Sent_To_Email__c;        
      }

      public PageReference submit() {
        Savepoint sp;
        try {
            grabPostData();           
            update survey;
            PageReference pr = Page.CustomerSurveyThankYou;
            pr.setRedirect(true);
            return pr;
        } catch (Exception e) {
            Database.rollback(sp);
            return null;
        }
    }
    
    //Grabs radio button values from post data (non-visualforce inputs)
    private void grabPostData() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        survey.Overall_Experience__c                = params.get('Question1');
        survey.Likelihood_of_Recommendation__c      = params.get('Question2');
        survey.Recommendation_Reason__c             = params.get('Question3');
        survey.Solar_System_Design__c            = params.get('Question4');
        survey.Sales_Proposal_Accuracy__c           = params.get('Question5');
        survey.Sales_Proposal_Completeness__c             = params.get('Question6');
        survey.Sales_Proposal_Timeliness__c             = params.get('Question7');
        survey.Consultant_Responsiveness__c             = params.get('Question8');
        survey.Consultant_Knowledge__c             = params.get('Question9');
        survey.Consultant_Appearance__c             = params.get('Question10');
        survey.Consultant_Honesty__c             = params.get('Question11');
        survey.Consultant_Clarity__c             = params.get('Question12');
        survey.Consultant_Followup__c             = params.get('Question13');
        survey.Process_Usefulness__c             = params.get('Question14');
        survey.Process_Paperwork_Ease__c             = params.get('Question15');
        survey.Process_Utility_Ease__c            = params.get('Question16');
        survey.Process_Timeliness__c             = params.get('Question17');
        survey.Process_Effectiveness__c            = params.get('Question18');
        survey.Process_Install_Speed__c             = params.get('Question19');
        survey.PL_Concern_for_Needs__c             = params.get('Question20');
        survey.PL_Knowledge__c                  = params.get('Question21');
        survey.PL_Appearance__c                 = params.get('Question22');
        survey.PL_Courtesy__c                   = params.get('Question23');
        survey.PL_Clarity__c                    = params.get('Question24');
        survey.PL_Commitments__c                   = params.get('Question25');
        survey.Install_Promptness__c                = params.get('Question26');
        survey.Install_Appearance__c            = params.get('Question27');
        survey.Install_Clarity__c             = params.get('Question28');
        survey.Install_Courtesy__c             = params.get('Question29');
        survey.Install_Workmanship__c             = params.get('Question30');
        survey.Install_Site_Cleanliness__c             = params.get('Question31');
        survey.Electrician_Promptness__c             = params.get('Question32');
        survey.Electrician_Appearance__c             = params.get('Question33');
        survey.Electrician_Clarity__c            = params.get('Question34');
        survey.Electrician_Courtesy__c             = params.get('Question35');
        survey.Electrician_Workmanship__c             = params.get('Question36');
        survey.Electrician_Site_Cleanliness__c             = params.get('Question37');
        survey.Solar_System_Appearance__c             = params.get('Question38');
        survey.Ease_of_Payment__c                   = params.get('Question39');
        survey.Billing_Helpfullness__c            = params.get('Question40');
        survey.Financing_Coordination__c             = params.get('Question41');
        survey.HOA_Coordination__c             = params.get('Question42');
        survey.Exceptional_Employee__c             = params.get('Question43');
        survey.Favorite_Experience__c            = params.get('Question44');
        survey.Least_Favorite_Experience__c            = params.get('Question45');
        survey.Improvement_Comments__c             = params.get('Question46');
        survey.Survey_Completed_By__c             = ReceipientName;// params.get('Question47');
        survey.Survey_Completed_by_Email__c             = ReceipientEmail; // params.get('Question48');
        survey.Future_Reference_Agreement__c             = params.get('Question49');
        survey.Survey_Completed__c                = true;
        survey.Survey_Date_Completed__c                    = System.Today();
               
        
    }


}