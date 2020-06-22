
import UIKit

class NotesListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        // Do any additional setup after loading the view.
    }
    
    @objc func addTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NoteDetailsViewController") as! NoteDetailsViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

