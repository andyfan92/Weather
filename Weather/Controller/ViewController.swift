//
//  ViewController.swift
//  Weather
//
//  Created by fan on 10/28/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let arr = ["Seattle WA, USA 54 °F", "Delhi DL, India, 75°F"]
    
    
    var arrCityInfo: [CityInfo] = [CityInfo]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tblView.delegate = self
        tblView.dataSource = self
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        arrCurrentWeather.removeAll()
        loadCurrentConditions()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(arr.count)
        return arrCurrentWeather.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("FirstTableViewCell", owner: self, options: nil)?.first as! FirstTableViewCell
        
        cell.lblImage.text = arrCurrentWeather[indexPath.row].cityInfoName + "      " + String(arrCurrentWeather[indexPath.row].temp) + "°F     " + arrCurrentWeather[indexPath.row].weatherText
        cell.imgView.image = UIImage(named: String(arrCurrentWeather[indexPath.row].weatherIcon))
        
        return cell
    }
    
    func loadCurrentConditions(){
            
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Read all the values from realm DB and fill up the arrCityInfo
        // for each city info het the city key and make a NW call to current weather condition
        // wait for all the promises to be fulfilled
        // Once all the promises are fulfilled fill the arrCurrentWeather array
        // call for reload of tableView
        
        do{
            let realm = try Realm()
            let cities = realm.objects(CityInfo.self)
            self.arrCityInfo.removeAll()
            getAllCurrentWeather(Array(cities)).done { currentWeather in
               self.tblView.reloadData()
            }
            .catch { error in
               print(error)
            }
       }catch{
           print("Error in reading Database \(error)")
       }
            
            
            
    }
    
    func getAllCurrentWeather(_ cities: [CityInfo] ) -> Promise<[CurrentWeather]> {
                
        var promises: [Promise< CurrentWeather>] = []
        
        if cities.count == 0 {
            return when(fulfilled: promises)
        }
        for i in 0 ... cities.count - 1 {
            promises.append( getCurrentWeather(cities[i].key, cities[i].localizedName + "," + cities[i].administrativeID))
        }
        
        return when(fulfilled: promises)
                
    }
    
    func getCurrentWeather(_ cityKey : String, _ cityName : String) -> Promise<CurrentWeather>{
        return Promise<CurrentWeather> { seal -> Void in
            let url = currentConditionURL + cityKey + "?apikey=" + apiKey // build URL for current weather here
            
            AF.request(url).responseJSON { response in
                
                if response.error != nil {
                    seal.reject(response.error!)
                }
                
                print(response)
                let currentWeather = CurrentWeather()
                let weathers = JSON(response.data!).array
                currentWeather.cityKey = cityKey
                currentWeather.cityInfoName = cityName
                currentWeather.weatherText = weathers![0]["WeatherText"].stringValue
                currentWeather.temp = weathers![0]["Temperature"]["Imperial"]["Value"].intValue
                currentWeather.epochTime = weathers![0]["EpochTime"].intValue
                currentWeather.isDayTime = weathers![0]["IsDayTime"].boolValue
                currentWeather.weatherIcon = weathers![0]["WeatherIcon"].intValue
                self.arrCurrentWeather.append(currentWeather)
                seal.fulfill(currentWeather)
                
            }
        }
    }


}

