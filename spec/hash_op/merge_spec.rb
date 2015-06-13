require 'spec_helper'
require 'hash_op/merge'

describe HashOp::Merge do

  describe '::merge(hashes)' do

    it 'should return the resulting hash of merging all specified hashes' do
      hashes = [
        { a: 1, b: 2},
        { c: 3, d: 4},
        { a: 2, e: 5}
      ]
      result = described_class.merge(hashes)
      expect(result).to eq({
        a: 2,
        b: 2,
        c: 3,
        d: 4,
        e: 5
      })
    end
  end

  describe '::merge_by_group(array, key)' do

    it 'should merge hashes grouped on the specified key' do
      array = [
        { a: 1, b: 2},
        { a: 2, b: 1},
        { a: 1, c: 3},
        { a: 2, b: 2, c: 2}
      ]
      result = described_class.merge_by_group(array, :a)
      expect(result).to eq([
        { a: 1, b: 2, c: 3},
        { a: 2, b: 2, c:2 }
      ])
    end
  end
end
