require 'spec_helper'

describe PeopleFiltersController do
  
  before { sign_in(people(:top_leader)) }
  
  let(:group) { groups(:top_group) }
  let(:role_types) { ['Group::TopGroup::Leader', 'Group::TopGroup::Member'] } 
  
  context "GET new" do
    it "builds entry with group and existing params" do
      get :new, group_id: group.id, people_filter: {role_types: role_types}
      
      filter = assigns(:people_filter)
      filter.group.should == group
      filter.role_types.should == role_types
    end
  end
  
  context "POST create" do
    it "redirects to show for search" do
      expect {
        post :create, group_id: group.id, people_filter: {role_types: role_types, kind: 'layer'}, button: 'search'
      }.not_to change { PeopleFilter.count } 
      
      should redirect_to(group_people_path(group, role_types: role_types, kind: 'layer'))
    end
    
    it "saves filter and redirects to show with save" do
      expect {
        post :create, group_id: group.id, people_filter: {role_types: role_types, kind: 'layer', name: 'Test Filter'}, button: 'save'
        should redirect_to(group_people_path(group, role_types: role_types, kind: 'layer', name: 'Test Filter'))
      }.to change { PeopleFilter.count }.by(1)
    end
    
    context "with read only permissions" do
      before do
        @role = Fabricate(Group::BottomLayer::Member.name.to_sym, group: groups(:bottom_layer_one))
        @person = @role.person
        sign_in(@person)
      end 
        
      let(:group) { @role.group }
      
      it "redirects to show with search" do
        expect {
          post :create, group_id: group.id, people_filter: {role_types: role_types, kind: 'layer'}, button: 'search'
        }.not_to change { PeopleFilter.count } 
        
        should redirect_to(group_people_path(group, role_types: role_types, kind: 'layer'))
      end
      
      it "is not authorized with save" do
        expect {
          post :create, group_id: group.id, people_filter: {role_types: role_types, kind: 'layer', name: 'Test Filter'}, button: 'save'
        }.not_to change { PeopleFilter.count }
        
        should redirect_to(root_path)
      end
    end
  end
  
end