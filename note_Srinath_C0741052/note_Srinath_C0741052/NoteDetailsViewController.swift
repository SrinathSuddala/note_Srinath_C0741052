
import Foundation
import UIKit
import MapKit
import AVFoundation

class NoteDetailsViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView:UITextView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var selectCategoryButton: UIButton!
    var selectedImage: UIImage?
    var imagePicker: ImagePicker!
    var selectedNote: Note?
    var currentLocation: CLLocationCoordinate2D?
    var selectedCategory: Category?
    
    
    
    @IBOutlet var recordingTimeLabel: UILabel!
    
    var recordUrl: String?
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    
    fileprivate let locationManager: CLLocationManager = {
       let manager = CLLocationManager()
       manager.requestWhenInUseAuthorization()
       return manager
    }()
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.cornerRadius = 5.0
        imageButton.layer.borderColor = UIColor.black.cgColor
        imageButton.layer.borderWidth = 1.0
        
        recordButton.layer.borderColor = UIColor.black.cgColor
        recordButton.layer.borderWidth = 1.0
        selectCategoryButton.layer.borderColor = UIColor.black.cgColor
        selectCategoryButton.layer.borderWidth = 1.0
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboardTapOfMainView))
        self.view.addGestureRecognizer(dismissTap)
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        showSelectedNote()
        currentLocationSetUp()
        checkRecordPermission()
        // Do any additional setup after loading the view.
    }
    
    func checkRecordPermission(){
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
            })
            break
        default:
            break
        }
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func getFileUrl() -> URL{
        let filename = "\(UUID()).m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        recordUrl = "\(filePath)"
        return filePath
    }
    
    func setup_recorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSession.Category.playAndRecord)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error {
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        }
        else{
            display_alert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")
        }
    }
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String) {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
        _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    @objc func dismissKeyboardTapOfMainView() {
        self.view.endEditing(true)
    }
    
    func currentLocationSetUp() {
       locationManager.delegate = self
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       if #available(iOS 11.0, *) {
          locationManager.showsBackgroundLocationIndicator = true
       }
       locationManager.startUpdatingLocation()
    }
    
    func showSelectedNote() {
        guard let note = selectedNote else { return }
        titleTextField.text = note.title
        descriptionTextView.text = note.desc
        selectCategoryButton.setTitle(note.category.title, for: UIControl.State())
        
        if let image = note.image,
            let data = Data(base64Encoded: image, options: .ignoreUnknownCharacters),
            let finalImage = UIImage(data: data) {
            imageButton.setTitle("", for: UIControl.State())
            imageButton.setBackgroundImage(finalImage, for: UIControl.State())
        }
        
    }
    
    @IBAction func selectCategoryTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
        viewController.isFromNotesDetails = true
        viewController.selectedCategoryUuid = selectedNote?.category.uuid
        viewController.onCategorySelected = { category in
            self.selectedCategory = category
            self.selectCategoryButton.setTitle(category.title, for: UIControl.State())
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        saveDataInDataBase()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedImageButton(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func audioButtonTapped(_ sender: UIButton) {
        if(isRecording) {
            finishAudioRecording(success: true)
            recordButton.setTitle("Record", for: .normal)
//            play_btn_ref.isEnabled = true
            isRecording = false
        } else {
            setup_recorder()

            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            recordButton.setTitle("Stop", for: .normal)
//            play_btn_ref.isEnabled = false
            isRecording = true
        }
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recordingTimeLabel.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }

    func finishAudioRecording(success: Bool)
    {
        if success{
            audioRecorder.stop()
            audioRecorder = nil
            meterTimer.invalidate()
            print("recorded successfully.")
        } else {
            display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    
    func saveDataInDataBase() {
        guard let title = titleTextField.text, !title.isEmpty, let descriptionText = descriptionTextView.text else { return }
        let note = selectedNote != nil ? selectedNote! : Note(context: appdelegate.persistentContainer.viewContext)
        note.title = title
        note.desc = descriptionText
        note.date = Date()
        if let category = selectedCategory {
            note.category = category
        }
        if let image = selectedImage,let imageData = image.jpeg(.low) {
            note.image = imageData.base64EncodedString(options: .lineLength64Characters)
        }
        if let location = currentLocation {
            note.lat = location.latitude
            note.long = location.longitude
        }
        note.audio = recordUrl
        if selectedNote == nil {
            appdelegate.persistentContainer.viewContext.insert(note)
        }
        try? appdelegate.persistentContainer.viewContext.save()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            finishAudioRecording(success: false)
        }
//        play_btn_ref.isEnabled = true
    }
    
}

extension NoteDetailsViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.imageButton.setTitle(image == nil ? "Select image" : "", for: UIControl.State())
        self.imageButton.setBackgroundImage(image, for: UIControl.State())
        selectedImage = image
    }
}

//MARK: - CLLocationManagerDelegate Methods
extension NoteDetailsViewController: CLLocationManagerDelegate {
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        self.currentLocation = currentLocation
        locationManager.stopUpdatingLocation()
     }
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
     }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
