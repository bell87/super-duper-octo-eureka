class V2::TodosController < ApplicationController

  def index
    json_response({ message: 'Hello world '})
  end

end
