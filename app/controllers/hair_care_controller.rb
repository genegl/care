class HairCareController < ApplicationController

	def index

		@xNode = params[:z]
		@yNode = params[:y]
		@px = params[:p]
		
			if @px
				#
			else
				@px = 1
			end
				

		def itemSearchRequest(pg)
	
				timeAmazon = Time.now.iso8601
				timeAmazon = timeAmazon.gsub(":", "%3A")


				linkString = "http://webservices.amazon.com/onca/xml?"
				oneString = ''
				if @xNode
					parametersArray = 
						["Service=AWSECommerceService", "AWSAccessKeyId=#{$accessKey}", "AssociateTag=#{$baseId}","Operation=ItemSearch", "BrowseNode=#{@xNode}", "ResponseGroup=Small,Images,ItemAttributes", "SearchIndex=Beauty", "ItemPage=#{pg}", "Version=2013-08-01", "Timestamp=#{timeAmazon}"]
				elsif @yNode
					parametersArray = ["Service=AWSECommerceService", "AWSAccessKeyId=#{$accessKey}", "AssociateTag=#{$baseId}", "Operation=ItemLookup", "ItemId=#{@yNode}", "ResponseGroup=OfferFull,Images,EditorialReview,ItemAttributes", "Condition=All", "Version=2013-08-01", "Timestamp=#{timeAmazon}"]
				else
					parametersArray = 
						["Service=AWSECommerceService", "AWSAccessKeyId=#{$accessKey}", "AssociateTag=#{$baseId}","Operation=ItemSearch", "BrowseNode=#{$baseNode}", "ResponseGroup=Small,Images,ItemAttributes", "SearchIndex=Beauty", "ItemPage=#{pg}", "Version=2013-08-01", "Timestamp=#{timeAmazon}"]
				end

							
				
				i = 0
				parametersArray.each do |p|
					parametersArray[i] = p.gsub(",", "%2C")
					i += 1
				end

				parametersArray = parametersArray.sort
				parametersArray.each do |q|
					oneString = oneString + q + '&'
				end

				theRequest = oneString
				oneString = oneString.chomp[0..-2]
				oneString = "GET\nwebservices.amazon.com\n/onca/xml\n" + oneString
				the_key = $keySSL
				s256 = OpenSSL::Digest::SHA256.new
				sig = OpenSSL::HMAC.digest(s256, the_key, oneString)
				signature = Base64.strict_encode64(sig)
				signature = signature.gsub("+", "%2B")
				signature = signature.gsub("=", "%3D")
				fullRequest = linkString + theRequest + "Signature=" + signature

				result = Net::HTTP.get(URI.parse(fullRequest))
				result = result.to_s.force_encoding("UTF-8")
				return result
		end
				
		@getRespond = itemSearchRequest(@px)


		def setData
			if @xNode							# Data for list of items
				
				def getPics(xList)

					y1 = 0
					x1 = 0
					w1 = 0
					itemsImgs = []

					10.times do |i|
						x1 = xList.index("<ASIN>", y1)
						w1 = xList.index("</Item>", x1)
						x2 = xList.index("<MediumImage>", x1)
						if x2 && x2 < w1
							x3 = xList.index("<URL>", x2)
							y1 = xList.index("</URL>", x3)
							itemsImgs[i] = xList[(x3+5)...y1]
						else
							itemsImgs[i] = ''
							y1 = w1
						end
					end

					return itemsImgs
				end

		

				def getModels(xList)

					y1 = 0
					x1 = 0
					x2 = 0
					itemsMdls = []

					10.times do |i|
						x1 = xList.index("<ASIN>", y1)
						if x1
							x2 = xList.index("<Brand>", x1)
								if x2
									y1 = xList.index("</Brand>", x2)
									itemsMdls[i] = xList[(x2+7)...y1]
								else
									itemsMdls[i] = ' '
									y1 = x1 + 1
								end
						else
							itemsMdls[i] = ''
						end
					end

					return itemsMdls
				end

		

				def getTitles(xList)

					y1 = 0
					x1 = 0
					itemsTtls = []

					10.times do |i|
						x1 = xList.index("<ASIN>", y1)
						x2 = xList.index("<Title>", x1)
						y1 = xList.index("</Title>", x2)
						xTtl = xList[(x2+7)...y1]
						if xTtl.size > 100
							xTtl = xTtl[0...100] + '[...]'
						end
						itemsTtls[i] = xTtl
					end

					return itemsTtls
				end

		

				def getASIN(xList)

					y1 = 0
					x1 = 0
					itemsAsin = []

					10.times do |i|
						x1 = xList.index("<ASIN>", y1)
						y1 = xList.index("</ASIN>", x1)
						xAsin = xList[(x1+6)...y1]
						itemsAsin[i] = xAsin
					end

					return itemsAsin
				end

		

				def getPrice(xList)

					y1 = 0
					x1 = 0
					w1 = 0
					itemsPrc = []

					10.times do |i|
						x1 = xList.index("<ASIN>", y1)
						w1 = xList.index("</Item>", x1)
						x2 = xList.index("<FormattedPrice>", x1)
						if x2 < w1
							y1 = xList.index("</FormattedPrice>", x2)
							xPrc = xList[(x2+16)...y1]
							itemsPrc[i] = xPrc
						else
							itemsPrc[i] = ''
							y1 = w1
						end
					end

					return itemsPrc
				end

				@itemsImgs = getPics(@getRespond)
				@itemsMdl = getModels(@getRespond)
				@itemsTtl = getTitles(@getRespond)
				@itemsAsin = getASIN(@getRespond)
				@itemsPrc = getPrice(@getRespond)

				xUrl = request.original_url
				x1 = xUrl.rindex("/")
				x2 = xUrl.rindex("?")
				if x2
					xName = xUrl[(x1+1)...x2]
					@baseUrl = xUrl[0...x2]
				else
					xName = xUrl[(x1+1)..-1]
					@baseUrl = xUrl[0..-1]
				end




			elsif @yNode							# Data for specific item
						
				def getPics(xList)

					y1 = 0
					x1 = 0
					w1 = 0
					@itemImg = ''

			
					x1 = xList.index("<ASIN>", y1)
					w1 = xList.index("</Item>", x1)
					x2 = xList.index("<LargeImage>", x1)
					if x2 && x2 < w1
						x3 = xList.index("<URL>", x2)
						y1 = xList.index("</URL>", x3)
						@itemImg = xList[(x3+5)...y1]
					else
						@itemImg = ''
						y1 = w1
					end
			
					return @itemImg
				end


				def getPrice(xList)

					y1 = 0
					x1 = 0
					w1 = 0
					@itemPrc = []

			
					x1 = xList.index("<ASIN>", y1)
					w1 = xList.index("</Item>", x1)
					x2 = xList.index("<ListPrice>", x1)
					if x2 && x2 < w1
						x3 = xList.index("<FormattedPrice>", x2)
						y1 = xList.index("</FormattedPrice>", x3)
						@itemPrc[0] = xList[(x3+16)...y1]					# Original price
					else
						@itemPrc[0] = nil
						y1 = x1 + 1
					end

					x2 = xList.index("<LowestNewPrice>", x1)
					if x2 && x2 < w1
						x3 = xList.index("<FormattedPrice>", x2)
						y1 = xList.index("</FormattedPrice>", x3)
						@itemPrc[1] = xList[(x3+16)...y1]					# Discounted price
					else
						@itemPrc[1] = nil
						y1 = x1 + 1
					end

					x2 = xList.index("<PercentageSaved>", x1)
					if x2 && x2 < w1
						x3 = xList.index("<PercentageSaved>", x2)
						y1 = xList.index("</PercentageSaved>", x3)
						@itemPrc[2] = xList[(x3+17)...y1]					# Percentage Saved
					else
						@itemPrc[2] = nil
						y1 = x1 + 1
					end
			
					return @itemPrc
				end


				def getTitle(xList)

					y1 = 0
					x1 = 0
					@itemTtl = ''

					x1 = xList.index("<ASIN>", y1)
					x2 = xList.index("<Title>", x1)
					y1 = xList.index("</Title>", x2)
					xTtl = xList[(x2+7)...y1]
					@itemTtl = xTtl.html_safe
			
					return @itemTtl
				end

		

				def getDescr(xList)

					y1 = 0
					x1 = 0
					w1 = 0
					r1 = true
					i1 = 0
					@indDscr = []

					x1 = xList.index("<ASIN>", y1)
					w1 = xList.index("</Item>", x1)
					while r1 do
						x2 = xList.index("<Feature>", x1)

						if x2 && x2 < w1
							y1 = xList.index("</Feature>", x2)
							@indDscr[i1] = xList[(x2+9)...y1]
							x1 = y1
							i1 += 1
						else
							r1 = false
						end
					end
					xDscr = @indDscr.join
					xDscr = xDscr.html_safe
					return xDscr
				end

				def getModel(xList)

					y1 = 0
					x1 = 0
					x2 = 0
					itemsMdls = []

					
						x1 = xList.index("<ASIN>", y1)
						if x1
							x2 = xList.index("<Brand>", x1)
								if x2
									y1 = xList.index("</Brand>", x2)
									itemsMdls = xList[(x2+7)...y1]
									itemsMdls = itemsMdls.html_safe
								else
									itemsMdls = ''
									y1 = x1 + 1
								end
						else
							itemsMdls = ''
						end
					

					return itemsMdls
				end

				@oneImg = getPics(@getRespond)
				@onePrc = getPrice(@getRespond)
				@oneTtl = getTitle(@getRespond)
				@oneDscr = getDescr(@getRespond)
				@oneMdl = getModel(@getRespond)

			else								# Data for base page (http://youraddress.com)
				def getPics(xList)

					y1 = 0
					x1 = 0
					w1 = 0
					itemsImgs = []

					10.times do |i|
						x1 = xList.index("<ASIN>", y1)
						w1 = xList.index("</Item>", x1)
						x2 = xList.index("<MediumImage>", x1)
						if x2 && x2 < w1
							x3 = xList.index("<URL>", x2)
							y1 = xList.index("</URL>", x3)
							itemsImgs[i] = xList[(x3+5)...y1]
						else
							itemsImgs[i] = ''
							y1 = w1
						end
					end

					return itemsImgs
				end

		

				def getModels(xList)

					y1 = 0
					x1 = 0
					x2 = 0
					itemsMdls = []

					10.times do |i|
						x1 = xList.index("<ASIN>", y1)
						if x1
							x2 = xList.index("<Brand>", x1)
								if x2
									y1 = xList.index("</Brand>", x2)
									itemsMdls[i] = xList[(x2+7)...y1]
								else
									itemsMdls[i] = ' '
									y1 = x1 + 1
								end
						else
							itemsMdls[i] = ''
						end
					end

					return itemsMdls
				end

		

				def getTitles(xList)

					y1 = 0
					x1 = 0
					itemsTtls = []

					10.times do |i|
						x1 = xList.index("<ASIN>", y1)
						x2 = xList.index("<Title>", x1)
						y1 = xList.index("</Title>", x2)
						xTtl = xList[(x2+7)...y1]
						if xTtl.size > 100
							xTtl = xTtl[0...100] + '[...]'
						end
						itemsTtls[i] = xTtl
					end

					return itemsTtls
				end

		

				def getASIN(xList)

					y1 = 0
					x1 = 0
					itemsAsin = []

					10.times do |i|
						x1 = xList.index("<ASIN>", y1)
						y1 = xList.index("</ASIN>", x1)
						xAsin = xList[(x1+6)...y1]
						itemsAsin[i] = xAsin
					end

					return itemsAsin
				end

		

				def getPrice(xList)

					y1 = 0
					x1 = 0
					w1 = 0
					itemsPrc = []

					10.times do |i|
						x1 = xList.index("<ASIN>", y1)
						w1 = xList.index("</Item>", x1)
						x2 = xList.index("<FormattedPrice>", x1)
						if x2 < w1
							y1 = xList.index("</FormattedPrice>", x2)
							xPrc = xList[(x2+16)...y1]
							itemsPrc[i] = xPrc
						else
							itemsPrc[i] = ''
							y1 = w1
						end
					end

					return itemsPrc
				end

				@itemsImgs = getPics(@getRespond)
				@itemsMdl = getModels(@getRespond)
				@itemsTtl = getTitles(@getRespond)
				@itemsAsin = getASIN(@getRespond)
				@itemsPrc = getPrice(@getRespond)

				xUrl = request.original_url
				x1 = xUrl.rindex("?")
				if x1
					@pageLink = xUrl + "&"
					@currentUrl = xUrl[0...x1]
				else
					@pageLink = xUrl + "?"
					@currentUrl = xUrl
				end

				if @currentUrl.last != "/"
					@currentUrl = @currentUrl + "/"
				end

			end

			def setMenuNames
				@menuNames = { "10656662011" => "3-in-1 Shampoo", "10656663011" => "Daily Shampoo", "10656664011" => "Dry Shampoo", "11057441" => "Shampoo Conditioner Sets", "3781381" => "Shampoo Plus Conditioner",
				 				"11057251" => "Conditioner", "10664362011" => "Detanglers", "11057871" => "Gels", "11057891" => "Hair Sprays", "11057901" => "Mousses & Foams", "10666019011" => "Oils & Serums", "11057931" => "Pomades & Waxes",
				 				"10664802011" => "Putties & Clays", "10666084011" => "Styling Treatments", "10728531" => "Hair Color", "10676298011" => "Color Additives & Fillers", "3781671" => "Color Correctors", "10676302011" => "Color Glazes",
				 				"3784201" => "Color Removers", "3784151" => "Coloring & Highlighting Tools", "3784161" => "Applicator Bottles", "3784171" => "Brushes, Combs & Needles", "3784181" => "Caps, Foils & Wraps", "3784191" => "Hair Color Mixing Bowls",
				 				"10676347011" => "Developers", "10676355011" => "Hair Chalk", "10676359011" => "Hair Mascaras & Root Touch Ups", "3781641" => "Hennas", "11057431" => "Hair & Scalp Treatments", "10666437011" => "Hair Masks",
				 				"10666439011" => "Treatment Oils", "11057981" => "Barrettes", "10676142011" => "Bun & Crown Shapers", "3784401" => "Clips", "11058071" => "Elastics & Ties", "3784491" => "Hair Drying Towels", "3784391" => "Hair Pins",
				 				"11058051" => "Headbands", "11058011" => "Side Combs", "3784341" => "Crimpers & Wavers", "11058251" => "Curling Irons & Wands", "11058111" => "Diffusers & Dryer Attachments", "11058121" => "Hair Brushes", "11058131" => "Hair Combs",
				 				"11058141" => "Hair Dryers", "3784371" => "Hair Rollers", "11058221" => "Hot-Air Brushes", "11058261" => "Straighteners", "3781901" => "Perms & Straighteners", "10702858011" => "Relaxers & Texturizers", "10676812011" => "Adhesives",
				 				"10676816011" => "Feather Extensions", "702379011" => "Hair Extensions", "702380011" => "Hairpieces", "10676818011" => "Wig Caps", "702381011" => "Wigs", "7706130011" => "Hair Clippers & Accessories", "3006301011" => "Hair Cutting Kits",
				 				"3006300011" => "Shears"}
			end

			setMenuNames()
					
		end 	# setData

		setData()

	
	end 	#index





end