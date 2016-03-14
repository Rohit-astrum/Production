public with sharing class SightenAPIQuote extends SightenAPIEntity {

	public SightenAPIQuoteData data {get;set;}
	public SightenAPIQuoteRequest request {get;set;}
	
	public SightenAPIQuote(){
		data = new SightenAPIQuoteData();
		request = new SightenAPIQuoteRequest();
	}

	public override String buildRequestBody(){
		return request.toJsonString();
	}

	public static String getApiName(){
		return 'solar/quotegen/quote';
	}


	public class SightenAPIQuoteData extends SightenAPIEntity.SightenAPIEntityData {
		public Double avg_monthly_solar_bill {get;set;}
		public Double consumer_savings_pct {get;set;}
		public Double consumer_savings_usd {get;set;}
		public Integer contract_term {get;set;}
		public Double inipmt {get;set;}
		public Double install_cost_cash {get;set;}
		public SightenAPIRelation product {get;set;}
		public Double rate_contract {get;set;}
		public Double rate_esc_pct {get;set;}
		public String status {get;set;}
		//public SightenAPIRelation x_system {get;set;}
		public SightenAPISystem.SightenAPISystemData x_system {get;set;}
		//milestones	Collection	Milestones
		//proposals	Collection	proposals
		//tasks	Collection

		public SightenAPIQuoteData(){}
	}

	public class SightenAPIQuoteRequest extends SightenAPIEntity.SightenAPIEntityRequest {
		public Map<String, Object> process_args {get;set;}
		public Map<String, Object> response_args {get;set;}
		public SightenAPISystem.SightenAPISystemRequest x_system {get;set;}

		public SightenAPIQuoteRequest(){
			process_args = new Map<String, Object>();
			response_args = new Map<String, Object>();
			x_system = new SightenAPISystem.SightenAPISystemRequest();
		}

		public override Object toJsonObject(){
			if(process_args.size() > 0){
				this.addPostParameter('process_args', process_args);
			}
			if(response_args.size() > 0){
				this.addPostParameter('response_args', response_args);
			}
			if(!postParameters.containsKey('system')){
				this.addPostParameter('system', x_system.toJsonObject());
			}
			return postParameters;
		}
	}

	public with sharing class SightenAPIQuoteList extends SightenAPIEntity {
		public List<SightenAPIQuoteData> data {get;set;}
		
		public SightenAPIQuoteList(){
			data = new List<SightenAPIQuoteData>();
		}
	}
}