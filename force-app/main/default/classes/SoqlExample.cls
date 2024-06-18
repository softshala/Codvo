public class SoqlExample {
    public static Account getData(String Namedata) {
        System.debug('Value->>'+ Namedata);
        Account acc = [Select Name, NumberOfEmployees, BillingState from Account where Name = :Namedata LIMIT 1];
        System.debug('Account->>>'+acc);
        acc.BillingState = 'Virginia';
        acc.NumberOfEmployees = 600;
        System.debug('Account->>>'+acc);
        return acc;
        
        
    }
    
    public static String updateData(Account acc) {
       
        update acc;
        return 'done';
        
        
    }
}