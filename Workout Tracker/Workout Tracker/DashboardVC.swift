//
//  DashboardVC.swift
//  Workout Tracker
//
//  Created by Seschwan on 2/17/20.
//  Copyright © 2020 LambdaLabsPT7. All rights reserved.
//

import UIKit

class DashboardVC: UIViewController {
    
    let activityScheduledCellIdentifier = "activityScheduledCell"
    
    // MARK: - Outlets
    @IBOutlet weak var scheduleBtn: UIButton!
    @IBOutlet weak var viewAllScheduleBtn: UIButton!
    @IBOutlet weak var seeMoreProgressBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var activitiesSubView: UIView!
    @IBOutlet weak var overallProgressView: UIView!
    
    @IBOutlet weak var activitiesCountLbl: UILabel!
    
    @IBOutlet weak var sheildImageView: UIImageView!
    
    var recentlySavedDate = Date()
    
    var userController: UserController?
    
    let fbController = FBController()
    
    var arrayOfStoredSchedules = [ScheduledWorkout]()
    //    var arrayOfStoredSchedules = [Array<ScheduledWorkout>]()
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupUI()
        setupViewNibs()
        
        //fetchScheduledWorkouts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: .updateMyActivitiesTableView, object: nil)
        
        NotificationCenter.default.addObserver(forName: .updateDate, object: nil, queue: OperationQueue.main) { (notification) in
            let scheduleVC = notification.object as! CreateANewScheduleVC
            self.recentlySavedDate = scheduleVC.combinedTimeAndDate
            self.getScheduleFromStorage()
            self.tableView.reloadData()
        }
        getScheduleFromStorage()
//        checkForGoldStatus(totalCount)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    @objc func refreshTableView() {
        print("\nrefreshTableView Called\n")
        tableView.reloadData()
        
        
    }
    
    func setupUI() {
        let cornerRadius: CGFloat = 5
        let viewBorderColor = UIColor.systemGray.cgColor
        let borderWidth: CGFloat = 1
        
        scheduleBtn.layer.cornerRadius = cornerRadius
        viewAllScheduleBtn.layer.cornerRadius = cornerRadius
        seeMoreProgressBtn.layer.cornerRadius = cornerRadius
        
        overallProgressView.layer.borderColor = viewBorderColor
        overallProgressView.layer.borderWidth = borderWidth
        overallProgressView.layer.cornerRadius = cornerRadius
        activitiesSubView.backgroundColor = .systemBlue
    }
    
    func setupViewNibs() {
        
        let myNib2 = UINib(nibName: "ActivityScheduledTableViewCell", bundle: Bundle.main)
        tableView.register(myNib2, forCellReuseIdentifier: activityScheduledCellIdentifier)
    }
    
    @IBAction func goToCreateNewSchedule(_ sender: Any) {
        
        WorkoutController.chosenExercisesArray.removeAll()
        
        NotificationCenter.default.post(name: .updateCollectionView, object: self)
    }
    
    
    //    func fetchScheduledWorkouts() {
    //        fbController.fetchScheduledWorkouts { (error) in
    //            if let error = error {
    //                NSLog("There was an error fetching workouts in DashBoard")
    //            }
    //            self.tableView.reloadData()
    //        }
    //    }
    func getScheduleFromStorage() {
        let selectedDate = recentlySavedDate
        
        let fetched = WorkoutStorage.shared.fetch(exerciseDate: selectedDate)
        self.arrayOfStoredSchedules = fetched
        
        
    }
    
    fileprivate func checkForGoldStatus(_ totalCount: Int) {
        if totalCount >= 10 {
            sheildImageView.image = UIImage(named: "gold shield")
        }
    }
    
    @IBAction func seeMoreProgressTapped(_ sender: Any) {
        let fileManager = FileManager.default
        var totalCount = 0
        do {
            let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let enumerator = FileManager.default.enumerator(at: documentsURL,
                                                            includingPropertiesForKeys: resourceKeys,
                                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                print("directoryEnumerator error at \(url): ", error)
                                                                return true
            })!
            for case let fileURL as URL in enumerator {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                //                        print(fileURL.path, resourceValues.creationDate!, resourceValues.isDirectory!)
                
                if resourceValues.isDirectory == true {
                    let dirContents = try fileManager.contentsOfDirectory(atPath: fileURL.path)
                    for item in dirContents {
                        print("found \(item)")
                        let fetchedArray = WorkoutStorage.shared.fetchByString(exerciseDateString: item)
                        let scheduledCount = fetchedArray.count
                        print(scheduledCount)
                        totalCount += scheduledCount
                    }
                }
            }
        } catch {
            print(error)
        }
        print(totalCount)
        activitiesCountLbl.text = String(totalCount)
        checkForGoldStatus(totalCount)
    }
    
}

extension DashboardVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let someArray = arrayOfStoredSchedules
        let first1 = Array(someArray.prefix(1))
        
        
        return first1.count
        
        //return FBController.scheduledWorkoutArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: activityScheduledCellIdentifier, for: indexPath) as? ActivityScheduledTableViewCell else { return UITableViewCell() }
        
        cell.scheduleFromStorage = arrayOfStoredSchedules[indexPath.row]
        cell.workoutNameLabel.text = arrayOfStoredSchedules[indexPath.row].workoutName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        cell.dateScheduledLabel.text = dateFormatter.string(from: arrayOfStoredSchedules[indexPath.row].startTime!)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        cell.startTimeLabel.text = timeFormatter.string(from: arrayOfStoredSchedules[indexPath.row].startTime!)
        
        
        // Getting the workout name
        //        let workout = FBController.scheduledWorkoutArray[indexPath.row]
        //        cell.workoutNameLabel.text = workout.workoutName
        //
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateStyle = .short
        //        cell.dateScheduledLabel.text = dateFormatter.string(from: workout.startTime)
        //
        //        let timeFormatter = DateFormatter()
        //        timeFormatter.timeStyle = .short
        //        cell.startTimeLabel.text = timeFormatter.string(from: workout.startTime)
        
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toActivityDetail" {
            guard let destinationVC = segue.destination as? MyActivitiesDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            destinationVC.scheduleFromStorage = arrayOfStoredSchedules[indexPath.row]
            
        }
    }
    
    
}
