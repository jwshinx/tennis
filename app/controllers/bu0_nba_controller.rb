require 'mechanize'

class NbaController < ApplicationController
  def index
  end

  def getgames
    logger.info "===> NC.getgames 1"

    agent = WWW::Mechanize.new { |a| a.log = Logger.new('scrape.log')}
    agent.user_agent_alias = 'Linux Firefox'
    #page = agent.get('http://sports.yahoo.com/nba/players/3704/gamelog')
    page = agent.get('http://sports.yahoo.com/nba/boxscore?gid=2010100809')

    #page.links.each { |link| logger.info "   <#{link.to_s.lstrip}>" } 
    #@data = page.links.map { |item| item } 
    #@data.each { |item| logger.info "   [#{item}]" }
    #@post = Post.new(params[:post])
  
    @playersdata = []
    playersodd = page.parser.xpath("//tr[@class='ysprow1']")
    #playerseven = page.parser.xpath("//tr[@class='ysprow2']")
    for i in playersodd
      player = []
      for j in i.children
        if j.class == Nokogiri::XML::Element
          player << j.text.lstrip.rstrip.gsub(/\s+/,'').gsub(/\302\240/,'')
        end


      end
      @playersdata << player
    end
   
    logger.info "===> NC.getgames 1"
    upload(@playersdata[0])
    logger.info "===> NC.getgames 2: #{@playersdata.length}"

    respond_to do |format|
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
    logger.info "===> #{data}"
    logger.info "===> NC.upload last"
  end
end
