public class DML 
{
    //Singleton Pattern
    private static DML uniqueInstance;

    public static DML getInstance()
    {
        if(uniqueInstance == null)
        {
            uniqueInstance = new DML();
        }
        
        return uniqueInstance;
    }

    public Boolean isPasswordTaken(String password)
    {
        List<RC_event__c> events = [SELECT Id, event_id__c from RC_event__c where event_id__c = :password];

        if(events.size() == 0) return false;
        else return true;
    }

    public Boolean isPasswordTakenUpdate(String password, String EventID)
    {
        List<RC_event__c> events = [SELECT Id, event_id__c from RC_event__c where event_id__c = :password AND Id != :EventID];

        if(events.size() == 0) return false;
        else return true;
    }
    

    public List<RC_college__c> getCollegeNames()
    {
       return ([SELECT Name FROM RC_college__c]);
    }

    public List<RC_panelist__c> getPanelistNames()
    {
        return ([SELECT Id, panelistsName__c FROM RC_panelist__c]);
    }

    
    public String insertEventRecord(String eventName, String eventPassword, String eventDate, String eventLocation, String eventStartTimeString, String eventDuration, String cutoff, Integer aptiEasy, Integer aptiMed, Integer aptiHard, Integer CEasy, Integer CMed, Integer CHard)
    {
        Time eventStartTime = Utility.getInstance().convertStringToTime(eventStartTimeString);

        RC_event__c newEvent = new RC_event__c();
        newEvent.Name = eventName;
        newEvent.event_id__c = eventPassword;
        newEvent.event_location__c = eventLocation;
        newEvent.event_duration__c = Integer.valueOf(eventDuration);
        newEvent.cutoff__c = Integer.valueOf(cutoff);
        newEvent.event_date__c = Date.valueOf(eventDate); 
        newEvent.event_start_time__c = eventStartTime;
        newEvent.aptiEasy__c = aptiEasy;
        newEvent.aptiMeduim__c = aptiMed;
        newEvent.aptiHard__c = aptiHard;
        newEvent.CEasy__c = CEasy;
        newEvent.CMeduim__c = CMed;
        newEvent.CHard__c = CHard;
        Database.SaveResult sr = Database.insert(newEvent, false);

        if(sr.isSuccess()){
            return Id.valueOf(sr.getId());
        }
        else {
            return 'failed';
        }
    }


    public String updateEventRecord(String eventID, String eventName, String eventPassword, String eventDate, String eventLocation, String eventStartTimeString, String eventDuration, String cutoff, Integer aptiEasy, Integer aptiMed, Integer aptiHard, Integer CEasy, Integer CMed, Integer CHard)
    {
        Time eventStartTime = Utility.getInstance().convertStringToTime(eventStartTimeString);

        RC_event__c newEvent = new RC_event__c();
        newEvent.Id = eventId;
        newEvent.Name = eventName;
        newEvent.event_id__c = eventPassword;
        newEvent.event_location__c = eventLocation;
        newEvent.event_duration__c = Integer.valueOf(eventDuration);
        newEvent.cutoff__c = Integer.valueOf(cutoff);
        newEvent.event_date__c = Date.valueOf(eventDate); 
        newEvent.event_start_time__c = eventStartTime;
        newEvent.aptiEasy__c = aptiEasy;
        newEvent.aptiMeduim__c = aptiMed;
        newEvent.aptiHard__c = aptiHard;
        newEvent.CEasy__c = CEasy;
        newEvent.CMeduim__c = CMed;
        newEvent.CHard__c = CHard;
        Database.SaveResult sr = Database.update(newEvent, false);

        if(sr.isSuccess()){
            return Id.valueOf(sr.getId());
        }
        else {
            return 'failed';
        }
    }

    public Boolean deleteLinkedColleges(String EventID)
    {
        List<RC_college_event_junction__c> linkedColleges = getCollegeForEvent(EventID);

        Database.DeleteResult[] srList = Database.delete(linkedColleges, false);

        for (Database.DeleteResult sr : srList) {
            if (sr.isSuccess()) 
            {
                //continue
            }
            else{
                return false;
            }            
        }

        return true;
    }

    public Boolean deleteLinkedPanelists(String EventID)
    {
        List<RC_panelists_event_junction__c> linkedPanelists = getPanelistsForEvent(EventID);

        Database.DeleteResult[] srList = Database.delete(linkedPanelists, false);

        for (Database.DeleteResult sr : srList) {
            if (sr.isSuccess()) 
            {
                //continue
            }
            else{
                return false;
            }            
        }

        return true;
    }


    public String getEventID(String eventName)
    {
        return ([SELECT Id FROM RC_event__c WHERE Name = :eventName].Id);
    }

    public String getEventRecordID(String eventPassword)
    {
        return ([SELECT event_id__c FROM RC_event__c WHERE event_id__c = :eventPassword]).Id;
    }

    public RC_event__c getEventData(string eventID)
    {
        return ([SELECT Id, CEasy__c, CHard__c, CMeduim__c, Colleges__c, aptiEasy__c, aptiHard__c, aptiMeduim__c, cutoff__c, event_date__c, event_duration__c, event_id__c, event_location__c, event_start_time__c, Name FROM RC_event__c WHERE Id = :eventID]);
    }

    public List<RC_college_event_junction__c> getCollegeForEvent(String EventID)
    {
        return ([SELECT Id,  event_id__c, college_id__r.Name FROM RC_college_event_junction__c WHERE event_id__c = :EventID]);
    }

    public List<RC_panelists_event_junction__c> getPanelistsForEvent(String EventID)
    {
        return ([SELECT Id, panelists_id__r.panelistsName__c, event__c FROM RC_panelists_event_junction__c WHERE event__c = :EventID]);
    }

    public Boolean linkCollegeAndEventViaJunctionRecord(String eventId, String[] collegesLinkedToEvent)
    {
        List<RC_college_event_junction__c> collegeEventJunctions = new List<RC_college_event_junction__c>();
        
        for(Integer i = 0; i < collegesLinkedToEvent.size();i++)
        {
            RC_college_event_junction__c newCollegeJunctionEvent = new RC_college_event_junction__c();
            newCollegeJunctionEvent.Name = eventId + '_' + collegesLinkedToEvent[i];
            newCollegeJunctionEvent.event_id__c = eventId;
            newCollegeJunctionEvent.college_id__c = collegesLinkedToEvent[i];
            collegeEventJunctions.add(newCollegeJunctionEvent);
        }

        Database.SaveResult[] srList = Database.insert(collegeEventJunctions, false);

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) 
            {
                //continue
            }
            else{
                return false;
            }            
        }

        return true;
    }

    public Boolean linkPanelistsAndEventViaJunctionRecord(String eventId, String[] panelistLinkedToThisEvent)
    {
        List<RC_panelists_event_junction__c> panelistsEventJunctions = new List<RC_panelists_event_junction__c>();

        for(Integer i = 0; i < panelistLinkedToThisEvent.size(); i++)
        {
            RC_panelists_event_junction__c newJunctionRecord = new RC_panelists_event_junction__c();
            newJunctionRecord.event__c = eventId;
            newJunctionRecord.panelists_id__c = panelistLinkedToThisEvent[i];
            panelistsEventJunctions.add(newJunctionRecord);
        }

        Database.SaveResult[] srList = Database.insert(panelistsEventJunctions, false);

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) 
            {
                //continue
            }
            else{
                return false;
            }            
        }

        return true;
    }

    public Boolean updateStudentTestLog(String studentTestID,String logText)
    {
        RC_student_test__c studentTestObj = [SELECT Id, studentTestLog__c FROM RC_student_test__c WHERE Id = :studentTestID];
        Boolean willOverflow = false;
        String rawJSON = studentTestObj.studentTestLog__c;

        // if(rawJSON.length() > 130000)
        // {
        //     willOverflow = true;
        // }

        List<String> studentTestLogs = new List<String>();
        if(!String.isBlank(studentTestObj.studentTestLog__c))
        {
            studentTestLogs = (List<String>)JSON.deserialize(studentTestObj.studentTestLog__c, List<String>.class);
        }

        // if(willOverflow)
        // {
        //     //delete for the first 10 logs
        //     for(Integer i = 0; i < 10; i++)
        //     {
        //         studentTestLogs.remove(0);
        //     }

        //     willOverflow = false;
        // }

        studentTestLogs.add(logText);

        System.debug('Student Test logs: ' + studentTestLogs);
        studentTestObj.studentTestLog__c = (String)JSON.serialize(studentTestLogs);
        
        Database.SaveResult sr = Database.update(studentTestObj, false);
        if(sr.isSuccess())
        {
            return true;
        }
        else 
        {
            return false;
        }
    }

    
    public Boolean insertCollegeRecord(CollegeRegistrationDTO formData)
    {
        RC_College__c newRecord = new RC_College__c(
            Name = formData.collegeName,
            tpo_name__c = formData.tpoName,
            college_tpo_email__c = formData.collegeTPOEmail,
            college_tpo_phone__c = formData.collegeTPOPhone,
            college_code__c = formData.collegeCode,
            affiliated_university__c = formData.AffiliatedUniversity,
            college_address__c = formData.collegeAddress,
            college_pincode__c = formData.zipCode
        );

        Database.SaveResult sr = Database.insert(newRecord, false);

        if(sr.isSuccess()){
            return true;
        }
        else {
            return false;
        }
    }

    public Boolean insertQuestionIntoQuestionSet
    (
        String questionDescription,
        String questionDifficulty,
        String questionTitle,
        String questionCategory,
        String option1,
        String option2,
        String option3,
        String option4,
        String questionCorrectAnswer,
        Boolean hasProgram,
        Boolean isUpdate,
        String qID
        
    )
    {
        RC_question_set__c newQuestion = new RC_question_set__c();

        newQuestion.question_description__c = questionDescription;
        newQuestion.question_difficulty__c = questionDifficulty;
        newQuestion.question_title__c = questionTitle;
        newQuestion.question_category__c = questionCategory;
        newQuestion.option_1__c = option1;
        newQuestion.option_2__c = option2;
        newQuestion.option_3__c = option3;
        newQuestion.option_4__c = option4;
        newQuestion.question_correct_answer__c = questionCorrectAnswer;
        newQuestion.hasProgram__c = hasProgram;

        Database.SaveResult sr;
        if(isUpdate)
        {
            newQuestion.Id = qID;
            sr = Database.update(newQuestion, false);   
        }
        else{
            sr = Database.insert(newQuestion, false);
        }

        if(sr.isSuccess()){
            return true;
        }
        else {
            return false;
        }
    }

    public Boolean createEventQuestionTestSet(String eventID, Integer aptiEasy, Integer aptiMed, Integer aptiHard, Integer CEasy, Integer CMed, Integer CHard)
    {
        List<RC_question_set__c> questionForEvent = DML.getInstance().getRandomQuestionsForEvent(aptiEasy, aptiMed, aptiHard, CEasy, CMed, CHard);

        List<RC_Event_Question_Test_Set__c> eventQuestions = new List<RC_Event_Question_Test_Set__c>();

        for(Integer i = 0; i < questionForEvent.size(); i++)
        {
            RC_Event_Question_Test_Set__c newQuestion = new RC_Event_Question_Test_Set__c();
            newQuestion.option_1__c = questionForEvent[i].option_1__c;
            newQuestion.option_2__c = questionForEvent[i].option_2__c;
            newQuestion.option_3__c = questionForEvent[i].option_3__c;
            newQuestion.option_4__c = questionForEvent[i].option_4__c;
            newQuestion.question_correct_answer__c = questionForEvent[i].question_correct_answer__c;
            newQuestion.question_description__c = questionForEvent[i].question_description__c;
            newQuestion.question_title__c = questionForEvent[i].question_title__c;
            newQuestion.Name = questionForEvent[i].Name;
            newQuestion.hasProgram__c = questionForEvent[i].hasProgram__c;
            newQuestion.question_category__c = questionForEvent[i].question_category__c;
            newQuestion.question_difficulty__c = questionForEvent[i].question_difficulty__c;
            newQuestion.event_id__c = eventID;
            newQuestion.question_image__c = questionForEvent[i].question_image__c ;
            eventQuestions.add(newQuestion);
        }

        Database.SaveResult[] srList = Database.insert(eventQuestions, false);

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) 
            {
                //continue
            }
            else{
                return false;
            }            
        }

        return true;

    }

    public Boolean createStudentTestQuestions(String studentTestID, String eventID)
    {
        //Get the question Count for Apti and C
        RC_event__c tempEvent = [SELECT aptiEasy__c,aptiHard__c,aptiMeduim__c,CEasy__c,CHard__c,CMeduim__c FROM RC_event__c WHERE Id = :eventID];
        RC_student_test__c  studentTest= [SELECT Id, StudentQuestions_JSON__c FROM RC_student_test__c WHERE Id = :studentTestID];
        Integer noOfCQuestions = 0, noOfAptiQuestions = 0;

        noOfAptiQuestions += Integer.valueOf(tempEvent.aptiEasy__c);
        noOfAptiQuestions += Integer.valueOf(tempEvent.aptiHard__c);
        noOfAptiQuestions += Integer.valueOf(tempEvent.aptiMeduim__c);
        noOfCQuestions += Integer.valueOf(tempEvent.CEasy__c);
        noOfCQuestions += Integer.valueOf(tempEvent.CMeduim__c);
        noOfCQuestions +=  Integer.valueOf(tempEvent.CHard__c);

        System.debug('No Of C Questions For Students: ' + noOfCQuestions);
        System.debug('No Of Apti Questions For Students: ' + noOfAptiQuestions);

        //Generate Random Set
        List<RC_Event_Question_Test_Set__c> questionsForStudent = DML.getInstance().getRandomQuestionsForStudent(eventID,noOfAptiQuestions, noOfCQuestions);

        
        //string query='SELECT Id, Name, hasProgram__c, question_correct_answer__c, question_description__c, question_title__c, option_1__c, option_2__c, option_3__c, option_4__c, question_category__c, question_difficulty__c FROM RC_question_set__c';
        string Outputget= JSON.serialize(questionsForStudent); 
        studentTest.StudentQuestions_JSON__c = Outputget;
        update studentTest;
        // List<RC_question_set__c> q = (List<RC_question_set__c>) JSON.deserialize(Outputget, List<RC_question_set__c>.class);
        // system.Debug(q[0].Id);
        // system.Debug(q[1].Id);

        // List<RC_student_question__c> studentQuestions = new List<RC_student_question__c>();

        // for(Integer i = 0; i < questionsForStudent.size(); i++)
        // {
        //     RC_student_question__c newQuestion = new RC_student_question__c();
        //     newQuestion.option_1__c = questionsForStudent[i].option_1__c;
        //     newQuestion.option_2__c = questionsForStudent[i].option_2__c;
        //     newQuestion.option_3__c = questionsForStudent[i].option_3__c;
        //     newQuestion.option_4__c = questionsForStudent[i].option_4__c;
        //     newQuestion.question_correct_answer__c = questionsForStudent[i].question_correct_answer__c;
        //     newQuestion.question_description__c = questionsForStudent[i].question_description__c;
        //     newQuestion.question_title__c = questionsForStudent[i].question_title__c;
        //     newQuestion.Name = questionsForStudent[i].Name;
        //     newQuestion.hasProgram__c = questionsForStudent[i].hasProgram__c;
        //     newQuestion.question_category__c = questionsForStudent[i].question_Category__c;
        //     newQuestion.question_difficulty__c = questionsForStudent[i].question_difficulty__c;
        //     newQuestion.student_test_id__c = studentTestID;
        //     newQuestion.currentQuestion__c = false;
        //     newQuestion.question_number__c = i+1;
        //     studentQuestions.add(newQuestion);
        // }

        // studentQuestions[0].currentQuestion__c = true;
        // Database.SaveResult[] srList = Database.insert(studentQuestions, false);

        // String errorMessage;
        // for (Database.SaveResult sr : srList) {
        //     if (sr.isSuccess()) 
        //     {
        //         //continue
        //     }
        //     else{
        //        return false;
        //     }            
        // }

        return true;
    }

    public List<RC_question_set__c> getRandomQuestionsForEvent(Integer aptiEasySize, Integer aptiMedSize, Integer aptiHardSize, Integer CEasySize, Integer CMedSize, Integer CHardSize)
    {
        List<RC_question_set__c> questionsForStudent = new List<RC_question_set__c>();
        List<RC_question_set__c> aptitudeQuestionsEasy = new List<RC_question_set__c>();
        List<RC_question_set__c> aptitudeQuestionsMedium = new List<RC_question_set__c>();
        List<RC_question_set__c> aptitudeQuestionsHard = new List<RC_question_set__c>();
        List<RC_question_set__c> cProgrammingQuestionsEasy = new List<RC_question_set__c>();
        List<RC_question_set__c> cProgrammingQuestionsMedium = new List<RC_question_set__c>();
        List<RC_question_set__c> cProgrammingQuestionsHard = new List<RC_question_set__c>();
        
        List<RC_question_set__c> allQuestions = [SELECT Id, Name, hasProgram__c, question_correct_answer__c, question_description__c, question_title__c, option_1__c, option_2__c, option_3__c, option_4__c, question_category__c, question_difficulty__c,question_image__c FROM RC_question_set__c];
        
        for(Integer i = 0; i < allQuestions.size(); i++)
        {
            if(allQuestions[i].question_category__c == 'Aptitude')
            {
                if(allQuestions[i].question_difficulty__c == 'Easy')
                {
                    aptitudeQuestionsEasy.add(allQuestions[i]);
                }
                else if(allQuestions[i].question_difficulty__c == 'Medium')
                {
                    aptitudeQuestionsMedium.add(allQuestions[i]);
                }
                else if(allQuestions[i].question_difficulty__c == 'Hard')
                {
                    aptitudeQuestionsHard.add(allQuestions[i]);
                }
                
            }
            else
            {
               if(allQuestions[i].question_difficulty__c == 'Easy')
                {
                    cProgrammingQuestionsEasy.add(allQuestions[i]);
                }
                else if(allQuestions[i].question_difficulty__c == 'Medium')
                {
                    cProgrammingQuestionsMedium.add(allQuestions[i]);
                }
                else if(allQuestions[i].question_difficulty__c == 'Hard')
                {
                    cProgrammingQuestionsHard.add(allQuestions[i]);
                }
            }
        }
        
        //get apti set
        Utility.getInstance().AssignRandomQuestions(aptiEasySize,aptitudeQuestionsEasy,questionsForStudent);
        Utility.getInstance().AssignRandomQuestions(aptiMedSize,aptitudeQuestionsMedium,questionsForStudent);
        Utility.getInstance().AssignRandomQuestions(aptiHardSize,aptitudeQuestionsHard,questionsForStudent);
        
        //get CQuestions set
        Utility.getInstance().AssignRandomQuestions(CEasySize,cProgrammingQuestionsEasy,questionsForStudent);
        Utility.getInstance().AssignRandomQuestions(CMedSize,cProgrammingQuestionsMedium,questionsForStudent);
        Utility.getInstance().AssignRandomQuestions(CHardSize,cProgrammingQuestionsHard,questionsForStudent);
         
        return questionsForStudent;
    }

    public List<RC_question_set__c> getQuestionSetData()
    {
        return [SELECT Id, question_category__c, question_difficulty__c FROM RC_question_set__c];
    }

    public List<RC_Event_Question_Test_Set__c> getRandomQuestionsForStudent(String eventID, Integer noOfAptiQuestions, Integer noOfCQuestions)
    {
        Integer aptisize = noOfAptiQuestions , cprogsize = noOfCQuestions;
        List<RC_Event_Question_Test_Set__c> questionsForStudent = new List<RC_Event_Question_Test_Set__c>();
        List<RC_Event_Question_Test_Set__c> allQuestions = [SELECT Id, is_attempted__c, event_id__c, question_image__c,currentQuestion__c, hasProgram__c, isStudentAnswerdCorrect__c, option_1__c, option_2__c, option_3__c, option_4__c, question_category__c, question_description__c, question_title__c, question_difficulty__c, question_number__c, student_attempt__c FROM RC_Event_Question_Test_Set__c where event_id__c = :eventID];
        List<RC_Event_Question_Test_Set__c> aptiQuestions = new List<RC_Event_Question_Test_Set__c>();
        List<RC_Event_Question_Test_Set__c> cprogramQuestions = new List<RC_Event_Question_Test_Set__c>();


        for(Integer i = 0; i < allQuestions.size(); i++)
        {
            if(allQuestions[i].question_category__c == 'Aptitude')
            {
                aptiQuestions.add(allQuestions[i]);
            }
            else
            {
                cprogramQuestions.add(allQuestions[i]);
            }
        }

        Utility.getInstance().AssignRandomQuestionsStudents(cprogsize,cprogramQuestions,questionsForStudent);
        Utility.getInstance().AssignRandomQuestionsStudents(aptiSize,aptiQuestions,questionsForStudent);
         
        AssignQuestionNumbers(questionsForStudent);
        return questionsForStudent;
    }

    public void AssignQuestionNumbers(List<RC_Event_Question_Test_Set__c> questionsForStudent)
    {
        for(Integer i = 1; i <= questionsForStudent.size(); i++)
        {
            questionsForStudent[i-1].question_number__c  = i;
            questionsForStudent[i-1].currentQuestion__c = false;
        }

        questionsForStudent[0].currentQuestion__c = true;
    }
    
    //student registration DML class
    public RC_student__c createStudentBasicAccount(
        String name, String phone, String email, 
        String address1,
        // String address2, 
        String usn, 
        String city, 
        String state, 
        String pincode,
        String collegeId,
        String schoolName, 
        Decimal schoolMarks, 
        String schoolPassYear, 
        String secondarySchoolName, 
        Decimal puMarks, 
        String puPassingYear,
        String degreeType,
        String branchType,
        Decimal degreeMarks, 
        String degreePassingYear,
        String altPhone,
        String gender,
        String dob,
        String martialStatus,
        String permanentAddressJson,
        String corrAddressJson,
        String studentExpJson,
        String secondarySchoolCourse,
        String diplomaCollegeName,
        Decimal diplomaMarks,
        String diplomaPassingYear,
        String profilePhoto,
        String finalMarksType) 
    {
            System.debug('Entered createStudent');
            RC_student__c student = new RC_student__c();
            student.Name = name;
            student.Phone__c = phone;
            student.email__c = email;
            student.usn__c = usn;
            student.street__c = address1;
            student.city__c = city;
            student.state__c = state;
            student.pincode__c = Integer.valueOf(pincode);
            student.hsc_name__c = schoolName;
            student.hsc_marks__c = schoolMarks;
            student.hsc_pass_year__c = schoolPassYear;
            student.ssc_name__c = secondarySchoolName;
            student.ssc_marks__c = puMarks;
            student.ssc_pass_year__c = puPassingYear;
            student.college_id__c = collegeId; 
            student.degree_pursuing__c = degreeType;
            student.branch_type__c = branchType;
            student.degree_cgpa__c = degreeMarks;
            student.degree_pass_year__c = degreePassingYear;
            student.Gender__c = gender;
            student.MartialStatus__c = martialStatus;
            student.alternate_phone__c = altPhone;
            student.DateOfBirth__c = dob;
            student.permanent_address__c = permanentAddressJson;
            student.correspondence_address__c = corrAddressJson;
            student.student_exp__c = studentExpJson;
            student.secondarySchoolCourse__c = secondarySchoolCourse;
            student.diploma_college_name__c = diplomaCollegeName;
            student.diploma_marks__c = Integer.valueOf(diplomaMarks);
            student.diploma_passing_year__c= diplomaPassingYear;
            student.student_image__c = profilePhoto;
            student.marks_type__c = finalMarksType;
            
            insert student;
            return student;
    }
}