//
//  DayViewController.swift
//  Ravenclaw
//
//  Created by Aj Fermin on 10/03/2017.
//  Copyright © 2017 SourcePad. All rights reserved.
//

import UIKit
import CalendarKit
import DateToolsSwift
import DynamicColor
import Alamofire

class CalendarDayViewController: DayViewController, AddVCDelegate {
    
    let baseUrl = "http://52.23.109.219/rooms"
    let colors = [UIColor.blue,
                  UIColor.yellow,
                  UIColor.gray,
                  UIColor.green,
                  UIColor.red]
    
    var roomNo: Int = 0
    var events: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        dayView.dayHeaderView.delegate = self
        
//        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        getScheduleForDate(date: dayView.dayHeaderView.currentDate)
    }
    
    // MARK: DayViewDataSource
    
    override func eventViewsForDate(_ date: Date) -> [EventView] {

        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        var eventViews: [EventView] = []
        for event in events {
            
            let eventView = EventView()
            
            let startDate = df.date(from: (event["start_date"] as? String)!)
            let endDate = df.date(from: (event["end_date"] as? String)!)
            
            let duration = Calendar.current.dateComponents([.minute], from: startDate!, to: endDate!).minute ?? 0
            let datePeriod = TimePeriod(beginning: startDate, end: endDate)
           
            eventView.datePeriod = datePeriod
            eventView.data = [(event["event"] as? String)!, (event["description"] as? String)!, (event["creator"] as? String)!]
            eventView.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
            eventViews.append(eventView)
            
        }
        
        return eventViews
    }
    
    // MARK: DayViewDelegate
    
    override func dayViewDidSelectEventView(_ eventview: EventView) {
        
        print("Event has been selected: \(eventview.data)")
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        print("Event has been longPressed: \(eventView.data)")
    }
    
    @IBAction func barButtonAddTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ScheduleToAdd", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "ScheduleToAdd" {
            let addVC = segue.destination as? AddViewController
            addVC?.roomNo = roomNo
            addVC?.delegate = self
        }
    }
    
    func getScheduleForDate(date: Date) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: date)
        
        print(baseUrl + "/\(roomNo)?start_date=\(dateString)")
        
        Alamofire.request(baseUrl + "/\(roomNo)?start_date=\(dateString)", method: .get, encoding: URLEncoding.default).responseJSON { (response) in
            
            switch response.result {
            case .success(let data as NSDictionary):
                let dataData = data["data"] as? NSDictionary
                self.parseResponse(data: (dataData?["attributes"] as? NSDictionary)!)
                
            case .failure(let error):
                print(error)
                
            default: ()
            }
        }
    }
    
    func didFinishAddingSched() {
        _ = self.navigationController?.popViewController(animated: true)
        
        getScheduleForDate(date: dayView.dayHeaderView.currentDate)
    }
    
    func parseResponse(data: NSDictionary) {
        events = []
        events = data["schedule-for-day"] as! [NSDictionary]
        
        print(events)
        reloadData()

    }
}

