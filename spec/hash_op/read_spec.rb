require 'spec_helper'
require 'hash_op/read'

describe HashOp::Read do

  describe '::values_at_path(hashes, path)' do
    subject { described_class.values_at_path(hashes, path) }

    let(:hashes) do
      [
        {
          a: { b: { c: 1 } }
        },
        {
          a: { b: { c: 2 } }
        },
        {}
      ]
    end
    let(:path) { :'a.b.c' }

    it 'returns an array of the values of each hash at path' do
      expect(subject).to eq([1, 2, nil])
    end
  end
end
