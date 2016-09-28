import UIKit
import Parse

class categoryViewController: UIViewController, UINavigationBarDelegate, UITextFieldDelegate {
    
    
    //Variables to control the scroll view
    var activeField: UITextField?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    //Outlets for each text field
    @IBOutlet weak var foodField: UITextField!
    @IBOutlet weak var transportationField: UITextField!
    @IBOutlet weak var entertainmentField: UITextField!
    @IBOutlet weak var billsField: UITextField!
    @IBOutlet weak var otherField: UITextField!
    @IBOutlet weak var nameField: UITextField!

    //Active budget
    var activeBudgetID: String?
    
    
    
    
    
    
    
    
    //Display alert given a title and string. Add an ok button to it.
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: {(action) -> Void in })
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    
    //ADDED A QUERY FOR THE USERS ACTIVE BUDGET, ADDED SECOND WHERE KEY***********
    //https://gist.github.com/sideops/106a0b9b8a7da6d7713c Programmatically set a custom title
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        //Set tag
        nameField.tag = 1

        //Assign the current view controller as the delegte for the nameField
        self.nameField.delegate = self
        self.foodField.delegate = self
        self.transportationField.delegate = self
        self.entertainmentField.delegate = self
        self.billsField.delegate = self
        self.otherField.delegate = self
        
        // Create a navigation item with a title
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 20, self.view.frame.size.width, 44))
        navigationBar.backgroundColor = UIColor.whiteColor()
        navigationBar.delegate = self;
        let navigationItem = UINavigationItem()
        if createBudgetActive == true {navigationItem.title = "Create Budget"}
        else {navigationItem.title = "Edit Budget"}
        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: self, action: "goBack:")
        leftButton.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        
        
        //Get the user's active budget and set the title
        let userQuery = PFUser.query()
        userQuery!.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        userQuery!.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFObject]{
                for object in objects{
                    userActiveBudget = object["budgetSelected"] as? String
                }}})
        print("Loaded view: Current active budget: " + String(userActiveBudget))
        
        
        
        //If the activeBudget variable is not empty, then preload it!
        if userActiveBudget != nil && createBudgetActive == false {
            let query = PFQuery(className: "Budget")
            query.whereKey("name", equalTo: userActiveBudget!)
            query.whereKey("createdBy", equalTo:(PFUser.currentUser()?.objectId!)!)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        
                        //Set the active budgets ID
                        self.activeBudgetID = object.objectId
                        
                        //Load each class variable
                        let food = object["food"] as! Double
                        let entertainment = object["entertainment"] as! Double
                        let transportation = object["transportation"] as! Double
                        let other = object["other"] as! Double
                        let bills = object["bills"] as! Double
                        let name = object["name"] as! String
                        
                        //Set the textfields
                        self.foodField.text = String(food)
                        self.entertainmentField.text = String(entertainment)
                        self.transportationField.text = String(transportation)
                        self.otherField.text = String(other)
                        self.billsField.text = String(bills)
                        self.nameField.text = String(name)
                    }}})}}
    
    
    
    
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return.LightContent
    }
    
    
    
    
    
    
    
    
    
    
    //ADDED A SECOND WHERE KEY, CHANGED TOTAL TO NON-OPTIONAL, ADDED CASTING**************
    //Save the budget to Parse when edited or created
    @IBAction func saveBudget(sender: AnyObject) {
        
        //Default variables
        var errorMessage = "Error"
        var total = 0.0
        
        //Display an alert if the form is not complete
        if foodField.text == ""  || transportationField.text == "" || entertainmentField.text == "" || billsField.text == "" || otherField.text == "" || nameField.text == "" {
            displayAlert("Error in form", message: "Please fill in all fields")}
        
        //If we are creating a budget, check if the name already exists
        if createBudgetActive == true{
            let query = PFQuery(className:"Budget")
            query.whereKey("name", equalTo: nameField.text!)
            query.whereKey("createdBy", equalTo:(PFUser.currentUser()?.objectId!)!)
            query.findObjectsInBackgroundWithBlock {(objects, error) -> Void in
                if let object = objects{
                    if object.count > 0 {
                        self.displayAlert("Error", message: "This budget name already exists")
                    }
                    else{
                        //Initialize values
                        let budget = PFObject(className:"Budget")
                        budget["name"] = String(self.nameField.text!)
                        budget["food"] = Double(self.foodField.text!)
                        total = total + Double(self.foodField.text!)!
                        budget["entertainment"] = Double(self.entertainmentField.text!)
                        total = total + Double(self.entertainmentField.text!)!
                        budget["bills"] = Double(self.billsField.text!)
                        total = total + Double(self.billsField.text!)!
                        budget["other"] = Double(self.otherField.text!)
                        total = total + Double(self.otherField.text!)!
                        budget["transportation"] = Double(self.transportationField.text!)
                        total = total + Double(self.transportationField.text!)!
                        budget["total"] = total
                        budget["createdBy"] = PFUser.currentUser()?.objectId
                        //Save
                        budget.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                            if (success) {self.displayAlert("Success", message: "Budget Saved")}
                            else {
                                if let errorString = error!.userInfo["error"] as? String {errorMessage = errorString}
                                print(errorMessage)}}}}}}
            

        //Else createBudget Active = false, update the current selected object
        else {
            let query = PFQuery(className:"Budget")
            query.getObjectInBackgroundWithId(activeBudgetID!) {(object: PFObject?, error: NSError?) -> Void in
                
                if error != nil {print(error)}
                else if let object = object {

                    //Edit data fields
                    object["name"] = String(self.nameField.text!)
                    object["food"] = Double(self.foodField.text!)
                    total = total + Double(self.foodField.text!)!
                    object["entertainment"] = Double(self.entertainmentField.text!)
                    total = total + Double(self.entertainmentField.text!)!
                    object["bills"] = Double(self.billsField.text!)
                    total = total + Double(self.billsField.text!)!
                    object["other"] = Double(self.otherField.text!)
                    total = total + Double(self.otherField.text!)!
                    object["transportation"] = Double(self.transportationField.text!)
                    total = total + Double(self.transportationField.text!)!
                    object["total"] = total
            
                    object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if (success) {self.displayAlert("Success", message: "Budget Updated")}
                        else {
                            if let errorString = error!.userInfo["error"] as? String {errorMessage = errorString}
                            print(errorMessage)
                        }})}}
                    updateUserBudget()
        }
    }
    
    
    
    
    
    func updateUserBudget(){
        //Update the budgetSelected in the User Class
        let userQuery = PFUser.query()
        userQuery!.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        userQuery!.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFObject]{
                for object in objects{
                    userActiveBudget = String(self.nameField.text!)
                    object["budgetSelected"] = userActiveBudget
                    print("Saving new active budget:" + userActiveBudget!)
                    object.saveInBackground()
                }}})
    }
    
    
    
    //Perform user logout
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        var currentUser = PFUser.currentUser() // this will now be nil
        performSegueWithIdentifier("logout3", sender: self)
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
        self.view.frame.origin.y -= 209
        
    }
    
    func textFieldDidEndEditing(textField: UITextField!)
    {
        activeField = nil
        
        self.view.frame.origin.y += 209
        
        
    }

    
   
    
    //Hides the keyboard when the user touches away from it
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    

    
    
    //Hides the keyboard when the user tocuhes return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    //http://renren.io/questions/4102218/limit-uitextfield-to-one-decimal-point-swift
    //http://stackoverflow.com/questions/32638488/nil-is-not-compatible-with-expected-argument-type-uiviewanimationoptions
    //Prevents the user from typing more than one decimal point in any text field and non-numeric characters
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let c = textField
        if c.tag != 1 {
            
        //Array of characters
        var array = [Character]()
        
        //Get the interim string
        let interim = textField.text! + string
        
        //Put all characters in an array for parsing
        for c in interim.characters{
            array.append(c)
        }
        
        //If a decimal exists, check the difference between the new strings length and the old
        //If it's 4, then the user is trying to use 3 decimal places. Return false.
        if let i = array.indexOf("."){
            if array.count - i == 4 {
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
        }
        //If all tests pass, return true
        return true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {super.didReceiveMemoryWarning()}
    
    
    
    
    
    
    
    
    
    
    
    
    //Return to the previous screen
    func goBack(sender: AnyObject){
        performSegueWithIdentifier("backToBudgetList", sender: UIBarButtonItem())
    }
}
