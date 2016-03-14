public with sharing class CPQpreviewController {

    @RemoteAction
    public static List<Proposal__c> getProposalsList( String sdqId ) {
            
        //List<Proposal__c> ProIds = new List<Proposal__c>();

        //ProIds = [SELECT Id, Name, Current__c, LastModifiedDate
        //            FROM Proposal__c WHERE System_Design_Quote__c = :sdqId ORDER BY Name];
                        
        //return ProIds;
        return new List<Proposal__c>();
    }
    
    
    @RemoteAction
    public static Boolean insertAttachment(String imgData, String imgName, String parentID){
        //Boolean imgInserted = false;
        //if (imgData.length() > 0) {
        //    Attachment imgFile = new Attachment();

        //    // break string into parts
        //    Integer pos1 = imgData.indexOf(':');
        //    Integer pos2 = imgData.indexOf(';', pos1);
        //    Integer pos3 = imgData.indexOf(',', pos2);

        //    // decode the base64 encoded image
        //    imgFile.Body = EncodingUtil.base64Decode(imgData.substring(pos3+1));

        //    imgFile.ContentType = imgData.substring((pos1+1), pos2);
        //    imgFile.Name = imgName;
        //    imgFile.ParentId = parentID;

        //    Attachment[] existingAttchs = [SELECT ID FROM Attachment WHERE ParentID = :parentID AND Name = :imgName LIMIT 1];
        //    if (existingAttchs.isEmpty()){
        //        try {
        //            insert imgFile;
        //            imgInserted = true;
        //        } catch (Exception e) {
        //            System.debug('Error in insertAttachment() in CPQController on line ' + e.getLineNumber() + ': ' + e.getMessage());
        //        }
        //    }
        //}
        //return imgInserted;
        return false;
    }

}