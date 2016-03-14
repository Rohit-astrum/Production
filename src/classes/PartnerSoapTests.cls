/* FILE: PartnerSoapTests.cls
 * AUTHOR: Rohit Jain
 * DATE: July 13, 2013
 * PURPOSE: Test Methods for NRG Integration
 * MODIFICATION HISTORY:
 *
 */
@isTest(SeeAllData=true)
public class PartnerSoapTests{
    
    static testMethod void PartnerSoapTest()    
    {
        partnerSoapSforceCom.getUserInfo_element u = new partnerSoapSforceCom.getUserInfo_element();
        partnerSoapSforceCom.LoginResult l = new partnerSoapSforceCom.LoginResult ();
        partnerSoapSforceCom.DescribeSoftphoneLayoutResult  d = new partnerSoapSforceCom.DescribeSoftphoneLayoutResult ();
        
        partnerSoapSforceCom.ProcessResult  u1 = new partnerSoapSforceCom.ProcessResult ();
        partnerSoapSforceCom.queryMore_element l1 = new partnerSoapSforceCom.queryMore_element ();
        partnerSoapSforceCom.DescribeSoftphoneLayoutItem  d1 = new partnerSoapSforceCom.DescribeSoftphoneLayoutItem ();
        
        partnerSoapSforceCom.logout_element u2 = new partnerSoapSforceCom.logout_element();
        partnerSoapSforceCom.DescribeSoftphoneLayoutSection l2 = new partnerSoapSforceCom.DescribeSoftphoneLayoutSection ();
        partnerSoapSforceCom.describeDataCategoryGroupsResponse_element  d2 = new partnerSoapSforceCom.describeDataCategoryGroupsResponse_element ();
        
        partnerSoapSforceCom.PerformQuickActionRequest  u3 = new partnerSoapSforceCom.PerformQuickActionRequest ();
        partnerSoapSforceCom.describeQuickActionsResponse_element l3 = new partnerSoapSforceCom.describeQuickActionsResponse_element ();
        partnerSoapSforceCom.PerformQuickActionResult  d3 = new partnerSoapSforceCom.PerformQuickActionResult ();
        
        partnerSoapSforceCom.ResetPasswordResult  u4 = new partnerSoapSforceCom.ResetPasswordResult();
        partnerSoapSforceCom.merge_element l4 = new partnerSoapSforceCom.merge_element();
        partnerSoapSforceCom.describeSoftphoneLayoutResponse_element d4 = new partnerSoapSforceCom.describeSoftphoneLayoutResponse_element();
        
        partnerSoapSforceCom.describeGlobal_element  u5 = new partnerSoapSforceCom.describeGlobal_element();
        partnerSoapSforceCom.RecordTypeInfo  l5 = new partnerSoapSforceCom.RecordTypeInfo();
        partnerSoapSforceCom.queryResponse_element d5 = new partnerSoapSforceCom.queryResponse_element();
        
        partnerSoapSforceCom.DescribeColumn u6 = new partnerSoapSforceCom.DescribeColumn ();
        partnerSoapSforceCom.emptyRecycleBinResponse_element l6 = new partnerSoapSforceCom.emptyRecycleBinResponse_element ();
        partnerSoapSforceCom.EmptyRecycleBinResult d6 = new partnerSoapSforceCom.EmptyRecycleBinResult ();
        
        partnerSoapSforceCom.loginResponse_element u7 = new partnerSoapSforceCom.loginResponse_element();
        partnerSoapSforceCom.describeDataCategoryGroupStructures_element l7 = new partnerSoapSforceCom.describeDataCategoryGroupStructures_element ();
        partnerSoapSforceCom.Email d7 = new partnerSoapSforceCom.Email ();
        
        partnerSoapSforceCom.describeSoftphoneLayout_element d8 = new partnerSoapSforceCom.describeSoftphoneLayout_element();
        partnerSoapSforceCom.getServerTimestamp_element  d9 = new partnerSoapSforceCom.getServerTimestamp_element ();
        partnerSoapSforceCom.GetUserInfoResult d10 = new partnerSoapSforceCom.GetUserInfoResult ();
        partnerSoapSforceCom.ChildRelationship d11 = new partnerSoapSforceCom.ChildRelationship ();
        partnerSoapSforceCom.process_element d12 = new partnerSoapSforceCom.process_element();
        partnerSoapSforceCom.DescribeLayoutComponent  d13 = new partnerSoapSforceCom.DescribeLayoutComponent ();
        partnerSoapSforceCom.QueryResult d14 = new partnerSoapSforceCom.QueryResult ();
        partnerSoapSforceCom.performQuickActions_element d15 = new partnerSoapSforceCom.performQuickActions_element();
        
        partnerSoapSforceCom.QueryOptions_element  d16 = new partnerSoapSforceCom.QueryOptions_element ();
        partnerSoapSforceCom.LeadConvertResult d17 = new partnerSoapSforceCom.LeadConvertResult ();
        partnerSoapSforceCom.CallOptions_element d18 = new partnerSoapSforceCom.CallOptions_element();
        partnerSoapSforceCom.sendEmailMessage_element d19 = new partnerSoapSforceCom.sendEmailMessage_element();
        partnerSoapSforceCom.processResponse_element  d20  = new partnerSoapSforceCom.processResponse_element ();
        partnerSoapSforceCom.MruHeader_element d21 = new partnerSoapSforceCom.MruHeader_element();
        partnerSoapSforceCom.describeAvailableQuickActions_element  d22 = new partnerSoapSforceCom.describeAvailableQuickActions_element ();
        partnerSoapSforceCom.DescribeSearchScopeOrderResult d23 = new partnerSoapSforceCom.DescribeSearchScopeOrderResult ();
        partnerSoapSforceCom.Soap d24 = new partnerSoapSforceCom.Soap ();
        partnerSoapSforceCom.ProcessWorkitemRequest d25 = new partnerSoapSforceCom.ProcessWorkitemRequest ();
        
        partnerSoapSforceCom.SessionHeader_element d26 = new partnerSoapSforceCom.SessionHeader_element();
        partnerSoapSforceCom.AllOrNoneHeader_element d27 = new partnerSoapSforceCom.AllOrNoneHeader_element();
        partnerSoapSforceCom.DescribeDataCategoryGroupStructureResult d28 = new partnerSoapSforceCom.DescribeDataCategoryGroupStructureResult ();
        partnerSoapSforceCom.DescribeSoftphoneLayoutInfoField d29 = new partnerSoapSforceCom.DescribeSoftphoneLayoutInfoField ();
        partnerSoapSforceCom.describeTabsResponse_element d30 = new partnerSoapSforceCom.describeTabsResponse_element();
        partnerSoapSforceCom.describeTabs_element d31 = new partnerSoapSforceCom.describeTabs_element ();
        partnerSoapSforceCom.describeGlobalResponse_element d32 = new partnerSoapSforceCom.describeGlobalResponse_element();
        partnerSoapSforceCom.DescribeLayoutButton d33 = new partnerSoapSforceCom.DescribeLayoutButton ();
        partnerSoapSforceCom.describeDataCategoryGroups_element d34 = new partnerSoapSforceCom.describeDataCategoryGroups_element();
        partnerSoapSforceCom.SendEmailError  d35 = new partnerSoapSforceCom.SendEmailError ();
        
        partnerSoapSforceCom.DescribeLayoutItem  d36 = new partnerSoapSforceCom.DescribeLayoutItem ();
        partnerSoapSforceCom.AllowFieldTruncationHeader_element d37 = new partnerSoapSforceCom.AllowFieldTruncationHeader_element ();
        partnerSoapSforceCom.getDeletedResponse_element d38 = new partnerSoapSforceCom.getDeletedResponse_element();
        partnerSoapSforceCom.SaveResult d39 = new partnerSoapSforceCom.SaveResult ();
        partnerSoapSforceCom.deleteResponse_element d40 = new partnerSoapSforceCom.deleteResponse_element();
        partnerSoapSforceCom.convertLead_element d41 = new partnerSoapSforceCom.convertLead_element();        
        partnerSoapSforceCom.describeSObjects_element  d42 = new partnerSoapSforceCom.describeSObjects_element ();
        partnerSoapSforceCom.describeDataCategoryGroupStructuresResponse_element d43 = new partnerSoapSforceCom.describeDataCategoryGroupStructuresResponse_element();
        partnerSoapSforceCom.emptyRecycleBin_element d44 = new partnerSoapSforceCom.emptyRecycleBin_element();
        partnerSoapSforceCom.update_element  d45 = new partnerSoapSforceCom.update_element ();
        partnerSoapSforceCom.DisableFeedTrackingHeader_element d46 = new partnerSoapSforceCom.DisableFeedTrackingHeader_element();
        partnerSoapSforceCom.search_element d47 = new partnerSoapSforceCom.search_element();
        partnerSoapSforceCom.searchResponse_element d48 = new partnerSoapSforceCom.searchResponse_element();
        partnerSoapSforceCom.MergeResult  d49 = new partnerSoapSforceCom.MergeResult ();
        
        partnerSoapSforceCom.describeQuickActions_element d50 = new partnerSoapSforceCom.describeQuickActions_element();
        partnerSoapSforceCom.DescribeAvailableQuickActionResult  d51 = new partnerSoapSforceCom.DescribeAvailableQuickActionResult ();
        partnerSoapSforceCom.RelatedListSort d52 = new partnerSoapSforceCom.RelatedListSort ();
        partnerSoapSforceCom.describeSObject_element d53 = new partnerSoapSforceCom.describeSObject_element();
        partnerSoapSforceCom.invalidateSessionsResponse_element d54 = new partnerSoapSforceCom.invalidateSessionsResponse_element();
        partnerSoapSforceCom.LoginScopeHeader_element  d55 = new partnerSoapSforceCom.LoginScopeHeader_element ();
        partnerSoapSforceCom.EmailFileAttachment  d56 = new partnerSoapSforceCom.EmailFileAttachment ();
        partnerSoapSforceCom.convertLeadResponse_element d57 = new partnerSoapSforceCom.convertLeadResponse_element ();
        partnerSoapSforceCom.delete_element d58 = new partnerSoapSforceCom.delete_element();
        partnerSoapSforceCom.sendEmail_element d59 = new partnerSoapSforceCom.sendEmail_element();
        
        partnerSoapSforceCom.DescribeQuickActionListResult d60 = new partnerSoapSforceCom.DescribeQuickActionListResult();
        partnerSoapSforceCom.DescribeLayoutButtonSection  d61 = new partnerSoapSforceCom.DescribeLayoutButtonSection ();
        partnerSoapSforceCom.updateResponse_element d62 = new partnerSoapSforceCom.updateResponse_element();
        partnerSoapSforceCom.queryAll_element d63 = new partnerSoapSforceCom.queryAll_element();
        partnerSoapSforceCom.retrieve_element  d64 = new partnerSoapSforceCom.retrieve_element ();
        partnerSoapSforceCom.describeSearchLayoutsResponse_element d65 = new partnerSoapSforceCom.describeSearchLayoutsResponse_element();
        partnerSoapSforceCom.GetServerTimestampResult  d66 = new partnerSoapSforceCom.GetServerTimestampResult ();
        partnerSoapSforceCom.RelatedList d67 = new partnerSoapSforceCom.RelatedList ();
        partnerSoapSforceCom.describeSearchScopeOrderResponse_element d68 = new partnerSoapSforceCom.describeSearchScopeOrderResponse_element();
        partnerSoapSforceCom.retrieveResponse_element d69 = new partnerSoapSforceCom.retrieveResponse_element();
        
        partnerSoapSforceCom.queryAllResponse_element d70 = new partnerSoapSforceCom.queryAllResponse_element();
        partnerSoapSforceCom.invalidateSessions_element d71 = new partnerSoapSforceCom.invalidateSessions_element();
        partnerSoapSforceCom.create_element d72 = new partnerSoapSforceCom.create_element();
        partnerSoapSforceCom.ProcessSubmitRequest  d73 = new partnerSoapSforceCom.ProcessSubmitRequest ();
        partnerSoapSforceCom.describeLayoutResponse_element  d74 = new partnerSoapSforceCom.describeLayoutResponse_element ();
        partnerSoapSforceCom.createResponse_element d75 = new partnerSoapSforceCom.createResponse_element();
        partnerSoapSforceCom.ProcessRequest  d76 = new partnerSoapSforceCom.ProcessRequest ();
        partnerSoapSforceCom.DescribeSearchLayoutResult  d77 = new partnerSoapSforceCom.DescribeSearchLayoutResult ();
        partnerSoapSforceCom.LeadConvert  d78 = new partnerSoapSforceCom.LeadConvert ();
        partnerSoapSforceCom.getServerTimestampResponse_element d79 = new partnerSoapSforceCom.getServerTimestampResponse_element();
        
        partnerSoapSforceCom.DescribeQuickActionListItemResult  d80 = new partnerSoapSforceCom.DescribeQuickActionListItemResult ();
        partnerSoapSforceCom.DeletedRecord  d81 = new partnerSoapSforceCom.DeletedRecord ();
        partnerSoapSforceCom.SearchResult  d82 = new partnerSoapSforceCom.SearchResult ();
        partnerSoapSforceCom.LocaleOptions_element  d83 = new partnerSoapSforceCom.LocaleOptions_element ();
        partnerSoapSforceCom.DescribeSoftphoneScreenPopOption  d84 = new partnerSoapSforceCom.DescribeSoftphoneScreenPopOption ();
        partnerSoapSforceCom.getUpdatedResponse_element d85 = new partnerSoapSforceCom.getUpdatedResponse_element();
        partnerSoapSforceCom.query_element d86 = new partnerSoapSforceCom.query_element();
        partnerSoapSforceCom.StreamingEnabledHeader_element  d87 = new partnerSoapSforceCom.StreamingEnabledHeader_element ();
        partnerSoapSforceCom.DescribeDataCategoryGroupResult d88 = new partnerSoapSforceCom.DescribeDataCategoryGroupResult ();
        partnerSoapSforceCom.DataCategoryGroupSobjectTypePair d89 = new partnerSoapSforceCom.DataCategoryGroupSobjectTypePair ();
        
         partnerSoapSforceCom.DescribeTab   d90 = new partnerSoapSforceCom.DescribeTab ();
         partnerSoapSforceCom.RelatedListColumn   d91 = new partnerSoapSforceCom.RelatedListColumn ();
         partnerSoapSforceCom.DescribeQuickActionResult   d92 = new partnerSoapSforceCom.DescribeQuickActionResult ();
         partnerSoapSforceCom.DescribeGlobalSObjectResult   d93 = new partnerSoapSforceCom.DescribeGlobalSObjectResult ();
         partnerSoapSforceCom.DescribeSObjectResult   d94 = new partnerSoapSforceCom.DescribeSObjectResult ();
         partnerSoapSforceCom.Field   d95 = new partnerSoapSforceCom.Field ();
         partnerSoapSforceCom.SingleEmailMessage   d96 = new partnerSoapSforceCom.SingleEmailMessage ();
         partnerSoapSforceCom.DescribeLayoutSection   d97 = new partnerSoapSforceCom.DescribeLayoutSection ();
         partnerSoapSforceCom.GetDeletedResult   d98 = new partnerSoapSforceCom.GetDeletedResult ();
         partnerSoapSforceCom.DataCategory   d99 = new partnerSoapSforceCom.DataCategory ();
         
         partnerSoapSforceCom.GetUpdatedResult e1 = new partnerSoapSforceCom.GetUpdatedResult ();
         partnerSoapSforceCom.DeleteResult e2 = new partnerSoapSforceCom.DeleteResult ();
         partnerSoapSforceCom.EmailHeader_element e3 = new partnerSoapSforceCom.EmailHeader_element ();
         partnerSoapSforceCom.queryMoreResponse_element e4 = new partnerSoapSforceCom.queryMoreResponse_element();
         partnerSoapSforceCom.upsert_element e5 = new partnerSoapSforceCom.upsert_element();
         partnerSoapSforceCom.performQuickActionsResponse_element e6 = new partnerSoapSforceCom.performQuickActionsResponse_element();
         partnerSoapSforceCom.OwnerChangeOptions_element e7 = new partnerSoapSforceCom.OwnerChangeOptions_element();
         partnerSoapSforceCom.DescribeLayoutRow  e8 = new partnerSoapSforceCom.DescribeLayoutRow ();
         partnerSoapSforceCom.describeAvailableQuickActionsResponse_element e9 = new partnerSoapSforceCom.describeAvailableQuickActionsResponse_element();
         partnerSoapSforceCom.UndeleteResult  e10 = new partnerSoapSforceCom.UndeleteResult ();
         
         
         partnerSoapSforceCom.DescribeSoftphoneLayoutCallType  e11 = new partnerSoapSforceCom.DescribeSoftphoneLayoutCallType ();
         partnerSoapSforceCom.setPassword_element e12 = new partnerSoapSforceCom.setPassword_element();
         partnerSoapSforceCom.resetPassword_element e13 = new partnerSoapSforceCom.resetPassword_element();
         partnerSoapSforceCom.Error  e14 = new partnerSoapSforceCom.Error ();
         partnerSoapSforceCom.SetPasswordResult  e15 = new partnerSoapSforceCom.SetPasswordResult ();
         partnerSoapSforceCom.DebuggingHeader_element e16 = new partnerSoapSforceCom.DebuggingHeader_element();
         partnerSoapSforceCom.sendEmailMessageResponse_element e17 = new partnerSoapSforceCom.sendEmailMessageResponse_element();
         partnerSoapSforceCom.resetPasswordResponse_element  e18 = new partnerSoapSforceCom.resetPasswordResponse_element ();
         partnerSoapSforceCom.MergeRequest  e19 = new partnerSoapSforceCom.MergeRequest ();
         partnerSoapSforceCom.describeSearchScopeOrder_element  e20 = new partnerSoapSforceCom.describeSearchScopeOrder_element ();
         
         partnerSoapSforceCom.logoutResponse_element  e21 = new partnerSoapSforceCom.logoutResponse_element ();
         partnerSoapSforceCom.InvalidateSessionsResult  e22 = new partnerSoapSforceCom.InvalidateSessionsResult ();
         partnerSoapSforceCom.describeLayout_element e23 = new partnerSoapSforceCom.describeLayout_element();
         partnerSoapSforceCom.DescribeLayout e24 = new partnerSoapSforceCom.DescribeLayout ();
         partnerSoapSforceCom.describeSObjectsResponse_element e25 = new partnerSoapSforceCom.describeSObjectsResponse_element();
         partnerSoapSforceCom.getUserInfoResponse_element e26 = new partnerSoapSforceCom.getUserInfoResponse_element();
         partnerSoapSforceCom.undeleteResponse_element e27 = new partnerSoapSforceCom.undeleteResponse_element();
         partnerSoapSforceCom.UpsertResult e28 = new partnerSoapSforceCom.UpsertResult ();
         partnerSoapSforceCom.setPasswordResponse_element e29 = new partnerSoapSforceCom.setPasswordResponse_element();
         
         
         partnerSoapSforceCom.login_element f1 = new partnerSoapSforceCom.login_element();
         partnerSoapSforceCom.MassEmailMessage f2 = new partnerSoapSforceCom.MassEmailMessage ();
         partnerSoapSforceCom.SendEmailResult f3 = new partnerSoapSforceCom.SendEmailResult ();
         partnerSoapSforceCom.mergeResponse_element f4 = new partnerSoapSforceCom.mergeResponse_element();
         partnerSoapSforceCom.PicklistForRecordType f5 = new partnerSoapSforceCom.PicklistForRecordType ();
         partnerSoapSforceCom.getUpdated_element f6 = new partnerSoapSforceCom.getUpdated_element();
         partnerSoapSforceCom.DescribeTabSetResult  f7 = new partnerSoapSforceCom.DescribeTabSetResult ();
         partnerSoapSforceCom.upsertResponse_element f8 = new partnerSoapSforceCom.upsertResponse_element();
         
         partnerSoapSforceCom.PicklistEntry f11 = new partnerSoapSforceCom.PicklistEntry ();
         partnerSoapSforceCom.UserTerritoryDeleteHeader_element f12 = new partnerSoapSforceCom.UserTerritoryDeleteHeader_element();
         partnerSoapSforceCom.DebuggingInfo_element f13 = new partnerSoapSforceCom.DebuggingInfo_element();
         partnerSoapSforceCom.SearchRecord  f14 = new partnerSoapSforceCom.SearchRecord ();
         partnerSoapSforceCom.describeSObjectResponse_element f15 = new partnerSoapSforceCom.describeSObjectResponse_element ();
         partnerSoapSforceCom.undelete_element f16 = new partnerSoapSforceCom.undelete_element();
         partnerSoapSforceCom.sendEmailResponse_element f17 = new partnerSoapSforceCom.sendEmailResponse_element();
         partnerSoapSforceCom.RecordTypeMapping  f18 = new partnerSoapSforceCom.RecordTypeMapping ();
         partnerSoapSforceCom.DescribeGlobalResult  f19 = new partnerSoapSforceCom.DescribeGlobalResult (); 
         
         partnerSoapSforceCom.DescribeLayoutResult f20 = new partnerSoapSforceCom.DescribeLayoutResult ();                 
          partnerSoapSforceCom.AssignmentRuleHeader_element f23= new partnerSoapSforceCom.AssignmentRuleHeader_element();                 
          partnerSoapSforceCom.describeSearchLayouts_element f22 = new partnerSoapSforceCom.describeSearchLayouts_element();                 
          partnerSoapSforceCom.PackageVersionHeader_element f21 = new partnerSoapSforceCom.PackageVersionHeader_element();                          
         
         sobjectPartnerSoapSforceCom.sObject_x sp = new sobjectPartnerSoapSforceCom.sObject_x();
         
    }
    
    static testMethod void soapSforceComSchemasClassAstrumleadTest()    
    {
        soapSforceComSchemasClassAstrumlead ss = new soapSforceComSchemasClassAstrumlead();
        soapSforceComSchemasClassAstrumlead.AllowFieldTruncationHeader_element  a1 = new  soapSforceComSchemasClassAstrumlead.AllowFieldTruncationHeader_element();
        soapSforceComSchemasClassAstrumlead.AstrumLead  a2 = new  soapSforceComSchemasClassAstrumlead.AstrumLead ();
        soapSforceComSchemasClassAstrumlead.CallOptions_element  a3 = new  soapSforceComSchemasClassAstrumlead.CallOptions_element ();
        soapSforceComSchemasClassAstrumlead.createLeadResponse_element a4= new  soapSforceComSchemasClassAstrumlead.createLeadResponse_element ();
        soapSforceComSchemasClassAstrumlead.SessionHeader_element a5 = new  soapSforceComSchemasClassAstrumlead.SessionHeader_element();
        soapSforceComSchemasClassAstrumlead.LogInfo  a6 = new  soapSforceComSchemasClassAstrumlead.LogInfo ();
        soapSforceComSchemasClassAstrumlead.DebuggingHeader_element a7 = new  soapSforceComSchemasClassAstrumlead.DebuggingHeader_element();
        soapSforceComSchemasClassAstrumlead.AstrumSystem a8  = new  soapSforceComSchemasClassAstrumlead.AstrumSystem ();
        soapSforceComSchemasClassAstrumlead.AstrumArray a9 = new  soapSforceComSchemasClassAstrumlead.AstrumArray ();
        soapSforceComSchemasClassAstrumlead.AstrumLeadIntegrationWS a10  = new  soapSforceComSchemasClassAstrumlead.AstrumLeadIntegrationWS ();
        soapSforceComSchemasClassAstrumlead.AstrumQuote a11 = new  soapSforceComSchemasClassAstrumlead.AstrumQuote ();
        soapSforceComSchemasClassAstrumlead.createLead_element a12 = new  soapSforceComSchemasClassAstrumlead.createLead_element ();
        soapSforceComSchemasClassAstrumlead.DebuggingInfo_element a13  = new  soapSforceComSchemasClassAstrumlead.DebuggingInfo_element();
        
    }
 }