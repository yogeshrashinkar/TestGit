/***********************************************************
* Test Class Name : JOMV_ImportSiteRef_Controller*
* Description: This class is used to import site references in bulk, when you upload csv. *
* Application: JOV-MVRR*
* Created By : TCS*
***********************************************************/
public class JOMV_ImportSiteRef_Controller {
    @AuraEnabled
    public static User getUser(){
	//Added comments here
        return [SELECT FirstName,LastName FROM User WHERE Id=: UserInfo.getUserId()];
    }
    
    @AuraEnabled
    public static void importSiteReferences(List<List<string>> data){
        system.debug('data  : '+  data);				
        List<JOMV_Site_Reference__c> importSiteRef = new List<JOMV_Site_Reference__c>();
        set<Id> siteRefIds = new set<Id>();
        for(List<string> row : data ){
            JOMV_Site_Reference__c siteRef = new JOMV_Site_Reference__c();
            system.debug('row size'+  row.size());
            siteRef.Therapeutic_Area__c = row[0];
            siteRef.Facility_Department_Name__c = row[1];
            siteRef.PI_First_Name__c = row[2];
            siteRef.PI_Last_Name__c = row[3];
            siteRef.Country__c = row[4];
            siteRef.Name = row[5];
            siteRef.Trial__c = row[6];
            siteRef.UniqueKey__c = row[5]+'_'+row[6];
            importSiteRef.add(siteRef);
        }
        set<string> created = new set<string>();
        set<string> updated = new set<string>();
        List<string> duplicate = new List<string>();
        system.debug('importSiteRef size'+importSiteRef.size()  +  'Data : '+importSiteRef  );
        if(importSiteRef.size()>0){
            try {
                Database.UpsertResult[] results = Database.upsert(importSiteRef, JOMV_Site_Reference__c.UniqueKey__c,false);
                if (results != null){
                    for (Database.UpsertResult result : results) {
                        if (!result.isSuccess()) {
                            Database.Error[] errs = result.getErrors();
                            for(Database.Error err : errs)
                                System.debug(err.getStatusCode() + ' - ' + err.getMessage());
                        }else{
                            System.debug('success :'+result );
                        }
                    }
                }
                system.debug('results.size()'+results.size());
                for(Integer index = 0, size = results.size(); index < size; index++) {
                    if(results[index].isSuccess()) {
                        if(results[index].isCreated()) {
                            created.add(importSiteRef[index].UniqueKey__c);
                            System.debug(importSiteRef[index].UniqueKey__c +' was created');
                        } else {
                            updated.add(importSiteRef[index].UniqueKey__c);
                            System.debug(importSiteRef[index].UniqueKey__c +' was updated');
                        }
                    }else{
                        duplicate.add(importSiteRef[index].UniqueKey__c);
                        System.debug(importSiteRef[index].UniqueKey__c +' was failed');
                    }
                }
            } catch (Exception e) {
                System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
                throw new AuraHandledException('Darn it! Something went wrong: '
                                               + e.getMessage()); 
            }
            //Database.UpsertResult[] results = Database.upsert(importSiteRef, JOMV_Site_Reference__c.UniqueKey__c);
            //system.debug('results'+results);
            string csv='';
            csv+='Therapeutic Area,';
            csv+='Facility Department Name,';
            csv+='PI First Name,';
            csv+='PI Last bName,';
            csv+='Country,';
            csv+='Name,';
            csv+='Trial,';
            csv+='Unique Key,';
            csv+='Status,';
            csv+='\r\n';
            for(JOMV_Site_Reference__c  loopvar:importSiteRef ){
                csv+=loopvar.Therapeutic_Area__c+',';
                csv+=loopvar.Facility_Department_Name__c+',';
                csv+=loopvar.PI_First_Name__c+',';
                csv+=loopvar.PI_Last_Name__c+',';
                csv+=loopvar.Country__c+',';
                csv+=loopvar.Name+',';
                csv+=loopvar.Trial__c+',';
                csv+=loopvar.UniqueKey__c+',';
                if(created.contains(loopvar.UniqueKey__c)){
                    csv+= 'Sucess : Inserted'+',';
                    csv+='\r\n';
                }
                else if(updated.contains(loopvar.UniqueKey__c)){
                    csv+= 'Sucess : Updated'+',';                
                    csv+='\r\n';
                }else{
                    csv+= 'Failed : Duplicate/Bad Data'+',';                
                    csv+='\r\n';
                }
            }
            Integer createdCount = created.size();
            Integer updatedCount = updated.size();
            Integer duplicateCount = duplicate.size();
            sendEmail(csv,createdCount,updatedCount,duplicateCount);
        }
    }
    
    @future
    public static void sendEmail(string csv,Integer created,Integer updated,Integer duplicate){
        List<Id> ide = new List<Id>();
        ide.add(userInfo.getUserId());
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        Set<String> Emailsids = new Set<String>();
        Emailsids.add([SELECT Email  FROM User WHERE id=: UserInfo.getuserId()].Email);
        String [] emailsAsArray = new String [Emailsids.size()];
        Integer i = 0;
        for (String singleCCEmail: Emailsids) {
            emailsAsArray[i++] = singleCCEmail;
        }
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        //EmailTemplate template = [Select id,body from EmailTemplate where DeveloperName='CLAI_Import_Asset' limit 1];
        System.debug(emailsAsArray);
        message.toAddresses = emailsAsArray ;
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName('Data Import Summary.csv');
        efa.setBody(blob.valueof(csv));
        message.plainTextBody=String.valueof('Hi '+JOMV_ImportSiteRef_Controller.getUser().FirstName +',\n\n'+(created > 0 ?'You have successfully inserted '+created +' Site References.\n':'')+ (updated > 0 ?'You have successfully updated '+updated +' Site References.\n':'')+(duplicate > 0 ?'\nUnfortunately '+duplicate+' records are duplicated or bad record.':'')+'\n\nPlease find attached summary. \n\n\nThanks,\nSalesforce.');
        fileAttachments.add(efa);
        message.setFileAttachments(fileAttachments);
        message.subject = 'Site Referecne Import Results';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            if (!Test.IsRunningTest()) { 
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
    }
}