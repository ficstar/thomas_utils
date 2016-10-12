require 'rspec'

module ThomasUtils
  module Enum
    describe MakeUnique do

      let(:enum) { (0...10) }
      let(:callback) { ->(item) { item } }
      let(:make_unique) { MakeUnique.new(enum, callback) }
      let(:enum_modifier) { make_unique }
      let(:enum_modifier_klass) { MakeUnique }

      subject { make_unique }

      it { is_expected.to be_a_kind_of(Enumerable) }

      describe '#each' do
        let(:results) { [] }

        describe 'the result' do
          subject { results }

          before { make_unique.each { |value| results << value } }

          it { is_expected.to eq(enum.to_a) }

          context 'with a different enum' do
            let(:enum) { (10...100) }
            let(:limit) { 90 }

            it { is_expected.to eq(enum.to_a) }
          end

          context 'when the enum contains duplicates' do
            let(:enum) { [0, 1, 1, 2, 2, 3] }
            it { is_expected.to eq((0..3).to_a) }
          end

          context 'with a different callback' do
            let(:callback) { ->(item) { item < 5 } }
            it { is_expected.to eq([0, 5]) }
          end
        end

        context 'without a block given' do
          it 'returns itself' do
            expect(make_unique.each).to eq(make_unique)
          end
        end
      end

    end
  end
end
