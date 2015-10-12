ReadMe.rtf

Application: Sample Movie Database (Sample MDB)
Version: 1.0
Modification Date: 10/12/2014

Description

A sample Movie Review manager / browser with review add, edit, and delete capability. Add, edit, and delete require login to use.

Designed to meet specifications as outlined by David Gibb. Implementation consists of two executable components.
•	iOS client
⁃	Interface derived from iOS SplitView project and modified to requirement.
⁃	Caching through Core Data
⁃	REST interaction functionality implemented as a category of NSManagedObject  with specific MovieReview components in Movie Review subclass
⁃	Movie Review retrieval, insert, delete, and update achieved through Core Data and concurrently mapped to corresponding REST functions. (future implementation could include a REST NSPersistentStore to make even more transparent)
•	Python / Django REST server
⁃	Implements (among others)
⁃	GET (moviereview/ or moviereview/#/) - get movie review list or movie review item
⁃	POST (moviereview/) - insert new movie review item
⁃	PUT (moviereview/#/) - update movie review item
⁃	DELETE (moviereview/#/) - delete movie review item
⁃	OPTIONS (moviereview/) - returns fields with descriptions of movie review
⁃	Sqlite backend with schema and db managed by Django


Installation

Execute the following in order:

REST server
1.	On the machine where the iOS simulator will execute, open a terminal window and go to directory where the django app is installed / decompressed.
2.	Install Python libraries (http://www.django-rest-framework.org)
a.	pip install -U django
b.	pip install -U djangorestframework
c.	pip install -U markdown
d.	pip install -U django-filter
e.	pip install -U django-guardian
3.	Execute at the shell from the directory where the 'manage.py' exists: 'python ./manage.py runserver'
a.	to run at a different ip: 'python ./manage.py runserver <server>:<port>'
5.	Server should be available at http://localhost:8000/ for browsing if default server:port settings were used.

iOS Client
1.	Build and execute XCode project in simulator (or device but untested on device).
2.	As default user, password and server information should populate text fields, click the "Login" button to authenticate with server and start browsing movie reviews and interacting with app.




Release Notes

Unimplemented Features
•	Detail Movie Review screen could be polished more.  Only a basic implementation is in place.
•	Login screen could use more polish and improvements (see below).
•	Launch screen is basic and could use improvements.
•	Error handling is minimal and should be improved in future release.
•	ingest movie reviews from requirement REST service to this sample service.  Can be accomplished through REST keymap in NSManagedObject

iOS Client Issues
•	iOS client only confirmed on simulator (iPhone 6s & 6s plus simulator).

Login Screen
•	Looks best in portrait.  Minor formatting issues exist on login screen when opened in landscape mode.
•	Not fully tested with wrong REST server information. Use correct REST service URL when running.
•	Login screen does not permit using the application (stays on the authentication screen) without authenticating with server although application can browse, edit, and delete cached titles without logging in. A "cancel" button can be added later to bypass screen and review and act on cached reviews. Service failures (untested) will also need to be captured in code properly enable this functionally

Work Flow
•	App loads current set of Movie Reviews as provided by REST service upon app startup.  A tableview flicker may occur as application deletes working cache of movie reviews and reloads current movie set from service.

DJango / Python REST server
•	API extraneous to project exist (profile, address) that is only visible when looking at service code and API listing through browser access.  Please ignore.

Code cleanup
•	Opportunities exist to clean up and normalize portions of codebase into common methods and primitives to reduce amount of code and increase manageability (following rules of best practice).

More notes with diagram may be added later






