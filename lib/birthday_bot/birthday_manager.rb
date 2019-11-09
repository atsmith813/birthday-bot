class BirthdayManager
  attr_accessor :birthdays, :todays_birthdays

  VALID_MONTHS = %w(january february march april may june july august september october november december).freeze

  VALID_BIRTHDAY_TYPES = [:past, :today].freeze

  def initialize(birthdays)
    @birthdays = birthdays
    @todays_birthdays = birthdays.select { |birthday| birthday.date == Date.today }.sort_by(&:date)
  end

  def send_todays_birthdays_text()
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    client = Twilio::REST::Client.new(account_sid, auth_token)

    from = ENV['FROM_PHONE_NUMBER'] # Your Twilio number
    to = ENV['TO_PHONE_NUMBER'] # Your mobile phone number

    client.messages.create(
      from: from,
      to: to,
      body: create_birthday_text()
    )
  end

  def get_birthday_by_name(name)
    return nil unless name

    @birthdays.find { |birthday| birthday.name == name }
  end

  def get_birthdays_by_date(date)
    return nil unless date

    date = Date.parse(date)
    birthdays = @birthdays.select { |birthday| birthday.date == date }
    birthdays.sort_by(&:date)
  end

  def get_birthdays_by_month(month_number)
    raise ArgumentError, "Invalid month_number".red unless (1..12).include?(month_number)

    birthdays_by_month = @birthdays.select { |birthday| birthday.date.month == month_number }
    birthdays_by_month.sort_by(&:date)
  end

  def get_birthdays_on_or_between(start_date, end_date)
    raise TypeError, "start_date is not a Date".red unless start_date.is_a? Date
    raise TypeError, "end_date is not a Date".red unless end_date.is_a? Date

    raise ArgumentError, "start_date must be before end_date".red if start_date > end_date

    birthdays_in_range = @birthdays.select { |birthday| birthday.date >= start_date && birthday.date <= end_date }
    birthdays_in_range.sort_by(&:date)
  end

  def get_birthdays_on_or_before(end_date)
    raise TypeError, "end_date is not a Date".red unless end_date.is_a? Date

    birthdays_in_range = @birthdays.select { |birthday| birthday.date <= end_date }
    birthdays_in_range.sort_by(&:date)
  end

  def get_birthdays_on_or_after(start_date)
    raise TypeError, "start_date is not a Date".red unless start_date.is_a? Date

    birthdays_in_range = @birthdays.select { |birthday| birthday.date >= start_date }
    birthdays_in_range.sort_by(&:date)
  end

  def update_birthdays(spreadsheet, type)
    raise ArgumentError, "type must be :past or :today".red unless VALID_BIRTHDAY_TYPES.include? type

    birthdays =
      case type
      when :past
        birthday_manager = BirthdayManager.new(@birthdays)
        birthday_manager.get_birthdays_on_or_before(Date.today.prev_day)
      when :today
        @todays_birthdays
      end

    if birthdays.length == 0
      puts "No birthdays found for type :#{type}".yellow

      return true
    end

    ws = spreadsheet.worksheets.first

    (1..ws.num_rows).each do |row|
      name = ws[row, 1]
      birthday = birthdays.find { |bday| bday.name == name }

      next unless birthday

      next_birthday = birthday.date.next_year.to_s
      ws[row, 2] = next_birthday

      puts "Set #{name}'s birthday to #{next_birthday}".yellow
    end

    ws.save

    true
  end

  def create_birthday_text()
    if @todays_birthdays.length > 0
      birthday_text = "Friends with birthdays today:\n"
      @todays_birthdays.each { |birthday | birthday_text += "#{birthday.name}\n" }

      return birthday_text
    else
      return "No birthdays today!"
    end
  end
end
