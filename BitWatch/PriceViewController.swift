//
//  PriceViewController.swift
//  BitWatch
//
//  Created by Francisco Caro Diaz on 03/02/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit
import BitWatchKit

class PriceViewController: UIViewController {
  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var horizontalLayoutConstraint: NSLayoutConstraint!
  
  let tracker = Tracker()
  let xOffset: CGFloat = -22
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.tintColor = UIColor.blackColor()
    
    horizontalLayoutConstraint.constant = 0
    
    let originalPrice = tracker.cachedPrice()
    updateDate(tracker.cachedDate())
    updatePrice(originalPrice)
    tracker.requestPrice { (price, error) -> () in
      if error? == nil {
        self.updateDate(NSDate())
        self.updateImage(originalPrice, newPrice: price!)
        self.updatePrice(price!)
        
        if let userDefaults = NSUserDefaults(suiteName: "group.arequawatchkitapp") {
            userDefaults.setObject(price, forKey: "price")
            userDefaults.synchronize()
        }
        
        
     }
    }
  }
  
  private func updateDate(date: NSDate) {
    self.dateLabel.text = "Last updated \(Tracker.dateFormatter.stringFromDate(date))"
  }
  
  private func updateImage(originalPrice: NSNumber, newPrice: NSNumber) {
    if originalPrice.isEqualToNumber(newPrice) {
      horizontalLayoutConstraint.constant = 0
    } else {
      if newPrice.doubleValue > originalPrice.doubleValue {
        imageView.image = UIImage(named: "Up")
      } else {
        imageView.image = UIImage(named: "Down")
      }
      horizontalLayoutConstraint.constant = xOffset
    }
  }
  
  private func updatePrice(price: NSNumber) {
    self.priceLabel.text = Tracker.priceFormatter.stringFromNumber(price)
  }
}
