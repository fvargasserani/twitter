require 'rails_helper'

RSpec.describe "tweets/_form", type: :view do
  context 'before publication' do 
    it 'cannot be blank' do  
      expect { Tweet.create.content.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
