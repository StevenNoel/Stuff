# Teams and Microsoft MDT or Master/Golden Image build notification
This script can be used to automate the Notification when a Master/Godlen Image has been completed.

I'm currently using this in my Microsoft MDT task sequence.  One of the last tasks is to run the powershell script in the task sequence.  This will put out a notification in a Teams channel.

*Note*:  You will need to setup your Teams Web Hook prior to setting up this script. Use steps 1-7 from https://kb.itglue.com/hc/en-us/articles/115001798191-Setting-up-Microsoft-Teams-webhook-notifications.


#Sample Output
![Teams-Notification](https://github.com/StevenNoel/Stuff/blob/master/Microsoft/Teams/Teams-Notification.PNG)
