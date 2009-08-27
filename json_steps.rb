Then /^I should see the following JSON$/ do |table|
  table.hashes.each do |hash|
    # JSON matcher
    hash.should match_json(response.body)
  end
end

Then /^I should not see the following JSON$/ do |table|
  table.hashes.each do |hash|
    hash.should_not match_json(response.body)
  end
end