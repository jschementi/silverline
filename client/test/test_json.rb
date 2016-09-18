require '../lib/helpers/json'

DATA = '[{"updated_at": "2008/03/18 00:45:47 -0700", "title": "This is my first post", "body": "VS Languages Rock!", "post_id": null, "id": 1, "created_at": "2008/03/18 00:45:47 -0700"}, {"updated_at": "2008/03/21 14:29:24 -0700", "title": "Test", "body": "This is a test", "post_id": null, "id": 2, "created_at": "2008/03/21 14:29:24 -0700"}, {"updated_at": "2008/03/23 00:17:01 -0700", "title": "Test", "body": "Another post!", "post_id": null, "id": 3, "created_at": "2008/03/23 00:17:01 -0700"}]'

puts "---------------------------------"
puts "Before:"
puts "---------------------------------"
puts DATA

$p = JSON.new
$r = $p.parse DATA

puts "---------------------------------"
puts "After:"
puts "---------------------------------"
puts $r.inspect
