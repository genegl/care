class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  $baseId = ''										# Enter here your Amazon Associate ID (looks like YourAssosciateName-20)
  $theBase = ''						# Enter here base web address wit a slash (http://myaddress.com/)
  $accessKey = ''						# Enter here key for Amazon API (looks like "IVO5D4MUZYFI7X")
  $keySSL = ''		# Enter here key for SSL (looks like "bdtWeli0syAEthRyxe4kAPb7XXEg")

  $baseNode = '11057241'	# Amazon's node ID for Hair Care
  
end
