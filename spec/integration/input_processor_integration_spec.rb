# frozen_string_literal: true

require 'spec_helper'
require_relative '../../input_processor'
require_relative '../../forms/record_form'
require_relative '../../entities/record'
require_relative '../../record_processor'
require_relative '../../services/process_funds'
require 'fileutils'
require 'json'
require 'date'
require_relative '../../lib/date_comparisons'
using DateComparisons

INPUT_FILE = 'input.txt'
OUTPUT_FILE = 'output.txt'
EXPECTED_OUTPUT_FILE = 'spec/tmp/expected_output.txt'
CUSTOMER_IDS = [1, 2, 3, 5, 7].freeze
START_DATE = Date.parse('2010-01-01')
END_DATE = Date.parse('2011-12-12')
MAX_DAILY = 5_000
MAX_MONTHLY = 20_000

# rubocop:disable Metrics/BlockLength
describe 'InputProcessor Integration' do
  before(:all) do
    FileUtils.mkdir_p('spec/tmp')
    # Generate input file
    records = []
    d = START_DATE
    id_counter = 1
    months = []
    while d <= END_DATE
      months << d if d.day == 1
      d += 1
    end
    months.each do |month_start|
      month_dates = (month_start...(month_start.next_month)).to_a & (START_DATE..END_DATE).to_a
      num_records = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13].sample
      month_dates.sample(num_records).sort.each do |date|
        customer_id = CUSTOMER_IDS.sample
        record_id = id_counter
        id_counter += 1
        load_amount = date.wday == 1 ? 3000 : 1000
        records << {
          'id' => record_id,
          'customer_id' => customer_id,
          'load_amount' => load_amount,
          'time' => date.to_s
        }
        break if records.size >= 100
      end
      break if records.size >= 100
    end
    records = records.sort_by { |r| r['time'] }
  end

  after(:all) do
    FileUtils.rm_f(OUTPUT_FILE)
    FileUtils.rm_f(EXPECTED_OUTPUT_FILE)
  end

  it 'produces output matching expected output based on business rules' do
    # Compute expected output
    state = {}
    last_prime_record_date = nil
    File.open(EXPECTED_OUTPUT_FILE, 'w') do |f|
      File.foreach(INPUT_FILE) do |line|
        hash = JSON.parse(line)
        form = RecordForm.new.call(hash)
        record = Record.new(**form.to_h)

        customer_id = record.customer_id
        date = record.time
        state[customer_id] ||= { daily: {}, monthly: {}, last_date: nil }
        # Monday doubling

        funds = record.calculated_load_funds
        # Prime number rule
        is_prime = Prime.prime?(record.id)
        already_prime_this_month = last_prime_record_date&.same_month?(record.time)
        if is_prime && already_prime_this_month
          f.puts({ id: record.id, customer_id: customer_id, accepted: false }.to_json)
          next
        end
        # Daily/monthly limits
        day = date.to_s
        state[customer_id][:daily][day] ||= 0
        state[customer_id][:daily][day] ||= 0
        state[customer_id][:monthly][[date.year, date.month]] ||= 0

        if state[customer_id][:daily][day] + funds > MAX_DAILY
          f.puts({ id: record.id, customer_id: customer_id, accepted: false }.to_json)
          next
        end
        if state[customer_id][:monthly][[date.year, date.month]] + funds > MAX_MONTHLY
          f.puts({ id: record.id, customer_id: customer_id, accepted: false }.to_json)
          next
        end
        # Accept
        last_prime_record_date = record.time if record.id.prime?
        state[customer_id][:daily][day] += funds
        state[customer_id][:monthly][[date.year, date.month]] += funds
        state[customer_id][:last_date] = date
        f.puts({ id: record.id, customer_id: customer_id, accepted: true }.to_json)
      end
    end
    # Run InputProcessor
    InputProcessor.new(input_file: INPUT_FILE, output_file: OUTPUT_FILE).call
    # Compare files
    actual = File.read(OUTPUT_FILE).split("\n")
    expected = File.read(EXPECTED_OUTPUT_FILE).split("\n")
    puts actual - expected
    expect(actual).to eq(expected)
  end
end
# rubocop:enable Metrics/BlockLength
