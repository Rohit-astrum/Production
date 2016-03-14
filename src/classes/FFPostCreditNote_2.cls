global with sharing class FFPostCreditNote_2 implements rstk.FinancialForce_2.PostCreditNote {
global void postCreditNote(String creditNoteId) {
	c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
	ref.Id = creditNoteId;
	c2g.CODAAPISalesCreditNote_7_0.PostCreditNote(null, ref);
}
}