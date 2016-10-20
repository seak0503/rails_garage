[クックパッド開発者ブログ RESTful Web API 開発をささえる Garage](http://techlife.cookpad.com/entry/2014/11/06/100000)の個人勉強用リポジトリです

## 要件

* ruby 2.2.5
* mysql
* rbenvインストール済み
* rbenv-gemsetインストール済み

## 使い方

```
$ git clone git@github.com:seak0503/rails_garage.git

$ cd rails_garage

$ rbenv gemset create 2.2.5 rails_garage

$ bundle install

$ bin/rake db:create

$ bin/rake db:migrate

$ bundle exec rspec # すべてのテストが通ることを確認
```

## APIの動きを確認する

```
$ rails runner 'User.create(name: "alice", email: "alice@example.com")' # creating test user

$ rails s

open http://localhost:3000/oauth/applications # Then create test application

$ curl -u "$APPLICTION_ID:$APPLICATION_SECRET" -XPOST http://localhost:3000/oauth/token -d 'grant_type=password&username=alice@example.com' # Then you got access token

$ curl -XGET -H "Authorization: Bearer $ACCESS_TOKEN" http://localhost:3000/v1/users
```

## API ドキュメント生成

```
$ AUTODOC=1 bin/rspec
```

## 補足

### Rails new

Gemfileで`gem 'garage', github: 'cookpad/garage'`となっているが`gem 'the_garage'`にしないと`bundle install`の際にエラーになる。


### リソースの保護

ドキュメントのとおり設定しても下記のテストが落ちる

```
context 'without owned resource' do
  let!(:other) { create(:user, name: 'raymonde') }

  it 'returns 403' do
    put "/v1/users/#{other.id}", params, env
    expect(response).to have_http_status(403)
  end
end
```

原因はオリジナルのdoorkeeperを使っていたことにあった。

garageのバージョンがあがったことによる影響らしい。

[garageのREADME](https://github.com/cookpad/garage)をよく見ると、[Advanced Configurations](https://github.com/cookpad/garage#advanced-configurations)のところで、garage-doorkeeperを使うよう書かれている。


そこで、Gemfileから`doorkeeper`を削除し、`garage-doorkeeper`を追加した後、bundle インストールし、`config/initializer/garage.rb`を下記のように変更したところ、テストがpathした。

* `config/initializer/garage.rb`

```
Garage.configure {}
Garage::TokenScope.configure do
  register :public, desc: 'accessing publicly available data' do
    access :read, User
    access :write, User
  end
end

Garage.configuration.strategy = Garage::Strategy::Doorkeeper
Doorkeeper.configure do
  orm :active_record
  default_scopes :public
  optional_scopes(*Garage::TokenScope.optional_scopes)

  resource_owner_from_credentials do |routes|
    User.find_by(email: params[:username])
  end
end
```