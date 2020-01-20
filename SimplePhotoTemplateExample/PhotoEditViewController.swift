//
//  PhotoEditViewController.swift
//  PhotoEditKit
//
//  Created by Shawn Wu on 1/11/20.
//  Copyright © 2020 Shawn Wu. All rights reserved.
//

import UIKit
import SVProgressHUD
import SimplePhotoTemplate

class PhotoTemplateEditController: UIViewController {
    private let exportButton: UIButton
    private let templateView: TemplateView
    private let editCarouselView: TemplateCarouselCollectionView
    
    private let viewModel: PhotoEditViewModel
    
    init(template: Template) {
        exportButton = UIButton()
        templateView = TemplateView(template: template)
        editCarouselView = TemplateCarouselCollectionView()
        viewModel = PhotoEditViewModel()
    
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = colorBlack
        
        view.addSubview(templateView)
        templateView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerY.equalToSuperview().offset(-44)
            make.height.equalTo(templateView.snp.width)
        }
    
        editCarouselView.delegate = self
        editCarouselView.dataSource = self
        editCarouselView.flowLayout.itemSize = CGSize(width: 120, height: 100)
        editCarouselView.flowLayout.minimumInteritemSpacing = 0
        editCarouselView.flowLayout.minimumLineSpacing = 0
        
        view.addSubview(editCarouselView)
        editCarouselView.snp.makeConstraints { make in
            make.height.equalTo(120)
            make.width.equalToSuperview()
            make.top.equalTo(templateView.snp.bottom).offset(12)
        }
        
        view.addSubview(exportButton)
        exportButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        exportButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        exportButton.setTitle("Export", for: .normal)
        exportButton.addTarget(self, action: #selector(exportButtonWasTapped), for: .touchUpInside)
        exportButton.backgroundColor = colorBlue
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc func exportButtonWasTapped() {
        SVProgressHUD.show()
        let image = templateView.render()
        viewModel.savePhotoToCameraRoll(image: image)
    }
}

extension PhotoTemplateEditController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoTemplateCell.reuseIdentifier,
                                                      for: indexPath) as! PhotoTemplateCell
        let optionName = viewModel.options[indexPath.row].name
        cell.configure(name: optionName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let option = viewModel.options[indexPath.row]
        switch option {
        case .text:
            viewModel.selectedOption = .text
            let text = Text(font: "HelveticaNeue", size: 20, color: "white")
            templateView.add(text: text)
        case .photo:
            SVProgressHUD.show()
            viewModel.selectedOption = .photo
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            present(imagePicker, animated: true) {
                SVProgressHUD.dismiss()
            }
        case .background:
            SVProgressHUD.show()
            viewModel.selectedOption = .background
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            present(imagePicker, animated: true) {
                SVProgressHUD.dismiss()
            }
        }
    }
}

extension PhotoTemplateEditController: PhotoEditViewModelDelegate {
    func savePhotoDidComplete(error: Error?) {
        SVProgressHUD.dismiss()
        let alert: UIAlertController
        if let error = error {
            print("saving photo with error: \(error.localizedDescription)")
            alert = UIAlertController(title: "we are having issues exporting photos, please try again later.",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "photos successfully saved into camera roll.",
                                      message: nil,
                                      preferredStyle: .alert)
            
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension PhotoTemplateEditController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer { picker.dismiss(animated: true, completion: nil) }
        guard let image = info[.originalImage] as? UIImage,
            let selectedOption = viewModel.selectedOption else {
            return
        }

        switch selectedOption {
        case .photo:
            templateView.add(image: image)
        case .background:
            templateView.updateBackground(image: image)
        default:
            break
        }
        viewModel.selectedOption = nil
    }
}
