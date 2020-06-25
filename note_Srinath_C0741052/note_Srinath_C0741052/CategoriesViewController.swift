import UIKit
import CoreData

class CategoriesViewController: UIViewController {
    
    @IBOutlet weak var categoryTable: UITableView!
    var categories: [Category] = []
    let appdelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Category"
        categoryTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categories = fetchCategories()
        categoryTable.reloadData()
    }
    
    func fetchCategories() -> [Category] {
        guard let categories = try? appdelegate.persistentContainer.viewContext.fetch(Category.fetchRequest() as NSFetchRequest<Category>) else {
            return []
        }
        return categories
    }
    
    @objc func addTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CategoryDetailViewController") as! CategoryDetailViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

extension CategoriesViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    
    return categories.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.title
        return cell
    }
}
