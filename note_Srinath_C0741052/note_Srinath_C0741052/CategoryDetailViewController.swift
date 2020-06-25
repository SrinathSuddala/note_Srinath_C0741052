
import UIKit

class CategoryDetailViewController: UIViewController {

    @IBOutlet weak var titleTextField : UITextField!
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(saveTapped))
        // Do any additional setup after loading the view.
    }
    
    @objc func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        let category = Category(context: appdelegate.persistentContainer.viewContext)
        category.title = title
        category.uuid = UUID()
        appdelegate.persistentContainer.viewContext.insert(category)
        try? appdelegate.persistentContainer.viewContext.save()
        self.navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
