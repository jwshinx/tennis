require 'mechanize'
require 'benchmark'

class NbaController < ApplicationController

  include Sorting

  def index
    
  end
  def mspts
    logger.info "==== NC.mspts 1"
    respond_to do |format|
      format.html
      format.xml 
    end
  end
  def top_scorers
    logger.info "==== NC.top_scorers 1"
    greetings
    @best = Performance.find(:all,
                             :select => "name, pts, game",
                             :order => "pts DESC",
                             :limit => 25)
    logger.info "==== NC.top_scorers 2"
    respond_to do |format|
      flash[:notice] = 'scoring performances 20 points and greater.'
      format.html 
      format.xml  { render :xml => @best }
    end
  end
  def top_rebounders
    logger.info "==== NC.top_rebounders 1"
    @best = Performance.find(:all,
                             :select => "name, orb, rb, game",
                             :order => "rb DESC",
                             :limit => 25)
    logger.info "==== NC.top_rebounders 2"
    respond_to do |format|
      flash[:notice] = 'top 10 rebound performances.'
      format.html 
      format.xml  { render :xml => @best }
    end
  end
  def getgamepages 
    games = []
    gamesfullurl = []
    agent = WWW::Mechanize.new { |a| a.log = Logger.new('scrape.log')}
    agent.user_agent_alias = 'Linux Firefox'
    page = agent.get('http://sports.yahoo.com/nba/scoreboard?d=2010-10-08')
    logger.info "=================== getgamespage 1 ============"
    @filesarray = openfile
    logger.info "    @filesarray: #{@filesarray.inspect}"
    logger.info "=================== getgamespage 2 ============"
    pagepartone = 'http://sports.yahoo.com'

    if @filesarray.empty?
      logger.info "  THERE IS NOTHING TO UPLOAD"
    else 
      @filesarray.each do |aurl|
        page = agent.get(aurl)
        games = page.links.map do |x|
          x.href if x.href =~ /boxscore/
        end
        games = games.compact
        games.each do |i| 
          i = pagepartone + i 
          logger.info "     >>> #{i}"
          gamesfullurl << i
        end 
      end
    end


    #logger.info "=================== getgamespage 3 ============"
    #logger.info "    gamesfullurl: #{gamesfullurl.inspect}"
    #logger.info "=================== getgamespage 4 ============"
    gamesfullurl
  end
  def getgames

    agent = WWW::Mechanize.new { |a| a.log = Logger.new('scrape.log')}
    agent.user_agent_alias = 'Linux Firefox'
    
    games = getgamepages
    gameid = ""

if games.empty?
  @rowsuploaded = 0
  logger.info "====> getgames games is empty.  @rowsuploaded: #{@rowsuploaded}"
else

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
    @rowsuploaded = @playersdata.length
end

    respond_to do |format|
      flash[:notice] = 'Stats successfully scraped, and uploaded.'
      format.html 
      format.xml  { render :xml => @post }
    end
  end
 
  def openfile()
    openfilearray = []
    pagesfile = File.open("/home/joel/myrailsapps/tennis/public/yahoonbalinks", "r")
    pagesfile.each do |line|
      #temp = line.split.join("\n")
      if line=~/#####/
        logger.info "=====> ##### is there #{line}"
      else
        logger.info "=====> ##### none there #{line}"
        openfilearray << line
      end 
      #openfilearray << line
    end
    pagesfile.close
    openfilearray
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
          item.orb=Integer(row[z]) 
        elsif(z==8)
          item.rb=Integer(row[z]) 
        elsif(z==9)
          item.ass=Integer(row[z]) 
        elsif(z==10)
          item.to=Integer(row[z]) 
        elsif(z==11)
          item.stl=Integer(row[z]) 
        elsif(z==12)
          item.bs=Integer(row[z]) 
        elsif(z==13)
          item.ba=Integer(row[z]) 
        elsif(z==14)
          item.pf=Integer(row[z]) 
        elsif(z==15)
          item.pts=Integer(row[z]) 
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
