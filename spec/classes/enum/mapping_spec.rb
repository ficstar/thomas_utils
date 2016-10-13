require 'rspec'

module ThomasUtils
  module Enum
    describe Mapping do

      let(:enum) { (0...10) }
      let(:callback) { ->(item) { item + 1 } }
      let(:result_mapping) { Mapping.new(enum, callback) }
      let(:enum_modifier) { result_mapping }
      let(:enum_modifier_klass) { Mapping }

      subject { result_mapping }

      it { is_expected.to be_a_kind_of(Enumerable) }

      describe '#each' do
        let(:results) { [] }

        describe 'the result' do
          subject { results }

          before { result_mapping.each { |value| results << value } }

          it { is_expected.to eq(enum.map(&callback)) }

          context 'with a different callback' do
            let(:enum) { (10...100) }
            let(:callback) { ->(item) { item - 37 } }

            it { is_expected.to eq(enum.map(&callback)) }
          end
        end

        context 'without a block given' do
          it 'returns itself' do
            expect(result_mapping.each).to eq(result_mapping)
          end
        end
      end

      describe '#get' do
        let(:enum) { Faker::Lorem.words }
        let(:callback) { ->(item) { item + ' world' } }

        subject { result_mapping.get }
        it { is_expected.to eq(result_mapping.to_a) }
      end

      describe 'common modifier behaviour' do
        let(:callback) { ->(item) { item + ' world' } }

        it_behaves_like 'an Enumerable modifier'

        describe '#method_missing' do
          let(:result_enum_modifier) { Mapping.new(enum_two, callback) }

          it_behaves_like '#method_missing for an Enumerable modifier'
        end
      end

    end
  end
end
