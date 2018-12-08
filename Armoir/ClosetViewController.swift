//
//  ClosetViewController.swift
//  Armoir
//
//  Created by alex weitzman on 11/30/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit

class ClosetViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    let itemsPerRow: CGFloat = 2.0
    var status_lending = true

    @IBOutlet weak var tabPicker: UISegmentedControl!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var viewOfItems: UICollectionView!
   @IBOutlet weak var profileName: UILabel!
    

    //Replace with the uploadItemButton
    @IBAction func uploadItemButton(_ sender: UIButton) {
        self.showActionSheet();
    }
    
    @objc func showActionSheet() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Import Image", message: "Take a picture or select one from your library.", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            startWithCamera = true
            self.performSegue(withIdentifier: "toCameraPage", sender: self)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            startWithCamera = false
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            itemImage = selectedImage!
            dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "toAddItemPage", sender: self)
            })
        } else if let originalImage = info[.originalImage] as? UIImage{
            selectedImage = originalImage
            itemImage = selectedImage!
            dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "toAddItemPage", sender: self)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func loadData() {
        
        //1. read json from file: DONE
        var longJsonData = ""
        let url = Bundle.main.url(forResource: "search", withExtension: "json")!
        do {
            let jsonData = try Data(contentsOf: url)
            try all_users = JSONDecoder().decode([a_User].self, from: jsonData);
            
        }
        catch {
            print(error)
        }
        
        //2. when adding, add to the all_users array: to do in code
       
        
        //3. then, encode it to be in json
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(all_users)
            longJsonData = String(data: data, encoding: .utf8)!
            //print(String(data: data, encoding: .utf8)!)
            print("DONE ENCODING")
        }
        catch {
            print("array didn't work");
        }
        print(longJsonData)
        
        //4. write to search.json with new encoded string
        let path = "test2" //this is the file. we will write to and read from it
        print("continuing");
        let text = longJsonData //just a text
        if let fileURL = Bundle.main.url(forResource: path, withExtension: "json") {
            //print(fileURL)
            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
                print("tried to write")
                let url = Bundle.main.url(forResource: "test2", withExtension: "json")!
                do {
                    let jsonData = try Data(contentsOf: url)
                    let newArray = try JSONDecoder().decode([a_User].self, from: jsonData);
                    print(newArray)
                }
                catch {
                    print(error)
                }
            }
            catch {
                print ("oh no");
            }
        }
        
        for user_instance in all_users {
            if user_instance.user_ID == user_num {
                currUser = user_instance;
            }
        }
    }
    
    func loadProfImage() {
        let image = UIImage(named: currUser.profPic);
        self.profilePicture.image = image;
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
    }
    
    func showUserName() {
        let userName = currUser.owner;
       self.profileName.text = userName;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currArray.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //for clothes you are lending
        if (status_lending) {
            let cell = viewOfItems.dequeueReusableCell(withReuseIdentifier: "lendingCell",for: indexPath) as! ItemCell
            let i = currArray[indexPath.row]
            cell.itemName.text = i.name;
            cell.img_display.image = UIImage(named: i.image);
            cell.img_display.contentMode = .scaleToFill;
            cell.img_display.layer.borderWidth = 1;
            if (i.borrowed) {
                cell.backgroundColor = UIColor(hue: 0.0028, saturation: 0, brightness: 0.82, alpha: 1.0)
                cell.due_display.text = "1 day left";
                cell.due_display.textColor = UIColor(hue: 0.0028, saturation: 0.97, brightness: 0.65, alpha: 1.0);
            } else {
                cell.backgroundColor = UIColor.white
                cell.due_display.text = "not borrowed";
                cell.due_display.textColor = UIColor.black;
            }
            return cell
        } // for borrowing clothes
        else {
            let cell = viewOfItems.dequeueReusableCell(withReuseIdentifier: "borrowingCell",for: indexPath) as! BorrowedCell
            let i = currArray[indexPath.row]
            cell.img_display.image = UIImage(named: i.image);
            cell.img_display.contentMode = .scaleToFill;
            cell.img_display.layer.borderWidth = 1;
            cell.dist_display.text = "1.2 mi";
            cell.due_display.text = "Due in 2 days";
            cell.due_display.textColor = UIColor.black;
            cell.price_display.text = String(i.price);
            cell.backgroundColor = UIColor.white
            return cell
        }

    }
    


    func loadLending() {
        currArray = currUser.closet;
        status_lending = true;
    }
    
    
    @IBAction func indexChanged(_ sender: AnyObject) {
        switch tabPicker.selectedSegmentIndex
        {
        case 0:
            loadLending();
        case 1:
            currArray = currUser.borrowed;
            status_lending = false;
        default:
            break
        }
       self.viewOfItems.reloadData();
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currItem = currArray[indexPath.row].item_id;

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData();
        loadProfImage();
        showUserName();
        loadLending();
        uploadButton.imageView?.contentMode = .scaleAspectFit;
        uploadButton.layer.cornerRadius = 5;
        viewOfItems.contentInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        //let availableWidth = viewOfItems.frame.size.width-(10*6.5);
        //let widthPerItem = availableWidth / 2;
        let widthPerItem = (UIScreen.main.bounds.width / 2) - 3
        let layout = UICollectionViewFlowLayout()
        //let layout = viewOfItems.collectionViewLayout as! UICollectionViewFlowLayout;
        layout.minimumInteritemSpacing = 1;
        layout.itemSize = CGSize( width: widthPerItem, height: widthPerItem*1.3)
    
        viewOfItems.collectionViewLayout = layout

        
    }
   

}
