Overview
============
AutoCompleteSearchBar is a subclass of UISeachBar which supports the autocomplete feature including:
- Showing a list of results while inputing search text
- Selecting one of the results will replace the search text
- Compact mode(compact mode is minimized the results list frame, default is off)

Install with Cocoapod
============
copy this in your podfile
```
pod 'AutoCompleteSearchBar', :git => 'https://github.com/shengrong1987/AutoCompleteSearchBar.git
```

run from your commandline from your project directory
```
pod install
```

Usage
============
AutoCompleteSearchBar support configuring the maxheight of the result table view in two ways either using a fixed maximum height or puting the maximum result number. Check out in Configuration section for more.

You can turn on compact mode as well, compact mode is a mode that minimizes the result view area to be almost as long as the longest result and follow the searchBar text offset in horizontal. (default off)

Code
============
To simply start, just call `AutoCompleteSearchBar(frame: CGRect)` or drag a `UISearchBar` in interfacebuilder then change class to `AutoCompleteSearchBar`

Configuration
============
```
static public let HEIGHT_FOR_CELL = 30
static public let RESULT_FONT_SIZE = CGFloat(12.0)
static public let SEARCH_TEXT_OFFSET_X = CGFloat(30)
static public let RESULT_FONT_NAME = "Helvetica"
    
//compact mode switch
public var compact : Bool = true
//max autocomplete container width
public var maxWidthAutoComplete : CGFloat?
//max autocomplete container height
public var maxHeightAutoComplete : CGFloat?
//max number of result shown in table view
public var maxResultNumber : Int?
```

