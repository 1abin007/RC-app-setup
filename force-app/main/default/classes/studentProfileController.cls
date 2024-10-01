public without sharing class studentProfileController {

    
    public studentProfileController() {

    }

    public class Experience {
        public String ExperienceType { get; set; }
        public String Organization { get; set; }
        public String Location { get; set; }
        public String Topic { get; set; }
        public String StartDuration { get; set; }
        public String EndDuration { get; set; }
    }
    public class Address {
        public String Address { get; set; }
        public String City { get; set; }
        public String State { get; set; }
        public String Pincode { get; set; }
    }
    public class MarksType {
        public String SchoolMarksType {get; set;}
        public String PuMarksType {get; set;}
        public String DiplomaMarksType {get; set;}
        public String DegreeMarksType {get; set;}
    }
    //Old version of student experience json, add to student wrapper when reusing.
    // public class StudentExperience {
    //     public List<Experience> experiences { get; set; }
    // }
    

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

    public class StudentWrapper {
        public RC_student__c studentDetails;
        public RC_student_test__c studentTest;
        public List<StudentAssessment> studentAssessmentList;
        public List<Experience> experience;
        public RC_event__c testDetails;
        public Address permanentAddress;
        public Address correspondenceAddress;
        public Boolean success;
        public String panelistName;
        public Integer RoundNo;
        public String errorMessage;
        public MarksType marksType;
    
        public StudentWrapper() {
            success = true;
            errorMessage = null;
        }
    }
    
    @RemoteAction
    public static StudentWrapper retrieveStudentDetails(String studentId, String eventId, String panelistsID) {
        StudentWrapper wrapper = new StudentWrapper();
        try {
            wrapper.studentTest = [SELECT Name, Id, student_id__c, event_id__c, student_marks_scored__c, has_cleared_cutoff__c, 
                event_cutoff__c, student_test_current_time__c, student_test_duration__c, student_test_start_time__c, 
                student_test_isStarted__c, student_test_warning__c, isLoggedIn__c, code_warnings__c, student_apti_marks__c, 
                student_cprogram_marks__c, neg_student_marks_scored__c, neg_student_apti_marks__c, neg_student_cprogram_marks__c, RoundOneStatus__c, isApproved__c,
                assessment__c , studentTestLog__c
            FROM RC_student_test__c 
            WHERE student_id__c = :studentId AND event_id__c = :eventId];
    
            if (wrapper.studentTest != null) {
                // Deserialize the assessment JSON string into a list of StudentAssessment objects
                wrapper.studentAssessmentList = (List<StudentAssessment>) JSON.deserialize(wrapper.studentTest.assessment__c, List<StudentAssessment>.class);
            }
        } catch (Exception e) {
            wrapper.success = false;
            wrapper.errorMessage = e.getMessage();
            
        }
        try {
            wrapper.studentDetails = [SELECT Id, Name, branch_type__c, city__c, college_id__r.Name, diploma_college_name__c, DateOfBirth__c, alternate_phone__c, MartialStatus__c,
                diploma_passing_year__c, email__c, hsc_marks__c, hsc_name__c, hscCourse__c , hsc_specialization__c, phone__c, hsc_pass_year__c, 
                pincode__c, ssc_marks__c, ssc_name__c, ssc_pass_year__c, SecondarySchoolCourse__c, SecondarySchoolSpecialization__c, state__c, street__c, usn__c, isHired__c, diploma_marks__c, DiplomaCourse__c, DiplomaSpecialization__c,
                degree_pursuing__c, degree_cgpa__c, degree_pass_year__c, student_exp__c, permanent_address__c, correspondence_address__c, student_image__c, Gender__c, 
                marks_type__c
            FROM RC_student__c 
            WHERE Id = :studentId];

            if (wrapper.studentDetails != null) {
                wrapper.experience = (List<Experience>) JSON.deserialize(wrapper.studentDetails.student_exp__c, List<Experience>.class);
                wrapper.permanentAddress = (Address) JSON.deserialize(wrapper.studentDetails.permanent_address__c, Address.class);
                wrapper.correspondenceAddress = (Address) JSON.deserialize(wrapper.studentDetails.correspondence_address__c, Address.class);
                wrapper.marksType = (MarksType) JSON.deserialize(wrapper.studentDetails.marks_type__c, MarksType.class);
            }
            
        } catch (Exception e) {
            wrapper.success = false;
            wrapper.errorMessage = e.getMessage();
            //return wrapper;
        }
        
        try{
            RC_student_test__c studentTest = [SELECT Id, Assessment__c FROM RC_student_test__c WHERE Student_Id__c = :studentId AND Event_Id__c = :eventId LIMIT 1];
            List<RC_panelist_junction_student_test__c> studentsUnderThisPanelist = [SELECT Id, assigned_panelist_round__c, panelist_id__r.panelistsName__c FROM RC_panelist_junction_student_test__c WHERE panelist_id__c = :panelistsID AND student_test_id__c = :studentTest.Id];
            wrapper.panelistName = studentsUnderThisPanelist[0].panelist_id__r.panelistsName__c;
            wrapper.RoundNo = Integer.valueOf(studentsUnderThisPanelist[0].assigned_panelist_round__c);
        }
        catch (Exception e)
        {
            wrapper.success  = false;
            wrapper.errorMessage = e.getMessage();
            //return wrapper;
        }

        try{
            wrapper.testDetails = [SELECT CEasy__c, CHard__c, CMeduim__c, aptiEasy__c, aptiHard__c, aptiMeduim__c, cutoff__c
            FROM RC_event__c WHERE Id = :eventId ];

        }
        catch (Exception e)
        {
            wrapper.success  = false;
            wrapper.errorMessage = e.getMessage();
        }
    
        return wrapper;
    }
    
    
    @RemoteAction
    public static void updateStudentAssessment(String jsonStr, String studentId, String eventId, String panelistID) {

        try{
            List<RC_panelist_junction_student_test__c> studentsUnderThisPanelists = [SELECT Id, panelist_id__r.panelistsName__c, student_test_id__c FROM RC_panelist_junction_student_test__c WHERE panelist_id__c = :panelistID];
            RC_student_test__c studentTest = [SELECT Id, Assessment__c FROM RC_student_test__c WHERE Student_Id__c = :studentId AND Event_Id__c = :eventId LIMIT 1];

            Boolean IsCorrectPanelistsForStudent = false;
            for(Integer i = 0; i < studentsUnderThisPanelists.size(); i++)
            {
                if(studentsUnderThisPanelists[i].student_test_id__c == studentTest.Id)
                {
                    IsCorrectPanelistsForStudent = true;
                }
            }

            if(!IsCorrectPanelistsForStudent)
            {
                system.debug('WRONG PANELISTS TRIED TO PUT ASSESMENT');
                return;
            }
        
            if (studentTest != null) {
                List<StudentAssessment> deSerializedJson = (List<StudentAssessment>) JSON.deserialize(jsonStr, List<StudentAssessment>.class);
                String status = deSerializedJson[deSerializedJson.size()-1].studentStatus;
                String roundNumber = deSerializedJson[deSerializedJson.size()-1].round;
                String updateStatus;
                if(status == 'Approved'){updateStatus = '2 - Cleared';}
                if(status == 'On-Hold'){updateStatus = '3 - On Hold';}
                if(status == 'Rejected'){updateStatus = '4 - Rejected';}
                if (roundNumber == '2'){
                    if(status == 'Approved')
                    {
                        studentTest.round_two_cleared__c = true;
                        studentTest.RoundThreeStatus__c = '0 - Waiting';
                        studentTest.RoundFourStatus__c = '5 - NA';
                    }
                    if(status == 'Rejected')
                    {
                        studentTest.RoundTwoStatus__c = '4 - Rejected';
                        studentTest.RoundThreeStatus__c = '4 - Rejected';
                        studentTest.RoundFourStatus__c = '4 - Rejected';
                    }

                    studentTest.RoundTwoStatus__c = updateStatus;
                }
                if (roundNumber == '3'){
                    if(status == 'Approved')
                    {
                        studentTest.round_three_cleared__c = true;
                        studentTest.RoundFourStatus__c = '0 - Waiting';
                    }
                    if(status == 'Rejected')
                    {
                        studentTest.RoundThreeStatus__c = '4 - Rejected';
                        studentTest.RoundFourStatus__c = '4 - Rejected';
                    }
                    studentTest.RoundThreeStatus__c = updateStatus;
                    
                }
                if (roundNumber == '4'){
                    if(status == 'Approved')
                    {
                        studentTest.round_four_cleared__c = true;
                        // studentTest.RoundFourStatus__c = '0 - Waiting';
                    }
                    if(status == 'Rejected')
                    {
                        studentTest.round_four_cleared__c = false;
                        studentTest.RoundFourStatus__c = '4 - Rejected';
                    }
                    studentTest.RoundFourStatus__c = updateStatus;
                    
                }

                //deSerializedJson.panelistName = studentsUnderThisPanelists[0].panelist_id__r.panelistsName__c;
                String serializedJson = JSON.serialize(deSerializedJson);
                studentTest.Assessment__c = serializedJson;
                update studentTest;
            } 
        }
        catch(Exception e){
            system.debug('Error Message: '+e);
        }
    }

    // @RemoteAction
    // public static void setStudentLogs(Map<String, Object> logs) {
    //     ApexPages.currentPage().getParameters().put('studentLogs', JSON.serialize(logs));
    // }

    @RemoteAction
    public static List<String> retrieveStudentLogs(String eventId, String studentId) {
        List<String> logsList = new List<String>();

        List <RC_student_test__c> logRecords = [SELECT studentTestLog__c FROM RC_student_test__c WHERE student_id__c = :studentId AND event_id__c = :eventId LIMIT 1];

        if (!logRecords.isEmpty()) {
            String logs = logRecords[0].studentTestLog__c;
            logsList = (List<String>)JSON.deserialize(logs, List<String>.class);
        }

        return logsList;
    }
}