
import Foundation
import UIKit

class NoteDetailsViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView:UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
    }
    
}
