require 'mechanize'

class NbaController < ApplicationController
  def index
  end

  def getgames
    logger.info "===> NC.getgames 1: #{params.inspect}"

    agent = WWW::Mechanize.new { |a| a.log = Logger.new('scrape.log')}
    agent.user_agent_alias = 'Linux Firefox'
    #page = agent.get('http://sports.yahoo.com/nba/players/3704/gamelog')
    page = agent.get('http://sports.yahoo.com/nba/boxscore?gid=2010100809')

    #page.links.each { |link| logger.info "   <#{link.to_s.lstrip}>" } 
    #@data = page.links.map { |item| item } 
    #@data.each { |item| logger.info "   [#{item}]" }
    #@post = Post.new(params[:post])
  
    gameid = ""
    page.links.each do |x| 
      gameid = x.href[18..28] if x.href=~/boxscore/ 
    end
    #logger.info "===> NC.getgames 1.1: #{gameid}"
    
    
    @playersdata = []
    playersodd = page.parser.xpath("//tr[@class='ysprow1']")
    playerseven = page.parser.xpath("//tr[@class='ysprow2']")
    #for i in playersodd
    playersodd.each do |i|
      player = []
      for j in i.children
        if j.class == Nokogiri::XML::Element
          player << j.text.lstrip.rstrip.gsub(/\s+/,'').gsub(/\302\240/,'')
        end
      end
      player[16] = gameid
      #logger.info "===> NC.getgames 1.2: #{player[0]}"
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
      #logger.info "===> NC.getgames 1.3: #{player[0]}"
      @playersdata << player
    end
   
    #logger.info "===> NC.getgames 1"
    upload(@playersdata)
    @rowsuploaded = @playersdata.length
    #logger.info "===> NC.getgames 2: #{@rowsuploaded}"

    respond_to do |format|
      flash[:notice] = 'Stats successfully scraped, and uploaded.'
      format.html 
      format.xml  { render :xml => @post }
=begin
      if @post.save
        flash[:notice] = 'Post was successfully created.'
        format.html { redirect_to(@post) }
        format.xml  { render :xml => @post, :status => :created, 
                             :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, 
                             :status => :unprocessable_entity }
      end
=end
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
