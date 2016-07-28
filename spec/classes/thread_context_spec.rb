require 'rspec'

module ThomasUtils
  describe ThreadContext do

    before { Thread.current[:__tutils_thread_context] = nil }

    subject { ThreadContext.new(Thread.current) }

    it { is_expected.to be_a_kind_of(Hash) }

    describe '.current' do
      subject { ThreadContext.current }

      it { is_expected.to be_a_kind_of(ThreadContext) }

      it 'should not share contexts between threads' do
        context_two = Thread.new { ThreadContext.current }.value
        expect(context_two.object_id).not_to eq(subject)
      end

      context 'when previously initialized' do
        before { ThreadContext.current[:hello] = :world }

        it { is_expected.to eq(hello: :world) }
      end
    end

    describe '#push_state' do
      let(:expected_result) { Faker::Lorem.sentence }
      let(:new_state) { Faker::Lorem.words.inject({}) { |memo, key| memo.merge!(key => Faker::Lorem.sentence) } }
      let(:clear_state) { new_state.inject({}) { |memo, (key, _)| memo.merge!(key => nil) } }

      it 'overrides the current state within the block provided' do
        state = subject.push_state(new_state) { subject.dup }
        expect(state).to eq(new_state)
      end

      it 'resets the values of the state on completion' do
        subject.push_state(new_state) {}
        expect(subject).to eq(clear_state)
      end

      it 'returns the result of the block' do
        result = subject.push_state(new_state) { expected_result }
        expect(result).to eq(expected_result)
      end

      describe 'recursive state changes' do
        let(:new_state_two) { Faker::Lorem.words.inject({}) { |memo, key| memo.merge!(key => Faker::Lorem.sentence) } }
        let(:clear_state) { new_state_two.inject({}) { |memo, (key, _)| memo.merge!(key => nil) }.merge(new_state) }

        it 'overrides the current state within the block provided' do
          state = subject.push_state(new_state) do
            subject.push_state(new_state_two) do
              subject.dup
            end
          end
          expect(state).to eq(new_state.merge(new_state_two))
        end

        it 'resets the values of the state on completion' do
          subject.push_state(new_state) do
            subject.push_state(new_state_two) {}
            expect(subject).to eq(clear_state)
          end
        end
      end

      context 'with no new attributes provided' do
        it 'does not perform any unnecessary merges' do
          expect_any_instance_of(Hash).not_to receive(:merge!)
          subject.push_state({}) {}
        end

        it 'returns the result of the block' do
          result = subject.push_state({}) { expected_result }
          expect(result).to eq(expected_result)
        end
      end
    end

    describe '#id' do
      let(:thread_id) { Thread.current.object_id.to_s(16) }
      let(:expected_id) { "0x#{thread_id}" }

      subject { ThreadContext.current }

      its(:id) { is_expected.to eq(expected_id) }

      context 'when called from a different thread' do
        it 'should use the proper thread id' do
          expected_id = nil
          context = Thread.new do
            thread_id = Thread.current.object_id.to_s(16)
            expected_id = "0x#{thread_id}"
            ThreadContext.current
          end.value
          expect(context.id).to eq(expected_id)
        end
      end
    end

  end
end
