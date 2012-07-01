require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'progressbar'

class Udacity
    def parseLink(links)
        urlArray = []
            for i in links
	        urlArray.push(i) if i =~ /^http:\/\/www\.youtube\.com/
	    end
	urlArray
    end
    def httpsLink(links)
        urlArray = []
        for i in links
            i.sub!(/^(http:)/,'https:')
	    urlArray.push(i) 
	end
	urlArray
    end
    def ydownloader(vidurl)
	  youtubepath = vidurl
	  uri = URI.parse(youtubepath)
	  open(uri) do |file|
		openedsource = file.read
		#  search for the title
		rgtitlesearch = Regexp.new(/\<meta name="title" content=.*/)
		vidtitle = rgtitlesearch.match(openedsource)
		vidtitle = vidtitle[0].gsub("<meta name=\"title\" content=\"","").gsub("\">","").gsub(/ /,'')+".flv"
		# search for the download link
		rglinksearch = Regexp.new(/,url=.*\\u0026quality=/)
		vidlink = rglinksearch.match(openedsource)
		vidlink[0].split(",url=").each do |foundlinks|
		  vidlink = foundlinks.gsub(",url=","").gsub("\\u0026quality=","").gsub("%3A",":").gsub("%2F","/").gsub("%3F","?").gsub("%3D","=").gsub("%252C",",").gsub("%253A",":").gsub("%26","&")
		end
		def download vidlink, vidfile

		  writeOut = open(vidfile, "wb")
		  writeOut.write(open(vidlink).read)
		  writeOut.close
		end
		download(vidlink,vidtitle)
		print " " #Download DOne!
	  end
	end
	# Main script
	puts "Enter mirror URL"
	str = gets.chomp
        page = Nokogiri::HTML(open(str))
	links = []
	linkshash = page.css('a')
	  for i in linkshash
		links.push(i['href'].to_s)
	  end
	u = Udacity.new
	links = u.parseLink(links)
	links = u.httpsLink(links)
	puts "Total #{links.count} videos to be downloaded"
	incr_step = 100 / links.count
	pbar = ProgressBar.new("Downloading...",links.count)
	#pbar.file_transfer_mode = :stat_for_file_transfer
		for i in links
		  u.ydownloader(i)
		  pbar.inc(incr_step)
		end
	#pbar.finish
	pbar.halt
	puts 'Downloads complete!'
end
