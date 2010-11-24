require 'mechanize'
require 'benchmark'

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
    gamesfullurl
  end
  def getgames

    agent = WWW::Mechanize.new { |a| a.log = Logger.new('scrape.log')}
    agent.user_agent_alias = 'Linux Firefox'
    
    games = getgamepages
    gameid = ""

    page = agent.get(games[0])
    @playersdata = []
    games.each do |thispage|

      page = agent.get(thispage)
      #@playersdata = []

      if(thispage =~ /boxscore/)
        gameid = thispage[(thispage=~/boxscore/)+13,10]
      end

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
    end

    upload(@playersdata)
    openfile
    @rowsuploaded = @playersdata.length

    respond_to do |format|
      flash[:notice] = 'Stats successfully scraped, and uploaded.'
      format.html 
      format.xml  { render :xml => @post }
    end
  end
 
  def openfile()
    openfiletime = Benchmark.measure do
      logger.info "===> openfile 1"
      pagesfile = File.open("/home/joel/yahoonbalinks", "r")
      logger.info "===> openfile 2"
      pagesfile.each do |line|
        #temp = line.split.join("\n")
        logger.info "=====> #{line}"
      end
      logger.info "===> openfile 3"
      pagesfile.close
    end #benchmark
    logger.info "===> openfile 4: #{openfiletime}"
  end

  def upload(data)
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
        end
        z+=1
      end
      item.save!
    end  
  end
end
