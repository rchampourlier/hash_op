require 'spec_helper'
require 'hash_op/grouping'

describe HashOp::Grouping do

  let(:hashes) do
    [
      { a: { aa: 'groupA', ag: 1 }, b: :b1, c: :c1 },
      { a: {}, b: :b2, c: :c2 },
      { a: { aa: 'groupA', ag: 1 }, b: :b3 },
      { b: :b4, c: :c4 },
      { a: { aa: 'groupB' }},
      { a: { aa: 'groupB' }, b: :b6 },
      { a: { aa: 'groupC' }},
      { a: { aa: 'groupA', ag: 2 }, b: :b8 },
      { a: { aa: 'groupA', ag: 2 }, b: :b9 },
      { a: { aa: 'groupA', ag: 3 }, b: :b10 }
    ]
  end

  describe '::group_on_path(hashes, path)' do
    subject { described_class.group_on_path(hashes, path) }

    context 'for a deep path' do
      let(:path) { :'a.aa' }

      it 'should return an hash with hashes grouped on the values at the specified path' do
        expected_result = {
          'groupA' => [
            { a: { aa: 'groupA', ag: 1 }, b: :b1, c: :c1 },
            { a: { aa: 'groupA', ag: 1 }, b: :b3 },
            { a: { aa: 'groupA', ag: 2 }, b: :b8 },
            { a: { aa: 'groupA', ag: 2 }, b: :b9 },
            { a: { aa: 'groupA', ag: 3 }, b: :b10 }
          ],
          'groupB' => [
            { a: { aa: 'groupB' }},
            { a: { aa: 'groupB' }, b: :b6 },
          ],
          'groupC' => [
            { a: { aa: 'groupC' }}
          ],
          nil => [
            { a: {}, b: :b2, c: :c2 },
            { b: :b4, c: :c4 },
          ]
        }
        expect(subject).to eq(expected_result)
      end
    end
  end

  describe '::group_on_paths(hashes, paths)' do
    subject { described_class.group_on_paths(hashes, paths) }

    let(:paths) { [:'a.aa', :'a.ag'] }

    it 'should return the expected result' do
      expected_result = {
        'groupA' => {
          1 => [
            { a: { aa: 'groupA', ag: 1 }, b: :b1, c: :c1 },
            { a: { aa: 'groupA', ag: 1 }, b: :b3 },
          ],
          2 => [
            { a: { aa: 'groupA', ag: 2 }, b: :b8 },
            { a: { aa: 'groupA', ag: 2 }, b: :b9 }
          ],
          3 => [
            { a: { aa: 'groupA', ag: 3 }, b: :b10 }
          ]
        },
        'groupB' => {
          nil => [
            { a: { aa: 'groupB' }},
            { a: { aa: 'groupB' }, b: :b6 },
          ]
        },
        'groupC' => {
          nil => [
            { a: { aa: 'groupC' } }
          ],
        },
        nil => {
          nil => [
            { a: {}, b: :b2, c: :c2 },
            { b: :b4, c: :c4 },
          ]
        }
      }
      expect(subject).to eq(expected_result)
    end
  end
end
