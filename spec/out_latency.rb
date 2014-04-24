# encoding: UTF-8
require_relative 'spec_helper'

describe Fluent::LatencyOutput do
  before { Fluent::Test.setup }
  let(:config) { %[] }
  let(:tag) { 'tag' }
  let(:driver) { Fluent::Test::OutputTestDriver.new(Fluent::LatencyOutput, tag).configure(config) }

  describe 'test configure' do
    subject { driver.instance }

    context "check default" do
      let(:config) { %[] }
      its(:tag) { should == 'latency' }
      its(:interval) { should == 60 }
    end

    context "check config" do
      let(:config) { %[tag tag\ninterval 120]}
      its(:tag) { should == 'tag' }
      its(:interval) { should == 120 }
    end
  end

  describe 'test emit' do
    let(:emit_time) { Time.utc(1,1,1,1,1,2010,nil,nil,nil,nil).to_i }
    let(:current_time) { Time.utc(2,1,1,1,1,2010,nil,nil,nil,nil).to_i }
    let(:message) { "INFO GET /ping" }
    let(:expected) { {"max" => 1.0, "avg" => 1.0, "num" => 1} }
    before {
      Timecop.freeze(Time.at(current_time))
      Fluent::Engine.should_receive(:emit).with("latency", current_time, expected)
    }
    after  { Timecop.return }
    it {
      driver.run { driver.emit({'message' => message}, emit_time) }
      driver.instance.flush_emit
    }
  end
end
