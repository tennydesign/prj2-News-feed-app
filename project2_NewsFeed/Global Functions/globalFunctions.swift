//
//  globalFunctions.swift
//  project2_NewsFeed
//
//  Created by Tennyson Pinheiro on 10/16/17.
//  Copyright © 2017 Tenny. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SystemConfiguration

var storedKeywords: [NSManagedObject] = []

func from(link: String) -> UIImageView? {
    
    guard let url = URL(string: link),
        let data = try? Data(contentsOf: url),
        let image = UIImage(data: data)
        else {
            return nil
    }
    
    return UIImageView(image: image)
}

var getPublishedDateTIme: (String) -> [String] = { strToConvert in
    return strToConvert.components(separatedBy: CharacterSet(charactersIn: "T,Z"))
}

func getElapsedTimeFromISO8601(pDate: String) -> String
{
    let dateFormatter = ISO8601DateFormatter()
    guard let date = dateFormatter.date(from:pDate) else {
        return " - "
    }
    
    let now = Date()
    let publishedDate = date //now.addingTimeInterval(24 * 3600 * 17)
    
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .abbreviated
    let elapsedTime = formatter.string(from: publishedDate, to: now)!
    
    
    return elapsedTime
}

func weekMonthDayNum() -> (String,String) {
    let date = NSDate()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat  = "EEEE"//"EE" to get short style
    let weekday = dateFormatter.string(from: date as Date)//"Sunday"
    dateFormatter.dateFormat  = "MMMM"
    let monthName = dateFormatter.string(from: date as Date)
    dateFormatter.dateFormat  = "dd"
    let DayNum = dateFormatter.string(from: date as Date)
    
    let monthPlusDay = monthName + " " + DayNum
    return (weekday,monthPlusDay)
}

func iconForWeatherConditions() {
    let urlString = "https://api.darksky.net/forecast/205cf9c34b36d818c09542488fa6a347/37.8267,-122.4233"
    let requestUrl = URL(string:urlString)
    let request = URLRequest(url:requestUrl!)

    if (isConnectedToNetwork()) {
    let task = URLSession.shared.dataTask(with: request) {
        (data, response, error) in
        

        if error == nil, let data = data {
            print("JSON Received...File Size: \(data) \n")

            do {
                

                let weatherJson = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                
                
                let weatherDict = weatherJson["currently"] as! [String: Any]
                
                DispatchQueue.main.async  {
                    let iconName = String(describing: weatherDict["icon"] ?? "defaultWeather")
                    News.sharedINstance.weatherIcon = UIImage(named: iconName)!
                    News.sharedINstance.updateWeatherIcon()
                }
                
            } catch {
                print("Error deserializing JSON: \(error)")
            }

        } else {
            print("Networking Error: \(String(describing: error) )")
        
        }
        
    }

    task.resume()
    } else {
         News.sharedINstance.weatherIcon = #imageLiteral(resourceName: "nowifi2")
    }
}

func checkIfIsCategory(stringToCheck: String) -> Bool {
    
    return true
}


// Making it work
func callSynAPI(keyword: String) {
    let keyword = keyword.replacingOccurrences(of: " ", with: "%20")
    let urlString = "https://api.datamuse.com/words?ml=" + keyword
    let requestUrl = URL(string:urlString)
    let request = URLRequest(url:requestUrl!)
    var synWords = [""]
    let task = URLSession.shared.dataTask(with: request) {
        (data, response, error) in
        
        
        if error == nil, let data = data {
            print("JSON Received...File Size: \(data) \n")
            
            do {
                
                
                let syn = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:Any]]
                
                for i in syn {
                    synWords = [String(describing: i["word"])]
                }
                
                // let weatherDict = syn["currently"] as! [String: Any]
                
                DispatchQueue.main.async  {
                    //                    let iconName = String(describing: weatherDict["icon"] ?? "defaultWeather")
                    //                    News.sharedINstance.weatherIcon = UIImage(named: iconName)!
                    //                    News.sharedINstance.updateWeatherIcon()
                }
                
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
        } else {
            print("Networking Error: \(String(describing: error) )")
            
        }
        
    }
    
    task.resume()
    
}

//MARK: Core data functions

func getContext() -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.persistentContainer.viewContext
}

func saveToDisk(Keyword: String) {
    
    // 1 - create a Managed Context
    let managedContext = getContext()
    // 2 - creating the entity
    let entity = NSEntityDescription.entity(forEntityName: "SearchKeywords", in: managedContext)!
    // 3 - creating the register
    let searchTerm = NSManagedObject(entity: entity, insertInto: managedContext)
    // 4 - appending the register to the field
    searchTerm.setValue(Keyword, forKeyPath: "keywordField")
    
    //5 - Saving to disk
    do {
        try managedContext.save()
        storedKeywords.append(searchTerm)
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
    }
}

func deleteFromDisk(fromRow: Int) {
    //persisting data to disk//
    
    let searchTerm = storedKeywords[fromRow]
    getContext().delete(searchTerm)
    (UIApplication.shared.delegate as! AppDelegate).saveContext()
    
    fetchDataFromDisk()
}

func fetchDataFromDisk() {
   // News.sharedINstance.keywords = [""]
    let managedContext = getContext()
    
    //2
    let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "SearchKeywords")
    
    //3
    do {
        storedKeywords = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    for item in storedKeywords {
        News.sharedINstance.keywords.append((item.value(forKeyPath: "keywordField") as? String)!)
    }
    
}

func DeleteAllData(){
    let managedContext = getContext()
    let DeleteAllRows = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "SearchKeywords"))
    do {
        try managedContext.execute(DeleteAllRows)
    }
    catch {
        print(error)
    }
}

func saveKeyWordsToDisk() {
    DeleteAllData()
    for item in News.sharedINstance.keywords {
        saveToDisk(Keyword: item)
    }
}

// Networking



var networkIsReachable: Bool = false

func isConnectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    
    return (isReachable && !needsConnection)
    
}
