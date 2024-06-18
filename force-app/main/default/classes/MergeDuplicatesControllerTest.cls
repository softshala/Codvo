@isTest
public class MergeDuplicatesControllerTest {
    
    @testSetup 
    public static void setupMethod(){
        Customers__c cus1 = new Customers__c(name = 'Shubham Sharma',Phone__c='12343');
        Customers__c cus2 = new Customers__c(name = 'Shubham Sharma',Phone__c='9876');
        List<Customers__c> cusList = new List<Customers__c>{cus1,cus2}; 
        insert cusList;
        Appointment__c app1 = new Appointment__c(Customer__c=cus1.id,name='A1');
        insert app1;
    }
    
    @isTest 
    public static void testMethod1(){
        Id currentRecordId = [SELECT id FROM Customers__c WHERE Phone__c = '9876'].id;
        Test.startTest();
        MergeDuplicatesController.findDuplicates(currentRecordId, 'Customers__c');
        Test.stopTest(); 
    }
    
    @isTest
    public static void testMethod2(){
        Id baseRecordId = [SELECT id FROM Customers__c WHERE Phone__c = '9876'].id;
        Id mergeRecordId = [SELECT id FROM Customers__c WHERE Phone__c = '12343'].id;
        Map<String,String> fieldSelection = new Map<String,String>{'Phone__C'=>'Phone__C'};
        Test.startTest();
        MergeDuplicatesController.mergeSelectedFields(baseRecordId, mergeRecordId, 'Customers__c', fieldSelection);
        system.assertEquals ([SELECT id,phone__c FROM Customers__c WHERE id = :baseRecordId].phone__c,[SELECT id,phone__c FROM Customers__c WHERE id = :mergeRecordId].phone__c,'success');
        Test.stopTest();
    }
    @isTest 
    public static void testMethod3(){
        Test.startTest();
        MergeDuplicatesController.getAllFields('Customers__c');
        MergeDuplicatesController.getFieldMetadata('Customers__c');
        Test.stopTest();
    }
    
    @isTest 
    public static void testMethod4(){
        Id recordId = [select id from Customers__c limit 1].id;
        Test.startTest();
        MergeDuplicatesController.getRecordDetails('Customers__c',recordId);
        System.assertEquals(1, Limits.getQueries(), 'There should be exactly one SOQL query executed.');
        Test.stopTest();
    }  
}