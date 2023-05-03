# Hipo Labs IOS Assignment

![githubApp](https://user-images.githubusercontent.com/98701769/236035255-136006c0-99fc-4ce4-9244-0cd8fb96bc25.jpg)


 + This application is a member list application where user can add, edit and delete members.The app also allows the user to search for members by their first name or position and to sort the members list by the number of occurrences of a particular character in the members' last name.
 
 + The application uses CoreData to store the member list data and also reads the member data from the JSON file supplied with the application.
 
 + The application shows the details of a member selected by the user. It pulls data from the Github API, showing a user's profile information on GitHub, including their avatar, number of followers, number of people they follow, and number of public repositories they own. It also displays a table view with some details about its repositories, such as the repository name, the language it is written in, the number of stars it has, and the date it was created.
 
 + Add members page provides functionality to add new members to a member list. It uses Core Data to store member information and checks the validity of the entry before adding the member to the list. It also makes an API call to the GitHub API to verify the existence of the entered GitHub username.
 
 + The member edit page is used to change the information of an existing member and the new information is replaced with Core Data.
 
 + The Ranking page creates a view on a member list screen, showing members alphabetically sorted by last name.
