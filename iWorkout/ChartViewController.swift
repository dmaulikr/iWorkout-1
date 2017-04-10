//
//  BarChartViewController.swift
//  iWorkout
//
//  Created by Dayan Yonnatan on 26/12/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import UIKit
import Charts

@objc class ChartViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
    //@IBOutlet weak var pieChartView: PieChartView!
    
    var days:[String]!
    var trackerTitle:String! = nil

    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }

        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Units performed")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        
        lineChartView.data = lineChartData
        lineChartView.chartDescription?.text = "Date"
        lineChartDataSet.circleColors = ChartColorTemplates.colorful()
        
        setupXLabels()
        setupXAxis(labelCount: dataPoints.count)
        setupYAxis()
    }
    
    func setupXLabels() {
        self.lineChartView.xAxis.granularity = 1
        self.lineChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { (index, _) -> String in
            return self.days[Int(index)]
        })
    }
    
    func setupYAxis() {
        setupYAxis(yAxis: lineChartView.rightAxis)
        setupYAxis(yAxis: lineChartView.leftAxis)
    }
    func setupYAxis(yAxis:YAxis) {
        yAxis.forceLabelsEnabled = true
        yAxis.axisMinimum = 1.0
    }
    func setupXAxis(labelCount:Int) {
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.avoidFirstLastClippingEnabled = false
        lineChartView.xAxis.forceLabelsEnabled = true
        
        lineChartView.xAxis.drawAxisLineEnabled = true
        lineChartView.xAxis.setLabelCount(labelCount, force: true)
    }
    
    
    func showWelcome(withValues values:[Double]) {
        let highScore = (Int, Double)(getHighscore(values))
        let highscoreUnits = highScore.1
        let highscoreIndex = highScore.0
        
        let daysSkipped = getMissedDays(values)
        
        var alertString = "You have a high score of \(highscoreUnits) on \(days[highscoreIndex])."
        
        if(daysSkipped > 2) {
            alertString.append("\nBut you have skipped \(daysSkipped) days of \(self.trackerTitle!). No worries, just keep training hard!")
        } else {
            alertString.append("\nWe are seeing a great consistency, keep training hard!")
        }
        
        let alert = UIAlertController(title: "This is a tracker of your progression", message:alertString, preferredStyle: .alert)
        let thanksAction = UIAlertAction(title: "Thanks!", style: .default, handler: nil)
        alert.addAction(thanksAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    func getHighscore(_ values:[Double]) -> (Int,Double) {
        var highScore = 0.0
        var indexOfScore = 0
        var index = 0
        
        for unit in values {
            if(unit > highScore) {
                highScore = unit
                indexOfScore = index
            }
            index += 1
        }
        return (indexOfScore, highScore)
    }
    func getMissedDays(_ values:[Double]) -> Int {
        var count = 0
        
        for unit in values {
            if(unit == 0.0) {
                count += 1
            }
        }
        return count
    }
    
    
    func setTrackerTitle(title:String) {
        self.trackerTitle = title
    }

    func isDataEmpty(name: String) -> Bool {
        let chartsCreator:ChartsCreator = ChartsCreator(withExerciseName: name)
        let _ = chartsCreator.fetchLastTenExercises() 
        

        return chartsCreator.checkIfDataIsEmpty()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let title = self.trackerTitle {
            
            let chartsCreator:ChartsCreator = ChartsCreator(withExerciseName: title)
            //let unitsPerformed = chartsCreator.fetchLastTenExercises() as [Double]
            let unitsPerformed = chartsCreator.fetchLastTenExercises() as! [Double]
            
            days = chartsCreator.retrieveDatesAsStrings()
            lineChartView.delegate = self
            
            setChart(dataPoints: days, values: unitsPerformed)
            
            if(chartsCreator.checkIfDataIsEmpty()) {
                // Not enough data to draw chart
                showInsufficientData()
                print("Showing insufficient data!")
                self.dismiss(animated: true, completion: nil)
            } else {
                // Show welcome
                showWelcome(withValues: unitsPerformed)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInsufficientData() {
        let alert = UIAlertController(title: "No data", message: "There is insufficient data for the last 10 workouts days to draw a chart", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .destructive, handler: { (action) in
            _ = self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion:nil)
    }
    
    func showActionSheetFor(index:Int, withCount count:Double) {
        let selectedDate = getFullDateFromString(days[index])
        
        let actionSheet = UIAlertController(title: "\(selectedDate)", message: "You performed \(count) of \(self.trackerTitle!) on \(selectedDate)", preferredStyle: .actionSheet)
        
        let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        actionSheet.addAction(dismiss)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    func getFullDateFromString(_ dateString:String) -> String {
        let origDateFormat = DateFormatter()
        origDateFormat.dateFormat = "dd/MM/yy"
        let date = origDateFormat.date(from: dateString)
        
        return DateFormat.getDateString(from: date, with: 4)
    }
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let index = Int(entry.x)
        showActionSheetFor(index: index, withCount: entry.y)
    }
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("Nothing selected")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
