//
//  ViewController.swift
//  MyFoodChoice
//
//  Created by Daniyar Mussin on 30.05.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var numberOfTimesLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var PickerView: UIPickerView!
    @IBOutlet weak var myChoiceImage: UIImageView!
    
    @IBAction func eatButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func rateButtonPressed(_ sender: Any) {
    }
    
    
    // Method for extracting data from file
    private func getDataFromFile() {
        
        // Fetch
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mark != nil ") // what we want to get
        
        var records = 0
        
        do {
            records = try context.count(for: fetchRequest)
            print("Is Data There Already?")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        // how many records we do have in RECORDS
        guard records == 0 else { return }
        
        guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"),
              let dataArray = NSArray(contentsOfFile: pathToFile) else { return }
        
    // itteration and placing to core data as an objects
        for dictionary in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "Food", in: context)
            let food = NSManagedObject(entity: entity!, insertInto: context) as! Food
            
            let foodDictionary = dictionary as! [String : AnyObject]
            food.food = foodDictionary["food"] as? String
            food.type = foodDictionary["type"] as? String
            food.rating = foodDictionary["rating"] as! Double
            food.lastEated = foodDictionary["lastEated"] as? Date
            food.myChoice = foodDictionary["myChoice"] as! Bool
            food.numberOfTimes = foodDictionary["numberOfTimes"] as! Int16
            
            
            // Image
            let imageName = foodDictionary["imageName"] as? String
            let image = UIImage(named: imageName!)
            let imageData = image?.pngData()
            food.imageData = imageData
            
            
            // Tasty
            if let tastyDictionary = foodDictionary["tasty"] as? [String: Float] {
                // getting value as Array
                food.tasty = getTasty(tastyDictionary: tastyDictionary)
    }
  }
}
    
    // Method getTasty
    private func getTasty(tastyDictionary: [String: Float]) -> UIColor {
        guard let red = tastyDictionary["red"],
              let green = tastyDictionary["green"],
              let blue = tastyDictionary["blue"] else { return UIColor()}
        return UIColor(red: CGFloat(red / 255), green: CGFloat(green / 255), blue: CGFloat(blue / 255), alpha: 1.0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // getting data from data.plist
        getDataFromFile()   // Can be implemented by USER DEFAULTS
    }


}

