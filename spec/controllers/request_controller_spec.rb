require 'spec_helper'

describe RequestController do

	it "should have an API Key" do
		req = RequestController.new
		req.empty_key?
		req.should_not be_empty_key
	end

	it "has all parameters"

	it "returns http success"


end
