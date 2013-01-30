require 'spec_helper'

describe Heroku::Runner do
  context "without a command" do
    it "raises a missing command error" do
      expect {
        Heroku::Runner.new
      }.to raise_error Heroku::Commander::Errors::MissingCommandError, /Missing command./
    end
  end
  context "with a command" do
    subject do
      Heroku::Runner.new({ :command => "ls -1" })
    end
    its(:app) { should be_nil }
    its(:logger) { should be_nil }
    its(:command) { should eq "ls -1" }
    its(:cmdline) { should eq "heroku run \"(ls -1 2>&1 ; echo rc: \\$?)\"" }
    context "run!" do
      it "runs the command" do
        Heroku::Executor.stub(:run).with(subject.send(:cmdline), { :logger => nil }).
          and_yield("Running `...` attached to terminal... up, run.xyz").
          and_yield("app").
          and_yield("bin").
          and_yield("rc: 0").
          and_return([ "Running `...` attached to terminal... up, run.xyz", "app", "bin", "rc: 0" ])
        subject.run!.should == [ "app", "bin" ]
      end
      it "raises an exception if the command fails" do
        Heroku::Executor.stub(:run).with(subject.send(:cmdline), { :logger => nil }).
          and_yield("Running `...` attached to terminal... up, run.xyz").
          and_yield("app").
          and_yield("bin").
          and_yield("rc: 0").
          and_return([ "Running `...` attached to terminal... up, run.xyz", "app", "bin", "rc: 1" ])
        expect {
          subject.run!
        }.to raise_error Heroku::Commander::Errors::CommandError, /The command `ls -1` failed with exit status 1./
      end
    end
  end
end

