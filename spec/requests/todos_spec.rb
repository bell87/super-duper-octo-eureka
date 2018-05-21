# spec/requests/todos_spec.rb
require 'rails_helper'

RSpec.describe 'Todos API', type: :request do
  # initialise test data
  let(:user) { create(:user) }
  let!(:todos) { create_list(:todo, 25, created_by: user.id) }
  let(:todo_id) { todos.first.id }
  let(:headers) { valid_headers }

  # Test suite for GET /todos
  describe 'GET /todos' do
    # make HTTP get request before each example
    before { get '/todos', params: {}, headers: headers }

    it 'returns todos' do
      # Note `json` is a custom helper to parse JSON response
      expect(json).not_to be_empty
      expect(json.size).to eq(20)
    end

    it 'returns a status code 200' do
      expect(response).to have_http_status(200)
    end

  end

  describe 'GET /todos?page=2' do
    before { get '/todos', params: {page: 2}, headers: headers }
    it 'returns an empty array' do
      expect(json).not_to be_empty
      expect(json.size).to eq(5)
    end
  end
  
  describe 'Get /todos/:id' do
    before { get "/todos/#{todo_id}", params: {}, headers: headers }

    context 'when the record exists' do
      it 'returns the todo' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(todo_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:todo_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Todo/)
      end
    end
  end

  describe 'Post /todos' do
    # valid payload
    let(:valid_attributes) do
      { title: 'Learn Rails', created_by: '1' }.to_json
    end

    context 'when the request is valid' do
      before { post '/todos', params: valid_attributes, headers: headers }

      it 'creates a todo' do
        expect(json['title']).to eq('Learn Rails')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when request is invalid' do
      let(:invalid_attributes) { { title: nil }.to_json }
      before { post '/todos', params: invalid_attributes, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/Validation failed: Title can't be blank/)
      end
    end
  end

  describe 'PUT /todos/:id' do
    let(:valid_attributes) { { title: 'Shopping' }.to_json }

    context 'when the record exists' do
      before { put "/todos/#{todo_id}", params: valid_attributes, headers: headers }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  describe 'DELETE /todos/:id' do
    before { delete "/todos/#{todo_id}", params: {}, headers: headers }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end