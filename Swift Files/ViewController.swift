
//Frameworks
import UIKit
import Parse

//Global variables
var signupActive = true
var createBudgetActive = true
var foodTotal = 0.0
var entertainmentTotal = 0.0
var billsTotal = 0.0
var transportationTotal = 0.0
var otherTotal = 0.0

//The users current budget as a global variable
var userActiveBudget: String? = String()

class ViewController: UIViewController, UITextFieldDelegate {
    
    //Outlets for text boxes
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var topButtonMessage: UIButton!
    @IBOutlet weak var bottomButtonMessage: UIButton!
    
    
    //Display alert given a title and string
    func displayAlert(title: String, message: String){
        
        //Create alert object
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Add a button to dismiss the alert
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: {(action) -> Void in })
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return.LightContent
    }
  
    @IBAction func topButton(sender: AnyObject) {
        
        //Switch to login mode
        if signupActive == true {
            email.hidden = true
            bottomButtonMessage.setTitle("Log In", forState: UIControlState.Normal)
            topText.text = "Not Registered?"
            topButtonMessage.setTitle("Sign Up", forState: UIControlState.Normal)
            signupActive = false
            
        }
        else {
            email.hidden = false
            bottomButtonMessage.setTitle("Sign Up", forState: UIControlState.Normal)
            topText.text = "Already Registered?"
            topButtonMessage.setTitle("Login", forState: UIControlState.Normal)
            signupActive = true
        }
    }
    
   
    @IBAction func bottomButton(sender: AnyObject) {
        
        //Default error message
        var errorMessage = "Error"
        
        //Display an alert if the form is not complete
        if username.text == ""  || password.text == "" {
            displayAlert("Error in form", message: "Please enter username and password")
        }else {
            //Try to Signup
            if signupActive == true {
                //Create Parse Framework object and assign the entered fields
                let user = PFUser()
                user.username = username.text
                user.password = password.text
                user.email = email.text
                
                //Invoke signup function from parse
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    
                    //If signup is successful
                    if error == nil {
                        self.performSegueWithIdentifier("login", sender: self)
                    }
                    else {
                        //Save the error
                        if let errorString = error!.userInfo["error"] as? String {errorMessage = errorString}
                        
                        //Pass the saved error to an alert
                        self.displayAlert("Could Not Sign Up", message: errorMessage)
                    }
                })
            }
                
            //Try to log in
            else {
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
                    //User is found
                    if user != nil {
                        self.performSegueWithIdentifier("login", sender: self)
                    }
                        
                    //Else user is not found, Save error
                    else {
                        //Save the error
                        if let errorString = error!.userInfo["error"] as? String {errorMessage = errorString}
                        
                        //Pass the saved error to an alert
                        self.displayAlert("Could Not Login", message: errorMessage)
                    }
                })
            }
        }
    }
    
  
    //Hides the keyboard when the user touches away from it
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    //Hides the keyboard when the user tocuhes return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }


    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.username.delegate = self
        self.password.delegate = self
        self.email.delegate = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

