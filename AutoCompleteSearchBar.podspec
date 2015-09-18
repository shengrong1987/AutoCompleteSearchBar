
Pod::Spec.new do |s|

  s.name         = "AutoCompleteSearchBar"
  s.version      = "0.0.1"
  s.summary      = "AutoCompleteSearchBar is a subclass of UISeachBar which supports the autocomplete feature ."

s.description  = "AutoCompleteSearchBar is a subclass of UISeachBar which supports the autocomplete feature including:- Showing a list of results while inputing search text- Selecting one of the results will replace the search text- Compact mode(compact mode is minimized the results list frame, default is off)"

    s.homepage     = "https://github.com/shengrong1987/AutoCompleteSearchBar"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "ShengRong" => "aimbebe.r@gmail.com" }
  s.source       = { :git => "https://github.com/shengrong1987/AutoCompleteSearchBar.git", :tag => "0.0.1" }
  s.source_files  = "AutoCompleteSearchBar/**/*.{swift}"
end