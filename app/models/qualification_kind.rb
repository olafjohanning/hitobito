# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# == Schema Information
#
# Table name: qualification_kinds
#
#  id             :integer          not null, primary key
#  label          :string(255)      not null
#  validity       :integer
#  description    :string(1023)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#  reactivateable :integer
#

#
class QualificationKind < ActiveRecord::Base

  acts_as_paranoid
  extend Paranoia::RegularScope

  attr_accessible :label, :validity, :description, :reactivateable


  ### ASSOCIATIONS

  has_many :qualifications


  has_and_belongs_to_many :event_kinds, join_table: 'event_kinds_qualification_kinds',
                                        class_name: 'Event::Kind',
                                        association_foreign_key: :event_kind_id
  has_and_belongs_to_many :preconditions, join_table: 'event_kinds_preconditions',
                                          class_name: 'Event::Kind',
                                          association_foreign_key: :event_kind_id
  has_and_belongs_to_many :prolongations, join_table: 'event_kinds_prolongations',
                                          class_name: 'Event::Kind',
                                          association_foreign_key: :event_kind_id

  ### VALIDATES

  validate :assert_validity_when_reactivateable

  ### INSTANCE METHODS

  def to_s(format = :default)
    label
  end

  # Soft destroy if events exist, otherwise hard destroy
  def destroy
    if qualifications.exists?
      super
    else
      destroy!
    end
  end


  private

  def assert_validity_when_reactivateable
    if reactivateable.present? && (validity.to_i <= 0)
      errors.add(:validity,
                 'muss einen positive Zahl sein um die ' +
                 "#{self.class.model_name.human} reaktivierbar zu machen.")
    end
  end

end
