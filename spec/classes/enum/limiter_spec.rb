require 'rspec'

module ThomasUtils
  module Enum
    describe Limiter do

      let(:enum) { (0...10) }
      let(:limit) { 10 }
      let(:result_limiter) { Limiter.new(enum, limit) }
      let(:enum_modifier) { result_limiter }
      let(:enum_modifier_klass) { Limiter }

      subject { result_limiter }

      it { is_expected.to be_a_kind_of(Enumerable) }

      describe '#each' do
        let(:results) { [] }

        describe 'the result' do
          subject { results }

          before { result_limiter.each { |value| results << value } }

          it { is_expected.to eq(enum.to_a) }

          context 'with a different enum' do
            let(:enum) { (10...100) }
            let(:limit) { 90 }

            it { is_expected.to eq(enum.to_a) }
          end

          context 'with a limit less than the enum' do
            let(:limit) { 5 }
            it { is_expected.to eq((0...5).to_a) }
          end

          context 'with a limit greater than the enum' do
            let(:limit) { 15 }
            it { is_expected.to eq(enum.to_a) }
          end
        end

        context 'without a block given' do
          it 'returns itself' do
            expect(result_limiter.each).to eq(result_limiter)
          end
        end
      end

      describe '#get' do
        let(:enum) { Faker::Lorem.words }
        subject { result_limiter.get }
        it { is_expected.to eq(result_limiter.to_a) }
      end

      describe '#==' do
        let(:enum) { Faker::Lorem.words }
        let(:limit) { 15 }
        let(:enum_two) { enum }
        let(:limit_two) { limit }
        let(:result_limiter_two) { Limiter.new(enum_two, limit_two) }

        subject { result_limiter == result_limiter_two }

        it { is_expected.to eq(true) }

        context 'with a different enum' do
          let(:enum_two) { Faker::Lorem.words }
          it { is_expected.to eq(false) }
        end

        context 'with a different limit' do
          let(:limit_two) { 71 }
          it { is_expected.to eq(false) }
        end

        context 'when not a limiter' do
          let(:result_limiter_two) { [] }
          it { is_expected.to eq(false) }
        end
      end

      describe '#respond_to?' do
        let(:enum) { double(:enum) }
        let(:respond_method) { :each }
        let(:include_all) { rand(0..1).nonzero? }

        subject { enum_modifier.respond_to?(respond_method, include_all) }

        it { is_expected.to eq(true) }

        context 'without including everything' do
          subject { enum_modifier.respond_to?(respond_method) }

          it { is_expected.to eq(true) }
        end

        context 'with an unsupported method' do
          let(:respond_method) { Faker::Lorem.word }

          it { is_expected.to eq(false) }

          context 'when the underlying enum supports that method' do
            before { allow(enum).to receive(:respond_to?).with(respond_method, include_all).and_return(true) }

            it { is_expected.to eq(true) }
          end
        end
      end

      describe '#method_missing' do
        let(:limit) { rand(0...enum_two.count) }
        let(:result_enum_modifier) { Limiter.new(enum_two, limit) }

        let(:respond_method) { Faker::Lorem.word.to_sym }
        let(:enum_two) { Faker::Lorem.words }
        let(:enum) { double(:enum) }
        let(:args) { Faker::Lorem.words }
        let(:block) { ->() {} }

        subject { enum_modifier.public_send(respond_method, *args, &block) }

        before do
          allow(enum).to receive(respond_method).with(*args).and_return(enum_two)
        end

        it { is_expected.to be_a_kind_of(enum_modifier_klass) }

        its(:to_a) { is_expected.to eq(result_enum_modifier.to_a) }

        context 'with a block required' do
          let(:some_double) { double(:some_double, call: nil) }
          let(:block) { ->() { some_double.call } }

          before do
            allow(enum).to receive(respond_method).and_yield
          end

          it 'should pass the block' do
            expect(some_double).to receive(:call)
            subject
          end
        end
      end

    end
  end
end
