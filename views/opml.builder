xml.instruct! :xml, :version => "1.0"
xml.opml :version => "2.0" do
    xml.head do
        xml.title "IndyHackers Planet Feed"
        xml.docs "https://github.com/codatory/indyhackers.org-planet"
    end
    xml.body do
        for feed in @feeds
            xml.outline(
                title: feed[:title],
                description: feed[:description],
                htmlUrl: feed[:html_url],
                xmlUrl: feed[:xml_url]
            )
        end
    end
end