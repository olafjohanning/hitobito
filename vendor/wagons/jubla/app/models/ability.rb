class Ability
  include CanCan::Ability

  def initialize(user)
    @groups_group_full = user.groups_with_permission(:group_full)
    @groups_layer_full = user.groups_with_permission(:layer_full)
    @groups_layer_read = user.groups_with_permission(:layer_read)
    
    
    if show_person_permissions?
      layers_read = layers(@groups_layer_full, @groups_layer_read)
      
      # View all person details
      can :show, Person do |person|
        # user has group_full, person in same group
        (person.groups & @groups_group_full).present? ||
        
        (layers_read.present? &&
          # user has layer_full or layer_read, person in same layer
          ((layers_read & person.layer_groups).present? ||
  
          # user has layer_full or layer_read, person below layer and visible_from_above
          (layers_read & person.above_groups_visible_from).present?
          ))
      end
    end
      
    if manage_person_permissions?
      layers_full = layers(@groups_layer_full)
      
      can :manage, Person do |person|
        # user has group_full, person in same group
        (person.groups & @groups_group_full).present? ||
        
        (layers_full.present? &&
          # user has layer_full, person in same layer
          ((layers_full & person.layer_groups).present? ||
          
          # user has layer_full, person below layer and visible_from_above
          (layers_full & person.above_groups_visible_from).present?
          ))
      end
      
    end
    
    # List / view contact data
    can :index, Person do |person|
      # can show person
      # user has contact_data, person has contact_data
      # person in same group
    end
    
    
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
  
  private
  
  def show_person_permissions?
    @groups_group_full.present? || @groups_layer_full.present? || @groups_layer_read.present?
  end
  
  def manage_person_permissions?
    @groups_group_full.present? || @groups_layer_full.present?
  end
  
  def layers(*groups)
    groups.flatten.collect(&:layer_group).uniq
  end
end