require 'rspec'

module ThomasUtils
  module Enum
    describe Filter do

      let(:enum) { [] }
      let(:filter_block) { ->(_) { true } }
      let(:filter) { Filter.new(enum, filter_block) }
      let(:enum_modifier) { filter }
      let(:enum_modifier_klass) { Filter }

      subject { filter }

      it { is_expected.to be_a_kind_of(Enumerable) }

      describe '#each' do
        let(:results) { [] }

        before { filter.each { |value| results << value } }

        describe 'the results' do
          subject { results }

          it { is_expected.to eq([]) }

          context 'with items' do
            let(:enum) { Faker::Lorem.words }

            it { is_expected.to eq(enum) }

            context 'with items yield blocks with higher arity' do
              let(:words) { Faker::Lorem.words }
              let(:enum) { [words] }

              it { is_expected.to eq([words.last]) }
            end

            context 'with a filter' do
              let(:filter_list) { enum.sample(2) }
              let(:filter_block) { ->(value) { !filter_list.include?(value) } }

              it { is_expected.to eq(enum - filter_list) }
            end
          end
        end

        describe 'the enumerator' do
          it 'returns itself' do
            expect(filter.each).to eq(filter)
          end
        end

      end

      describe '#==' do
        let(:enum) { Faker::Lorem.words }
        let(:enum_two) { enum }
        let(:filter_block_two) { filter_block }
        let(:filter_two) { Filter.new(enum_two, filter_block_two) }

        subject { filter == filter_two }

        it { is_expected.to eq(true) }

        context 'with a different enum' do
          let(:enum_two) { Faker::Lorem.words }
          it { is_expected.to eq(false) }
        end

        context 'with a different filter block' do
          let(:filter_two) { ->(_) { false } }
          it { is_expected.to eq(false) }
        end

        context 'when the rhs is not a filter' do
          let(:filter_two) { Faker::Lorem.words }
          it { is_expected.to eq(false) }
        end
      end

      it_behaves_like 'an Enumerable modifier'

      describe '#method_missing' do
        let(:result_enum_modifier) { Filter.new(enum_two, filter_block) }

        it_behaves_like '#method_missing for an Enumerable modifier'
      end

    end
  end
end
