/***********************************************************
* Test Class Name : JOMV_ResponseReport_Controller_Test*
* Description: This test class is used to code coverage of JOMV_ResponseReport_Controller *
* Application: JOV-MVRR*
* Created By : TCS*
***********************************************************/
@IsTest
public class JOMV_ImportSiteRef_Controller_Test {
    public testmethod static void testGetUser(){
        test.startTest();
        User getUser = JOMV_ImportSiteRef_Controller.getUser();
        system.assert(getUser != null);
        test.stopTest();
    }
    public testmethod static void testImportSiteReferences(){
        test.startTest();
        List<string> header = new List<string>{'No','Therapeutic Area','Facility  Department Name','PI First Name','PI Last Name','Country	Name','Trial'};
        List<string> row = new List<string>{'Test9','Department9','Yogesh','Rashinkar','India','Test','Test'};
        List<string> row1 = new List<string>{'Test9','Department9','Yogesh','Rashinkar','India','Test9','Test9'};
        List<string> rowDup = new List<string>{'Test9','Department9','Yogesh','Rashinkar','India','Test9','Test9'};
        List<List<string>> data = new List<List<string>>();
        data.add(header);
        data.add(row);
        data.add(row1);
        data.add(rowDup);
        JOMV_ImportSiteRef_Controller.importSiteReferences(data);
        system.assert([SELECT Id FROM JOMV_Site_Reference__c WHERE UniqueKey__c = 'Test_Test'].size() > 0);
        test.stopTest();
    }
}