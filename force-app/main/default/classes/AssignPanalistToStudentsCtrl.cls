public without sharing class AssignPanalistToStudentsCtrl {
    public AssignPanalistToStudentsCtrl() {

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

    @RemoteAction
    public static List<RC_panelists_event_junction__c> GetPanalistData(String eventId){
        List<RC_panelists_event_junction__c> panalist_res = [SELECT Id, panelists_id__r.Id, panelists_id__r.panelistsName__c   FROM RC_panelists_event_junction__c where event__c = :eventId];
        return panalist_res;
    }

    @RemoteAction
    public static Boolean PromoteDemoteStudent(String StudTestId, Integer RoundNumber, Boolean isPromote){
        RC_student_test__c test_obj = [SELECT assessment__c, isLoggedIn__c, Id, RoundOneStatus__c, RoundTwoStatus__c, RoundThreeStatus__c,RoundFourStatus__c FROM RC_student_test__c WHERE Id = :StudTestId];
        if(isPromote == true){ 
            if(RoundNumber == 2){
                test_obj.RoundTwoStatus__c = '2 - Cleared';
                test_obj.RoundThreeStatus__c = '0 - Waiting';
                test_obj.round_two_cleared__c  = true;
                update test_obj;
                return true;
            }else if(RoundNumber == 3){
                test_obj.RoundThreeStatus__c = '2 - Cleared';
                test_obj.RoundFourStatus__c = '4 - Waiting';
                test_obj.round_three_cleared__c = true;
                update test_obj;
                return true;
            }
        }else{ 
            if(RoundNumber == 3){
                test_obj.RoundTwoStatus__c = '0 - Waiting';
                test_obj.RoundThreeStatus__c = '5 - NA';
                test_obj.round_three_cleared__c  = false;
                update test_obj;
                return true;
            }
            else if(RoundNumber == 4)
            {
                test_obj.RoundThreeStatus__c = '0 - Waiting';
                test_obj.RoundFourStatus__c = '5 - NA';
                test_obj.round_four_cleared__c  = false;
                update test_obj;
                return true;
            }
        }


        return false;

       


    }


    @RemoteAction
    public static List<RC_student_test__c> GetStudentsData(String panelistID, String eventId,String StudentSort,Integer StudentCount,String StudentFilter, String RoundSelected,Boolean isGetAllStudents){
        
       if(isGetAllStudents == true){
            String query = 'SELECT Id, RoundOneStatus__c, RoundTwoStatus__c, RoundThreeStatus__c,RoundFourStatus__c, event_id__c, student_id__r.Name, student_id__r.usn__c, student_id__r.phone__c, student_id__r.email__c,  round_one_cleared__c, round_two_cleared__c, round_three_cleared__c, student_marks_scored__c, student_cprogram_marks__c, student_apti_marks__c, isApproved__c ' +
            'FROM RC_student_test__c' +' '+ 
            'WHERE'+' '+'(round_one_cleared__c = true OR isApproved__c = true ) AND event_id__c = \'' + eventId + '\''; 
            List<RC_student_test__c> StudetList = Database.query(query);

            return StudetList;
       }
        
        
        String SortVar = '', FilterVar = '';

        if(StudentSort == 'Name ASC'){
             SortVar = 'student_id__r.Name ASC';
        }else if(StudentSort == 'Name DESC'){
            SortVar = 'student_id__r.Name DESC';
        }else if(StudentSort == 'RoundOneStatus__c ASC'){
            SortVar = 'RoundOneStatus__c ASC';
        }else if(StudentSort == 'RoundOneStatus__c DESC'){
            SortVar = 'RoundOneStatus__c DESC';
        }else if(StudentSort == 'RoundTwoStatus__c ASC'){
            SortVar = 'RoundTwoStatus__c ASC';
        }else if(StudentSort == 'RoundTwoStatus__c DESC'){
            SortVar = 'RoundTwoStatus__c DESC';
        }else if(StudentSort == 'RoundThreeStatus__c ASC'){
            SortVar = 'RoundThreeStatus__c ASC';
        }else if(StudentSort == 'RoundThreeStatus__c DESC'){
            SortVar = 'RoundThreeStatus__c DESC';
        }
         
        

        if(StudentFilter == '1st Round Cleared'){
            FilterVar = 'round_one_cleared__c = true AND ';
        }else if(StudentFilter == '2nd Round Cleared'){
            FilterVar = 'round_two_cleared__c = true AND ';
        }else if(StudentFilter == '3rd Round Cleared'){
            FilterVar = 'round_three_cleared__c = true AND ';
        }else if(StudentFilter == 'Rejected Students'){
            FilterVar = '(RoundOneStatus__c = \'4 - Rejected\' OR RoundTwoStatus__c = \'4 - Rejected\' OR RoundThreeStatus__c = \'4 - Rejected\') AND ';
        }else if(StudentFilter == 'On Hold Students'){
            FilterVar = '(RoundOneStatus__c = \'3 - On Hold\' OR RoundTwoStatus__c = \'3 - On Hold\' OR RoundThreeStatus__c = \'3 - On Hold\') AND ';
        }else if(StudentFilter == 'Approved Students'){
            FilterVar = 'isApproved__c = true AND ';
        }else if(StudentFilter == 'Hired Students'){
            FilterVar = 'round_four_cleared__c = true AND';
        }
        else {
            FilterVar = '(round_one_cleared__c = true OR isApproved__c = true ) AND';
        }
        

        String query = 'SELECT Id, RoundOneStatus__c, RoundTwoStatus__c, RoundThreeStatus__c,RoundFourStatus__c, event_id__c, student_id__r.Name, student_id__r.usn__c, student_id__r.phone__c, student_id__r.email__c,  round_one_cleared__c, round_two_cleared__c, round_three_cleared__c, student_marks_scored__c, student_cprogram_marks__c, student_apti_marks__c, isApproved__c ' +
               'FROM RC_student_test__c' +' '+ 
               'WHERE'+' ' + FilterVar +' '+' event_id__c = \'' + eventId + '\''+' '+ 
              // (SortVar != '' ? 'ORDER BY'+' ' + SortVar : '') +' '+
               (StudentCount != 0 ? 'LIMIT'+' ' + StudentCount : ' ');
        System.debug('*33 '+query);
               
        List<RC_student_test__c> StudetList = Database.query(query); 
        System.debug('*4 '+StudetList);
        return StudetList;
    }



    @RemoteAction
    public static List<RC_student_test__c> GetAllStudentsData(String eventId){
         
        String query = 'SELECT Id, RoundOneStatus__c, RoundTwoStatus__c, RoundThreeStatus__c,RoundFourStatus__c, event_id__c, student_id__r.Name, student_id__r.usn__c, student_id__r.phone__c, student_id__r.email__c,  round_one_cleared__c, round_two_cleared__c, round_three_cleared__c, student_marks_scored__c, student_cprogram_marks__c, student_apti_marks__c, isApproved__c ' +
        'FROM RC_student_test__c' +' '+ 
        'WHERE'+' '+'(round_one_cleared__c = true OR isApproved__c = true ) AND event_id__c = \'' + eventId + '\''; 
        List<RC_student_test__c> StudetList = Database.query(query);
 
        return StudetList;
    }


    @RemoteAction
    public static List<RC_student_test__c> GetSearchStudentsData(String eventId,String SearchString){
         
        String query = 'SELECT Id, RoundOneStatus__c, RoundTwoStatus__c, RoundThreeStatus__c,RoundFourStatus__c, event_id__c, student_id__r.Name, student_id__r.usn__c, student_id__r.phone__c, student_id__r.email__c,  round_one_cleared__c, round_two_cleared__c, round_three_cleared__c, student_marks_scored__c, student_cprogram_marks__c, student_apti_marks__c, isApproved__c ' +
               'FROM RC_student_test__c' +' '+ 
               'WHERE'+' '+'round_one_cleared__c = true AND event_id__c = \'' + eventId + '\''+' AND '+' (student_id__r.Name LIKE \''+'%' + SearchString +'%'+ '\''+' OR '+' student_id__r.email__c LIKE \''+'%' + SearchString +'%'+ '\'' +' OR '+' student_id__r.phone__c LIKE \''+'%' + SearchString +'%'+ '\''+')';
                System.debug('*23 '+query);
        List<RC_student_test__c> StudetList = Database.query(query);
 
        return StudetList;
    }

    @RemoteAction
    public static List<RC_panelist_junction_student_test__c> GetStudentPanelists(String StudTestId , Integer Round){
        List<RC_panelist_junction_student_test__c> res_list = [SELECT Id, panelist_id__c,assigned_panelist_round__c, student_test_id__c , panelist_id__r.panelistsName__c FROM RC_panelist_junction_student_test__c WHERE student_test_id__c = :StudTestId and assigned_panelist_round__c = :Round];
        return res_list;
    }

    @RemoteAction
    public static RC_panelist_junction_student_test__c AssignPanelistAddJunction(String pan_id,String stud_test_id, Integer round_number){
        RC_panelist_junction_student_test__c  obj = new RC_panelist_junction_student_test__c();
        RC_student_test__c test_obj = [SELECT isLoggedIn__c, Id, RoundOneStatus__c, RoundTwoStatus__c, RoundThreeStatus__c,RoundFourStatus__c FROM RC_student_test__c WHERE Id = :stud_test_id];
        
        if(round_number == 1){
            test_obj.RoundOneStatus__c  = '1 - In Progress';
        }else if(round_number == 2){
            test_obj.RoundTwoStatus__c  = '1 - In Progress';
        }else if(round_number == 3){
            test_obj.RoundThreeStatus__c  = '1 - In Progress';
        }
        else if(round_number == 4)
        {
            test_obj.RoundFourStatus__c = '1 - In Progress';
        }

        update test_obj;

        obj.panelist_id__c = pan_id;
        obj.student_test_id__c = stud_test_id;
        obj.assigned_panelist_round__c = round_number;
        insert obj;
        return obj;
    }

    @RemoteAction
    public static Boolean RemovePanStudtestJunction(String pan_id, String stud_test_id, Integer round_numb){
        List<RC_panelist_junction_student_test__c> obj_to_delete  = [SELECT Id, panelist_id__c, student_test_id__c, assigned_panelist_round__c FROM RC_panelist_junction_student_test__c WHERE panelist_id__c = :pan_id AND student_test_id__c  = :stud_test_id  AND assigned_panelist_round__c = :round_numb];
        List<RC_panelist_junction_student_test__c> obj_to_delete_assign_status  = [SELECT Id, panelist_id__c, student_test_id__c, assigned_panelist_round__c FROM RC_panelist_junction_student_test__c WHERE student_test_id__c  = :stud_test_id  AND assigned_panelist_round__c = :round_numb];
        if(obj_to_delete_assign_status.size () == 1){
                RC_student_test__c test_obj = [SELECT isLoggedIn__c, Id, RoundOneStatus__c, RoundTwoStatus__c, RoundThreeStatus__c,RoundFourStatus__c FROM RC_student_test__c WHERE Id = :stud_test_id];
                
                if(round_numb == 1){
                    test_obj.RoundOneStatus__c  = '0 - Waiting';
                }else if(round_numb == 2){
                    test_obj.RoundTwoStatus__c  = '0 - Waiting';
                }else if(round_numb == 3){
                    test_obj.RoundThreeStatus__c  = '0 - Waiting';
                }

                update test_obj;
        }
        
        if(obj_to_delete.size() != 0){
              delete obj_to_delete;
              return true;
        }
        return false;
    }

    @RemoteAction
    public static String getPanelistId(String studentTestId, Decimal roundNumber)
    {
        List<RC_panelist_junction_student_test__c> panelistTestJunction = [SELECT Id, assigned_panelist_round__c, panelist_id__c, student_test_id__c
                                                                            FROM RC_panelist_junction_student_test__c
                                                                            WHERE student_test_id__c = :studentTestId AND assigned_panelist_round__c = :roundNumber];

        if(panelistTestJunction.size() == 0) return 'false';
        
        return panelistTestJunction[0].panelist_id__c;

    }





//****************************** PDF RELATED CODE *********************************/
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
 
    



    public class StudentWrapper {
        public List<RC_student__c> studentDetailsList;
        public List<RC_student_test__c> studentTestList;
        public Map<Id,List<StudentAssessment>> studentAssessmentList;
        public Map<Id,List<Experience>> experienceMap;
        public Map<Id,Address> permanentAddressMap;
        public Map<Id,Address> correspondenceAddressMap;
        public Boolean success;
        public String panelistName;
        public Integer RoundNo;
        public String errorMessage;
    
        public StudentWrapper() {
            success = true;
            errorMessage = null;
        }
    }
    
    @RemoteAction
    public static StudentWrapper retrieveStudentDetails(List<String> studentId, String eventId) {
        StudentWrapper wrapper = new StudentWrapper();
        try {
            wrapper.studentTestList = [SELECT Name, Id, student_id__c ,student_id__r.Name, event_id__c,event_id__r.CEasy__c,
                event_id__r.CMeduim__c,event_id__r.CHard__c,event_id__r.aptiEasy__c,event_id__r.aptiMeduim__c,event_id__r.aptiHard__c,
                student_marks_scored__c, has_cleared_cutoff__c, 
                event_cutoff__c, student_test_current_time__c, student_test_duration__c, student_test_start_time__c, 
                student_test_isStarted__c, student_test_warning__c, isLoggedIn__c, code_warnings__c, student_apti_marks__c, 
                student_cprogram_marks__c, neg_student_marks_scored__c, neg_student_apti_marks__c, neg_student_cprogram_marks__c, 
                assessment__c  
            FROM RC_student_test__c 
            WHERE student_id__c IN :studentId AND event_id__c = :eventId];
    
            if (wrapper.studentTestList != null) {

                wrapper.studentAssessmentList = new Map<Id,List<StudentAssessment>>();

                for(Integer i = 0 ; i < wrapper.studentTestList.size(); i++)
                {
                    if(wrapper.studentTestList[i].assessment__c != null)
                    {
                        System.debug('#0 Hello ');
                        List<StudentAssessment> studentAssessment = (List<StudentAssessment>) JSON.deserialize(wrapper.studentTestList[i].assessment__c, List<StudentAssessment>.class);   
                        wrapper.studentAssessmentList.put(wrapper.studentTestList[i].Id, studentAssessment);
                    }
                    
                }
                // Deserialize the assessment JSON string into a list of StudentAssessment objects
            }
        } catch (Exception e) {
            wrapper.success = false;
            wrapper.errorMessage = e.getMessage();
            
        }
        
        try {
            wrapper.studentDetailsList = [SELECT Id, Name, branch_type__c, city__c, degree_cgpa__c,
            college_id__r.Name, degree_pass_year__c, degree_pursuing__c, diploma_college_name__c, 
            diploma_marks__c, diploma_passing_year__c, email__c, hsc_marks__c, hsc_name__c, 
            hsc_pass_year__c, isHired__c, phone__c, pincode__c, ssc_marks__c, ssc_name__c, 
            ssc_pass_year__c, state__c, street__c, usn__c, student_exp__c, DateOfBirth__c, 
            Gender__c, MartialStatus__c, AlternateContactNumber__c, NoOfDaysRequiredToJoin__c, 
            hscCourse__c, hsc_specialization__c, SecondarySchoolCourse__c, SecondarySchoolSpecialization__c, 
            DiplomaCourse__c, DiplomaSpecialization__c, permanent_address__c, correspondence_address__c, 
            alternate_phone__c,student_image__c 
            FROM RC_student__c
            WHERE Id IN :studentId];

            if (wrapper.studentDetailsList != null) {
                wrapper.experienceMap = new Map<Id,List<Experience>>();
                wrapper.permanentAddressMap = new Map<Id,Address>();
                wrapper.correspondenceAddressMap = new Map<Id,Address>();

                for(Integer i = 0; i < wrapper.studentDetailsList.size(); i++)
                {
                    wrapper.experienceMap.put(wrapper.studentDetailsList[i].Id, (List<Experience>) JSON.deserialize(wrapper.studentDetailsList[i].student_exp__c, List<Experience>.class));
                    wrapper.permanentAddressMap.put(wrapper.studentDetailsList[i].Id, (Address) JSON.deserialize(wrapper.studentDetailsList[i].permanent_address__c, Address.class));
                    wrapper.correspondenceAddressMap.put(wrapper.studentDetailsList[i].Id, (Address) JSON.deserialize(wrapper.studentDetailsList[i].correspondence_address__c, Address.class));
                }

                // wrapper.experience = (List<Experience>) JSON.deserialize(wrapper.studentDetails.student_exp__c, List<Experience>.class);
                // wrapper.permanentAddress = (Address) JSON.deserialize(wrapper.studentDetails.permanent_address__c, Address.class);
                // wrapper.correspondenceAddress = (Address) JSON.deserialize(wrapper.studentDetails.correspondence_address__c, Address.class);
            }
            
        } catch (Exception e) {
            wrapper.success = false;
            wrapper.errorMessage = e.getMessage();
            //return wrapper;
        } 
        
    
        return wrapper;
    }


    

    
}