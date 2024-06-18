trigger ContactTrigger on Contact (after insert, after update, after delete, after undelete) {
    
  
    if(trigger.isinsert && trigger.isafter){
     //   String contactString = JSON.serialize(trigger.new[0]);
    //    HttpPostCallout.createContactInPostgrid(contactString);
        
        
        
        System.debug('Running after insert' + trigger.new); 
       ContactTriggerController.countCOntact(trigger.new); // trigger.new (List<Contact>)
    }
 
    if(trigger.isupdate && trigger.isafter){
        System.debug(' trigger.new update' +  trigger.new); 
         System.debug(' trigger.old update' +  trigger.old); 
       ContactTriggerController.countCOntact(trigger.new);
         ContactTriggerController.countCOntact(trigger.old);
    }
    
    if(trigger.isdelete && trigger.isafter){
        List<Contact> newCOntact = trigger.old;
        System.debug('Running after update' + newCOntact); 
         ContactTriggerController.countCOntact(trigger.old);
    }
    
    if(trigger.isundelete && trigger.isafter){
        List<Contact> newCOntact = trigger.new;
        System.debug('Running after update' + newCOntact);
          ContactTriggerController.countCOntact(trigger.new);
    }

}