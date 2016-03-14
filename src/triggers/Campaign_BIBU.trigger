/* FILE: Campaign_BIBU.trigger
 * AUTHOR: Rohit Jain
 * DATE: Jan 07, 2013
 * PURPOSE: Derive the Campaign Name and Dimension 4 on Campaign Creation/Update
 * MODIFICATION HISTORY
 *
 */
trigger Campaign_BIBU on Campaign (Before Insert, Before Update) {
     
     // Variable Declarations
     datetime dt;
     String StartDate;
     String StartDateD;
     String Type;
     String Name;
     String DName;
     String City;
     String State;
     String CityD;
     Integer nameLen;
     c2g__codaDimension4__c dim4;
     
     List<c2g__codaDimension4__c> dim4List = new List<c2g__codaDimension4__c>();
     List<c2g__codaDimension4__c> dim4UpdList = new List<c2g__codaDimension4__c>();
     
     Map<String,c2g__codaDimension4__c> dim4Map = new Map<String,c2g__codaDimension4__c>();
     Map<Id,String> dim4UpdateMap = new Map<Id,String>();
     Map<Id,String> dim4UpdateNameMap = new Map<Id,String>();
     
     for (Campaign camp : trigger.new){
         // Do the processing only if StartDate and Type are not null
         if(camp.Startdate != null && camp.Type != null)
         {
             // Get the Datetime object to format Date
             dt = Datetime.newInstance(camp.StartDate, time.newInstance(0, 0, 0, 0));
             // Formating for Campaign Name/Dimension Name
             StartDate = dt.format('yyMMMdd'); 
             // Formatting for Dimension Reporting Code
             StartDateD = dt.format('yyMMdd');    
             
             // Derive Type based on campaign Type
             if( camp.Type == 'Trade Show' ) 
             {
                 Type = 'S';
                 Name = camp.Event_Name__c;
                 
             }   
             else if( camp.Type == 'Community Tabling') 
             {
                 Type = 'T';           
                 Name = camp.Event_Name__c;   
             }    
             else if( camp.Type == 'Community Seminar' ) 
             {
                 Type = 'P';
                 Name = camp.Event_Name__c; 
             }   
             else if( camp.Type == 'Other' ) 
             {
                 Type = 'O';
                 Name = camp.Event_Name__c;
                 
             }    
             else if( camp.Type == 'Solar Open House' ) 
             {
                 Type = 'H';
                 if(camp.Customer_Host_NA__c)
                     Name = camp.Canvass_Area_Name__c;
                 else
                 {
                     Account a = [Select Name from Account where Id= :camp.Customer_Host__c];
                     Name = a.Name;
                 }    
             }    
             else if( camp.Type == 'Canvassing' ) 
             {
                 Type = 'C';
                 if(camp.Customer_Host_NA__c)
                     Name = camp.Canvass_Area_Name__c;
                 else
                 {
                     Account a = [Select Name from Account where Id= :camp.Customer_Host__c];
                     Name = a.Name;
                 }    
             }    
             else if( camp.Type == 'Retail Tabling' ) 
             {
                 Type = 'R';    
                 Name = camp.Retailer_Name__c; 
             }
             else
             {
                 Type = 'M';    // For any misc Marketing campaigns
                 if(camp.Name != null)
                  Name = camp.Name;      
                 else
                  Name = 'MiscCamp';    
             
             }
                
             // Truncate Name         
             nameLen = Name.length();
             if(nameLen <= 8){
                Name = Name.substring(0, nameLen );
             } else {
               Name = Name.substring(0,8);
             }
             Name = Name.trim();  
             
             // Truncate City Name
             if( camp.City__c != null ) 
             {
                 City = camp.City__c;
                 nameLen = City.length();
                 if(nameLen <= 4){
                     City = City.substring(0, nameLen );
                 } else {
                   City = City.substring(0,4);
                 }
                 City = City.trim();  
                 // City for Dimension Reporting Code
                 CityD= City.substring(0,3);
              }
             else
             {
               City = 'Misc';
               CityD= City.substring(0,3);
             } 
             
             if(camp.State__c != null)
             {
                 State = camp.State__c;
             }
             else
                 State = 'XX';
             
             camp.Name = StartDate+'-'+Type+'-'+State+'-'+Name+'-'+ City;
             
             // Dimension Reporting Code format T YYMMDD ST NameName Cit
             DName = Type+'-'+StartDateD+'-'+State+'-'+Name+'-'+ CityD;
             
             // If Insert create Dimension 4 Object
             if(trigger.isInsert)
             {
                 camp.isActive = true; // Make campaign Active on Insert. 
                 dim4 = new c2g__codaDimension4__c();
                 if (DName != null && DName.length() > 24)
                     dim4.c2g__ReportingCode__c = DName.substring(0,24);
                 else
                     dim4.c2g__ReportingCode__c = DName;
                          
                 dim4.Name = camp.Name;
                 
                 dim4List.add(dim4);
                 dim4Map.put(camp.Name,dim4);             
             } 
             
             // If Update get list Dim4 Instances
             if(trigger.isUpdate)
             {
                 if(camp.Dimension_4__c != null)
                 {
                     dim4UpdateMap.put(camp.Dimension_4__c,DName); // Reporting Code Map
                     dim4UpdateNameMap.put(camp.Dimension_4__c,camp.Name); // Name Map
                 }    
                 else
                 {
                     dim4 = new c2g__codaDimension4__c();
                     if (DName != null && DName.length() > 24)
                         dim4.c2g__ReportingCode__c = DName.substring(0,24);
                     else
                         dim4.c2g__ReportingCode__c = DName;
                          
                     dim4.Name = camp.Name;
                     
                     dim4List.add(dim4);
                     dim4Map.put(camp.Name,dim4);               
                 
                 }
              }  
        } // If Condition          
     } // END for Loop
     
     if(dim4List.size() > 0 )
     {
          insert dim4List;
          // Associate Dimension 4 to Campaign    
          for (Campaign camp : trigger.new){
              camp.Dimension_4__c = dim4Map.get(camp.Name).Id;
          }
     }    
     
     
     if(dim4UpdateMap.size() > 0)
     {
         dim4UpdList = [Select Id,Name,c2g__ReportingCode__c from c2g__codaDimension4__c Where Id in :dim4UpdateMap.KeySet()];         
         
         for(c2g__codaDimension4__c dim4u :dim4UpdList  )
         {
             dim4u.Name = dim4UpdateNameMap.get(dim4u.Id);
             dim4u.c2g__ReportingCode__c = dim4UpdateMap.get(dim4u.Id);
         }
         
         update dim4UpdList;
     
     }
}