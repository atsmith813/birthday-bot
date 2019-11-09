module SheetManager

  # Imports Birthday records to Google worksheet - returns true if new birthdays
  # are imported.
  # Otherwise, it returns false (no birthdays provided or no new birthdays were
  # found).
  # It accepts birthdays (An Array of Birthday records) and
  # spreadsheet (a GoogleDrive::Spreadsheet)
  def self.import_new_birthdays(birthdays, spreadsheet)
    raise TypeError, "birthdays must be an Array" unless birthdays.is_a? Array
    raise TypeError, "birthdays must be an Array of Birthday objects" unless birthdays.first.is_a? Birthday

    if birthdays.length == 0
      "No birthdays found!".red
      return false
    end

    raise ArgumentError, "No spreadsheet provided!".red if spreadsheet.nil?
    raise TypeError, "spreadsheet is not a GoogleDrive::Spreadsheet".red unless spreadsheet.is_a? GoogleDrive::Spreadsheet

    ws = spreadsheet.worksheets.first

    # Grab the existing names in the worksheet
    existing_names = ws.rows.map(&:first)
    puts "Found #{existing_names.length} existing names!".green

    # Remove existing birthdays
    if existing_names.length > 0
      puts "Removing duplicate birthdays...".yellow
      birthdays.reject! { |birthday| existing_names.include? birthday.name }
      puts "Removed duplicate birthdays!".green
    end

    # Exit if no new birthdays were found to import
    if birthdays.length == 0
      puts "No new birthdays found!".red
      return false
    end

    # Appends newly found birthdays to the worksheet
    puts "Adding #{birthdays.length} new birthdays...".yellow

    birthdays = birthdays.sort_by(&:date)

    birthdays.each.with_index(ws.num_rows + 1) do |birthday, i|
      ws[i, 1] = birthday.name
      ws[i, 2] = birthday.date.to_s
    end

    ws.save

    puts "New birthdays added!".green
    true
  end

  # Parse Google Sheet for Birthdays. Returns an Array of Birthdays
  # Accepts a GoogleDrive::Spreadsheet object which can be obtained from the
  # open_spreadsheet method
  def self.export_birthdays_from_spreadsheet(spreadsheet)
    raise ArgumentError, "No spreadsheet provided!".red if spreadsheet.nil?
    raise TypeError, "spreadsheet is not a GoogleDrive::Spreadsheet".red unless spreadsheet.is_a? GoogleDrive::Spreadsheet

    ws = spreadsheet.worksheets.first

    birthdays = []

    puts "Exporting #{ws.num_rows} birthdays...".yellow

    (1..ws.num_rows).each do |row|
      name = ws[row, 1]
      date = Date.parse(ws[row, 2])

      birthdays << Birthday.new(name, date)
    end

    if birthdays.length > 0
      puts "#{birthdays.length} birthdays found!".green
    else
      puts "No birthdays found!".red
    end

    birthdays.sort_by(&:date)
  end

  # Authenticate and open Google spreadsheet
  # Accepts spreadsheet_name as a string or checks the ENV for GOOGLE_SHEET_NAME
  # as the default/fallback
  def self.open_spreadsheet(spreadsheet_name = nil)
    spreadsheet_name ||= ENV['GOOGLE_SHEET_NAME']

    raise ArgumentError, "No spreadsheet_name was given or set in the ENV at GOOGLE_SHEET_NAME!".red if spreadsheet_name.nil?

    puts "Opening Google worksheet...".yellow
    session = GoogleDrive::Session.from_service_account_key(StringIO.new(ENV['GOOGLE_APPLICATION_CREDENTIALS']))
    spreadsheet = session.spreadsheet_by_name(spreadsheet_name)

    raise "No spreadsheet found!".red unless spreadsheet

    puts "Google spreadsheet opened!".green

    spreadsheet
  end
end
