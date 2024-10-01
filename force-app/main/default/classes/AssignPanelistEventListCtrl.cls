public without sharing class AssignPanelistEventListCtrl {  

    @RemoteAction
    public static List<RC_event__c> GetEventData(){
   
        String query = 'SELECT Id, event_date__c, event_duration__c, event_id__c, event_location__c, event_start_time__c, isTestLive__c, Name FROM RC_event__c';
        
               
        List<RC_event__c> EventList = Database.query(query);
   
        System.debug('*4 '+EventList);
        return EventList;
    } 

 

    @RemoteAction
    public static List<RC_event__c> GetSearchEventsData(String SearchString){
        String query = 'SELECT Id, event_date__c, event_duration__c, event_id__c, event_location__c, event_start_time__c, isTestLive__c, Name FROM RC_event__c WHERE ' +
        ' (Name LIKE \''+'%' + SearchString +'%'+ '\''+' OR '+' event_id__c LIKE \''+'%' + SearchString +'%'+ '\')';
                System.debug('*23 '+query);
        List<RC_event__c> StudetList = Database.query(query); 
        return StudetList;
    }
 
}