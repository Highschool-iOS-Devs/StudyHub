//
//  TimerManager.swift
//  StudyHub
//
//  Created by Santiago Quihui on 01/09/20.
//  Copyright © 2020 Dakshin Devanand. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
class TimerManager: ObservableObject {
    
    var userData: UserData = UserData.shared
    
    var minutes = [5, 10, 30, 60]
    
    private var timer: Timer? = nil
    
    private var firstTimeRun = true
    @Published var isRunning = false
    
    @Published var timePassed = 0.0
    @Published var remainingTime = 0.0
    
    @Published var timeGoal = 0.0
    
    private var startDate = Date()
    var endDate = Date()
    
    private var pauseDate = Date()
    private var resumeDate = Date()
    
    private var totalTimePassed = 0.0
    
    private var hasSavedBefore = false
    
    @Published var studyHours = [Double]()
    @Published var studyDates = [String]()
    
    @Published var today = [Double]()
    @Published var month = [Double]()
    @State var i = 0
    @State var timerLog = TimerLog(id: UUID(), userID: "", category: "Math", time: 0.0, date: 0.0)
    @Published var category = "Math"
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            withAnimation(.linear(duration: 1.0)) {
                guard self.remainingTime > 0 else {
                    self.endTimer()
                    return
                }
                self.timePassed += 1.0
                self.remainingTime -= 1.0
            }
        })
        isRunning = true
        firstTimeRun = false
        saveToUD()
    }
    
    func setTimer(seconds: Double) {
        stopTimer()
        timePassed = 0
        timeGoal = seconds
        remainingTime = seconds
        startDate = Date()
        endDate = startDate.addingTimeInterval(timeGoal)
        startTimer()
    }
    
    func setTimer(minutes: Int) {
        let seconds = minutes * 60
        setTimer(seconds: Double(seconds))
    }
    
    func stopTimer() {
        timer?.invalidate()
        isRunning = false
    }
    
    func endTimer() {
        stopTimer()
        if timePassed > 300 {
            //only give credit if study time is longer than 5 minutes
            self.totalTimePassed += self.timePassed
        
            saveToFB()
           
        }
        resetTimer()
        saveToUD()
    }
    
    
    func resetTimer() {
        timeGoal = 0.0
        timePassed = 0.0
        isRunning = false
        remainingTime = 0.0
        startDate = Date()
        endDate = Date()
        firstTimeRun = true
    }
    
    func handleTap() {
        if self.firstTimeRun {
            withAnimation {
                self.timePassed = 0.0
            }
        } else if self.isRunning {
            self.stopTimer()
            self.pauseDate = Date()
            saveToUD()
        } else {
            self.startTimer()
            self.resumeDate = Date()
            let timePaused = resumeDate.timeIntervalSince(pauseDate)
            endDate.addTimeInterval(timePaused)
        }
    }
    
    func add(_ seconds: Double) {
        remainingTime += seconds
        timeGoal += seconds
        if firstTimeRun {
            startDate = Date()
            endDate = startDate.addingTimeInterval(timeGoal)
            startTimer()
        } else {
            endDate.addTimeInterval(seconds)
        }
    }
    
    func substract(_ seconds: Double) {
        let newRemainingTime = remainingTime - seconds
        guard newRemainingTime >= 0 else {
            remainingTime = 0
            timeGoal = 0
            return
        }
        remainingTime = newRemainingTime
        timeGoal -= seconds
        endDate.addTimeInterval(-seconds)
    }
    
    func saveToUD() {
        let defaults = UserDefaults.standard
        defaults.set(isRunning, forKey: "timerIsRunning")
        defaults.set(remainingTime, forKey: "timerRemainingTime")
        defaults.set(timePassed, forKey: "timePassed")
        defaults.set(endDate, forKey: "endDate")
        defaults.set(timeGoal, forKey: "timeGoal")
        defaults.set(firstTimeRun, forKey: "firstTimeRun")
        defaults.set(true, forKey: "hasSaved")
        defaults.set(pauseDate, forKey: "pauseDate")
        defaults.set(resumeDate, forKey: "resumeDate")
        defaults.set(totalTimePassed, forKey: "totalTime")
        hasSavedBefore = true
        defaults.set(hasSavedBefore, forKey: "hasSaved")
    }
    
    func loadData() {
        let defaults = UserDefaults.standard
        isRunning = defaults.bool(forKey: "timerIsRunning")
        let remaining = defaults.double(forKey: "timerRemainingTime")
        timePassed = defaults.double(forKey: "timePassed")
        endDate = defaults.object(forKey: "endDate") as? Date ?? Date()
        timeGoal = defaults.double(forKey: "timeGoal")
        
        pauseDate = defaults.object(forKey: "pauseDate") as? Date ?? Date()
        resumeDate = defaults.object(forKey: "resumeDate") as? Date ?? Date()
        hasSavedBefore = defaults.bool(forKey: "hasSaved")
        if hasSavedBefore {
            firstTimeRun = defaults.bool(forKey: "firstTimeRun")
            totalTimePassed = defaults.double(forKey: "totalTime")
        } else {
            getStudyHoursFromFB()
        }
        
        startFromLoadedData(remainingTime: remaining)
    }
    
   
    
    
    
    
    private func saveToFB() {
        print(totalTimePassed)
        getStudyHoursFromFB() 
        let db = Firestore.firestore()
         studyHours.append(totalTimePassed / 3600)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
         studyDates.append(dateFormatter.string(from: endDate))
        
        for date in studyDates {
        
           
            print(dateFormatter.date(from: date)!.get(.day))
        print( Date().get(.day) )
            if dateFormatter.date(from: date)!.get(.day) == Date().get(.day) {
                today.append(studyHours[i])
            }
           
            
            if dateFormatter.date(from: date)!.get(.month) == Date().get(.month) {
                month.append(studyHours[i])
            }
            i += 1
        }
        let sum = studyHours.reduce(0, +)
        let day = today.reduce(0, +)
        let months = month.reduce(0, +)
        let timerData: [String: Any] = [
            "studyDate" : studyDates,
            "studyHours" : studyHours,
            "all": sum,
            "day": day,
            "month": months
        ]
        db.collection("users").document(userData.userID).updateData(timerData) { error in
            if let error = error {
                print("Error updating data: \(error.localizedDescription)")
            } else {
                print("Success updating data")
            }
        }
       
       let timerLog = TimerLog(userID: userData.userID, category: category, time: timePassed, date: Double(NSDate().timeIntervalSince1970))
        do {
            try db.collection("timerLog").document(UUID().uuidString).setData(from: timerLog) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        } catch {
            
        }
    }
    
    private func getStudyHoursFromFB() {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(userData.userID)

        ref.getDocument { (document, error) in
            guard let document = document else {
                print("Error loading data: \(error)")
                return
            }
            self.studyHours = document.data()?["studyHours"] as? [Double] ?? [0.0]
            self.studyDates = document.data()?["studyDate"] as? [String] ?? [""]
            
            let data = document.data()?["studyHours"] as? [Double]
            self.totalTimePassed = data?.first ?? 0

        }
    }
    
    private func setNewRemainingTime() {
        let currentDate = Date()
        let newRemainingTime = endDate.timeIntervalSince(currentDate)
        let newTimePassed = timeGoal - newRemainingTime
        guard newRemainingTime > 0 else {
            remainingTime = 0
            timePassed = timeGoal
            return
        }
        remainingTime = newRemainingTime
        withAnimation {
            timePassed = newTimePassed
        }
        
    }
    
    func startFromLoadedData(remainingTime: Double) {
        guard firstTimeRun == false else { return }
        if isRunning {
            setNewRemainingTime()
            startTimer()
        } else {
            self.remainingTime = remainingTime
        }
    }
    
    func invalidateTimer() {
        timer?.invalidate()
    }
    
}
