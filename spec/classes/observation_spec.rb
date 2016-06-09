require 'rspec'

module ThomasUtils
  describe Observation do

    let(:complete_mock_observation_klass) do
      Struct.new(:value, :error) do
        def on_complete
          yield value, error
          self
        end

        def then
          yield value unless error
        end
      end
    end
    let(:then_only_mock_observation_klass) do
      Struct.new(:value, :error) do
        def then
          yield value unless error
        end
      end
    end
    let(:complete_only_mock_observation_klass) do
      Struct.new(:value, :error) do
        def on_complete
          yield value, error
          self
        end
      end
    end

    let(:value) { Faker::Lorem.word }
    let(:error) { nil }
    let(:executor) { Concurrent::ImmediateExecutor.new }
    let(:observable) { Concurrent::IVar.new }
    let(:observation) { Observation.new(executor, observable) }

    before do
      if error
        observable.fail(error)
      elsif value
        observable.set(value)
      end
    end

    describe '#initialized_at' do
      subject { observation.initialized_at }

      around { |example| Timecop.freeze { example.run } }

      it { is_expected.to eq(Time.now) }

      context 'with a specific initialization time provided' do
        let(:minutes_ago) { rand(1..10) }
        let(:initialized_at) { Time.now - minutes_ago * 60 }
        let(:observation) { Observation.new(executor, observable, initialized_at) }

        it { is_expected.to eq(initialized_at) }
      end
    end

    describe '#resolved_at' do
      let(:observable) { double(:observable, set: nil, add_observer: nil) }

      subject { observation.resolved_at }

      it { is_expected.to be_nil }

      context 'when the observable has been resolved' do
        let(:resolved_at) { Time.now }

        before do
          allow(observable).to receive(:add_observer) do |&block|
            block[resolved_at, nil, nil]
          end
        end

        it { is_expected.to eq(resolved_at) }
      end
    end

    describe '#on_success' do
      let(:result) { [] }
      let(:block) { ->(value) { result << value } }

      subject { observation.on_success(&block) }

      it { is_expected.to eq(observation) }

      it 'should call the block' do
        subject
        expect(result).to eq([value])
      end

      context 'when the observation has failed' do
        let(:error) { StandardError.new }

        it 'should not call the block' do
          subject
          expect(result).to be_empty
        end
      end

      context 'when the value is not immediately ready' do
        let(:value) { nil }
        let(:eventual_value) { Faker::Lorem.word }

        before do
          subject
          observable.set(eventual_value)
        end

        it 'should call the block when complete' do
          expect(result).to eq([eventual_value])
        end
      end
    end

    describe '#on_failure' do
      let(:error) { StandardError.new(Faker::Lorem.word) }
      let(:result) { [] }
      let(:block) { ->(error) { result << error } }

      subject { observation.on_failure(&block) }

      it { is_expected.to eq(observation) }

      it 'should call the block' do
        subject
        expect(result).to eq([error])
      end

      context 'when the observation was successful' do
        let(:error) { nil }

        it 'should not call the block' do
          subject
          expect(result).to be_empty
        end
      end

      context 'when the value is not immediately ready' do
        let(:value) { nil }
        let(:error) { nil }
        let(:eventual_error) { StandardError.new(Faker::Lorem.word) }

        before do
          subject
          observable.fail(eventual_error)
        end

        it 'should call the block when complete' do
          expect(result).to eq([eventual_error])
        end
      end
    end

    describe '#on_timed' do
      let(:initialized_at) { Time.now }
      let(:time_to_resolve) { rand(1..10) * 60 }
      let(:resolved_at) { initialized_at + time_to_resolve }
      let(:result_klass) { Struct.new(:initialized_at, :resolved_at, :duration) }
      let(:result) { result_klass.new }

      subject { result }

      before do
        allow(Time).to receive(:now).and_return(initialized_at, resolved_at)
        observation.on_timed do |initialized_at, resolved_at, duration|
          result.initialized_at = initialized_at
          result.resolved_at = resolved_at
          result.duration = duration
        end
      end

      its(:initialized_at) { is_expected.to eq(initialized_at) }
      its(:resolved_at) { is_expected.to eq(resolved_at) }
      its(:duration) { is_expected.to eq(time_to_resolve) }
    end

    describe '#on_complete' do
      let(:result_list) { [] }
      let(:result) { result_list.first }
      let(:block) { ->(value, error) { result_list << [value, error] } }

      subject { observation.on_complete(&block) }

      it { is_expected.to eq(observation) }

      it 'should call the block with the value an NO error' do
        subject
        expect(result).to eq([value, nil])
      end

      context 'when the observation has failed' do
        let(:error) { StandardError.new }

        it 'should call the block with NO value and the error' do
          subject
          expect(result).to eq([nil, error])
        end
      end

      context 'when the value is not immediately ready' do
        let(:value) { nil }
        let(:error) { nil }
        let(:eventual_value) { Faker::Lorem.word }

        before do
          subject
          observable.set(eventual_value)
        end

        it 'should call the block when complete' do
          expect(result).to eq([eventual_value, nil])
        end
      end
    end

    describe '#get' do
      subject { observation.get }

      it { is_expected.to eq(value) }

      context 'when the observation has failed' do
        let(:error) { StandardError.new(Faker::Lorem.word) }

        it 'should raise the error' do
          expect { subject }.to raise_error(error)
        end

      end
    end

    describe '#join' do
      subject { observation.join }

      it { is_expected.to eq(observation) }

      it 'should force the observation to complete' do
        expect(observable).to receive(:value).at_least(1).times
        subject
      end
    end

    describe '#then' do
      let(:salt) { Faker::Lorem.word }
      let(:value_modifier) { ->(value) { Digest::MD5.base64digest(value + salt) } }
      let(:expected_result) { value_modifier.call(value) }
      let(:block) { ->(value) { value_modifier.call(value) } }

      subject { observation.then(&block) }

      it { is_expected.to be_a_kind_of(Observation) }

      its(:get) { is_expected.to eq(expected_result) }

      context 'when the observation has failed' do
        let(:error) { StandardError.new(Faker::Lorem.word) }

        it 'should raise the error when resolved' do
          expect { subject.get }.to raise_error(error)
        end
      end

      context 'when the block raises an error' do
        let(:block_error) { StandardError.new(Faker::Lorem.word) }
        let(:block) { ->(_) { raise block_error } }

        # an immediate executor would have caused this test to pass immediately,
        # where as an asynchronous one causes a deadlock
        let(:executor) { Concurrent::CachedThreadPool.new }

        it 'should raise the error when resolved' do
          expect { subject.get }.to raise_error(block_error)
        end

        context 'when it is not a StandardError' do
          let(:block_error) { Interrupt.new }

          it 'should raise the error when resolved' do
            expect { subject.get }.to raise_error(block_error)
          end
        end
      end

      context 'when the block returns an Observation' do
        let(:value_two) { Faker::Lorem.word }
        let(:error_two) { nil }
        let(:observable_two) { Concurrent::IVar.new }
        let(:block) do
          ->(value) do
            Observation.new(executor, observable_two).then do
              value_modifier.call(value)
            end
          end
        end

        before do
          if error_two
            observable_two.fail(error_two)
          elsif value_two
            observable_two.set(value_two)
          end
        end

        its(:get) { is_expected.to eq(expected_result) }

        context 'with a return value responding to the successive interface' do
          let(:mock_observation_klass) { complete_mock_observation_klass }
          let(:mock_observation) { mock_observation_klass.new(value_modifier.call(value), error) }
          let(:block) { ->(_) { mock_observation } }

          its(:get) { is_expected.to eq(expected_result) }

          context 'when missing #on_complete' do
            let(:mock_observation_klass) { then_only_mock_observation_klass }
            its(:get) { is_expected.to eq(mock_observation) }
          end

          context 'when missing #then' do
            let(:mock_observation_klass) { complete_only_mock_observation_klass }
            its(:get) { is_expected.to eq(mock_observation) }
          end
        end

        context 'when the child observation fails' do
          let(:error_two) { StandardError.new(Faker::Lorem.word) }

          it 'should raise the error when resolved' do
            expect { subject.get }.to raise_error(error_two)
          end
        end
      end
    end

    describe '#fallback' do
      let(:error_msg) { Faker::Lorem.sentence }
      let(:error) { StandardError.new(error_msg) }
      let(:error_modifier) { ->(error) { error.message } }
      let(:block) { ->(error) { error_modifier.call(error) } }

      subject { observation.fallback(&block) }

      it { is_expected.to be_a_kind_of(Observation) }
      its(:get) { is_expected.to eq(error_msg) }

      context 'when the observation has succeeded' do
        let(:error) { nil }

        it 'should raise the error when resolved' do
          expect(subject.get).to eq(value)
        end
      end

      context 'when the block raises an error' do
        let(:block_error) { StandardError.new(Faker::Lorem.word) }
        let(:block) { ->(_) { raise block_error } }

        # see #then
        let(:executor) { Concurrent::CachedThreadPool.new }

        it 'should raise the error when resolved' do
          expect { subject.get }.to raise_error(block_error)
        end
      end

      context 'when the block returns an Observation' do
        let(:value_two) { Faker::Lorem.word }
        let(:error_two) { nil }
        let(:observable_two) { Concurrent::IVar.new }
        let(:block) do
          ->(error) do
            Observation.new(executor, observable_two).then do
              error_modifier.call(error)
            end
          end
        end

        before do
          if error_two
            observable_two.fail(error_two)
          elsif value_two
            observable_two.set(value_two)
          end
        end

        its(:get) { is_expected.to eq(error_msg) }

        context 'when the child observation fails' do
          let(:error_two) { StandardError.new(Faker::Lorem.word) }

          it 'should raise the error when resolved' do
            expect { subject.get }.to raise_error(error_two)
          end
        end
      end
    end

    describe '#none_fallback' do
      let(:fallback) { SecureRandom.uuid }
      let(:block) { ->() { fallback } }

      subject { observation.none_fallback(&block) }

      it { is_expected.to be_a_kind_of(Observation) }
      its(:get) { is_expected.to eq(value) }

      context 'when the value is nil' do
        let(:value) { nil }

        before { observable.set(nil) }

        its(:get) { is_expected.to eq(fallback) }
      end
    end

    describe '#ensure' do
      let!(:ensure_observer) { double(:observer, call: nil) }
      let(:block) { ->(value, error) { ensure_observer.call(value, error) } }

      subject { observation.ensure(&block) }

      it { is_expected.to be_a_kind_of(Observation) }
      its(:get) { is_expected.to eq(value) }

      it 'should call the provided block with the value' do
        expect(ensure_observer).to receive(:call).with(value, nil)
        subject
      end

      context 'when the observation has failed' do
        let(:error) { StandardError.new(Faker::Lorem.sentence) }

        it { expect { subject.get }.to raise_error(error) }

        it 'should call the provided block with the error' do
          expect(ensure_observer).to receive(:call).with(nil, error)
          subject
        end
      end

      context 'when the block has not completed' do
        let!(:observable_two) { Concurrent::IVar.new.set(nil) }
        let(:block) do
          ->(value, error) do
            Observation.new(executor, observable_two).then do
              sleep 0.01
              ensure_observer.call(value, error)
            end
          end
        end

        # see #then
        let(:executor) { Concurrent::CachedThreadPool.new }

        its(:get) { is_expected.to eq(value) }

        it 'should wait for the block to complete' do
          expect(ensure_observer).to receive(:call)
          subject.get
        end
      end

      context 'when the block raises an error' do
        let(:block_error) { StandardError.new(Faker::Lorem.word) }
        let(:block) { ->(_, _) { raise block_error } }

        # see #then
        let(:executor) { Concurrent::CachedThreadPool.new }

        it 'should raise the error when resolved' do
          expect { subject.get }.to raise_error(block_error)
        end

        context 'when it is not a StandardError' do
          let(:block_error) { Interrupt.new }

          it 'should raise the error when resolved' do
            expect { subject.get }.to raise_error(block_error)
          end
        end
      end

      context 'when the block returns an Observation' do
        let(:value_two) { Faker::Lorem.word }
        let(:error_two) { nil }
        let(:observable_two) { Concurrent::IVar.new }
        let(:block) do
          ->(value, error) do
            Observation.new(executor, observable_two).then do
              ensure_observer.call(value, error)
            end
          end
        end

        before do
          if error_two
            observable_two.fail(error_two)
          elsif value_two
            observable_two.set(value_two)
          end
        end

        it 'should call the provided block with the value' do
          expect(ensure_observer).to receive(:call).with(value, nil)
          subject
        end

        context 'when the child observation fails' do
          let(:error_two) { StandardError.new(Faker::Lorem.word) }

          it 'should raise the error when resolved' do
            expect { subject.get }.to raise_error(error_two)
          end
        end
      end
    end

    describe '#on_success_ensure' do
      let!(:callback) { double(:callback, call: nil) }
      let(:block) { ->(value) { callback.call(value) } }

      subject { observation.on_success_ensure(&block) }

      it { is_expected.to be_a_kind_of(Observation) }
      its(:get) { is_expected.to eq(value) }
      it { is_expected.not_to eq(observation) }

      it 'should ensure the callback gets called' do
        expect(callback).to receive(:call).with(value)
        subject.get
      end

      context 'when the block itself returns an Observation' do
        let(:value_two) { Faker::Lorem.words }
        let!(:observable_two) { Concurrent::IVar.new.set(value_two) }
        let(:block) do
          ->(value) do
            Observation.new(executor, observable_two).then do
              sleep 0.01
              callback.call(value)
            end
          end
        end

        # see #then
        let(:executor) { Concurrent::CachedThreadPool.new }

        its(:get) { is_expected.to eq(value) }

        it 'should ensure the callback gets called before resolving' do
          expect(callback).to receive(:call).with(value)
          subject.get
        end
      end

      context 'with an error' do
        let(:error) { StandardError.new(Faker::Lorem.sentence) }

        it { expect { subject.get }.to raise_error(error) }

        it 'should not call the callback' do
          expect(callback).not_to receive(:call)
          subject.get rescue nil
        end
      end
    end

    describe '#on_failure_ensure' do
      let(:error) { StandardError.new(Faker::Lorem.sentence) }
      let!(:callback) { double(:callback, call: nil) }
      let(:block) { ->(error) { callback.call(error) } }

      subject { observation.on_failure_ensure(&block) }

      it { is_expected.to be_a_kind_of(Observation) }
      it { expect { subject.get }.to raise_error(error) }
      it { is_expected.not_to eq(observation) }

      it 'should ensure the callback gets called' do
        expect(callback).to receive(:call).with(error)
        subject.get rescue nil
      end

      context 'when the block itself returns an Observation' do
        let(:value_two) { Faker::Lorem.words }
        let!(:observable_two) { Concurrent::IVar.new.set(value_two) }
        let(:block) do
          ->(error) do
            Observation.new(executor, observable_two).then do
              sleep 0.01
              callback.call(error)
            end
          end
        end

        # see #then
        let(:executor) { Concurrent::CachedThreadPool.new }

        it { expect { subject.get }.to raise_error(error) }

        it 'should ensure the callback gets called before resolving' do
          expect(callback).to receive(:call).with(error)
          subject.get rescue nil
        end
      end

      context 'with no error' do
        let(:error) { nil }

        its(:get) { is_expected.to eq(value) }

        it 'should not call the callback' do
          expect(callback).not_to receive(:call)
          subject.get
        end
      end
    end

  end
end
