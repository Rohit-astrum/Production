global with sharing class FFPostInvoice_2 implements rstk.FinancialForce_2.PostInvoice {
global void postInvoice(String invoiceId) {
	c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
	ref.Id = invoiceId;
	c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, ref);
}
global void bulkPostInvoices(List<String> invoiceIds) {
	List<c2g.CODAAPICommon.Reference> refs = new List<c2g.CODAAPICommon.Reference>();
   for (String invoiceId: invoiceIds) {
	  c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
	  ref.Id = invoiceId;
     refs.add(ref);
   }
	c2g.CODAAPISalesInvoice_7_0.BulkPostInvoice(null, refs);
}
}