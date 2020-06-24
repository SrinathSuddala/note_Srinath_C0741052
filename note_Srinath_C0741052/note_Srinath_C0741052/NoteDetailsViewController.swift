
import Foundation
import UIKit

class NoteDetailsViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView:UITextView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    var selectedImage: UIImage?
    var imagePicker: ImagePicker!
    var selectedNote: Note?
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboardTapOfMainView))
        self.view.addGestureRecognizer(dismissTap)
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        showSelectedNote()
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboardTapOfMainView() {
        self.view.endEditing(true)
    }
    
    func showSelectedNote() {
        guard let note = selectedNote else { return }
        titleTextField.text = note.title
        descriptionTextView.text = note.desc
        if let image = note.image,
            let data = Data(base64Encoded: image, options: .ignoreUnknownCharacters),
            let finalImage = UIImage(data: data) {
            imageButton.setTitle("", for: UIControl.State())
            imageButton.setBackgroundImage(finalImage, for: UIControl.State())
        }
        
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        saveDataInDataBase()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedImageButton(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    func saveDataInDataBase() {
        guard let title = titleTextField.text, !title.isEmpty, let descriptionText = descriptionTextView.text else { return }
        let note = selectedNote != nil ? selectedNote! : Note(context: appdelegate.persistentContainer.viewContext)
        note.title = title
        note.desc = descriptionText
        note.date = Date()
        if let image = selectedImage,let imageData = image.jpeg(.low) {
            note.image = imageData.base64EncodedString(options: .lineLength64Characters)
        }
        appdelegate.persistentContainer.viewContext.insert(note)
        try? appdelegate.persistentContainer.viewContext.save()
    }
    
}

extension NoteDetailsViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.imageButton.setTitle(image == nil ? "Select image" : "", for: UIControl.State())
        self.imageButton.setBackgroundImage(image, for: UIControl.State())
        selectedImage = image
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
