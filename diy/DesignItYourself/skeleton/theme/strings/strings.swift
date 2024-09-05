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
        public static let appName = "Globe"
        public static let confirm = "Confirm"
        public static let cancel = "Cancel"
        public static let delete = "Delete"
        public static let modify = "Modify"
        public static let share = "Share"
        public static let setting = "Setting"
        public static let complete = "Complete"
        
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
        public static let dateFormatterRoute = "EEEE, MMMM d, yyyy"
        public static let dateFormatterPhoto = "MM/dd hh:mm"
    }
    
    struct alert {
        public static var apns = "notification"
        public static var api = "Api notification"
        public static var apiErrorServer = "Connection lost. Please try again later."
        public static var apiErrorClient = "Please check the internet connection and try again."
        public static var networkError = "We've lost your connection."
        public static var dataError = "No data."
        
        public static var requestAccessPhoto = "I need your photo."
        public static var requestAccessCamera = "I need your camera."
        public static var requestAccessPhotoText = "Take photos and mark them on the map."
        public static var requestAccessCameraText = "Take a photo and mark it on the map."
        
        public static var requestAccessLocation = "I need your location."
        public static var requestAccessLocationText = "To identify and display location information in photos."
        
        public static var inputLocation = "Please enter location information."
        public static var createGlobeStart = "Bring photos taken during your trip and record your travel itinerary."
        
        public static var limitedImageUpload = "You can only upload a maximum of %s images at a time."
        public static var limitedImageUploadSelect = "You can only select up to %s images."
        public static var unsavedExit = "Any unsaved information will be lost."
        public static var noInformationChanged = "No information has changed."
        public static var noPhotoSelected = "No photos selected."
        
        public static var existCategory = "The category you are trying to change already exists. Do you want to merge?"
        public static var deleteCategory = "All information in that category will be deleted.\nDo you want to continue?"
        
        public static let setupCategoryCompleted = "Would you like to go to that category?"
    }
    
    struct page {

        public static let additionalPhoto = "Additional photos"
        public static let needMoreInformation = "Need more information"
        
        public static let uploadSns = "Upload your travel picture to SNS."
        public static let shareRoute = "Share your travel route by GoogleMap."
        public static let globeRouteEmpty = "Bring photos to complete your itinerary."
        
        public static let globeCaptureEmpty = "Take a photo to remember your current location."
        public static let createRouteByCapture = "You can create a route by selecting a location."
        public static let setCategorySelectCapture = "Please import the captured location to add it to the category."
        public static let titleEmpty = "Enter the subject"
        
        public static let setupCategory = "Manage your location by setting categories."
        public static let setupCategoryInfo = "When you set a category, It is saved in the corresponding category in my location."
        
        public static let rateThePlace = "Please rate the place."
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
