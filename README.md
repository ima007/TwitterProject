## TwitterProject

This is a basic twitter app to read and compose tweets the [Twitter API](https://apps.twitter.com/).

Time spent: X hours

### Features

- Hamburger menu
  - [X] Dragging anywhere in the view should reveal the menu.
  - [X] The menu should include links to your profile, the home timeline, and the mentions view.
  - [X] The menu can look similar to the LinkedIn menu below or feel free to take liberty with the UI.

- Profile page
  - [ ] Contains the user header view
  - [ ] Contains a section with the users basic stats: # tweets, # following, # followers
  - [ ] Optional: Implement the paging view for the user description.
  - [ ] Optional: As the paging view moves, increase the opacity of the background screen.
  - [ ] Optional: Pulling down the profile page should blur and resize the header image.

- Home Timeline
  - [X] Tapping on a user image should bring up that user's profile page

- Optional: Account switching
  - [ ] Long press on tab bar to bring up Account view with animation
  - [ ] Tap account to switch to
  - [ ] Include a plus button to Add an Account
  - [ ] Swipe to delete an account

### Walkthrough
TBD

### Installation
* Requires Xcode 6.3 Beta 2
* Create a Twitter app to get a Consumer Key and Consumer Secret from http://apps.twitter.com
* In the root folder, create ApiConfig.xcconfig
* Inside ApiConfig.xcconfig, add:

````
    TWEET_CONSUMER_KEY = your-consumer-key
    TWEET_CONSUMER_SECRET = your-consumer-secret
````

* Open the TwitterProject.xcworkspace file, and build!
