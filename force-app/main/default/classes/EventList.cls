public without sharing class EventList {

    public class StudentInfo {
        public StudentPersonalInfo studentData { get; set; }
        public Decimal marksScored { get; set; }
        public Decimal cpMarks { get; set; }
        public Decimal aptiMarks { get; set; }
        public Decimal negtotalMarks { get; set; }
        public Decimal negcpMarks { get; set; }
        public Decimal negaptiMarks { get; set; }
        public String Id { get; set; }
        public Boolean approve { get; set; }
        public String testId { get; set; }
    
        public StudentInfo(String tid, String fid, StudentPersonalInfo sdata, Decimal marks, Decimal cpm, Decimal aptim, Decimal negtm, Decimal negcpm, Decimal negaptim, Boolean appr) {
            studentData = sdata;
            marksScored = marks;
            cpMarks = cpm;
            aptiMarks = aptim;
            negtotalMarks = negtm;
            negcpMarks = negcpm;
            negaptiMarks = negaptim;
            Id = fid;
            approve = appr;
            testId = tid;
        }
    }

    public class StudentPersonalInfo{
        public String name { get; set; }
        public String phone { get; set; }
        public String email { get; set; }
        public String usn { get; set; }

        public StudentPersonalInfo(String sname, String sphone, String semail, String susn){
            name = sname;
            phone = sphone;
            email = semail;
            usn = susn;
        }

    }

    public class MyWrapper {
        public List<RC_student__c> student_list { get; set; }
        public List<RC_event__c> Event_List { get; set; }
        public List<RC_student_test__c> student_test_details { get; set; }
        public List<StudentInfo> studentInfoList { get; set; }
    }

    public class EventStudentDetails{
        public String EventId;
        public String StudentId;
        public String ErrorMsg; 
        public EventStudentDetails(String EventId,String StudentId,String ErrorMsg){
            this.EventId = EventId;
            this.StudentId = StudentId;
            this.ErrorMsg = ErrorMsg;
        }
    }



    @RemoteAction
    public static MyWrapper showResults(String event_id, String PanelistID, Integer check){

        MyWrapper result = new MyWrapper();
        result.studentInfoList = new List<StudentInfo>();


        if (check == 1){

            if(PanelistID != null)
            {
                List<RC_panelist_junction_student_test__c> studentsAssignedToThisPanelists = [SELECT Id, student_test_id__c, panelist_id__c FROM RC_panelist_junction_student_test__c WHERE panelist_id__c = :PanelistID];
                List<Id> studentTestId = new List<Id>();

                for(RC_panelist_junction_student_test__c junctionRecord: studentsAssignedToThisPanelists)
                {
                    studentTestId.add(junctionRecord.student_test_id__c);
                }

                result.student_test_details = [Select student_id__c, student_marks_scored__c, student_cprogram_marks__c, student_apti_marks__c, neg_student_marks_scored__c, neg_student_cprogram_marks__c, neg_student_apti_marks__c, isApproved__c from RC_student_test__c where event_id__c = :event_id AND Id IN :studentTestId];
            }
            else
            {
                result.student_test_details = [Select student_id__c, student_marks_scored__c, student_cprogram_marks__c, student_apti_marks__c, neg_student_marks_scored__c, neg_student_cprogram_marks__c, neg_student_apti_marks__c, isApproved__c from RC_student_test__c where event_id__c = :event_id];
            }
        

        
        List<Id> studentIds = new List<Id>();
        for (RC_student_test__c junctionRecord : result.student_test_details) {
            studentIds.add(junctionRecord.student_id__c);
        }

        result.student_list = [SELECT Name,	phone__c,email__c,	usn__c FROM RC_student__c WHERE Id IN :studentIds];


        Map<Id, StudentPersonalInfo> studentNameMap = new Map<Id, StudentPersonalInfo>();

        // Populate a map of student Ids to student names
        for (RC_student__c student : result.student_list) {
            StudentPersonalInfo info = new StudentPersonalInfo(student.Name,student.phone__c,student.email__c,student.usn__c);
            studentNameMap.put(student.Id, info);
        }


        for (RC_student_test__c junctionRecord : result.student_test_details) {
            StudentPersonalInfo studentData = studentNameMap.get(junctionRecord.student_id__c);
            if (studentData != null) {
                StudentInfo studentInfo = new StudentInfo(junctionRecord.Id, junctionRecord.student_id__c, studentData, junctionRecord.student_marks_scored__c,junctionRecord.student_cprogram_marks__c, junctionRecord.student_apti_marks__c, junctionRecord.neg_student_marks_scored__c, junctionRecord.neg_student_cprogram_marks__c, junctionRecord.neg_student_apti_marks__c, junctionRecord.isApproved__c);
                result.studentInfoList.add(studentInfo);
            }
        }


        return result;


    }
    else{
        result.Event_List = [select Name,event_date__c from RC_event__c];
        return result;
    }
}

@RemoteAction
public static String changeApproval(String testId,String eventID,Integer Check){

    if(Check == 1){
    RC_student_test__c studentApproval = [Select isApproved__c from RC_student_test__C where id = :testId];

    if(studentApproval.isApproved__c == true){
        studentApproval.isApproved__c = false;
    }
    else{
        studentApproval.isApproved__c = true;
    }

    update studentApproval;

    
}
return 'Approval Update Complete';
}


@RemoteAction
public static String changeRound1ClearedforAll(List<String> testIds){
    List<RC_student_test__c> studentApprovals = [SELECT Id,round_one_cleared__c FROM RC_student_test__c WHERE id in :testIds];
    for (RC_student_test__c studentApproval : studentApprovals){
        if(studentApproval.round_one_cleared__c == false){
            studentApproval.round_one_cleared__c = true;

        }

        studentApproval.RoundOneStatus__c = '2 - Cleared';
        studentApproval.RoundTwoStatus__c = '0 - Waiting';
        studentApproval.RoundThreeStatus__c = '5 - NA';
    }
    update studentApprovals;
    
    return 'Approval Update Complete';
}

@RemoteAction
public static String compileEventTests(String eventID){
   
    List<RC_student_test__C> a=[SELECT Id FROM RC_student_test__c WHERE event_id__c=:eventID];
    Integer n = (Integer)Math.ceil(a.size());
    
    for(Integer i=0;i<n;i+=20){
        updateTestsFuture(eventID,i);
    }
    return 'Updation Completed';

}

@RemoteAction
public static EventStudentDetails resetStudent(String studentEmail, String eventID)
{
    String eventPassword = getEventPassword(eventID);
    EventStudentDetails obj = UpdateWarnings(studentEmail, eventPassword);
    return obj;
}


public static String getEventPassword(String eventID)
{
    String eventPassword = [SELECT Id, event_id__c FROM RC_event__c WHERE Id = :eventID].event_id__c;
    return eventPassword;
}



    public static EventStudentDetails UpdateWarnings(String studentEmail, String eventPassword)
    {
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');

       List<RC_event__c> eventRes = [SELECT Id, event_id__c,isTestLive__c, event_date__c FROM RC_event__c WHERE event_id__c = :eventPassword];
       List<RC_student__c> studentRes = [SELECT Id, email__c FROM RC_student__c WHERE email__c = :studentEmail];
       if(studentRes.size() == 0 && eventRes.size() == 0)
       {
        EventStudentDetails obj = new EventStudentDetails('', '', 'Email is Not registered and Incorrect Event Password');
        return obj; 
       }
       if(studentRes.size() == 0){
        EventStudentDetails obj = new EventStudentDetails('', '', 'Email is Not registered');
        return obj; 
       }
       if(eventRes.size() == 0){
        EventStudentDetails obj = new EventStudentDetails('', '', 'Event Password is Incorrect');
        return obj; 
       }
       
       String testDate = DateTime.newInstance(
        eventRes[0].event_date__c.year(), eventRes[0].event_date__c.month(), eventRes[0].event_date__c.day()
                    ).format('yyyy-MM-dd');

       if(testDate != todaysDateStr){
        System.debug(testDate);
        System.debug(todaysDateStr);
        EventStudentDetails obj = new EventStudentDetails('', '', 'Test will be live on ' + testDate);
        return obj;
       }
    //    else if(eventRes[0].isTestLive__c == false)
    //    {
    //     EventStudentDetails obj = new EventStudentDetails('', '', 'Test is not live yet, Please Wait');
    //     return obj;
    //    }

        List<RC_student_test__c> validation = [select Id, Name, isLoggedIn__c, student_id__c, event_id__c,student_test_warning__c from RC_student_test__c where student_id__c = :studentRes[0].Id and event_id__c = :eventRes[0].Id];
        if(validation.size() == 0){
            

            EventStudentDetails obj = new EventStudentDetails('','','No Test for this student on this event');
            return obj;
        }else{ 
            validation[0].isLoggedIn__c = false;
            validation[0].student_test_warning__c = 6;
            update validation;
            EventStudentDetails obj = new EventStudentDetails(eventRes[0].Id, studentRes[0].Id,'');
            return obj;
        }
    }


@future
public static void updateTestsFuture(String eventID,Integer i){
    try{
    List<RC_student_test__c > stlist=[SELECT Id, event_id__c, student_id__c FROM RC_student_test__c
    where event_id__c=:eventID order by student_id__c asc limit 20 offset :i ];

   // Integer start = System.Now().millisecond();
  //  while(System.Now().millisecond()< start+1000){ 
  //  }
    
    for(RC_student_test__c r:stlist)
        {
        AltQuestionPageCtrl.updateTestMarks(r.student_id__c,r.event_id__c );
         }
      
    }catch(Exception e){
        System.debug('compileEventTests exception : '+e);
        System.debug('Exception in compileEventTests');
    }
   System.debug('compileEventTests Succesfully');
 }

}