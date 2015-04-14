require 'test_helper'
require 'helpers'
require 'ui'

RAILS_ENV = 'production'

class UiForRailsTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  #p ENV
  extend UI::Helpers

  puts Benchmark.measure {  
    str = <<-end_src 
      <ul id="ui-menu" class="menu">
        <li class="ui-menu-open">
          <h3><a href=''>bb</a></h3>
          <ul></ul>
        </li>
        <li>
          <h3><a href=''>cc</a></h3>
          <ol></ol>
        </li>
      </ul>
    end_src
  }
  test "the truth" do
    assert true
  end
end
