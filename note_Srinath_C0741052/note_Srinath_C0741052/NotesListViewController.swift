
import UIKit
import CoreData

class NotesListViewController: UIViewController {
    
    @IBOutlet weak var noteTableView: UITableView!
    var notes: [Note] = []
    let appdelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        noteTableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        // Do any additional setup after loading the view.
    }
    
    func fetchNotes() -> [Note] {
        guard let notes = try? appdelegate.persistentContainer.viewContext.fetch(Note.fetchRequest() as NSFetchRequest<Note>) else {
            return []
        }
        return notes
    }
    
    @objc func addTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NoteDetailsViewController") as! NoteDetailsViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}


// MARK: - UITableViewDataSource
extension NotesListViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    
    return notes.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell",
                                          for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].title
        return cell
    }
}
