public without sharing class D2D_ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
	public D2D_ChangePasswordController() {}

    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);
    }     
}