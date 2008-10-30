# Alter Radiant's site controller to add the domain to the cache files.
# Also store requests for later use.
# See radiant/app/controllers/site_controller.rb
module CacheByDomain
  def show_page
    response.headers.delete('Cache-Control')
    
    url = params[:url]
    if Array === url
      url = url.join('/')
    else
      url = url.to_s
    end
    
    cache_key = cache_key_for_url(url) # Use cache_key, not raw URL
    
    if (request.get? || request.head?) and live? and (@cache.response_cached?(url))
      @cache.update_response(cache_key, response, request)
      @performed_render = true
    else
      show_uncached_page(url)
    end
  end
  
  
  private
    def cache_key_for_url(url)
      "#{request.host}/#{url}"
    end

    # def show_uncached_page(url)
    #   @page = find_page(url)
    #   unless @page.nil?
    #     process_page(@page)
    #     cache_key = cache_key_for_url(url) # Use cache key, not raw URL
    #     @cache.cache_response(cache_key, response) if request.get? and live? and @page.cache?
    #     @performed_render = true
    #   else
    #     render :template => 'site/not_found', :status => 404
    #   end
    # rescue Page::MissingRootPageError
    #   redirect_to welcome_url
    # end
end
