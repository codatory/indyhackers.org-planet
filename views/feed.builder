xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.title CONFIG['title']
    xml.description CONFIG['about']
    xml.link CONFIG['root_url']
    xml.tag! 'atom:link', :href => "#{CONFIG['root_url']}posts.rss", :rel => 'self', :type => 'application/rss+xml'

    for post in @posts
      xml.item do
        xml.title post.title
        content = (post.content || post.summary)
        if content
          xml.description content
        else
          xml.description "No content"
        end
        xml.pubDate post.published.rfc2822
        xml.link post.url
        xml.guid post.url
      end
    end
  end
end
