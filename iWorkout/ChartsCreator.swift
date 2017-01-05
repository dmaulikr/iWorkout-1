//
//  ChartsCreator.swift
//  iWorkout
//
//  Created by Dayan Yonnatan on 04/01/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import Foundation
import UIKit


@objc class ChartsCreator: NSObject {
    
    // To fetch data for the selected exercise
    let exerciseName:String!
    
    // The data, after being sorted.
    var sortedArrayOfDates:[Date]!
    var sortedArrayOfData:[NSNumber]!
    
    // The dictionary of key & value pairs retrieved from AppDelegate
    var dictionaryOfData:[String:NSNumber]!
    
    // General date format to use with the dates
    var dateFormat:DateFormatter!
    
    init(withExerciseName exercise:String) {
        exerciseName = exercise
        sortedArrayOfDates = [Date]()
        dictionaryOfData = [String:NSNumber]()
        sortedArrayOfData = [NSNumber]()
        dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
    }
    func retrieveDates() -> [Date] {
        return sortedArrayOfDates as [Date]
    }
    
    func retrieveDatesAsStrings() -> [String] {
        let newDateFormat = DateFormatter()
        newDateFormat.dateFormat = "dd/MM/yy"
        
        let newArray = NSMutableArray()
        for (date) in sortedArrayOfDates.enumerated() {
            newArray.add(newDateFormat.string(from: date.element))
        }
        return newArray.copy() as! [String]
    }
    func retrieveDataForDate(date:Date) -> Double {
        let dateString = dateFormat.string(from: date)
        return dictionaryOfData[dateString]!.doubleValue
    }
    func retrieveDataForString(dateString:String) -> Double {
        return dictionaryOfData[dateString]!.doubleValue
    }
    func fetchLastTenExercises() -> [NSNumber] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        dictionaryOfData = appDelegate.fetchLastTenExercises(forExerciseName: exerciseName) as! [String : NSNumber]!
        
        for (_, element) in dictionaryOfData!.enumerated() {
            sortedArrayOfDates.append(dateFormat.date(from: element.key)!)
        }
      
        sortedArrayOfDates.sort()
        
        for (date) in sortedArrayOfDates.enumerated() {
            let dateString = dateFormat.string(from: date.element)
            sortedArrayOfData.append(dictionaryOfData[dateString]!)
        }
        
        if(checkIfDataIsEmpty()) {
            print("Data is empty!")
        }
        
        
        return sortedArrayOfData
    }
    
    func checkIfDataIsEmpty() -> Bool {
        var totalDouble = Double()
        for data in sortedArrayOfData.enumerated() {
            totalDouble = totalDouble + data.element.doubleValue
        }
        if(totalDouble > 0.0) {
            return false
        }
        
        return true
    }
    
}
