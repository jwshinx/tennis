class PostSweeper < ActionController::Caching::Sweeper
  observe Post
  def after_save(post)
    logger.info("=====> PSweeper.after_save 1")
    clear_posts_cache(post)
  end
  def after_destroy(post)
    logger.info("=====> PSweeper.after_destroy 1")
    clear_posts_cache(post)
  end
  def clear_posts_cache(post)
    #expire_page :controller => :posts, :action => :index, :page => params[:page]
    #expire_page :controller => '/posts/page', :page => params[:page]
    #expire_page posts_with_pages(post)
   
    # this one below; commented for fragment caching.
    #expire_page :controller => :posts, :action => :index
    #expire_page :controller => :posts, :action => :show, :id => post
    expire_fragment :recent_posts
  end
end
