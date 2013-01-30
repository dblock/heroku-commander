require 'spec_helper'

describe Heroku::Config do
  context "without arguments" do
    subject do
      Heroku::Config.new
    end
    its(:app) { should be_nil }
    its(:cmdline) { should eq "heroku config -s" }
    context "reload!" do
      it "reloads the configuration" do
        Heroku::Executor.stub(:run).with("heroku config -s", { :logger => nil }).
          and_yield("APP_NAME=heroku-commander").
          and_yield("RACK_ENV=staging")
        subject.reload!
        subject.size.should == 2
        subject["APP_NAME"].should eq "heroku-commander"
        subject["RACK_ENV"].should eq "staging"
      end
      it "reloads the configuration a second time" do
        subject["APP_NAME"] = "old"
        subject["OLD_VARIABLE"] = "old"
        Heroku::Executor.stub(:run).with("heroku config -s", { :logger => nil }).
          and_yield("APP_NAME=heroku-commander").
          and_yield("RACK_ENV=staging")
        subject.reload!
        subject.size.should == 2
        subject["APP_NAME"].should eq "heroku-commander"
        subject["RACK_ENV"].should eq "staging"
      end
    end
  end
  context "with app" do
    subject do
      Heroku::Config.new({ :app => "heroku-commander" })
    end
    its(:app) { should eq "heroku-commander" }
    its(:cmdline) { should eq "heroku config -s --app heroku-commander" }
    context "reload!" do
      it "reloads the configuration" do
        Heroku::Executor.stub(:run).with("heroku config -s --app heroku-commander", { :logger => nil }).
          and_yield("APP_NAME=heroku-commander").
          and_yield("RACK_ENV=staging")
        subject.reload!
        subject.size.should == 2
        subject["APP_NAME"].should eq "heroku-commander"
        subject["RACK_ENV"].should eq "staging"
      end
    end
  end
  context "with logger" do
    subject do
      logger = Logger.new($stdout)
      Heroku::Config.new({ :logger => logger })
    end
    context "reload!" do
      it "passes the logger" do
        PTY.stub(:spawn)
        subject.logger.should_receive(:debug).with("Running: heroku config -s")
        subject.reload!
      end
    end
  end
end

