//
//  AllPhotoVC.swift
//  MultiPhotoPicker
//
//  Created by KOSIGN on 5/10/23.
//

import UIKit
import Photos
import PhotosUI

class AllPhotoVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    var imageArray = [UIImage]()
    let imagePicker = UIImagePickerController()
    var selectedImages: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
      setUpCollectionView()
        imagePicker.delegate = self
        imageArray = loadImagesFromPhone()
        customGridLayout : do {
            let gridLayout  =  UICollectionViewFlowLayout()
            let itemWidth = (UIScreen.main.bounds.width - 10)/4
            gridLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
            gridLayout.minimumLineSpacing = 1
            gridLayout.minimumInteritemSpacing = 0
            gridLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            gridLayout.scrollDirection = .vertical
            collectionView.setCollectionViewLayout(gridLayout, animated: false)

        }
    }

    override func viewDidAppear(_ animated: Bool) {
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            let imagePickerController = UIImagePickerController()
//            imagePickerController.delegate = self;
//            imagePickerController.sourceType = .photoLibrary
////            imagePickerController.modalPresentationStyle = .fullScreen
//            self.present(imagePickerController, animated: true, completion: nil)
//        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImages = info[.phAsset] as? [PHAsset] {
            // Handle the selected images
            for asset in selectedImages {
                // Access the selected images using the PHAsset object
                print(asset)
            }
        }

        picker.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }


    func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
    }

    private func loadImagesFromPhone() -> [UIImage] {
        // Code to load images from iPhone's photo library
        return []
    }

}

extension AllPhotoVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
//        let fetchOptions = PHFetchOptions()
//        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//        cell.imageView.image = selectedImages[indexPath.item]
        return cell
    }


}

