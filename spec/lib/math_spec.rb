require 'spec_helper'
require 'hash_op/math'

describe HashOp::Math do

  describe '::sum' do

    context '1-level integer-valued hashes' do
      context 'only' do
        it 'should return the correct hash' do
          summed_hashes = [
            {a: 1, b: 2},
            {a: 1, c: 3},
            {b: 2, d: 4}
          ]
          expected_result = {a: 2, b: 4, c:3, d: 4}
          result = described_class.sum(*summed_hashes)
          expect(result).to eq expected_result
        end
      end
      context 'and empty hashes' do
        it 'should return the correct hash' do
          summed_hashes = [
            {a: 1, b: 2},
            {},
            {b: 1, c: 3}
          ]
          expected_result = {a: 1, b: 3, c: 3}
          result = described_class.sum(*summed_hashes)
          expect(result).to eq expected_result
        end
      end
    end
  end

  describe '::sum_two' do
    it 'should sum two 1-level hashes with integer values' do
      expected_result = {a: 2, b: 2, c:3}
      result = described_class.sum_two({a: 1, b: 2}, {a: 1, c: 3})
      expect(result).to eq expected_result
    end
  end

  describe '::sum_on_groups' do

    let(:hashes) do
      [
        { group: :a, value: 1 },
        { group: :b, value: 'a' },
        { group: :c, value: [] },
        { group: :a, value: 1 },
        { group: :b, value: 'b' }
      ]
    end

    it 'should return an Hash with sums on the :group key' do
      result = described_class.sum_on_groups(hashes, :group, :value)
      expect(result).to eq([
        { group: :a, value: 2 },
        { group: :b, value: 'ab' },
        { group: :c, value: [] }
      ])
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
