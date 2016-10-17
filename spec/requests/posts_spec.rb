require 'rails_helper'

describe 'posts', type: :request   do
  include RequestHelper

  let(:post_structure) do
    {
      'id' => a_kind_of(Integer),
      'title' => a_kind_of(String),
      'body' => a_kind_of(String).or(a_nil_value),
      'published_at' => a_kind_of(String).or(a_nil_value)
    }
  end

  describe 'GET /v1/posts' do
    let!(:posts) { create_list(:post, 3) }

    example "returns post resources" do
      get '/v1/posts', params, env
      expect(response).to have_http_status(200)
      expect(JSON(response.body)).to all(match(post_structure))
    end
  end

  describe 'POST /v1/posts' do
    before do
      params[:title] = 'abc'
      params[:body] = 'body for post'
      env['Content-Type'] = 'application/json'
    end

    example "creates post resource" do
      post '/v1/posts', params.to_json, env
      expect(response).to have_http_status(201)
      expect(JSON(response.body)).to match(post_structure)
    end

    context 'with invalid parameters' do
      before { params.delete(:title) }

      it 'returns 400' do
        post '/v1/posts', params.to_json, env
        expect(response).to have_http_status(400)
      end
    end
  end

  describe 'GET /v1/posts/:post_id' do
    context 'with owned published post' do
      let!(:post) { create(:post, user: resource_owner) }

      example "returns post resource" do
        get "/v1/posts/#{post.id}", params, env
        expect(response).to have_http_status(200)
        expect(JSON(response.body)).to match(post_structure)
      end
    end

    context 'with not owned published post' do
      let!(:post) { create(:post, user: other) }
      let(:other) { create(:user) }

      example "returns post resource" do
        get "/v1/posts/#{post.id}", params, env
        expect(response).to have_http_status(200)
      end
    end

    context 'with owned draft post' do
      let!(:post) { create(:post, user: resource_owner, published_at: nil) }

      example "returns draft post response" do
        get "/v1/posts/#{post.id}", params, env
        expect(response).to have_http_status(200)
      end
    end

    context 'with not owned draft post' do
      let!(:post) { create(:post, user: other, published_at: nil) }
      let(:other) { create(:user) }

      example "returns 403" do
        get "/v1/posts/#{post.id}", params, env
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'PUT /v1/posts/:post_id' do
    let!(:post) { create(:post, user: resource_owner) }

    before do
      params[:title] = 'abc'
      params[:body] = 'body for post'
      env['Content-Type'] = 'application/json'
    end

    example 'updates post resource' do
      put "/v1/posts/#{post.id}", params.to_json, env
      expect(response).to have_http_status(204)
    end
  end

  describe 'DELETE /v1/posts/:post_id' do
    let!(:post) { create(:post, user: resource_owner) }

    example 'deletes post resource' do
      delete "/v1/posts/#{post.id}", params, env
      expect(response).to have_http_status(204)
    end
  end

  describe 'GET /v1/users/:user_id/posts' do
    let!(:post) { create(:post, user: other) }
    let!(:another_post) { create(:post, user: create(:user)) }
    let(:other) { create(:user) }

    example "returns post resources of the user" do
      get "/v1/users/#{other.id}/posts", params, env
      expect(response).to have_http_status(200)
      expect(JSON(response.body).size).to eq(1)
    end
  end
end
