# csv_practice_spec.rb

require "minitest"
require "minitest/spec"
require "minitest/autorun"
require "minitest/reporters"
require "minitest/pride"

require_relative "../lib/csv_practice"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

CSV_HEADERS = %w[ID Name Sex Age Height Weight Team NOC Games Year Season City Sport Event Medal]
MEDAL_TOTALS_FILENAME = "data/medal_totals.csv"
OLYMPIC_DATA_FILENAME = "data/athlete_events.csv"

describe "CSV Practice Methods" do
  describe "load_data" do
    it "returns an array of hashes" do
      # Arrange & Act
      data = load_data(OLYMPIC_DATA_FILENAME)

      # Assert
      expect(data.class).must_equal Array
      data.each do |data_row|
        expect(data_row.class).must_equal Hash

        CSV_HEADERS.each do |key|
          expect(data_row.key?(key)).must_equal true
        end
      end
    end

    it "has the proper number of rows" do
      # Arrange & Act
      data = load_data(OLYMPIC_DATA_FILENAME)

      # Assert
      expect(data.length).must_equal 49503
    end

    it "has the right 1st and last row" do
      # Arrange & Act
      data = load_data(OLYMPIC_DATA_FILENAME)

      # Assert
      expect(data.first["ID"]).must_equal "21"
      expect(data.first["Name"]).must_equal "Ragnhild Margrethe Aamodt"
      expect(data.first["Team"]).must_equal "Norway"
      expect(data.last["ID"]).must_equal "135568"
      expect(data.last["Name"]).must_equal "Olga Igorevna Zyuzkova"
      expect(data.last["Team"]).must_equal "Belarus"
    end
  end

  describe "total_medals_per_country" do
    # Arrange
    data = load_data(OLYMPIC_DATA_FILENAME)

    correct_totals = {
      "Norway" => 133,
      "United States" => 944,
      "Canada" => 321,
      "Russia" => 470,
      "China" => 423,
      "Bahrain" => 3,
      "Jamaica" => 69,
      "United Arab Emirates" => 1,
    }

    it "should return an array of hashes" do

      # Act
      total_medals = total_medals_per_country(data)

      # Assert
      expect(total_medals).must_be_instance_of Array
      correct_totals.keys.each do |country|
        country_total = total_medals.find do |medal_total|
          medal_total[:country] == country
        end

        expect(country_total[:total_medals]).must_equal correct_totals[country]
      end
    end
  end

  describe "Can create a total medal file" do
    it "The file is created" do
      # Arrange
      data = load_data(OLYMPIC_DATA_FILENAME)
      medal_totals = total_medals_per_country(data)

      # Act
      save_medal_totals(MEDAL_TOTALS_FILENAME, medal_totals)

      # Assert
      expect(File.exist?(MEDAL_TOTALS_FILENAME)).must_equal true
    end

    it "The file contains the right entries and headers" do
      # Arrange
      data = load_data(OLYMPIC_DATA_FILENAME)
      medal_totals = total_medals_per_country(data)

      # Act
      save_medal_totals(MEDAL_TOTALS_FILENAME, medal_totals)

      # Assert
      CSV.read(OLYMPIC_DATA_FILENAME, headers: true) do |line|
        correct_totals.keys.each do |key|
          expect(line[key]).must_equal correct_totals[key]
        end
      end
    end
  end

  describe "All Gold Medal Winners" do
    # Arrange
    data = load_data(OLYMPIC_DATA_FILENAME)

    # Act
    gold_medal_winners = all_gold_medal_winners(data)

    it "returns an array of hashes" do
      # Assert
      expect(gold_medal_winners.class).must_equal Array
      gold_medal_winners.each do |winner|
        expect(winner.class).must_equal Hash
      end
    end

    it "They all have `Gold` in the medal field" do
      # Assert
      gold_medal_winners.each do |winner|
        expect(winner["Medal"].upcase.include? "GOLD").must_equal true
      end
    end

    it "has the correct number of gold medalists" do
      count = data.sum do |athlete|
        athlete["Medal"].upcase == "GOLD" ? 1 : 0
      end
      expect(gold_medal_winners.length).must_equal count
    end
  end

  describe "country_totals_sorted_by_country" do
    it "orders all the total medal reports" do
      # Arrange
      data = load_data(OLYMPIC_DATA_FILENAME)
      medal_totals = total_medals_per_country(data)

      # Act
      sorted_medal_list = medals_sorted_by_country(medal_totals)

      # Assert
      last_medal = sorted_medal_list.first
      sorted_medal_list.each do |current_entry|
        expect(last_medal[:country] <= current_entry[:country]).must_equal true

        last_medal = current_entry
      end
    end
  end

  describe "total_medals_per_country" do
    it "returns the right value" do
      # Arrange
      data = load_data(OLYMPIC_DATA_FILENAME)
      medal_totals = total_medals_per_country(data)

      # Act
      most_medals = country_with_most_medals(medal_totals)

      # Assert
      expect(most_medals[:country]).must_equal "United States"
    end
  end

  describe "athlete_height_in_inches" do
    it "correctly converts the height to inches" do
      # Arrange
      data = load_data(OLYMPIC_DATA_FILENAME)

      # Act
      converted_data = athlete_height_in_inches(data)

      # Assert
      expect(converted_data.class).must_equal Array
      converted_data.each_with_index do |entry, index|
        expect(entry.class).must_equal Hash
        # puts "#{data[index]["Height"]}"
        # puts "Converted data #{entry["Height"]}"
        expect(entry["Height"]).must_be_close_to(data[index]["Height"].to_i / 2.5)
      end
    end
  end
end
