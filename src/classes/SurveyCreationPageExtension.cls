public with sharing class SurveyCreationPageExtension {

    private Survey__c survey;
    public String unzippedState {get;set;}
    public String recType {get;set;}
    public Boolean sunEye {get;set;}
    public Boolean Confirm {get;set;}   
    public Boolean validationError {get;set;}
    public Boolean surfacesExistedFlag {get;set;}
    private Map<String ,Physical_Surface__c > surfaceMap ;
    private Apexpages.StandardController controller; 
    public Integer rowNum{get;set;}

    
    public List<Install_Location__c> locations {get;set;}
    public List<Install_Location__c> unziplocations {get;set;}
    public List<Physical_Surface__c> unzipSurfaces {get;set;}   
    public List<Physical_Surface__c> surfacesExisted {get;set;}   

    
    public List<Install_Location__c> deleteLocations;
    private Boolean verifiedSunEye = true;

    public List<Physical_Surface__c> existingSurfaces {
        get {
            List<Physical_Surface__c> surfaces = [Select Id,Name,Property__c,Physical_Surface_Assigned_Letter__c,Surface_Type__c,Number_of_Stories__c
                                  ,Description__c,Surface_Tilt__c,Surface_Azimuth__c,Mounting_Plane_is_Not_Parallel__c,Mounting_Plane_Tilt__c,Mounting_Plane_Azimuth__c
                                  ,Trenching_Dist_to_Intercon_Pt_ft__c
                              from Physical_Surface__c 
                              Where Property__c = :survey.Property__c Order by Physical_Surface_Assigned_Letter__c]; 
            return  surfaces;

        }
    }
    
    /*
    private static String redirectUri { 
        get { return URL.getSalesForceBaseUrl().toExternalForm() + '/apex/SurveyCreationPage'; }
    }

    private static String clientId = 'b27bh696wb03q1kbwhn53mei5q01xw1c';
    private static String clientSecret = 'pduQq1bK9AXVFE7vPYDr35OUU2o0FKNm';
    public Boolean showAccessLink { get; set; }


    public BoxOAuth2Helper oauth {get;set;}

    public String accessToken {get;set;}
    */

    private static String[] months = new String[] {
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    };

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public SurveyCreationPageExtension(ApexPages.StandardController stdController) {
       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 
           // 'Unzip processing will start once the file is selected, please wait to be redirected to the results after this.'));
        this.controller = stdController;
        this.survey = (Survey__c)stdController.getRecord();   
        unziplocations = new List<Install_Location__c>();

        //oauth = new BoxOAuth2Helper(clientId, clientSecret, redirectUri);
        
        
        //oauth.ensureAccessToken();

        //accessToken = oauth.accessToken;

        

       
        
        String surveyId = ApexPages.currentPage().getParameters().get('id');
        if(surveyId != null && surveyId != '')
        {
            //MK - 2014-05-12 - Using temporary object instead of overwriting the one that is a byref to the standard controller record so that the changes made to Surveyor, Date Completed, Tree removal are actually upserted.
            //MK - survey = [Select RecordType.Name,Property__c from Survey__c Where id = :SurveyId];
            sunEye = true;            
            Survey__c surveyTemp = [Select RecordType.Name,Property__c from Survey__c Where id = :SurveyId];
            recType = surveyTemp.RecordType.Name;
            unziplocations = [Select Id,Name,Survey__c,Physical_Surface_letter__c,Physical_Surface__c,Pitch__c,Azimuth__c,Annual_Solar_Access__c
                                ,Jan_Solar_Access__c,Feb_Solar_Access__c,Mar_Solar_Access__c,Apr_Solar_Access__c,May_Solar_Access__c
                                ,Jun_Solar_Access__c,Jul_Solar_Access__c,Aug_Solar_Access__c,Sep_Solar_Access__c,Oct_Solar_Access__c
                                ,Nov_Solar_Access__c,Dec_Solar_Access__c,Location__c,Tree_Removal__c
                                 , TSRF__c, Property__c from Install_Location__c Where Survey__c = :surveyId]; 
            if(recType != 'Field Survey')
            {
                deleteLocations = new List<Install_Location__c>();
                verifiedSunEye = false;
            }
        }
        else{
            String recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
            if(recordTypeId != null && recordTypeId != '')
            {
                RecordType rt = [select id,name from RecordType Where Id = :recordTypeId];
                recType = rt.Name;
                if(recType != 'Field Survey')
                {
                    sunEye = true;  
                    verifiedSunEye = false;
                    Install_Location__c il = new Install_Location__c();
                    il.Location__c = 'S01';
                    unziplocations.add(il);  
                }
            }    
        }

        locations = new List<Install_Location__c>();  

        surfacesExisted = [Select Id,Name,Property__c,Physical_Surface_Assigned_Letter__c,Surface_Type__c,Number_of_Stories__c
                                  ,Description__c,Surface_Tilt__c,Surface_Azimuth__c,Mounting_Plane_is_Not_Parallel__c,Mounting_Plane_Tilt__c,Mounting_Plane_Azimuth__c
                              from Physical_Surface__c 
                              Where Property__c = :survey.Property__c Order by Physical_Surface_Assigned_Letter__c]; 
        if(surfacesExisted != null && !surfacesExisted.isEmpty())   
        {
            surfacesExistedFlag = true;
            //existingSurfaces = surfacesExisted;
        }
        
    }

    
    //checks if user authorized access
    /*
    public PageReference checkAccess() {

        System.debug('**checkAccess');

        String code = ApexPages.currentPage().getParameters().get('code');
        String state = ApexPages.currentPage().getParameters().get('state');
        
        Boolean hadRefreshToken = oauth.hasRefreshToken();

        System.debug('**checkAccess oauth.isAccessTokenValid() '+oauth.isAccessTokenValid());

        //if no access token or no longer valid, get new one
        if (!oauth.isAccessTokenValid()) {

            oauth.refreshAccessToken(code);
        }
        
        if (code != null) {
            //TODO: make this smarter
            PageReference pr = Page.SurveyCreationPage;
            pr.setRedirect(true);
            return pr;
        }

        System.debug('**checkAccess oauth.isAccessTokenValid() '+oauth.isAccessTokenValid());
        
        //check if new token valid
        
        if (oauth.isAccessTokenValid()) {
            showAccessLink = false;         
            accessToken = oauth.accessToken;  
        } else {
            showAccessLink = true;
        }
        
        return null;    
    }
    
    public PageReference requestBoxAccess() {
        return oauth.requestBoxAccess();
    }

    public PageReference revokeAccess() {
        //oauth.revokeAccess();
        //showAccessLink = true;
        return Page.SurveyCreationPage; 
    }
    */

    // Action Function method called by client code once all entries have been unzipped
    public PageReference unzipped()
    {
        // Redirect to ZipFile record        
        unziplocations = new List<Install_Location__c>();
        System.debug('#$'+unzippedState);
        JSONParser parser = JSON.createParser(unzippedState);
        while (parser.nextToken() != null) {
            // Start at the array of invoices.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next invoice statement object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire invoice object, including its array of line items.
                        Install_Location__c loc = (Install_Location__c)parser.readValueAs(Install_Location__c.class);      
                        unziplocations.add(loc);                 
                        // For debugging purposes, serialize again to verify what was parsed.  
                        // Skip the child start array and start object markers.
                        parser.skipChildren();
                    }
                }
            }
        }
        unziplocations.sort();
        //insert lcs;
        sunEye = true;
        return null;
        //return new PageReference('/' + lcs[0].Id);  
    }

    public PageReference save() {
        //Validation
        for(Physical_Surface__c ps : surfaceMap.values())
        {            
            if(ps.Mounting_Plane_is_Not_Parallel__c
                && (ps.Mounting_Plane_Tilt__c == null || ps.Mounting_Plane_Azimuth__c == null))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Mounting Tilt and Azimuth are required when the "Mounting Surface is Not Parallel" field is checked.'));
                return null;
            }   
            if(!ps.Mounting_Plane_is_Not_Parallel__c
                && (ps.Mounting_Plane_Tilt__c != null || ps.Mounting_Plane_Azimuth__c != null))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '"Mounting Surface is Not Parallel" field must be checked when entering any value into the Mounting Tilt and Azimuth. Either check the checkbox, or clear the values of these fields (highlight the number and delete).'));
                return null;
            }    
            
        } 





        upsert survey;
       
        for(Physical_Surface__c ps : surfaceMap.values())
        {            
            if(ps.Property__c == null)
            {
                ps.Property__c = Survey.Property__c;
            } 

            ps.Roof_Angle__c =  (ps.Surface_Type__c == 'Soil' ? 'Not Applicable' : ( ps.Surface_Tilt__c > 9 ? 'Pitched' : 'Flat Roof'));
            ps.Mounting_Allignment__c =  (ps.Surface_Type__c == 'Soil' ? 'Not Applicable' : ( ps.Mounting_Plane_is_Not_Parallel__c ? 'Tilted' : 'Flush'));            
            //ps.Survey__C = survey.Id;
            // Update the default Mounting Type
            try{
                System_Design_Product__c sdp = [Select Id, Applicable_Roof_Materials__c ,Applicable_Roof_Angle__c
                                                      ,Applicable_Alignment__c                                                                                                     
                                                  from System_Design_Product__c 
                                                 Where RecordType.DeveloperName  = 'Mounting' 
                                                   and Default_method__c = true
                                                   and Applicable_Roof_Materials__c includes (:ps.Surface_Type__c)
                                                   and Applicable_Roof_Angle__c includes (:ps.Roof_Angle__c)
                                                   and Applicable_Alignment__c includes (:ps.Mounting_Allignment__c)  limit 1];

                ps.Default_Mounting__c = sdp.id;                                   
            }
            catch(Exception e)
            {
                ps.Default_Mounting__c = null;
            }
        }
        upsert surfaceMap.values();

       
        for(Install_Location__c l : unziplocations)
        {
            if(l.Id == null)
            {
                l.Property__c = survey.Property__c;
                l.Survey__c = survey.Id;
                l.Verified_Single_SunEye_Data__c = verifiedSunEye;                
            }    
            l.Physical_Surface__c = surfaceMap.get(l.Physical_Surface_Letter__c).Id;
            
        }

        upsert unziplocations;
        if(deleteLocations != null && deleteLocations.size() > 0)
        {
            delete deleteLocations;
        }
        PageReference newPage = New PageReference('/'+ survey.Id);        
        newPage.setRedirect(true);
        return newPage;
    }

    public PageReference Confirm() {    
        validationError = false;    
        unzipSurfaces = new List<Physical_Surface__c>();
        surfaceMap = new Map<String, Physical_Surface__c>();
        Map<String, Physical_Surface__c> existingSurfaceMap = new Map<String, Physical_Surface__c>();
        
        System.debug('*surface Existed'+ surfacesExisted.size() + ' '+survey.Property__c + ' '+ survey);

        for(Physical_Surface__c ps : surfacesExisted)
        {
           existingSurfaceMap.put(ps.Physical_Surface_Assigned_Letter__c,ps);                    
        }

        for(Install_Location__c l : unziplocations)
        {            
            if(l.TSRF__c > 100)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'TSRF Cannot exceed 100%'));
                validationError = true;
                break;

            }
            if(surfaceMap.get(l.Physical_Surface_letter__c) != null)
            {
                Physical_Surface__c ps = surfaceMap.get(l.Physical_Surface_letter__c) ;   
                if(ps.Surface_Tilt__c != l.Pitch__c || ps.Surface_Azimuth__c != l.Azimuth__c )
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please make sure a Phyical Surface have same Tilt and Azimuth assigned to all locations.'));
                    validationError = true;
                    break;
                }                
            }  
            else
            {
                Physical_Surface__c ps ;
                if(existingSurfaceMap.get(l.Physical_Surface_letter__c) != null)
                {
                    ps = existingSurfaceMap.get(l.Physical_Surface_letter__c);
                    ps.Last_Surface_Azimuth__c = ps.Surface_Azimuth__c;
                    ps.Last_Surface_Tilt__c = ps.Surface_Tilt__c;
                }
                else
                {
                    ps = new Physical_Surface__c();
                }
               
                ps.Surface_Azimuth__c = l.Azimuth__c;
                ps.Surface_Tilt__c = l.Pitch__c;  
                ps.Physical_Surface_Assigned_Letter__c = l.Physical_Surface_Letter__c;              
                surfaceMap.put(l.Physical_Surface_letter__c, ps);    
            } 
        }
        unzipSurfaces = surfaceMap.Values();
        unzipSurfaces.sort();

        if(!validationError)
        {
            Confirm = true;           
        }    
        return null;
    }

    public PageReference Reassign() {    
        validationError = false;            
        Confirm = false;
        return null;
    }

    public void addNewLocation() {    
        integer size = unziplocations.size();
        Install_Location__c il = new Install_Location__c();
        if(size < 9)
        {
            size++;
            il.Location__c = 'S0'+ size;
        }  
        else
        {   
            size++;
            il.Location__c = 'S'+size;   
        }  
        unziplocations.add(il);  
        //unziplocations.add(new Install_Location__c());        
    }

    public void deleteLocation()
    {
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        if(unziplocations[rowNum].Id != null && deleteLocations != null)
        {
            deleteLocations.add(unziplocations[rowNum]);
        }        
        unziplocations.remove(rowNum);          
    }    

    /*
    public static String generateJSONContent() {
        // Create a JSONGenerator object.
        // Pass true to the constructor for pretty print formatting.
        JSONGenerator gen = JSON.createGenerator(true);
                
        // Write data to the JSON string.
        gen.writeStartObject();
            gen.writeStringField('name', 'pete_Survey_'+Math.random());
            gen.writeFieldName('parent');
            gen.writeStartObject();
                gen.writeStringField('id', '74568125');
            gen.writeEndObject();
        gen.writeEndObject();
        // Get the JSON string.
        String jsonRequest = gen.getAsString();
        
        System.debug(jsonRequest);
        return jsonRequest;
    }

    @RemoteAction
    public static String createBoxFolder(String oauth)
    {
        String jSonRequest = generateJSONContent();       
        System.debug('**jSonRequest '+jSonRequest);
        String jSonResponse;
        try{
          jSonResponse = BoxOAuth2Helper.createSurveyFolder(jSonRequest,oauth);
          System.debug('#Res '+jSonResponse);
        }
        catch(Exception e)
        {
           System.debug(e);
        }  
        return jSonResponse;
    }

    public static String generateUpdateFolderJSON() {
        // Create a JSONGenerator object.
        // Pass true to the constructor for pretty print formatting.
        JSONGenerator gen = JSON.createGenerator(true);
                
        // Write data to the JSON string.
        gen.writeStartObject();
            gen.writeStringField('name', 'ACCT-00044423_117 Birchwood Dr_a0JL0000001fhxn');
            //gen.writeStringField('tags', 'ACCT-00044423_117 Birchwood Dr_a0JL0000001fhxn');            
        gen.writeEndObject();
        // Get the JSON string.
        String jsonRequest = gen.getAsString();
        
        System.debug(jsonRequest);
        return jsonRequest;
    }

    @RemoteAction
    public static String updateBoxFolder(String oauth , String folder_id)
    {
        String jSonRequest = generateUpdateFolderJSON();       
        System.debug('**jSonRequest '+jSonRequest + ' folder_id'+folder_id);
        String jSonResponse;
        try{
          jSonResponse = BoxOAuth2Helper.updateSurveyFolder(jSonRequest,oauth,folder_id);
          System.debug('#Res '+jSonResponse);
        }
        catch(Exception e)
        {
           System.debug(e);
        }  
        return jSonResponse;
    }
    */

    @RemoteAction
    // JavaScript Remoting method called as each item is unzipped from the file
    public static List<Install_Location__c> receiveZipFileEntry(String filename, String path, String data, List<Install_Location__c> locations)
    {
                
        
        if(locations == null)
        {
            locations = new List<Install_Location__c>();
        }
        // Attach unzipped file
        if(path.contains('DailySolarAccess') && !path.contains('Windowed'))
        {
            
            Install_Location__c location = new Install_Location__c();            
                         
            
            String[] filelines = EncodingUtil.base64Decode(data).toString().split('\n');
            System.debug(filelines.size());
            //accstoupload = new List<Account>();
            for (Integer i=1;i<filelines.size();i++)
            {
                if(filelines[i].contains('Skyline:'))
                {
                      
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');   
                    System.debug(inputvalues[1]);             
                    location.Location__c = inputvalues[1].replaceAll('"','').replaceAll('ky','');
                    location.Name = location.Location__c; 

                    /*
                    //MK - 2014-05-12 - this field moved to the survey level for simplicity.
                    if(location.Location__c.endsWith('A') || location.Location__c.endsWith('a') || location.Location__c.endsWith('B') 
                        || location.Location__c.endsWith('b')  || location.Location__c.endsWith('C') || location.Location__c.endsWith('c'))
                    {
                        
                        location.Tree_Removal__c = true;
                    }
                    */

                }    
               
                if(filelines[i].contains('Panel Tilt:'))
                {
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');   
                    System.debug(inputvalues[1]);             
                    location.Pitch__c = Integer.ValueOf(inputvalues[1].trim());
                }    
                if(filelines[i].contains('Panel Azimuth:'))
                {
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');                
                    location.Azimuth__c = Integer.ValueOf(inputvalues[1].trim());
                }   
                
                if(filelines[i].contains('Monthly totals:'))
                {
                    System.debug('Monthly inputvalues - '+ filelines[i]); 
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');  
                    System.debug('inputvalues - '+inputvalues.size()); 
                    integer count = 0;
                    for(String input : inputvalues)             
                    {
                        if(count > 1)
                        {
                            System.debug(months[count-2]+ '_Solar_Access__c' +' '+input.trim()); 
                            location.put(months[count-2]+ '_Solar_Access__c' ,  Decimal.ValueOf(input.trim()));
                        }    
                        count++;
                    } 
                       
                }   
              
                if(filelines[i].contains('Annual:'))
                {
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');                
                    location.Annual_Solar_Access__c = Decimal.ValueOf(inputvalues[1].trim());
                }    
            } 

            locations.add(location);

            System.debug(locations);
    
            
        }    
        return locations;       
    }  
}