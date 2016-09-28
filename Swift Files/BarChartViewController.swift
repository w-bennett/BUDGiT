//http://www.appcoda.com/ios-charts-api-tutorial/
//This tutorial taught us how to use the open source library ios-charts manually installed in our project

import UIKit
import Charts
import Parse
class BarChartViewController: UIViewController, ChartViewDelegate {
    
    
    
    
    //Variables & outlets
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var pieChartView: PieChartView!
    var foodCap = 0.0
    var entertainmentCap = 0.0
    var transportationCap = 0.0
    var otherCap = 0.0
    var billsCap = 0.0
    var total = 0.0
    var errorMessage = "Error"
    let categories = ["Food", "Ent.", "Bills", "Trans.", "Other"]
    var categories2 = [String]()
    var unitsSold2 = [Double]()
    var maxValue = 0.0
    var maxArray = [Double]()
    
    
    //Display alert given a title and string. Add an ok button to it.
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: {(action) -> Void in })
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
    //On load...
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set delegates
        barChartView.delegate = self
        pieChartView.delegate = self

        //Set pie chart tag and values
        pieChartView.tag = 1
        if foodTotal != 0 {
            categories2.append("Food")
            unitsSold2.append(foodTotal)
        }
        if entertainmentTotal != 0 {
            categories2.append("Ent.")
            unitsSold2.append(entertainmentTotal)
        }
        if billsTotal != 0 {
            categories2.append("Bills")
            unitsSold2.append(billsTotal)
        }
        if transportationTotal != 0 {
            categories2.append("Trans.")
            unitsSold2.append(transportationTotal)
        }
        if otherTotal != 0 {
            categories2.append("Other")
            unitsSold2.append(otherTotal)
        }
        
        setPieChart(categories2, values: unitsSold2)
        
        
        
        //Set bar chart
        let unitsSold1 = [foodTotal, entertainmentTotal, billsTotal, transportationTotal, otherTotal]
        maxArray = [foodCap, entertainmentCap, transportationCap, otherCap, billsCap, unitsSold1.maxElement()!]
        maxValue = maxArray.maxElement()!
        setChart(categories, values: unitsSold1)
        
        //Query to load all the users caps
        let query = PFQuery(className:"Budget")
        query.whereKey("createdBy", equalTo: (PFUser.currentUser()?.objectId!)!)
        query.whereKey("name", equalTo: userActiveBudget!)
        query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil{
            if let objects = objects as? [PFObject]{
                for object in objects{
                    self.foodCap = object["food"] as! Double
                    self.entertainmentCap = object["entertainment"] as! Double
                    self.transportationCap = object["transportation"] as! Double
                    self.otherCap = object["other"] as! Double
                    self.billsCap = object["bills"] as! Double
                    self.total = foodTotal + entertainmentTotal + transportationTotal + otherTotal + billsTotal
                }}}
            else{
                 if let errorString = error!.userInfo["error"] as? String {self.errorMessage = errorString}
                self.displayAlert("Error", message: self.errorMessage)}}
    }
    
    
    
    
    //Set bar chart
    func setChart(dataPoints: [String], var values: [Double]) {
        
        //Set properties of barChart
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        barChartView.legend.enabled = false
        barChartView.xAxis.setLabelsToSkip(0)
        barChartView.doubleTapToZoomEnabled = false
        barChartView.descriptionText = ""
        barChartView.leftAxis.customAxisMax = maxValue+25
        barChartView.rightAxis.enabled = false
        //barChartView.backgroundColor = UIColor.lightTextColor()
        
        //Create an array of BarChartDataEntry objects given the passed arguments.
        var dataEnteries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEnteries.append(dataEntry)
        }
        
        //Use this to create a BarChartDataSet. Then use this to create a BarChartData object which we set as our chart view’s data.
        //Afterwards, enable the chart data
        let chartDataSet = BarChartDataSet(yVals: dataEnteries, label: "Units Sold")
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        barChartView.data = chartData
        
        //Randomly generate colors
        var colors: [UIColor] = []
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        chartDataSet.colors = colors
    }
    
    
    
    
    //For pie chart
    func setPieChart(dataPoints: [String], values: [Double]) {
        
        
        //Set properties of pieChart
        pieChartView.animate(xAxisDuration: 2.0)
        pieChartView.legend.enabled = false
        pieChartView.descriptionText = ""
        pieChartView.data?.setValueTextColor(UIColor.clearColor())
        //pieChartView.backgroundColor = UIColor.lightTextColor()
        //pieChartView.holeColor = UIColor(red: 164/255.0, green: 205/255.0, blue: 255/255.0, alpha: 1.0)
        
        //Create an array of PieChartDataEntry objects given the passed arguments.
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        //Use this to create a PieChartDataSet. Then use this to create a PieChartData object which we set as our chart view’s data.
        //Afterwards, enable the chart data
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Units Sold")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartDataSet.drawValuesEnabled = false
        pieChartView.data = pieChartData
        
        
        //Randomly generate colors
        var colors: [UIColor] = []
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = colors
    
        
    }

    
    
    
    //When selecting a chart
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        
        //To get the percentage
        let numberOfPlaces = 2.0
        let multiplier = pow(10.0, numberOfPlaces)
        var touchedCategory = String()
        
        //Determine which category array to use
        if chartView.tag == 0{touchedCategory = "\(categories[entry.xIndex])"}
        else {touchedCategory = "\(categories2[entry.xIndex])"}
    
        //Remove existing lines from the bar graph
        barChartView.leftAxis.removeAllLimitLines()
        
        //Depending on which category was touched...
        switch touchedCategory{
            case "Food":
                print(touchedCategory)
                if chartView.tag == 0{
                    let ll = ChartLimitLine(limit: foodCap, label: "Target")
                    print("Selected bar graph, pressing food")
                    barChartView.leftAxis.addLimitLine(ll)
                }
                else{
                    print("Selected pie graph, pressing food")
                    let num = (foodTotal/total)*100
                    let rounded = round(num * multiplier) / multiplier
                    pieChartView.centerText = String(rounded) + "%"
                }
            
            case "Ent.":
                if chartView.tag == 0{
                    print("Selected bar graph, pressing ent.")
                    let ll = ChartLimitLine(limit: entertainmentCap, label: "Target")
                    barChartView.leftAxis.addLimitLine(ll)
                }
                else{
                    print("Selected pie graph, pressing ent.")
                    let num = (entertainmentTotal/total)*100
                    let rounded = round(num * multiplier) / multiplier
                    pieChartView.centerText = String(rounded) + "%"
            }
            
            case "Trans.":
                if chartView.tag == 0{
                    print("Selected bar graph, pressing Trans")
                    let ll = ChartLimitLine(limit: transportationCap, label: "Target")
                    barChartView.leftAxis.addLimitLine(ll)
                }
                else{
                    print("Selected pie graph, pressing Trans")
                    let num = (transportationTotal/total)*100
                    let rounded = round(num * multiplier) / multiplier
                    pieChartView.centerText = String(rounded) + "%"
            }
            
            case "Bills":
                if chartView.tag == 0{
                    print("Selected bar graph, pressing bills")
                    let ll = ChartLimitLine(limit: billsCap, label: "Target")
                    barChartView.leftAxis.addLimitLine(ll)
                }
                else{
                    print("Selected pie graph, pressing bills")
                    let num = (billsTotal/total)*100
                    let rounded = round(num * multiplier) / multiplier
                    pieChartView.centerText = String(rounded) + "%"
            }
            
            case "Other":
                if chartView.tag == 0{
                    print("Selected bar graph, pressing other")
                    let ll = ChartLimitLine(limit: otherCap, label: "Target")
                    barChartView.leftAxis.addLimitLine(ll)
                }
                else{
                    print("Selected pie graph, pressing other")
                    let num = (otherTotal/total)*100
                    let rounded = round(num * multiplier) / multiplier
                    pieChartView.centerText = String(rounded) + "%"            }
            
            default:
                print("error")
            
            
        }
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return.LightContent
    }
    
    //Back to overview
    @IBAction func analysisToOverview(sender: AnyObject) {
        performSegueWithIdentifier("analysisToOverview", sender: self)
    }
    
    
    
    
    //Back to budget
    @IBAction func analysisToBudgets(sender: AnyObject) {
        performSegueWithIdentifier("analysisToBudgets", sender: self)
    }
    
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        var currentUser = PFUser.currentUser() // this will now be nil
        performSegueWithIdentifier("logout5", sender: self)
    }
    
   
    
}
