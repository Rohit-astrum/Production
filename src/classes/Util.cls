public class Util{
    public static Boolean run = true;
    
    public static Boolean runOnce(){
        if (run){
            run = false;
            return true;
        }
        
        return false;
    }
}