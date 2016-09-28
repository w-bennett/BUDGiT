
//Import frameworks
import UIKit
import Parse


class BudgetListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    
    //Make an outlet for the table view
    @IBOutlet weak var tableView: UITableView!
    var budgetNames = [String]()

    
    

    //Display alert given a title and string
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: {(action) -> Void in })
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    

    //On load...
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load all the users budgest and append them to an array
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        let query = PFQuery(className: "Budget")
        query.whereKey("createdBy", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFObject] {
                for object in objects {
                    let name = object["name"] as! String
                    self.budgetNames.append(name)
                    self.tableView.reloadData()
                }}})
    
        //Get the user's active budget and set the title
        let userQuery = PFUser.query()
        userQuery!.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        userQuery!.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFObject]{
                for object in objects{
                    userActiveBudget = object["budgetSelected"] as? String
                }}})
    }
    
    
    
    
    //Unused default function...
    override func didReceiveMemoryWarning() {super.didReceiveMemoryWarning()}
    
    
    

    //If we are creating a budget...
    @IBAction func createBudget(sender: AnyObject) {
        createBudgetActive = true
        performSegueWithIdentifier("createBudget", sender: self)
    }
    
    
    

    //If we are editing a budget...
    @IBAction func editBudget(sender: AnyObject) {
        if userActiveBudget != nil {
            createBudgetActive = false
            performSegueWithIdentifier("editBudget", sender: self)
        } else {displayAlert("Error", message: "No Active Budget Selected")}
    }

    
    
    
    //return number of rows total in table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return self.budgetNames.count}
    
    
    
    
    //For each row create a cell and assign the item in the array respective to the index returned by this function to that cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = self.budgetNames[indexPath.row]
        
        //If its the current active budget, assign a checkmark on load
        if userActiveBudget != nil{
            if self.budgetNames[indexPath.row] == String(userActiveBudget!)
            {cell.accessoryType = UITableViewCellAccessoryType.Checkmark}}
        return cell
    }
    
    
  
    
    //Add a checkmark to the selected budget and update parse
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        let activeBudgetName = budgetNames[indexPath.row]
        
        let query = PFUser.query()
        query!.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        query!.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFObject]{
                for object in objects{
                    userActiveBudget = activeBudgetName
                    object["budgetSelected"] = activeBudgetName
                    object.saveInBackground()
                    self.uncheck(activeBudgetName)
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    self.getTotalPerCategory()
                }}})
    
        //Get the totals for every category for the users selected budget
        //getTotalPerCategory()
    
    }
    
    
    
    
    //Re-calculate total for each category for use on budget analysis page
    func getTotalPerCategory(){
        
        //If there is no active budget, return
        if userActiveBudget == nil {return}
        
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
                for object in objects {foodTotal = foodTotal + ((object["amount"] as! Double) * -1.0)}}})
        
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
                for object in objects {otherTotal = otherTotal + ((object["amount"] as! Double) * -1.0)}}})
    }
    
    


    //http://stackoverflow.com/questions/29601294/how-to-loop-over-data-in-a-uitableview-in-swift
    //Loop through each cell to make sure only one is checked at a time
    func uncheck(activeBudgetName: String){
        for section in 0..<tableView.numberOfSections{
            for row in 0..<tableView.numberOfRowsInSection(section){
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                if cell?.textLabel?.text != activeBudgetName{
                    cell?.accessoryType = UITableViewCellAccessoryType.None}}}}
    
    
    
    
    //Go back to overview
    @IBAction func backToOverview(sender: AnyObject) {performSegueWithIdentifier("budgetToOverview", sender: self)}
    
    
    
    
    //Go to analysis
    @IBAction func toAnalysis(sender: AnyObject) {

        if foodTotal == 0 && entertainmentTotal == 0 && transportationTotal == 0 && billsTotal == 0 && otherTotal == 0 {
            displayAlert("Error", message: "No data")
            return
        }
        else if userActiveBudget == nil {
            displayAlert("Error", message: "No Active Budget Selected")
            return
        }
        else {
            performSegueWithIdentifier("budgetToAnalysis", sender: self)
        }

    }
    
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        var currentUser = PFUser.currentUser() // this will now be nil
        performSegueWithIdentifier("logout4", sender: self)
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return.LightContent
    }
    
    //Enables the editing of a cell, in this case deletion
    //http://stackoverflow.com/questions/24103069/swift-add-swipe-to-delete-tableviewcell
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    

    
    //This function provides a delete button upon swipe of a cell and defines what happens when it is pressed
    //http://stackoverflow.com/questions/24103069/swift-add-swipe-to-delete-tableviewcell
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){

        var errorMessage = "Error"
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let budgetToDelete = budgetNames[indexPath.row]
            budgetNames.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath],  withRowAnimation: UITableViewRowAnimation.Automatic)
            
            //Delete the purchases associated with the budget
            let purchases_query = PFQuery(className: "purchases")
            purchases_query.whereKey("budgetSelected", equalTo: budgetToDelete)
            purchases_query.whereKey("createdBy", equalTo:(PFUser.currentUser()?.objectId!)!)
            purchases_query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        object.deleteInBackgroundWithBlock({ (success, error) -> Void in
                            if (success) { //Good job!
                            } else {
                                if let errorString = error!.userInfo["error"] as? String {errorMessage = errorString}
                                self.displayAlert("Error", message: errorMessage)
                            }
                        })
                        self.tableView.reloadData()}}})
            
            //Delete the Budget from the Budget Class
            let query = PFQuery(className: "Budget")
            query.whereKey("name", equalTo: budgetToDelete)
            query.whereKey("createdBy", equalTo:(PFUser.currentUser()?.objectId!)!)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        object.deleteInBackgroundWithBlock({ (success, error) -> Void in
                            if (success) { //Good job!
                            } else {
                                if let errorString = error!.userInfo["error"] as? String {errorMessage = errorString}
                                self.displayAlert("Error", message: errorMessage)
                            }
                        })
                        self.tableView.reloadData()}}})
            
            
            
            
            //If the budget deleted is the user's active budget, update the User class so their active budget is nil
            if budgetToDelete == userActiveBudget {
                
                //Update the budgetSelected in the User Class
                let userQuery = PFUser.query()
                userQuery!.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
                userQuery!.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if let objects = objects as? [PFObject]{
                        for object in objects{
                            object.removeObjectForKey("budgetSelected")
                            object.saveInBackground()
                            userActiveBudget = nil
                        }}})}}
    }

    
    
    
}
