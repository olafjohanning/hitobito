class Group::StateWorkGroup < Group::WorkGroup

  class Leader < Group::WorkGroup::Leader
  end
  
  class Member < Group::WorkGroup::Member
  end
  
  roles Leader, Member
  
end