require 'spec_helper'
require 'hash_op/filter'

describe HashOp::Filter do

  describe '::filter' do

    context '1st-level filtering' do

      let(:source) do
        [
          { a: 1, b: 'ok', result: :in },
          { a: 1, b: 'result: ok', result: :in },
          { a: 2, b: 'ok', result: :out },
          { a: 1, b: 'ko', result: :out }
        ]
      end

      it 'should return the expected hashes' do
        result = described_class.filter(source, a: 1, b: /ok/)
        expect(result).to eq [
          { a: 1, b: 'ok', result: :in },
          { a: 1, b: 'result: ok', result: :in }
        ]
      end
    end

    context 'deep filtering' do

      let(:source) do
        [
          { a: { deep: { value: 1 } }, b: 'ok', result: :in },
          { a: { deep: { value: 1 } }, b: 'result: ok', result: :in },
          { a: { deep: { value: 2 } }, b: 'ok', result: :out },
          { a: { deep: { value: 1 } }, b: 'ko', result: :out }
        ]
      end

      it 'should return the expected hashes' do
        result = described_class.filter(source, :'a.deep.value' => 1, b: /ok/)
        expect(result).to eq [
          { a: { deep: { value: 1 } }, b: 'ok', result: :in },
          { a: { deep: { value: 1 } }, b: 'result: ok', result: :in }
        ]
      end
    end
  end

  describe '::filter_deep' do
    let(:source) do
      { array:
        [
          { a: { deep: { value: 1 } }, b: 'ok', result: :in },
          { a: { deep: { value: 1 } }, b: 'result: ok', result: :in },
          { a: { deep: { value: 2 } }, b: 'ok', result: :out },
          { a: { deep: { value: 1 } }, b: 'ko', result: :out }
        ]
      }
    end

    it 'should filter an array of hashes inside an hash' do
      result = described_class.filter_deep(source, :array, :'a.deep.value' => 1, :b => /ok/)
      expect(result).to eq({
        array: [
          { a: { deep: { value: 1 } }, b: 'ok', result: :in },
          { a: { deep: { value: 1 } }, b: 'result: ok', result: :in }
        ]
      })
    end
  end

  describe '::match?' do

    context '1st-level' do
      let(:hash) { { a: 1, b: 2 } }

      context 'value' do

        it 'should return true when equal' do
          result = described_class.match? hash, a: 1
          expect(result).to eq true
        end

        it 'should return false when not equal' do
          result = described_class.match? hash, a: 2
          expect(result).to eq false
        end
      end

      context 'regexp' do
        let(:hash) { { a: 'test:d12' } }

        it 'should return true if the regexp matches' do
          result = described_class.match? hash, a: /[a-z]\d{2}$/
          expect(result).to eq true
        end

        it 'should return false if the regexp doesn\'t match' do
          result = described_class.match? hash, a: /[A-Z](\d){3}$/
          expect(result).to eq false
        end
      end

      context 'proc' do
        let(:hash) { { a: Time.now } }

        it 'should return true if the proc does' do
          result = described_class.match? hash, a: lambda { |value| value.is_a?(Time) }
          expect(result).to eq true
        end

        it 'should return false if the proc doesn\'t return true' do
          result = described_class.match? hash, a: lambda { |value| value.is_a?(Date) }
          expect(result).to eq false
        end
      end
    end

    context 'deep' do
      let(:hash) { {a: { b: { c: 1} } } }

      it 'should return true for a deep match' do
        result = described_class.match? hash, :'a.b.c' => 1
        expect(result).to eq true
      end

      it 'should return false for a deep non-match' do
        result = described_class.match? hash, :'a.b.c' => 2
        expect(result).to eq false
      end
    end

    context 'specific cases' do

      it 'should raise an error if not passed an Hash' do
        expect {
          described_class.match? 'String', {}
        }.to raise_error(ArgumentError, 'First argument must be an Hash')
      end

      it 'should return true if the criteria is blank' do
        result = described_class.match?({ any: :thing }, {})
        expect(result).to eq(true)
      end
    end
  end
end
