require 'net/http'
require 'digest/sha1'
require 'json'

class RequestController < ApplicationController

	@@KEY = "b07a12df7d52e6c118e5d47d3f9e60135b109a1f"


	def empty_key?
			@@KEY == ""
	end

	Integer= /[1-9]/

	#With this method we validate the input parameters
	def check_params
		#User ID must introduced
		if params[:uid].blank?
			flash[:error] = "User ID cannot be void"
			redirect_to :action =>'index' and return
		#Page must be a number
		elsif (!params[:page].blank? && !(Integer === params[:page]))
			flash[:error] = "Page must be a number"
			redirect_to :action => 'index' and return
		#If page is empty, we set it to 1
		elsif params[:page].blank?
			@page = '1'
			@uid = params[:uid]
		  @pub0 = params[:pub0]
		#Normal assignments
		else
			@uid = params[:uid]
		  @pub0 = params[:pub0]
		  @page = params[:page].to_i
		end
	end

	def index
	end

  def results

		#Parameters validation
		check_params

		#This hash contains all request parameters
		params_api_hash = {	'appid' => '157',
				    	'ip' => '109.235.143.113',
				    	'locale' => 'de',
					    'page' => @page,
				    	'uid' => @uid,
							'timestamp' => Time.now.to_i,
							'device_id' => '2b6f0cc904d137be2e1730235f5664094b831186',
							'offer_types' => '112'}

		#pub0 is an optional paremeter, so we just add it if user introduces it
		if !params[:pub0].blank?
			params_api_hash['pub0'] = @pub0
		end

		#This list will contain all the parameters alphabetically sorted
		params_api_list = []

		#Each parameter is introduced
		params_api_hash.each do|key,value|
			params_api_list << "#{key}=#{value}"
		end

		#The list is sorted
		params_api_list.sort!

		#We concatenate all the values of the list separated by & and we set them to lowercase
		@params_api_string = params_api_list.join('&').downcase

		#The API Key comes at the end of this string
		@params_api_string_plus_key = @params_api_string + "&" + @@KEY

		#We hash the resulting string using SHA1
		@hashstring = (Digest::SHA1.hexdigest 			@params_api_string_plus_key).downcase

		#It comes at the end of the parameters string
		@params_api_string += "&hashkey=#{@hashstring}"

		#The URL request is made using Net:HTTP
		@resp = Net::HTTP.get_response("api.sponsorpay.com", "/feed/v1/offers.json?#{@params_api_string}")

		#This variable contains the body of the response
		@body = @resp.body

		#And this one the message of the response
		@message = @resp.message

		#We check that it's a real response
		@resp_sha1 = Digest::SHA1.hexdigest(@resp.body + @@KEY)
    @ok = @resp["X-Sponsorpay-Response-Signature"] == @resp_sha1

		#Using JSON the response body is decoded in order to use it to get the results
		@decoded_body = ActiveSupport::JSON.decode(@body)

	end
end
