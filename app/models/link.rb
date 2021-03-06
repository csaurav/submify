# == Schema Information
#
# Table name: links
#
#  id             :integer          not null, primary key
#  url_link       :string(255)
#  url_heading    :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  picture        :string(255)
#  comments_count :integer          default(0)
#  description    :text
#

#
# Submify - Dashboard of web and web activity
# Copyright (C) 2013 Vysakh Sreenivasan <support@submify.com>
#
# This file is part of Submify.
#
# Submify is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Submify is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Submify.  If not, see <http://www.gnu.org/licenses/>.
#
require 'uri'
require 'open-uri'

class Link < ApplicationModel

  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :url_link,:url_heading, :description
  has_many :flags, as: :flaggable
  has_many :link_users, foreign_key: "link_id", dependent: :destroy
  has_many :users, through: :link_users, source: :user

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :topics, through: :link_users, source: :topic

  validates :url_link, uniqueness: true

  def link_with_topic!(topic_name, user, topic_page)
    topic_slug = topic_name.to_s.parameterize
    if topic_page
      topic = topic_page
    elsif topic = Topic.find_by_slug(topic_slug)
    else
      topic = Topic.create!(name: topic_name)
    end
     LinkUser.create!(topic_id: topic.id, user_id: user.id, link_id: self.id)
  end

  def self.search(params)

    tire.search(load: true) do
      query { string params[:q], default_operator: "OR" } if params[:q].present?
      #    filter :range, published_at: {lte: Time.zone.now}
    end
    # raise to_curl
  end


  def to_param
    "#{id} #{url_heading}".parameterize
  end
end
