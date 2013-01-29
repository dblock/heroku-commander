require 'spec_helper'

describe Heroku::Commander do
  context "without arguments" do
    subject do
      Heroku::Commander.new
    end
    its(:app) { should be_nil }
  end
  context "with app" do
    before :each do
      Heroku::Executor.stub(:run)
    end
    subject do
      Heroku::Commander.new({ :app => "heroku-commander" })
    end
    its(:app) { should eq "heroku-commander" }
    its(:config) { should be_a Heroku::Config }
  end
  context "with a heroku configuration" do
    before :each do
      Heroku::Executor.stub(:run).with("heroku config -s --app heroku-commander").
        and_yield("APP_NAME=heroku-commander").
        and_yield("RACK_ENV=staging")
    end
    subject { Heroku::Commander.new({ :app => "heroku-commander" }).config }
    context "config" do
      its(:size) { should == 2 }
      it { subject["APP_NAME"].should eq "heroku-commander" }
    end
  end
end

