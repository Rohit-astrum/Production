global with sharing class FFDiscardInvoice_2 implements rstk.FinancialForce_2.DiscardInvoice {
global void discardInvoice(String invoiceId, String reason) {
	c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
	ref.Id = invoiceId;
	c2g.CODAAPIInvoiceTypes_4_0.Invoice APIinv = Test.isRunningTest()?
	  new c2g.CODAAPIInvoiceTypes_4_0.Invoice():
	  c2g.CODAAPISalesInvoice_4_0.GetInvoice( null, ref );
   if (APIinv.LineItems != null && APIinv.LineItems.LineItemList != null) {
     APIinv.LineItems.LineItemList.clear();
   }
   APIinv.InvoiceStatus = c2g.CODAAPIInvoiceTypes_4_0.enumInvoiceStatus.Discarded;
   APIinv.DiscardReason = reason;
   APIinv.CustomFields = null;
   c2g.CODAAPISalesInvoice_4_0.UpdateInvoice( null, APIinv );
}
}