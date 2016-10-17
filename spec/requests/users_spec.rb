require 'rails_helper'

describe 'users', type: :request do
  include RequestHelper

  let(:user_structure) do
    {
      'id' => a_kind_of(Integer),
      'name' => a_kind_of(String),
      'email' => a_kind_of(String),
      '_links' => {
        'posts' => {
          'href' => a_string_matching(%r(/v1/users/\d+/posts))
        }
      }
    }
  end

  describe 'GET /v1/users' do
    let!(:users) { create_list(:user, 3) }

    example "returns user resources" do
      get '/v1/users', params, env
      expect(response).to have_http_status(200)
      expect(JSON(response.body)).to all(match(user_structure))
    end
  end

  describe 'GET /v1/users/:user_id' do
    let!(:user) { create(:user, name: 'alice') }

    example "returns user response" do
      get "/v1/users/#{user.id}", params, env
      expect(response).to have_http_status(200)
      expect(JSON(response.body)).to match(user_structure)
    end
  end

  describe 'PUT /v1/users/:user_id' do
    let!(:user) { resource_owner }
    before { params[:name] = 'bob' }

    context 'with owned response' do
      example "updates user resource" do
        put "/v1/users/#{user.id}", params, env
        expect(response).to have_http_status(204)
      end
    end

    context 'without owned resource' do
      let!(:other) { create(:user, name: 'raymonde') }

      it 'returns 403' do
        put "/v1/users/#{other.id}", params, env
        expect(response).to have_http_status(403)
      end
    end
  end
end