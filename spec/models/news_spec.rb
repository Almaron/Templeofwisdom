require 'spec_helper'

describe News, :type => :model do

  it "should be valid" do
    news = build_stubbed :news
    expect(news).to be_valid
  end

end

