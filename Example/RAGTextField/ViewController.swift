import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private enum Topic: String {
        
        case placeholder
        case hint
        case textAlignment
        case textPadding
        case outline
        case underline
        case leftAndRightViews
        
        static var allTopics: [Topic] {
            return [
                .placeholder,
                .hint,
                .textAlignment,
                .textPadding,
                .outline,
                .underline,
                .leftAndRightViews
            ]
        }
    }
    
    override func viewDidLoad() {
        
        title = "Overview"
        
        if #available(iOS 11, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        super.viewDidLoad()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Topic.allTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = title(for: Topic.allTopics[indexPath.row])
        cell.textLabel?.textColor = .darkGray
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    private func title(for topic: Topic) -> String {
        
        switch topic {
        case .placeholder:
            return "Animated placeholder"
        case .hint:
            return "Hint label"
        case .textAlignment:
            return "Text alignments"
        case .textPadding:
            return "Text padding"
        case .outline:
            return "Outlined style"
        case .underline:
            return "Underlined style"
        case .leftAndRightViews:
            return "Left and right views"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let topic = Topic.allTopics[indexPath.row]
        
        let storyboardName = formatStoryboardName(for: topic)
        guard Bundle.main.path(forResource: storyboardName, ofType: "storyboardc") != nil else {
            return
        }
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let viewController = storyboard.instantiateInitialViewController() {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return CGFloat.leastNonzeroMagnitude
    }
    
    private func formatStoryboardName(for topic: Topic) -> String {
        
        let value = topic.rawValue
        let name = value.prefix(1).uppercased() + value.dropFirst()
        
        return name
    }
}
