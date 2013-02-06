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
    its(:cmdline) { should eq "heroku run \"(ls -1 2>&1 ; echo rc=\\$?)\"" }
    its(:running?) { should be_false }
    context "check_pid" do
      it "parses up, run.1234" do
        subject.send(:check_pid, "up, run.1234")
        subject.pid.should == "run.1234"
      end
      it "parses attached to terminal ... up, run.1234" do
        subject.send(:check_pid, "parses attached to terminal ... up, run.1234")
        subject.pid.should == "run.1234"
      end
      it "parses detached ... up, run.1234" do
        subject.send(:check_pid, "detached ... up, run.1234")
        subject.pid.should == "run.1234"
      end
    end
    context "run!" do
      before :each do
        Heroku::Executor.stub(:run).with(subject.send(:cmdline), { :logger => nil }).
          and_yield("Running `...`").
          and_yield("attached to terminal... up, run.9783").
          and_yield("app").
          and_yield("bin").
          and_yield("rc= 0").
          and_return([ "Running `...`", "attached to terminal... up, run.9783", "app", "bin", "rc=0" ])
      end
      it "runs the command w/o a block" do
        subject.run!.should == [ "app", "bin" ]
        subject.pid.should == "run.9783"
        subject.should_not be_running
      end
      it "runs the command with a block" do
        lines = []
        subject.run!.each do |line|
          lines << line
        end
        lines.should == [ "app", "bin" ]
        subject.pid.should == "run.9783"
        subject.should_not be_running
      end
      it "raises an exception if the command fails" do
        Heroku::Executor.stub(:run).with(subject.send(:cmdline), { :logger => nil }).
          and_return([ "Running `...` attached to terminal... up, run.9783", "app", "bin", "rc=1" ])
        expect {
          subject.run!
        }.to raise_error Heroku::Commander::Errors::CommandError, /The command `ls -1` failed with exit status 1./
      end
    end
    context "run! detached" do
      before :each do
        Heroku::Executor.stub(:run).with(subject.send(:cmdline, { :detached => true }), { :logger => nil }).
          and_yield("Running `ls -1` detached... up, run.8748").
          and_yield("Use `heroku logs -p run.8748` to view the output.").
          and_yield("rc=0").
          and_return([ "Running `ls -1` detached... up, run.8748", "Use `heroku logs -p run.8748` to view the output.", "rc=0" ])
        Heroku::Executor.stub(:run).with("heroku logs -p run.8748 --tail", { :logger => nil }).
          and_yield("2013-01-31T01:39:30+00:00 heroku[run.8748]: Starting process with command `ls -1`").
          and_yield("2013-01-31T01:39:31+00:00 app[run.8748]: bin").
          and_yield("2013-01-31T01:39:31+00:00 app[run.8748]: app").
          and_yield(nil).
          and_yield("2013-01-31T00:56:13+00:00 app[run.8748]: rc=0").
          and_yield("2013-01-31T01:39:33+00:00 heroku[run.8748]: Process exited with status 0").
          and_yield("2013-01-31T01:39:33+00:00 heroku[run.8748]: State changed from up to complete").
          and_return([
            "2013-01-31T01:39:30+00:00 heroku[run.8748]: Starting process with command `ls -1`",
            "2013-01-31T01:39:31+00:00 app[run.8748]: bin",
            "2013-01-31T01:39:31+00:00 app[run.8748]: app",
            "2013-01-31T00:56:13+00:00 app[run.8748]: rc=0",
            "2013-01-31T01:39:33+00:00 heroku[run.8748]: Process exited with status 0",
            "2013-01-31T01:39:33+00:00 heroku[run.8748]: State changed from up to complete"
          ])
        Heroku::Runner.any_instance.should_receive(:terminate_executor!).twice
      end
      it "runs the command w/o a block" do
        subject.run!({ :detached => true }).should == [ "bin", "app", "" ]
        subject.pid.should == "run.8748"
        subject.should_not be_running
      end
      it "runs the command with a block" do
        lines = []
        subject.run!({ :detached => true }).each do |line|
          lines << line
        end
        lines.should == [ "bin", "app", "" ]
        subject.pid.should == "run.8748"
        subject.should_not be_running
      end
    end
  end
end

