require 'rspec'

module ThomasUtils
  module Enum
    describe Combiner do

      let(:enum) { [] }
      let(:enum_two) { [] }
      let(:combiner) { Combiner.new(enum, enum_two) }
      let(:enum_modifier) { combiner }
      let(:enum_modifier_klass) { Combiner }

      subject { combiner }

      it { is_expected.to be_a_kind_of(Enumerable) }

      describe '#each' do
        let(:results) { [] }

        describe 'the results' do
          before { combiner.each { |value| results << value } }

          subject { results }

          it { is_expected.to eq([]) }

          context 'when the first one has results' do
            let(:enum) { Faker::Lorem.words }
            it { is_expected.to eq(enum) }

            context 'when the second one has results' do
              let(:enum_two) { Faker::Lorem.words }
              it { is_expected.to eq(enum + enum_two) }
            end
          end
        end

        describe 'the enumerator' do
          it 'returns itself' do
            expect(combiner.each).to eq(combiner)
          end
        end

      end

      describe '#==' do
        let(:enum) { Faker::Lorem.words }
        let(:enum_two) { Faker::Lorem.words }
        let(:other_enum) { enum }
        let(:other_enum_two) { enum_two }
        let(:other_combiner) { Combiner.new(other_enum, other_enum_two) }

        subject { combiner == other_combiner }

        context 'when the combiners have the same enums' do
          it { is_expected.to eq(true) }

          context 'when the first one is different' do
            let(:other_enum) { Faker::Lorem.words }
            it { is_expected.to eq(false) }
          end

          context 'when the second one is different' do
            let(:other_enum_two) { Faker::Lorem.words }
            it { is_expected.to eq(false) }
          end
        end

        context 'when the second combiner is of the wrong type' do
          let(:other_combiner) { Limiter.new(enum, 5) }
          it { is_expected.to eq(false) }
        end
      end

      describe 'delegation' do
        let(:enum_two) { double(:enum, each: nil) }
        let(:responds) { true }
        let(:respond_method) { :some_method }
        let(:include_all) { true }

        before do
          allow(enum_two).to receive(:respond_to?).with(respond_method, include_all).and_return(responds)
        end

        it_behaves_like 'an Enumerable modifier'

        context 'when the enums are reversed' do
          let(:combiner) { Combiner.new(enum_two, enum) }

          it_behaves_like 'an Enumerable modifier'

          context 'when that enum does not respond to the same method' do
            let(:responds) { false }

            describe '#respond_to?' do
              subject { enum_modifier.respond_to?(respond_method, include_all) }
              before { allow(enum).to receive(:respond_to?).and_return(true) }

              it { is_expected.to eq(false) }
            end
          end
        end
      end

      describe '#method_missing' do
        let(:other_enum) { double(:enum, respond_method => []) }
        let(:combiner) { Combiner.new(enum, other_enum) }
        let(:result_enum_modifier) { Combiner.new(enum_two, []) }

        it_behaves_like '#method_missing for an Enumerable modifier'

        context 'when the enums are reversed' do
          let(:combiner) { Combiner.new(other_enum, enum) }
          let(:result_enum_modifier) { Combiner.new([], enum_two) }

          it_behaves_like '#method_missing for an Enumerable modifier'
        end
      end

    end
  end
end
