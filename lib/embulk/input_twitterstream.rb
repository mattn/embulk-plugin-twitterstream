require 'twitter'
require 'json'

module Embulk
  class StopStreamException < Exception; end

  class InputTwitterStream < InputPlugin
    Plugin.register_input('twitterstream', self)

      COLUMN_NAMES = [
        'text',
        'created_at',
        'id_str',
        'user.follow_request_sent',
        'user.following',
        'user.time_zone',
        'user.created_at',
        'user.profile_sidebar_fill_color',
        'user.profile_image_url',
        'user.default_profile',
        'user.geo_enabled',
        'user.profile_sidebar_border_color',
        'user.is_translator',
        'user.url',
        'user.profile_image_url_https',
        'user.description',
        'user.listed_count',
        'user.profile_use_background_image',
        'user.friends_count',
        'user.followers_count',
        'user.profile_text_color',
        'user.profile_background_image_url',
        'user.location',
        'user.profile_link_color',
        'user.protected',
        'user.default_profile_image',
        'user.lang',
        'user.statuses_count',
        'user.verified',
        'user.name',
        'user.id_str',
        'user.show_all_inline_media',
        'user.contributors_enabled',
        'user.notifications',
        'user.profile_background_image_url_https',
        'user.profile_background_color',
        'user.id',
        'user.profile_background_tile',
        'user.utc_offset',
        'user.favourites_count',
        'user.screen_name',
        'in_reply_to_user_id',
        'id',
        'contributors',
        'truncated'
      ]

    def self.transaction(config, &control)
      task = config
      threads = 1
      cols = config.param('columns', :array)
      if cols.empty?
        columns = COLUMN_NAMES.map.with_index  {|column, index|
          Column.new(index, column, :string)
        }
      else
        columns = config.param('columns', :array).map.with_index { |column, index|
          Column.new(index, column, :string)
        }
      end
      commit_reports = yield(task, columns, threads)
      return {}
    end

    def initialize(task, schema, index, page_builder)
      super
    end

    def dot_flatten(hash, path = '')
      hash.each_with_object({}) do |(k, v), ret|
        key = path + k.to_s
        if v.is_a? Hash
          ret.merge! dot_flatten(v, key + '.')
        else
          ret[key] = v
        end
      end
    end

    def run
      client = Twitter::Streaming::Client.new(
        consumer_key:         @task['consumer_key'],
        consumer_secret:      @task['consumer_secret'],
        access_token:         @task['access_token'],
        access_token_secret:  @task['access_token_secret'],
      )
      count = @task['count'] ? @task['count'].to_i : 0
      begin
        client.user do |item|
          case item
          when Twitter::Tweet
            tweet = dot_flatten(item.to_hash)
            @page_builder.add(@schema.map {|column| tweet.has_key?(column.name) ? tweet[column.name].to_s : ''})
            if count > 0
              count -= 1
              if count == 0
                raise StopStreamException if count == 0
              end
            end
          end
        end
      rescue StopStreamException
      end
      @page_builder.finish
      commit_report = {}
      return commit_report
    end
  end
end
