require 'spec_helper'

RSpec.describe Frontkick::Command do
  describe '.exec' do
    describe 'timeout option' do
      subject { described_class.exec('sleep 2 && ls /hoge', timeout: 1) }
      it { expect { subject }.to raise_error Frontkick::Timeout }
    end
  end
end
