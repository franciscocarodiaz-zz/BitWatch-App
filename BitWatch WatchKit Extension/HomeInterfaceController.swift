//
//  InterfaceController.swift
//  BitWatch WatchKit Extension
//
//  Created by Francisco Caro Diaz on 03/02/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import WatchKit
import Foundation
import BitWatchKit

class HomeInterfaceController: WKInterfaceController {

    let tracker = Tracker()
    var updating = false
    var _eventsData:[Event] = []
    var theVideos:[YoutubeVideo] = []
    
    // Image collection
    @IBOutlet weak var mainImage: WKInterfaceImage!
    @IBOutlet weak var mainTitle: WKInterfaceLabel!
    var index : Int = 0
    @IBAction func nextTapped() {
        index++
        self.loadImage()
    }
    
    private func loadImage(){
    
        if (index >= theVideos.count){
            self.index = 0
        }
        let videoYoutube = theVideos[index]
            let url = NSURL(string: videoYoutube.thumbnail as String);
            let picData = NSData(contentsOfURL: url!);
            let img = UIImage(data: picData!);
            
            let mainTitle = theVideos[index].title as String
            
            self.updateMainInfo(mainTitle, _mainImage: img!)
        
        
        
        
    
    }
    
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    @IBOutlet weak var image: WKInterfaceImage!
    @IBOutlet weak var lastUpdatedLabel: WKInterfaceLabel!
    @IBOutlet weak var priceLabel: WKInterfaceLabel!
    @IBAction func refreshTapped() {
        update()
    }
    
    @IBOutlet weak var buttonRefresh: WKInterfaceButton!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        
        // Configure interface objects here.
        updatePrice(tracker.cachedPrice())
        
        image.setHidden(true)
        updateDate(tracker.cachedDate())
        
        _eventsData = Event.eventsList()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        update()
        setupTable()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: Helper method
    
    private func setupTable() {
        
        var rowTypesList = [String]()
        
        for event in _eventsData {
            
            var typeFound = false
            
            if let eventImage = event.eventImageName {
                if strlen(eventImage) > 0 {
                    rowTypesList.append("ImportantEventRow")
                    typeFound = true
                }
            }
            
            if typeFound == false {
                rowTypesList.append("OrdinaryEventRow")
            }
        }
        
        tableView.setRowTypes(rowTypesList)
        
        for var i = 0; i < tableView.numberOfRows; i++ {
            
            let row: AnyObject? = tableView.rowControllerAtIndex(i)
            let event = _eventsData[i]
            
            if row is ImportantEventRow {
                let importantRow = row as ImportantEventRow
                importantRow.eventImage.setImage(UIImage(named: event.eventImageName!))
                importantRow.titleLabel.setText(event.eventTitle)
                importantRow.timeLabel.setText(event.eventTime)
            } else {
                let ordinaryRow = row as OrdinaryEventRow
                ordinaryRow.titleLabel.setText(event.eventTitle)
                ordinaryRow.timeLabel.setText(event.eventTime)
            }
        }
        
    }
    
    private func updatePrice(price: NSNumber) {
        priceLabel.setText(Tracker.priceFormatter.stringFromNumber(price))
    }
    
    private func updateMainInfo(_mainTitle: String, _mainImage: UIImage) {
        mainTitle.setText(_mainTitle)
        mainImage.setImage(_mainImage)
        //buttonRefresh.setBackgroundImage(_mainImage)
    }
    
    private func update() {
        if !updating {
            updating = true
            let originalPrice = tracker.cachedPrice()
            tracker.requestPrice { (price, error) -> () in
                if error == nil {
                    self.updatePrice(price!)
                    self.updateDate(NSDate())
                    self.updateImage(originalPrice, newPrice: price!)
                }
                self.updating = false
            }
            
            tracker.requestYoutube({ (arrayOfObjects, title, image, error) -> () in
                if error == nil{
                    arrayOfObjects
                    let responseDictData = arrayOfObjects as NSDictionary!
                    
                    if let responseDictDataItems = responseDictData.valueForKey("items") as? NSArray {
                        let video: AnyObject = ""
                        self.theVideos = [YoutubeVideo]()
                        for video in responseDictDataItems {
                            
                            let id = video["id"];
                            let title = video["title"];
                            let thumbnail = video.objectForKey("thumbnail") as? NSDictionary
                            let hqDefault: AnyObject? = thumbnail?.objectForKey("hqDefault");
                            
                            let youtubeVideo = YoutubeVideo()
                            youtubeVideo.id = id as String
                            youtubeVideo.title = title as String
                            youtubeVideo.thumbnail = hqDefault as String
                            
                            self.theVideos.append(youtubeVideo)
                        }
                        
                    }
                    
                    
                    self.index = 0
                        let url = NSURL(string: self.theVideos[self.index].thumbnail as String);
                        let picData = NSData(contentsOfURL: url!);
                        let img = UIImage(data: picData!);
                    
                    let mainTitle = self.theVideos[self.index].title as String
                    
                    self.updateMainInfo(mainTitle, _mainImage: img!)
                }
            })
        }
    }
    
    private func updateDate(date: NSDate) {
        self.lastUpdatedLabel.setText("Last updated \(Tracker.dateFormatter.stringFromDate(date))")
    }
    
    private func updateImage(originalPrice: NSNumber, newPrice: NSNumber) {
        if originalPrice.isEqualToNumber(newPrice) {
            // 1
            image.setHidden(true)
        } else {
            // 2
            if newPrice.doubleValue > originalPrice.doubleValue {
                image.setImageNamed("Up")
            } else {
                image.setImageNamed("Down")
            }
            image.setHidden(false)
        }
    }
}
