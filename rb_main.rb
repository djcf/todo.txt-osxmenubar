framework 'AppKit'
require 'lib/todo'
require 'digest/md5'

#
# Initialize the stuff
#

# we expect to find their todo in ~/todo.txt
@todo_path = NSHomeDirectory() + "/todo.txt"

# Parse user's todo.txt file
def readToDoList
	# initialise a timer to check whether the file has changed and reload if it has - every 3 minutes
	timer = NSTimer.scheduledTimerWithTimeInterval(180, target: self, selector: "checkReloadFile:", userInfo: nil, repeats: true)
	begin # open it.
		return Todo.parse_file @todo_path
	rescue StandardError
		return Todo.parse(File.new(@todo_path).read)
	end
	@file_hash = Digest::MD5.file(@todo_path).hexdigest #get the md5 for the file reloader
end

# We build the status bar item menu
def setupMenu(todo_list)
  # with each todo list item, populate a new item on the menubar
  n=0
  todo_list.each do |todo|
	unless todo.done?
		mi = NSMenuItem.new.initWithTitle(todo.to_s, action: 'miClicked:', keyEquivalent: (n+=1).to_s)
		mi.representedObject = todo
		mi.target = self
		@menu.addItem mi
	end
  end
  
  #ni = NSMenuItem.new.initWithTitle("Add todo", action: 'addNew:', keyEquivalent: "n")
  #ni.target = self
  #@menu.addItem ni
  
  @ni = NSMenuItem.new
  input = NSTextField.alloc.initWithFrame([500, 30, 480, 20])
  input.setTarget self
  input.setAction "addNew:"
  @ni.setView input
  @menu.addItem @ni
  
  @qi = NSMenuItem.new.initWithTitle("Quit", action: 'quit:', keyEquivalent: "q")
  @qi.target = self
  @menu.addItem @qi

end
 
# Init the menu bar
def initStatusBar
  @menu = NSMenu.new
  @menu.initWithTitle 'ToDo.txt'
  
  status_bar = NSStatusBar.systemStatusBar
  status_item = status_bar.statusItemWithLength NSVariableStatusItemLength
  status_item.setMenu @menu 

  status_item.setImage NSImage.new.initWithContentsOfFile NSBundle.mainBundle.pathForResource("icon", ofType:"png")
end
 
#
# Menu Item Action (mark as done)
#
def miClicked(sender)
	#first, mark the item done
	sender.representedObject.do

	#update the menuitem
	sender.title = sender.representedObject.to_s
		
	#finally, save the updated list
	File.open(@todo_path, "w") { |file| file.puts(@todo_list) }
	@file_hash = Digest::MD5.file(@todo_path).hexdigest
end

#
# Add new todo item
#
def addNew(sender)
	# make and add a new menu item out of a new todo item
	new_item = NSMenuItem.new.initWithTitle(sender.stringValue, action: 'miClicked:', keyEquivalent: "")
	new_item.target = self
	new_todo = Todo.new sender.stringValue
	new_item.representedObject = new_todo
	@todo_list.push new_todo
	@menu.addItem new_item

	# remove and then add the new item box and the quit item so that both are at the bottom of the menu
	@menu.removeItem @ni
	@menu.removeItem @qi
	@menu.addItem @ni
	@menu.addItem @qi

	# remap the keyboard shortcuts for the first 9 items
	n=0
	@menu.itemArray.first(9).each { |item| item.keyEquivalent = (n+=1).to_s }
	# make sure the remapping didn't overwrite quit's shortcut
	@qi.keyEquivalent = "q"
	
	# rewrite the todo.txt file with the new entry...
	File.open(@todo_path, "w") { |file| file.puts(@todo_list) }
	@file_hash = Digest::MD5.file(@todo_path).hexdigest

	# finally, reset the text entry box
	sender.stringValue = ""
end

#
# Quit menu item
# todo: method must always be invoked on quit
def quit(sender)
	checkReloadFile

	#write all items which have yet to be completed and exit..
	still_todo = @todo_list.reject {|item| item.done? }
	File.open(@todo_path, "w") { |file| file.puts(still_todo) }
	
	app = NSApplication.sharedApplication
	app.terminate self
end

def checkReloadFile
	current_file_hash = Digest::MD5.file(@todo_path).hexdigest
	if @file_hash != current_file_hash
		@todo_list = Todo.parse_file @todo_path
		@file_hash = current_file_hash		
		@menu.removeAllItems
		setupMenu @todo_list
	end
end

#
# Rock'n Roll
#
app = NSApplication.sharedApplication
# Get the todo, create the status bar items, add the menu and run the app
@todo_list = readToDoList
initStatusBar
setupMenu @todo_list
app.run