# frozen_string_literal: true

require 'spec_helper'

describe Trace2::ArgumentsParser do
  let!(:random_gem) do
    module Trace2
      class RandomGem
      end
    end
  end
  describe '.parse' do
    it 'returns the runner and its arguments as a hash' do
      args = ['random_gem']

      parsed_args = Trace2::ArgumentsParser.parse(args)

      expect(parsed_args[:runner]).to eq Trace2::RandomGem
      expect(parsed_args[:runner_args]).to eq []
      expect(parsed_args[:trace2_args]).to eq({})
    end

    it 'returns the arguments for trace2 and the runner' do
      args = ['-a', 'something', 'random_gem']

      parsed_args = Trace2::ArgumentsParser.parse(args)

      expect(parsed_args[:runner]).to eq Trace2::RandomGem
      expect(parsed_args[:runner_args]).to eq []
      expect(parsed_args[:trace2_args]).to eq('a' => 'something')
    end

    it 'returns all the arguments parsed' do
      args = ['-a', 'something', 'random_gem', '/my/file/', '-f', 'a']

      parsed_args = Trace2::ArgumentsParser.parse(args)

      expect(parsed_args[:runner]).to eq Trace2::RandomGem
      expect(parsed_args[:runner_args]).to eq ['/my/file/', '-f', 'a']
      expect(parsed_args[:trace2_args]).to eq('a' => 'something')
    end
  end
end
