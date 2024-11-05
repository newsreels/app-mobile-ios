


import UIKit


class TreeNode: NSObject {
    
    var id : String = ""
    var name : String = ""
    var city : String = ""
    var state : String = ""
    var country: String = ""
    var language : String = ""
    var image : String = ""
    var selected : Bool = false
    var has_child: Bool = false

	var isOpen = false
	var subNodes = [TreeNode]()
	var levelString = "1.0"
	
	var level: Int {
		return levelString.components(separatedBy: ".").count
	}
	var isLeaf: Bool {
		return subNodes.isEmpty
	}
	
	override var description: String {
		return "levelString: \(levelString) name: \(name)"
	}
    
    init(id : String, name : String, city : String, state : String, country : String, language : String, image : String, selected : Bool, has_child : Bool, subNodes: [TreeNode]) {
        
        self.id = id
        self.name = name
        self.city = city
        self.state = state
        self.country = country
        self.language = language
        self.image = image
        self.selected = selected
        self.has_child = has_child
        self.subNodes = subNodes
    }
    
    convenience init(id : String, name : String, city : String, state : String, country : String, language : String, image : String, selected : Bool, has_child : Bool) {
        self.init(id : id, name : name, city : city, state : state, country : country, language : language, image : image, selected : selected, has_child : has_child, subNodes: [TreeNode]())
    }
}


extension TreeNode {

	override func setValue(_ value: Any?, forUndefinedKey key: String) {
		if key == "subs", let subs = value as? [Editions] {
			for i in 0..<subs.count {
				let tree = TreeNode.modelWithDictionary(subs[i], levelString: i,parent: levelString)
				subNodes.append(tree)
			}
		}
	}

	public static func modelWithDictionary(_ e: Editions, levelString index: Int, parent levelString: String?) -> TreeNode{
        let model = TreeNode(id: e.id ?? "", name: e.name ?? "", city: e.city ?? "", state: e.state ?? "", country: e.country ?? "", language: e.language ?? "", image: e.image ?? "", selected: e.selected ?? false, has_child: e.has_child ?? false)
		model.levelString = levelString != nil ? (levelString! + ".\(index + 1)") : "\(index + 1)"
		//model.setValuesForKeys(e)
		return model
	}
}


extension TreeNode{
	var needsDisplayNodes: [TreeNode]{
		return needsDisplayNodesOf(ancestor: self)
	}
	
	// Should be displayed
	private func needsDisplayNodesOf(ancestor: TreeNode) -> [TreeNode]{
		var nodes = [TreeNode]()
		for node in ancestor.subNodes {
			nodes.append(node)
			if node.isOpen {
				nodes.append(contentsOf: needsDisplayNodesOf(ancestor: node))
			}
		}
		return nodes.sorted{ $0.levelString < $1.levelString }
	}
}


extension TreeNode{
//	public static func mockData() -> [TreeNode]{
//		var trees = [TreeNode]()
//		do{
//			let data = try Data(contentsOf: Bundle.main.url(forResource: "tree.json", withExtension: nil)!)
//			guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [[String: Any]] else{
//				return trees
//			}
//			for i in 0..<jsonArray.count{
//				let tree = TreeNode.modelWithDictionary(jsonArray[i], levelString: i, parent: nil)
//				trees.append(tree)
//			}
//		}catch{
//			fatalError("JSON Data analysis failed")
//		}
//		return trees
//	}
}
