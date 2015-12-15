# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Person::AddRequest::Creator
  class Event < Base

    alias_method :role, :entity

    def required?
      role.participation.new_record? && super()
    end

    def body
      role.participation.event
    end

    def person
      role.participation.person
    end

    def request_attrs
      super.merge(role_type: role.type)
    end

  end
end