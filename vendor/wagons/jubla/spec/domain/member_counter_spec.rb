require 'spec_helper'

describe MemberCounter do
  
  let(:flock) { groups(:bern) }

  subject { MemberCounter.new(2012, flock) }
  
  before do
    asterix = groups(:asterix)
    obelix = groups(:obelix)
    leader = Fabricate(Group::Flock::Leader.name, group: flock, person: Fabricate(:person, gender: 'w', birthday: '1985-01-01'))
    guide = Fabricate(Group::Flock::Guide.name, group: flock, person: Fabricate(:person, gender: 'm', birthday: '1989-01-01'))
    Fabricate(Group::ChildGroup::Leader.name, group: asterix, person: Fabricate(:person, gender: 'w', birthday: '1988-01-01'))
    Fabricate(Group::ChildGroup::Leader.name, group: obelix, person: guide.person)
    Fabricate(Group::ChildGroup::Child.name, group: asterix, person: Fabricate(:person, gender: 'w', birthday: '1999-01-01'))
    Fabricate(Group::ChildGroup::Child.name, group: asterix, person: Fabricate(:person, gender: 'm', birthday: '1999-01-01'))
    Fabricate(Group::ChildGroup::Child.name, group: obelix, person: Fabricate(:person, gender: 'w', birthday: '1999-02-02'))
    # external roles, not counted
    Fabricate(Jubla::Role::External.name, group: obelix, person: Fabricate(:person, gender: 'm', birthday: '1971-01-01'))
    Fabricate(Group::Flock::Coach.name, group: flock, person: Fabricate(:person, gender: 'w', birthday: '1972-01-01'))
  end

  its(:state) { should == groups(:be) }
  
  its(:members) { should have(6).items }
  
  its(:excluded_role_types) { should =~ %w(Group::Flock::Coach 
                                           Group::Flock::Advisor 
                                           Jubla::Role::External)}
                                           
  it "creates member counts" do
    expect { subject.count! }.to change { MemberCount.count }.by(4)
    
    assert_member_counts(1985, 1, nil, nil, nil)
    assert_member_counts(1988, 1, nil, nil, nil)
    assert_member_counts(1989, nil, 1, nil, nil)
    assert_member_counts(1999, nil, nil, 2, 1)
  end
  
  def assert_member_counts(born_in, leader_f, leader_m, child_f, child_m)
    count = MemberCount.where(state_id: groups(:be).id, flock_id: flock.id, year: 2012, born_in: born_in).first
    count.leader_f.should == leader_f
    count.leader_m.should == leader_m
    count.child_f.should == child_f
    count.child_m.should == child_m
  end
                                          
end