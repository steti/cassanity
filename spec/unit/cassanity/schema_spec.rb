require 'helper'
require 'cassanity/schema'

describe Cassanity::Schema do
  let(:required_arguments) {
    {
      primary_key: :id,
      columns: {
        id: :text,
        name: :text,
      }
    }
  }

  let(:composite_required_arguments) {
    {
      primary_key: [:bucket, :id],
      columns: {
        bucket: :text,
        id: :text,
        name: :text,
      }
    }
  }

  let(:schema) { described_class.new(required_arguments) }
  let(:composite_schema) { described_class.new(composite_required_arguments) }

  subject { schema }

  describe "#initialize" do
    [:primary_key, :columns].each do |key|
      it "raises error without :#{key} key" do
        args = required_arguments.reject { |k, v| k == key }
        expect { described_class.new(args) }.to raise_error(KeyError)
      end
    end

    it "raises error if primary_keys are not all included in columns" do
      args = required_arguments.merge({
        primary_key: [:foo, :bar],
        columns: {
          id: :text,
        }
      })

      expect {
        described_class.new(args)
      }.to raise_error(ArgumentError, "The following primary keys were not defined as a column: foo, bar")
    end
  end

  describe "#column_names" do
    it "returns array of column names" do
      subject.column_names.should eq([:id, :name])
    end
  end

  describe "#column_types" do
    it "returns array of column types" do
      subject.column_types.should eq([:text, :text])
    end
  end

  describe "#primary_keys" do
    context "with single primary key" do
      subject { schema }

      it "returns array of primary keys" do
        subject.primary_keys.should eq([:id])
      end
    end

    context "with composite primary key" do
      subject { composite_schema }

      it "returns array of primary keys" do
        subject.primary_keys.should eq([:bucket, :id])
      end
    end
  end

  describe "#primary_key" do
    context "with single primary key" do
      subject { schema }

      it "returns array of primary keys" do
        subject.primary_key.should eq([:id])
      end
    end

    context "with composite primary key" do
      subject { composite_schema }

      it "returns array of primary keys" do
        subject.primary_key.should eq([:bucket, :id])
      end
    end
  end

  describe "#composite_primary_key?" do
    context "with single primary key" do
      subject { schema }

      it "returns returns false" do
        subject.composite_primary_key?.should be_false
      end
    end

    context "with composite primary key" do
      subject { composite_schema }

      it "returns true" do
        subject.composite_primary_key?.should be_true
      end
    end
  end
end
