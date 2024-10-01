public class CreateEventController 
{

    class EventData{
        RC_event__c eventData;
        String event_date,event_start_time;

        public EventData(RC_event__c eventData, String event_date, String event_start_time)
        {
            this.eventData = eventData;
            this.event_date = event_date;
            this.event_start_time = event_start_time;
        }
    }

    @RemoteAction
    public static Boolean createEvent
    (
        String eventName, 
        String eventPassword,
        String eventDate, 
        String eventLocation, 
        String eventStartTime, 
        String eventDuration, 
        String colleges,
        String cutoff, 
        String panelists,
        Integer aptiEasy,
        Integer aptiMed,
        Integer aptiHard,
        Integer CEasy,
        Integer CMed,
        Integer CHard
    )
    {
        Boolean flag = false;
        //Create a event Record
        String currentEventId = DML.getInstance().insertEventRecord(eventName,eventPassword,eventDate,eventLocation,eventStartTime,eventDuration,cutoff,aptiEasy, aptiMed, aptiHard, CEasy, CMed, CHard);

        if(currentEventId == 'failed') return false; //couldn't create an event

        flag = DML.getInstance().createEventQuestionTestSet(currentEventId,aptiEasy,aptiMed,aptiHard,CEasy,CMed,CHard); //creates a test for the event
        
        if(flag == false)  return false;
    
        //Setup Link between college and event via junction object
        String[] collegesForThisEvent = colleges.split(',');
        String[] panelistsForThisEvent = panelists.split(',');
        flag = DML.getInstance().linkCollegeAndEventViaJunctionRecord(currentEventId,collegesForThisEvent);
        if(flag == false)  return false;
        return DML.getInstance().linkPanelistsAndEventViaJunctionRecord(currentEventID,panelistsForThisEvent);
    }

    @RemoteAction
    public static Boolean updateEvent
    (
        String eventId,
        String eventName, 
        String eventPassword,
        String eventDate, 
        String eventLocation, 
        String eventStartTime, 
        String eventDuration, 
        String colleges,
        String cutoff, 
        String panelists,
        Integer aptiEasy,
        Integer aptiMed,
        Integer aptiHard,
        Integer CEasy,
        Integer CMed,
        Integer CHard
    )
    {
        Boolean flag = false;
        //Update a event Record
        String currentEventId = DML.getInstance().updateEventRecord(eventId, eventName,eventPassword,eventDate,eventLocation,eventStartTime,eventDuration,cutoff,aptiEasy, aptiMed, aptiHard, CEasy, CMed, CHard);

        if(currentEventId == 'failed') return false; //couldn't create an event

        //Delete all college and panelists link with this event and overwrite
        flag = DML.getInstance().deleteLinkedColleges(currentEventID);
        if(flag == false) return false;
        flag = DML.getInstance().deleteLinkedPanelists(currentEventID);
        if(flag == false) return false;

        //Setup Link between college and event via junction object
        String[] collegesForThisEvent = colleges.split(',');
        String[] panelistsForThisEvent = panelists.split(',');
        flag = DML.getInstance().linkCollegeAndEventViaJunctionRecord(currentEventId,collegesForThisEvent);
        if(flag == false)  return false;
        flag = DML.getInstance().linkPanelistsAndEventViaJunctionRecord(currentEventID,panelistsForThisEvent);
        if(flag == false) return false;

        return true;
    }

    @RemoteAction
    public static Boolean checkIfPasswordTaken(String password)
    {
        return DML.getInstance().isPasswordTaken(password);
    }

    @RemoteAction
    public static String getEventRecordID(string EventPassword)
    {
        return DML.getInstance().getEventRecordID(EventPassword);
    }

    @RemoteAction
    public static Boolean checkIfPasswordTakenUpdate(String password, String EventID)
    {
        return (DML.getInstance().isPasswordTakenUpdate(password,EventID));
    }

    // public Boolean createEventQuestionsTestSet(String currentEventID, Integer noOfQuestions)
    // {
    //     Boolean result = DML.getInstance().createEventQuestionTestSet(currentEventID,noOfQuestions);
    //     return result;
    // }

    @RemoteAction
    public static List<RC_college__c> getAllCollegeNames()
    {
        return DML.getInstance().getCollegeNames();
    }

    @RemoteAction
    public static List<RC_panelist__c> getAllPanelistNames()
    {
        return DML.getInstance().getPanelistNames();
    }

    @RemoteAction
    public static EventData getEventData(String eventID)
    {
        RC_event__c eventData = new RC_event__c();
         eventData = DML.getInstance().getEventData(eventID);

         String testDate = DateTime.newInstance(
            eventData.event_date__c.year(), eventData.event_date__c.month(), eventData.event_date__c.day()
                        ).format('yyyy-MM-dd');
        
        String testStartTimedb =  String.valueOf(Time.newInstance(
            eventData.event_start_time__c.hour(), eventData.event_start_time__c.minute(), 0,0));

        String TestStartTime = testStartTimedb.removeEnd(':00.000Z');

        EventData ed = new EventData(eventData,testDate, TestStartTime);
        return ed;
    }

    @RemoteAction
    public static List<RC_college_event_junction__c> getCollegesForEvent(String EventID)
    {
        return (DML.getInstance().getCollegeForEvent(EventID));
    }

    @RemoteAction
    public static List<RC_panelists_event_junction__c> getPanelistsForEvent(String EventID)
    {
        return (DML.getInstance().getPanelistsForEvent(EventID));
    }

    public class QuestionSetData
    {
        Integer aptiEasy,aptiMeduim,aptiHard,CEasy,CMeduim,CHard;

        QuestionSetData(Integer aptiEasy, Integer aptiMeduim, Integer aptiHard, Integer CEasy, Integer CMeduim, Integer CHard)
        {
            this.aptiEasy = aptiEasy;
            this.aptiMeduim = aptiMeduim;
            this.aptiHard = aptiHard;
            this.CEasy = CEasy;
            this.CMeduim = CMeduim;
            this.CHard = CHard;
        }
    }

    @RemoteAction
    public static QuestionSetData getQuestionSetData()
    {
        Integer aptiEasy = 0,aptiMeduim = 0,aptiHard = 0,CEasy = 0,CMeduim = 0,CHard = 0;
        List<RC_question_set__c> questionSet = DML.getInstance().getQuestionSetData();
        
        
        for(Integer i = 0; i < questionSet.size(); i++)
        {
            if(questionSet[i].question_category__c == 'Aptitude')
            {
                if(questionSet[i].question_difficulty__c == 'Easy')
                {
                    aptiEasy++;
                }
                else if(questionSet[i].question_difficulty__c == 'Medium')
                {
                    aptiMeduim++;
                }
                else if(questionSet[i].question_difficulty__c == 'Hard')
                {
                   aptiHard++;
                }
                
            }
            else
            {
               if(questionSet[i].question_difficulty__c == 'Easy')
                {
                    CEasy++;
                }
                else if(questionSet[i].question_difficulty__c == 'Medium')
                {
                   CMeduim++;
                }
                else if(questionSet[i].question_difficulty__c == 'Hard')
                {
                   CHard++;
                }
            }
        }

        QuestionSetData qdata = new QuestionSetData(aptiEasy,aptiMeduim, aptiHard, CEasy, CMeduim, CHard);
        return qdata;
    }
}