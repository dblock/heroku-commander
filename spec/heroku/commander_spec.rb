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
      Heroku::Executor.stub(:run).with("heroku config -s --app heroku-commander", { :logger => nil }).
        and_yield("APP_NAME=heroku-commander").
        and_yield("RACK_ENV=staging")
    end
    subject { Heroku::Commander.new({ :app => "heroku-commander" }).config }
    context "config" do
      its(:size) { should == 2 }
      it { subject["APP_NAME"].should eq "heroku-commander" }
    end
  end
  context "with logger" do
    subject do
      logger = Logger.new($stdout)
      Heroku::Commander.new({ :logger => logger })
    end
    context "reload!" do
      it "passes the logger" do
        PTY.stub(:spawn)
        subject.logger.should_receive(:debug).with("Running: heroku config -s")
        subject.config
      end
    end
  end
  context "run" do
    it "runs the command" do
      Heroku::Executor.stub(:run).
        and_yield("Running `...` attached to terminal... up, run.xyz").
        and_yield("app").
        and_yield("bin").
        and_yield("rc=0").
        and_return([ "Running `...` attached to terminal... up, run.xyz", "app", "bin", "rc=0" ])
      subject.run("ls -1").should == [ "app", "bin" ]
    end
  end
end
