/* FILE: c.cls
 * AUTHOR: Rohit Jain
 * DATE: March 14, 2013
 * PURPOSE: Test class for JournalLineItem_BIBU Trigger
 * MODIFICATION HISTORY:
 *
 */
 
@isTest(SeeAllData = true)
public class JournalLineItemTriggerTest{


    static testMethod void JournalLineItemLoad() {
    
         c2g__codaDimension1__c dim1 = new c2g__codaDimension1__c();
         dim1.c2g__ReportingCode__c = '300 MARYLAND TEST';
         dim1.Name = 'MARYLAND TEST';
         insert dim1;
         
         c2g__codaGeneralLedgerAccount__c gl = new c2g__codaGeneralLedgerAccount__c();
         gl.c2g__Type__c = 'Balance Sheet';
         gl.c2g__ReportingCode__c  = '88999';
         gl.Name = '88999 Test Account';
         insert gl;
         
         
         //c2g__codaPeriod__c period = [Select Id,c2g__EndDate__c From c2g__codaPeriod__c c Where c.name = '2013/003'];           
         c2g__codaCompany__c company = [Select Id From c2g__codaCompany__c c Limit 1];
         SCRB_SalesOrder__c so = [Select Id,Job_Id__c from SCRB_SalesOrder__c  Where Job_Id__c != null Limit 1];
         
         c2g__codaPeriod__c period =  [Select id,c2g__EndDate__c,c2g__Closed__c 
                                        from c2g__codaPeriod__c where c2g__Closed__c = false order by c2g__EndDate__c DESC limit 1 ];


         c2g__codaJournal__c journal = new c2g__codaJournal__c();
         journal.c2g__JournalDate__c = period.c2g__EndDate__c;
         journal.c2g__Period__c = period.Id;
         journal.c2g__Type__c = 'Manual Journal';
         journal.c2g__OwnerCompany__c = company.Id;         
         insert  journal;
         
         
         Test.startTest();
         c2g__codaJournalLineItem__c journalline = new c2g__codaJournalLineItem__c ();
         
         journalline.c2g__Value__c = 1;
         journalline.c2g__LineType__c = 'General Ledger Account';
         journalline.C2G__JOURNAL__C = journal.Id;
         journalline.C2G__DIMENSION1__C = dim1.Id;
         journalline.C2G__GENERALLEDGERACCOUNT__C = gl.Id; //'a1hC0000000PP45IAG';
         journalline.C2G__OWNERCOMPANY__C = company.Id;
         journalline.RS_PROJECT_ID__C = so.Job_Id__c ;
             
         insert journalline;
         
         
         
         c2g__codaJournalLineItem__c journalline2 = new c2g__codaJournalLineItem__c ();
         
         journalline2.c2g__Value__c = 1;
         journalline2.c2g__LineType__c = 'General Ledger Account';
         journalline2.C2G__JOURNAL__C = journal.Id;
         journalline2.C2G__DIMENSION1__C = dim1.Id;
         journalline2.C2G__GENERALLEDGERACCOUNT__C = gl.Id; //'a1hC0000000PP45IAG';
         journalline2.C2G__OWNERCOMPANY__C = company.Id;         
         journalline2.SALES_ORDER__C = so.Id;
         
         insert journalline2;
         
         Test.stopTest();
         
         c2g__codaJournalLineItem__c  j1 = [Select SALES_ORDER__C,RS_PROJECT_ID__C from  c2g__codaJournalLineItem__c Where Id = :journalline.Id ];
         c2g__codaJournalLineItem__c  j2 = [Select SALES_ORDER__C,RS_PROJECT_ID__C from  c2g__codaJournalLineItem__c Where Id = :journalline2.Id ];
         
         System.debug(j2);
         System.debug(journalline2);
         
         System.assertequals(j1.SALES_ORDER__C,so.Id );
         System.assertequals(j2.RS_PROJECT_ID__C,so.Job_Id__c );
         
         
            
    
    }
}