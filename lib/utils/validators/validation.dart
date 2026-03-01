
class AppValidator {

  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) return 'Please enter $fieldName';
    return null;
  }

  static String? validateEmail (String? value) {
    if (value == null || value.isEmpty) return 'Please enter an email address';

    final emailReg = RegExp( r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
    if(!emailReg.hasMatch(value)) {return 'Please enter a valid email address';}
 
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';

    if (value.length < 6) return 'Password must be at least 6 characters';

    //Check for uppeercase letters
    //if (!value.contains(RegExp(r'[A-Z]'))) return 'Password must contain at least one uppercase letter';

     //Check for numbers
   //  if (!value.contains(RegExp(r'[0-9]'))) return 'Password must contain at least one number';

    //check for special characters
   // if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return 'Password must contain at least one special character';
 
    return null;
    
  }
 
  static String? validatePhone(String? value) {
  if (value == null || value.isEmpty) return 'Please enter a phone number';

  final phoneReg = RegExp(r'^(09|\+639)\d{9}$');
  if (!phoneReg.hasMatch(value)) return 'Please enter a valid phone number';

  return null;
}
 

}
