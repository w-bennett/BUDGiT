import UIKit
import Parse

class DebitCreditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationBarDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    //Variables to control the scroll view
    var activeField: UITextField?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //Outlets for picker views. Tags set manually in utilities menu.
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerView2: UIPickerView!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var reasonField: UITextField!
    
    //Budget categories that the user wills select from
    let items = ["food", "entertainment", "bills", "transportation", "other"]
    let action = ["debit", "credit"]

    //Set users choice
    var pickerView1choice = 0
    var pickerView2choice = 0
    
    //Display alert given a title and string
    func displayAlert(title: String, message: String){
        
        //Create alert object
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Add a button to dismiss the alert
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: {(action) -> Void in })
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //Set delegates
        self.amount.delegate = self
        self.reasonField.delegate = self
        pickerView.delegate = self
        pickerView2.delegate = self
        pickerView.dataSource = self
        pickerView2.dataSource = self
        reasonField.tag = 1
        
        // Offset by 20 pixels vertically to take the status bar into account
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 20, self.view.frame.size.width, 44))
        navigationBar.backgroundColor = UIColor.whiteColor()
        navigationBar.delegate = self;
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Add Debit or Credit"
   
        // Create left button for navigation item
        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: self, action: "goBack:")
        leftButton.tintColor = UIColor.whiteColor()
        
        // Create button for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Populate rows
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return items[row]
        } else {
            return action[row]
        }
    }
    
    //Return number of rows
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return items.count
        } else {
            return action.count
        }
    }
    
    //Retrurn number of sections
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Get selected answer
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            pickerView1choice = row
        } else {
            pickerView2choice = row
        }
    
    }
    
    //Return to the previous screen
    func goBack(sender: AnyObject){
        performSegueWithIdentifier("backToOverview", sender: UIBarButtonItem())
    }
    
    //http://renren.io/questions/4102218/limit-uitextfield-to-one-decimal-point-swift
    //http://stackoverflow.com/questions/32638488/nil-is-not-compatible-with-expected-argument-type-uiviewanimationoptions
    //Prevents the user from typing more than one decimal point in any text field and non-numeric characters
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        //Array of characters
        var array = [Character]()

        //Get the interim string
        let interim = textField.text! + string
        
        //Put all characters in an array for parsing
        for c in interim.characters{
            array.append(c)
        }
        
        let c = textField
        if c.tag != 1 {
            print("init")
        //Only allow 4 digits before the decimal point
                if array.count==5{
                    if let _ = array.indexOf("."){
                        //nothing
                    } else{
                        return false
                    }
                }
        
                //Return false if the user is trying to use 3 decimal places
                if let i = array.indexOf("."){
                    if array.count - i == 4{
                        return false
                    }
                }
        
                //Check if valid numeric character
                let invalidCharacters = NSCharacterSet(charactersInString: "0123456789.").invertedSet
                if let _ = string.rangeOfCharacterFromSet(invalidCharacters, options: [], range:Range<String.Index>(start: string.startIndex, end: string.endIndex)) {
                    return false
                }
        
                //Check if decimal point already exists
                let tempRange = textField.text!.rangeOfString(".", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil)
                if tempRange?.isEmpty == false && string == "." {
                    return false
                }
        } else {
                print ("init")
                if array.count == 15 {
                    return false
                }
                
            }
        
            //If all tests pass, return true
            return true
    }
    
   
    @IBAction func submit(sender: AnyObject) {
        
        //Default error message.
        var errorMessage = "Could not save. Please try again later."
        var creditOrDebit = ""
        
        //Display an alert if the form is not complete
        if self.amount.text == "" || self.reasonField.text == "" {
            displayAlert("Error in form", message: "Please enter the amount.")
        } else{
            
            //Else, set the objects data fields
            let addition = PFObject(className:"purchases")
            addition["createdBy"] = PFUser.currentUser()?.objectId
            addition["category"] = items[pickerView1choice]
            addition["budgetSelected"] = userActiveBudget
            addition["reason"] = String(self.reasonField.text!)
            
            //Make it negative addition if debit
            if pickerView2choice == 0 {
                addition["amount"] = Double(self.amount.text!)! * -1
                creditOrDebit = "Budget Debited"
            } else{
                addition["amount"] = Double(self.amount.text!)
                creditOrDebit = "Budget Credited"
            }
            
            //Save the item and catch error (if any)
            addition.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    self.displayAlert("Success", message: creditOrDebit)
                } else {
                    if let errorString = error!.userInfo["error"] as? String {errorMessage = errorString}
                    self.displayAlert("Error", message: errorMessage)
                }
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return.LightContent
    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        var currentUser = PFUser.currentUser() // this will now be nil
        performSegueWithIdentifier("logout2", sender: self)
    }
    
    
    
    //Series of functions that scrolls view up when a textfield is selected
    //code comes from http://stackoverflow.com/questions/28813339/move-a-view-up-only-when-the-keyboard-covers-an-input-field
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.scrollEnabled = true
        var info : NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        var contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeFieldPresent = activeField
        {
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        
        
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        var info : NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        var contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.scrollEnabled = false
        
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField!)
    {
        activeField = textField
        print (activeField)
        self.view.frame.origin.y -= 216
        
    }
    
    func textFieldDidEndEditing(textField: UITextField!)
    {
        activeField = nil
        
        self.view.frame.origin.y += 216
        
        
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
    

}
