
import Foundation
import UIKit

class NoteDetailsViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView:UITextView!
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        saveDataInDataBase()
        self.navigationController?.popViewController(animated: true)
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
