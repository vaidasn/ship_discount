# frozen_string_literal: true

require 'shipdiscount/data_file'
require 'tempfile'

RSpec.describe Shipdiscount::DataFile do
  temp_file1 = nil

  before do
    temp_file1 = Tempfile.new
    temp_file1.puts 'line one'
    temp_file1.puts 'second line'
    temp_file1.close
  end

  after do
    temp_file1&.unlink
  end

  let(:mocked_three_record_file) do
    file_double = double('File')
    expect(file_double).to receive(:each_line).with("\n") do |&block|
      block.call(" this is\tline one")
      block.call('and this is two  ')
      block.call(' line_three  ')
    end
    allow(File).to receive(:new)
      .with('test_data.txt', 'r').and_return(file_double)
  end

  let(:mocked_empty_file) do
    file_double = double('File')
    expect(file_double).to receive(:each_line).with("\n")
    allow(File).to receive(:new)
      .with('test_data.txt', 'r').and_return(file_double)
  end

  context 'when each_record invoked' do
    it 'iterates over three record mocked file' do
      mocked_three_record_file
      records = []
      Shipdiscount::DataFile.each_record('test_data.txt') do |fields|
        records << fields
      end
      expect(records).to eq([%w[this is line one],
                             %w[and this is two],
                             ['line_three']])
    end
    it 'done not iterate over empty mocked file' do
      mocked_empty_file
      Shipdiscount::DataFile.each_record('test_data.txt')
    end
    it 'iterates over temp file' do
      records = []
      Shipdiscount::DataFile.each_record(temp_file1&.to_path) do |fields|
        records << fields
      end
      expect(records).to eq([%w[line one], %w[second line]])
    end
  end

  context 'when read invoked' do
    it 'reads three record mocked file' do
      mocked_three_record_file
      records = Shipdiscount::DataFile.read('test_data.txt')
      expect(records).to eq([%w[this is line one],
                             %w[and this is two],
                             ['line_three']])
    end
    it 'done not iterate over empty mocked file' do
      mocked_empty_file
      records = Shipdiscount::DataFile.read('test_data.txt')
      expect(records).to eq([])
    end
    it 'iterates over temp file' do
      records = Shipdiscount::DataFile.read(temp_file1&.to_path)
      expect(records).to eq([%w[line one], %w[second line]])
    end
  end
end
