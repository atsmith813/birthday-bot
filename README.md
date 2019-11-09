# Birthday Bot

## Description

I’ve always wanted a better way to keep up with friends and family by wishing them a happy birthday. Most people post something short and sweet when they see the notification on Facebook while they’re surfing the feed for a fresh dopamine hit. Yes, I’m one of *those* people who don’t really use Facebook.

So for those of you who are like me (don’t use Facebook and want to wish others a happy birthday via text) keep reading to see how I built a little "bot" to help me accomplish this.

Facebook used to be how I managed birthdays. But they somewhat recently [removed the ability to export birthdays from Facebook](https://www.digitaltrends.com/news/facebook-removes-friends-birthday-export/). To be fair, it was in the name of privacy so I can’t *really* complain about that.

As referenced in the [article](https://www.digitaltrends.com/news/facebook-removes-friends-birthday-export/), someone built a nice [workaround](https://github.com/mobeigi/fb2cal) to export birthdays from Facebook using Python. By following the steps in the [README](https://github.com/mobeigi/fb2cal/blob/master/README.md), I was able to get all of the data I need to get started. All of my Facebook friends' birthdays are exported into a file named `birthdays.ics`. This will be the starting point - you have birthdays in a `.ics` file.

## Overview

Here's how the 🤖 works.

1. It looks for the `birthdays.ics` file in the root directory and uploads any new birthdays to a Google Sheet.
2. Every day, the bot reads the Google Sheet to find any birthdays on the current day.
3. The bot then sends a text message with any found birthdays.
4. The current day's birthdays are then updated to be 1 year in the future.

## Instructions

The goal of this project is for others to be able to quickly and easily setup the same bot to use themselves. 

### Requirements

- GitHub account
- Heroku account
- Twilio account
- Google Docs account

### Quick Start

First things first, I'm going to assume you are somewhat familiar with GitHub, Heroku, and the command line. If you have any trouble, feel free to open an issue, open a PR, or fork this project to play with on your own!

1. Fork this project.
2. Create a Heroku project and deploy your forked code to your project. [Here's](https://devcenter.heroku.com/articles/git) a guide on how to do this.
3. Set your config vars on your Heroku project from the variables described above and listed in [.env.template](.env.template). [Here's](https://devcenter.heroku.com/articles/config-vars) a guide to setting config vars on Heroku.
4. Install the [Heroku Scheduler add-on](https://elements.heroku.com/addons/scheduler).
5. Setup a scheduler on Heroku to run `rake birthdays:send_todays_birthdays_text` daily at a time of your choosing.

### Required ENV variables

- **TWILIO_ACCOUNT_SID** - you can find this on the dashboard for your Twilio project.
- **TWILIO_AUTH_TOKEN** - you can find this on the dashboard for your Twilio project.
- **FROM_PHONE_NUMBER** - this is your Twilio phone number which you can find this on the dashboard for your Twilio project.
- **TO_PHONE_NUMBER** - your phone number or the phone number you'd like to text the birthdays to.
- **GOOGLE_SHEET_NAME** - the name of the Google Spreadsheet with the Birthdays.
- **GOOGLE_APPLICATION_CREDENTIALS** - a JSON string of your Google Drive credentials.

[Sign up for Twilio](https://www.twilio.com/try-twilio) and create a project. You can find a [guide](https://www.twilio.com/docs/sms/quickstart/ruby) on how to do this or watch a [video](https://www.youtube.com/watch?v=8SLdV8dn7_I) to get you started. It’s very quick.

Twilio also has a great [guide](https://www.twilio.com/blog/2017/03/google-spreadsheets-ruby.html) on how to setup Google Drive, including a nifty gif of a screen share walking through the steps.

### Rake tasks

Everything is packaged up into Rake tasks.

- `rake birthdays:import` - this will open the `birthdays.ics` file in the root directory, parse the data into Birthday objects, and upload them to Google Sheets.
- `rake birthdays:update_past` - if you find yourself in a situation where you exported birthdays to `birthdays.ics` and then don't start running the bot until days later, you'll have some birthdays that are missed. You can run this task to update any birthdays that are in the past.
- `rake birthdays:send_todays_birthdays_text` - this is the primary task that gets scheduled to run daily on Heroku. It opens the Google Sheet, parses out the birthdays, finds the current day's birthdays, sends the text message, and then updates the current birthdays to 1 year in the future.

## Future Ideas
Some future ideas/features I hope to add:
- Turn this into an Alexa skill so you can ask your Alexa, "Alexa, whose birthday is it today?"
- Add future birthday notices (i.e. get a notification 1 week before the actual birthday)
- Import phone numbers of friends from contacts
