require 'rails_helper'

RSpec.describe DateIndexer, type: :model do
  # HANDLED DATE VALUES
  #   1732-02-03/1732-03-24
  #   1732-06-09
  #   1732/1783
  #   0000/1885-06-10
  #   1/31/1991
  #   1903-05
  #   approx. 1934
  #   circa 1960-1969
  #   July 1, 1997 - June 30, 1998
  #   1/21/1999-4/4/2012
  #   5/1986
  #   1776-7
  #   unknown
  #   [1999]
  #   1999
  #   0000-00-00
  #   1920-00-00
  #   1800-1900
  # PROBLEM DATE VALUES
  #   27847584.329847
  let(:date_indexer) do
    DateIndexer.new
  end
  it 'returns an array of years given an array of values containing legit single
      dates as strings' do
    dc_dates = %w(1732-02-03 1921-02-03)
    expect(date_indexer.get_valid_years_for(dc_dates)).to eq %w(1732 1921)
  end
  it 'returns an array of years given an array of values containing nonsense
      days that do not exist' do
    dc_dates = %w(1732-02-31 1921-03-32)
    expect(date_indexer.get_valid_years_for(dc_dates)).to eq %w(1732 1921)
  end
  it 'returns an array of years given an array of values containing legit single
      dates as strings' do
    dc_dates = %w(garbage 3000 0123)
    expect(date_indexer.get_valid_years_for(dc_dates)).to eq []
  end
  it 'returns an array of years given an array of values containing dates with
      some common errors' do
    dc_dates = %w(1999-00-00 2001--07-09 2004-03-00)
    expect(date_indexer.get_valid_years_for(dc_dates)).to eq %w(1999 2001 2004)
  end
  it 'returns an array of years given an array of values containing dates in the
      ugly format' do
    dc_dates = %w(02/03/1732 2/3/1776 11/25/1916 9/15/2016)
    expect(date_indexer.get_valid_years_for(dc_dates)).to(
      eq %w(1732 1776 1916 2016)
    )
  end
  it 'returns an array of years given an array of values containing an ugly date
      range and some text' do
    dc_dates = ['circa 1999-2001']
    expect(date_indexer.get_valid_years_for(dc_dates)).to eq %w(1999 2000 2001)
  end
  it 'returns an array of years given an array of values containing an normal
      date range' do
    dc_dates = ['1-1-1983/1-1-1990']
    expect(date_indexer.get_valid_years_for(dc_dates)).to(
      eq %w(1983 1984 1985 1986 1987 1988 1989 1990)
    )
  end
  it 'returns an array of years given an array of values containing an normal
      date range without days' do
    dc_dates = ['1-1983/7-1990']
    expect(date_indexer.get_valid_years_for(dc_dates)).to(
      eq %w(1983 1984 1985 1986 1987 1988 1989 1990)
    )
  end
  it 'returns an array of years given an array of values containing an normal
      date range without days or months' do
    dc_dates = ['1983/1990']
    expect(date_indexer.get_valid_years_for(dc_dates)).to(
      eq %w(1983 1984 1985 1986 1987 1988 1989 1990)
    )
  end
  it 'returns an array of years given an array of values containing an ugly date
      range without days or months' do
    dc_dates = ['1983-1990']
    expect(date_indexer.get_valid_years_for(dc_dates)).to(
      eq %w(1983 1984 1985 1986 1987 1988 1989 1990)
    )
  end
  it 'returns a single date given an array of values possible containing legit
      dates ' do
    dc_dates = %w(garbage 94827 3-9-1777)
    expect(date_indexer.get_sort_date(dc_dates)).to eq '1777'
  end
end