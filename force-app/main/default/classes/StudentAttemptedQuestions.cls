public without sharing class StudentAttemptedQuestions { 

   //Wrapper Class
   //Should hold all the questions data and correct option to that question
   public class StudentAttemptKey
   {
      RC_Event_Question_Test_Set__c question; 
      String answerKey;
   }

    @RemoteAction
    public static List<StudentAttemptKey> GetInitialDataJSON(Id studentId, Id eventId) {  
       String JSONstring = [SELECT Id, StudentQuestions_JSON__c  FROM RC_student_test__c  where student_id__c = :studentId and event_id__c = :eventId].StudentQuestions_JSON__c;
       List<RC_Event_Question_Test_Set__c> res_student_qustion_json = (List<RC_Event_Question_Test_Set__c>) JSON.deserialize(JSONstring, List<RC_Event_Question_Test_Set__c>.class);
       List<RC_Event_Question_Test_Set__c> res_event_questions = [SELECT Id, event_id__c, question_correct_answer__c, question_number__c, question_category__c FROM RC_Event_Question_Test_Set__c where event_id__c = :eventId];
       List<StudentAttemptKey> result = new List<StudentAttemptKey>();

       //Gets the question and correct answer in the wrapper class
       for(Integer i = 0; i< res_student_qustion_json.size(); i++)
       {
         for(Integer j = 0; j <res_event_questions.size(); j++)
         {
           if(res_student_qustion_json[i].Id == res_event_questions[j].Id )
           {
                  StudentAttemptKey res = new StudentAttemptKey();
                  res.question = res_student_qustion_json[i];
                  res.answerKey = res_event_questions[j].question_correct_answer__c;
                  result.add(res);
           }      
         }
       }

       return result;
   } 
 }