public with sharing class SystemDesignImageController {

	/*private final sObject mysObject;
    public Attachment imgFile { get; set;}
    public String imgURL { get; set; }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    // 
    public SystemDesignImageController() {
        // load the System Design sObject
        
        imgFile = new Attachment();
        imgURL = '';
    }

    public PageReference noop() {
        return null;
    }

    public PageReference uploadImg() {

        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Info, 'You should never see this message if things went well.' ) );

        System.debug('ImgURL length: ' + imgURL.length());
        
        if( imgURL.length() > 0 ) {
            String tmpstr = imgURL;

            // break string apart into parts
            Integer pos1 = tmpstr.indexOf(':');
            Integer pos2 = tmpstr.indexOf(';', pos1);
            Integer pos3 = tmpstr.indexOf(',', pos2);

            System.debug('Pos1: ' + pos1 + '  Pos2: ' + pos2 + '  Pos3: ' + pos3);

            // decode the base64 encoded imag
            imgFile.Body = EncodingUtil.base64Decode(tmpstr.substring(pos3+1));

            // set imgFile parts to proper values
            imgFile.ContentType = tmpstr.substring((pos1+1), pos2);
            imgFile.Name = 'sample_sketch.jpg';
            imgFile.ParentId = 'a0U19000000Cd5X';

            // insert imgFile
            try {
                insert imgFile;
            } catch (Exception e) {
                ApexPages.addMessages( e );
                return null;
            }

            System.debug('New Attachemnt Id: ' + imgFile.Id);
            // forward imgFile.Id to next page

            PageReference pgref = new PageReference('/apex/SystemDesignProposal?id=' + imgFile.Id);
            //PageReference pgref = new PageReference('/apex/SystemDesignProposal?id=HowNowBrownCow');
            return pgref;

        }
        return null;
    }*/
}