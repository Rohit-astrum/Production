public with sharing class CPQproposalChartTestController {

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

        //    try {
        //        insert imgFile;
        //        imgInserted = true;
        //        System.debug('Inserted chart image attachment ' + imgName + ' with data ' + imgData);
        //    } catch (Exception e) {
        //        System.debug('Error in insertAttachment() in CPQController on line ' + e.getLineNumber() + ': ' + e.getMessage());
        //    }
        //}
        //return imgInserted;
        return false;
    }
}