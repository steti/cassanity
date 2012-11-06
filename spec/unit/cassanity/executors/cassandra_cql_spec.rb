require 'helper'
require 'cassanity/executors/cassandra_cql'

describe Cassanity::Executors::CassandraCql do
  let(:client) { lambda { |args| 'Called' } }

  let(:required_arguments) {
    {
      client: client,
    }
  }

  let(:command_to_argument_generator_map) {
    {
      :foo => lambda { |args| ['mapped', args] },
    }
  }

  subject { described_class.new(required_arguments) }

  describe "#initialize" do
    [:client].each do |key|
      it "raises error without :#{key} key" do
        args = required_arguments.reject { |k, v| k == key }
        expect { described_class.new(args) }.to raise_error(KeyError)
      end
    end

    it "sets client" do
      subject.client.should eq(client)
    end

    it "defaults :command_to_argument_generator_map" do
      subject.command_to_argument_generator_map.should eq(described_class::CommandToArgumentGeneratorMap)
    end

    it "allows overriding :command_to_argument_generator_map" do
      instance = described_class.new(required_arguments.merge({
        command_to_argument_generator_map: command_to_argument_generator_map
      }))

      instance.command_to_argument_generator_map.should eq(command_to_argument_generator_map)
    end
  end

  KnownCommands = [
    :keyspaces,
    :keyspace_create,
    :keyspace_drop,
    :keyspace_use,
    :column_family_create,
    :column_family_drop,
    :column_family_truncate,
    :column_family_insert,
    :column_family_update,
    :column_family_delete,
    :column_family_alter,
    :index_create,
    :index_drop,
  ]

  KnownCommands.each do |key|
    it "responds to #{key} command by default" do
      subject.command_to_argument_generator_map.should have_key(key)
    end
  end

  describe "#call" do
    subject {
      described_class.new(required_arguments.merge({
        command_to_argument_generator_map: command_to_argument_generator_map,
      }))
    }

    context "for known command" do
      it "generates arguments based on command to argument map and passes generated arguments client execute method" do
        args = {
          command: :foo,
          arguments: {
            something: 'else',
          },
        }

        client.should_receive(:execute).with('mapped', args[:arguments])
        subject.call(args)
      end
    end

    context "for unknown command" do
      it "generates arguments based on command to argument map and passes generated arguments client execute method" do
        expect {
          subject.call({
            command: :surprise,
          })
        }.to raise_error(Cassanity::UnknownCommand, 'Original Exception: KeyError: key not found: :surprise')
      end
    end

    context "when client raises exception" do
      it "raises Cassanity::Error" do
        client.should_receive(:execute).and_raise(Exception.new)
        expect {
          subject.call({
            command: :foo,
          })
        }.to raise_error(Cassanity::Error, /Exception: Exception/)
      end
    end
  end
end