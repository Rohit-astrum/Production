@isTest(SeeAllData=false)
public with sharing class TestFinancialForce2 {
	
static testMethod void doTestPostInvoice() {
	Type tp = Type.forName('', 'FFPostInvoice_2');
		
	if (tp != null) {
		rstk.FinancialForce_2.PostInvoice p = (rstk.FinancialForce_2.PostInvoice) tp.newInstance();
		try {
			p.postInvoice(null);
		} catch (Exception e) {
		}
		try {
			p.bulkPostInvoices(new Id [] { null });
		} catch (Exception e) {
		}
	}
}
static testMethod void doTestDiscardInvoice() {
	Type tp = Type.forName('', 'FFDiscardInvoice_2');
		
	if (tp != null) {
		rstk.FinancialForce_2.DiscardInvoice d = (rstk.FinancialForce_2.DiscardInvoice) tp.newInstance();
		try {
			d.discardInvoice(null, 'a reason');
		} catch (Exception e) {
		}
	}
}
static testMethod void doTestPostCreditNote() {
	Type tp = Type.forName('', 'FFPostCreditNote_2');
		
	if (tp != null) {
		rstk.FinancialForce_2.PostCreditNote d = (rstk.FinancialForce_2.PostCreditNote) tp.newInstance();
		try {
			d.postCreditNote(null);
		} catch (Exception e) {
		}
	}
}
}