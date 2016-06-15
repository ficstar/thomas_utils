require 'rspec'

module ThomasUtils
  describe InMemoryLogger do

    describe '#write' do
      let(:entry) { Faker::Lorem.words }

      before { subject.write(entry) }

      its(:log) { is_expected.to eq([entry]) }

      context 'with multiple entries' do
        let(:entry_two) { Faker::Lorem.words }

        before { subject.write(entry_two) }

        its(:log) { is_expected.to eq([entry, entry_two]) }
      end
    end

    describe '#clear' do
      before do
        Faker::Lorem.words.each { |entry| subject.write(entry) }
        subject.clear
      end

      its(:log) { is_expected.to be_empty }
    end

  end
end
