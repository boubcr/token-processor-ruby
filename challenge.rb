require 'json'
require 'fileutils'

class Challenge
  def execute
    companies = FileManager.get_companies_from_json
    users = FileManager.get_users_from_json

    output = get_users_by_company(companies, users)
    output_string = build_txt_output_string(output)
    FileManager.write_on_txt_file(output_string)
  end

  private

  def get_users_by_company(companies, users)
    active_users_per_company = users
                                 .select(&:active_status)
                                 .group_by(&:company_id)

    active_users_per_company.sort.map do |company_id, user_list|
      company = companies.find { |c| c.id == company_id }
      company ? OutputCompany.new(company, user_list) : nil
    end.compact
  end

  def build_txt_output_string(companies)
    companies.map do |company|
      output = []
      output << build_line("Company Id", company.company_id, 1)
      output << build_line("Company Name", company.name, 1)
      output << build_line("Users Emailed", nil, 1)
      output << build_user_lines(company.emailed) if company.emailed.any?
      output << build_line("Users Not Emailed", nil, 1)
      output << build_user_lines(company.not_emails) if company.not_emails.any?
      output << build_line("Total amount of top ups for #{company.name}", company.tokens, 1)
      output.join
    end.join("\n")
  end

  def build_user_lines(users)
    users.map { |user| build_user_line(user) }.join
  end

  def build_user_line(user)
    output = []
    user_name = "#{user.last_name}, #{user.first_name}, #{user.email}"
    output << build_line(user_name, nil, 2)
    output << build_line("Previous Token Balance, #{user.previous_token}", nil, 3)
    output << build_line("New Token Balance, #{user.new_token}", nil, 3)
    output.join
  end

  def build_line(label, line, level)
    "\t" * level + "#{label}" + (line ? ": #{line}" : "") + "\n"
  end
end

class FileManager
  COMPANIES_JSON_FILE = './companies.json'
  USERS_JSON_FILE = './users.json'
  OUTPUT_TXT_FILE = './output.txt'

  def self.write_on_txt_file(data)
    File.open(OUTPUT_TXT_FILE, 'w') { |file| file.write(data) }
  rescue StandardError => e
    raise WriteFileException, "Error writing on txt file: #{e.message}"
  end

  def self.get_companies_from_json
    data = File.read(COMPANIES_JSON_FILE)
    companies = JSON.parse(data, symbolize_names: true)
    companies.map { |company| Company.new(company) }.sort_by(&:id)
  rescue StandardError => e
    raise ReadFileException, "Error getting company json file: #{e.message}"
  end

  def self.get_users_from_json
    data = File.read(USERS_JSON_FILE)
    users = JSON.parse(data, symbolize_names: true)
    users.map { |user| User.new(user) }.sort_by(&:last_name)
  rescue StandardError => e
    raise ReadFileException, "Error getting users json file: #{e.message}"
  end
end

class WriteFileException < StandardError; end
class ReadFileException < StandardError; end

class OutputCompany
  attr_reader :company_id, :name, :tokens, :emailed, :not_emails

  def initialize(company, users)
    @company_id = company.id
    @name = company.name
    @tokens = company.top_up * users.size
    @emailed = []
    @not_emails = []

    users.each do |user|
      output_user = OutputUser.new(user, company.top_up)
      if company.email_status && user.email_status
        @emailed << output_user
      else
        @not_emails << output_user
      end
    end
  end
end

class OutputUser
  attr_reader :first_name, :last_name, :email, :previous_token, :new_token

  def initialize(user, company_tokens)
    @first_name = user.first_name
    @last_name = user.last_name
    @email = user.email
    @previous_token = user.tokens
    @new_token = user.tokens + company_tokens
  end
end

class Company
  attr_reader :id, :name, :top_up, :email_status

  def initialize(data)
    @id = data[:id]
    @name = data[:name]
    @top_up = data[:top_up]
    @email_status = data[:email_status]
  end
end

class User
  attr_reader :id, :first_name, :last_name, :email, :company_id, :email_status, :active_status, :tokens

  def initialize(data)
    @id = data[:id]
    @first_name = data[:first_name]
    @last_name = data[:last_name]
    @email = data[:email]
    @company_id = data[:company_id]
    @email_status = data[:email_status]
    @active_status = data[:active_status]
    @tokens = data[:tokens]
  end
end

# To run the code
Challenge.new.execute
