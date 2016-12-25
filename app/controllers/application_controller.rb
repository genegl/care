class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  $baseId = ''										# Enter here your Amazon Associate ID
  $theBase = ''						# Enter here base web address wit a slash (http://myaddress.com/)
  $accessKey = ''						# Enter here key for Amazon API
  $keySSL = ''		# Enter here key for SSL

  $baseNode = '11057241'	# Amazon's node ID for Hair Care
  
end
