public without sharing class AltQuestionPageCtrl { 
 

   //  public static List<RC_student_question__c> questionObj{get;set;}
   //  public static String questionObjJson { get; set; } 
    public static Integer testCurrentTime {get;set;}  


    public AltQuestionPageCtrl(){
      // List<RC_student_question__c> student_question_list = [SELECT Id, Name, student_test_id__c, is_attempted__c, currentQuestion__c, question_correct_answer__c, question_description__c, hasProgram__c, question_title__c, student_attempt__c, question_category__c, question_difficulty__c, option_1__c, option_2__c, option_3__c, option_4__c, question_number__c FROM RC_student_question__c];
      // questionObjJson = JSON.serialize(student_question_list);
         
      

   } 

   @RemoteAction
   public static String getResourceUrl(String resourceName) {
       return URL.getSalesforceBaseUrl().toExternalForm() + '/resource/' + resourceName;
   }


   @RemoteAction
   //DEPRECATED
   public static List<RC_student_question__c> GetInitialData(Id studentId, Id eventId) {  
      List<RC_student_question__c> student_test_questions = [SELECT Id, Name, student_test_id__c, is_attempted__c, currentQuestion__c,  question_description__c, hasProgram__c, question_title__c, student_attempt__c, question_category__c, question_difficulty__c, option_1__c, option_2__c, option_3__c, option_4__c, question_number__c
      FROM RC_student_question__c
      WHERE student_test_id__c IN (SELECT Id FROM RC_student_test__c WHERE student_id__c = :studentId and event_id__c = :eventId) ORDER BY question_number__c];
      return student_test_questions;
   }

   @RemoteAction
   public static List<RC_Event_Question_Test_Set__c> GetInitialDataJSON(Id studentId, Id eventId) {  
      String JSONstring = [SELECT Id, StudentQuestions_JSON__c  FROM RC_student_test__c  where student_id__c = :studentId and event_id__c = :eventId].StudentQuestions_JSON__c;
      List<RC_Event_Question_Test_Set__c> res = (List<RC_Event_Question_Test_Set__c>) JSON.deserialize(JSONstring, List<RC_Event_Question_Test_Set__c>.class);
      String logText =  '[LOGIN][' + Utility.getInstance().getTimeStamp() + ']' + ' Student Login';
      RC_student_test__c studentTest = [SELECT student_id__c, event_id__c FROM RC_student_test__c WHERE student_id__c = :studentId AND event_id__c = :eventId];
      DMl.getInstance().updateStudentTestLog(studentTest.Id, logText); 
      return res;
   }


   @RemoteAction
   public static Decimal GetCurrentTimer(Id studentId,Id eventId ) {  
      Decimal currentTime = [SELECT Id, student_id__c, student_test_current_time__c, student_test_duration__c FROM RC_student_test__c  where student_id__c = :studentId and event_id__c = :eventId].student_test_current_time__c;
      return currentTime;
   }

   @RemoteAction
   public static  RC_student_test__c GetCurrentStudentSession(Id studentId,Id eventId ) {  
      RC_student_test__c currentTime = [SELECT Id, student_test_isStarted__c, student_test_warning__c FROM RC_student_test__c  where student_id__c = :studentId and event_id__c = :eventId];
      return currentTime;
   }

   @RemoteAction
   public static void UpdateCurrentTimer(Integer currentTime, Id studentId, Id eventId, Boolean student_test_isStarted,Integer student_test_warning, Boolean isMaliciousActivity, String buttonPress) {  
      RC_student_test__c currentTimeDB = [SELECT Id, student_id__c, student_test_current_time__c, student_test_duration__c,student_test_isStarted__c,student_test_warning__c FROM RC_student_test__c  where student_id__c = :studentId and event_id__c = :eventId];
      currentTimeDB.student_test_current_time__c = currentTime;
      currentTimeDB.student_test_isStarted__c = student_test_isStarted;
      currentTimeDB.student_test_warning__c = student_test_warning;
      update currentTimeDB;

      //Update Student logs
      if(!isMaliciousActivity) return;
      if(String.isBlank(buttonPress)) buttonPress = 'Esc Key';
      String timeStampText = Utility.getInstance().getTimeStamp();
      String logText = '[MALICIOUS][' + timeStampText +']' + ' Malicious Activity detected, ' + buttonPress + ' was pressed!';
      DML.getInstance().updateStudentTestLog(currentTimeDB.Id, logText);
   }



   
 


    @RemoteAction
    public static List<RC_student_question__c> updateCurrentQuestion(Integer updatedQuestionNumber,String studentAnswer, Id questionId,Boolean isQstAttempted,Id studentId, Id eventId) {  
        System.debug('k* ' + updatedQuestionNumber   +studentAnswer);
         List<RC_student_question__c> student_question_list = [SELECT Id, Name, student_test_id__c, is_attempted__c, currentQuestion__c,  question_description__c, hasProgram__c, question_title__c, student_attempt__c, question_category__c, question_difficulty__c, option_1__c, option_2__c, option_3__c, option_4__c, question_number__c
         FROM RC_student_question__c
         WHERE student_test_id__c IN (SELECT Id FROM RC_student_test__c WHERE student_id__c = :studentId and event_id__c = :eventId) ORDER BY question_number__c];
         for( Integer i = 0 ;i< student_question_list.size();i++){
                  if(updatedQuestionNumber == student_question_list[i].question_number__c){
                     student_question_list[i].currentQuestion__c = true; 
                  }else{
                     student_question_list[i].currentQuestion__c = false;
                  }
                  if( student_question_list[i].Id == questionId){
                     student_question_list[i].student_attempt__c = studentAnswer;
                     student_question_list[i].is_attempted__c = isQstAttempted;
                  }

         }
         try{
            update student_question_list;
            return student_question_list;
         }catch(Exception e){
            return null;
         } 
    }


    @RemoteAction
    public static List<RC_Event_Question_Test_Set__c> updateCurrentQuestionJSON(Integer updatedQuestionNumber,String studentAnswer, Id questionId,Boolean isQstAttempted,Id studentId, Id eventId) {  
      String JSONstring = [SELECT Id, StudentQuestions_JSON__c  FROM RC_student_test__c  where student_id__c = :studentId and event_id__c = :eventId].StudentQuestions_JSON__c;
         List<RC_Event_Question_Test_Set__c> res_json_student_quesitons = (List<RC_Event_Question_Test_Set__c>) JSON.deserialize(JSONstring, List<RC_Event_Question_Test_Set__c>.class);
         List<RC_student_test__c> res_json_student_quesitons_to_update =  [SELECT Id, StudentQuestions_JSON__c  FROM RC_student_test__c  where student_id__c = :studentId and event_id__c = :eventId];
         for( Integer i = 0 ;i< res_json_student_quesitons.size();i++){
                  if(updatedQuestionNumber == res_json_student_quesitons[i].question_number__c){
                     res_json_student_quesitons[i].currentQuestion__c = true; 
                  }else{
                     res_json_student_quesitons[i].currentQuestion__c = false;
                  }
                  if( res_json_student_quesitons[i].Id == questionId){
                     res_json_student_quesitons[i].student_attempt__c = studentAnswer;
                     res_json_student_quesitons[i].is_attempted__c = isQstAttempted;
                  }
         }

         //Update Test Logs
         String timeStampText = Utility.getInstance().getTimeStamp();
         String logText;
         if(!String.isBlank(studentAnswer))
         {
            logText = '[ATTEMPT][' + timeStampText + ']'  + ' Student Attempt ' + studentAnswer + ' for Q.NO. ' + String.valueOf(updatedQuestionNumber);
         }
         else 
         {   
            logText = '[ATTEMPT][' + timeStampText + ']'  + ' Student Cleared selection' + studentAnswer + ' for Q.NO. ' + String.valueOf(updatedQuestionNumber);
         }
         Boolean flag =  DML.getInstance().updateStudentTestLog(res_json_student_quesitons_to_update[0].Id, logText);

         if(flag == false)
         {
            return null;
         }

         try{
            String JSONstring_to_udate = JSON.serialize(res_json_student_quesitons);
            res_json_student_quesitons_to_update[0].StudentQuestions_JSON__c = JSONstring_to_udate;
            update res_json_student_quesitons_to_update;
            return res_json_student_quesitons;
         }catch(Exception e){
            return null;
         } 

         
    }

 

   public static Integer reulsOfAgre(List<AggregateResult> results){
      if (!results.isEmpty()) {
         AggregateResult aggregateResult = results[0];
         return (Integer.valueOf(aggregateResult.get('cnt')));
     } else {
         return 0; 
     }
   }


   @RemoteAction
   public static Boolean updateTestMarks(Id studentId,Id eventId) { 
         
         RC_student_test__c studentTestIDRecord =  [SELECT Id, student_marks_scored__c, isLoggedIn__c  FROM RC_student_test__c where student_id__c = :studentId and event_id__c = :eventId];
         Integer marksScored = 0, AptiMarks = 0, CMarks = 0;
         Integer neg_marksScored = 0, neg_AptiMarks = 0, neg_CMarks = 0;

         //Update logs
         String timeStampText = Utility.getInstance().getTimeStamp();
         String logText = '[SUBMISSION][' + timeStampText + ']' + ' Student Submitted Test.';
         DML.getInstance().updateStudentTestLog(studentTestIDRecord.Id, logText);
         
         String JSONstring = [SELECT Id, StudentQuestions_JSON__c  FROM RC_student_test__c  where student_id__c = :studentId and event_id__c = :eventId].StudentQuestions_JSON__c;
         List<RC_Event_Question_Test_Set__c> res_student_qustion_json = (List<RC_Event_Question_Test_Set__c>) JSON.deserialize(JSONstring, List<RC_Event_Question_Test_Set__c>.class);
         List<RC_Event_Question_Test_Set__c> res_event_questions = [SELECT Id, event_id__c, question_correct_answer__c, question_number__c, question_category__c FROM RC_Event_Question_Test_Set__c where event_id__c = :eventId];
         for(Integer i = 0; i< res_student_qustion_json.size(); i++){
                   for(Integer j = 0; j <res_event_questions.size(); j++){
                     if(res_student_qustion_json[i].Id == res_event_questions[j].Id ) 
                        if(res_student_qustion_json[i].is_attempted__c == true)
                           if(res_student_qustion_json[i].student_attempt__c == res_event_questions[j].question_correct_answer__c){
                                    marksScored++;
                     }else if(res_student_qustion_json[i].Id == res_event_questions[j].Id)
                               if(res_student_qustion_json[i].is_attempted__c == true){
                                          neg_marksScored++;
                               }
                     if(res_student_qustion_json[i].Id == res_event_questions[j].Id)  
                        if(res_student_qustion_json[i].question_category__c == 'c programming') 
                            if(res_student_qustion_json[i].is_attempted__c == true) 
                                 if(res_student_qustion_json[i].student_attempt__c == res_event_questions[j].question_correct_answer__c){
                                       CMarks++;
                     }else if(res_student_qustion_json[i].Id == res_event_questions[j].Id) 
                                 if(res_student_qustion_json[i].is_attempted__c == true){
                                          neg_CMarks++;
                                 }

                     if(res_student_qustion_json[i].Id == res_event_questions[j].Id) 
                        if(res_student_qustion_json[i].question_category__c == 'Aptitude') 
                           if(res_student_qustion_json[i].is_attempted__c == true) 
                              if(res_student_qustion_json[i].student_attempt__c == res_event_questions[j].question_correct_answer__c){
                                    AptiMarks++;
                     }else if(res_student_qustion_json[i].Id == res_event_questions[j].Id) 
                                 if(res_student_qustion_json[i].is_attempted__c == true){
                                    neg_AptiMarks++;
                                 }

                   }
         } 

       
         studentTestIDRecord.student_marks_scored__c = marksScored;
         studentTestIDRecord.student_apti_marks__c = AptiMarks;
         studentTestIDRecord.student_cprogram_marks__c = CMarks;

         studentTestIDRecord.neg_student_marks_scored__c = neg_marksScored;
         studentTestIDRecord.neg_student_apti_marks__c = neg_AptiMarks;
         studentTestIDRecord.neg_student_cprogram_marks__c = neg_CMarks;


         studentTestIDRecord.isLoggedIn__c = false; 
         Database.SaveResult sr = Database.update(studentTestIDRecord, false);

       if(sr.isSuccess()){
           //do nothing
       }
       else {
           return false;
       }

       return true;

   }
}