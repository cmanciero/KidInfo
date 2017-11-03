//
//  HeightGrowthChartViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/16/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit
import Charts

class HeightGrowthChartViewController: UIViewController {
    var kid: Kid? = nil;
    var months: [String]!;
    var arrKidHeights: [Height]!;
    var arrDates: [Date]! = [];
    var arrHeights: [Double]! = [];

    @IBOutlet weak var lineChart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if(kid?.heights != nil){
            arrKidHeights = kid!.heights!.array as! [Height];
        }
        
        for ht in arrKidHeights{
            arrDates.append(ht.date! as Date);
            arrHeights.append(ht.height);
        }
        
        setChart(dataPoints: arrDates, values: arrHeights);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataPoints: [Date], values: [Double]){
        lineChart.noDataText = "You need to provide data for the chart";
        
        var dataEntries: [ChartDataEntry] = [];

        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i]);
            dataEntries.append(dataEntry)
        }
        
        lineChart.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        lineChart.xAxis.labelPosition = .bottom;
        // display values on xaxis
        //        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints);
        lineChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0);

        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Unites");
        let lineChartData = LineChartData(dataSet: lineChartDataSet);
        // set colors, array of colors to loop through for data point
        //        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)];
        //        lineChartDataSet.colors = ChartColorTemplates.material();
        lineChart.data = lineChartData;
        // sets description text in lower right corner
        lineChart.chartDescription?.text = "";
    }

    func convertHeight(nHeight: Double) -> Double{
        return nHeight;
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
