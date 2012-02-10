require 'net/http'
require 'digest/sha1'
require 'json'

class RequestController < ApplicationController
	@@KEY = "b07a12df7d52e6c118e5d47d3f9e60135b109a1f"

	def check_params
		if params[:uid].blank?
			flash[:error] = "User ID cannot be void"
			redirect_to :action =>'index' and return
		elsif (!params[:page].blank? && params[:page].to_i > 10)
			flash[:error] = "Page must be less than 10"
			redirect_to :action => 'index' and return
		elsif params[:page].blank?
			@page = '1'
			@uid = params[:uid]
		  @pub0 = params[:pub0]
		else
			@uid = params[:uid]
		  @pub0 = params[:pub0]
		  @page = params[:page]
		end
	end

	def render_error
		respond_to do |format|
		  format.html { render :file => "#{Rails.root}/public/"+@type_error+".html", :status => :not_found }
		end
	end

	def check_error
		case @resp.message
			when 'Bad Request' then
				@type_error = "400"
				render_error
			when 'Unauthorized' then
				@type_error = "401"
				render_error
			when 'Not found' then
				@type_error = "404"
				render_error
			when 'Internal Server Error' then
				@type_error = "500"
				render_error
			when 'Bad Gateway' then
				@type_error = "502"
				render_error
		end
	end


  def results

		check_params


		# a hash holding the relevant keys and values
		params_api_hash = {	'appid' => '157',
				    	'ip' => '109.235.143.113',
				    	'locale' => 'de',
					    'page' => @page,
				    	'uid' => @uid,
							'timestamp' => Time.now.to_i,
							'device_id' => '2b6f0cc904d137be2e1730235f5664094b831186',
							'offer_types' => '112'}

		if !params[:pub0].blank?
			params_api_hash['pub0'] = @pub0
		end

		# set up an array so the params can be sorted alphatetically
		params_api_list = []

		params_api_hash.each do|key,value|
			params_api_list << "#{key}=#{value}"
		end
		# sort alphabetically

		params_api_list.sort!

		@params_api_string = params_api_list.join('&').downcase

		@params_api_string_plus_key = @params_api_string + "&" + @@KEY

		@hashstring = (Digest::SHA1.hexdigest @params_api_string_plus_key).downcase

		@params_api_string += "&hashkey=#{@hashstring}"

		@resp = Net::HTTP.get_response("api.sponsorpay.com", "/feed/v1/offers.json?#{@params_api_string}")

		#check_error
		#if @resp.message == "Bad Request"
			#flash[:error] = "Invalid or missing request parameters"
			#redirect_to :action =>'index' and return
		#end

		@body = @resp.body

		@message = @resp.message

		@resp_sha1 = Digest::SHA1.hexdigest(@resp.body + @@KEY)

    @ok = @resp["X-Sponsorpay-Response-Signature"] == @resp_sha1

		@decoded_body = ActiveSupport::JSON.decode(@body)

    #@offers = @decoded_body["offers"]

	end
end
