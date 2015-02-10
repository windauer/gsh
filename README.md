# gsh
Draft work on geospatial history project

To get started
- Clone the repository to your desktop

To run the app (assumes ant and eXist)
- Run `ant`
- Open eXist Dashboard > Package Manager
- Click on the `+` icon and drag the `build/gsh-*.xar` file onto the window 
- Close the Package Manager
- Select the app icon from the Dashboard's menu of apps
- Go to the `territories` section

To upload new versions of the app
- In the Package Manager, delete the existing version of the app
- Run ant and upload again

To edit the data (assumes oXygen)
- Open `gsh.xar` in oXygen
- Open files from the `data/territories` folder
- As you make edits, oXygen should flag schema issues
- Also, in the app, cells with likely problems are flagged by `*` and have a yellow background
- Commit fixes as pull requests

To automate build and deploy procedure (to eliminate the Dashboard step above)
- Edit build properties with eXist URI, dba username, password
- Eun `ant install`
