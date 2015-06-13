require 'spec_helper'
require 'hash_op/mapping'

describe HashOp::Mapping do

  describe '::apply_mapping' do

    let(:mapping) do
      {
        int:  { path: :'root.integer' },
        str:  { path: :'root.string' },
        time: { path: :'root.deep_1.deep_2.time', type: :time },
        strings: { path: :'root.array_of_strings' },
        mapped_hash: {
          path: :'root.mapped_hash',
          type: :mapped_hash,
          mapping: {
            str:  { path: :'root.string' },
            time: { path: :'root.time', type: :time }
          }
        },
        parseable_string: {
          path: :'root.parseable_string',
          type: :parseable_string,
          parsing_mapping: {
            value_1: { regexp: 'parseable(.*)&other' },
            value_2: { regexp: '&other(.*)' }
          }
        },
        array_of_mapped_hashes: {
          path: :'root.array_of_mapped_hashes',
          type: :array,
          item_mapping: {
            type: :mapped_hash,
            mapping: {
              str:  { path: :'root.string' },
              time: { path: :'root.deep_1.time', type: :time }
            }
          }
        },
        array_of_parseable_strings: {
          path: :'root.array_of_parseable_strings',
          type: :array,
          item_mapping: {
            type: :parseable_string,
            parsing_mapping: {
              value_1: { regexp: 'value1=([^&]*)' },
              value_2: { regexp: 'value2=([^&]*)' }
            }
          }
        }
      }
    end

    it 'should correctly perform the complete mapping' do
      value = {
        root: {
          integer: rand(100000),
          string: 'some string',
          deep_1: {
            deep_2: {
              time: rand(10).days.ago.to_s
            }
          },
          mapped_hash: {
            root: {
              string: 'mapped hash string',
              time: rand(10).years.from_now.to_s
            }
          },
          array_of_strings: [
            'string_1',
            'string_2'
          ],
          array_of_mapped_hashes: [
            {
              root: {
                string: 'some mapped string 1',
                deep_1: {
                  time: rand(10).seconds.ago.to_s
                }
              }
            },
            {
              root: {
                string: 'some mapped string 2',
                deep_1: {
                  time: rand(10).seconds.ago.to_s
                }
              }
            }
          ],
          parseable_string: 'parseableValue1&otherValue2',
          array_of_parseable_strings: [
            'value1=item1value1&value2=item1value2',
            'value2=item2value2&value1=item2value1'
          ]
        }
      }
      expected_result = {
        int: value[:root][:integer],
        str: value[:root][:string],
        time: Time.parse(value[:root][:deep_1][:deep_2][:time]),
        strings: value[:root][:array_of_strings],
        mapped_hash: {
          str: value[:root][:mapped_hash][:root][:string],
          time: Time.parse(value[:root][:mapped_hash][:root][:time])
        },
        array_of_mapped_hashes: [
          {
            str: value[:root][:array_of_mapped_hashes].first[:root][:string],
            time: Time.parse(value[:root][:array_of_mapped_hashes].first[:root][:deep_1][:time])
          },
          {
            str: value[:root][:array_of_mapped_hashes].last[:root][:string],
            time: Time.parse(value[:root][:array_of_mapped_hashes].last[:root][:deep_1][:time])
          }
        ],
        parseable_string: {
          value_1: 'Value1',
          value_2: 'Value2'
        },
        array_of_parseable_strings: [
          {
            value_1: 'item1value1',
            value_2: 'item1value2'
          },
          {
            value_1: 'item2value1',
            value_2: 'item2value2'
          }
        ]
      }
      result = described_class.apply_mapping(value, mapping)
      expect(result).to include expected_result
    end

    context 'with nil values' do

      before(:all) do
        mapping = {
          str:  { path: :'root.string' },
          time: { path: :'root.time', type: :time },
          array: { path: :'root.array', type: :array }
        }
        value = {
          root: {
            string: nil,
            time: nil,
            array_of_mapped_hashes: nil
          }
        }
        @result = described_class.apply_mapping(value, mapping)
      end

      it 'should include the keys of nil entries' do
        [:str, :time].each do |expected_key|
          expect(@result.keys).to include expected_key
        end
      end

      it 'should map nil to the nil entry' do
        expect(@result[:str]).to eq nil
      end

      it 'should map nil to a converted nil entry' do
        expect(@result[:time]).to eq nil
      end

      it 'should map nil to an empty array' do
        expect(@result[:array]).to eq []
      end
    end

    context 'with missing values' do

      before(:all) do
        mapping = {
          str:  { path: :'root.string' },
          time: { path: :'root.time', type: :time }
        }
        value = {
          root: {}
        }
        @result = described_class.apply_mapping(value, mapping)
      end

      it 'should include the keys of nil entries' do
        [:str, :time].each do |expected_key|
          expect(@result.keys).to include expected_key
        end
      end

      it 'should map nil to the nil entry' do
        expect(@result[:str]).to eq nil
      end

      it 'should map nil to a converted nil entry' do
        expect(@result[:time]).to eq nil
      end
    end
  end

  describe '::process_with_mapping_item' do
    it 'should call the correct method according to mapping\'s type' do
      value = double('value')
      mapping_item = { type: :the_type }
      expect(described_class).to receive(:process_with_mapping_item_the_type).with(value, mapping_item)
      described_class.process_with_mapping_item(value, mapping_item)
    end
  end

  describe '::process_with_mapping_item_raw' do
    it 'should return the raw value' do
      value = double('value')
      result = described_class.process_with_mapping_item_raw(value, {})
      expect(result).to eq value
    end
  end

  describe '::process_with_mapping_item_time' do

    it 'should return the value converted to time' do
      value = Time.now.round(0)
      result = described_class.process_with_mapping_item_time(value.to_s, { type: :time })
      expect(result).to eq value
    end

    it 'should return nil for a string which can\'t be parsed to a time' do
      value = 'not-parseable-as-a-time'
      result = described_class.process_with_mapping_item_time(value, { type: :time })
      expect(result).to be_nil
    end
  end

  describe '::process_with_mapping_item_mapped_hash' do
    it 'should return the mapped hash' do
      value = {
        root: {
          string: 'mapped hash string',
          time: rand(10).years.from_now.to_s
        }
      }

      mapping = {
        path: :'root.mapped_hash',
        type: :mapped_hash,
        mapping: {
          str:  { path: :'root.string' },
          time: { path: :'root.time', type: :time }
        }
      }

      expected_result = {
        str: value[:root][:string],
        time: Time.parse(value[:root][:time])
      }

      result = described_class.process_with_mapping_item_mapped_hash(value, mapping)
      expect(result).to eq expected_result
    end
  end

  describe '::process_with_mapping_item_parseable_string' do

    it 'should return the hash for the parsed string' do
      value = 'parseableValue1&otherValue2'
      mapping = {
        path: 'root.parseable_string',
        type: :parseable_string,
        parsing_mapping: {
          value_1: { regexp: 'parseable(.*)&other' },
          value_2: { regexp: '&other(.*)' }
        }
      }
      result = described_class.process_with_mapping_item_parseable_string(value, mapping)
      expect(result).to eq({
        value_1: 'Value1',
        value_2: 'Value2'
      })
    end

    it 'should perform the conversion on a parsed value' do
      time = Time.now.round(0)
      value = "date=#{time.to_s}&&none"
      mapping = {
        type: :parseable_string,
        parsing_mapping: {
          time: { regexp: 'date=([^&]*)&&', type: :time }
        }
      }
      result = described_class.process_with_mapping_item_parseable_string(value, mapping)
      expect(result).to eq({
        time: time
      })
    end
  end

  describe '::process_with_mapping_item_array' do

    let(:mapping) do
      {
        path: :'root.array_of_mapped_hashes',
        type: :array,
        item_mapping: {
          type: :mapped_hash,
          mapping: {
            str:  { path: :'root.string' },
            time: { path: :'root.deep_1.time', type: :time }
          }
        }
      }
    end

    it 'should return the correct array of mapped hashes' do
      value = [
        {
          root: {
            string: 'some mapped string 1',
            deep_1: {
              time: rand(10).seconds.ago.to_s
            }
          }
        },
        {
          root: {
            string: 'some mapped string 2',
            deep_1: {
              time: rand(10).seconds.ago.to_s
            }
          }
        }
      ]
      result = described_class.process_with_mapping_item_array(value, mapping)
      expect(result).to eq [
        {
          str: value.first[:root][:string],
          time: Time.parse(value.first[:root][:deep_1][:time])
        },
        {
          str: value.last[:root][:string],
          time: Time.parse(value.last[:root][:deep_1][:time])
        }
      ]
    end

    it 'should return an empty array for a nil value' do
      result = described_class.process_with_mapping_item_array(nil, mapping)
      expect(result).to eq []
    end
  end
end
