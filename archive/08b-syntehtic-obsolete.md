### TIP: CREATING A DASHBOARD WITH PERFORMANCE VIEW DATA
Use the performance view to identify the path, object, counter, and instance required when adding the performance widget. Creating this view ahead of time makes it easier to determine what the appropriate information is when you are configuring the performance widget.


### Skip this part: Recording a web browser session
1. Using the Web Application Editor, the next step is to record a web session and look at the additional options available when creating a web application synthetic transaction. Begin by deleting any web addresses present in the editor in preparation for recording a web session. Select the website configured in the wizard in the previous section and click the Delete option on the right-hand side in the Actions pane under the Web Request section. Click OK when prompted.
1. Click the Start Capture button. This opens an Internet Explorer browser window with a Web Recorder pane on the left-hand side. Approve any plugins displayed at the bottom of the screen.
1. With the editor cleared, record a web session while browsing a number of pages on Bing, entering a search term, browsing to a website, and browsing to an https (SSL) site. This process demonstrates OpsMgr’s capability to simulate various browser steps and record them. For this example, browse to Bing (www.bing.com) and perform a search. From the search results browse to a resulting wiki page and from there open an https site.
1. After you complete recording the web session, click the Stop button in the Web Recorder pane. This closes Internet Explorer, bringing you back to the editor with the web addresses displayed in the console.
