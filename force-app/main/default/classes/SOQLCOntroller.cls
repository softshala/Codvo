public class SOQLCOntroller {
    /*
Objective: This question is designed to assess your proficiency with
string manipulation, control structures, and list handling in Apex,
Salesforce's proprietary programming language.

Task Description:

Develop an Apex method that fulfills the following requirements:

Parameters:

List<String> originalList: A list containing one or more strings.
String targetString: The string within the list that needs to be identified for replacement.
String replacementString: The string that will replace targetString in the list.
The primary objective of this method is to iterate through originalList,
locate all instances of targetString, and replace them entirely with replacementString.

The method should not utilize predefined list or string methods for finding 
and replacing strings. Instead, you are expected to implement this functionality 
using loops and control statements.

The method must return a new List<String> reflecting the changes,
with all occurrences of targetString replaced by replacementString. 
The original list should remain unchanged.

Expected Output:

The method should return a modified list where every instance 
of targetString has been replaced by replacementString.

Key Considerations:

Consider how your solution will handle cases where targetString is not present in originalList.
Reflect on the efficiency of your approach, particularly for large lists or strings.
Example Scenario:

Suppose your method is named replaceStringInList, and it's called with the following parameters:

Original List of Strings: ['apple', 'banana', 'apple', 'cherry']
Target String: 'apple'
Replacement String: 'orange'
The method should return a new list: ['orange', 'banana', 'orange', 'cherry'].

This question evaluates your ability to work
with lists and strings in Apex, requiring a manual implementation of 
string search and replacement functionality. Your solution should showcase 
your understanding of Apex programming principles and your ability to write efficient, logical code.
*/
    
  public static Integer ReplaceStringMethod(List<String> OriginalList, String TargetString, String ReplacementString ){
       
      
      return 0;
  }
    
    
   // fields = 'name,Annualrevenue,Type'
    public static void dynamicSOQLMethod(String ObjectName, String fields,  String condition ){
        List<string> allfields =  fields.split(','); // ['Name','AnnualRevenue','Type'];
        Integer i = allfields.size() ;
        System.debug('i->>'+i);
        String endfield = allfields[i-1]; // type
        System.debug('endfield->>'+endfield);
       String queryData = 'Select '+ fields + ' from ' + ObjectName + ' where '+ endfield + ' like :  condition';
        System.debug('queryData  ->> '+ queryData);
       List<Sobject> sList = Database.query(queryData);
        System.debug('Slist->>'+ sList);
       
        
     
    }
    // Variable Binding
    public static void SOQLMethod(String City, Integer Revenue){
       
       List<Account> AccList = [Select Name, Email_2__c, AnnualRevenue, BillingCity, BillingStreet, NumberOfEmployees from Account where NumberOfEmployees != null AND (BillingCity = :City AND AnnualRevenue > :Revenue )];

        for(Account acc:AccList){
             System.debug(Acc.Name +'  ----->>'+ acc.NumberOfEmployees + ' , City->> '+ acc.BillingCity + '  ,AnnualRevenue--> '+ acc.AnnualRevenue);
        }
    }
    
    public static void highPrioirtyAccount(){
       
       List<Account> AccList = [Select ID, Name from Account];
        System.debug(AccList);
        Integer i=0;
        List<String> NameList = new List<String>();
        for(Account acc:AccList){
            if(!NameList.contains(acc.Name)){
                i++;
                NameList.add(acc.Name);
            }
            
        }
        System.debug(i);
      
        
        
    }
    
    public static Boolean parentChildMethod(){
         

        List<Account> AccList = [Select Id, Name, BillingCity, (Select Id, Name, Description from Contacts) from Account where BillingCity = 'Alabama'];
        for(Account acc: Acclist){
            System.debug(acc.Name);
            System.debug(acc);
            
            for(Contact con : acc.Contacts){
                System.debug(con);
                con.Description = acc.Name + ' is your parent company';
                System.debug(con);
            }   
        }

        return true;
    }
    
    
    
    

}