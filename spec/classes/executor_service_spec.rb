require 'rspec'

module Concurrent
  describe ExecutorService do

    let(:executor_class) do
      Class.new do
        include ExecutorService

        attr_reader :tasks

        def initialize
          @tasks = []
        end

        def post(*args, &block)
          @tasks << [*args, block.call]
        end
      end
    end

    subject { executor_class.new }

    describe '#execute' do
      let(:args) { Faker::Lorem.words }
      let(:result) { Faker::Lorem.word }
      let(:block) { ->() { result } }

      it 'should delegate to post' do
        subject.execute(*args, &block)
        expect(subject.tasks.first).to eq([*args, result])
      end
    end

  end
end
