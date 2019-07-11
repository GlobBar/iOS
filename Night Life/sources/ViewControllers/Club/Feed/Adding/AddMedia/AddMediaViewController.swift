 //
 //  AddPhotoViewController.swift
 //  Night Life
 //
 //  Created by Vlad Soroka on 2/29/16.
 //  Copyright © 2016 com.NightLife. All rights reserved.
 //
 
 import UIKit
 import RxSwift
 
 import RxCocoa
 
 import MBCircularProgressBar
 import MobileCoreServices
 
 class AddMediaViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var viewModel: AddMediaViewModel!
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate weak var mediaPlayerController: MediaPlayerViewController!
    
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    
    @IBOutlet weak var descriptionTextField: UITextField! {
        didSet {
            descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Add a caption", attributes: [NSAttributedStringKey.foregroundColor:UIColor(red: 117, green: 117, blue: 117), NSAttributedStringKey.font: UIFont(name: "Raleway", size: 12)!])
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    fileprivate let gradientLayer: CALayer = UIConfiguration.gradientLayer(    UIColor(fromHex: 0x171717),
                                                                               to: UIColor(fromHex: 0x343434))
    
    fileprivate var imagePicker: UIImagePickerController = {
        
        let picker = UIImagePickerController()
        
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.videoMaximumDuration = AppConfiguration.maximumRecordedVideoDuration
        
        return picker
    }()
    
    @IBOutlet weak var unlockLabel: UILabel!
    @IBOutlet weak var unlockStepper: UIStepper!
    @IBOutlet weak var unlockValue: UILabel!
    
    
    
    override func loadView() {
        super.loadView()
        
        if viewModel == nil { fatalError("viewModel must be initialized prior to using AddMediaViewController") }
        
        imagePicker.mediaTypes = viewModel.mediaType == .photo ? [kUTTypeImage as String] : [kUTTypeMovie as String]
        imagePicker.delegate = self
        
        self.title = "Add Media"
        
        scrollView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isFan = User.currentUser()?.type == .fan
        
        unlockLabel.isHidden = isFan
        unlockStepper.isHidden = isFan
        unlockValue.isHidden = isFan
        
        unlockStepper.rx.value
            .map { "\(Int($0))$" }
            .bind(to: unlockValue.rx.text)
            .disposed(by: disposeBag)
        
        // comment here to run the app on simulator without crash
        self.present(imagePicker, animated: false, completion: nil)
        
        //// keyboard show hide
        NotificationCenter.default
            .rx.notification(NSNotification.Name.UIKeyboardWillShow)
            .subscribe(onNext: { [unowned self] notification in
                
                let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
                
                var offset = self.scrollView.contentOffset
                
                let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                
                if (self.scrollView.frame.size.height - (self.descriptionTextField.frame.origin.y + self.descriptionTextField.frame.size.height) + self.scrollView.contentOffset.y)  < keyboardSize.origin.y
                {
                    offset.y += keyboardSize.height
                    
                    UIView.animate(withDuration: duration) { self.scrollView.contentOffset = offset }
                }
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default
            .rx.notification(NSNotification.Name.UIKeyboardWillHide)
            .subscribe(onNext: { [unowned self] notification in
                
                let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
                
                var offset = self.scrollView.contentOffset
                offset.y = 0.0
                
                UIView.animate(withDuration: duration) { self.scrollView.contentOffset = offset }
            })
            
            .disposed(by: disposeBag)
        //
        ////upload progress
        viewModel.uploadProgress.asDriver()
            .drive(onNext: { [unowned self] value in
                guard let percent = value else {
                    return
                }
                
                self.progressView.isHidden = false
                self.progressView.value = CGFloat(percent * 100.0)
            })
            .disposed(by: disposeBag)
        
        
        ///upload button
        let uploadBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: .plain, target: self, action: #selector(mock))
        uploadBarButtonItem.rx.tap
            .flatMap { [weak t = self.descriptionTextField] _ -> Observable<String?> in
                t!.resignFirstResponder()
                
                return t!.rx.text.asObservable()
            }
            .notNil()
            .subscribe(onNext: { [unowned self] description in
                self.descriptionTextField.isHidden = true
                
                let price = Int(self.unlockStepper.value) * 100
                
                if User.currentUser()?.type == .dancer {
                  
                    guard let c = User.currentUser()?.dancerClub else {
                        self.presentErrorMessage(error: "Please select your affiliation club by going to the club’s page and tapping 'Choose Club' first")
                        return
                    }
                    
                    guard c.id == self.viewModel.club.id else {
                        self.presentErrorMessage(error: "You work at \(c.name) and cannot upload to \(self.viewModel.club.name). Please select new club affiliation first")
                        return
                    }
                    
                }
                
                self.viewModel.uploadSelectedMedia(description, price: price)
                }
            )
            .disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem = uploadBarButtonItem
        
        ///selection media binding
        viewModel.selectedImage.asDriver()
            .filter { $0 != nil }.map { $0! }
            .drive(onNext: { [unowned self] image in
                self.mediaPlayerController.image.value = image
                }
            )
            .disposed(by: disposeBag)
        
        viewModel.selectedVideoURL.asDriver()
            .filter { $0 != nil }
            .map { $0! }
            .drive(onNext: { [unowned self] tuple in
                self.mediaPlayerController.playableContentURL.value = tuple.0
                }
            )
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = self.scrollView.bounds
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let url = info[UIImagePickerControllerMediaURL] as? URL {
            viewModel.addedVideo(url)
        }
        else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            viewModel.addedPhoto(image)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: false, completion: nil)
        self.progressView.isHidden = true
        self.viewModel.cancelMediaAdding()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    @objc func mock() {}
 }
 
 extension AddMediaViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed media player" {
            mediaPlayerController = segue.destination as! MediaPlayerViewController
        }
    }
    
 }
