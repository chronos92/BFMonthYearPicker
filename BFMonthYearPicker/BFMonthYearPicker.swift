//
//  BFMonthYearPicker.swift
//  Golee
//
//  Created by Boris Falcinelli on 14/06/16.
//  Copyright © 2016 Golee. All rights reserved.
//

import Foundation
import UIKit

public enum BFMonthYearPickerType {
    case MonthYear
    case Year
}

public class BFMonthYearPicker : UIPickerView {
    private var pickerDelegate : BFMonthYearPickerDelegate!
    var maxDate : NSDate? {
        didSet {
            pickerDelegate.maxDateSelected = maxDate
        }
    }
    var minDate : NSDate?
    var initDate : NSDate = NSDate() {
        didSet {
            reloadAllComponents()
            pickerDelegate.selectDate(initDate)
        }
    }
    
    var currentDate : NSDate = NSDate()
    
    var pickerType : BFMonthYearPickerType = .MonthYear {
        didSet {
            reloadAllComponents()
            pickerDelegate.selectDate(initDate)
        }
    }
    
    init() {
        super.init(frame: CGRectZero)
        self.pickerDelegate = BFMonthYearPickerDelegate(object: self)
        delegate = pickerDelegate
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        pickerDelegate = BFMonthYearPickerDelegate(object: self)
        delegate = pickerDelegate
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        reloadAllComponents()
        pickerDelegate.selectDate(initDate)
    }
}

internal class BFMonthYearPickerDelegate : NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let minYear : Int = 0
    private let maxYear : Int = 10000
    
    private var maxYearSelectable : Int = 10000
    private var maxMonthSelectable : Int = 12
    
    private var currentYear : Int { return getComponents(NSDate()).year+1 }
    private var currentMonth : Int { return getComponents(NSDate()).month }
    
    private var calendar : NSCalendar = {
       let cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(name: "GMT")!
        return cal
    }()
    
    var maxDateSelected : NSDate? {
        set {
            if newValue != nil {
                let comp = getComponents(newValue!)
                maxYearSelectable = comp.year
                maxMonthSelectable = comp.month
            } else {
                maxYearSelectable = 10000
                maxMonthSelectable = 12
            }
        }
        get {
            return picker.maxDate
        }
    }
    
    private let disabledTitleAttribute : [String:AnyObject] = [NSForegroundColorAttributeName : UIColor.lightGrayColor()]
    private let enabledTitleAttribute : [String:AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor()]

    private var selectedMonth : Int = 0 {
        didSet {
            let comp = getComponents(picker.currentDate)
            comp.month = selectedMonth+1
            picker.currentDate = calendar.dateFromComponents(comp)!
        }
    }
    private var selectedYear : Int = 0 {
        didSet {
            if picker.pickerType == .MonthYear {
                picker.reloadComponent(0)
                pickerView(picker, didSelectRow: selectedMonth, inComponent: 0)
            }
            let comp = getComponents(picker.currentDate)
            comp.year = selectedYear
            picker.currentDate = calendar.dateFromComponents(comp)!
        }
    }
    
    private var picker : BFMonthYearPicker
    private var years : [Int]
    private var months : [String] = {
        let formatter = NSDateFormatter()
        return formatter.monthSymbols
    }()
 
    init(object : BFMonthYearPicker) {
        years = Array(minYear...maxYear)
        picker = object
        super.init()
    }
    
    func selectDate(date : NSDate) {
        switch picker.pickerType {
        case .MonthYear:
            let comp = getComponents(date)
            selectedYear = comp.year
            selectedMonth = comp.month-1
            picker.selectRow(selectedYear, inComponent: 1, animated: false)
            picker.selectRow(selectedMonth, inComponent: 0, animated: false)
        case .Year:
            selectedYear = getComponents(date).year
            picker.selectRow(selectedYear, inComponent: 0, animated: false)
        }
//        picker.reloadAllComponents()
    }
    
    private func getComponents(date : NSDate) -> NSDateComponents {
        return calendar.components([ NSCalendarUnit.Year, NSCalendarUnit.Month, ], fromDate: date)
    }
    
    @objc func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        switch picker.pickerType {
        case .MonthYear: return 2
        case .Year: return 1
        }
    }
    
    @objc internal func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch picker.pickerType {
        case .MonthYear: return component == 0 ? months.count : years.count
        case .Year: return years.count
        }
    }
    
    @objc internal func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch (picker.pickerType,component) {
        case (.MonthYear,0):
            let month = months[row]
            let disabled = (selectedYear > maxYearSelectable) || (selectedYear == maxYearSelectable && row+1 > maxMonthSelectable)
            return NSAttributedString(string: month, attributes: disabled ? disabledTitleAttribute : enabledTitleAttribute)
        case (.MonthYear,1):
            let year = years[row]
            return NSAttributedString(string: "\(year)", attributes: year > maxYearSelectable ? disabledTitleAttribute : enabledTitleAttribute)
        case (.Year,_):
            let year = years[row]
            return NSAttributedString(string: "\(year)", attributes: year > maxYearSelectable ? disabledTitleAttribute : enabledTitleAttribute)
        default : return nil
        }
    }
    
    @objc internal func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch (picker.pickerType,component) {
        case (.MonthYear,0): //month
            var month = row
            let disabled = (selectedYear > maxYearSelectable) || (selectedYear == maxYearSelectable && row+1 > maxMonthSelectable)
            if disabled {
                month = maxMonthSelectable-1
            }
            picker.selectRow(month, inComponent: 0, animated: true)
            selectedMonth = month
        case (.MonthYear,1): //year
            var year = years[row]
            if year > maxYearSelectable {
                year = maxYearSelectable
            }
            picker.selectRow(year, inComponent: 1, animated: true)
            selectedYear = year
        case (.Year,_):
            var year = years[row]
            if year > maxYearSelectable {
                year = maxYearSelectable
            }
            picker.selectRow(year, inComponent: 0, animated: true)
            selectedYear = year
        default:break
        }
    }
}