public without sharing class AdminLoginController {
    public class LoginDetails{
        public String recordID;
        public Boolean isAdmin;
        public Boolean isDirector;
        public LoginDetails(String recordID,Boolean isAdmin, Boolean isDirector){
            this.recordID = recordID;
            this.isAdmin = isAdmin;
            this.isDirector = isDirector;
        }
    }

    @RemoteAction
    public static LoginDetails LoginAdmin(String EmailInput, String adminPassword) {

            List<RC_panelist__c> panelistRes = [SELECT Id, panelistsEmail__c FROM RC_panelist__c WHERE panelistsEmail__c = :EmailInput AND panelistsPassword__c = :adminPassword];
            List<RC_admin__c> adminRes = [SELECT Id, adminEmail__c FROM RC_admin__c WHERE adminEmail__c = :EmailInput AND adminPassword__c = :adminPassword];
            List<RC_director__c> directorRes = [SELECT Id, directorEmail__c FROM RC_director__c WHERE directorEmail__c = :EmailInput AND directorPassword__c = :adminPassword];
            
            if(adminRes.size() != 0)
            {
                LoginDetails lg = new LoginDetails(adminRes[0].Id,true,false);
                return lg;
            }

            if(panelistRes.size() != 0)
            {
                LoginDetails lg = new LoginDetails(panelistRes[0].Id,false,false);
                return lg;
            }

            if(directorRes.size() != 0)
            {
                LoginDetails lg = new LoginDetails(directorRes[0].Id,false,true);
                return lg;
            }

            if(adminRes.size() == 0 && panelistRes.size() == 0 && directorRes.size() == 0)
            {
                LoginDetails lg = new LoginDetails('',false,false);
                return lg;
            }

            return null;
       }
    
}