# Basic 
Imagine wanting to put a array of items in a simple list and present it. Without the need to creat table view subclass and go into delegate and datasource. 

## 1. Model 
```swift
let models = ["Apple", "Microsoft", "Google"]
```

## 2. Describe Cell for model
Describe what a cell would do for a single model. 
```swift
    let cellDescs  = models.map { m -> ListCellDescriptor<String, SimpleCell> in
            var cd = ListCellDescriptor(m, identifier: identifier, cellClass: SimpleCell.self, 
            // 1. Configure 
            configure: { cell in
                cell.textLabel?.text = m
            })

            // set action handler
            cd.onSelect = { [weak self] in
                self?.tapped(m)
            }
            return cd
        }
```

SimpleCell used above is just a empty subclass of normal UITableViewCell. Prefer to subclass and provide custom design that matches your business logic. 
```swift
class SimpleCell: UITableViewCell { }
```

## 3. Pack it into SectionDescriptors 
SectionDescriptors are just a way to group CellDescriptors. Think of them as array of each section's cell view model. 
```swift
/// A SectionDescriptor is made up of array of cell descriptor.
let sections = ListSectionDescriptor(with: cellDescs)
```

## 4. Constrcut ListViewController
```swift
/// A List is made of up array of section. 
let list = ListViewController(with: [sections])
```

## 5. Effecient updates 
If your model gets updated later on after the list is already on screen, simply pass the new `sectionDescriptors` to the list's `update` method. 

```swift
list.update(with: newSections)
```

The `ListViewController` uses `FastDiff`, a very fast diffing algorithm with time complexity of O(nm), to perfrom updates with standard table view animations. 

## 6. Present! 
That's it. 

# Note 
So far we have seen how to present one *type* of model with single *type/variant* of cell. We even had just 1 section. This is called homogeneous typed list. 

Can we support multiple sections? What if each section could have varying types? For instance first section contains 3 big corp names. The second section, for some other reason, contains 3 different color. 


# Intermediate (Multi Section)
# Advanced (Heterogeneous list)
# Advanced (Custom action handling)