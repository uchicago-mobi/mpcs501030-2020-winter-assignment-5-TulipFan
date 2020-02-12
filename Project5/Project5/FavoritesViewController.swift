//
//  FavoritesViewController.swift
//  Project5
//
//  Created by YAJING FAN on 2/8/20.
//  Copyright © 2020 YAJING FAN. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Exit button to exit FavoritesViewController without a selection
    @IBAction func exitButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBOutlet weak var favorites: UITableView!
    weak var delegate: PlacesFavoritesDelegate!
    var defaults = UserDefaults.standard.array(forKey: "name") as? [String] ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.favorites.dataSource = self
        self.favorites.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if defaults.count == 0 {
            return 0
        }
        else {
            return defaults.count
        }
    }
    
    //Show name of the favorites saved in UserDefaults
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favorites.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! FavoriteCell
        cell.FavoriteName.text = defaults[indexPath.row]
        return cell
    }
    
    //Run favoritePlace function and exit the current view controller when a favorite is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = favorites.indexPathForSelectedRow {
            delegate!.favoritePlace(name: defaults[index.row])
        }
        self.dismiss(animated: true)
    }
}
