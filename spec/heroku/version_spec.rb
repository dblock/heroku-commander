require 'spec_helper'

describe Heroku::Commander do
  it "has a version" do
    Heroku::Commander::VERSION.should_not be_nil
  end
end

