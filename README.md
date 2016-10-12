[クックパッド開発者ブログ RESTful Web API 開発をささえる Garage](http://techlife.cookpad.com/entry/2014/11/06/100000)の個人勉強用リポジトリです

## 要件

* ruby 2.2.5
* mysql

## 使い方

```
$ git clone git@github.com:seak0503/rails_garage.git

$ cd rails_garage

$ bundle install
```

## 補足

### Rails new

Gemfileで`gem 'garage', github: 'cookpad/garage'`となっているが`gem 'the_garage', github: 'cookpad/garage'`にしないと`bundle install`の際にエラーになる。
