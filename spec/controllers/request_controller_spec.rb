require 'spec_helper'

describe RequestController do

  describe "GET 'results'" do
    it "returns http success" do
      get 'results'
      response.should be_success
    end
  end

end
