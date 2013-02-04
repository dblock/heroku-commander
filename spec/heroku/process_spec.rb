require 'spec_helper'

describe Heroku::Process do
  context "without pid" do
    subject { lambda { Heroku::Process.new } }
    it { should raise_error Heroku::Commander::Errors::MissingPidError, /Missing pid./ }
  end
  context "with pid" do
    subject do
      Heroku::Process.new({ :pid => "run.1234", :status => "idle" })
    end
    its(:pid) { should eq "run.1234" }
    its(:status) { should eq "idle" }
    context "refresh_status!" do
      before do
        Heroku::Executor.stub(:run).with("heroku ps", { :logger => nil }).
          and_yield("run.1234: up for ~ 1m")
        subject.refresh_status!
      end
      its(:status) { should eq "up" }
    end
  end
end

