
import Foundation
import UIKit

class NoteDetailsViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView:UITextView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboardTapOfMainView))
        self.view.addGestureRecognizer(dismissTap)
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboardTapOfMainView() {
        self.view.endEditing(true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        saveDataInDataBase()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedImageButton(_ sender: UIButton) {
        
    }
    
    func saveDataInDataBase() {
        guard let title = titleTextField.text, !title.isEmpty, let descriptionText = descriptionTextView.text else { return }
        let note = Note(context: appdelegate.persistentContainer.viewContext)
        note.title = title
        note.desc = descriptionText
        appdelegate.persistentContainer.viewContext.insert(note)
        try? appdelegate.persistentContainer.viewContext.save()
    }
    
}
