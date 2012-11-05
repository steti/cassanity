require 'helper'
require 'cassanity/connection'

describe Cassanity::Connection do
  let(:keyspace_name) { 'analytics' }
  let(:executor) {
    double('Executor', {
      call: nil,
    })
  }

  let(:required_arguments) {
    {
      executor: executor,
    }
  }

  subject { described_class.new(required_arguments) }

  it { should respond_to(:executor) }

  [:executor].each do |key|
    it "raises error if initialized without :#{key} key" do
      args = required_arguments.reject { |k, v| k == key }
      expect { described_class.new(args) }.to raise_error(KeyError)
    end
  end

  describe "#keyspace" do
    before do
      @return_value = subject.keyspace(keyspace_name)
    end

    it "returns instance of keyspace" do
      @return_value.should be_instance_of(Cassanity::Keyspace)
    end

    context "with args" do
      before do
        @return_value = subject.keyspace(keyspace_name, {
          strategy_class: 'NetworkTopologyStrategy',
        })
      end

      it "passes args to initialization" do
        @return_value.strategy_class.should eq('NetworkTopologyStrategy')
      end

      it "returns instance of keyspace" do
        @return_value.should be_instance_of(Cassanity::Keyspace)
      end
    end
  end

  describe "#[]" do
    before do
      @return_value = subject[keyspace_name]
    end

    it "returns instance of keyspace" do
      @return_value.should be_instance_of(Cassanity::Keyspace)
    end
  end
end
