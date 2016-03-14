/* FILE: SystemDesignRollupCalcUtility.cls
 * AUTHOR: Rohit Jain
 * DATE: Sep 24, 2013
 * PURPOSE: Rollup field Calculation on System Design
 * MODIFICATION HISTORY
 *                    MK - 2014-03-13 - Improved the substring string method logic to allow rollups for fields with api names less than 20 characters.
 *
 */
public class SystemDesignRollupCalcUtility{
        
    static String SOQL_TEMPLATE = 'SELECT {0} FROM {1} {2} GROUP BY {3}';
    
    public static Sobject[] rollUp(Context ctx, Sobject[] detailRecordsFromTrigger) {
        
        // API name of the lookup field on detail sobject
        String lookUpFieldName = ctx.lookupField.getName();
                
        Set<Id> masterRecordIds = new Set<Id>(); 
        for (Sobject kid : detailRecordsFromTrigger) {
            masterRecordIds.add((Id)kid.get(lookUpFieldName));
        }
        return rollUp(ctx, masterRecordIds);
    }    
    
    public static Sobject[] rollUp(Context ctx,  Set<Id> masterIds) {
        // K: Id of master record
        // V: Empty sobject with ID field, this will be used for updating the masters
        Map<Id, Sobject> masterRecordsMap = new Map<Id, Sobject>(); 
        List<ID> sdIds = new List<ID>();
        for (Id mId : masterIds) {
            masterRecordsMap.put(mId, ctx.master.newSobject(mId));
            sdIds.add(mId);
        }
        
        // #0 token : SOQL projection
        String soqlProjection = ctx.lookupField.getName();
        // k: detail field name, v: master field name
        Map<String, String> detail2MasterFldMap = new Map<String, String>();
        for (RollupSummaryField rsf : ctx.fieldsToRoll) {
            // create aggreate projection with alias for easy fetching via AggregateResult class
            // i.e. SUM(Amount) Amount
            /* MK - needed to allow for smaller field names than 20 characters
            soqlProjection += ', ' + rsf.operation + '(' + rsf.detail + ') ' + rsf.detail.subString(1,20);
            detail2MasterFldMap.put(rsf.detail.subString(1,20), rsf.master);
            */
            
            //ALIAS LENGTH MAXIMUM IS 25 CHARACTERS, HERE IS THE ERROR: System.QueryException: alias is too long, maximum of 25 characters
            integer aliasLength = (rsf.detail.length()<25 ? rsf.detail.length() : 25); //grab no more than 25 characters to create easy alias
            string rsfAlias = rsf.detail.subString(0,aliasLength);                        
            soqlProjection += ', ' + rsf.operation + '(' + rsf.detail + ') ' + rsfAlias;
            detail2MasterFldMap.put(rsfAlias, rsf.master);
        }
        
        // #1 token for SOQL_TEMPLATE
        String detailTblName = ctx.detail.getDescribe().getName();
        String masterTblName = ctx.master.getDescribe().getName();
        
        // #2 Where clause
        String whereClause = 'WHERE ' + masterTblName +' IN :sdIds  ';
        if (ctx.detailWhereClause != null && ctx.detailWhereClause.trim().length() > 0) {
            whereClause = whereClause+ ' AND ' + ctx.detailWhereClause ;
        }
        
        // #3 Group by field
        String grpByFld = ctx.lookupField.getName();
        
        String soql = String.format(SOQL_TEMPLATE, new String[]{soqlProjection, detailTblName, whereClause, grpByFld});
        System.debug('********$$$$$ '+soql);
        // aggregated results 
        List<AggregateResult> results = Database.query(soql);
        
        for (AggregateResult res : results){
            Id masterRecId = (Id)res.get(grpByFld);
            Sobject masterObj = masterRecordsMap.get(masterRecId);
            if (masterObj == null) {
                System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
                continue;
            }
            
            for (String detailFld : detail2MasterFldMap.keySet()) {
                Object aggregatedDetailVal = res.get(detailFld);
                masterObj.put(detail2MasterFldMap.get(detailFld), aggregatedDetailVal);
            }           
        }
        
        return masterRecordsMap.values();   
    }
    
    public class BadRollUpSummaryStateException extends Exception {}
    
    public enum RollupOperation {
        Sum, Max, Min, Avg, Count
    }
       
    public class RollupSummaryField {
        //public Schema.Describefieldresult master;
        //public Schema.Describefieldresult detail;
        public String master;
        public String detail;
        public RollupOperation operation;
        
        // derived fields, kept like this to save script lines later, by saving the same
        // computations over and over again
        /*public boolean isMasterTypeNumber;
        public boolean isDetailTypeNumber;
        public boolean isMasterTypeDateOrTime;
        public boolean isDetailTypeDateOrTime; */
        
        public RollupSummaryField(String m, 
                                         String d, RollupOperation op) {
            this.master = m;
            this.detail = d;
            this.operation = op;
            // caching these derived attrbutes for once
            // as their is no view state involved here
            // and this caching will lead to saving in script lines later on
            //this.isMasterTypeNumber = isNumber(master.getType());
            //this.isDetailTypeNumber = isNumber(detail.getType());
            //this.isMasterTypeDateOrTime = isDateOrTime(master.getType());
            //this.isDetailTypeDateOrTime = isDateOrTime(detail.getType()); 
            // validate if field is good to work on later 
            //validate();
        }   
        
        /*void validate() {
            if (master == null || detail == null || operation == null) 
                throw new BadRollUpSummaryStateException('All of Master/Detail Describefieldresult and RollupOperation info is mandantory');

            if ( (!isMasterTypeDateOrTime && !isMasterTypeNumber) 
                  || (!isDetailTypeDateOrTime && !isDetailTypeNumber)) {
                    throw new BadRollUpSummaryStateException('Only Date/DateTime/Time/Numeric fields are allowed');
            }
            
            if (isMasterTypeDateOrTime && (RollupOperation.Sum == operation || RollupOperation.Avg == operation)) {
                throw new BadRollUpSummaryStateException('Sum/Avg doesnt looks like valid for dates ! Still want, then implement the IRollerCoaster yourself and change this class as required.');
            }
        }
        
        boolean isNumber (Schema.Displaytype dt) {
            return dt == Schema.Displaytype.Currency 
                   || dt == Schema.Displaytype.Integer
                   || dt == Schema.Displaytype.Percent
                   || dt == Schema.Displaytype.Double;
        }
        
        boolean isDateOrTime(Schema.DisplayType dt) {
            return dt == Schema.Displaytype.Time 
                   || dt == Schema.Displaytype.Date
                   || dt == Schema.Displaytype.Datetime;
        }
        */
    }
        
    public class Context {
        // Master Sobject Type
        public Schema.Sobjecttype master;
        // Child/Details Sobject Type
        public Schema.Sobjecttype detail;
        // Lookup field on Child/Detail Sobject
        public Schema.Describefieldresult lookupField;
        // various fields to rollup on
        public List<RollupSummaryField> fieldsToRoll;
        
        // Where clause or filters to apply while aggregating detail records
        public String detailWhereClause;            
        
        public Context(Schema.Sobjecttype m, Schema.Sobjecttype d, 
                           Schema.Describefieldresult lf) {
            this(m, d, lf, '');                             
        }
        
        public Context(Schema.Sobjecttype m, Schema.Sobjecttype d, 
                           Schema.Describefieldresult lf, String detailWhereClause) {
            this.master = m;
            this.detail = d;
            this.lookupField = lf;
            this.detailWhereClause = detailWhereClause;
            this.fieldsToRoll = new List<RollupSummaryField>();
        }
        
        /**
            Adds new rollup summary fields to the context
        */
        public void add(RollupSummaryField fld) {
            this.fieldsToRoll.add(fld);
        }
    }    
}