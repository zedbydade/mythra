# Rakefile

require 'rake/testtask'
require 'minitest/test_task'

Minitest::TestTask.create

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.warning = false
  t.pattern = 'lib/**/*_test.rb' # Path to your test files
end

task default: :test
