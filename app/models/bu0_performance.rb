class Performance < ActiveRecord::Base
  def best_pts(points)
    logger.info "===> P.best_pts 1: #{points}"
    @bestperfs = Performance.find(:all, :conditions => ['pts >= ?', points])
  end
  
  def fg_pct(x)
    @perf = Performance.find(:first, :conditions => ["id = ?", x])
    @fg = @perf.fg
    if @fg.nil?
      puts "===> @fg is nil"
      return 0
    end
    puts "===> @fg is not nil"
      
    @dash_index = @fg.index('-') 
    puts "===> P.fg_pct 1: #{x}:#{@perf.name}:#{@perf.fg}"
    puts "===> P.fg_pct 2: #{@dash_index}"
    @num = @fg.slice(0, @dash_index)
    if @num == "0"
      puts "===> @fg is zero"
      return 0
    end
    puts "===> @fg is not zero"
    puts "===> P.fg_pct 3: #{@num}"
    @den = @fg.slice((@dash_index+1), @fg.length)
    puts "===> P.fg_pct 4: #{@den}"
    @pct = @num.to_f / @den.to_f 
    puts "===> P.fg_pct 5: #{@pct}"
    @pct
  end
  def ft_pct(x)
    @perf = Performance.find(:first, :conditions => ["id = ?", x])
    @ft = @perf.ft
    if @ft.nil?
      puts "===> @ft is nil"
      return 0
    end
    puts "===> @ft is not nil"
    @dash_index = @ft.index('-') 
    @num = @ft.slice(0, @dash_index)
    puts "===> #{@ft}:#{@num}"

    if @num == "0"
      puts "===> @ft is zero"
      return 0
    end
    puts "===> @ft is not zero"
    @den = @ft.slice((@dash_index+1), @ft.length)
    @pct = @num.to_f / @den.to_f 
    @pct
  end
end
