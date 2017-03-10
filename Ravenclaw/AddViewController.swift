//
//  AddViewController.swift
//  Ravenclaw
//
//  Created by Aj Fermin on 10/03/2017.
//  Copyright © 2017 SourcePad. All rights reserved.
//

import UIKit
import Eureka
import Alamofire

class AddViewController: FormViewController {
    
    let addSched = "http://52.23.109.219/schedules"
    
    var roomName = ""
    var roomNo: Int = 0
    weak var delegate: AddVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch roomNo {
        case 101:
            roomName = "📍 Big Conference Room"
        case 102:
            roomName = "📍 Small Conference Room"
        case 103:
            roomName = "📍 Sleeping Room"
        case 104:
            roomName = "📍 Pump Room"
        default: ()
        }
        
        initializeForm()
    }
    
    private func initializeForm() {
        
        form =
            
            TextRow("Name").cellSetup { cell, row in
                cell.textField.placeholder = "👤 \(row.tag!)"
            }
            
            <<< TextRow("Event Title") { row in
                row.placeholder = "📌 \(row.tag!)"
            }
                
            <<< LabelRow () {
                $0.title = roomName
                $0.disabled = true
            }
            
            +++
            
            DateTimeInlineRow("Starts") {
                $0.title = "📅 \($0.tag!)"
//                $0.value = Date().addingTimeInterval(60*60*24)
                $0.dateFormatter?.dateStyle = .medium
                $0.dateFormatter?.timeStyle = .short
                }
                .onChange { [weak self] row in
                    let endRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Ends")
                    endRow.value = Date(timeInterval: 15, since: row.value!)
                    endRow.maximumDate = self?.endOfDayForDate(date: row.value!)
                    endRow.updateCell()
                }
                .onExpandInlineRow { cell, row, inlineRow in
                    inlineRow.cellUpdate { [weak self] cell, dateRow in
                        cell.datePicker.datePickerMode = .dateAndTime
                        cell.datePicker.minuteInterval = 15
                        cell.datePicker.minimumDate = Date()
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
            }
            
            <<< DateTimeInlineRow("Ends"){
                $0.title = "⏱ \($0.tag!)"
//                $0.value = Date().addingTimeInterval(60*60*25)
                $0.dateFormatter?.dateStyle = .none
                $0.dateFormatter?.timeStyle = .short
                }
                .onChange { [weak self] row in
                    row.updateCell()
                }
                .onExpandInlineRow { cell, row, inlineRow in
                    inlineRow.cellUpdate { [weak self] cell, dateRow in
                        let startRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Starts")
                         cell.datePicker.datePickerMode = .time
                         cell.datePicker.minuteInterval = 15
                         cell.datePicker.minimumDate = startRow.value!
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
        }
        
        form +++
            
            TextAreaRow("notes") {
                $0.placeholder = "📝 Notes"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
        }
        
    }
    
    func endOfDayForDate(date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: date)!
    }
    
    @IBAction func barButtonSaveTapped(_ sender: UIBarButtonItem) {
        let valuesDictionary = form.values()
        
        let name: String = (valuesDictionary["Name"] as? String)!
        let eventTitle: String = (valuesDictionary["Event Title"] as? String)!
        let eventNotes: String = (valuesDictionary["notes"] as? String)!
        let startDate: Date = (valuesDictionary["Starts"] as? Date)!
        let endDate: Date = (valuesDictionary["Ends"] as? Date)!
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let startDateString = df.string(from: startDate)
        let endDateString = df.string(from: endDate)
        
        let params = ["start_date": startDateString,
                      "end_date": endDateString,
                      "event": eventTitle,
                      "description": eventNotes,
                      "creator": name,
                      "room_tag": roomNo] as [String : Any]
        
        postSchedule(params: params)
    }
    
    func postSchedule(params: [String: Any]) {
        print(params)
        
        Alamofire.request(addSched, method: .post, parameters: ["schedule": params], encoding: JSONEncoding.default).responseJSON { (response) in
            
            switch response.result {
            case .success(let data as NSDictionary):
                
                print("BOOM \(data)")
                self.delegate?.didFinishAddingSched()
            case .failure(let error):
                print(error)
                
            default: ()
            }
        }
    }
}

protocol AddVCDelegate: class {
    func didFinishAddingSched()
}
