# frozen_string_literal: true

require 'shipdiscount/transaction'

RSpec.describe Shipdiscount::Transaction do
  PackageForTransaction = Struct.new(:size, :price)
  let(:providers) do
    provider = double('Provider')
    allow(provider).to receive(:packages)
      .and_return('S' => PackageForTransaction.new('S', 2.0),
                  'M' => PackageForTransaction.new('M', 4.0))
    providers = double('Providers')
    allow(providers).to receive(:[])
    allow(providers).to receive(:[]).with('MR').and_return(provider)
    providers
  end
  subject do
    # noinspection RubyYardParamTypeMatch
    Shipdiscount::Transaction.new providers
  end
  it 'fills two ordered transactions' do
    expect(subject.next_transaction(%w[2015-02-01 S MR]))
      .to eq([ymd('2015-02-01'), 'S', 'MR', 2.0])
    expect(subject.next_transaction(%w[2015-02-03 M MR]))
      .to eq([ymd('2015-02-03'), 'M', 'MR', 4.0])
  end
  it 'invalidates mis-ordered transactions' do
    expect(subject.next_transaction(%w[2015-02-03 S MR]))
      .to eq([ymd('2015-02-03'), 'S', 'MR', 2.0])
    expect { subject.next_transaction(%w[2015-02-01 M MR]) }
      .to throw_symbol(:invalid_transaction)
  end
  it 'invalidates transaction with wrong date' do
    expect { subject.next_transaction(%w[2015-year S MR]) }
      .to throw_symbol(:invalid_transaction)
  end
  it 'invalidates unrecognized transaction' do
    expect { subject.next_transaction(%w[2015-02-29 CUSPS]) }
      .to throw_symbol(:invalid_transaction)
  end
  it 'invalidates transaction with invalid provider' do
    expect { subject.next_transaction(%w[2015-02-01 S MX]) }
      .to throw_symbol(:invalid_transaction)
  end
  it 'invalidates transaction with invalid package size' do
    expect { subject.next_transaction(%w[2015-02-01 XL MR]) }
      .to throw_symbol(:invalid_transaction)
  end
  it 'invalidates transaction with incorrect number of fields' do
    expect { subject.next_transaction(%w[2015-02-01 S MR 2.0]) }
      .to throw_symbol(:invalid_transaction)
  end
end
