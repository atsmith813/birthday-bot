require 'dotenv/tasks'

require_relative './lib/birthday_bot'

namespace :birthdays do
  desc "Import birthdays from .ics file to Google Sheets"
  task import: :dotenv do
    # Parse .ics file for Birthdays
    birthdays = IcsParser.parse_to_birthdays('birthdays.ics')

    # Import new birthdays to Google Sheets
    spreadsheet = SheetManager.open_spreadsheet
    SheetManager.import_new_birthdays(birthdays, spreadsheet)
  end

  desc "Update birthdays in the past"
  task update_past: :dotenv do
    # Export birthdays from Google Sheets
    spreadsheet = SheetManager.open_spreadsheet
    birthdays = SheetManager.export_birthdays_from_spreadsheet(spreadsheet)

    # Update past birthdays
    birthday_manager = BirthdayManager.new(birthdays)
    birthday_manager.update_birthdays(spreadsheet, :past)
  end

  desc "Send today's birthdays text"
  task send_todays_birthdays_text: :dotenv do
    # Export birthdays from Google Sheets
    spreadsheet = SheetManager.open_spreadsheet
    birthdays = SheetManager.export_birthdays_from_spreadsheet(spreadsheet)

    birthday_manager = BirthdayManager.new(birthdays)

    # Send today's birthdays text
    birthday_manager.send_todays_birthdays_text()

    # Update birthdays
    birthday_manager.update_birthdays(spreadsheet, :today)
  end
end

