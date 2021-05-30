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
    
    // Time formater
    lazy var dateFormater: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
    // Background Image
    var imageView: UIImageView = {
          let imageView = UIImageView(frame: .zero)
          imageView.image = UIImage(named: "background.jpg")
        imageView.contentMode = .scaleAspectFill
          imageView.translatesAutoresizingMaskIntoConstraints = false
          return imageView
      }()
    
    @IBOutlet weak var foodsLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var lastEatenLabel: UILabel!
    @IBOutlet weak var imageName: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var numberOfTimesLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var myChoiceImage: UIImageView!
    
    @IBAction func segmentedCtrlPressed(_ sender: Any) {
        
    }
    
    // Method for inserting data from dictionary to Interface
    private func insertDataFrom(selectedFood food: Food) {
        imageName.image = UIImage(data: food.imageData!)
        foodsLabel.text = food.foods
        typeLabel.text = food.type
        myChoiceImage.isHidden = !(food.myChoice)
        ratingLabel.text = "Rating: \(food.rating) / 10"
        numberOfTimesLabel.text = "Number of times: \(food.numberOfTimes)"
        
        lastEatenLabel.text = "Last time eaten: \(dateFormater.string(from: food.lastEaten!))"
        
        // segment
        segmentedControl.tintColor = food.tintColor as? UIColor
    }
    
    // Method for extracting data from file
    private func getDataFromFile() {
        
        // Fetch
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "foods != nil ") // what we want to get
        
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
            food.foods = foodDictionary["foods"] as? String
            food.type = foodDictionary["type"] as? String
            food.rating = foodDictionary["rating"] as! Double
            food.lastEaten = foodDictionary["lastEaten"] as? Date
            food.myChoice = foodDictionary["myChoice"] as! Bool
            food.numberOfTimes = foodDictionary["numberOfTimes"] as! Int16
            
            
            // Image
            let imageName = foodDictionary["imageName"] as? String
            let image = UIImage(named: imageName!)
            let imageData = image!.pngData()
            food.imageData = imageData
            
            
            // Tasty
            if let colorDictionary = foodDictionary["tintColor"] as? [String: Float] {
                // getting value as Array
                food.tintColor = getColor(colorDictionary: colorDictionary)
    }
  }
}
    
    // Method getTasty
    private func getColor(colorDictionary: [String: Float]) -> UIColor {
        guard let red = colorDictionary["red"],
              let green = colorDictionary["green"],
              let blue = colorDictionary["blue"] else { return UIColor()}
        return UIColor(red: CGFloat(red / 255), green: CGFloat(green / 255), blue: CGFloat(blue / 255), alpha: 1.0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background
        view.insertSubview(imageView, at: 0)
              NSLayoutConstraint.activate([
                  imageView.topAnchor.constraint(equalTo: view.topAnchor),
                  imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                  imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                  imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
              ])
        
        //Segmented Control Title Color
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)
        
        // getting data from data.plist
        getDataFromFile()   // Can be implemented by USER DEFAULTS
        
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let foods = segmentedControl.titleForSegment(at: 0)
        fetchRequest.predicate = NSPredicate(format: "foods == %@", foods!) // what we want to get
        
        do{
            let results = try context.fetch(fetchRequest)
            let selectedFood = results.first
            insertDataFrom(selectedFood: selectedFood!)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }


}

