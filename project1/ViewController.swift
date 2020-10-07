//
//  ViewController.swift
//  project1
//
//  Created by Kristoffer Eriksson on 2020-08-25.
//  Copyright © 2020 Kristoffer Eriksson. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures = [String]()
    var picDict = [String: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Hand Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        performSelector(inBackground: #selector(getPictures), with: nil)
        // got error in getpictures function
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        
        let defaults = UserDefaults.standard
        if let savedDict = defaults.object(forKey: "picDict") as? Data {
            if let savedPictures = defaults.object(forKey: "pictures") as? Data {
                let jsonDecoder = JSONDecoder()
                do {
                    picDict = try jsonDecoder.decode([String: Int].self, from: savedDict)
                    
                    pictures = try jsonDecoder.decode([String].self, from: savedPictures)
                } catch {
                    print("failed to load clickCount")
                }
            }
        }
    }
    
    @objc func getPictures(){
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
                
        for item in items {
            if item.hasPrefix("IMG"){
                //this is a picture to load !
                pictures.append(item)
                picDict[item] = 0
            }
        }
        print(pictures)
        print(picDict)
        pictures.sort()
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        cell.detailTextLabel?.text = "Viewed \(picDict[pictures[indexPath.row]]!) times."
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
            vc.currentElement = indexPath.row + 1
            vc.totalElements = pictures.count
        }
        picDict[pictures[indexPath.row]]! += 1
        save()
        tableView.reloadData()
        print(picDict)
    }
    func save(){
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(picDict){
            if let savedPic = try? jsonEncoder.encode(pictures){
                let defaults = UserDefaults.standard
                defaults.set(savedData, forKey: "picDict")
                defaults.set(savedPic, forKey: "pictures")
            } else {
                print("could not save count")
            }
        }
    }
}


