
import UIKit

class NotesListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        // Do any additional setup after loading the view.
    }
    
    @objc func addTapped() {
        
    }
}

