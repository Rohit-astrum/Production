public with sharing class DatePickerComponentController {
    public String currentDate{get; set;}
 
    public DatePickerComponentController() {
        currentDate = Date.Today().format();
    }
}