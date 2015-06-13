require 'spec_helper'
require 'hash_op/deep_access'

describe HashOp::DeepAccess do

  describe '::fetch' do

    context 'simple fetch' do

      let(:hash) do
        {
          a: { b: { c: 1 } },
          'a' => { 'b' => { 'c' => 2 } }
        }
      end

      context 'non-matching path' do
        let(:path) { 'b.c.a' }
        subject { described_class.fetch(hash, path) }

        it { should be_nil }
      end

      context 'Symbol key' do
        it 'should fetch the value' do
          result = described_class.fetch(hash, :'a.b.c')
          expect(result).to eq 1
        end
      end

      context 'String key' do
        it 'should fetch the value' do
          result = described_class.fetch(hash, 'a.b.c')
          expect(result).to eq 2
        end
      end
    end

    context 'fetch on array of hashes' do

      let(:hash) do
        {
          a: [
            { b: 1 },
            { b: 2 },
            { b: 3 }
          ]
        }
      end

      it 'should return the array of values' do
        result = described_class.fetch(hash, :'a.b')
        expect(result).to eq [1, 2, 3]
      end
    end
  end

  describe '::merge' do

    it 'should merge the value at the specified path' do
      hash = { a: { b: { c: 1 } } }
      result = described_class.merge hash, :'a.b.c', 2
      expect(result).to eq({ a: { b: { c: 2 } } })
    end

    it 'should merge into hashes within an array' do
      hash = { a: { b: [ { c: 1 }, { c: 2 } ] } }
      result = described_class.merge hash, :'a.b.c', 3
      expect(result).to eq({ a: { b: [ { c: 3 }, { c: 3 } ] } })
    end

    it 'should merge into a new path if it doesn\'t exist' do
      hash = { a: { b: { c: 1 } } }
      result = described_class.merge hash, :'a.b.d', 3
      expect(result).to eq(
        { a: { b: { c: 1, d: 3 } } }
      )
    end

    it 'should handle complex hashes with partial matching' do
      hash = {
        a: [
          { b: { c: 1, d: 2 } },
          { b: { c: 1 } },
          { b: 1 },
          { e: 1 }
        ]
      }
      result = described_class.merge hash, :'a.b.d', 3
      expect(result).to eq({
        a: [
          { b: { c: 1, d: 3 } },
          { b: { c: 1, d: 3 } },
          { b: { d: 3 } },
          { b: { d: 3 }, e: 1 }
        ]
      })
    end

    it 'should replace an array at the specified path' do
      hash = { a: [ { b: 1 }, { b: 2 } ] }
      result = described_class.merge hash, :a, [ :b, :c ]
      expect(result).to eq(
        { a: [ :b, :c ] }
      )
    end
  end

  describe '::build_with_segments' do
    it 'should build an hash with a value at the specified path' do
      result = described_class.build_with_segments([:a, :b, :c], :value)
      expect(result[:a][:b][:c]).to eq(:value)
    end
  end
end