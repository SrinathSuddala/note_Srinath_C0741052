
import UIKit
import CoreData

class NotesListViewController: UIViewController {
    
    @IBOutlet weak var noteTableView: UITableView!
    var notes: [Note] = []
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedCategory: Category!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        noteTableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteTableViewCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(mapTapped))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notes = fetchNotes()
        noteTableView.reloadData()
    }
    
    func fetchNotes() -> [Note] {
        guard let notes = try? appdelegate.persistentContainer.viewContext.fetch(Note.fetchRequest(with: selectedCategory.uuid!) as NSFetchRequest<Note>) else {
            return []
        }
        return notes
    }
    
    @objc func mapTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        viewController.notes = notes
        self.navigationController?.pushViewController(viewController, animated: true)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell") as! NoteTableViewCell
        cell.titleLabel.text = notes[indexPath.row].title
        cell.descLabel.text = notes[indexPath.row].desc
        if let image = notes[indexPath.row].image,
            let data = Data(base64Encoded: image, options: .ignoreUnknownCharacters),
            let finalImage = UIImage(data: data) {
            cell.noteImage.image = finalImage
        }
        return cell
    }
}

extension NotesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NoteDetailsViewController") as! NoteDetailsViewController
        viewController.selectedNote = notes[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension NotesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.notes = fetchNotes(with: searchText)
        noteTableView.reloadData()
    }
    
    func fetchNotes(with text: String) -> [Note] {
        if text.isEmpty {
            guard let notes = try? appdelegate.persistentContainer.viewContext.fetch(Note.fetchRequest(with: selectedCategory.uuid!) as NSFetchRequest<Note>) else {
                return []
            }
            return notes
        } else {
            guard let notes = try? appdelegate.persistentContainer.viewContext.fetch(Note.fetchRequest(with: text, categoryUuid: selectedCategory.uuid!) as NSFetchRequest<Note>) else {
                return []
            }
            return notes
        }
    }
}
