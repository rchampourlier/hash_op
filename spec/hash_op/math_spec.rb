require 'spec_helper'
require 'hash_op/math'

describe HashOp::Math do

  describe '::sum_on_groups' do

    let(:hashes) do
      [
        { group_1: :a, group_2: :a, value_1: 1, value_2: 1 },
        { group_1: :a, group_2: :b, value_1: 1, value_2: 2 },
        { group_1: :a, group_2: :b, value_1: 1, value_2: 2 },
        { group_1: :b, group_2: :c, value_1: 1, value_2: 3 }
      ]
    end
    let(:value_paths) { [:value_1, :value_2] }
    subject { described_class.sum_on_groups(hashes, grouping_paths, value_paths) }

    context 'single-level grouping paths' do
      let(:grouping_paths) { [:group_1] }
      it 'returns hashes with sums on the specified values for each group' do
        expect(subject).to eq([
          { group_1: :a, value_1: 3, value_2: 5 },
          { group_1: :b, value_1: 1, value_2: 3 }
        ])
      end
    end

    context '2-level grouping paths' do
      let(:grouping_paths) { [:group_1, :group_2] }
      it 'returns hashes with sums on the specified values for each group' do
        expect(subject).to eq([
          { group_1: :a, group_2: :a, value_1: 1, value_2: 1 },
          { group_1: :a, group_2: :b, value_1: 2, value_2: 4 },
          { group_1: :b, group_2: :c, value_1: 1, value_2: 3 }
        ])
      end
    end
  end

  describe '::sum_at_path(hashes, path, zero = 0)' do

    it 'should sum integer values' do
      hashes = [
        { a: { b: 1 } },
        { a: { b: 2 } }
      ]
      result = described_class.sum_at_path hashes, :'a.b'
      expect(result).to eq 3
    end

    it 'should coerce nil to zero' do
      hashes = [
        { a: { b: 1 } },
        { a: { b: 2 } },
        { a: { b: nil } }
      ]
      result = described_class.sum_at_path hashes, :'a.b'
      expect(result).to eq 3
    end
  end

  describe '::deep_min' do

    let(:hashes) do
      [
        { a: { b: { c: 1} } },
        { a: { b: { c: 2} } }
      ]
    end

    it 'should return the min at the specified path' do
      expect(described_class.deep_min(hashes, :'a.b.c')).to eq 1
    end
  end

  describe '::deep_max' do

    let(:hashes) do
      [
        { a: { b: { c: 1} } },
        { a: { b: { c: 2} } }
      ]
    end

    it 'should return the max at the specified path' do
      expect(described_class.deep_max(hashes, :'a.b.c')).to eq 2
    end
  end
end
