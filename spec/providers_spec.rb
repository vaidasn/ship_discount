# frozen_string_literal: true

require 'ship_discount/providers'

RSpec.describe ShipDiscount::Providers do
  context 'when each invoked' do
    it 'requires a block' do
      expect { subject.each }.to raise_error(LocalJumpError)
    end
    it 'every item is Provider' do
      subject.each { |p| expect(p).to be_a(ShipDiscount::Providers::Provider) }
    end
    it 'every provider contains at least one Package' do
      subject.each do |p|
        expect(p.packages).not_to eq({})
        p.packages.each do |_size, package|
          expect(package).to be_a(ShipDiscount::Providers::Package)
          expect(package.size).to be_a(String)
          expect(package.price).to be > 0.0
        end
      end
    end
  end
  context 'when provider is get' do
    it 'returns provider by name' do
      expect(subject['LP']).to be_a(ShipDiscount::Providers::Provider)
      expect(subject['LP'].name).to eq('LP')
    end
    it 'returns nil for unknown provider' do
      expect(subject['unknown']).to be_nil
    end
  end
end
