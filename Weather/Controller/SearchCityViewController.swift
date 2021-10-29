//
//  SearchCityViewController.swift
//  Weather
//
//  Created by fan on 10/28/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import RealmSwift

class SearchCityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tblView: UITableView!
    
    var arr = ["Seattle WA, USA", "Seaside CA, USA"]
    
    var arrCityInfo: [CityInfo] = [CityInfo]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCityInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("SecondTableViewCell", owner: self, options: nil)?.first as! SecondTableViewCell
        
        var city = arrCityInfo[indexPath.row] as! CityInfo
        
        cell.lblImage.text = city.localizedName + "  " + city.administrativeID +  "  " + city.countryLocalizedName
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addCityinDB(arrCityInfo[indexPath.row])
        arrCityInfo.removeAll()
        self.tblView.reloadData()
        
        
        
        
    }
    
    func addCityinDB(_ cityInfo : CityInfo){
        do{
            let realm = try Realm()
            try realm.write {
                realm.add(cityInfo, update: .modified)
            }
        }catch{
            print("Error in getting values from DB \(error)")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           print(searchText)
           if searchText.count < 3 {
               arrCityInfo.removeAll()
               self.tblView.reloadData()
            return
           }
           getCitiesFromSearch(searchText)

    }
    
    func getSearchURL(_ searchText : String) -> String{
            return locationSearchURL + "apikey=" + apiKey + "&q=" + searchText
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.dataSource = self
        tblView.delegate = self
        searchBar.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func getCitiesFromSearch(_ searchText : String) {
            // Network call from there
            let url = getSearchURL(searchText)
            
            self.arrCityInfo.removeAll()
            AF.request(url).responseJSON { response in
                
              print(JSON(response.data))
                if response.error != nil {
                    print(response.error?.localizedDescription)
                }
                
                let cities = JSON(response.data!).array
                print(cities![0])
                
                
                for i in 0 ... cities!.count - 1 {
//                    self.arr.append(cities![i]["Key"].stringValue)
                    let cityInfo = CityInfo()
                    
                    cityInfo.administrativeID = cities![i]["AdministrativeArea"]["ID"].stringValue
                    cityInfo.key = cities![i]["Key"].stringValue
                    cityInfo.type = cities![i]["Type"].stringValue
                    cityInfo.countryLocalizedName = cities![i]["Country"]["LocalizedName"].stringValue
                    cityInfo.localizedName = cities![i]["LocalizedName"].stringValue
                    
                    self.arrCityInfo.append(cityInfo)
                }
                
                self.tblView.reloadData()
                
                
                
                // You will receive JSON array
                // Parse the JSON array
                // Add values in arrCityInfo
                // Reload table with the values
            }
            
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
