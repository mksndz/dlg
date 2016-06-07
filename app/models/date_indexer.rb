class DateIndexer

  # todo this should be a module

  YYYY_MM_DD = /[1-2][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/
  YYYY_MM = /[1-2][0-9][0-9][0-9]-[0-9][0-9]/
  YYYY = /[1-2][0-9][0-9][0-9]/

  UGLY_DATE = /[0-9]{1,2}\/[0-9]{1,2}\/[1-2][0-9]{3}/
  UGLY_RANGE = /[0-2][0-9][0-9][0-9]-[0-2][0-9][0-9][0-9]/

  def initialize
    @logger = Logger.new('./log/date_indexer_debug.log')
  end

  def get_valid_years_for(dc_date)
    item_dates = []
    dc_date.each do |date|

       date = date.to_s
       date = cleanup date

       # check for ugly ranges before throwing out alpha entries to catch the following case
       # circa 1960-1966
       if has_ugly_range? date
         item_dates << [process_y(date.scan(YYYY))]
         next
       end

       next if has_alpha? date

       if has_semicolons? date or has_commas? date
         # ex: 1999; 1989;
         item_dates << process_y(date.scan(YYYY))
         next
       end

       if has_slashes? date

         # UGLY DATE

         if has_ugly_date? date
           item_dates << process_ugly(date.scan(UGLY_DATE))
           next
         end

         # RANGES

         if has_pretty_date? date
           item_dates << [process(date.scan(YYYY_MM_DD))]
           next
         end

         if date.scan(YYYY_MM).present?
           item_dates << [process_ym(date.scan(YYYY_MM))]
           next
         end

         if date.scan(YYYY).present?
           item_dates << [process_y(date.scan(YYYY))]
           next
         end

         # be done
         next

       end

       # single date processing

       if has_pretty_date? date
         item_dates << process(date.scan(YYYY_MM_DD))
         next
       end

       if date.scan(YYYY_MM).present?
         item_dates << process_ym(date.scan(YYYY_MM))
         next
       end

       if date.scan(YYYY).present?
         item_dates << process_y(date.scan(YYYY))
         next
       end       
       
    end

    item_years = []

    item_dates.each do |e|

      if e[0].is_a? Array and e[0].length == 2
        item_years << range_dates(e[0])
      elsif e[0].is_a? Date
        item_years << e[0].strftime('%Y')
      end
    end

    item_years.flatten.uniq

  end

  def get_sort_date(dc_date)
    dc_date.each do |d|
      return d.scan(YYYY).first if d.scan(YYYY).present?
    end
    return
  end

  private
  
  def range_dates(range)
    range.sort
    start_year = range[0].strftime('%Y')
    end_year = range[1].strftime('%Y')
    years = []
    (start_year..end_year).each do |year|
      years << year
    end
    years
  end

  def has_alpha?(date)
    date.scan(/[a-zA-Z]/).present?
  end

  def has_slashes?(date)
    date.scan(/\//).present?
  end

  def has_commas?(date)
    date.scan(/,/).present?
  end

  def has_semicolons?(date)
    date.scan(/;/).present?
  end

  def has_ugly_date?(date)
    date.scan(UGLY_DATE).present?
  end

  def has_pretty_date?(date)
    date.scan(YYYY_MM_DD).present?
  end

  def has_ugly_range?(date)
    date.scan(UGLY_RANGE).present?
  end

  def dateify_ym(ym)
    ym + '-01'
  end

  def dateify_y(y)
    y + '-01-01'
  end

  def process_ugly(dates)
    dates.map do |date|
      begin
        Date.strptime(date, '%d/%m/%Y')
      rescue StandardError => e
        @logger.error "Ugly Date could not be objectified: #{date}"
        return
      end
    end
  end

  def process_y(y_dates)
    y_dates.map do |d|
      get_date_obj_using_yyyy_mm_dd dateify_y(d)
    end
  end

  def process_ym(ym_dates)
    ym_dates.map do |d|
      get_date_obj_using_yyyy_mm_dd dateify_ym(d)
    end
  end

  def process(dates)
    dates.map do |d|
      get_date_obj_using_yyyy_mm_dd d
    end
  end

  def cleanup(date)
    date.gsub(/--/,'-').gsub(/-00-00/,'-01-01').gsub(/-00/,'-01').gsub(/\[/,'').gsub(/\]/,'')
  end

  def get_date_obj_using_yyyy_mm_dd(date)
    unless date.scan(YYYY_MM_DD).present?
      @logger.error 'Object attempted but no proper date found.'
      @logger.error "Problem value: #{date}"
      return
    end
    tries = 0
    begin
      tries += 1
      date_obj = Date.strptime(date, '%Y-%m-%d')
    rescue StandardError => e
      @logger.error "Date object creation failed: #{e}"
      @logger.error "Problem value: #{date}"
      date = date.scan(YYYY_MM).first
      date = dateify_ym(date)
      @logger.error "Retrying with: #{date}"
      retry unless tries == 2
    end
    date_obj
  end

end