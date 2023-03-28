//
//  ScheduleDatePopupVC.swift
//  Bullet
//
//  Created by Mahesh on 15/06/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol ScheduleDatePopupVCDelegate: class {
    
    func dismissScheduleDateTimeSelected(dateTime: String, localDate: String)
}


class ScheduleDatePopupVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var viewNextButton: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnContinue: UIButton!

    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var lblTime: UILabel!

    var selectDateString = ""
    var curSelDate = Date()
    var localDate: Date?
    var selectDate: Date?
    var selectTime: Date?
    weak var delegate: ScheduleDatePopupVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.setLocalizableString()
        self.setDesignView()
        
        if !selectDateString.isEmpty {
                        
            if let selDate = SharedManager.shared.utcToLocal(dateStr: selectDateString) {
                curSelDate = selDate
                selectDate = selDate
                
                let selYear = curSelDate.dateString("yyyy")
                let curYear = Date().dateString("yyyy")
                
                if selYear == curYear {
                    lblDate.text = curSelDate.dateString("EE, MMM dd")
                }
                else {
                    lblDate.text = curSelDate.dateString("EE, MMM dd, yyyy")
                }
                lblTime.text = curSelDate.dateString("hh:mm a")
            }
        }
    }
    
    func setDesignView() {
        
        self.viewContainer.theme_backgroundColor = GlobalPicker.backgroundDiscoverHeader

        lblTitle.theme_textColor = GlobalPicker.textColor
        viewNextButton.theme_backgroundColor = GlobalPicker.themeCommonColor
        viewNextButton.cornerRadius = viewNextButton.frame.size.height / 2
        lblContinue.addTextSpacing(spacing: 2)

        viewDate.theme_backgroundColor = GlobalPicker.searchBGViewColor
        viewTime.theme_backgroundColor = GlobalPicker.searchBGViewColor
        
        lblDate.theme_textColor = GlobalPicker.textColor
        lblTime.theme_textColor = GlobalPicker.textColor
    }
    
    func setLocalizableString() {
        
        lblDate.text = NSLocalizedString("Select Date", comment: "")
        lblTime.text = NSLocalizedString("Select Time", comment: "")
        
        lblTitle.text = NSLocalizedString("Schedule Post", comment: "")
        lblMessage.text = NSLocalizedString("", comment: "")
        lblContinue.text = NSLocalizedString("CONTINUE", comment: "")
    }
    
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        let calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        mergedComponents.second = timeComponents.second
        
        return calendar.date(from: mergedComponents)
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapClose(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapContinue(_ sender: Any) {
        
        let stDate = lblDate.text?.trim() ?? ""
        let stTime = lblTime.text?.trim() ?? ""
        
        if stDate.isEmpty || stDate == NSLocalizedString("Select Date", comment: "") {
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Please select date", comment: ""))
            return
        }
        
        if stTime.isEmpty || stTime == NSLocalizedString("Select Time", comment: "") {
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Please select time", comment: ""))
            return
        }
        
        self.dismiss(animated: true) {
            
            if let date = self.selectDate, let time = self.selectTime {
                self.localDate = self.combineDateWithTime(date: date, time: time)
            }
            else {
                self.localDate = Date()
            }
            
            self.delegate?.dismissScheduleDateTimeSelected(dateTime: "\(stDate) \(stTime)", localDate: SharedManager.shared.localToUTC(date: self.localDate!))
            //print(SharedManager.shared.localToUTC(date: self.localDate!))
        }
    }

    
    @IBAction func didTapDate(_ sender: Any) {
        
        //Show date picker with min and max date
        RPicker.selectDate(title: NSLocalizedString("Select Date", comment: ""), cancelText: NSLocalizedString("Cancel", comment: ""), selectedDate: curSelDate, minDate: Date(), maxDate: Date().dateByAddingYears(5), didSelectDate: {[weak self] (selectedDate) in
            
            self?.curSelDate = selectedDate
            self?.selectDate = selectedDate
            
            let selYear = selectedDate.dateString("yyyy")
            let curYear = Date().dateString("yyyy")
            
            if selYear == curYear {
                self?.lblDate.text = selectedDate.dateString("EE, MMM dd")
            }
            else {
                self?.lblDate.text = selectedDate.dateString("EE, MMM dd, yyyy")
            }
        
            self?.lblTime.text = NSLocalizedString("Select Time", comment: "")
        })
    }
    
    @IBAction func didTapTime(_ sender: Any) {
        
        let setSelectDt = self.selectDate?.dateString("yyyy-MM-dd") ?? ""
        let curDate = Date().dateString("yyyy-MM-dd")
                
        // Simple Time Picker
        RPicker.selectDate(title: NSLocalizedString("Select Time", comment: ""), cancelText: NSLocalizedString("Cancel", comment: ""), datePickerMode: .time, selectedDate: curSelDate, minDate: curDate == setSelectDt ? Date() : nil, maxDate: curDate == setSelectDt ? Date().dateByAddingYears(5) : nil, didSelectDate: { [weak self](selectedDate) in
            
            self?.curSelDate = selectedDate
            self?.selectTime = selectedDate
            self?.lblTime.text = selectedDate.dateString("hh:mm a")
        })
    }
}

