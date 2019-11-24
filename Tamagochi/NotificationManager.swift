//
//  NotificationManager.swift
//  Tamagochi
//
//  Created by Alessio Petrone on 21/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate{
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    // Seconds from last pic to send notification
    let foodInterval = 14400  // 4 hours
    let waterInterval = 7200 // 2 hours
    
    private let timeIntervalDemoMode = 300 // 5 minutes
    
    /**
     Ask permission to send local notifications
     */
    func requestAuthorization(){
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        notificationCenter.requestAuthorization(options: options) { (granted, error) in

            if granted == true && error == nil {
                print("User has granted notifications")
            }
        }
    }
    
    // Check notification permission before schedule notifications
    private func schedule(notification: Notification){
        notificationCenter.getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotification(notification)
            default:
                break // Do nothing
            }
        }
    }
    
    // Schedule
    private func scheduleNotification(_ notification: Notification){
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound    = .default

        let trigger: UNTimeIntervalNotificationTrigger
        
        if GlobalSettings.demoMode {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeIntervalDemoMode), repeats: false)
        }else{
           trigger = UNTimeIntervalNotificationTrigger(timeInterval: notification.timeInterval, repeats: false)
        }
            
            
        let request: UNNotificationRequest
        
        switch notification.id {
            case .hungry:
                request = UNNotificationRequest(identifier: "hungry", content: content, trigger: trigger)
            case .thirsty:
                request = UNNotificationRequest(identifier: "thirsty", content: content, trigger: trigger)
        }

        notificationCenter.add(request) { error in

            guard error == nil else { return }

            print("Notification scheduled! --- ID = \(notification.id)")
        }
    }
    
    /**
        Create notification that will be schedule.
     If notifications that will be scheduled have the same id, the system will replace it with the last added
     - Parameters _ notification: Notification that will be scheduled
     */
    func setNotification(_ notification: Notification ){
        schedule(notification: notification)
    }
    
    
    
    /**
     Send notification between 8am to 21pm. Notification after 21pm will be schedule at 8am
     */
    func scheduleNotificationByTimeRange(nowDate: Date, nextDate: Date, notification: Notification){
            
    }
    
    
    
    
    
    
    /**
     Remove notifications scheduled with specific ids
      - Parameters _ notification: Notification that will be scheduled
     */
    func removeScheduledNotifications(_ notificationsIds: [NotificationType]){
        var notif = [String]()
        
        for notification in notificationsIds {
            switch notification {
                
            case .hungry:
                notif.append("hungry")
            case .thirsty:
                notif.append("thirsty")
            }
        }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notif)
    }
}

struct Notification{
    let id: NotificationType
    let title: String
    let body: String
    var timeInterval: TimeInterval
}

enum NotificationType{
    case hungry
    case thirsty
}
