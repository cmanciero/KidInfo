//
//  WeightGrowthChartViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/16/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit
//import Charts

class WeightGrowthChartViewController: UIViewController {
    var kid: Kid? = nil;
    var months: [String]!;
    var arrKidWeights: [Weight]!;
    var arrDates: [Date]! = [];
    var arrWeights: [Double]! = [];
    
//    @IBOutlet weak var lineChart: LineChartView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad();

        // Do any additional setup after loading the view.
//        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        if(kid?.weights != nil){
            arrKidWeights = kid!.weights!.array as! [Weight];
        }
        
        for wt in arrKidWeights{
            arrDates.append(wt.date! as Date);
            arrWeights.append(wt.weight);
        }
        
//        setChart(dataPoints: arrDates, values: arrWeights);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataPoints: [Date], values: [Double]){
//        lineChart.noDataText = "You need to provide data for the chart";
        
//        var dataEntries: [ChartDataEntry] = [];
        
//        for i in 0..<dataPoints.count {
//            let dataEntry = ChartDataEntry(x: Double(i), y: values[i]);
//            dataEntries.append(dataEntry)
//        }
  
//        lineChart.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
//        lineChart.xAxis.labelPosition = .bottom;
        // display values on xaxis
//        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints);
//        lineChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0);
        
//        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Unites");
//        let lineChartData = LineChartData(dataSet: lineChartDataSet);
        // set colors, array of colors to loop through for data point
//        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)];
//        lineChartDataSet.colors = ChartColorTemplates.material();
//        lineChart.data = lineChartData;
        // sets description text in lower right corner
//        lineChart.chartDescription?.text = "";
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
