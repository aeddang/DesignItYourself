//
//  strings.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

extension String {
    private static let isPad =  AppUtil.isPad()
    func loaalized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    struct app {
        public static let appName = "DiY"
        public static let confirm = "Confirm"
        public static let cancel = "Cancel"
        public static let yes = "Yes"
        public static let no = "No"
        public static let delete = "Delete"
        public static let modify = "Modify"
        public static let share = "Share"
        public static let setting = "Setting"
        public static let complete = "Complete"
        
        public static let pick = "Pick"
        public static let all = "All"
        public static let one = "One"
        
        //
        public static let update = "Update"
        public static let save = "Save"
        public static let saveAs = "Save as"
        
        public static let title = "Title"
        public static let category = "Category"
        public static let description = "Description"
        public static let location = "Location"
        public static let date = "Date"
        
        public static let addPhoto = "Add photo"
        public static let pickDate = "Pick a date"
        
        public static let upload = "Upload"
        public static let login = "Login"
        
        public static let locations = "My Locations"
        public static let routes = "My Routes"
        public static let captures = "Captured Images"
        public static let createRoute = "Create Route"
        public static let createCategory = "Create Category"
        public static let editPhoto = "Edit photo"
        public static let capture = "Take a photo"
       
        public static let uncheck = "Uncheck"
        public static let check = "Check"
    }
    
    struct format {
        public static let dateFormatterYMDHM = "EEEE, MMMM d, yyyy hh:mm"
        public static let dateFormatterYMD = "EEEE, MMMM d, yyyy"
        public static let dateFormatterMDHM = "MM/dd hh:mm"
    }
    
    struct alert {
        public static var apns = "notification"
        public static var api = "Api notification"
        public static var apiErrorServer = "Connection lost. Please try again later."
        public static var apiErrorClient = "Please check the internet connection and try again."
        public static var networkError = "We've lost your connection."
        public static var dataError = "No data."
        public static var dataEmpty = "No data."
        
        public static var existMaterial = "already exists."
        public static var includeSelectedMaterial = "Do you want to include current material?"
        public static var deleteMaterial = "All information in that category will be deleted.\nDo you want to continue?"
        
    }
    
    struct page {

        public static let additionalPhoto = "Additional photos"
    }
    
    
    struct week {
        static func getDayString(day:Int) -> String{
            switch day {
            case 2 : return "mon"
            case 3 : return "tue"
            case 4 : return "wed"
            case 5 : return "thu"
            case 6 : return "fri"
            case 7 : return "sat"
            case 1 : return "sun"
            default : return ""
            }
        }
    }
        
}
