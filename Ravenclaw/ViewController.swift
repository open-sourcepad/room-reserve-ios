//
//  ViewController.swift
//  Ravenclaw
//
//  Created by Aj Fermin on 10/03/2017.
//  Copyright © 2017 SourcePad. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonBigConfTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "StartToSchedule", sender: sender)
    }

    @IBAction func buttonSmallConfTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "StartToSchedule", sender: sender)
    }
    
    @IBAction func buttonSleepTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "StartToSchedule", sender: sender)
    }
    
    @IBAction func buttonPumpTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "StartToSchedule", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "StartToSchedule" {
            let dayVC = segue.destination as? CalendarDayViewController
            dayVC?.roomNo = ((sender as? UIButton)?.tag)!
        }
    }
}

