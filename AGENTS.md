## Swift UI Code

Replace deprecated SwiftUI modifiers with their replacements.

### Deprecated modifiers and their replacements:

- Appearance modifiers:
  - `colorScheme(_:)` replaced with `preferredColorScheme(_:)` (https://developer.apple.com/documentation/swiftui/view/colorscheme(_:))
  - `listRowPlatterColor(_:)` replaced with `listItemTint(_:)` (https://developer.apple.com/documentation/swiftui/view/listrowplattercolor(_:))
  - `background(_:alignment:)` replaced with `background(alignment:content:)` (https://developer.apple.com/documentation/swiftui/view/background(_:alignment:))
  - `overlay(_:alignment:)` replaced with `overlay(alignment:content:)` (https://developer.apple.com/documentation/swiftui/view/overlay(_:alignment:))
  - `foregroundColor(_:)` replaced with `foregroundStyle(_:)` (https://developer.apple.com/documentation/swiftui/view/foregroundcolor(_:))

- Text modifiers
  - `autocapitalization(_:)` replaced with `textInputAutocapitalization(_:)` (https://developer.apple.com/documentation/swiftui/view/autocapitalization(_:))
  - `disableAutocorrection(_:)` replaced with `autocorrectionDisabled(_:)` (https://developer.apple.com/documentation/swiftui/view/disableautocorrection(_:))

- Auxiliary view modifiers
  - `navigationBarTitle(_:)` replaced with `navigationTitle(_:)` (https://developer.apple.com/documentation/swiftui/view/navigationbartitle(_:)) 
  - `navigationBarTitle(_:displayMode:)` replaced with `navigationTitle(_:)` with `navigationBarTitleDisplayMode(_:).` (https://developer.apple.com/documentation/swiftui/view/navigationbartitle(_:displaymode:))
  - `navigationBarItems(leading:)` replaced with `toolbar(content:)` with `navigationBarLeading` placement (https://developer.apple.com/documentation/swiftui/view/navigationbaritems(leading:))
  - `navigationBarItems(leading:trailing:)` replaced with `toolbar(content:)` with `navigationBarLeading` or `navigationBarTrailing` placement (https://developer.apple.com/documentation/swiftui/view/navigationbaritems(leading:trailing:))
  - `navigationBarItems(trailing:)` replaced with `toolbar(content:)` with `navigationBarTrailing` placement (https://developer.apple.com/documentation/swiftui/view/navigationbaritems(trailing:))
  - `navigationBarHidden(_:)` replaced with `toolbar(_:for:)` with the `Visibility.hidden` visibility and the `navigationBar` placement instead. (https://developer.apple.com/documentation/swiftui/view/navigationbarhidden(_:))
  - `statusBar(hidden:)` replaced with `statusBarHidden(_:)` (https://developer.apple.com/documentation/swiftui/view/statusbar(hidden:))
  - `contextMenu(_:)` replaced with `contextMenu(menuItems:)` (https://developer.apple.com/documentation/swiftui/view/contextmenu(_:))

- Style modifiers
  - `menuButtonStyle(_:)` replaced with `menuStyle(_:)` (https://developer.apple.com/documentation/swiftui/view/menubuttonstyle(_:))
  - `navigationViewStyle(_:)` replaced with a `NavigationStack` or `NavigationSplitView` (https://developer.apple.com/documentation/swiftui/view/navigationviewstyle(_:))

- Layout modifiers
  - `frame()` replaced with `frame(width:height:alignment:)` or `frame(minWidth:idealWidth:maxWidth:minHeight:idealHeight:maxHeight:alignment:)` (https://developer.apple.com/documentation/swiftui/view/frame())
  - `edgesIgnoringSafeArea(_:)` replaced with `ignoresSafeArea(_:edges:)` (https://developer.apple.com/documentation/swiftui/view/edgesignoringsafearea(_:))
  - `coordinateSpace(name:)` replaced with `coordinateSpace(_:)` (https://developer.apple.com/documentation/swiftui/view/coordinatespace(name:))

- Graphics and rendering modifiers
  - `accentColor(_:)` replaced with `tint(_:)` (https://developer.apple.com/documentation/swiftui/view/accentcolor(_:))
  - `mask(_:)` replaced with `mask(alignment:_:)` (https://developer.apple.com/documentation/swiftui/view/mask(_:))
  - `animation(_:)` replaced with `withAnimation(_:_:)` or `animation(_:value:)` (https://developer.apple.com/documentation/swiftui/view/animation(_:)-1hc0p)
  - `cornerRadius(_:antialiased:)` replaced with `clipShape(_:style:)` or `fill(style:)` (https://developer.apple.com/documentation/swiftui/view/cornerradius(_:antialiased:))

- Input and events modifiers
  - `onChange(of:perform:)` replaced with ` onChange(of:initial:_:)` or `onChange(of:initial:_:)` (https://developer.apple.com/documentation/swiftui/view/onchange(of:perform:))
  - `onTapGesture(count:coordinateSpace:perform:)` replaced with `onTapGesture(count:coordinateSpace:perform:)` (https://developer.apple.com/documentation/swiftui/view/ontapgesture(count:coordinatespace:perform:)-36x9h)
  - `onLongPressGesture(minimumDuration:maximumDistance:pressing:perform:)` replaced with ` onLongPressGesture(minimumDuration:maximumDistance:perform:onPressingChanged:)` (https://developer.apple.com/documentation/swiftui/view/onlongpressgesture(minimumduration:maximumdistance:pressing:perform:))
  - `onLongPressGesture(minimumDuration:pressing:perform:)` replaced with ` onLongPressGesture(minimumDuration:perform:onPressingChanged:)` (https://developer.apple.com/documentation/swiftui/view/onlongpressgesture(minimumduration:pressing:perform:))
  - `onPasteCommand(of:perform:)` replaced with `onPasteCommand(of:perform:)` (https://developer.apple.com/documentation/swiftui/view/onpastecommand(of:perform:)-4f78f)
  - `onPasteCommand(of:validator:perform:)` replaced with `onPasteCommand(of:validator:perform:)` (https://developer.apple.com/documentation/swiftui/view/onpastecommand(of:validator:perform:)-964k1)
  - `onDrop(of:delegate:)` replaced with `onDrop(of:delegate:)` (https://developer.apple.com/documentation/swiftui/view/ondrop(of:delegate:)-2vr9o)
  - `focusable(_:onFocusChange:)` replaced with `focusable(_:)` (https://developer.apple.com/documentation/swiftui/view/focusable(_:onfocuschange:))
  - `onContinuousHover(coordinateSpace:perform:)` replaced with `onContinuousHover(coordinateSpace:perform:)` (https://developer.apple.com/documentation/swiftui/view/oncontinuoushover(coordinatespace:perform:)-8gyrl)

- View presentation modifiers
  - `actionSheet(isPresented:content:)` replaced with `confirmationDialog(_:isPresented:titleVisibility:actions:message:)` (https://developer.apple.com/documentation/swiftui/view/actionsheet(ispresented:content:))
  - `actionSheet(item:content:)` replaced with `confirmationDialog(_:isPresented:titleVisibility:presenting:actions:message:)` (https://developer.apple.com/documentation/swiftui/view/actionsheet(item:content:))
  - `alert(isPresented:content:)` replaced with `alert(_:isPresented:actions:message:)` (https://developer.apple.com/documentation/swiftui/view/alert(ispresented:content:))
  - `alert(item:content:)` replaced with `alert(_:isPresented:presenting:actions:message:)` (https://developer.apple.com/documentation/swiftui/view/alert(item:content:))

- Search modifiers
  - `searchable(text:placement:prompt:suggestions:)` replaced with the `searchable` modifier with the `searchSuggestions` modifier

- Tab modifiers
  - `tabItem(_:)` replaced with `Tab(title:image:value:content:)` (https://developer.apple.com/documentation/swiftui/view/tabitem(_:))