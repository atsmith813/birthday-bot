module IcsParser

  # Returns an Array of Birthday objects parsed from the provided .ics file
  def self.parse_to_birthdays(file_name)
    raise "File not found! - #{file_name}" unless File.exist? file_name
    raise "File must be a .ics file!" unless File.extname(file_name) == '.ics'

    cal = File.read(file_name).split("BEGIN:VEVENT")
    cal.shift # First row is meta data from export

    birthdays = []

    cal.each do |event|
      date = Date.parse(
        event.split("DATE:").last
        .split("\rDURATION:").first
      )

      name = event.split("SUMMARY:").last
        .split("'s Birthday").first

      birthdays << Birthday.new(name, date)
    end

    if birthdays.length > 0
      puts "Parsed #{birthdays.length} birthdays!".green
    else
      puts "No birthdays found!".red
    end

    birthdays.sort_by(&:date)
  end
end
