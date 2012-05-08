require 'test_helper'
require 'app'
require 'stringio'

class App < Configurable
  config.logger = Logger.new StringIO.new

  config.tubular = "way cool"
  config.awesome = nil
  config.mondo = lambda { |a, b| return a, b }
  from_yaml(File.join(File.dirname(__FILE__), 'test.yml')) do |hash|
    config.top_key1 = hash['key1']
  end
  from_yaml(File.join(File.dirname(__FILE__), 'test.yml'), "development") do |hash|
    config.test_key1 = hash['key1']
  end
end

class AppTest < ActiveSupport::TestCase
  test "should access many ways" do
    assert_equal "way cool", App.tubular
    assert_equal "way cool", App["tubular"]
    assert_equal "way cool", App[:tubular]
  end

  test "should parse and yield yaml" do
    assert_equal "value1", App[:test_key1]
    assert_equal "topvalue1", App[:top_key1]
  end

  test "should return booleans" do
    assert_equal true, App.tubular?
    assert_equal false, App.awesome?
  end

  test "should pass args" do
    assert_nothing_raised do
      App.mondo(1, 2)
    end
  end

  test "should warn for nonexistent keys" do
    log = App.logger.instance_variable_get(:@logdev).dev
    orig_length = log.length
    App.outrageous!
    assert_not_equal orig_length, log.length
  end

  test "should be reopenable" do
    App.configure do
      config.funky = Time.now
    end

    assert App.funky.is_a?(Time)
  end

  test "should be private" do
    assert_raise(NoMethodError) { App.assign = "this" }
    assert_raise(NoMethodError) { App.config = {} }
  end
end
