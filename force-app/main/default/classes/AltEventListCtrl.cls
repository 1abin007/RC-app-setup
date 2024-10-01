public without sharing class AltEventListCtrl {
    public AltEventListCtrl() {

    } 


        //Custom class that holds the JSON data
        public class StudentAssessment
        {
            public String attitudeComment, techComment, commComment,attitudeRating, techRating, commRating, studentStatus, round, instanceId, firstRoundRemark, longTermRating, longTermRatingAlt, readyToJoinRating, longTermComment, longTermCommentAlt, readyToJoinComment, panelistName, panelistId;
            
            public StudentAssessment()
            {
                //no nothing
            }
            
            public StudentAssessment(String attitudeComment, String techComment, String commComment, String attitudeRating, String techRating,String commRating, String studentStatus, String round, String instanceId, String firstRoundRemark,String longTermRating, String readyToJoinRating, String longTermComment, String readyToJoinComment, String panelistName, String panelistId)
            {
                this.attitudeComment = attitudeComment;
                this.techComment = techComment;
                this.commComment = commComment;
                this.attitudeRating = attitudeRating;
                this.techRating = techRating;
                this.commRating = commRating;
                this.studentStatus = studentStatus;
                this.round = round;
                this.instanceId = instanceId;
                this.firstRoundRemark = firstRoundRemark;
                this.longTermRating = longTermRating;
                this.longTermRatingAlt = longTermRatingAlt;
                this.readyToJoinRating = readyToJoinRating;
                this.longTermComment = longTermComment;
                this.longTermCommentAlt = longTermCommentAlt;
                this.readyToJoinComment = readyToJoinComment;
                this.panelistName = panelistName;
                this.panelistId = panelistId;
            }
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
    public static List<RC_student_test__c> GetStudentsData(String panelistID, String eventId){
        List<RC_panelist_junction_student_test__c> studentsAssignedToThisPanelists = [SELECT Id, student_test_id__c, panelist_id__c FROM RC_panelist_junction_student_test__c WHERE panelist_id__c = :panelistID];
        List<Id> studentTestId = new List<Id>();

        for(RC_panelist_junction_student_test__c junctionRecord: studentsAssignedToThisPanelists)
        {
            studentTestId.add(junctionRecord.student_test_id__c);
        }

        String query;

        List<RC_student_test__c> StudetList;

        if(String.isBlank(panelistID) )
        {
            StudetList = [SELECT  student_id__r.Name, student_id__r.usn__c, student_id__r.phone__c,
            student_id__r.email__c, CreatedById, CreatedDate, Id, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, 
            LastReferencedDate, LastViewedDate, Name, RoundOneStatus__c, RoundThreeStatus__c, RoundTwoStatus__c,  
            SystemModstamp, assessment__c, code_warnings__c, event_cutoff__c, event_id__c, has_cleared_cutoff__c, isApproved__c, 
            isLoggedIn__c, neg_student_apti_marks__c, neg_student_cprogram_marks__c, neg_student_marks_scored__c, round_one_cleared__c, 
            round_three_cleared__c, round_two_cleared__c, studentTestLog__c, student_apti_marks__c, student_cprogram_marks__c, student_id__c, 
            student_marks_scored__c, student_test_current_time__c, student_test_duration__c, student_test_isStarted__c, 
            student_test_start_time__c, student_test_warning__c 
            FROM RC_student_test__c 
            WHERE event_id__c = :eventId
            ORDER BY student_marks_scored__c DESC NULLS LAST];

            // query = 'SELECT  student_id__r.Name, student_id__r.usn__c, student_id__r.phone__c, student_id__r.email__c, CreatedById, CreatedDate, Id, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, RoundOneStatus__c, RoundThreeStatus__c, RoundTwoStatus__c, StudentQuestions_JSON__c, SystemModstamp, assessment__c, code_warnings__c, event_cutoff__c, event_id__c, has_cleared_cutoff__c, isApproved__c, isLoggedIn__c, neg_student_apti_marks__c, neg_student_cprogram_marks__c, neg_student_marks_scored__c, round_one_cleared__c, round_three_cleared__c, round_two_cleared__c, studentTestLog__c, student_apti_marks__c, student_cprogram_marks__c, student_id__c, student_marks_scored__c, student_test_current_time__c, student_test_duration__c, student_test_isStarted__c, student_test_start_time__c, student_test_warning__c ' +
            //     'FROM RC_student_test__c' +' '+ 
            //     'WHERE' +' '+' event_id__c = \'' + eventId + '\''+' '+'ORDER BY student_marks_scored__c DESC NULLS LAST';
        }
        else 
        {
            StudetList = [SELECT  student_id__r.Name, student_id__r.usn__c, student_id__r.phone__c,
            student_id__r.email__c, CreatedById, CreatedDate, Id, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, 
            LastReferencedDate, LastViewedDate, Name, RoundOneStatus__c, RoundThreeStatus__c, RoundTwoStatus__c,  
            SystemModstamp, assessment__c, code_warnings__c, event_cutoff__c, event_id__c, has_cleared_cutoff__c, isApproved__c, 
            isLoggedIn__c, neg_student_apti_marks__c, neg_student_cprogram_marks__c, neg_student_marks_scored__c, round_one_cleared__c, 
            round_three_cleared__c, round_two_cleared__c, studentTestLog__c, student_apti_marks__c, student_cprogram_marks__c, student_id__c, 
            student_marks_scored__c, student_test_current_time__c, student_test_duration__c, student_test_isStarted__c, 
            student_test_start_time__c, student_test_warning__c 
            FROM RC_student_test__c 
            WHERE event_id__c = :eventId AND Id IN :studentTestId
            ORDER BY student_marks_scored__c DESC NULLS LAST];

            /*
            query = 'SELECT  student_id__r.Name, student_id__r.usn__c, student_id__r.phone__c, student_id__r.email__c, CreatedById, CreatedDate, Id, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, RoundOneStatus__c, RoundThreeStatus__c, RoundTwoStatus__c, StudentQuestions_JSON__c, SystemModstamp, assessment__c, code_warnings__c, event_cutoff__c, event_id__c, has_cleared_cutoff__c, isApproved__c, isLoggedIn__c, neg_student_apti_marks__c, neg_student_cprogram_marks__c, neg_student_marks_scored__c, round_one_cleared__c, round_three_cleared__c, round_two_cleared__c, studentTestLog__c, student_apti_marks__c, student_cprogram_marks__c, student_id__c, student_marks_scored__c, student_test_current_time__c, student_test_duration__c, student_test_isStarted__c, student_test_start_time__c, student_test_warning__c ' +
            'FROM RC_student_test__c' +' '+ 
            'WHERE' +' '+' event_id__c = \'' + eventId + '\''+' '+' AND Id IN :' + studentTestId + 'ORDER BY student_marks_scored__c DESC NULLS LAST';
            */
        }
        
        
        // System.debug('*33 '+query);
               
        // List<RC_student_test__c> StudetList = Database.query(query); 
        // System.debug('*4 '+StudetList);
        return StudetList;
    }

    @RemoteAction
    public static EventStudentDetails resetStudent(String studentId, String eventID)
    {
        EventStudentDetails obj = UpdateWarnings(studentId, eventID);
        return obj;
    }


    public static EventStudentDetails UpdateWarnings(String studentId, String eventID)
    {
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');

       List<RC_event__c> eventRes = [SELECT Id, event_id__c,isTestLive__c, event_date__c FROM RC_event__c WHERE Id = :eventID];
       List<RC_student__c> studentRes = [SELECT Id FROM RC_student__c WHERE Id = :studentId];
       if(studentRes.size() == 0 && eventRes.size() == 0)
       {
        EventStudentDetails obj = new EventStudentDetails('', '', 'Student is not Registered and Incorrect Event Password');
        return obj; 
       }
       if(studentRes.size() == 0){
        EventStudentDetails obj = new EventStudentDetails('', '', 'Student is Not registered');
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

    @RemoteAction
    public static EventStudentDetails resetAllStudent(String adminId, String eventPassword)
    {  
        //Commenting this code so that, directors also can do admin related work.
        // List<RC_admin__c> adminRes = [SELECT Id, adminEmail__c FROM RC_admin__c WHERE Id = :adminId];

        // if(adminRes.size() == 0)
        // {
        //     EventStudentDetails obj = new EventStudentDetails('','','Email is Not registered and Incorrect Event Password');
        //     return obj;
        // }

        List<RC_student_test__c> validation = [SELECT Id, isLoggedIn__c, student_test_warning__c FROM RC_student_test__c where event_id__r.Id = :eventPassword];
        if(validation.size() == 0){  
            EventStudentDetails obj = new EventStudentDetails('','','No Test for this event');
            return obj;
        }else{ 
            for(Integer i = 0;i<validation.size();i++){
                validation[i].isLoggedIn__c = false;
                validation[i].student_test_warning__c = 6; 
            }  
            update validation;
            EventStudentDetails obj = new EventStudentDetails(adminId, eventPassword,'');
            return obj;
        }    
    }


    
@RemoteAction
public static void changeApproval(String testId,String eventID,Boolean isApproved){
    RC_student_test__c studentApproval = [SELECT isApproved__c,RoundOneStatus__c, RoundThreeStatus__c, RoundTwoStatus__c,RoundFourStatus__c  FROM RC_student_test__C WHERE id = :testId];
    studentApproval.isApproved__c = isApproved;
    
    if(isApproved)
    {
        studentApproval.RoundOneStatus__c = '2 - Cleared';
        studentApproval.RoundTwoStatus__c = '0 - Waiting';
        studentApproval.RoundThreeStatus__c = '5 - NA';
        studentApproval.RoundFourStatus__c = '5 - NA';
    }

    update studentApproval;
}

@RemoteAction
public static void PromoteStudentsToRoundTwo(List<String> testIds){
    List<RC_student_test__c> studentApprovals = [SELECT Id,round_one_cleared__c,RoundOneStatus__c,RoundTwoStatus__c,RoundThreeStatus__c,RoundFourStatus__c FROM RC_student_test__c WHERE id in :testIds];
    for (RC_student_test__c studentApproval : studentApprovals)
    {
            studentApproval.round_one_cleared__c = true;
            studentApproval.RoundOneStatus__c = '2 - Cleared';
            studentApproval.RoundTwoStatus__c = '0 - Waiting';
            studentApproval.RoundThreeStatus__c = '5 - NA';
            studentApproval.RoundFourStatus__c = '5 - NA';
    }
    update studentApprovals;
}

@RemoteAction
public static void DemoteStudentsFromRoundTwo(List<String> testIds)
{
    List<RC_student_test__c> studentsToDemote =  [SELECT Id,round_one_cleared__c,RoundOneStatus__c,RoundTwoStatus__c,RoundThreeStatus__c,RoundFourStatus__c FROM RC_student_test__c WHERE id in :testIds];

    for(RC_student_test__c student : studentsToDemote)
    {
        student.round_one_cleared__c = false;
        student.RoundOneStatus__c = '5 - NA';
        student.RoundTwoStatus__c = '5 - NA';
        student.RoundThreeStatus__c = '5 - NA';
        student.RoundFourStatus__c = '5 - NA';
    }

    update studentsToDemote;
}

@RemoteAction
public static void compileEventTests(String eventID){
   
    List<RC_student_test__C> a=[SELECT Id FROM RC_student_test__c WHERE event_id__c=:eventID];
    Integer n = (Integer)Math.ceil(a.size());
    
    for(Integer i=0;i<n;i+=20){
        updateTestsFuture(eventID,i);
    }

}

@RemoteAction
public static List<RC_student_test__C> getDataForExcel(String eventId)
{
    List<RC_student_test__C> studentsForRoundTwo = [SELECT event_id__r.Name, event_id__r.event_date__c,CreatedById, CreatedDate, Id, IsDeleted, LastActivityDate, LastModifiedById, 
    LastModifiedDate, LastReferencedDate, LastViewedDate, Name, RoundOneStatus__c, RoundThreeStatus__c, RoundTwoStatus__c, 
      SystemModstamp, student_id__r.Name,student_id__r.email__c,student_id__r.usn__c, assessment__c, code_warnings__c,
    event_cutoff__c, event_id__c, has_cleared_cutoff__c, 
    isApproved__c, isLoggedIn__c, neg_student_apti_marks__c, neg_student_cprogram_marks__c, neg_student_marks_scored__c, 
    round_one_cleared__c, round_three_cleared__c, round_two_cleared__c, studentTestLog__c, student_apti_marks__c, student_cprogram_marks__c, 
    student_id__c, student_marks_scored__c, student_test_current_time__c, student_test_duration__c, student_test_isStarted__c, 
    student_test_start_time__c, student_test_warning__c
    FROM RC_student_test__c
    WHERE event_id__r.Id = :eventId AND (isApproved__c = true OR round_one_cleared__c = true)]; 

    return studentsForRoundTwo;
}

@RemoteAction
public static Map<String,List<StudentAssessment>> getStudentAssessment(List<String> studentIDs)
{
    Map<String,List<StudentAssessment>> studentAssementMap = new Map<String,List<StudentAssessment>>();

    List<RC_student_test__c> std =  [SELECT Id, assessment__c 
                                    FROM RC_student_test__c 
                                    WHERE Id IN :studentIDs];

    
    List<StudentAssessment> studentAssements = new List<StudentAssessment>();

    for(RC_student_test__c st : std)
    {
        if(String.isBlank(st.assessment__c)) continue;
        
        List<StudentAssessment> studentAssementsInStudentTest = (List<StudentAssessment>)JSON.deserialize(st.assessment__c, List<StudentAssessment>.class);
        studentAssementMap.put(st.Id, studentAssementsInStudentTest);
    } 

    return studentAssementMap;
}



@future
public static void updateTestsFuture(String eventID,Integer i){
    try{
    List<RC_student_test__c > stlist=[SELECT Id, event_id__c, student_id__c FROM RC_student_test__c
    where event_id__c=:eventID order by student_id__c asc limit 20 offset :i ];


    
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