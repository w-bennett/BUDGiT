//Frameworks
import UIKit
import Parse

//Global variables
var numericTotal = 0.0
var totalAmount = 0.0

//Main view controller class
class OverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UINavigationBarDelegate {

    
    
    
    //Make an outlet for the table view
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalSpent: UILabel!
    @IBOutlet weak var totalBudget: UILabel!
    
    
    
    
    //Variables
    var userIDS = [String]()
    var customMessage = [String]()
    var amounts = [String]()
    var selectedIndexPath : NSIndexPath?
    
    
    
    
    //Display alert given a title and string
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: {(action) -> Void in })
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
    //On load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign the UIViewController to the be table views delegate
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 20, self.view.frame.size.width, 44))
        //navigationBar.barTintColor = UIColor(red: 9/255.0, green: 80/255.0, blue: 208/255.0, alpha: 1.0)
        
        
        navigationBar.delegate = self;
        let navigationItem = UINavigationItem()
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "add:")
        rightButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        
        //Reset total to 0, get the user's active budget and set the title
        var total = 0.0
        var adjustedTotal = 0.0
        numericTotal = 0.0
        let userQuery = PFUser.query()
        userQuery!.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        userQuery!.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFObject]{
                for object in objects{
                    userActiveBudget = object["budgetSelected"] as? String
                    
                    //If the user has an active budget
                    if userActiveBudget != nil {
                        navigationItem.title = String(userActiveBudget!)
                        
                        
                        //Load all of the users debits and credits into an array
                        let query = PFQuery(className: "purchases")
                        query.whereKey("createdBy", equalTo: (PFUser.currentUser()?.objectId)!)
                        query.whereKey("budgetSelected", equalTo: userActiveBudget!)
                        query.orderByDescending("createdAt")
                        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                            if let objects = objects as? [PFObject] {
                                for object in objects {
                                    
                                    //Set data fields
                                    let category = object["category"] as! String
                                    let reason = object["reason"] as! String
                                    let amount = object["amount"] as! Double
                                    
                                    //Get total
                                    total = total + amount
                                    numericTotal = numericTotal + amount
                                    adjustedTotal = total * -1
                                    
                                    //Set labels
                                    if total == 0 {self.totalSpent.text = "$" + String(0.0)}
                                    else {self.totalSpent.text = "$" + String(adjustedTotal)}
                                    var combined : String
                                    if amount<0{combined = "- $" + String(amount * -1) + " to " + category + " for " + reason}
                                    else{combined = "+ $" + String(amount) + " towards " + category + " for " + reason}
                                    
                                    //Save objects, append to arrays, reload the table
                                    object.saveInBackground()
                                    self.amounts.append(String(amount))
                                    self.userIDS.append(object.objectId!)
                                    self.customMessage.append(combined)
                                    self.tableView.reloadData()}}})
                        
                        //Get the totals for every category for the users active budget
                        self.getTotalPerCategory()
                        
                        //Get total amount spent
                        let budgetQuery = PFQuery(className:"Budget")
                        budgetQuery.whereKey("createdBy", equalTo:(PFUser.currentUser()?.objectId!)!)
                        budgetQuery.whereKey("name", equalTo: userActiveBudget!)
                        budgetQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                            if let objects = objects as? [PFObject] {
                                for object in objects {totalAmount = object["total"] as! Double}
                                self.totalBudget.text = "$" + String(totalAmount)
                            }}}
                        
                    //Else, no active budget
                    else {navigationItem.title = "No Active Budget"}}}})}
    

    
    
    //Re-calculate total for each category for use on budget analysis page
    func getTotalPerCategory(){
        
        //If there is no active budget, return
        if userActiveBudget == nil {
            print("No active budget")
            return
        }
        
        //Initialize values to 0
        foodTotal = 0.0
        entertainmentTotal = 0.0
        billsTotal = 0.0
        otherTotal = 0.0
        transportationTotal = 0.0

        //Query to find the total purchases toward food
        let foodQuery = PFQuery(className: "purchases")
        foodQuery.whereKey("createdBy", equalTo: (PFUser.currentUser()?.objectId)!)
        foodQuery.whereKey("category", equalTo: "food")
        foodQuery.whereKey("budgetSelected", equalTo: userActiveBudget!)
        foodQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFObject] {
                for object in objects {
                    foodTotal = foodTotal + ((object["amount"] as! Double) * -1.0)}}})
        
        //Query to find the total purchases toward entertainment
        let entertainmentQuery = PFQuery(className: "purchases")
        entertainmentQuery.whereKey("createdBy", equalTo: (PFUser.currentUser()?.objectId)!)
        entertainmentQuery.whereKey("category", equalTo: "entertainment")
        entertainmentQuery.whereKey("budgetSelected", equalTo: userActiveBudget!)
        entertainmentQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFObject] {
                for object in objects {entertainmentTotal = entertainmentTotal + ((object["amount"] as! Double) * -1.0)}}})
        
        //Query to find the total purchaes toward bills
        let billsQuery = PFQuery(className: "purchases")
        billsQuery.whereKey("createdBy", equalTo: (PFUser.currentUser()?.objectId)!)
        billsQuery.whereKey("category", equalTo: "bills")
        billsQuery.whereKey("budgetSelected", equalTo: userActiveBudget!)
        billsQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFObject] {
                for object in objects {billsTotal = billsTotal + ((object["amount"] as! Double) * -1.0)}}})
        
        //Query to find the total purchases towards transportation
        let transportationQuery = PFQuery(className: "purchases")
        transportationQuery.whereKey("createdBy", equalTo: (PFUser.currentUser()?.objectId)!)
        transportationQuery.whereKey("category", equalTo: "transportation")
        transportationQuery.whereKey("budgetSelected", equalTo: userActiveBudget!)
        transportationQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFObject] {
                for object in objects {transportationTotal = transportationTotal + ((object["amount"] as! Double) * -1.0)}}})
        
        //Query to find the total purchases towards others
        let otherQuery = PFQuery(className: "purchases")
        otherQuery.whereKey("createdBy", equalTo: (PFUser.currentUser()?.objectId)!)
        otherQuery.whereKey("category", equalTo: "other")
        otherQuery.whereKey("budgetSelected", equalTo: userActiveBudget!)
        otherQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFObject] {
                for object in objects {otherTotal = otherTotal + ((object["amount"] as! Double) * -1.0)}}})}
    

    
    
    //Defaut function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return.LightContent
    }

    
    //Check if the user has an active budget. If so, segue to debit/credit screen.
    @IBAction func add(sender: AnyObject) {
        if userActiveBudget == nil {displayAlert("Error", message: "No Active Budget Selected")}
        else {performSegueWithIdentifier("debitCredit", sender: self)}
    }


    
    
    //First button
    @IBAction func addBudget(sender: AnyObject) {
        performSegueWithIdentifier("overviewToBudget", sender: self)
    }
    
    
    
    
    //Second button
    @IBAction func viewAnalysis(sender: AnyObject) {
        
        if userActiveBudget == nil {
            displayAlert("Error", message: "No Active Budget Selected")
            return
        }
        else if foodTotal == 0.0 && entertainmentTotal == 0.0 && transportationTotal == 0.0 && billsTotal == 0.0 && otherTotal == 0.0 {
            displayAlert("Error", message: "No data")
            return
        }
        else {performSegueWithIdentifier("overviewToAnalysis", sender: self)}
    }
    
    
    //logout button
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        var currentUser = PFUser.currentUser() // this will now be nil
        performSegueWithIdentifier("logout", sender: self)
    }
    
  
    
    
    //return number of rows total in table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userIDS.count
    }


    
    
    //For each row create a cell and assign the item in the array respective to the index returned by this function to that cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = self.customMessage[indexPath.row]
        return cell
    }
    
    
    
    
    //When the user selects a row
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
    }
    
    

    
    //Enables the editing of a cell, in this case deletion
    //http://stackoverflow.com/questions/24103069/swift-add-swipe-to-delete-tableviewcell
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    

    
    
    //This function provides a delete button upon swipe of a cell and defines what happens when it is pressed
    //http://stackoverflow.com/questions/24103069/swift-add-swipe-to-delete-tableviewcell
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        
        //Set variables
        var adjustedLabelValue = 0.0
        var errorMessage = "Error"
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            //Assign the object ID of whatever row they press delete on
            let creditOrDebitToDelete = userIDS[indexPath.row]

            //Set labels and totals
            let labelValue = numericTotal - (Double(amounts[indexPath.row])!)
            if labelValue != 0 {adjustedLabelValue = labelValue * -1}
            else {adjustedLabelValue = 0}
            numericTotal = numericTotal - (Double(amounts[indexPath.row])!)
            totalSpent.text = "$" + String(adjustedLabelValue)
            
            //Remove the budget from arrays, dictionary, and table
            customMessage.removeAtIndex(indexPath.row)
            amounts.removeAtIndex(indexPath.row)
            userIDS.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath],  withRowAnimation: UITableViewRowAnimation.Automatic)
            
            //Delete the purchase from the purchases Class
            let query = PFQuery(className: "purchases")
            query.whereKey("objectId", equalTo: creditOrDebitToDelete)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        object.deleteInBackgroundWithBlock({ (success, error) -> Void in
                            if (success) {
                                self.getTotalPerCategory()
                            } else {
                                //Save the error
                                if let errorString = error!.userInfo["error"] as? String {errorMessage = errorString}
                                //Pass the saved error to an alert
                                self.displayAlert("Error", message: errorMessage)
                            }})
                        
                        self.tableView.reloadData() 
                    }}})}
    }
}


    