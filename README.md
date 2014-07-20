todo.txt-osxmenubar
===================

This is a Mac-native Todo list helper application which lives in your menu bar. It uses the extremely simple todo.txt standard (http://todotxt.com) as a backend, making it small, portable, and modular.

Most todo.txt apps are far too heavyweight for practical use but I have been extremely impressed by the excellent todo list extensions for gnome shell (https://extensions.gnome.org/extension/570/todotxt/) and (https://extensions.gnome.org/review/2347). There is a similar app for OSX, but it isn't free software so I decided to create a simple proof-of-concept in MacRuby which mimics the features of the above GSEs.

Version
=======
This is a proof-of-concept but it works and some might find it useful.

Installation
============
Copy the application in build/Debug/Todo.app somewhere sensible on your file system then run it. It will look for a todo.txt in your main user area, or create a new one if it can't find one. If you like to keep your todo.txt somewhere else, I suggest you softlink it to ~. 

To make todo.app run on startup click go to the Accounts panel in System Preferences. Make sure your own user account is selected, then click "Login Items". Then either drag-and-drop todo.app into the list, or press the "+" sign and select it. To remove it, do the same, but click the "-" sign.

Roadmap
=======
There is a partial wishlist of features in the accompanying todo.txt file but I am unlikely to implement any of them unless other people find this useful as well.