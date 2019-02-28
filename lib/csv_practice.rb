# csv_practice.rb
require "csv"
require "awesome_print"
require "pry"

# Part 1 - CSV Practice
def load_data(filename)
  array_of_arrays = CSV.read(filename)
  keys = array_of_arrays[0]
  array_of_arrays.delete_at(0)
  array_of_hashes = array_of_arrays.map do |array|
    keys.zip(array).reduce({}) do |memo, value|
      memo.merge({ value[0] => value[1] })
    end
  end
  return array_of_hashes
end

def total_medals_per_country(olympic_data)
  olympic_data = olympic_data.reject { |event| event["Medal"] == "NA" }
  grouped_by_country = olympic_data.group_by do |event|
    event["Team"]
  end
  total_medals_per_country = grouped_by_country.map do |key, value|
    { :country => key, :total_medals => value.length }
  end
  return total_medals_per_country
end

def save_medal_totals(filename, medal_totals)
  CSV.open(filename, "w") do |csv|
    csv << ["Country", "Total Medals"]
    medal_totals.each do |country|
      csv << [country[:country], country[:total_medals]]
    end
  end
end

# Part 2 - More Enumerable Practice

def all_gold_medal_winners(olympic_data)
  return olympic_data.select { |event| event["Medal"] == "Gold" }
end

def medals_sorted_by_country(medal_totals)
  return medal_totals.sort_by { |country| country[:country] }
end

def country_with_most_medals(medal_totals)
  return medal_totals.max_by { |country| country[:total_medals] }
end

def athlete_height_in_inches(olympic_data)
  converted = []
  olympic_data.each do |hash|
    clone = hash.clone
    converted << clone
  end
  converted.each do |event|
    event["Height"] = (event["Height"].to_i / 2.5)
  end
  return converted
end
