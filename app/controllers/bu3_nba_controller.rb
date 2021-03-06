require 'mechanize'

class NbaController < ApplicationController
  def index
  end
  def getgamepages 
    games = []
    gamesfullurl = []
    agent = WWW::Mechanize.new { |a| a.log = Logger.new('scrape.log')}
    agent.user_agent_alias = 'Linux Firefox'
    page = agent.get('http://sports.yahoo.com/nba/scoreboard?d=2010-10-08')
    pagepartone = 'http://sports.yahoo.com'
    games = page.links.map do |x|
      x.href if x.href =~ /boxscore/
    end
    games = games.compact
    gamesfullurl = games.map { |x| pagepartone + x }
    logger.info "===> NC.getgamepages 1: #{gamesfullurl.inspect}"
    gamesfullurl
  end
  def getgames
    logger.info "===> NC.getgames 1: #{params.inspect}"

    agent = WWW::Mechanize.new { |a| a.log = Logger.new('scrape.log')}
    agent.user_agent_alias = 'Linux Firefox'
    #page = agent.get('http://sports.yahoo.com/nba/boxscore?gid=2010100809')

=begin
    fakepage = agent.get('http://sports.yahoo.com/nba/scoreboard?d=2010-10-08')
    gamess = []
    pagepartone = 'http://sports.yahoo.com'
    gamess = fakepage.links.map do |x|
      x.href if x.href =~ /boxscore/
    end
    gamess = gamess.compact
    gamesfullurl = gamess.map { |x| pagepartone + x }
    logger.info "===> NC.getgames 1.01: #{gamesfullurl.inspect}"
=end
    
    games = getgamepages
    logger.info "===> NC.getgames 1.01: #{games.inspect}"
    gameid = ""
    if games.empty?
      logger.info "===> NC.getgames 1.02: no urls."
    else
      logger.info "===> NC.getgames 1.03: yes urls. #{games[0].inspect}"
      if games[0] =~ /boxscore/
        logger.info "===> NC.getgames 1.04:"
        #logger.info "===> 21: #{(games[0]=~/boxscore/)}"
        #logger.info "===> 22: #{   games[0][(games[0]=~/boxscore/)+13,8]    }"
        gameid = games[0][(games[0]=~/boxscore/)+13,8]
        #logger.info "===> 23: #{gameid}"
      else
      end
    end

    page = agent.get(games[0])

=begin
    page.links.each do |x| 
      gameid = x.href[18..28] if x.href=~/boxscore/ 
    end
=end
    
    @playersdata = []
    playersodd = page.parser.xpath("//tr[@class='ysprow1']")
    playerseven = page.parser.xpath("//tr[@class='ysprow2']")
    playersodd.each do |i|
      player = []
      for j in i.children
        if j.class == Nokogiri::XML::Element
          player << j.text.lstrip.rstrip.gsub(/\s+/,'').gsub(/\302\240/,'')
        end
      end
      player[16] = gameid
      @playersdata << player
    end
    playerseven.each do |i|
      player = []
      for j in i.children
        if j.class == Nokogiri::XML::Element
          player << j.text.lstrip.rstrip.gsub(/\s+/,'').gsub(/\302\240/,'')
        end
      end
      player[16] = gameid
      @playersdata << player
    end
   
    upload(@playersdata)
    @rowsuploaded = @playersdata.length

    respond_to do |format|
      flash[:notice] = 'Stats successfully scraped, and uploaded.'
      format.html 
      format.xml  { render :xml => @post }
    end
  end
  def upload(data)
    logger.info "===> NC.upload 1"
    data.each do |row|
      item = Performance.new
      z = 0
      while z<row.length do 
        if(z==0) 
          item.name=row[z] 
        elsif(z==1)
          item.position=row[z] 
        elsif(z==2)
          item.time=row[z] 
        elsif(z==3)
          item.fg=row[z] 
        elsif(z==4)
          item.tg=row[z] 
        elsif(z==5)
          item.ft=row[z] 
        elsif(z==6)
          item.diff=row[z] 
        elsif(z==7)
          item.orb=row[z] 
        elsif(z==8)
          item.rb=row[z] 
        elsif(z==9)
          item.ass=row[z] 
        elsif(z==10)
          item.to=row[z] 
        elsif(z==11)
          item.stl=row[z] 
        elsif(z==12)
          item.bs=row[z] 
        elsif(z==13)
          item.ba=row[z] 
        elsif(z==14)
          item.pf=row[z] 
        elsif(z==15)
          item.pts=row[z] 
        elsif(z==16)
          item.game=row[z] 
        else
          logger.info "===>      it should never reach here: #{row[z]} "
        end
        z+=1
      end
      item.save!
    end  
    logger.info "===> NC.upload last"
  end
end
